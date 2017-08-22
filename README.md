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

Using the `sqlite3` command, create a database in the location the example
app will look for:

```bash
sqlite3 Database/main.sqlite
```

That will put you in a sql prompt. Copy and paste the following SQL query to set up the tables.

```sql
CREATE TABLE users(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, password TEXT NOT NULL);
```

Then use Ctrl-d to exit.


### Adding dependencies

If you change Package.swift then use `vapor update` to download dependencies.


### Other commands

Compile our custom Vapor image (required before we start using `docker run apptitude/vapor`):

```
docker build vapor
```

Login to a Vapor-enabled container:
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


## Deployment

This was tested on AWS, to a Ubuntu Xenial 16.04 (20170414) (ami-8fcc75ec) instance. The security group should have http and ssh open.

1. `ssh` into your newly created instance. (Note: the user to login with for Ubuntu images is `ubuntu`.)

2. Install docker
```

```

3. Install docker-compose
```

```

4. Create the /app directory
```
sudo mkdir /app
sudo chown ubuntu:ubuntu /app
```

5. Sync the files (e.g. copy from your local machine to the instance). See ./deploy for an example.

6. `ssh` back into the instance, and start the docker services
```
cd /app/docker
docker-compose up -d
```

7. Check everything looks ok on the logs.
```
docker-compose logs -ft
```
