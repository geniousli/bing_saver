class BingSaver
  attr_accessor :days_ago, :conn

  def initialize(day = 0)
    @days_ago = day
    @conn = Faraday.new(:url => 'http://cn.bing.com') do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      faraday.response :logger                  # log requests to STDOUT
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
  end

  def deliver()
    email = Notifier.bing(main_title, main_file, sub_text, side_pics)
    email.deliver
  end

  private

  def side_pics
    side_pics = side_response_body.css('.hplaCard').map.each_with_index do |item, index|
      title = item.css('.hplatt').first.text
      text = item.css('.hplatxt').first.text
      image_url = item.css('img').last.attributes['src'].value
      file = Tempfile.new([index.to_s, '.jpg'])
      file.binmode
      file.write(open(image_url).read)
      file.close
      {title: title, content: text, file: file}
    end

    title = side_response_body.css('.hplatt').first.text
    content = side_response_body.css('#hplaSnippet').first.text
    url =
      if side_response_body.css('.hplaDMLink').empty?
        side_response_body.css('#hpla').first.children[1].attributes['src'].value
      else
        side_response_body.css('.hplaDMLink').first.children.first.attributes['src'].value
      end
    file = Tempfile.new(['1', '.jpg'])
    file.binmode
    file.write(open(url).read)
    file.close
    side_pics.unshift({title: title, content: content, file: file})
    side_pics
  end

  def side_response_body
    unless @side_response_body
      response = conn.get('/cnhp/life', {mkt: 'zh-Cn', IID: 'SERP.5045', IG: '0FD014CDE0EF4E589929E8B32015C6E5', currentDate: days_ago.days.ago.strftime('%Y%m%d')})
      @side_response_body = Nokogiri::HTML(response.body)
    end
    @side_response_body
  end

  def sub_text
    text_ary = side_response_body.css('.hplactc').children.map &:text
    side_response_body.css('.hplactt').to_a.map.each_with_index do |item, index|
      span, image = item.children
      title = span.children.first.text
      {title: title, content: text_ary[index]}
    end
  end

  def main_title
    side_response_body.css('#hplaT').first.text
  end

  def main_file
    response = conn.get("/HPImageArchive.aspx", format: 'js', idx: days_ago, n: 1, nc: Time.now.to_i)
    url = JSON.parse(response.body)['images'].first['url']
    t_file= Tempfile.new()
    t_file.binmode
    t_file.write(open(url).read)
    t_file.close
    t_file
  end
end
