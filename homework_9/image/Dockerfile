FROM mariadb:11

RUN apt-get update
RUN apt-get install -y sysbench

EXPOSE 3306

LABEL version="1.0"
LABEL description="MariaDB Server"

CMD ["mariadbd"]