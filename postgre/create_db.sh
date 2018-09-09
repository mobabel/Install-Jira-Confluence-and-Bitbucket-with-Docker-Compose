#!/bin/bash

set -e
set -u

POSTGRES_USER="postgres"
USER="user"

create_user_and_database() {
	local database=$1
	local pwd=$2
	local special=$3
	local coding=""
	
	if [ "$special" == "y" ]
		then
		   local coding=" WITH ENCODING 'UNICODE' LC_COLLATE 'C' LC_CTYPE 'C' TEMPLATE template0"
	fi
	
	echo "  Creating user '$database$USER' and database '$database' "
	psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
	    DROP ROLE IF EXISTS $database$USER;
	    DROP USER IF EXISTS $database$USER;
	    
		CREATE USER $database$USER;
		ALTER ROLE $database$USER LOGIN;
		ALTER USER $database$USER WITH encrypted PASSWORD '$pwd';
		CREATE DATABASE $database $coding;
		
	    GRANT ALL PRIVILEGES ON DATABASE $database TO $database$USER;
		ALTER database $database owner to $database$USER;
EOSQL
}

create_user_and_database "jiradb" "yourjirapwd" "y"
create_user_and_database "confdb" "yourconfpwd" "n"
create_user_and_database "bitbucketdb" "yourbitbucketpwd" "n"
create_user_and_database "bitbucketdb_tmp" "yourbitbucketpwd" "n"

echo "Multiple databases created"