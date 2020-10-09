helm install postgresql center/bitnami/postgresql -n dbs --create-namespace
helm install pgadmin center/runix/pgadmin4 -n dbs
helm install mysql center/bitnami/mysql -n dbs
helm install phpmyadmin center/bitnami/phpmyadmin -n dbs --set db.host=mysql
helm install mongodb center/bitnami/mongodb-sharded -n dbs