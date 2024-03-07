class DaisyBuilder < ActionView::Helpers::FormBuilder
  include ActionView::Helpers::TagHelper
  # include ActionView::Context

  def label(attribute, text = nil, options = {}, &)
    return super(attribute, text, options.reverse_merge(class: 'label label-summer'), &) if block_given?

    super(attribute, options.reverse_merge(class: 'label label-summer')) do |builder|
      content_tag(:span, text.presence || builder.translation, class: 'label-text')
    end
  end

  def email_field(attribute, options = {})
    super(attribute, options.reverse_merge(class: 'input input-summer'))
  end

  def text_field(attribute, options = {})
    super(attribute, options.reverse_merge(class: 'input input-summer'))
  end

  def password_field(attribute, options = {})
    super(attribute, options.reverse_merge(class: 'input input-summer'))
  end

  def check_box(attribute, options = {})
    super(attribute, options.reverse_merge(class: 'checkbox'))
  end

  def submit(attribute, options = {})
    super(attribute, options.reverse_merge(class: 'btn'))
  end

  def text_area(attribute, options = {})
    super(attribute, options.reverse_merge(class: 'textarea textarea-bordered'))
  end
end
