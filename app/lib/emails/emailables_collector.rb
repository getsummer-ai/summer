# frozen_string_literal: true
module Emails
  #
  # Collects +ActiveRecord+ models from given instance variable
  #
  class EmailablesCollector
    attr_accessor :instance

    def initialize(instance, excluded = [])
      @instance = instance
      @excluded_models = Array.wrap(excluded)
    end

    #
    # Collect models from instance
    #
    # @return [Array] array of models
    def perform
      @instance.instance_values.values.each_with_object([]) do |v, c|
        model = model_from_instance_value v
        c << model if model.present? && @excluded_models.exclude?(model.class.name)
      end.uniq
    end

    #
    # Extract model object from instance variable
    #
    # @param [Object] value instance variable
    #
    # @return [Object, nil] model instance
    #
    def model_from_instance_value(value)
      return value if value.class < ApplicationRecord
      return value.object if value.is_a?(Draper::Decorator)
      nil
    end
  end
end
