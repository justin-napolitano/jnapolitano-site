+++
title =  "Automate Posting Hugo Blog to Social Sites...Second Attempt"
#date = "2024-06-15 22:36:34.376 -0500" 
description = "How To automate posting to social sites"
author = "Justin Napolitano"
tags = ['python', "hugo","programming","fail"]
images = ["images/feature-python.png"]
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


## Thoughts on This Second Pass


1. I will create a script that parses the sites rss feed...
2. it will then traverse the xml tree entries...
3. if a date is newer than the last publish date...
4. publish that post...

I am still thinking through how to publish. I will likely write a monolithic script here, but ideally I would write an api or a batch processor to handle this in some way. I am thinking.  


## Create a Script that Parses my Sites RSS Feed

Pull last run date from a local file.. or from a bucket if running on the cloud.. I'll update this later

```python
with open("last_run.txt", "r") as fp:
    epoch = fp.read()

# convert to integer
epoch = int(epoch)

```


### Parse the rss feed


Something like...

```python

import feedparser

try:
    NewsFeed = feedparser.parse("https://jnapolitano.com/index.xml")
    for entry in NewsFeed.entries:
        print(entry.published)
except Exception as e :
    raise e

# entry is returned in the following format and needs to be parsed into epoch
# Wed, 12 Jun 2024 00:00:00 +0000


```

### Convert the returned date to epoch

the given format is 
```Wed, 12 Jun 2024 00:00:00 +0000```

I'll have to conver that to epoch for a point of comparison. Some code below...

```python

from datetime import datetime
import time



# The given date string
date_str = "Wed, 12 Jun 2024 00:00:00 +0000"

# Define the format of the date string
date_format = "%a, %d %b %Y %H:%M:%S %z"

# Convert the date string to a datetime object
dt = datetime.strptime(date_str, date_format)

# Convert the datetime object to a timestamp (epoch time)
epoch_time = int(dt.timestamp())

print(epoch_time)

```

### Compare the returned date to the last run date

This is the really important step. I am currently just printing true... but in the next post i will write a script that actually publishes the information to socials. 
```python

if publish_date_epoch > last_run_epoch:
    print(True)
```

### Write latest to file when traversal is complete

```python
def write_current_dt_to_file(file_name = "last_run.txt"):

    try:
        # Get the current epoch time
        current_epoch_time = int(time.time())

        # Write the current epoch time to the file
        with open(file_name, "w") as file:
            file.write(str(current_epoch_time))
        return True
    except Exception as e:
        raise e
```

### Putting it all together

```python



from datetime import datetime
import time


# convert to integer
def get_last_run():
    try:
        with open("last_run.txt", "r") as fp:
            epoch = fp.read()

        epoch = int(epoch)
        return epoch
    except Exception as e:
        raise e

def get_news_feed():
    try:
        NewsFeed = feedparser.parse("https://jnapolitano.com/index.xml")
        return NewsFeed
    except Exception as e:
        raise e


def convert_to_epoch(given):

    try: 
        # The given date string
        date_str = given

        # Define the format of the date string
        date_format = "%a, %d %b %Y %H:%M:%S %z"

        # Convert the date string to a datetime object
        dt = datetime.strptime(date_str, date_format)

        # Convert the datetime object to a timestamp (epoch time)
        epoch_time = int(dt.timestamp())

        return epoch_time
    except Exception as e:
        raise e

def write_current_dt_to_file(file_name = "last_run.txt"):

    try:
        # Get the current epoch time
        current_epoch_time = int(time.time())

        # Write the current epoch time to the file
        with open(file_name, "w") as file:
            file.write(str(current_epoch_time))
        return True
    except Exception as e:
        raise e



try:
    last_run_epoch = get_last_run()
    NewsFeed = get_news_feed()
   
    for entry in NewsFeed.entries:
        given = entry.published
        # print(given)
        # print(convert_to_epoch(given))
        publish_date_epoch = convert_to_epoch(given)
        if publish_date_epoch > last_run_epoch:
            print(True)
            # in the next pass this will run the social update workflow
    
    # run the write epoch to file function
    result = write_current_dt_to_file()


except Exception as e :
    raise e

```

## Next Steps

I need to write the publishing application. I haven't figure out how I'll do that yet. I want to do some cool things, but tbh it is probably overkill for my use case. I will think on it.  
