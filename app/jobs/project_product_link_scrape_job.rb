# frozen_string_literal: true
class ProjectProductLinkScrapeJob < ApplicationJob
  queue_as :default
  # retry_on StandardError, attempts: 2

  def self.perform(*args)
    new.perform(*args)
  end

  # @param [Integer] id
  def perform(id)
    model = ProjectProduct.skip_retrieving(:icon).find(id)

    scraped = WebScrapperService.new(model.link).scrape
    model.update!(
      meta: {
        title: scraped.title,
        description: scraped.description,
        image: scraped.image_url
      }
    )

    return if scraped.image_url.nil?

    tempfile = Down.download(scraped.image_url, max_size: 5 * 1024 * 1024)
    cropped_webp_image = crop_image(tempfile)
    model.update!(icon: cropped_webp_image.read)
  end

  # @param [Tempfile] tempfile
  # @return [Tempfile]
  def crop_image(tempfile)
    ImageProcessing::Vips.source(tempfile)
      .resize_to_fit(100, 60)
      .saver(quality: 85)
      .convert("webp")
      .call
  end
end
