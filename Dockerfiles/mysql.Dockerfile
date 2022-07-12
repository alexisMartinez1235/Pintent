ARG mysqlVersion

FROM mysql:${mysqlVersion}
  RUN apt-get update -y
  RUN apt-get install -y procps  

  RUN mkdir /home/mysql
  RUN mkdir /usr/src/database

  RUN chown mysql:mysql -R /home/mysql
  RUN chown mysql:mysql -R /usr/src/database

# USER mysql

# RUN pwgen -s -1 16 > '$MYSQL_NEXT_PW_ROOT_FILE'
# RUN pwgen -s -1 16 > '$MYSQL_NEXT_PW_FILE'

