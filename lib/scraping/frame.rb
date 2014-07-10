require 'nokogiri'
require 'open-uri'

module Scraping
  module Frame
    def http_open(source)
      @list = source
    end
    def get_html?
      @list.present?
    end
    def output
      @list
    end
  end
end
