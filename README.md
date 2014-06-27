The Coral Trait Database
========================

The Coral Trait Database is a growing compilation of scleractinian coral life history trait, phylogenetic and biogeographic data. The database was initially a series of spreadsheet tables, but starting in 2013 this data is being transitioned into an online collaborative database with a growing number of contributors.

At the time of editing this readme file, there are 87,328 coral observations with 95,842 trait entries for 1,555 coral species in the database. Most of these entries are for shallow-water, reef-building species. Data contributors have access control over the data they enter. Nonetheless, an increasing proportion of these data is becoming publicly accessible.

The Coral Trait Database was started by [Dr. Joshua Madin](http://acropora.bio.mq.edu.au) (Macquarie University, Sydney) and Prof. Andrew Baird (James Cook University, Townsville) to help make all observations and measurements of corals in the vast coral literature easily accessible to scientists, and therefore support and accelerate coral reef science. If you use information from the database, you are obliged to cite the original data sources. In additional, we would also appreciate you citing the database itself as, because citations help us get funding to support database development:

* Madin JS and Baird AH (2014) The Coral Trait Database. http://coraltraits.org

## Observations and Measurements

The Coral Trait Database has been developed according to the Observation and Measurement Ontology (OBOE) that was developed at the National Center for Ecological Analysis and Synthesis (see references below). The system has been designed with reef corals in mind, but is a generic system for data in which entities are observed and traits of these entities are measured. The key distinction between OBOE and observational models is that trait-entity relationships and observation context are made explicit. These are the ingredients that make sense of within-dataset data (i.e., metadata about values).

Several contextual constraints have been implemented in the Coral Trait Database to simplify the structure. The model only includes four observed entities: User, Resource, Location and Coral. Measurements of "traits" can be taken of all four entities; however, those for the former three entities are constrained. Measurements of "traits" for Coral are highly flexible. Also for simplicity, many contextual entities, such as "habitat" or "plot", are measured at the Coral entity level. For example, a Coral "area" can be measured as expected, but so can traits for higher-level entities such as "water temperature", "depth" and "habitat". Such constraints on the model can be relaxed if deemed necessary, but greatly improved the performance of the model for it's current purposes.

## References

* Madin JS, Bowers S, Schildhauer M and Jones M (2008) Advancing ecological research with ontologies. Trends in Ecology and Evolution. 23:159-168.
* Bowers S, Madin JS and Schildhauer M (2008) A conceptual modeling framework for expressing observational data semantics. Lecture Notes in Computer Science.
* Madin JS, Bowers S, Schildhauer M, Krivov S, Pennington D and Villa F (2007) An ontology for describing and synthesizing ecological observational data. Ecological Informatics 2:279-296.
* The foundation for this web application (e.g., session and user models) was developed using [Michael Hartl's ruby of rails tutorial](http://railstutorial.org/).

## Database code

The database was developed using Ruby on Rails and can be freely downloaded from Github.

## Running in production

	$ git clone git@github.com:jmadin/coraltraits.git
	$ git pull master origin
	$ bundle update
	$ bundle exec rake db:migrate RAILS_ENV="production"
	$ rake tmp:clear
	$ bundle exec rake assets:precompile RAILS_ENV=production RAILS_GROUPS=assets
	$ rails s -e production -p 3009


  $ rails generate migration add_editor_to_user editor:boolean
  $ bundle exec rake db:migrate

  $ rails generate migration add_release_to_trait release_status:boolean
  $ bundle exec rake db:migrate

  $ rails generate migration add_approval_status_to_observation_measurements approval_status:string
  $ bundle exec rake db:migrate


update measurements set value_type="raw_value" where trait_id=8;
update measurements set value_type="expert_opinion" where trait_id=9;
update measurements set trait_id=8 where trait_id=9;

update measurements set value_type="raw_value" where trait_id=5;
update measurements set value_type="expert_opinion" where trait_id=6;
update measurements set trait_id=5 where trait_id=6;

update measurements set value_type="raw_value" where trait_id=3;
update measurements set value_type="expert_opinion" where trait_id=4;
update measurements set trait_id=3 where trait_id=4;


delete from observations where id IN (select id from observations where id NOT IN (select observation_id from measurements));


.mode csv
.import db/csf_obs.csv observations
.import db/csf_mea.csv measurements



