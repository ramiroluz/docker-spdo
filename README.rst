docker-spdo
-----------

Docker spdo image source. This is based on `ubuntu:12.04` image.
SPDO is a system for documents protocol control, used in city 
legislative chambers on Brazil. This is one of the Interlegis
free software products.

After installing docker you could add your user to the docker group.

.. code:: bash

  $ sudo gpasswd -a $USER docker

Image
-----

You can `pull` a ready to use image from Docker
(https://index.docker.io/u/ramiroluz/) running:

.. code:: bash

  $ docker pull ramiroluz/spdo


Or build this repository:

.. code:: bash

  $ git clone https://github.com/ramiroluz/docker-spdo.git
  $ cd docker-spdo/
  $ docker build -t ramiroluz/spdo .


Change `ramiroluz/spdo` to your Docker index username.

Container
---------

This image uses volumes and environment variables to control the mysql server
configuration, created by @wiliansouza. 
(https://github.com/wiliansouza/docker-mysql.git).

Volumes:

* `/etc/mysql/conf.d`: Change server configurations using it.
* `/var/lib/mysql`: Data goes here.
* `/var/log/mysql`: Access log from the container using it.

You pass with `-v` docker option. Don't forget to use absolute path here.

Environment variable:

* `MYSQL_ROOT_PASSWORD`: Root password.
* `MYSQL_DATABASE`: Database name.
* `MYSQL_USER`: If `MYSQL_DATABASE` is specified create a user.
* `MYSQL_PASSWORD`: Password for `MYSQL_USER`.
* `MYSQL_CHARACTER_SET`: Character set for `MYSQL_DATABASE`.
* `MYSQL_COLLATE`: Collate for `MYSQL_DATABASE`.
* `GRANT_HOSTNAME`: Hostname used on `GRANT` for `MYSQL_DATABASE`.

You pass with `-e` docker option.

For example, you can create the directories like this:

.. code:: bash

  $ export VOLUMES=$HOME/.containers/spdo/volumes/mysql/
  $ mkdir -p $VOLUMES{'log','lib','conf.d'}

The standard mysql configuration only accept local conections. The containers
run as separeted hosts, so it is required to change the mysql configuration to
accept conections from other hosts. It is possible to use the following code to
download the configuration to the correct prepared directory.

.. code:: bash

  $ wget https://raw.githubusercontent.com/ramiroluz/docker-spdo/master/bind.cnf -O $VOLUMES/conf.d/bind.cnf

Then, run the mysql server as follows:

.. code:: bash

  $ docker run --name mysql_1 -p 3306:3306 -d \
    -v $VOLUMES/log:/var/log/mysql \ 
    -v $VOLUMES/lib:/var/lib/mysql \
    -v $VOLUMES/conf.d:/etc/mysql/conf.d \
    -e MYSQL_ROOT_PASSWORD=interlegis \
    -e MYSQL_DATABASE=spdo -e MYSQL_USER=admin \
    -e MYSQL_PASSWORD=mypassword -t wiliamsouza/docker-mysql

Usage, ATTENTION, do not use it in production,
you must change passwords first:

.. code:: bash

  $ docker run --name spdo -d -p 8380:8380 \
    --link mysql_1:mysql_1 -t ramiroluz/spdo \
    /usr/local/bin/startup

The command above will start a container and return its ID.

To get a shell access:

.. code:: bash

  $ docker run --name spdo -i -p 8380:8380 \
    --link mysql_1:mysql_1 -t ramiroluz/spdo \
    /bin/bash

The command above will start a container give you a shell. Don't
forget to start the service running the ``startup &`` script.


After that the system should be available at http://localhost:8380
