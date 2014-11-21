it 'should overwrite observation' do
			obs =  FactoryGirl.create(:observation)

			CSV.open('spec/fixtures/files/bulk_upload_overwrite.csv', 'wb') do |csv|
				csv << ["observation_id", "access", "user_id", "coral_id", "coral_name", "location_id", "location_name", "latitude", "longitude", "resource_id", "measurement_id", "trait_id", "trait_name", "standard_id", "standard_unit", "methodology_id", "methodology_name", "value", "value_type", "precision", "precision_type", "precision_upper", "replicates", "notes"]
				mea = obs.measurements.first
				


				if obs.location.present?
		      loc = obs.location.location_name
		      lat = obs.location.latitude
		      lon = obs.location.longitude
		      if obs.location.id == 1
		        lat = nil
		        lon = nil
		      end
		    else
		      loc = nil
		      lat = nil
		      lon = nil
		    end
		    if obs.private == true
		      acc = 0
		    else
		      acc = 1
		    end

		    method = nil
		    if mea.methodology.present?
		      method = mea.methodology.methodology_name
		    end
				

				# Changing the value to be overwritten here
				mea.value = 'overwritten value'
				csv << [obs.id, acc, obs.user_id, obs.coral.id, obs.coral.coral_name, obs.location_id, loc, lat, lon, obs.resource_id, mea.id, mea.trait.id, mea.trait.trait_name, mea.standard.id, mea.standard.standard_unit, mea.methodology_id, method, mea.value, mea.value_type, mea.precision, mea.precision_type, mea.precision_upper, mea.replicates, mea.notes]
			end
			
			attach_file 'import_file', 'spec/fixtures/files/observation_test_file.csv'
			expect { click_button 'Import' }.to change(Observation, :count).by(1)
			expect(page).to have_selector('div.alert.alert-success')
	 	end