# The Coral Trait Database

This is the first application for the
[*Observations and Measurement Tutorial*](http://railstutorial.org/)
initiated by [Joshua Madin](http://acropora.bio.mq.edu.au/joshua-madin).

The project was built on Michael Hartl's sample_app_rails_4 from github, using these commands:

    $ cd /tmp
    $ git clone https://github.com/railstutorial/sample_app_rails_4.git
    $ cd sample_app_rails_4
    $ cp config/database.yml.example config/database.yml
    $ bundle install
    $ bundle exec rake db:migrate


rails generate model Citation trait:references resource:references

rails generate model Trait trait_name:string standard:references value_range:string trait_class:string trait_description:text user:references 

rails generate model Standard standard_name:string standard_unit:string standard_class:string standard_description:string user:references

rails generate model Resource author:string year:integer title:string resource_type:string doi_isbn:string journal:string volume_pages:string resource_notes:text user:references

rails generate model Location location_name:string latitude:decimal longitude:decimal location_description:text user:references

rails generate model Coral coral_name:string coral_description:text user:references

rails generate model Observation user:references location:references coral:references resource:references private:boolean

rails generate model Measurement observation:references user:references orig_user_id:integer trait:references standard:references value:string orig_value:string precision_type:string precision:string precision_upper:string replicates:string

bundle exec rake db:migrate


rails generate migration add_notes_to_measurement notes:text
bundle exec rake db:migrate

rails generate migration add_user_to_citation user:references
bundle exec rake db:migrate

rails generate migration add_contributor_to_user contributor:boolean
bundle exec rake db:migrate


# Importing

.mode insert
.out citations.sql
select * from citations;

.mode insert
.out users.sql
select id, last_name, email, created_at, updated_at, password_digest, remember_token, admin from contributors;

.mode insert
.out standards.sql
select * from standards;

.mode insert
.out corals.sql
select * from corals;

.mode insert
.out locations.sql
select id, location_name, latitude, longitude, location_description, contributor_id, created_at, updated_at from locations;

.mode insert
.out resources.sql
select id, author, year, title, resource_type, doi_isbn, journal, volume_pages, resource_notes, contributor_id, created_at, updated_at from resources;

.mode insert
.out traits.sql
select * from traits;

.mode insert
.out citations.sql
select * from citations;

# Observations mapping

.mode csv 
.header on 
.out observations.csv 
select * from observations;

delete from observations;
delete from sqlite_sequence where name='observations';

delete from measurements;
delete from sqlite_sequence where name='measurements';

# Fixing

UPDATE measurements SET standard_id=35 WHERE trait_id=28;

UPDATE observations SET resource_id=10 
WHERE id IN (SELECT observation_id FROM measurements WHERE trait_id=28);

UPDATE measurements SET standard_id=2 WHERE trait_id=4;

UPDATE observations SET location_id=1 
WHERE id IN (SELECT observation_id FROM measurements WHERE trait_id=4);

UPDATE observations SET location_id=1 
WHERE id IN (SELECT observation_id FROM measurements WHERE trait_id=6);

UPDATE observations SET location_id=1 
WHERE id IN (SELECT observation_id FROM measurements WHERE trait_id=4);

UPDATE measurements SET standard_id=10 WHERE trait_id=6;

UPDATE measurements SET standard_id=6 WHERE trait_id=12;

UPDATE measurements SET standard_id=56 WHERE trait_id=51;

UPDATE observations SET location_id=1 
WHERE id IN (SELECT observation_id FROM measurements WHERE trait_id=15);

UPDATE users SET name="Marcela Diaz" WHERE id=5;

UPDATE observations SET resource_id=38 WHERE resource_id=444;

UPDATE measurements SET standard_id=2 WHERE trait_id=88;

UPDATE users SET contributor='t' WHERE id=1;

UPDATE observations SET location_id=211 WHERE location_id=274;


# Hollie mapping

.mode csv
.import hollie/hollie_locs.csv locations

.import hollie/hollie_refs.csv resources

.import hollie/hollie_mea.csv measurements

.import hollie/hollie_obs.csv observations

delete from measurements where id > 93075;
delete from locations where id > 186;
delete from observations where id > 89831;
delete from resources where id > 460;


Fixing

UPDATE observations SET location_id=194 where location_id IN (231, 259, 323);

select * from observations SET location_id=1 
WHERE id IN (SELECT observation_id FROM measurements WHERE trait_id=15);

delete from observations where location_id>254 AND location_id<317
select id from observations where location_id>254 AND location_id<317


# Production

bundle exec rake db:migrate

rake tmp:clear
bundle exec rake assets:precompile RAILS_ENV=production RAILS_GROUPS=assets
rails s -e production -p 3009


# Entities

Entities are things that can be observed and measured, such as corals, time, locations, etc.
  
    $ rails generate scaffold Entity entity_name:string entity_description:string
    $ bundle exec rake db:migrate

# Traits

Traits (or characteristics) are aspects of entities that can be measured, such as height, color, name, etc.

    $ rails generate scaffold Trait name:string trait_description:text trait_class:string value_range:string
    $ bundle exec rake db:migrate
   
   
.mode insert 
.out traits.sql 
select id, name, trait_description, trait_class, value_range, created_at, updated_at from traits
    
delete from traits;
delete from sqlite_sequence where name='traits';

     
# Standards

Standards relate a measurement value to a prescribed scale or category, such as metre, pH, rank, etc.

    $ rails generate scaffold Standard standard_name:string standard_unit:string standard_class:string standard_description:string
    $ bundle exec rake db:migrate

.mode insert 
.out standards.sql 
select id, standard_name, standard_unit, standard_class, standard_description, created_at, updated_at from standards;



delete from standards;
delete from sqlite_sequence where name='standards';


# Resources

Standards relate a measurement value to a prescribed scale or category, such as metre, pH, rank, etc.

    $ rails generate scaffold Resource author:string year:integer title:string resource_type:string doi_isbn:string journal:string volume_pages:string pdf_name:string resource_notes:text
    $ bundle exec rake db:migrate

    .mode csv
    .import resources_upload.csv resources

delete from resources;
delete from sqlite_sequence where name='resources';


.mode insert 
.out resources.sql 
select id, author, year, title, resource_type, doi_isbn, journal, volume_pages, pdf_name, resource_notes, created_at, updated_at from resources;

t.string   "author"
t.integer  "year"
t.string   "title"
t.string   "resource_type"
t.string   "doi_isbn"
t.string   "journal"
t.string   "volume_pages"
t.string   "pdf_name"
t.text     "resource_notes"
t.datetime "created_at"
t.datetime "updated_at"

# Locations

Standards relate a measurement value to a prescribed scale or category, such as metre, pH, rank, etc.

    $ rails generate scaffold Location location_name:string latitude:decimal longitude:decimal location_description:text
    $ bundle exec rake db:migrate

.mode insert 
.out locations.sql 
select id, location_name, latitude, longitude, location_description, created_at, updated_at from locations;

delete from locations;
delete from sqlite_sequence where name='locations';

# Corals

Standards relate a measurement value to a prescribed scale or category, such as metre, pH, rank, etc.

    $ rails generate scaffold Coral coral_name:string coral_description:text
    $ bundle exec rake db:migrate

.mode insert 
.out corals.sql 
select * from corals;

delete from corals;
delete from sqlite_sequence where name='corals';

# Observations

Observations are made of entities, and are required to make measurements of traits.

    <!-- $ rails generate scaffold Observation group:references entity:references
    $ bundle exec rake db:migrate

    $ rails generate migration add_group_to_observation group:references
    $ bundle exec rake db:migrate -->

    $ rails generate scaffold Observation user:references location:references coral:references resource:references private:boolean
    $ bundle exec rake db:migrate


.mode csv 
.header on 
.out observations.csv 
select * from observations;

.mode csv 
.header on 
.out corals.dmp 
select * from corals;



delete from traits;
delete from sqlite_sequence where name='traits';

# Measurements

Measurements bind a value and standard to a trait of an observed entity.  Note that we do not consider values here, because we are creating a measurement "template".  Data (values) come in later.

    $ rails generate scaffold Measurement observation:references user:references trait:references standard:references value:string orig_value:string precision_type:string precision:string precision_upper:string replicates:string
    $ bundle exec rake db:migrate

rails generate migration RemoveResourceFromMeasurements resource:references

# Group

Measurements bind a value and standard to a trait of an observed entity.  Note that we do not consider values here, because we are creating a measurement "template".  Data (values) come in later.

    $ rails generate scaffold Group location:references coral:references resource:references
    $ bundle exec rake db:migrate

    $ rails generate migration add_location_to_group location:references
    $ bundle exec rake db:migrate

    $ rails generate migration add_coral_to_group coral:references
    $ bundle exec rake db:migrate

    $ rails generate migration add_resource_to_group resource:references
    $ bundle exec rake db:migrate



# Users

t.string   "first_name"
t.string   "last_name"
t.string   "short_name"
t.string   "email"
t.string   "phone"
t.text     "contributor_profile"
t.integer  "contributor_id"
t.datetime "created_at"
t.datetime "updated_at"
t.string   "password_digest"
t.string   "remember_token"
t.boolean  "admin",               default: false
t.string   "institution"
t.string   "country"

.mode insert 
.out users.sql 
select id, last_name, email, created_at, updated_at, password_digest, remember_token, admin from contributors

t.string   "name"
t.string   "email"
t.datetime "created_at"
t.datetime "updated_at"
t.string   "password_digest"
t.string   "remember_token"
t.boolean  "admin"

delete from users;
delete from sqlite_sequence where name='users';

# Git and Heroku

    $ git remote add origin https://github.com/jmadin/oboe.git

    $ git add .
    $ git commit -m "New commit."
    $ git push -u origin master

    $ bundle install --without production
    $ git commit -a -m "Update Gemfile.lock for Heroku."
    $ heroku login
    $ heroku create --stack cedar # for rails > 3.1
    $ rake assets:precompile
    
    $ RAILS_ENV=production rake assets:precompile
    
    $ git commit -a -m "Add precompiled assets for Heroku."

    $ git push heroku master
    $ heroku run rake db:migrate

    $ heroku rename obme
    $ heroku open



    $ git remote remove heroku
    $ git remote add heroku git@heroku.com:vast-dawn-2299.git