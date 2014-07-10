module Scraping
  class Html
    @search_module = Hash.new
    def initialize
  #    @search_module = {:rakuten => Rakuten.new, :hot = > Hotpepper.new, :kamimado => Kamimado.new}
      @search_module = {:hotpepper => Scraping::Frame::Hotpepper.new, :Rakuten => Scraping::Frame::Rakuten.new}#, :Vivivi => Vivivi.new}
    end

    def open(key, area)
      @search_module.each_value do |model|
        model.http_open(key, area)
      end
    end

    def html
      html_hash = Hash.new
      @search_module.each do |key, model|
        next unless model.get_html?
        html_hash[key] = Hash.new
        html_hash[key] = model.output
      end
      html_hash
    end
  end
end
