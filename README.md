# A-Grader

## Setup

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


### Adding dependencies

If you change Package.swift then use `vapor update` to download dependencies.


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
docker run -it --volume=$PWD/..:/app apptitude/vapor build
```

Seed the database:
```
docker run -it --volume=$PWD/..:/app apptitude/vapor run seed
```

Run a one-off worker:
```
docker run -it --volume=$PWD/..:/app apptitude/vapor run worker
```

Login to the mariadb/mysql database:
```
docker-compose exec database mysql -u root -p grader
```


## Deployment

This was tested on AWS, to a Ubuntu Xenial 16.04 (20170414) (ami-8fcc75ec) instance. The security group should have http and ssh open.

1. `ssh` into your newly created instance. (Note: the user to login with for Ubuntu images is `ubuntu`.)

2. Install docker
```
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -y docker-ce
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
