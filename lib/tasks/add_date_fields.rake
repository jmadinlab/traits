namespace :add_date_fields do
	desc "add_date_fields"
	task :add => :environment do

		## Convert to datetime.now for all

		
		Citation.all.each do |t|
			t.updated_at = Time.now
			t.created_at = Time.now
			t.save!
		end

		Trait.all.each do |t|
			t.updated_at = Time.now
			t.created_at = Time.now
			t.save!
		end

		puts 'Traits completed...'
		
		Coral.all.each do |t|
			t.updated_at = Time.now
			t.created_at = Time.now
			t.save!
		end
		puts 'Coral completed...'
		
		Issue.all.each do |t|
			t.updated_at = Time.now
			t.created_at = Time.now
			t.save!
		end
		puts 'Issue completed...'

		Location.all.each do |t|
			t.updated_at = Time.now
			t.created_at = Time.now
			t.save!
		end

		puts 'Location completed...'

		Measurement.all.each do |t|
			t.updated_at = Time.now
			t.created_at = Time.now
			t.save!
		end
		puts 'Measurement completed...'


		Methodology.all.each do |t|
			t.updated_at = Time.now
			t.created_at = Time.now
			t.save!
		end
		puts 'Methodology completed...'

		Observation.all.each do |t|
			t.updated_at = Time.now
			t.created_at = Time.now
			t.save!
		end

		puts 'Obsservation completed...'

		Resource.all.each do |t|
			t.updated_at = Time.now
			t.created_at = Time.now
			t.save!
		end

		puts 'Resource completed...'


		Standard.all.each do |t|
			t.updated_at = Time.now
			t.created_at = Time.now
			t.save!
		end

		puts 'Standard completed...'

		Synonym.all.each do |t|
			t.updated_at = Time.now
			t.created_at = Time.now
			t.save!
		end

		puts 'Synonym completed...'

		Traitvalue.all.each do |t|
			t.updated_at = Time.now
			t.created_at = Time.now
			t.save!
		end

		puts 'Traitvalue completed...'
		

		User.all.each do |t|
			t.updated_at = Time.now
			t.created_at = Time.now
			t.save!
		end

		puts 'User completed...'
		
		
		
		
		
		
		
		
		
	end
end