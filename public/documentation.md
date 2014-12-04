###Rails Deployment at Informatics Virtual Machine (VM)
***
 
**A) Production Server Details and Access**  
Hostname : `ctdwsprd1001a`  
Server IP: `10.26.2.85`  
Public IP : `137.111.200.166`  

	The VM is a Linux machine with Oracle Linux (much similar to Red Hat ). So any application has to be installed through 'yum'  

**1. Connect to Orbit VPN through OpenVPN software**  
The first criteria for accessing the VM is that you need to be in `Orbit VPN.` Informatics has already provided you access to the VPN. So you only have to install the VPN software  on your machine. Details of it can be found [https://wiki.mq.edu.au/display/infooperations/VPN+Access+to+Systems](https://wiki.mq.edu.au/display/infooperations/VPN+Access+to+Systems).  
 
Remember to be in Macquarie OneNet VPN as well.  
 
**2. ssh**  
You can now ssh into the machine with your `OneId`. Eg:
``ssh mq20140520@10.26.2.85``  
``ssh rails_deployer@10.26.2.85``
 
( I will email you the password for rails_deployer)
 
**3. The rails application is in the home folder of rails_deployer.**  
`/home/rails_deployer/coraltraits`
 
  
**B) Setting Up Development Environment (local machine for development)**  
The production server uses `PostgreSQL version 8.4.20` and so it is ideal to use the same version for development in order to avoid any misconfiguration issues.    

**1. Install postgres :**  
http://get.enterprisedb.com/postgresql/postgresql-8.4.22-1-osx.zip  
Unzip and run the installer  

	Useful Resources:  
	https://wiki.postgresql.org/wiki/Detailed_installation_guides
	windows : http://www.postgresqltutorial.com/install-postgresql/
 
**2. Create a user and database**  

a. In mac terminal : `createuser rails_deployer`  
b. Make it a `superuser` (the above command will ask the option)  
c. Run psql : `psql -U postgres`  
d. Make the user able to login to database and create database:    
	`ALTER ROLE rails_deployer with LOGIN CREATEDB;`  
e. Exit psql : `\q or Ctrl + D`  
f. In mac terminal inside rails root directory: `rake db:create:all`  
g. If you setup a password for the user, make sure to make the changes to `config/database.yml` file  

**3. Restore database from dump**  
In mac terminal :  

	pg_restore --verbose --clean --no-acl --no-owner -h localhost -d coraltraits_development my_database.dump   

Note: my_database.dump is the file that I will provide.  

If you want to load the production database in your machine do this:

	pg_restore --verbose --clean --no-acl --no-owner -h localhost -d coraltraits_production my_database.dump 

**4. Start Solr and Reindex**  
	
	rake sunspot:solr:start
	rake sunspot:reindex[500]

**5. Start rails server**  
`rails s`

**C) How to Deploy ?**  

1. Make all your changes to the code  
2. Commit the changes to version control  
	`git add -A`  
	`git commit -m “custom message”`  
3. Push the code to remote repository - `git push -u origin master`
4. Login to the VM using steps in A)
5. Go to `/home/rails_deployer/coraltraits`
6. Pull the code from the repository : `git pull`
7. Migrate database if any migrations are pending : `rake db:migrate`
8. Asset Precompile : `rake assets:precompile`
9. Restart Phusion Passenger : `touch tmp/restart.txt`
10. Restart Nginx : `sudo service nginx restart`


**D) Reference Note for sqlite3 to postgres conversion**  

1. `gem install taps`
2. `gem uninstall rack` (uninstall rack version 1.5.2)
3. `gem install rack --version 1.0.1`
4. `rake db:create:all` (create all the necessary databases for rails with configuration from config/database.yml. Make sure the file has postgres configuration instead of sqlite3)
5. `taps server sqlite://db/development.sqlite3 username password` (you can copy this as it is…. Username and passwords are of no use at this point)
6. Open another terminal and run the following command  
`taps pull postgres://rails_deployer@localhost/coraltraits_development http://username:password@localhost:5000`
 

**E) Sqlite3 vs. PostgreSQL syntax**  

**1. boolean operators**  
pg : `@obs = Observation.where(['observations.private IS false’])`  
sqlite3 : `@obs =Observation.where([‘observations.private IS ?’, false])`  
Remarks : sqlite3 syntax doesnt work for pg because when string substitution is done, false becomes ‘false’ a string instead of boolean in pg.  

**2. ‘IS’ vs. ‘='**   
pg: `@observation = Observation.where([‘observation.id = ?’, 4321])`  
sqlite3 : `@observation = Observation.where([‘observation.id IS ?’, 4321])`  
Remarks : For pg, integer comparision has to be with ‘=’ instead of ‘IS’  

**3. String Comparision**  
pg: `@coral = Coral.where(“coral.name LIKE ?”, ‘Acanthastrea’)`  
sqlite3: `@coral = Coral.where(“coral.name IS ?”, ‘Acanthastrea’)`  
Remarks : String comparision is through LIKE keyword.


**F) Appendix**   
**I) Web Application Architecture**  
Platform : `Ruby on Rails`  
Search Indexing : `Isolated Apache Solr Instance installed over Tomcat 7`  
Mail Server : `Host Relay`  

**II) Deployment**  
The application is deployed with `Phusion Passenger, Nginx and PostGresql.`  

**Nginx Configuration File:** /opt/nginx/conf/nginx.conf  
**SSL Certificates:**  /etc/pki/tls/certs/coraltraits_org.chain.crt  
**Key File:** /etc/pki/tls/private/coraltraits.key  

**III) Database**  
**PostgreSQL 8.4.20**  
Database User : `rails_deployer`  
Databases : `coraltraits_development, coraltraits_production, coraltraits_test`  


**IV) Log Files**  
**Nginx Error Log:** /opt/nginx/logs/error.log  
**Nginx Access Log:** /opt/nginx/logs/access.log  
**Application Log:** /home/rails_deployer/coraltraits/log/production.log  

**V) Backup arrangements and details**  
TODO - probably by informatics  


**VI) Workflow**  
Whatever changes you have made to the development database will have to be reflected in the production server. We will not be able to just copy a single development.sqlite3 file and put that into the server and change the filename to production.sqlite3. It is because the postgres database is stored inside its own server instead of a single file like sqlite3. 
 
However any keep in mind that this is not true for changing the database schema. If you have generated a new migration in the development, obviously git will take care of it and while in production, we also have to do a rake db:migrate to ensure the consistency.
 
	Resources on using pg_dump:
	i) http://www.postgresql.org/docs/9.3/static/app-pgdump.html
	ii) http://stackoverflow.com/questions/1237725/how-to-copy-postgres-database-to-another-server
 

**G) References**  
**Apache Solr**  

1. Solr with Rails in Different Environments : https://github.com/sunspot/sunspot/wiki/Configuring-solr-for-use-with-sunspot-in-development,-testing,-and-production
2. Apache Solr Homepage: http://lucene.apache.org/solr/  

**Sunspot Gem** : https://github.com/sunspot/sunspot





