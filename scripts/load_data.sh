#/bin/sh

echo "Создание таблиц для статистики ДТП..."
psql --host $APP_POSTGRES_HOST  -U postgres -a -f /srv/ddl.sql 

echo "Загружаем d_accident_type.csv..."
psql --host $APP_POSTGRES_HOST  -U postgres -c \
    "\\copy d_accident_type FROM '/data/d_accident_type.csv' DELIMITER ',' CSV HEADER"

echo "Загружаем d_car.csv..."
psql --host $APP_POSTGRES_HOST  -U postgres -c \
    "\\copy d_car FROM '/data/d_car.csv' DELIMITER ',' CSV HEADER"

echo "Загружаем f_accident.csv..."
psql --host $APP_POSTGRES_HOST  -U postgres -c \
    "\\copy f_accident FROM '/data/f_accident.csv' DELIMITER ',' CSV HEADER"
    
echo "Загружаем d_participant.csv..."
psql --host $APP_POSTGRES_HOST  -U postgres -c \
    "\\copy d_participant FROM '/data/d_participant.csv' DELIMITER ',' CSV HEADER"

