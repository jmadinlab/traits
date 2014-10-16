FactoryGirl.define do
	factory :user do
		name "Test User"
		email "test111@coraltraits.org"
		password 'test123'
		password_confirmation 'test123'

		factory :admin do
			admin true
			contributor true
		end
	end

	factory :location do
		location_name 'Test Location'
		latitude 10
		longitude 10
		location_description 'Test Location Description'
		user { FactoryGirl.build(:user) }

	end
	

	factory :coral do
		coral_name 'Test Coral'
		coral_description 'Test Coral Description'
		user_id { FactoryGirl.build(:user).id }

	end
	
	factory :resource do
		author 'Test Author'
		year '2012'
		title 'Test Title '
		resource_type 'paper'
		doi_isbn '12345678'
		journal 'Test Journal'
		volume_pages '150, 200'
		user { FactoryGirl.build(:user) }

		
	end

	factory :trait do
		trait_name 'Test Trait'
		standard { FactoryGirl.build(:standard) }
		trait_description 'Test Trait Description'
		value_range '10'
		trait_class 'test_class'
		user { FactoryGirl.build(:user) }
	end

	factory :standard do
		standard_name 'Test standard'
		standard_unit 'kg'
		standard_class 'weight'
		standard_description 'test standard Description'
		user { FactoryGirl.build(:user) }
		
		
	end

	
	factory :measurement do
		observation
		user FactoryGirl.build(:user) 
		trait_id FactoryGirl.create(:trait).id
		standard  FactoryGirl.build(:standard) 
		value '111'

		#association :observation, factory: :observation
	end

	factory :observation do
		user  FactoryGirl.build(:user) 
		location FactoryGirl.build(:location) 
		coral FactoryGirl.create(:coral) 
		resource FactoryGirl.build(:resource)
		
		after :build do |observation, evaluator|
			observation.measurements << FactoryGirl.build_list(:measurement, 1, observation: nil)
		end		
		
		

	end

	

	factory :methodology do
		methodology_name 'test methodology'
		method_description 'test methodology description'
		trait FactoryGirl.build(:trait)

	end


	factory :citation do
		trait_id  FactoryGirl.create(:trait).id
		resource  FactoryGirl.build(:resource) 
		user  FactoryGirl.build(:user) 

	end

	factory :traitvalue do
		value_name 'Test Value'	
		trait FactoryGirl.build(:trait).id 
		value_description 'Test description'
	end
	

end