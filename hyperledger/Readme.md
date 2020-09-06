
## Steps for installation for a first time (clean instance) on Ubuntu 18.04:

1) Login to your shell account on your Droplet and create a new account with sudo rights if you have not already done so. In our case, we assume that we will create an account named *'demo'* with the default root account:

  >     sudo adduser demo

and enter a password of your choice when prompted

Then give it sudo rights as shown:
  >     sudo usermod -aG sudo demo
  >     su - demo

2) Update the packages in the system:

  >     sudo apt update

3) Install Ruby dependencies (Nodejs, Yarn, etc.):

  >     curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
  >     curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
  >     echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
  >     sudo add-apt-repository ppa:chris-lea/redis-server
  >     sudo apt update
  >     sudo apt install git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev software-properties-common libffi-dev dirmngr gnupg apt-transport-https ca-certificates redis-server redis-tools nodejs yarn


confirm that nodejs and npm are installed:
  >     nodejs -v

4) Install Ruby 2.7.1 and Rails and use rbenv for versioning:

  >     git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
  >     echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
  >     echo 'eval "$(rbenv init -)"' >> ~/.bashrc
  >     source .bashrc
  >     git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
  >     rbenv install 2.7.1
  >     rbenv rehash
  >     rbenv global 2.7.1

confirm that ruby 2.7.1 is installed:
  >     ruby -v

Install rails and bundler to complete the Ruby setup
  >     gem install rails
  >     gem install bundler

confirm that bundle 2.0 is installed correctly
  >     bundle -v

5) Install postgres and its libraries as well as a database and its owner account (In this setup we are using *'demo'* for database, user and password. You can update that as you see fit):

  >     sudo apt install postgresql postgresql-contrib libpq-dev

You can start the service with:
  >     sudo service postgresql start

Then create the user:
  >     sudo -u postgres createuser demo

and the database the user owns:
  >     sudo -u postgres createdb demo -O demo

go into the postgres environment:
  >     sudo -u postgres psql postgres

and once in, set up the password as follows:
  >     ALTER USER demo WITH PASSWORD 'demo';

then exit from psql using
  >     \q

6) Install Apache2 (you can also choose Nginx but for this demo, Apache2 is sufficient):

  >     sudo apt install apache2

Verify that the default Apache2 page appears by visiting the website (droplet's IP on a web browser should work)
http://<public IP or domain name>

7) Add a file at /etc/apache2/sites-available/demo.conf to correspond to the app. We used *'demo'* but you can use any other name:

  >     sudo nano /etc/apache2/sites-available/demo.conf

In the file, ensure that you have the following values (replace the email and other the word 'demo' with the appropriate location of the app):

  >     ServerName <public ip>
  >     ServerAdmin admin@demo.com
  >     
  >     <VirtualHost *:80>
  >
  >     DocumentRoot /var/www/html/sljournalism
  >     
  >       <Directory /var/www/html/sljournalism>
  >         Allow from all
  >         Options -MultiViews
  >       </Directory>
  >     
  >       ErrorLog ${APACHE_LOG_DIR}/error.log
  >       CustomLog ${APACHE_LOG_DIR}/access.log combined
  >     
  >     </VirtualHost>

Remember to change <public ip> to your public IP.

Once you save and exit the file, ensure you enable it using the command:
  >     sudo a2ensite demo.conf

Furthermore, disable the default file using:
  >     sudo a2dissite 000-default.conf

8) Go to the root location of the www data files and clone github repo from: https://github.com/wsaqaf/sljournalism.git using the commands:

	>			sudo chown $USER:$USER -R /var/www
	>			sudo chmod -R 755 /var/www
	>     cd /var/www/html
  >     git clone https://github.com/wsaqaf/sljournalism.git

Then go into the created app folder sljournalism and run the commands:

  >     bundle install
  >     bundle exec rake secret
copy the value obtained from the last command (a long string) since you will use it in the next sep

9) Configure the app and rename it to *local_env.yml*:

Edit the contents of the file *sljournalism/config/local_env_empty.yml* and ensure all the relevant fields are filled.
The first value for the variable SECRET_KEY_BASE needs to be the string copied from the last command of the last step.
The postgres database, username and password values need to match those done in step 5 earlier

Don't forget to rename the file the file edited above from *local_env_empty.yml* to *local_env.yml*

10) Run bundle exec rake to create the database

  >     bundle exec rake assets:clobber db:schema:load RAILS_ENV=production DISABLE_DATABASE_ENVIRONMENT_CHECK=1

11) Install Phusion Passenger to connect to Apache

Install our PGP key and add HTTPS support for APT
  >     sudo apt install -y dirmngr gnupg
  >     sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7
  >     sudo apt install -y apt-transport-https ca-certificates
  >     sudo sh -c 'echo deb https://oss-binaries.phusionpassenger.com/apt/passenger bionic main > /etc/apt/sources.list.d/passenger.list'
  >     sudo apt update
  >     sudo apt install -y libapache2-mod-passenger
  >     sudo a2enmod passenger
  >     sudo apache2ctl restart

Then confirm if the installation is valid using any of the following commands:
  >     sudo passenger-install-apache2-module
  >     sudo /usr/bin/passenger-config validate-install
  >     sudo /usr/sbin/passenger-memory-stats

Add the following two lines to the demo.conf file under /etc/apache2 below the line starting with *'DocumentRoot'*:
  >     PassengerRuby /home/demo/.rbenv/versions/2.7.1/bin/ruby
  >     PassengerAppRoot /var/www/html/sljournalism

12) Restart Apache with:

  >     sudo service apache2 restart

Confirm that the app is working fine by visiting the website on your browser at:
http://<public IP or domain name>

13) In the file **sljournalism/config/local_env.yml,** fill in the top *SECRET_KEY_BASE* value with the output from step 10 and fill in the remaining information. Remember to use the postgres credentials used in step 11 above

14) Restart your http server (apache or ngix) to ensure the app is online

15) Install docker using instructions here:
https://www.hostinger.com/tutorials/how-to-install-docker-on-ubuntu

16) Install docker-composer using the commands:

  >     sudo apt-get install docker-compose

17) Add the current user to the docker group and close the ssh session and login again as shown:

  >     sudo usermod -a -G docker $USER; exit

18) install go-lang using the commands:

  >     sudo apt update; sudo apt install golang-go

19) go to /hyperledger/ and run the command:

  >     sh initialize.sh

20) go to hyperledger/ and the command:

  >     sh run.sh

**Congrats!** You should now be done and able to open the website try testing the various functions and features

#### *[Extra]* Setup SSL access for domain name
In case you have a domain name, ensure that you install an SSL certificate. You can use CertBot as shown here:
https://certbot.eff.org/lets-encrypt/ubuntubionic-apache.html

====================================

## Reseting the databases**
To reset the blockchain and database, empty the database (warning: all claim/claim review and blockchain data will be lost):

1) Go to the app's main folder and open the Rails Console using the command:

  >     rails c

2) Run the following commands to delete all claims and reviews and remove user references to the blockchain:

  >     Claim.destroy_all
  >     ClaimReview.destroy_all
  >     User.update_all("blockchain_tx=NULL")
  >     User.update_all("time_added_to_blockchain=NULL")

3) If you want to preserve the users credentials, skip this step and go to step 4. Otherwise, if you actually want to also delete the users to start from scratch, you can also use this command in Rails Console:

  >     User.destroy_all

4) Reset the hyperledger database by running the command under the hyperledger/ folder as described earlier :

  >     sh run.sh

5) Confirm by going to the website that all claims and proceed to sign up as admin if you deleted the users, or sign in as admin and add the users to the blockchain if you just removed them from the blockchain. Then you can do the other steps (add claims and review claims, etc.)

### Contact

Contact the developer walid.al-saqaf@sh.se for any comments or questions. You can also bring up issues in the repo to address ASAP.
