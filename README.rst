Arvie, an Arvados' docker-compose runner & docker images' builder
=================================================================

This repo holds scripts and files to build slim docker images for
Arvados components and run them using docker-compose.

TL;DR: It works! :D
-----

Arvados seems to fail if you're using **cgroup v2**, so make sure you're using 
The rest of this documentation needs update, that will be my next step. In the meantime, you can get arvie up and running with these steps:

1. download the repo and cd to it
2. create an environment

.. code-block:: bash
   ./arvie env

3. populate the gems/pips/npm caches (you'll need this only the 1st time, or when rebuilding them), it will take some time

.. code-block:: bash
   ./arvie prepare    # for your 1st time
   ./arvie prepare -c # when re-building

4. build arvie images locally. If you don't want to build them locally, you can download them from dockerhub (just skip this step, jump to next
   step, and images will be downloaded. Note that dockerhub is imposing limits, so this might take a while.

.. code-block:: bash
   ./arvie build

5. run arvie

.. code-block:: bash
    ./arvie up

6. Add an entry in ``/etc/hosts`` to get DNS entries for your cluster:

.. code-block:: bash
   export ARVIE_CLUSTER_NAME=arvie
   export DOMAIN=arv.local
   echo \
       127.0.0.2 \
       api.${ARVIE_CLUSTER_NAME}.${DOMAIN} \
       keep.${ARVIE_CLUSTER_NAME}.${DOMAIN} \
       keep0.${ARVIE_CLUSTER_NAME}.${DOMAIN} \
       collections.${ARVIE_CLUSTER_NAME}.${DOMAIN} \
       download.${ARVIE_CLUSTER_NAME}.${DOMAIN} \
       ws.${ARVIE_CLUSTER_NAME}.${DOMAIN} \
       workbench.${ARVIE_CLUSTER_NAME}.${DOMAIN} \
       workbench2.${ARVIE_CLUSTER_NAME}.${DOMAIN} \
       ${ARVIE_CLUSTER_NAME}.${DOMAIN} \
       | sudo tee --append /etc/hosts

7. Add the CA certificate to your browser: this will prevent security errors when accessing Arvados services with your web browser.

   * Go to the certificate manager in your browser.
   In Chrome, this can be found under “Settings → Advanced → Manage Certificates” or by entering chrome://settings/certificates in the URL bar.
   In Firefox, this can be found under “Preferences → Privacy & Security” or entering about:preferences#privacy in the URL bar and then choosing “View Certificates…”.
   Select the “Authorities” tab, then press the “Import” button. Choose `arvie.arv.local-CA.crt`

   The certificate will be added under “__ARVIE__”.

8. Enter the URL `https://workbench.arvie.arv.local:8443`_ in your browser.

9. Log in to your cluster (initial user/pass: alice/alice)

10. If you want to run an arvados' shell run

.. code-block:: bash
   docker exec -ti shell /bin/bash

11. Stop Arvie with ``./arvie down``

Data will be persisted under the ``./local/arvie`` subdir so, if you start arvie again, your work will be
available again.

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
  each component individually, or even test them without having to spin up or rebuild the whole cluster again.
* *For Production* (some day): As I'm writing this to play with docker-compose and buildkit, it can probably 
  be used to be deployed in the cloud (ie, using `Kelda <https://kelda.io>`_. (TODO)
* *Speed*: building **ALL** the images from scratch takes less that 10 minutes in my laptop (i7, 16GB ram).
  After the initial build, rebuilding any component takes somewhere between 5 seconds to a minute (Rails images
  are the ones that take most time).
* *Networked infrastructure*: arvie creates a docker network where each Arvados' component runs in its own *named* container,
  making it easier to spot components' relationships.
* *Docker images*: you can create your own Arvados' docker images for each component (see below).
  I'm uploading images built from Arvados' *master* branch to a `dockerhub repo https://hub.docker.com/u/nmarvie`_
  so you can use this without needed to build anything but the caches
* *Kubernetes*: the slim images and config already available in Arvie can probably be migrated for a
  k8s setup. (TODO)
* Other usages? Ie., learn new tools/things? :smile:

Repository layout
-----------------

To make it easier to use arvie or modify/customize it, things are organized in different subdirs:

* arvados: contains a copy of Arvados' repository. It is downloaded and populated when you run
  ``arvie prepare``. It's a git-submodule of Arvie, so you can either manage it as such or just
  change to it and manage independently. This directory is usually mounted in the running instances
  under ``/usr/src/arvados``.
* cache: holds gems, pips, npms and go packages that are used in the Rails apps or in various build
  stages, to speed things.
* configs: the configuration files for Arvados, Nginx, Postgresql are stored here. They're mounted
  as volumes in the instances, so you can modify them, restart/reload the process and change will
  be reflected in your cluster.
* docker-compose: different ``docker-compose.yml`` files that are used to build images or launch
  the cluster.
* scripts: start scripts that are used when starting the Arvados' components.
* commands: commands that are used to manage Arvie. These files are read by the ``arvie`` command,
  and presented to you as a sub-command. Run ``arvie`` with no parameters, and you'll get a list
  of the available commands. If you want to add another subcommand for your work, just drop a file
  in this directory and it will be automatically available as an ``arvie`` subcommand. Check the
  files for examples on how to write/organize them.
* dockerfiles: these are the Dockerfiles used to build the different Arvados' images.

Usage
-----

The building of images requires the arvados source code to be in a subdir of this repository tree,
due to docker design that does not allow to symlink to another directory in a parent/sibling dir
nor copy from them, so the easiest way is to just create a *git submodule* directory inside this repo.
The default subdir is *arvados*. 

1. Download this repo

.. code-block:: bash

   git clone https://github.com/netmanagers/arvie.git

2. Check the variables in the ``.env`` file, which will be used in a few places. Quite possible you don't
   need to change them. If unsure, leave them as they are. Default configuration work creating everything
   under Arvie's own directory.

3. Run ``./arvie up``. The first time you run it, it will first run the ``prepare`` subcommand, to 
   populate the Arvados directory, create SSL certs for Postgresql and populate the ``cache`` subdirs.
   As postgres needs the keys with certain permissions and ownership, the script will ask you for
   your sudo password.

   First run will take some time to start, as ``prepare`` will download and build a few gems that Arvadosi
   needs and then download the docker images from DockerHub.

   This is usually ~10 minutes (you'll see the build process on your screen).

4. Add an entry in ``/etc/hosts`` to get DNS entries for your cluster:

.. code-block:: bash

   export ARVIE_CLUSTER_NAME=arvie
   export DOMAIN=arv.local
   echo \
       127.0.0.2 \
       api.${ARVIE_CLUSTER_NAME}.${DOMAIN} \
       keep.${ARVIE_CLUSTER_NAME}.${DOMAIN} \
       keep0.${ARVIE_CLUSTER_NAME}.${DOMAIN} \
       collections.${ARVIE_CLUSTER_NAME}.${DOMAIN} \
       download.${ARVIE_CLUSTER_NAME}.${DOMAIN} \
       ws.${ARVIE_CLUSTER_NAME}.${DOMAIN} \
       workbench.${ARVIE_CLUSTER_NAME}.${DOMAIN} \
       workbench2.${ARVIE_CLUSTER_NAME}.${DOMAIN} \
       ${ARVIE_CLUSTER_NAME}.${DOMAIN} \
       | sudo tee --append /etc/hosts

5. Add the CA certificate to your browser: this will prevent security errors when accessing Arvados services with your web browser.

   * Go to the certificate manager in your browser.
   In Chrome, this can be found under “Settings → Advanced → Manage Certificates” or by entering chrome://settings/certificates in the URL bar.
   In Firefox, this can be found under “Preferences → Privacy & Security” or entering about:preferences#privacy in the URL bar and then choosing “View Certificates…”.
   Select the “Authorities” tab, then press the “Import” button. Choose `arvie.arv.local-CA.crt`

   The certificate will be added under “__ARVIE__”.

6. Enter the URL `https://workbench.arvie.arv.local:8443`_ in your browser.

7. Log in to your cluster (initial user/pass: alice/alice)

8. If you want to run an arvados' shell run

.. code-block:: bash
   docker exec -ti shell /bin/bash

9. Stop Arvie with ``./arvie down``

Data will be persisted under the ``./local/arvie`` subdir so, if you start arvie again, your work will be
available again.

Subcommands examples
--------------------

Build
^^^^^

If you want to build a local copy of any (or all) of Arvados' components, you can do it with the ``build``
subcommand:

.. code-block:: bash

   $ ./arvie build keepstore ws

to build those two images locally from the current Arvados tree in your working environment.
If no image/s is/are given, all the images will be built again. Run:

.. code-block:: bash

   $ ./arvie build -h

to get some help.

So far, the scripts can build docker images for the following components

.. code-block:: bash

   REPOSITORY                      TAG                 IMAGE ID            CREATED             SIZE
   nmarvie/compute                 latest              0de2ea413d7f        13 hours ago        190MB
   nmarvie/shell                   latest              b3cddf00f1e7        15 hours ago        757MB
   nmarvie/keepstore               latest              0e903cbefdf8        23 hours ago        92.8MB
   nmarvie/keepproxy               latest              3f97aa2cd894        23 hours ago        84.3MB
   nmarvie/workbench               latest              b4871ce60674        23 hours ago        663MB
   nmarvie/api                     latest              accaca9f80a5        23 hours ago        635MB
   nmarvie/keep-web                latest              9f9396865106        7 days ago          86.3MB
   nmarvie/keep-balance            latest              0ce7ab96b18e        7 days ago          84.5MB
   nmarvie/health                  latest              a9ffa91bb6ff        7 days ago          84.2MB
   nmarvie/crunch-dispatch-local   latest              d0d1a7fdde5b        7 days ago          123MB
   nmarvie/git-httpd               latest              09656234d70b        7 days ago          84.1MB
   nmarvie/client                  latest              cd95446a2bfa        7 days ago          85.7MB
   nmarvie/server                  latest              808e8218a12c        7 days ago          111MB

Compose
^^^^^^^

As a convenience, there's a ``compose`` subcommand, which is used to pass commands to ``docker-compose``.

Whatever you pass a parameters to the command ``./arvie compose`` will be passed verbatim to ``docker-compose``
with the ``docker-compose/base.yml`` config file.

Running ``./arvie up`` is equivalent to ``./arvie compose up`` and will start the cluster:

.. code-block:: bash

   $ docker-compose ps
   Name                 Command               State                                                             Ports
   ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
   api          /scripts/ruby/app_start 8004     Up
   controller   ./executable controller          Up
   database     docker-entrypoint.sh postg ...   Up       0.0.0.0:5432->5432/tcp
   dispatcher   ./executable -poll-interval=1    Exit 1
   keep         ./executable                     Up
   keep0        ./executable                     Up
   keep1        ./executable                     Up
   keepweb      ./executable                     Up
   nginx        /docker-entrypoint.sh ngin ...   Up       0.0.0.0:25101->25101/tcp, 80/tcp, 0.0.0.0:8000->8000/tcp, 0.0.0.0:8002->8002/tcp, 0.0.0.0:8443->8443/tcp,
                                                          0.0.0.0:9002->9002/tcp
                                                          shell        irb                              Up
                                                          websocket    ./executable ws                  Up
                                                          workbench    /scripts/ruby/app_start 8002     Up

You can validate your ``docker-compose`` configuration with

.. code-block:: bash

   $ ./arvie compose config
   $ ./arvie compose --file docker-compose/build.yml config

in this last example, remember that ``docker-compose/base.yml`` is used by default with the ``compose``
subcommand, so both files will be merged, by ``docker-compose``'s rules.

TODO
----

* Get Arvie to a useful state (almost there)
* Testing (real testing)
* Improve configuration (too many hardcoded things atm)
* Add missing features/configs

and what's in the `TODO TODO`_ file :smile:

Contributing to this repo
-------------------------

**Commit message formatting is significant!!**

Please see :ref:`How to contribute <CONTRIBUTING>` for more details.

