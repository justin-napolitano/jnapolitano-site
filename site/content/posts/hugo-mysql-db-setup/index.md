+++
title =  "Automate Posting Hugo Blog to Social Sites (with a db) Part 2"
date = "2024-06-15"
description = "How To automate posting to social sites"
author = "Justin Napolitano"
tags = ['python', "hugo","programming","fail"]
images = ["images/feature-image.png"]
[extra]
lang = "en"
toc = true
comment = false
copy = true
outdate_alert = true
outdate_alert_days = 120
math = false
mermaid = false
featured = false
reaction = false
+++


## Background



### Previous posts in this series

1. [part 1](https://jnapolitano.com/en/posts/hugo-social-publisher/)
2. [part 2](https://jnapolitano.com/en/posts/python-rss-reader/)
3. [part 3](https://jnapolitano.com/en/posts/mysql-install-buntu/)
4. [part 4](https://jnapolitano.com/en/posts/mysql-config/)
5. [part 5](https://jnapolitano.com/en/posts/hugo-rss-setup/)
6. [part 6](https://jnapolitano.com/en/posts/hugo-rss-mysql-update/)



### Expand a the mysql class

I create a [repo](https://github.com/justin-napolitano/mysql-utility-class.git) at ```https://github.com/justin-napolitano/mysql-utility-class.git``` to enable importing as a submodule the class that i have been workign on. 

### Set up the db

In [another part in this series](https://jnapolitano.com/en/posts/mysql-config/), I detailed setting up the mysql db via the command line. I am going to furher that workflow by modifying the files in that repo and then running thm to generat tables within my instance of mysql.


## Setup you dev environment...again

### Copy the .env file


Copy over the .env files from the previous few steps. 

### Import the Config repo 

```bash

git submodule add https://github.com/justin-napolitano/mysql-config.git mysql-config

```

### Import the utility class repo

```bash

git submodule add https://github.com/justin-napolitano/mysql-utility-class.git mysql-utility-class   

```


### Setup the package as a module 

#### From root drop an empty __init_.py file

```bash 

touch __init__.py
```

#### From the utility class directory drop another __init__.py

This one however will contain a relative import to enable access to the class

##### Touch

```bash 
cd {to the utility class directory} && touch __init__.py

```

##### Echo to file

```bash

echo "from .MySQLConnector import MySQLConnector" > __init__.py

```

#### Check the module hierarchy

We should be looking like this



```markdown
your_project/
|-- __init__.py
|-- main.py
|-- .env
`-- MySQLConnector/
    |-- __init__.py
    `-- MySQLConnector.py
```

## Create the main file

### Touch main.py

```bash

touch main.,py

```


### Modify main.py

My file currently looks like this to test the connect 

```python

from MySQLConnector import MySQLConnector

from dotenv import load_dotenv
import os



if __name__ == "__main__":
    load_dotenv()  # Load environment variables from .env file
    connection = MySQLConnector()
    connection.connect()
    connection.disconnect()

```

### Test the conection 

```bash 

python -m main.py

```

### Modify the class for more features. 

I want to be able to
* create a db
* drop a db
* use a db
* execute a script fro file 


#### Create db 

```python

 def create_database(self, database_name):
        try:
            self.cursor.execute(f"CREATE DATABASE {database_name}")
            self.cursor.execute(f"SHOW DATABASES LIKE '{database_name}'")
            result = self.cursor.fetchone()
            if result:
                print(f"Database {database_name} created successfully")
                return True
            else:
                print(f"Database {database_name} was not created")
                return False
        except Error as e:
            print(f"Error while creating database: {e}")
            return False

```

#### Drop db

```python

 def drop_database(self, database_name):
        try:
            self.cursor.execute(f"DROP DATABASE {database_name}")
            self.cursor.execute(f"SHOW DATABASES LIKE '{database_name}'")
            result = self.cursor.fetchone()
            if not result:
                print(f"Database {database_name} dropped successfully")
                return True
            else:
                print(f"Database {database_name} was not dropped")
                return False
        except Error as e:
            print(f"Error while dropping database: {e}")
            return False
```

#### use db

```python

def use_database(self,database_name):
        try:
            self.cursor.execute(f"USE {database_name}")
            print(f"Using database {database_name}")
        except Error as e:
            print(f"Error while selecting database: {e}")
```

#### Execute Script

```python

def execute_script_from_file(self, file_path):
        try:
            with open(file_path, 'r') as file:
                sql_script = file.read()
            
            sql_commands = sql_script.split(';')
            for command in sql_commands:
                if command.strip():
                    self.cursor.execute(command)
                    print(f"Executed: {command}")
            self.connection.commit()
            print("SQL script executed successfully")
        except Error as e:
            print(f"Error while executing SQL script: {e}")
```

### Test the module 

With the added logic my main.py file looks like 

```python 

def execute_script_from_file(self, file_path):
        try:
            with open(file_path, 'r') as file:
                sql_script = file.read()
            
            sql_commands = sql_script.split(';')
            for command in sql_commands:
                if command.strip():
                    self.cursor.execute(command)
                    print(f"Executed: {command}")
            self.connection.commit()
            print("SQL script executed successfully")
        except Error as e:
            print(f"Error while executing SQL script: {e}")

```

I execute with the following from the project root. 

```bash

python -m main.py

```

## The current MySQLConnector Class

Below is as it stand.. The most up to date file can always be found at ```https://github.com/justin-napolitano/mysql-utility-class.git```

```Python
import mysql.connector
from mysql.connector import Error
from dotenv import load_dotenv
import os

class MySQLConnector:
    def __init__(self):
        self.user = os.getenv('DB_USER')
        self.password = os.getenv('DB_PASSWORD')
        self.host = os.getenv('DB_HOST')
        self.database = os.getenv('DB_NAME')
        self.connection = None
        self.cursor = None

    def connect(self):
        try:
            self.connection = mysql.connector.connect(
                user=self.user,
                password=self.password,
                host=self.host
                # Do not specify database here
            )
            if self.connection.is_connected():
                self.cursor = self.connection.cursor()
                print("Connected to MySQL server")
        except Error as e:
            print(f"Error while connecting to MySQL: {e}")

    def disconnect(self):
        if self.cursor:
            self.cursor.close()
        if self.connection.is_connected():
            self.connection.close()
            print("MySQL connection is closed")

    def create_database(self, database_name):
        try:
            self.cursor.execute(f"CREATE DATABASE {database_name}")
            self.cursor.execute(f"SHOW DATABASES LIKE '{database_name}'")
            result = self.cursor.fetchone()
            if result:
                print(f"Database {database_name} created successfully")
                return True
            else:
                print(f"Database {database_name} was not created")
                return False
        except Error as e:
            print(f"Error while creating database: {e}")
            return False
        
    def drop_database(self, database_name):
        try:
            self.cursor.execute(f"DROP DATABASE {database_name}")
            self.cursor.execute(f"SHOW DATABASES LIKE '{database_name}'")
            result = self.cursor.fetchone()
            if not result:
                print(f"Database {database_name} dropped successfully")
                return True
            else:
                print(f"Database {database_name} was not dropped")
                return False
        except Error as e:
            print(f"Error while dropping database: {e}")
            return False


    def use_database(self,database_name):
        try:
            self.cursor.execute(f"USE {database_name}")
            print(f"Using database {database_name}")
        except Error as e:
            print(f"Error while selecting database: {e}")

    def execute_script_from_file(self, file_path):
        try:
            with open(file_path, 'r') as file:
                sql_script = file.read()
            
            sql_commands = sql_script.split(';')
            for command in sql_commands:
                if command.strip():
                    self.cursor.execute(command)
                    print(f"Executed: {command}")
            self.connection.commit()
            print("SQL script executed successfully")
        except Error as e:
            print(f"Error while executing SQL script: {e}")


# Usage example
if __name__ == "__main__":
    load_dotenv()  # Load environment variables from .env file
    db_name = 'testing_db'
    db = MySQLConnector()
    db.connect()
    db.create_database(db_name)  # Replace 'new_database' with the desired database name
    db.use_database(db_name)  # Use the specified database from .env
    db.drop_database(db_name)
    db.disconnect()

```
