module Scraping
  module Frame
    class Hotpepper
      include Scraping::Frame
      URL="http://beauty.hotpepper.jp/CSP/bt/freewordSearch/?freeword="
      #URL="http://localhost:3000"
      def http_open(key, area_code = nil)
        # hotpepperのリスト取得path
        # xpath('//body/div/div[@id="contents"]/div[@id="mainContents"]/ul[@id="listWrapper oh"]')
        # その後
        # count = 0
        # xx.children.each do |i|
        #   next if i.present?
        #   a[count] = i
        #   count += 1
        # end
        # 上記で各リストを配列でもたせることが出来る
        # エリア別設定
        # URL: serviceAreaCd=州のコード
        # エリア別コード
        # 北海道:SD
        # 北信越:SH
        # 東北:SE
        # 関東:SA
        # 東海:SC
        # 関西:SB
        # 中国:SF
        # 四国:SI
        # 九州・沖縄:SG
        #
        @list = Hash.new
        super(@list)
        url = "#{URL}#{key}"
        if area_code
          url.concat("&serviceAreaCd=#{area_code}")
        end
        Rails.logger.info "request rakuten url: #{url}"
        arr_list = Array.new
        begin
          html = Nokogiri::HTML(open(url))
          lists = html.xpath('//body/div/div[@id="contents"]/div[@id="mainContents"]/ul[@id="listWrapper oh"]')
          lists.children.each do |i|
            next unless i.present?
            arr_list.push(i)
          end
          arr_list.each_with_index do |value, key|
            @list[key] = Hash.new
            @list[key][:title] = value.css('h3').css('a').inner_text
            @list[key][:url] = value.css('h3').css('a').attribute('href').value
            @list[key][:img] = value.css('div').css('a').css('img').attribute('src').value
            @list[key][:description] = value.css('p[@class="shopCatchCopy"]').css('a').inner_text
          end
          rescue Exception => e
            Raisl.logger.error e.message
          end
      end
    end
  end
end
