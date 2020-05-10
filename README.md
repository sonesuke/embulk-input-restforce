# Salesforce input plugin for Embulk

TODO: Write short description here and embulk-input-restforce.gemspec file.

## Overview

* **Plugin type**: input
* **Resume supported**: no
* **Cleanup supported**: no
* **Guess supported**: no

## Configuration

- **user_name**: Salesforce's uesr name (string, required)
- **password**: Salesforce's password (string, required)
- **security_token**: Salesforce's security token (string, required)
- **client_id**: Salesforce's client id (string, required)
- **client_secret**: Salesforce's c;oem tsecret (string, required)
- **sobject**: SObject what you want to fetch.(string, required)
- **skip_columns**: Columns what you want to skip. Please see the following section for the detail. (Array)
- **columns**: Columns what you want to select. If nothing, the default is all columns.(Array)  

## CLIENT ID / CLIENT SECRET

If you don't know how to get it, pleaes refer this link. It's in Japanese.

https://qiita.com/beta_chelsea/items/9fd37947872747c8667f

## Skip column

Skip column is working without **columns** field. If it is not blank, it will not work.
Skip column supports Ruby regex syntax.

```yaml
in:
  skip_columns:
    - {pattern: .*Name}
    - {pattern: Email}
```

## Example

```yaml
in:
  type: restforce
  user_name: <your user name>
  password: <your password>
  security_token: <your key>
  client_id: <your client id>
  client_secret: <your client secret>
  sobject: Contact
  skip_columns:
    - {pattern: .*Name}
    - {pattern: Email}
```

```yaml
in:
  type: restforce
  user_name: <your user name>
  password: <your password>
  security_token: <your key>
  client_id: <your client id>
  client_secret: <your client secret>
  object: Contact
  columns:  
    - {name: Email, type: string}
```

## Build

```
$ docker-compose run dev bash

$ bundle install
$ bundle exec rake
```

## Debug

```
$ docker-compose run dev bash

$ embulk bundle install
$ sh debug-run.sh
```

## install from local 

```
$ docker-compose run dev bash

$ embulk gem install restforce -v "2.5.2"
$ embulk gem install --local pkg/embulk-input-restforce-0.1.0.gem
```