ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.raise_delivery_errors = true
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.logger = Logger.new(STDOUT)
ActionMailer::Base.view_paths = File.dirname(__FILE__)
yml_config = YAML.load(File.read(File.join(APP_PATH, 'mailer_config.yml')))
cofig = yml_config['mailer_config'].map { |key, value| [key.to_sym, value] }.to_h.merge(authentication: :plain, tls: true)
ActionMailer::Base.smtp_settings = cofig
class Notifier < ActionMailer::Base
  default from: '343776794@qq.com', to: ['xxxxx@qq.com']

  def bing(mail_title, main_file, sub_text, side_pics)
    attachments['main_file.jpg'] = File.read(main_file.path)
    @sub_text = sub_text
    @mail_title = mail_title
    @side_pics = side_pics
    @side_pics.each_with_index do |item, _index|
      attachments["#{item[:title]}.jpg"] = File.read(item[:file].path)
    end

    mail(subject: '必应图片') do |format|
      format.html { render :bing_email }
    end
  end
end
