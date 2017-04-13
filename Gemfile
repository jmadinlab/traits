source 'https://rubygems.org'
ruby '2.1.4'

gem 'rails', '~> 4.2', '>= 4.2.8'
# gem 'rails'#, '4.2.5'
gem 'bootstrap-sass'
gem 'bcrypt'
gem 'cocoon'
gem 'will_paginate'
gem 'bootstrap-will_paginate'
gem 'rake', '< 11.0'

gem 'select2-rails'
gem 'sunspot_rails'
gem 'sunspot_solr'
gem 'progress_bar'
gem 'sqlite3', group: :development
gem 'redcarpet'
gem 'google_visualr'#, '~> 2.1.0'
gem 'semantic'

gem 'sass-rails'
gem 'uglifier'
gem 'coffee-rails'
gem 'jquery-rails'#, '< 3.0.0'
gem 'turbolinks'
gem 'jbuilder'
gem 'jquery-turbolinks'
gem 'savon', '~> 2.10.0'

gem 'jquery-ui-rails' # jquery ui

gem 'capistrano',  '~> 3.1'
gem 'capistrano-rails', '~> 1.1'

gem 'colorize'

# database setup (postgres), and for Heroku
gem 'pg'
# gem 'rails_12factor', group: :production

gem 'roo'

# using paper_trail for database versioning
gem 'paper_trail', '~> 3.0.1'

# using mandrill for mailer
gem 'mandrill_mailer'

# using google analytics gem
gem 'google-analytics-rails'

# using zip to send multiple csv files in one click
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
  
  gem 'minitest'
  gem 'rspec-rails', '2.13.1'
  gem 'spring'

  # The following optional lines are part of the advanced setup.
  # gem 'guard-rspec', '2.5.0'
  # gem 'spork-rails', '4.0.0'
  # gem 'guard-spork', '1.5.0'
  # gem 'childprocess', '0.3.6'
end

group :test do
  gem 'selenium-webdriver'
  gem 'capybara', '2.1.0'
  gem 'factory_girl_rails', '4.2.0'
  # gem 'database_cleaner', github: 'bmabey/database_cleaner'

  # Uncomment this line on OS X.
  # gem 'growl', '1.0.3'

  # Uncomment these lines on Linux.
  # gem 'libnotify', '0.8.0'

  # Uncomment these lines on Windows.
  # gem 'rb-notifu', '0.0.4'
  # gem 'win32console', '1.3.2'
  # gem 'wdm', '0.1.0'
end

gem 'sdoc', '~> 0.4.0',          group: :doc

