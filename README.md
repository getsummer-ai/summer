## Summer APP

### Installation

To run app you need to have docker installed on your machine.

#### 1 - After docker is installed, go to the docker folder

```sh
cd ./docker
```

#### 2 - Prepare the app

```sh
docker compose run rails bundle install && bundle exec rails db:setup && yarn install
```

#### 3 - Run the app via docker compose

```sh
docker compose up
```

#### 4 - Open browser and enjoy the app

`http://localhost:3000/`
