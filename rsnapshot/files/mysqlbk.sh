#!/bin/sh
umask 0077
/usr/bin/mysqldump --defaults-file=/etc/mysql/debian.cnf --events --all-databases > mysqldump_all_databases.sql
/bin/chmod 0600 mysqldump_all_databases.sql
