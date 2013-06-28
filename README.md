twindle
=======

Twindle is a set of scripts for Twitter data analysis. The tools include a 
streaming API client which can store Twitter status updates into a Postgres
database as well as a variety of scripts used for data housekeeping, status 
categorization and trend extraction. 

Some typical use cases for twindle include: 

* Tracking a specific topic, such as a hashtag or a set of terms, to explore
  the frequency of its use over time.
* Following users to mine their activity and impact on Twitter (e.g. mentions, 
  retweets, terms used). 

Twindle uses a simple Google Spreadsheet (such as the one [here](https://docs.google.com/spreadsheet/ccc?key=0AplklDf0nYxWdENyTDlZYTNadUo2V2RjZGlIN2VqQWc#gid=0)) to 
let the user define terms and users that are to be recorded from the raw Twitter stream. Users which repeatedly match the tracking criteria are automatically added to twindle's search filter to keep track of their further communications. Note that this inbound filtering is very rough and should be refined during a second-level analysis of the collected data.

Status messages are stored by twindle into a fairly simple database structure
which can be queried for aggregate analysis. A set of included Python scripts 
can support such analysis, e.g. by importing lists of users from Twitter lists
or by geo-coding user's location settings.

Some of the functions in twindle are useful only when used with elevated API access. This particularly applies to the auto-follow function, as it easily exceeds the 
5000 follows included in normal API access.


Installing twindle
------------------

Twindle is written both in CoffeeScript/NodeJS (used for stream tracking)
and Python (used for offline analysis). To run, twindle will also require an 
instance of Postgres, and, depending on whether you want to run the application
in queued mode, RabbitMQ. 

For simplicity, the following instructions will assume a fresh install of 
Ubuntu 13.04; YMMV. To begin, we'll install the system dependencies, including
Postgres and RabbitMQ:

    sudo add-apt-repository ppa:chris-lea/node.js
    sudo apt-get update
    # optional:
    sudo apt-get install htop tmux

    sudo apt-get install postgresql-9.1 postgresql-server-dev-9.1 nodejs 
        python-virtualenv git python-dev rabbitmq-server nginx s3cmd
        supervisor
    sudo npm install -g coffee-script

Next, we'll set up a Python virtual environment as the working directory for 
twindle. We'll just put this into the home directory of the ubuntu user:

    cd /home/ubuntu
    virtualenv twindle
    cd twindle
    source bin/activate
    git clone https://github.com/pudo/twindle.git app
    cd app
    npm install
    pip install -r requirements.txt

After this, you need to create a database for twindle: 

    createuser -P twindle
    createdb -O twindle -E utf-8 twindle
    psql -f /home/ubuntu/twindle/app/schema.sql twindle

If you want to use the simple web interface that comes with twindle, you will
also need to set up a reverse proxy for it like this: 

    sudo cp deploy/nginx.conf /etc/nginx/sites-available/twindle
    sudo ln -s /etc/nginx/sites-available/twindle /etc/nginx/sites-enabled/twindle
    sudo service nginx restart 


Configuring twindle
-------------------

You'll need to visit [http://dev.twitter.com](http://dev.twitter.com) to set up
a Twitter application for twindle. After setting up a basic application, you
will be able to view your OAuth consumer credentials and to generate a pair of
access credentials through the web interface. 

Twindle is configured entirely via environment variables. Have a look at
dotenv.tmpl for the available variables and set up the twitter credentials you
have created as well as the database configuration. It makes sense to set these
variables in the login .bashrc as well as in the supervisor scripts (see below).

Finally, you'll need to set a Google Spreadsheet key to seed the search filters.
You can do this by cloning the [sample sheet](https://docs.google.com/spreadsheet/ccc?key=0AplklDf0nYxWdENyTDlZYTNadUo2V2RjZGlIN2VqQWc#gid=0), then updting the configuration with the new spreadsheet key and adapting the 
search terms to your needs. The sheet recognizes two distinct types of search 
filters: following a set of terms (``track`` in the ``type`` column) or a list of
users (``follow`` in the ``type`` column). For the list of terms, words are split 
on a comma. Searches are not case-sensitive and a word will also match as a 
hashtag.


Running the tracker
-------------------

The streaming API tracker can be run in two modes: as a two-process application 
with an intermediate queue (i.e. the reader frontend will only shuffle statuses
from the API stream onto the queue, insertion into SQL is delayed) or as a 
single process (reader and backend are combined, queueing happens through the 
node.js event loop). The two programs are: 

* ``app.coffee`` for the combined application, and 
* ``reader.coffee`` and ``backend.coffee`` are the two components of the 
  queue-based script version. Note that the backend need not be running all 
  the time, statuses which have not been persisted will be kept on the queue
  until a backend is available.

In either case, it makes sense to use a controlled environment for execution, 
such as ``supervisor``. A sample configuration file is included in
``deploy/supervisor.conf.tmpl``. As supervisor does not evaluate the user's
environment, you must set the configurations explicitly for the processes 
managed by supervisor.


Periodic tasks
--------------

The ``analysis/`` folder contains a set of Python scripts which can be used to 
further analyse the collected updates and to do some housekeeping on the database.
A ``Makefile`` is included which highlights the usage for some of these scripts. 

**dumpraw.py**

The dumpraw script will take a batch of stored tweets from the ``raw`` table 
(where they are initially stored as JSON encoded in a text field), delete them 
from the database and save them to a JSON file. The ``Makefile`` shows how this 
can be used in conjunction with the ``s3cmd`` command line utility to create a 
secondary data store in an S3 bucket.

**lists.py**

lists.py will import a Twitter list passed in as its first argument into the 
``lists`` table. Imported lists can be used to create blacklists or to track the 
activities of a certain subset of users.

**geocoding.py** 

While Twitter does have support for statuses with location information, many 
users have not activiated this function, or they are posting from devicded
without the location API. In those cases, some information with regards to 
geography can be gathered from their user profiles' ``location`` field. As this 
is a plain text field, the script uses MapQuests nominatim server to perform 
reverse geocoding against the OpenStreetMap database. The results are not very 
precise but can serve as a first indicator as to the distribution of messages.

**classify.py**

Incrementally perform regular expression-based filtering on the collected data. This script is not abstracted well at the moment and will require further generalization to be of wider use. 

Exporting data
--------------

Twindle itself does not have any data export function, we're assuming that you will either use the data directly from withtin the database or export it to another format yourself. To save and repeatedly execute SQL queries against twindle, consider using a [Freezefile](http://dataset.readthedocs.org/en/latest/freezefile.html) based on the Python dataset package included in the dependencies. This can be used to store a set of queries and repeatedly execute them, e.g. via a cron job.


License
-------

Copyright (c) 2013, Friedrich Lindenberg

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.