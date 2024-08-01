## Laravel Docker Example

Here's an example that will build a Docker container that runs Apache and PHP, 
together with all the PHP modules that are contained on your server.

To get this running, follow the following steps;

 - Download and install [Docker Desktop](https://docs.docker.com/desktop/install/windows-install/)
 - Clone this repository onto your machine
 - Bring up a command line and change into the repository directory
 - Run `docker-compose build`, this will build your image, it might take a few minutes
 - Run `docker-compose run web composer install`, this will install composer dependencies
 - Run `docker-compose up` this will start the container
 - Browse to [http://localhost:9999](http://localhost:9999)

You should be able to see a complete Laravel installation at that point, running in a little
Linux container with PHP 8.2 and Apache