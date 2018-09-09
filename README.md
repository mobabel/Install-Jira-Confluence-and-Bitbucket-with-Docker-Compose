# Install Jira, Confluence and Bitbucket with Docker Compose

## Create network

1 . Create network for atlassian

~~~~
$ docker network create --driver bridge network-atlassian || true
$ docker network inspect network-atlassian
~~~~


## Install Nginx

1 . Create volume for nginx

~~~~
$ docker volume create nginxdata
$ docker volume inspect nginxdata

$ docker volume create nginxwww
$ docker volume inspect nginxwww
~~~~
You will find nginxdata is located into:

/var/lib/docker/volumes/nginxdata/_data
/var/lib/docker/volumes/nginxwww/_data


Copy opt/nginx/docker-compose.yml to /opt/nginx/docker-compose.yml

~~~~
$ docker-compose up -d
~~~~

~~~~
$ docker exec -it nginx /bin/bash 
$ nginx -V
~~~~


## Install PostgreSQL

1 . Compose and run docker postgre

Copy opt/postgre/docker-compose.yml to /opt/postgre/docker-compose.yml

volume links to /var/postgre_atlassian/data

~~~~
$ docker-compose up -d
~~~~

2 . Create database in docker postgre
~~~~
$ docker exec -it postgre_atlassian /bin/bash 
$ cd /var/
$ vi create_db.sh 
$ sh create_db.sh 
~~~~

3 . Check database
~~~~
$ su postgres
$ psql
postgres=# \l
postgres=# \q
~~~~


## Install Jira

1 . Create volume for jira

~~~~
$ docker volume create jiradata
$ docker volume inspect jiradata
~~~~

You will find jiradata is located into:

/var/lib/docker/volumes/jiradata/_data

2 . Compose and run docker jira

Copy opt/jira/docker-compose.yml to /opt/jira/docker-compose.yml

~~~~
$ docker-compose up -d
# check logs
$ docker logs jira
$ docker exec -it jira /bin/bash 
~~~~


3 . Run and restore Jira from backup file [Skip if not necessary]

http://jira_ip:8085

restore jira data
Copy the backup jira_db_xxxx.zip file to /var/atlassian/jira/import under jira image
~~~~
$ docker exec -it jira /bin/bash 
$ cd /var/atlassian/jira/import
$ wget http://xxxxx/jira_db_xxxx.zip
~~~~

restore database data
~~~~
$ docker exec -it jira /bin/bash 
$ cd /var/atlassian/jira/
$ wget http://xxxxx/jira_data_xxx.tgz
$ tar -zxvf jira_data_xxx.tgz
~~~~
Set license and some required configurations, go to System->Import & Export. 
Then restore from the db data backup file.

4 . Restart docker jira


5 . Update license

* Update license, otherwise Jira Software does not work as wished
* Go to System to execute re-index
* Update Add-ons


## Install Confluence

1 . Create volume for confluence

~~~~
$ docker volume create confluencedata
$ docker volume inspect confluencedata
~~~~

You will find confluencedata is located into:

/var/lib/docker/volumes/confluencedata/_data

2 . Compose and run docker confluence

Copy opt/confluence/docker-compose.yml to /opt/confluence/docker-compose.yml

~~~~
$ docker-compose up -d
# check logs
$ docker logs confluence
$ docker exec -it confluence /bin/bash 
~~~~


3 . Run and restore Confluence [Skip if not necessary]

http://confluence_ip:8093

### Set up database

* Hostname: postgre_atlassian
* Port: 5432
* Database name: confdbname
* Username: confdbusername

### Restore Data

You can restore data by installation.(To avoid problem by installation, recommend to create a user account, complete the configuration and then restore after login)
Copy the backup confluence_xxxx.zip file to /var/lib/docker/volumes/confluencedata/_data/restore/confluence_xxxx.zip


You can also restore later, go to System -> General Configuration -> Backup and Restore. 
Then restore from the backup file.

or
~~~~
$ docker exec -it confluence /bin/bash 
$ cd /var/atlassian/confluence/restore

$ wget http://xxxxx/confluence_xxxx.zip
~~~~


4 . Restart docker confluence


5 . Update license

* Update license, otherwise Confluence Software does not work as wished
* Go to System to execute re-index
* Install required Add-ons


## Install Bitbucket

1 . Create volume for bitbucket

~~~~
$ docker volume create bitbucketdata
$ docker volume inspect bitbucketdata
~~~~

You will find bitbucketdata is located into:

/var/lib/docker/volumes/bitbucketdata/_data

2 . Compose and run docker bitbucket

Copy opt/bitbucket/docker-compose.yml to /opt/bitbucket/docker-compose.yml

~~~~
$ docker-compose up -d
# check logs
$ docker logs bitbucket
$ docker exec -it bitbucket /bin/bash 
~~~~


3 . Run and restore bitbucket [Skip if not necessary]

http://bitbucket_ip:7990

### Restore database

set configuration when install bitbucket, it is better to give one temprary database, to avoid dropping database before dump.

* Hostname: postgre_atlassian
* Port: 5432
* Database name: confdbname_tmp
* Username: confdbusername

Or go to /var/atlassian/bitbucket/shared folder and edit the bitbucket.properties file.

~~~~
jdbc.url=jdbc:postgresql://postgre_atlassian:5432/bitbucketdbname
~~~~

After installation, restore database

~~~~
$ docker stop bitbucket

$ docker exec -it postgre_atlassian /bin/bash 
$ cd /var/
$ wget http://xxxxx/bitbucket_xxxxx.bak

$ su postgres
$ psql
$ drop database bitbucketdb;
# then create database depends on create_db.sh
$ create database bitbucketdb;
$ GRANT ALL PRIVILEGES ON DATABASE bitbucketdb TO bitbucketdbuser;
$ ALTER database bitbucketdb owner to bitbucketdbuser;
$ \q

$ psql bitbucketdb < /var/bitbucket_xxxxx.bak

$ docker start bitbucket
~~~~

### Restore Data, Repositories

Install bitbucket, create a user account, complete the configuration.

Copy the backup bitbucket_data_xxxx.tgz file to /var/lib/docker/volumes/bitbucketdata/_data/shared/bitbucket_data_xxxx.tgz

~~~~
$ docker exec -it bitbucket /bin/bash 
$ cd /var/atlassian/bitbucket/shared/

$ wget http://xxxxx/bitbucket_data_xxxx.tgz
$ tar -zxvf bitbucket_data_xxxx.tgz
~~~~


4 . Restart docker bitbucket


5 . Update license

* Update license, otherwise bitbucket Software does not work as wished
* Go to System to execute re-index
* Install required Add-ons

## Links

[Install JIRA with Docker Compose](https://nellmedina.github.io/install-jira-with-docker-compose/)

[blacklabelops](https://github.com/blacklabelops/jira)







