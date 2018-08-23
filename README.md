# road-accidents
Проект предназначен для анализа ДТП на дорогах России.
Все данные загружены с ресурса http://stat.gibdd.ru/ .

## Описание репозитория:
1. data - входные и выходные данные для анализа ДТП
2. docker	- описание контейнеров, используемых для работы с данными
3. docs	- описание предметрой области и прочие документы
4. notebooks	 - тетрадки Jupyter Notebook
5. scripts - скрипты для загрузки данных, определения структуры и т.д.

## Загрузка данных:

1) Из папки {REPO}/docker запустить postgres-client c  помощью команды:

$ sudo docker-compose --project-name sql-proj -f docker-compose.yml run --rm postgres-client

2) Запустить файл load_data.sh с помощью следующей команды:

$ /srv/load_data.sh


## Работа с SQL:
1) Из папки {REPO}/docker запустить postgres-client c  помощью команды:

$ sudo docker-compose --project-name sql-proj -f docker-compose.yml run --rm postgres-client

2) Стартовать клиент Postgres в контейнере postgres-client с помощью команды:

$ psql --host $APP_POSTGRES_HOST -U postgres


## Работа с Jupyter Notebook:
1) Из папки {REPO}/docker запустить notebook c помощью команды:

$ sudo docker-compose --project-name sql-proj -f docker-compose.yml run --rm notebook

2) В сроке адреса в бразере перейти по следующей ссылке: http://localhost:8888/
3) В папке work находятся все тетрадки из репозитория


