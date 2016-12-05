# heap-mysql docker image.

Dockerized MySQL daemon as the main entrypoint.

## Usage

```
$ docker run -d -p 3306:3306 heap-memcached 
```

You can pass envrionment variables when launching the container:
```
$ docker run -d -e "VAR_MYSQL_INNODB_BUFFER_POOL_SIZE=48800M" -p 3306:3306 heap-mysql
```

## Environment variables

This image uses environment variables to override common configuration options.

The following environment variables are available (listed below with default values):

```
VAR_MYSQL_USER="admin"
VAR_MYSQL_PASS=""
VAR_MYSQL_SLOWLOG="true"
VAR_MYSQL_SLOWLOG_TIME="3"
VAR_MYSQL_SLOWLOG_INDEXES="0"
VAR_MYSQL_SERVER_ID="1"
VAR_MYSQL_BINLOG_SIZE="100M"
VAR_MYSQL_BINLOG_FORMAT="STATEMENT"
VAR_MYSQL_EXPIRE_LOGS_DAYS="14"
VAR_MYSQL_MAX_ALLOWED_PACKET="16M"
VAR_MYSQL_MAX_CONNECT_ERRORS="100000"
VAR_MYSQL_MAX_CONNECTIONS="500"
VAR_MYSQL_OPEN_FILES_LIMIT="65535"
VAR_MYSQL_INNODB_BUFFER_POOL_SIZE="100M"
VAR_MYSQL_INNODB_ADDITIONAL_MEM_POOL_SIZE="10M"
VAR_MYSQL_INNODB_LOG_FILE_SIZE="25M"
VAR_MYSQL_INNODB_LOG_BUFFER_SIZE="4M"
VAR_MYSQL_INNODB_FLUSH_LOG_AT_TRX_COMMIT="2"
VAR_MYSQL_TRANSACTION_ISOLATION="REPEATABLE-READ"
```

##  Alternate entrypoints

* [replicactl](REPLICACTL.md)
* [make-backup.sh](BACKUPS.md)

