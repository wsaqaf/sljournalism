

## Steps for installation for a first time (clean instance) on Ubuntu 18.04:

1) Install Node.js: https://www.digitalocean.com/community/tutorials/how-to-install-node-js-on-ubuntu-18-04

2) Install Ruby on Rails with rbenv (install latest ruby ver you see):
https://www.digitalocean.com/community/tutorials/how-to-install-ruby-on-rails-with-rbenv-on-ubuntu-18-04

3) Install PostgreSQL with Ruby on Rails App (remember db name, username and pw for later configurations):
https://www.digitalocean.com/community/tutorials/how-to-use-postgresql-with-your-ruby-on-rails-application-on-ubuntu-18-04
(only do steps 1 & 2)

4) Install Apache2 with the command:

    >     sudo apt-get install apache2-dev

5) Install Passenger as shown here:
https://codepen.io/asommer70/post/installing-ruby-rails-and-passenger-on-ubuntu-an-admin-s-guide

6) Deploy passenger to be used by the app as shown here:
https://www.phusionpassenger.com/library/deploy/apache/deploy/ruby/

7) Ensure you have git installed, else install using:

	> `sudo apt install git`

8) Clone github repo from: https://github.com/wsaqaf/sljournalism.git using the command:

	> `git clone https://github.com/wsaqaf/sljournalism.git`

9) Go to the created app folder *sljournalism*, run the commands:

	> `bundle install`

10) Run the command:

	> `bundle exec rake secret`

and copy the result, which will be used in step 15 below

11) Create the database using the commands (where is the value in step 2)

	>     sudo -u postgres createuser [dbuser]
	>     sudo -u postgres createdb [db] -O [user]
	>     sudo -u postgres psql postgres

and when in postgres environment, simply change to the password of your choice.

> `ALTER USER [dbuser] WITH PASSWORD '[password]';`

Replace the values in square brackets with what what you want to use in your setup.

12) Add an entry in /etc/postgresql/[XX]/main/pg_hba.conf under the line *local all postgres peer* as follows:

	> `local all [dbuser] trust`

where *[XX]* is your postgres version and *[dbuser]* is what you assigned earlier

13) Restart postgres with the command:

	> `sudo service postgresql restart`

14) Run the command

    > bundle exec rake assets:precompile db:schema:load \ RAILS_ENV=productionDISABLE_DATABASE_ENVIRONMENT_CHECK=1

15) In the file **sljournalism/config/local_env.yml,** fill in the top *SECRET_KEY_BASE* value with the output from step 10 and fill in the remaining information. Remember to use the postgres credentials used in step 11 above

16) Restart your http server (apache or ngix) to ensure the app is online

17) Install docker using instructions here:
https://www.hostinger.com/tutorials/how-to-install-docker-on-ubuntu

18) Install docker-composer using the commands:

	> `sudo apt-get install docker-compose`

19) Add the current user to the docker group and close the ssh session and login again as shown:

	> `sudo usermod -a -G docker $USER; exit`

20) install go-lang using the commands:

	> `sudo apt update; sudo apt install golang-go`

21) go to /hyperledger/ and run the command:

	> `sh initialize.sh`

22) go to hyperledger/ and the command:

	> `sh run.sh`

23) **Congrats!** You should now be done and able to open the website try testing the various functions and features

====================================

**Reseting the databases**
To reset the blockchain and database, empty the database (warning: all claim/claim review and blockchain data will be lost):

1) Open the Rails Console using:

	> `rails c`

2) Run the following commands to delete all claims and reviews and remove user references to the blockchain:

	    Claim.destroy_all
	    ClaimReview.destroy_all
	    User.update_all("blockchain_tx=NULL")
	    User.update_all("time_added_to_blockchain=NULL")

3) If you want to preserve the users credentials, skip this step and go to step 4. Otherwise, if you actually want to also delete the users to start from scratch, you can also use this command in Rails Console:

	> `User.destroy_all`

4) Reset the hyperledger database by running the command under the hyperledger/ folder as described earlier :

	> 	    sh run.sh

5) Confirm by going to the website that all claims and proceed to sign up as admin if you deleted the users, or sign in as admin and add the users to the blockchain if you just removed them from the blockchain. Then you can do the other steps (add claims and review claims, etc.)

### Contact

Contact the developer walid.al-saqaf@sh.se for any comments or questions. You can also bring up issues in the repo to address ASAP.
