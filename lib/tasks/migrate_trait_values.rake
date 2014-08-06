namespace :migrate_trait_values do
	desc "migrate"
	task :migrate => :environment do
		Trait.all.each do |t|
			values = t.value_range.split(',').map(&:strip)
			values.each do |v|
				tv = Traitvalue.new(:value_name => v, :trait_id => t.id)
				tv.save!
			end
			
		end
	end
end