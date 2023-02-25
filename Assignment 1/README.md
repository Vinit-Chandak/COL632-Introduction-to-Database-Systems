# PostgreSQL version: 8.4.22

# Steps to set-up PostgreSQL:
1. Install clang-14
2. Download and extract the source files for PostgreSQL 8.4.22
3. Run the following commands in the extracted directory:
    1. ./configure CC='clang-14'
    2. gmake
    3. sudo bash
    4. su
    5. gmake install
    6. adduser postgres
    7. mkdir /usr/local/pgsql/data
    8. chown postgres /usr/local/pgsql/data
    9. su - postgres
    10. /usr/local/pgsql/bin/initdb -D /usr/local/pgsql/data
    11. /usr/local/pgsql/bin/postgres -D /usr/local/pgsql/data >logfile 2>&1 &
    12. /usr/local/pgsql/bin/createdb test ('test' is the name of the database)
    13. /usr/local/pgsql/bin/psql test

# Steps to start the PostgreSQL server:
1. switch to postgres user -> sudo su - postgres
2. cd ~
3. /usr/local/pgsql/bin/pg_ctl start -l logfile -D /usr/local/pgsql/data
4. /usr/local/pgsql/bin/psql test 
(You can export the paths to make this process easy)
## The assignment was based on Baseball dataset. The dataset comprised of pitching, hitting, and fielding statistics for US Major League Baseball from 1871 through 2014. The details can be found here: [Assignment 1](https://github.com/Vinit-Chandak/COL632-Introduction-to-Database-Systems/blob/main/Assignment%201/COL362_Assignment1.pdf)
## We had to submit only one file which can be found here: [2022EET2109.sql](https://github.com/Vinit-Chandak/COL632-Introduction-to-Database-Systems/blob/main/Assignment%201/2022EET2109.sql)
