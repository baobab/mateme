#!/bin/sh
#
# wget ow.ly/MQMy # MQMy - pneumonic: Make My
# chmod +x prepare_ubuntu_for_deploy.sh
# sudo ./prepare_ubunt_for_deploy.sh

if [ -z "$SUDO_USER" ]; then
    echo "$0 must be called from sudo. Try: 'sudo ${0}'"
    exit 1
fi

set_mysql_root_password () {
  echo "Enter the root password to setup mysql with:"
  read MYSQL_ROOT_PASSWORD
  echo "mysql-server mysql-server/root_password select ${MYSQL_ROOT_PASSWORD}" | debconf-set-selections
  echo "mysql-server mysql-server/root_password_again select ${MYSQL_ROOT_PASSWORD}" | debconf-set-selections
}

if [ ! "$MYSQL_ROOT_PASSWORD" ]; then set_mysql_root_password; fi

if [ ! "$PRODUCTION_PASSWORD" ]; then 
  echo "Enter password for production database user mateme:"
  read PRODUCTION_PASSWORD
fi

echo "Creating user: deploy"
useradd -d /home/deploy -m deploy

echo "Giving deploy sudo"
echo "deploy          ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

su deploy -c "mkdir /home/deploy/.ssh"

# keys to login with
wget -qO- /tmp/allowed_public_keys http://github.com/mikeymckay/mateme/raw/master/script/allowed_public_keys >> /home/deploy/.ssh/authorized_keys

chmod 755 /home/deploy/.ssh/authorized_keys

apt-get --assume-yes install build-essential apache2 mysql-server openssh-server git-core wget ruby libxml2-dev libxslt1-dev ruby1.8-dev rdoc1.8 irb1.8 libopenssl-ruby1.8 rsnapshot nginx libmysqlclient15-dev irb

create_database() {
  local db_name=$1
  local user_name=$2
  local user_password=$3
  echo "Creating database '${db_name}' with username '${user_name}' and password '${user_password}'"

  echo "CREATE DATABASE ${db_name};" | mysql -u root -p$MYSQL_ROOT_PASSWORD
#  mysql -u root -p$MYSQL_ROOT_PASSWORD ${db_name} < /var/www/chits/db/core_data.sql
  echo "INSERT INTO user SET user='${user_name}',password=password('${user_password}'),host='localhost';
  FLUSH PRIVILEGES;
  GRANT ALL PRIVILEGES ON ${db_name}.* to ${user_name}@'%' IDENTIFIED BY '${user_password}';" | mysql -u root mysql -p$MYSQL_ROOT_PASSWORD
}

create_database "mateme_production" "mateme" "${PRODUCTION_PASSWORD}"
#create_database "mateme_development" "chits_live" "${CHITS_LIVE_PASSWORD}"
# TODO use a core DB without users
#create_database "chits_testing" "chits_tester" "useless_password"

#sed -i 's/^snapshot_root.*/snapshot_root\t\/var\/www\/chits\/backups\//' /etc/rsnapshot.conf
# Comment out all interval and backup lines
#sed -i 's/^\(interval.*\)/#\1/' /etc/rsnapshot.conf
#sed -i 's/^\(backup.*\)/#/' /etc/rsnapshot.conf
#echo "
#interval\tdaily\t7
#interval\tweekly\t4
#interval\tmonthly\t6

#backup_script\t/var/www/chits/scripts/dump_database.sh\t/var/www/chits/database_dumps
#" >> /etc/rsnapshot.conf

#PATH_TO_DUMP_SCRIPT="/var/www/chits/scripts/dump_database.sh"
#echo "#!/bin/bash
#mysqldump -u chits_live -p${CHITS_LIVE_PASSWORD} chits_live > chits_live.sql
#" >> ${PATH_TO_DUMP_SCRIPT}
#chmod +x ${PATH_TO_DUMP_SCRIPT}
#chmod -r ${PATH_TO_DUMP_SCRIPT}

#sed -i 's/^\# \(\d\)/\1/' /etc/rsnapshot.conf

wget --output-document=rubygems-1.3.5.tgz http://rubyforge.org/frs/download.php/60718/rubygems-1.3.5.tgz
tar xvf rubygems-1.3.5.tgz --directory /tmp
ruby /tmp/rubygems-1.3.5/setup.rb
ln -s /usr/bin/gem1.8 /usr/bin/gem
gem sources -a http://gems.github.com
echo "Installing testing tools"
gem install gemcutter
gem tumble
gem install -v=2.3.2 rails
gem install passenger mongrel rack cucumber mechanize rspec webrat mysql fastercsv rcov

mkdir --parents /var/www/mateme
chown deploy:deploy /var/www/mateme
