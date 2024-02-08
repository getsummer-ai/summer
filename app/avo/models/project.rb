# frozen_string_literal: true

module Avo
  module Models
    class Project < ::Project
      has_many :all_events, class_name: 'Event', foreign_key: 'project_id'

      def to_param
        id
      end
    end
  end
end
