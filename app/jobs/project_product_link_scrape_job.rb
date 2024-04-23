# frozen_string_literal: true
class ProjectProductLinkScrapeJob < ApplicationJob
  queue_as :default

  def self.perform(*args)
    new.perform(*args)
  end

  # @param [Integer] id
  def perform(id)
    model = ProjectProduct.skip_retrieving(:icon).find(id)

    model.update!(icon: nil, meta: { title: nil, description: nil, image: nil })
    scraped = WebScrapperService.new(model.link).scrape
    model.update!(
      meta: {
        title: scraped.title,
        description: scraped.description,
        image: scraped.image_url
      }
    )

    return if scraped.image_url.nil?

    image_url = prepare_image_url(model.link, scraped.image_url)
    tempfile = Down.download(image_url, max_size: 5 * 1024 * 1024)
    cropped_webp_image = crop_image(tempfile)
    model.update!(icon: cropped_webp_image.read)
  end

  private

  def prepare_image_url(link, image_path)
    return image_path if image_path.start_with?("http")

    uri = URI.parse(link)
    "#{uri.scheme}://#{uri.host}#{image_path}"
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
