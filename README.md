# Trait Database quick start guide
---

The following quick start guide creates a development database (using postgres).  The assumption is that you are trying out the database, and so don't need to get fancy at this stage. The first step is to set up rails on you computer or server (if you haven't already).  A rails installation guide can be found here: [https://gorails.com/setup/osx/12-monterey](https://gorails.com/setup/osx/12-monterey)

> Use ruby version '2.6.10'

> You don't need to install `rails`

> use `brew` to install postgres

The below quick start guide was last updated for ruby-2.6.10.

1. Clone the github repository

        git clone git@github.com:jmadinlab/traits.git

2. Move into the traits directory

        cd traits

3. Make sqlite3 database configuration file and local environment file  

        cd config  
        cp database.yml.postgres database.yml  
        cp local_env.yml.example local_env.yml  

4. Return to base directory and install gems

        cd ..
        bundle install

5.

5. Migrate database structure to sqlite3 development database

        rake db:migrate

6. Start solr search

        rake sunspot:solr:start
        rake sunspot:solr:reindex

7. Start rails server

        rails s

8. Sign-up user ([http://localhost:3000/signup](http://localhost:3000/signup))

9. Open development database

        sqlite3 db/development.sqlite3

10. In sqlite3, make the new user admin, editor and contributor

        update users set admin='t' where id=1;  
        update users set contributor='t' where id=1;  
        update users set editor='t' where id=1;  

### Notes


1. The bundler will complain if you don't have postgres installed. For more help: https://wiki.postgresql.org/wiki/Homebrew

2. On a Mac, you need to have JDK 8 installed. Easiest to do with `brew`

        brew install adoptopenjdk/openjdk/adoptopenjdk8
        java -version



pg_restore -d traits_development -U deploy coraltraits_production-database-202205180100.backup
