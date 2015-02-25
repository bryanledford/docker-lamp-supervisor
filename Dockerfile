FROM debian:wheezy

MAINTAINER Bryan Ledford <bledford@isitedesign.com>

# Prevent post install interactive prompts
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get -q -y upgrade

# Unattended install of mysql and apache2
# Info: http://www.microhowto.info/howto/perform_an_unattended_installation_of_a_debian_package.html
# Use default config, unless a previous configuration value has been set
RUN apt-get install -q -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" apache2 mysql-server

# Allow any IP address to access MySQL (not secure for production)
RUN sed -i '/^bind-address*/ s/^/#/' /etc/mysql/my.cnf

# Install of php5
RUN apt-get install -q -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" php5 php-pear php5-mysql

# Install of vim
RUN apt-get install -q -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" vim

# Restart mysql and apache2
RUN service apache2 restart
RUN service mysql start && mysql -u root --password= -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '' WITH GRANT OPTION;"

# supervisor installation && 
# create directory for child images to store configuration in
RUN apt-get -y install supervisor && \
  mkdir -p /var/log/supervisor && \
  mkdir -p /etc/supervisor/conf.d

# supervisor base configuration
COPY supervisor.conf /etc/supervisor.conf
COPY apache2.sv.conf /etc/supervisor/conf.d/
COPY mysql.sv.conf /etc/supervisor/conf.d/

# default command
CMD ["supervisord", "-c", "/etc/supervisor.conf"]
