# frozen_string_literal: true
class CheckProjectRequestForm
  include ActiveModel::Validations

  attr_accessor :project, :origin, :referer
  validates :project, presence: true
  validates :origin, url: true, if: ->{ origin.present? }
  validates :referer, url: true, if: ->{ origin.blank? }

  # @param [Project] project
  # @param [String, nil] origin
  # @param [String, nil] referer
  def initialize(project, origin, referer)
    # @type [Project]
    @project = project
    @origin = origin
    @referer = referer
  end

  def valid?(*)
    super
    return false if errors.any?
    request_from_url = @origin.presence || @referer.presence

    request_host = Project.parse_url(request_from_url)&.host

    @project.valid_host?(request_host)
  end
end
