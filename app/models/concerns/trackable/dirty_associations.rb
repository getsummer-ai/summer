# frozen_string_literal: true

module Trackable
  #
  # Track changes for has_many and HABTM associations.
  #
  module DirtyAssociations
    extend ActiveSupport::Concern

    # Extend trackable class with associations tracking
    module ClassMethods
      #
      # Init tracking for each association that needs events logging
      #
      # @param [Array<Symbol>] *associations
      #
      def track(*associations)
        associations.each { |association| _initialize_association_tracking(association) }
      end

      #
      # Add callbacks on a class to track association changes
      #
      def _initialize_association_tracking(association)
        name = association.to_s

        # Define an attribute to store tracked ids
        attribute :"tracked_#{name.singularize}_ids"

        # Get ActiveRecord version
        before_callback = _ar_before_callback(association)
        after_callback = _ar_after_callback(association)

        # Define callbacks for adding/removing associations
        send(:"before_add_for_#{name}") << before_callback
        send(:"before_remove_for_#{name}") << before_callback
        send(:"after_add_for_#{name}") << after_callback
        send(:"after_remove_for_#{name}") << after_callback
      end

      def _ar_before_callback(association)
        lambda do |_action, base_model, _association_model|
          return unless base_model.track?

          attribute_name_ids = "#{association.to_s.singularize}_ids"
          tracked_attribute_name_ids = "tracked_#{attribute_name_ids}"

          attributes = base_model.send(:mutations_from_database).send(:attributes)
          return unless attributes[tracked_attribute_name_ids].value_for_database.nil?

          attributes[tracked_attribute_name_ids] = ActiveModel::Attribute.from_database(
            tracked_attribute_name_ids,
            base_model.public_send(attribute_name_ids).dup,
            ActiveModel::Type::Value.new
          )
        end
      end

      def _ar_after_callback(association)
        lambda do |_action, base_model, _association_model|
          return unless base_model.track?

          attribute_name_ids = "#{association.to_s.singularize}_ids"
          tracked_attribute_name_ids = "tracked_#{attribute_name_ids}"

          current_value = base_model.send(attribute_name_ids).dup
          attributes = base_model.send(:mutations_from_database).send(:attributes)
          attributes.write_from_user(tracked_attribute_name_ids, current_value)
        end
      end
    end

    private

      def assign_nested_attributes_for_collection_association(name, attributes)
        if attributes.present? &&
            self.class.reflect_on_association(name).klass.include?(Trackable)
          attributes = nested_attributes_with_tracking(nested_attributes: attributes)
        end

        super(name, attributes)
      end

      def assign_nested_attributes_for_one_to_one_association(name, attributes)
        if attributes.present? &&
            self.class.reflect_on_association(name).klass.include?(Trackable)
          attributes = nested_attributes_with_tracking(nested_attributes: attributes)
        end

        super(name, attributes)
      end

      def nested_attributes_with_tracking(nested_attributes:)
        tracking_attributes = { _instance_tracking:,
                                _tracking_options: _current_tracking_options }

        if nested_attributes.respond_to?(:each_pair)
          if nested_attributes.keys.map(&:to_s).include?('id')
            nested_attributes = nested_attributes.merge(tracking_attributes)
          elsif nested_attributes.keys.map { |k| k =~ /^\d+$/ }.exclude? nil
            nested_attributes.values.each { |attributes| attributes.merge!(tracking_attributes) }
          else # one to one
            nested_attributes = nested_attributes.merge(tracking_attributes)
          end
        else
          nested_attributes.each { |attributes| attributes.merge!(tracking_attributes) }
        end

        nested_attributes
      end
  end
end
