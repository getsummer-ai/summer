## Summer APP

### Installation

To run app you need to have docker installed on your machine.

#### 1 - After docker is installed, go to the docker folder

```sh
cd ./docker
```

#### 2 - Prepare the app

```sh
docker compose run --rm rails bundle install && docker compose run --rm rails db:setup && docker compose run --rm yarn install
```

#### 3 - Run the app via docker compose

```sh
docker compose up
```

#### 4 - Open browser and enjoy the app

`http://localhost:3000/`

#### 5 - Turn off the app

```sh
docker compose down
```

#### 6 - To run rails console within the app

```sh
docker compose run --rm rails bundle exec rails c
```
