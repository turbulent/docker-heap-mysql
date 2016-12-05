
# Backups

The images comes with a backup script that will use the percona xtrabackup tools.

/make-backup.sh will run Percona xtrabackup tools to create database snapshots and dumps.

Usage: make-backup.sh TYPE KEEP FULLBACKUPLIFE
  TYPE: full or incremental
  KEEP: how many backups to keep apart from the one being incremented. Default 2.
  FULLBACKUPLIFE: How many seconds to keep incrementing a backup, minimum 60. Default 3600.


## Examples:

```
$ docker run --name db -d -p 3306:3306 heap-mysql
$ docker exec -t -i db /make-backup.sh full
$ docker exec -t -i db /make-backup.sh incremental 5 86400
```

