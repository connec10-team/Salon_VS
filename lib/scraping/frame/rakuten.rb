module Scraping
  module Frame
    class Rakuten
      include Scraping::Frame
      URL = "http://salon.rakuten.co.jp"
      AREACODE = {
        "SA" => "kanto",
        "SB" => "kansai",
        "SC" => "hokushinetsu_tokai",
        "SD" => "hokkaido",
        "SE" => "tohoku",
        "SF" => "chugoku_shikoku",
        "SG" => "kyushu_okinawa",
        "SH" => "hokushinetsu_tokai",
        "SI" => "chugoku_shikoku"
        }

      def http_open(key, area_code = nil)
        # エリア別設定
        # URL: salonsearch/エリア別code
        # 北海道:hokkaido
        # 東北:tohoku
        # 北信越・東海:hokushinetsu_tokai
        # 関東:kanto
        # 関西:kansai
        # 中国・四国:chugoku_shikoku
        # 九州・沖縄:kyushu_okinawa
        # フリーワード
        # url:w[f_w]=フリーワード
        # b = a.xpath('//body/div[@id="container"]/div[@id="wrapper"]/div[@id="content"]/div[@id="searchResult"]/div[@id="resultSection"]')
        # b.children.each do |i|
        #   next unless i.present?
        #   arr_list.puts(i)
        # end
        @list = Hash.new
        super(@list)
        url = "#{URL}/salonsearch/#{AREACODE[area_code]}"
        url.concat("?w[f_w]=#{key}")
        Rails.logger.info "request rakuten url: #{url}"
        arr_list = Array.new
        begin
          html = Nokogiri::HTML(open(url))
          lists = html.xpath('//body/div[@id="container"]/div[@id="wrapper"]/div[@id="content"]/div[@id="searchResult"]/div[@id="resultSection"]')
          lists.children.css('div[@class="resultbaseBox"]').each do |i|
            next unless i.present?
            arr_list.push(i)
          end
          arr_list.each_with_index do |value, key|
            @list[key] = Hash.new
            @list[key][:title] = value.css('div[@class="baseBoxHeader"]').css('dl[@class="basedate"]').css('dt[@class="title"]').css('a').inner_text
            @list[key][:url] = URL + value.css('div[@class="baseBoxHeader"]').css('dl[@class="basedate"]').css('dt[@class="title"]').css('a').attribute('href').value
            @list[key][:img] = value.css('div[@class="baseBoxBody"]').css('div[@class="shopInfo"]').css('div[@class="shopImg"]').css('img').attribute('src').value
            @list[key][:description] = value.css('div[@class="baseBoxBody"]').css('p[@class="shopLead"]').css('a').inner_text
          end
        rescue Exception => e
          Rails.logger.error e.message
        end
      end
    end
  end
end
