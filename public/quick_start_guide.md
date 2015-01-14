# Trait Database quick start guide
---

The following quick start guide creates a development database (using sqlite3).  The assumption is that you are trying out the database, and so don't need to get fancy at this stage. The first step is to set up rails on you computer or server (if you haven't already).  An excellent rails installation guide can be found here: [http://installrails.com]()

The below quick start guide was last updated for ruby-2.2.0.

    # Clone the github repository
    git clone https://github.com/jmadin/traits.git

    # Move into the traits directory
    cd coraltraits

    # Make sqlite3 database configuration file and local environment file
    cp config/database.yml.sqlite config/database.yml
    cp config/local_env.yml.example config/local_env.yml

    # Return to base directory and install gems
    cd ..
    bundle install

    # Migrate database structure to sqlite3 development database
    rake db:migrate

    # Start solr search
    rake sunspot:solr:start

    # Start rails server
    rails s

Sign-up user ([http://localhost:3000/signup](http://localhost:3000/signup))

    # Open development database
    sqlite3 db/development.sqlite3 

    # In sqlite3, make user admin, editor and contributor
    update users set admin='t' where id=1;
    update users set contributor='t' where id=1;
    update users set editor='t' where id=1;
