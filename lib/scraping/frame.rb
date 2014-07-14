require 'nokogiri'
require 'open-uri'
require 'uri'

module Scraping
  module Frame
    def http_open(source)
      @list = source
    end
    def get_html?
      @list.present?
    end
    def output
      no_price = Array.new
      data = Hash.new
      @list.each do |k,v|
        if v[:price].blank?
          no_price.push(v)
        else
          data.store(k,v)
        end
      end
      data_source = data.sort_by {|k,v| v[:price].to_i}
      no_price.each{ |v| data_source[data_source.size] = [data_source.size, v]}
      data_source
    end
  end
end
