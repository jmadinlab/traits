# Currently using GMAIL SMTP
# Uncomment for Mandrill Mailer
ActionMailer::Base.smtp_settings = {
    :address   => 'smtp.mandrillapp.com',
    :port      => 2525,
    :enable_starttls_auto => true, # detects and uses STARTTLS
    :user_name => ENV['MANDRILL_USERNAME'],
    :authentication => 'login', # Mandrill supports 'plain' or 'login'
    :password  => ENV['MANDRILL_PASSWORD'],
    :domain    => 'coraltraits.org'
  }
ActionMailer::Base.delivery_method = :smtp

MandrillMailer.configure do |config|
  config.api_key = ENV['MANDRILL_API_KEY']
end
