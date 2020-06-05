Arvie, an Arvados' docker-compose runner & docker images' builder
=================================================================

This repo holds scripts and files to build slim docker images for
Arvados components and run them using docker-compose.

General notes
-------------

This is a Work in Progress... Can break, can fail, can even not work at all.
If that's not suitable for you, sorry. If you can deal with that, feel free to contribute :smile:

This is build using upstream's docker binaries (>=19.03), from the
`Docker's repos <https://download.docker.com/>`_. The build process uses
the "new" features from BuildKit, like caching layers, so this might fail
to build if using older/custom docker versions. These features have been
added to docker in version 18.03, so it's quite possible you already have
them in place.

Afaik, docker-compose-alike and buildkit behaviours have been incorporated in
the latest docker binaries (ie, plugin *buildx* can replace BuildKit), but haven't
tested them yet. To be done :smile:

Why?
----

Mostly because I wanted to play with the tools involved, but also, because I think it can be useful in some ways:

* *For development*: although already exists a docker image for Arvados testing/demo `arbox <https://hub.docker.com/r/arvados/arvbox-demo>`_,
  everything runs in a single image. Arvie runs every component in its own instance, so you can rebuild/recreate
  each component individually, or even test them without having to spin up all the whole cluster.
* *For Production* (some day): As I created to play with docker-compose and buildkit, it can probably 
  be used to be deployed in the cloud (ie, using `Kelda <https://kelda.io>_`. (TODO)
* *Docker images*: Includes some dockerfiles that allows you to create slim images of each Arvados component (see below). 
* *Kubernetes*: the slim images and config already available in Arvie can probably be migrated for a
  k8s setup. (TODO)
* Other usages? Ie., learn new tools/things? :smile:

Usage
-----

The building of images requires the arvados source code to be in a subdir of this repository tree,
due to docker design that does not allow to symlink to another directory in a parent/sibling dir
nor copy from them, so the easiest way is to just create a *git submodule* directory inside this repo.
The default subdir is *arvados*. 

1. Download this repo

.. code-block:: bash

   $ git clone https://github.com/netmanagers/arvie.git

2. Run the `prepare` script, to get Arvados' subtree and generate a pair of SSL keys for postgres.
   (As postgres needs the keys with certain permissions and ownership, the script will ask you for
   your sudo password):

.. code-block:: bash

   $ ./prepare

if you want to update the Arvados repo, just run

.. code-block:: bash

   $ git submodule update --checkout

3. Check the variables in the **.env** file, which will be used in a few places. Quite possible you don't
   need to change them.

4. Run the script *builder* with the image you want to build, ie.

.. code-block:: bash

   $ ./builder keepstore ws

to build those two images locally, from the current Arvados tree in your working environment.
If no image/s are give, all the instances will be built again.

Status
------

So far, the scripts can build docker images for the following components

.. code-block:: bash

   REPOSITORY                      TAG                 IMAGE ID            CREATED             SIZE
   arvados/keepstore               latest              7a9f4fac7245        15 minutes ago      88.2MB
   arvados/keep-web                latest              8ae09a142eea        17 minutes ago      87.6MB
   arvados/keepproxy               latest              2de1ff3bed23        21 minutes ago      85.6MB
   arvados/keep-balance            latest              dfa57bc21913        23 minutes ago      85.8MB
   arvados/health                  latest              ac394015b7d0        25 minutes ago      85.5MB
   arvados/crunch-dispatch-local   latest              52ef37d98166        26 minutes ago      83.8MB
   arvados/git-httpd               latest              d7aa4a0f08dc        28 minutes ago      85.3MB
   arvados/workbench               latest              c86bad628fe4        29 minutes ago      974MB
   arvados/api                     latest              c3357fe16512        35 minutes ago      911MB
   arvados/client                  latest              3b0fe999a49e        38 minutes ago      86.3MB
   arvados/server                  latest              6775654d0d9d        40 minutes ago      114MB

Running `docker-compose` can start most of the instances, create the Arvados database and populate it.

And running `docker-compose up` we get here:

.. code-block:: bash

   $ docker-compose ps
   Name                                Command                 State               Ports
   ----------------------------------------------------------------------------------------------------------------
   arvados-compose_api_1                     /scripts/ruby/app_start 8004     Up           0.0.0.0:8004->8004/tcp
   arvados-compose_controller_1              ./executable controller          Up           0.0.0.0:8003->8003/tcp
   arvados-compose_crunch-dispatch-local_1   ./executable                     Exit 1
   arvados-compose_database_1                docker-entrypoint.sh postg ...   Up           0.0.0.0:5432->5432/tcp
   arvados-compose_git-httpd_1               ./executable                     Up           0.0.0.0:9001->9001/tcp
   arvados-compose_health_1                  ./executable                     Exit 1
   arvados-compose_keep-balance_1            ./executable                     Exit 1
   arvados-compose_keep-web_1                ./executable                     Up           0.0.0.0:9003->9003/tcp
   arvados-compose_keep0_1                   ./executable                     Up           0.0.0.0:25107->25107/tcp
   arvados-compose_keep1_1                   ./executable                     Up           0.0.0.0:25108->25108/tcp
   arvados-compose_keepproxy_1               ./executable                     Up           0.0.0.0:25100->25100/tcp
   arvados-compose_nginx_1                   nginx -g daemon off;             Restarting
   arvados-compose_websocket_1               ./executable ws                  Up           0.0.0.0:8005->8005/tcp
   arvados-compose_workbench_1               /scripts/ruby/app_start 9002     Up           0.0.0.0:9002->9002/tcp


TODO
----

* Get Arvie to a useful state
* Testing (real testing)
* Improve configuration (too many hardcoded things atm)
* Add missing features/configs

Contributing to this repo
-------------------------

**Commit message formatting is significant!!**

Please see :ref:`How to contribute <CONTRIBUTING>` for more details.

