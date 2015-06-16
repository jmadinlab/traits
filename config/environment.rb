# Load the rails application.
require File.expand_path('../application', __FILE__)

require 'base_ext'
# Initialize the rails application.
Traits::Application.initialize!

Time::DATE_FORMATS[:ctdb_date] = "%e %B %Y at %I:%M %p"
Time::DATE_FORMATS[:ctdb_date2] = "%e %B %Y"
