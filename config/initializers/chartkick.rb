# frozen_string_literal: true

if defined?(Chartkick)

  module ChartkickMixinJavascriptFunctions
    FUNCTION_NAME_DELIMITER = 'FN_NAME'
    FUNCTION_START = 'FN_START'
    FUNCTION_END = 'FN_END'

    module Helper
      def chartkick_js_function_name(fn)
        "#{FUNCTION_NAME_DELIMITER}#{fn}"
      end

      def chartkick_js_inline(js)
        "#{FUNCTION_START}#{js}#{FUNCTION_END}"
      end

      private
        def chartkick_chart(...)
          rendered = super

          rendered
            .gsub(/"#{FUNCTION_NAME_DELIMITER}([^""]+?)"/o, '\1')
            .gsub(/"#{FUNCTION_START}(.+?)#{FUNCTION_END}"/o, '\1')
            .gsub('\"', '"')
            .html_safe
        end

    end
  end

  Chartkick::Helper.prepend ChartkickMixinJavascriptFunctions::Helper
end
