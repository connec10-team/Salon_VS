module Scraping
  module Frame
    class Vivivi
      include Scraping::Frame
      URL = "http://www.vi-vi-vi.com"
      def http_open(key)
        # b = a.xpath('//body/div/div/div[@class="pos_r clearfix"]/div[@class="clearfix"]/div[@id="shop_main"]')
        # b.children.css('div[@class="outer_shop_li"]').each do |i|
        #   next unless i.present?
        # end
        url = "#{URL}/fword#{key}/"
        Rails.logger.info "rewuest vivivi url: #{url}"
        @list = Hash.new
        arr_list = Array.new
        begin
          html = Nokogiri::HTML(open(url))
          lists = html.xpath('//body/div/div/div[@class="pos_r clearfix"]/div[@class="clearfix"]/div[@id="shop_main"]')
          lists.children.css('div[@class="outer_shop_li"]').each do |i|
            next unless i.present?
            arr_list.push(i)
          end
          arr_list.each_with_index do |value, key|
            @list[key] = Hash.new
            @list[key][:title] = value.css('div').css('div').css('div').css('h4').inner_text
            @list[key][:url] = URL+ value.css('div').css('div').css('div').css('h4').css('a').attribute('href').value
            @list[key][:img] = value.css('div').css('div[@class="shop_list_inner clearfix"]').css('div[@class="bp_spc10 b_spc10 clearfix"]').css('div[@class="thumb_large"]').css('img').attribute('src').value
            #@list[key][:description] = value.css('div').css('div[@class="shop_list_inner clearfix"]').css('div[@class="bp_spc10 b_spc10 clearfix"]').css('div[@class="shop_txt b_spc5"]').inner_text
            @list[key][:description] = value.css('div').css('div[@class="shop_list_inner clearfix"]').css('div[@class="bp_spc10 b_spc10 clearfix"]').css('div[@class="shop_txt b_spc5"]').css('h5').inner_text
          end
        rescue Exception => e
          Rails.logger.error e.message
        end
      end
    end
  end
end
