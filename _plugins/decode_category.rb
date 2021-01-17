require "URI"

module CustomFilter
    def decode_category(input)
        URI.decode_www_form(input)
    end
end

Liquid::Template.register_filter(CustomFilter)