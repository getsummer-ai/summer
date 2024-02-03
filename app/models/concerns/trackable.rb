# frozen_string_literal: true

module Trackable
  extend ActiveSupport::Concern
  # Include a concern to track has_many associations changes
  include Trackable::DirtyAssociations

  DEFAULT_UNTRACKABLE_PARAMS = %i[updated_at].freeze

  included do |base|
    # condition for callbacks.
    cattr_accessor :_class_tracking, :_class_tracking_options, :_custom_untrackable_params,
      :_custom_change_formatters
    attr_accessor :_instance_tracking, :_skip_after_save_trackable_callback
    attr_writer :_tracking_options

    has_many :events, as: :trackable, class_name: '::Event'

    # inverse relation.
    # relation_name = base.name.tableize.tr('/', '_').to_sym

    # begin
    #   Event.belongs_to relation_name,
    #     -> { includes(:events).where(events: { trackable_type: base.name }) },
    #     foreign_key: 'trackable_id',
    #     class_name: base.name
    # rescue SyntaxError
    #   relation_name = base.table_name.singularize.to_sym
    #   retry
    # end

    with_options if: :track? do |assoc|
      assoc.after_create :track_creation
      assoc.after_save :track_changes
      assoc.after_destroy :track_removal
    end
  end

  #
  # Extend tracked class.
  #
  class_methods do
    def start_tracking(options = {})
      self._class_tracking = true
      self._class_tracking_options = options.dup
    end

    alias_method :trackable!, :start_tracking

    def stop_tracking
      self._class_tracking = false
      self._class_tracking_options = {}
    end

    def start_tracking_all(records, options)
      records.each { |record| record.start_tracking(options) }
    end

    def stop_tracking_all(records)
      records.each(&:stop_tracking)
    end

    def custom_untrackable_params(params = nil)
      return _custom_untrackable_params.to_a if params.nil?
      self._custom_untrackable_params = params.to_a
    end

    # @yieldparam [String, Boolean, Hash, SmartSettings, Number] old_value
    # @yieldparam [String, Boolean, Hash, SmartSettings, Number] new_value
    # @param [Symbol] attribute
    def track_changes_formatter_for(attribute, &block)
      self._custom_change_formatters ||= {}
      self._custom_change_formatters[attribute] = block
      yield
    end
  end

  def _tracking_options
    @_tracking_options || {}
  end

  # You can disable tracking only for one instance.
  def track?
    _instance_tracking.nil? ? _class_tracking : _instance_tracking
  end

  def track!(options = {})
    start_tracking(options)
    yield
  ensure
    stop_tracking
  end

  def start_tracking(options = {})
    self._tracking_options = options
    self._instance_tracking = true
  end

  def stop_tracking
    self._tracking_options = {}
    self._instance_tracking = false
  end

  # def track_email!(name, options = {})
  #   options = {
  #     category: 'email', subcategory: name.to_s, customer_id: try(:customer_id)
  #   }.merge(options)
  #   create_event(options)
  # end

  def track_creation(options = {})
    options = {
      category: 'log', subcategory: 'create', snapshot: snapshot, project_id: try(:project_id)
    }.merge(_current_tracking_options).merge(options)
    create_event(options)
    self._skip_after_save_trackable_callback = true
  end

  def track_changes(options = {})
    return self._skip_after_save_trackable_callback = false if _skip_after_save_trackable_callback
    options = {
      category: 'log', subcategory: 'update', changes: trackable_changes, project_id: try(:project_id)
    }.merge(_current_tracking_options).merge(options)
    create_event(options) if trackable_changes.present?
  end

  def track_removal(options = {})
    options = {
      category: 'log', subcategory: 'destroy', snapshot: snapshot, project_id: try(:project_id)
    }.merge(_current_tracking_options).merge(options)
    event = build_event(options)
    event.save
    event
  end

  private

    def create_event(options)
      # ::Events::OptionsValidator.new.call(options)
      events.create(options)
      # res.errors.full_messages
    end

    def build_event(options)
      # ::Events::OptionsValidator.new.call(options)
      events.build(options)
    end

    def trackable_changes
      calculated_changes = changes.select { |k, _| k.start_with? 'tracked_' }
      calculated_changes.merge!(saved_changes)
      reload_changed_many_to_many_associations(calculated_changes)

      changed_association_names = _reflections.keys.select do |reflection_name|
        calculated_changes.keys.include? "tracked_#{reflection_name.to_s.singularize}_ids"
      end
      fix_changed_association_ids(changed_association_names, calculated_changes)

      prepared_changes = useful_changes(calculated_changes)
      sanitized_changes(apply_change_formatters(prepared_changes))
    end

    def untrackable_params
      DEFAULT_UNTRACKABLE_PARAMS.map(&:to_s) | self.class.custom_untrackable_params.map(&:to_s)
    end

    def useful_changes(changes)
      changes
        .reject { |key, value| untrackable_params.include?(key.to_s) || value.uniq.count == 1 }
        .transform_keys { |k| k.delete_prefix('tracked_') }
    end

    def apply_change_formatters(changes)
      return changes if self.class._custom_change_formatters.blank?
      formatters = self.class._custom_change_formatters.presence || {}
      changes.each do |key, value|
        formatter = formatters[key.to_sym]
        next if formatter.nil? || !formatter.is_a?(Proc)
        changes[key] = formatter.call(*value)
      end
      changes
    end

    # so all objects will sanitized to json objects: strings, numbers, boolean, hashes, arrays.
    def sanitized_changes(changes)
      changes.transform_values(&:as_json)
    end

    def snapshot
      sanitized_changes attributes_with_changes.merge(model_name: model_name.to_s)
    end

    # Use <attribute>_will_change! for custom methods
    # It will in changes but not in snapshoted attributes for create.
    def attributes_with_changes
      calculated_changes = saved_changes
      attributes.each_with_object({}) do |(key, value), result|
        result[key] = calculated_changes.key?(key) ? calculated_changes[key].to_a.last : value
      end
    end

    # @param [ActiveSupport::HashWithIndifferentAccess] calculated_changes
    def reload_changed_many_to_many_associations(calculated_changes)
      _reflections
        .keys
        .select { |key| calculated_changes.keys.include? "#{key.to_s.singularize}_ids" }
        .each { |key| send(key).reload }
    end

    # Check the difference between trackable_association_ids and association_ids after reload.
    # They can be different if association_ids were set via accepts_nested_attributes_for
    # so in these cases trackable_association_ids can contain - [3, 18, 19, nil]
    # @param [Array<String>] association_names
    # @param [ActiveSupport::HashWithIndifferentAccess] changes
    def fix_changed_association_ids(association_names, changes)
      association_names.each do |key|
        association_ids_name = "#{key.to_s.singularize}_ids"
        name = "tracked_#{association_ids_name}"
        ids_after_reload = send(association_ids_name)
        changed_to = (changes[name][1].nil? ? [] : changes[name][1]).to_set
        changes[name][1] = ids_after_reload if changed_to != ids_after_reload.to_set
      end
    end

    #
    # Active tracking options for the model. Combined from class then instance options.
    #
    # @return [Hash]
    #
    def _current_tracking_options
      (_class_tracking_options || {}).merge(_tracking_options || {})
    end
end
