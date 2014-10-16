require 'spec_helper'

describe 'Bulk Upload' do
	
	subject { page }
	let(:admin) { FactoryGirl.create(:admin) }
	let(:id) { '111' }
	
	specify { expect(admin.admin? ).to equal(true) }

	before do
		admin.stub(:id).and_return(id)
		User.stub(:find).and_return(admin)

		visit signin_path
		fill_in 'Email', with: admin.email
		fill_in 'Password', with: admin.password
		click_button 'Sign in'
		
		puts '====================='
		puts admin.id
		puts '====================='
		 
	end
	
	describe 'import observations' do 
		before { visit '/imports/observations'}
	


		it 'can find import file field' do
			find('#import_file')
		end
		
		it 'can import observations' do
			#@file = fixture_file_upload('files/test_file.csv', 'text/csv')
			# New Import
			attach_file 'import_file', 'spec/fixtures/files/observation_test_file.csv'
			expect { click_button 'Import' }.to change(Observation, :count).by(1)
			expect(page).to have_selector('div.alert.alert-success')

		end

		it 'should not import observations with duplicates' do
			# New Import
			attach_file 'import_file', 'spec/fixtures/files/observation_test_file.csv'
			click_button 'Import'

			attach_file 'import_file', 'spec/fixtures/files/observation_test_file_2.csv'
			expect { click_button 'Import' }.to_not change(Observation, :count)

			expect(page).to have_selector('div#error_explanation')

		end

		
		# No Longer Valid
		"""
		it 'should not import observations with column header error' do
			attach_file 'import_file', 'spec/fixtures/files/observation_with_heading_error.csv'
			expect { click_button 'Import' }.to_not change(Observation, :count)
			expect(page).to have_selector('div#error_explanation')
			expect(page).to have_content('The column headers do not match...')
		end
		"""

	end
	
	
	"""
	
	describe 'import locations' do
		before { visit '/imports/locations'}

		it 'can import locations' do
			#@file = fixture_file_upload('files/test_file.csv', 'text/csv')
			attach_file 'import_file', 'spec/fixtures/files/location_without_error.csv'
			click_button 'Import'
			expect(page).to have_selector('div.alert.alert-success')
		end

		it 'cannot import locations with invalid longitude' do
			attach_file 'import_file', 'spec/fixtures/files/location_with_long_error.csv'
			click_button 'Import'
				
			expect(page).to have_selector('div#error_explanation')
		end

		it 'cannot import locations with invalid latitude' do

			attach_file 'import_file', 'spec/fixtures/files/location_with_lat_error.csv'
			click_button 'Import'
				
			expect(page).to have_selector('div#error_explanation')

		end

	end
	"""

end