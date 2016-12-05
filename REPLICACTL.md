  
    Usage: replicactl COMMAND [options]
    
    replicactl - MySQL replication control.
    
    Options:
      -d		Activate debugging logs
    
    Commands:
      master-status		Display the MySQL replica master status.
      master-reset		Reset the replica master.
      master-slaves		List MySQL slaves on this master.
      slave-status		Display the MySQL slave status
      slave-check		Run a slave check
      slave-init		Initialize the slave replication with a logfile and a log position.
      slave-start		Start the slave threads.
      slave-stop		Stop the slave threads.
      slave-reset		Reset the slave threads.
    
   
# replicactl examples

    docker exec mysqlmaster /replicactl master-status
    *************************** 1. row ***************************
            File: mysql-bin.000006
        Position: 107
    Binlog_Do_DB:
    Binlog_Ignore_DB:

    docker exec mysqlmaster /replicactl slave-check
    Slave_IO: 1
    Slave_SQL: 1
    Seconds behind master: 0
    Last error: None
    
    OK


    docker exec mysqlmaster /replicactl slave-init mysql-bin.0005 127
    OK

 
