#!/bin/bash 

/systpl/systpl.jinja.py /systpl/my.cnf.tmpl > /etc/mysql/my.cnf
/systpl/systpl.jinja.py /systpl/make-backup.sh.tmpl > /make-backup.sh
chmod 755 /make-backup.sh

####
VOLUME_HOME="/vol/database/`hostname`-mysql"
VOLUME_TMP="/vol/database/`hostname`-mysql-tmp"
CONF_FILE="/etc/mysql/my.cnf"
LOG="/vol/logs/`hostname`-mysql-error.log"

# Set permission of config file
chmod 644 ${CONF_FILE}
chmod 644 /etc/mysql/conf.d/mysqld_charset.cnf

StartMySQL ()
{
    /usr/bin/mysqld_safe > /dev/null 2>&1 &

    # Time out in 1 minute
    LOOP_LIMIT=13
    for (( i=0 ; ; i++ )); do
        if [ ${i} -eq ${LOOP_LIMIT} ]; then
            echo "Time out. Error log is shown as below:"
            tail -n 100 ${LOG}
            exit 1
        fi
        echo "=> Waiting for confirmation of MySQL service startup, trying ${i}/${LOOP_LIMIT} ..."
        sleep 5
        mysql -uroot -e "status" > /dev/null 2>&1 && break
    done
}

CreateMySQLUser()
{
	StartMySQL
	if [ "$VAR_MYSQL_PASS" = "**Random**" ]; then
	    unset VAR_MYSQL_PASS
	fi

	export VAR_MYSQL_PASS=${VAR_MYSQL_PASS:-$(pwgen -s 12 1)}
	_word=$( [ ${VAR_MYSQL_PASS} ] && echo "preset" || echo "random" )
	echo "=> Creating MySQL user ${VAR_MYSQL_USER} with ${_word} password"

	mysql -uroot -e "CREATE USER '${VAR_MYSQL_USER}'@'%' IDENTIFIED BY '$VAR_MYSQL_PASS'"
	mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO '${VAR_MYSQL_USER}'@'%' WITH GRANT OPTION"


	echo "=> Done!"

	echo "========================================================================"
	echo "You can now connect to this MySQL Server using:"
	echo ""
	echo "    mysql -u$VAR_MYSQL_USER -p$VAR_MYSQL_PASS -h<host> -P<port>"
	echo ""
	echo "Please remember to change the above password as soon as possible!"
	echo "MySQL user 'root' has no password but only allows local connections"
	echo "========================================================================"

	mysqladmin -uroot shutdown
}

if [[ ! -d $VOLUME_TMP ]]; then
    echo "=> Creating MySQL TMP in $VOLUME_TMP"
    mkdir -p $VOLUME_TMP
    chown heap:root $VOLUME_TMP
    echo "=> Done!"  
fi

if [[ ! -d $VOLUME_HOME ]]; then
    echo "=> An empty or uninitialized MySQL volume is detected in $VOLUME_HOME"
    echo "=> Installing MySQL ..."
    if [ ! -f /usr/share/mysql/my-default.cnf ] ; then
        cp /etc/mysql/my.cnf /usr/share/mysql/my-default.cnf
    fi 
    mysql_install_db > /dev/null 2>&1
    echo "=> Done!"  
    echo "=> Creating admin user ..."
    CreateMySQLUser
else
    echo "=> Using an existing volume of MySQL"
fi



# Set MySQL REPLICATION - MASTER
if [ -n "${VAR_MYSQL_REPLICATION_MASTER}" ]; then 
    echo "=> Configuring MySQL replication as master ..."
    if [ ! -f ${VOLUME_HOME}/.master.configured ]; then
        echo "=> Starting MySQL ..."
        StartMySQL
        echo "=> Creating a log user ${VAR_MYSQL_REPLICATION_USER}:${VAR_MYSQL_REPLICATION_PASSWORD}"
        mysql -uroot -e "CREATE USER '${VAR_MYSQL_REPLICATION_USER}'@'%' IDENTIFIED BY '${VAR_MYSQL_REPLICATION_PASSWORD}'"
        mysql -uroot -e "GRANT REPLICATION SLAVE ON *.* TO '${VAR_MYSQL_REPLICATION_USER}'@'%'"
        echo "=> Done!"
        mysqladmin -uroot shutdown
        touch ${VOLUME_HOME}/.master.configured
    else
        echo "=> MySQL replication master already configured, skipping."
    fi
fi

# Set MySQL REPLICATION - SLAVE
if [ -n "${VAR_MYSQL_REPLICATION_SLAVE}" ]; then 
    echo "=> Configuring MySQL replication as slave ..."
    if [ -n "${VAR_MYSQL_REPLICATION_HOST}" ] && [ -n "${VAR_MYSQL_REPLICATION_PORT}" ]; then
        if [ ! -f ${VOLUME_HOME}/.slave.configured ]; then
            echo "=> Starting MySQL ..."
            StartMySQL
            echo "=> Setting master connection info on slave"
            mysql -uroot -e "STOP SLAVE"
            mysql -uroot -e "CHANGE MASTER TO MASTER_HOST='${VAR_MYSQL_REPLICATION_HOST}',MASTER_USER='${VAR_MYSQL_REPLICATION_USER}',MASTER_PASSWORD='${VAR_MYSQL_REPLICATION_PASSWORD}',MASTER_PORT=${VAR_MYSQL_REPLICATION_PORT}, MASTER_CONNECT_RETRY=30"
            echo "=> Done!"
            mysqladmin -uroot shutdown
            touch ${VOLUME_HOME}/.slave.configured
        else
            echo "=> MySQL replicaiton slave already configured, skipping."
        fi
    else 
        echo "=> Cannot configure slave, please link it to another MySQL container with alias as 'mysql'"
        exit 1
    fi
fi

exec /usr/sbin/mysqld
