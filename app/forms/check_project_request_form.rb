# frozen_string_literal: true
class CheckProjectRequestForm
  include ActiveModel::Validations

  attr_accessor :project, :origin, :referer
  validates :project, presence: true
  validates :origin, url: true, if: ->{ origin.present? }
  validates :referer, url: true, if: ->{ origin.blank? }

  # @param [Project] project
  # @param [String] origin
  # @param [String] referer
  def initialize(project, origin, referer)
    # @type [Project]
    @project = project
    @origin = origin
    @referer = referer
  end

  def valid?(*args)
    super(*args)
    return false if errors.any?
    request_from_url = @origin.presence || @referer.presence

    request_host = Project.parse_url(request_from_url)&.host

    clean_from_www(request_host) == clean_from_www(@project.domain)
  end

  # @param [String, nil] domain
  def clean_from_www(domain)
    # return domain.to_s.delete_prefix('www.') if domain.to_s.start_with?('www.')
    # domain
    domain.to_s.delete_prefix('www.')
  end
end
