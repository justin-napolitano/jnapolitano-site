+++
title =  "Configure mysql server on ubuntu"
description = "MYSQL config buntu"
tags = ['python', "mysql","databases"]
images = ["images/feature-image.png"]
date = "2024-06-27"
categories = ["projects"]
series = ["Auto Post Hugo"]

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


## Why

I installed mysql in the previous post. Now I need to setup users, create a db, and create a table.  
   

### Parts of this series

1. [part 1](https://jnapolitano.com/en/posts/hugo-social-publisher/)
2. [part 2](https://jnapolitano.com/en/posts/python-rss-reader/)
3. [part 3](https://jnapolitano.com/en/posts/mysql-install-buntu/)



## MYSQL Resources

* [APT install guide](https://dev.mysql.com/doc/mysql-apt-repo-quick-guide/en/)
* [MYSQL config guide](https://dev.mysql.com/doc/mysql-getting-started/en/#mysql-getting-started-installing)


## Create a new user

### Login as Root


```bash 

mysql -u root -p

```

### Create some users

In my case I will create 4 users accounts.  

1. Cobra@localhost
2. Cobra@jnapolitano.com
3. admin@localhost
4. dummy@localhost

```dummy is just used to test service connection and has not access grants or writes```

``` sql

CREATE USER 'cobra'@'localhost'
  IDENTIFIED BY 'password';
GRANT ALL
  ON *.*
  TO 'cobra'@'localhost'
  WITH GRANT OPTION;

 

CREATE USER 'admin'@'localhost'
  IDENTIFIED BY 'password';
GRANT RELOAD,PROCESS
  ON *.*
  TO 'admin'@'localhost';

CREATE USER 'dummy'@'localhost';

```

> ACTUALLY enter a password above. Do not use password as the user password'


### Logout of root

enter ```EXIT``` in terminal

### Login as your user

In my case I pass ```mysql -u cobra -p``` back to the terminal.  

## Create a DB 

I will create a db for my personal website. The first command to run is

```sql

CREATE DATABASE jnapolitano;

```

### Use your new db

```sql

USE jnapolitano;
```

### Create the posts table

```sql 

CREATE TABLE posts
(
  id                    BINARY(16) NOT NULL DEFAULT (UUID_TO_BIN(UUID())),  # Unique ID for the record. This a smallish and not a very high performance db this should be fine. 
  author                BINARY(16),                                         # id of author
  publish_date          DATE,                                               # publish date
  description           VARCHAR(150),                                       # post description
  link                  VARCHAR(150),                                       # Link to post
  title                 VARCHAR(150),                                       # title of hte post
  PRIMARY KEY           (id)                                                # Make the id the primary key
);

```

### Create the authors table

```sql

CREATE TABLE authors
(
  id                    BINARY(16) NOT NULL DEFAULT (UUID_TO_BIN(UUID())),  # Unique ID for the record. This a smallish and not a very high performance db this should be fine. 
  name                  VARCHAR(150),                                      # name of author
  PRIMARY KEY           (id)                                                # Make the id the primary key
);

```


### Create the mastodon post table

I will be adding support for other systems. I am starting with mastodon. 

```sql 

CREATE TABLE mastodon_posts
(
  id                    BINARY(16) NOT NULL DEFAULT (UUID_TO_BIN(UUID())),  # Unique ID for the record. This a smallish and not a very high performance db this should be fine. 
  post_id               BINARY(16),                                         # name of author
  mastodon_post         VARCHAR(150),                                       # THE POST ID.. if it returns
  PRIMARY KEY           (id)                                                # Make the id the primary key
);

```


