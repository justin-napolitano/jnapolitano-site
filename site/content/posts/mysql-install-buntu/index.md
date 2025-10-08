+++
title =  "Install MySQL Server on Ubuntu"
description = "MYSQL buntu"
author = "Justin Napolitano"
tags = ['linux','bash', "mysql","databases"]
images = ["images/featured-caesar.jpg"]
categories = ['projects']
series = ["Auto Post Hugo"]
date = "2024-06-28"
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

1. I am working on an autoposting tool for social sites.
2. in order to complete that i want a db to log the metadata of my posts
   

### Parts of this series

1. [part 1](https://jnapolitano.com/en/posts/hugo-social-publisher/)
2. [part 2](https://jnapolitano.com/en/posts/python-rss-reader/)



## MYSQL Resources

* [APT install guide](https://dev.mysql.com/doc/mysql-apt-repo-quick-guide/en/)
* [MYSQL config guide](https://dev.mysql.com/doc/mysql-getting-started/en/#mysql-getting-started-installing)
* [Post Install configuration](https://dev.mysql.com/doc/refman/8.4/en/postinstallation.html)


## Install

### Download the config files

go to this link and download the script.

```https://dev.mysql.com/downloads/repo/apt/```

### Install the release package with dpkg

> note that the w.x.y.z will change according to the release package

run 

```bash

sudo dpkg -i mysql-apt-config_w.x.y-z_all.deb
```

in my case i ran 

```bash

sudo dpkg -i mysql-apt-config_0.8.30-1_all.deb 

```

### Update apt and install

so the package above just added the mysql repository to the apt package manager. to actually install we will run 

```bash
sudo apt-get update &&  sudo apt-get install mysql-server
```

### Start mysql

mysql will likely alrady be running post install. Check the status by running

```bash

systemctl status mysql

```
