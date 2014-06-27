class Methodology < ActiveRecord::Base
	has_and_belongs_to_many :traits
	has_many :measurements
end
