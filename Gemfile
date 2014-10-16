source 'https://rubygems.org'
ruby '2.1.0'

gem 'rails'#, '4.0.2'
gem 'bootstrap-sass'#, '2.3.2.0'
gem 'bcrypt-ruby'#, '3.1.2'
gem 'cocoon'#, github: 'nathanvda/cocoon'
gem 'will_paginate'#, '3.0.4'
gem 'bootstrap-will_paginate'#, '0.0.9'

gem 'select2-rails'
gem 'mandrill_mailer'
gem 'sunspot_rails'
gem 'sunspot_solr'
gem 'progress_bar'
gem 'redcarpet'
gem "google_visualr", "~> 2.1.0"

gem 'capistrano',  '~> 3.1'
gem 'capistrano-rails', '~> 1.1'
# gem 'select2-sass-bootstrap-rails'
# gem 'squeel', github: 'kiela/squeel'

gem 'roo'
# using paper_trail for versioning database
gem 'paper_trail', '~> 3.0.1'

# using google analytics gem
gem 'google-analytics-rails'

# using zip to send multiple csv files in one click (eg: corals.csv + resources.csv, observation.csv + resources.csv etc)
gem 'rubyzip', '>= 1.0.0'
gem 'zip-zip'

# for prettifying the rails console output
# Include the following code into ~/.irbrc file, so that everytime you start rails console, the hirb view is automatically loaded
# require 'hirb'
# View class needs to come before enable()
# class Hirb::Helpers::Yaml; def self.render(output, options={}); output.to_yaml; end ;end
# Hirb.enable :output=>{"Hash"=>{:class=>"Hirb::Helpers::Yaml"}}
gem 'hirb'

# for sharding database (main database and temporary database)
#gem "ar-octopus", :git => "git://github.com/tchandy/octopus.git", :require => "octopus"

group :development, :test do
  gem 'sqlite3'#, '1.3.8'
  #gem 'sunspot_solr'
  gem 'minitest'
  gem 'rspec-rails', '2.13.1'

  # The following optional lines are part of the advanced setup.
  # gem 'guard-rspec', '2.5.0'
  # gem 'spork-rails', '4.0.0'
  # gem 'guard-spork', '1.5.0'
  # gem 'childprocess', '0.3.6'
end

group :test do
  #gem 'selenium-webdriver', '2.35.1'
  gem 'capybara', '2.1.0'
  gem 'factory_girl_rails', '4.2.0'
  # gem 'cucumber-rails', '1.3.0', :require => false
  gem 'database_cleaner', github: 'bmabey/database_cleaner'

  # Uncomment this line on OS X.
  # gem 'growl', '1.0.3'

  # Uncomment these lines on Linux.
  # gem 'libnotify', '0.8.0'

  # Uncomment these lines on Windows.
  # gem 'rb-notifu', '0.0.4'
  # gem 'win32console', '1.3.2'
  # gem 'wdm', '0.1.0'
end

gem 'sass-rails'#, '4.0.1'
gem 'uglifier'#, '2.1.1'
gem 'coffee-rails'#, '4.0.1'
gem 'jquery-rails', '< 3.0.0'
gem 'turbolinks'#, '1.1.1'
gem 'jbuilder'#, '1.0.2'
# gem 'rails3-jquery-autocomplete', git: 'https://github.com/francisd/rails3-jquery-autocomplete'
gem 'jquery-turbolinks'

group :doc do
  gem 'sdoc', '0.3.20', require: false
end

group :production do
  # gem 'rails_12factor', '0.0.2'
  
end
