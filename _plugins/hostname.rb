require 'uri'

module Jekyll
  module HostnameFilter
    def hostname(input)
      parsed_uri = URI.parse(input)
      parsed_uri.host
    end
  end
end

Liquid::Template.register_filter(Jekyll::HostnameFilter)
