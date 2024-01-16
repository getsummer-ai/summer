# frozen_string_literal: true
module CustomTagsHelper
  def turbo_conditional_tag(name, condition, &)
    return turbo_frame_tag(name, &) if condition
    capture(&)
  end
end
