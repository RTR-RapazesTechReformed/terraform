FROM mysql:8.0

# Define variáveis de ambiente
ENV MYSQL_ROOT_PASSWORD=rootpassword
ENV MYSQL_DATABASE=techpointsdb
ENV MYSQL_USER=user
ENV MYSQL_PASSWORD=password

# Exponha a porta 3306
EXPOSE 3306

# Volume para persistência de dados
VOLUME ["/var/lib/mysql"]

# Comando para iniciar o MySQL
CMD ["mysqld"]