FactoryGirl.define do
	factory :user do
		name "Test User"
		email "test@coraltraits.org"
		password 'test123'
		password_confirmation 'test123'

		factory :admin do
			admin true
			contributor true
		end
	end
end