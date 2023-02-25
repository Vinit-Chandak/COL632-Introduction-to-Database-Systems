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
  12. /usr/local/pgsql/bin/createdb test
  13. /usr/local/pgsql/bin/psql test
