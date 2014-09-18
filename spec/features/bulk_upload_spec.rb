require 'spec_helper'

describe "Bulk Upload" do
	
	subject { page }
	let(:admin) { FactoryGirl.create(:admin) }
	
	specify { expect(admin.admin? ).to equal(true) }

	before do
		visit signin_path
		fill_in "Email", with: admin.email
		fill_in "Password", with: admin.password
		click_button "Sign in"
	end
	
	before { visit '/imports/observations'}
	it { should have_content('Upload Observation')}

	it "can import observations" do
		#@file = fixture_file_upload('files/test_file.csv', 'text/csv')
		attach_file "import_file", 'spec/fixtures/files/test_file.csv'
		click_button "Upload"
		expect(page).to have_selector('div.alert.alert-success')

	end

	it "should not import observations with duplicates" do
		attach_file "import_file", 'spec/fixtures/files/test_file.csv'
		click_button "Upload"

		attach_file "import_file", 'spec/fixtures/files/test_file_2.csv'
		click_button "Upload"
		expect(page).to have_selector('div#error_explanation')

	end
	

end