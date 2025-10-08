+++
title =  "Configure Hugo XML Output for RSS Feed"
description = "Hugo Custom RSS for my reader"
tags = ['python', "mysql","databases", "rss"]
images = ["images/feature-image.png"]
date = "2024-06-28"
categories = ["projects"]
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

I have a mysql db that will be used to store values read from the rss feed of my hugo site. I need some add some keys to help with organization
   

### Parts of this series

1. [part 1](https://jnapolitano.com/en/posts/hugo-social-publisher/)
2. [part 2](https://jnapolitano.com/en/posts/python-rss-reader/)
3. [part 3](https://jnapolitano.com/en/posts/mysql-install-buntu/)
4. [part 4](https://jnapolitano.com/en/posts/mysql-config/)



## Resources

* [Hugo Page Resources](https://gohugo.io/content-management/page-resources/)
* [Hugo Page Params](https://gohugo.io/methods/page/params/)
* [Hugo RSS Templates](https://gohugo.io/templates/rss/)


## RSS Config

### Copy over the posts/rss.xml file from your theme

From hugo root you would do something like...

```bash

mkdir layouts && mkdir layouts/posts && cp themes/[theme]/layouts/posts/index.xml

```

### Modify the rss.xml file

#### Add post id

Hugo supports a hash of the files path. It is not always unique... but for my purposes it will likely be good enough.  

``` xml
<postid> {{ .File.UniqueID }}</postid>
```

#### Add the author's name when defined

```xml
{{ with .Site.Params.author.name }}<author_name>{{.}}</author_name>{{end}}
```

#### Add the author email when defined

```xml

      {{ with .Site.Params.author.email }}<author_email>{{.}}</author_email>{{end}}
```

#### Add a hash of the author email when defined

```xml
{{ with .Site.Params.author.email }}<author_id>{{sha256 .}}</author_id>{{end}}
```

#### The entire file

The most up to date rss file is found at [this github link](https://github.com/justin-napolitano/jnapolitano.com/blob/main/layouts/posts/rss.xml)
