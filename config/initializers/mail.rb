# Currently using GMAIL SMTP
# Uncomment for Mandrill Mailer
ActionMailer::Base.smtp_settings = {
    :address   => 'mail.mq.edu.au',
    :port      => 25,
    :enable_starttls_auto => true, # detects and uses STARTTLS
    # :user_name => ENV['MANDRILL_USERNAME'],
    # :password  => ENV['MANDRILL_PASSWORD'],
    :authentication => 'plain', # Mandrill supports 'plain' or 'login'
    :domain    => 'coraltraits.org'
  }
ActionMailer::Base.delivery_method = :smtp

# MandrillMailer.configure do |config|
#   config.api_key = ENV['MANDRILL_API_KEY']
# end
