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
        # vivivi情報がある時は取得がおかしくなる
        @list = Hash.new
        super(@list)
        url = "#{URL}/salonsearch/#{AREACODE[area_code]}"
        url.concat("?w[f_w]=#{URI.escape(key)}")
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
            set_menu(key,value.css('div[@class="baseBoxBody"]').css('div[@class="shopBookMenu"]').css('div[@class="salonMenu"]').css('ul[@class="menuList"]').css('li'))
          end
        rescue Exception => e
          Rails.logger.error e.message
        end
      end

      def set_menu(key, value)
        cache = extraction(value)
        menu = menu_selection(cache)
        @list[key][:menus] = menu
      end

      def menu_selection(cache)
        cut = Array.new
        normal = Array.new
        cache.each do |i|
          if i[:title].index(/カット/)
            i[:type] = :cut
            cut.push(i)
          else
            i[:type] = :normal
            normal.push(i)
          end
        end
        count = max_count - cut.size
        if count > 0
          1.upto(count) do |i|
            cut.push(normal[i-1])
          end
        end
        cut
      end

      def extraction(value)
        cache = Array.new
        value.each do |i|
          h = Hash.new
          h[:title] = i.css('a').inner_text
          idx = i.css('dd[@class="price"]').inner_text
          if idx.blank?
            h[:price] = ""
          else
            h[:price] = idx.gsub(/[^0-9]/,"")
          end
          cache.push(h)
        end
        price_sort(cache)
      end

      def price_sort(value)
        no_price = Array.new
        price = Array.new
        value.each do |i|
          if i[:price].blank?
            no_price.push(i)
          else
            price.push(i)
          end
        end
        data = price.sort_by {|i| i[:price].to_i}
        no_price.each {|v| data[data.size] = v}
        data
      end
    end
  end
end
