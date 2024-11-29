Поднять сервис db_va можно командой:

`docker-compose up otusdb`

Для подключения к БД используйте команду:

`docker-compose exec otusdb mysql -u root -p12345 otus`

Для использования в клиентских приложениях можно использовать команду:

`mysql -u root -p12345 --port=3309 --protocol=tcp otus`

---
## Результаты sysbench


```
root@ce2be4ffc7ae:/# sysbench oltp_read_write --db-driver=mysql --table-size=10000000 --mysql-user=root --mysql-password=12345 --mysql-db=lifter_db --mysql-host=localhost --mysql-port=3309 --threads=12 prepare
sysbench 1.0.20 (using system LuaJIT 2.1.0-beta3)

Initializing worker threads...

Creating table 'sbtest1'...
Inserting 10000000 records into 'sbtest1'
Creating a secondary index on 'sbtest1'...
root@ce2be4ffc7ae:/# sysbench oltp_read_write --db-driver=mysql --table-size=10000000 --mysql-user=root --mysql-password=12345 --mysql-db=lifter_db --mysql-host=localhost --mysql-port=3309 --threads=12 run
sysbench 1.0.20 (using system LuaJIT 2.1.0-beta3)

Running the test with following options:
Number of threads: 12
Initializing random number generator from current time


Initializing worker threads...

Threads started!

SQL statistics:
queries performed:
read:                            372904
write:                           106544
other:                           53272
total:                           532720
transactions:                        26636  (2660.02 per sec.)
queries:                             532720 (53200.44 per sec.)
ignored errors:                      0      (0.00 per sec.)
reconnects:                          0      (0.00 per sec.)

General statistics:
total time:                          10.0131s
total number of events:              26636

Latency (ms):
min:                                    0.66
avg:                                    4.51
max:                                   78.98
95th percentile:                       12.52
sum:                               120072.25

Threads fairness:
events (avg/stddev):           2219.6667/147.82
execution time (avg/stddev):   10.0060/0.00
```