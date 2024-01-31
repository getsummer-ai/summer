# frozen_string_literal: true
class ProjectArticleForm
  include ActiveModel::Validations

  attr_accessor :url
  validates :url, url: true

  # @param [Project] project
  # @param [String] url
  def initialize(project, url)
    # @type [Project]
    @project = project
    @url = url.to_s.gsub(/&?utm_.+?(&|$)/, '').chomp('?')
    @hashed_url = Hashing.md5(@url)
  end

  # @return [ProjectArticle, nil]
  def find_or_create
    return nil if invalid?
    project_url = @project.project_urls.find_by(url_hash: @hashed_url)
    return project_url.project_articles.only_required_columns.take if project_url.present?
    create_or_find_article
  rescue StandardError => e
    Rails.logger.error e.message
    nil
  end

  # @return [ProjectArticle, nil]
  def create_or_find_article
    article = nil
    article_hash = Hashing.md5(scraped_article.content)
    ActiveRecord::Base.transaction do
      project_url = @project.project_urls.create!(url: @url, url_hash: @hashed_url)
      article =
        @project
          .project_articles
          .where(article_hash:)
          .first_or_create(
            article: scraped_article.content,
            title: scraped_article.title,
            article_hash:,
            title_hash: Hashing.md5(scraped_article.title),
            summary:
              "**Summary: Why Invoice is So Important for Correct Accounting**

- **Introduction:**
  - Invoicing is a routine process for companies but involves complexities such as applying taxes and structuring invoices.
  - Incorrect invoices can lead to accounting mistakes and fines.

- **Purpose of Accounting:**
  - Accounting is a means of communication between a company and the government, ensuring businesses pay taxes and comply with standards.
  - Government uses accounting reports and taxes to monitor financial transactions and conduct audits.

- **Importance of Invoices:**
  - Invoices transform financial transactions into accounting records and provide details of goods or services exchanged for money.
  - Invoices are not legal contracts but one-sided documents requesting payment.
  - Key information on invoices includes invoice number, dates, counterparties' details, product or service details, costs, taxes, and place of service.

- **Structuring Invoices:**
  - Invoices should follow a systematic numbering system, aiding in tracking payments and managing overdue invoices.
  - Invoicing changes, updates, and deletions impact income and should be integrated into the invoicing system.

- **Additional Purposes of Invoices:**
  - Invoices serve as a measure of a company's performance, assisting accountants, directors, and financial institutions.
  - They are essential for internal and external audits and can be provided to reassure creditors and business partners about the company's financial position.

- **Invoice Alternatives:**
  - Some countries allow simplified invoices or exemptions for specific activities.
  - Alternatives to traditional invoices include checks, bills, receipts, with varying purposes and requirements.

- **Organizing Invoice Management:**
  - Properly organizing the invoicing process is crucial for businesses.
  - Options include manually creating invoices, using invoicing services and setting up invoicing systems, or utilizing specialized platforms like Enty for automation.
  - Enty's Control Panel provides templates created by professionals, and with an accounting subscription, tax reports are automatically generated based on issued invoices, saving time and ensuring accuracy.",
          )
      article.project_urls << project_url
    end
    article
  end

  # @return [::ArticleScrapperService]
  def scraped_article
    @scraped_article ||= ArticleScrapperService.new(url).scrape
  end
end
