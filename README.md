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

# grader
