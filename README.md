# A-Grader

## Simple setup (using Xcode and no docker/worker agents -- frontend only)

### Install vapor and dependencies

If you are on macOS then make sure you have Homebrew installed first. Then:

```bash
brew tap vapor/homebrew-tap
brew update
brew install vapor
brew install sqlite3
```

### Clone

Do a git clone of this repo.


### Setup Xcode project

To create the files need

```bash
vapor xcode
```

Open the xcodeproj file in Xcode, check that "Run -> My Mac" is selected as the target and then hit "Play".

Check it is running in your browser at `http:://localhost:8080`.


### Setup database

The database will be created automatically when you run the project.

If you want to run the project in Xcode, then you can use an sqlite database that is included. To do this, change fluent.json to use the sqlite driver.

To seed the tables:
```
vapor run seed
```


### Adding dependencies

If you change Package.swift then use `vapor update` to download dependencies.


## Serious setup

You will need Docker (at least version 17).

This setup uses docker-compose to create 4 containers:
* `database` - a standard mariadb image
* `redis` - a standard redis image
* `web` - our vapor image that serves the website
* `worker` - our vapor image that runs multiple job threads

### Orchestrate your containers

* Clone the repo
* Open your terminal at the repo root, and `cd docker`
* Build the base docker image `docker build -t apptitude/vapor vapor`
* Build the application `./build`
* Change `Config/fluent.json` to use `"driver": "mysql"`
* Start redis & database `docker-compose up -d redis mysql`
* Check they're up `docker-compose ps`
* Check the logs if you have problems `docker-compose logs -ft <container_id>`
* After database is up, start web `docker-compose up -d web`
* After web is up, start worker `docker-compose up -d worker`
* Open your browser at `http://localhost` or your docker VM IP address
* By default you will be using mysql and the db will be empty, so next you should seed the db `docker-compose run worker run seed`

### Workflow

* Every change to the Swift source code requires compilation and restart the web/worker containers. The script `./build` will stop, compile and start.
* Changes to the resources (html, css, js, images -- and Leaf!) do not require recompilation (just refresh the browser).
* To inspect the database, it is easiest to login directly to the database container `docker-compose exec database mysql -u root -p grader`
* To test the running of submission jobs (or manually run a job), login to the worker container `docker-compose exec worker bash` and then use the vapor command `vapor run submission X` where `X` is your submission id.

### Other commands

Compile our custom Vapor image (required before we start using `docker run apptitude/vapor`):
```
docker build -t apptitude/vapor vapor
```

Login to a Vapor-enabled container (bash prompt, useful for exploring):
```
docker run -it --volume=$PWD/..:/app --entrypoint /bin/bash  apptitude/vapor
```

Run Vapor commands (e.g. `vapor build`):
```
docker run -it --volume=$PWD/..:/app apptitude/vapor build
```

In general, you can run any Vapor command (e.g. `vapor XXX`):
```
docker run -it --volume=$PWD/..:/app apptitude/vapor XXX
```

Run a one-off worker:
```
docker run -it --volume=$PWD/..:/app apptitude/vapor run worker
```


## Deployment

This was tested on AWS, to a Ubuntu Xenial 16.04 (20170414) (ami-8fcc75ec) instance. The security group should have http and ssh open.

1. `ssh` into your newly created instance. (Note: the user to login with for Ubuntu images is `ubuntu`.)

2. Install docker
```
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -y --allow-unauthenticated docker-ce
sudo systemctl status docker
sudo usermod -aG docker ${USER}
```
and check it is working `docker`

3. Install docker-compose
```
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo curl -o /usr/local/bin/docker-compose -L "https://github.com/docker/compose/releases/download/1.15.0/docker-compose-$(uname -s)-$(uname -m)"
sudo chmod +x /usr/local/bin/docker-compose
```
and check it is working `docker-compose -v`

4. Create the /app directory
```
sudo mkdir /app
sudo chown ubuntu:ubuntu /app
```

5. Sync the files (e.g. copy from your local machine to the instance). See ./deploy for an example.

6. `ssh` back into the instance, and build/start the docker services
```
cd /app/docker
docker build -t apptitude/vapor vapor
docker run -it --volume=$PWD/..:/app apptitude/vapor build
docker-compose up -d
```

7. Check everything looks ok on the logs.
```
docker-compose logs -ft
```

### Updates to the server

1. Make a backup first
```
ssh grader
cd /app
docker-compose exec database bash
mysqldump -u root -p grader > dump.sql
```

2. Copy backup down to localhost
```
docker cp <container_id>:/dump.sql /app/dump.sql
[Ctrl-D]
scp grader:/app/dump.sql ./
```

3. Make database changes (from aws)
```
ssh grader
cd /app
docker-compose exec database mysql -u root -p grader
```
(and do you stuff!)

4. Resync files (logout to localhost first)
```
./deploy
```

5. Rebuild the worker container (if required)
```
ssh grader
cd /app
docker-compose up -d --no-deps --build worker
```
