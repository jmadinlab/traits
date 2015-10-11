# Currently using GMAIL SMTP
# Uncomment for Mandrill Mailer
ActionMailer::Base.smtp_settings = {
    :address   => 'smtp.mandrillapp.com',
    :port      => 465,
    :user_name => ENV['MANDRILL_USERNAME'],
    :password  => ENV['MANDRILL_PASSWORD'],
    :domain    => 'coraltraits.org',
    :ssl       => true
  }
ActionMailer::Base.delivery_method = :smtp

MandrillMailer.configure do |config|
  config.api_key = ENV['MANDRILL_API_KEY']
end
