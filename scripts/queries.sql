-- 1. Выбрать TOP-5 марок машины, с которыми чаще всего происходит ДТП
SELECT d_car.brand, COUNT(d_car.id)
	FROM public.dtpmapapp_participant d_participant LEFT JOIN 
			public.dtpmapapp_car d_car
			ON d_participant.car_id = d_car.id
			WHERE d_participant.role = 'Водитель'
			GROUP BY d_car.brand
			ORDER BY 2 DESC
			LIMIT 5;
            
-- 2. Гендерное разделение. Посмотреть, сколько пострадавших среди мужчин и среди женщин и сколько погибших мужчин и женщин.

SELECT d_participant.gender, SUM(1) as count_injured, SUM(CASE when lower(status) like '%скончался%' then 1 else 0 end) as count_deceased
	FROM public.dtpmapapp_participant d_participant 
	WHERE d_participant.status != 'Не пострадал' AND gender IS NOT NULL
	GROUP BY d_participant.gender 
	ORDER BY 2 DESC;

-- 3. Выбрать TOP 5 марок машин, которые участвовали в ДТП со смертельным исходом
WITH t as (SELECT mvc_id, SUM(case when lower(status) like '%скончался%' then 1 else 0 end) as count_death FROM public.dtpmapapp_participant d_participant GROUP BY mvc_id)
SELECT d_car.brand, d_car.car_model, count(f_accident.id) FROM public.dtpmapapp_mvc f_accident
		    INNER JOIN t 
				ON t.mvc_id = f_accident.id
			INNER JOIN public.dtpmapapp_car d_car
				ON d_car.id = t.car_id
		WHERE  d_car.car_model IS NOT NULL
               AND count_death >0
		GROUP BY d_car.car_model, d_car.brand
		ORDER BY 3 DESC
		LIMIT 5;

-- 4. Аналитические функции. Для каждой машины, учавствовавшей в ДТП, в которой погиб человек, выбрать общее количество пострадавших, количество пассажиров в этой машине, количество пешеходов, количество велосипедистов и отсортировать по количеству участников ДТП

SELECT * FROM 
(SELECT DISTINCT 
         mvc_id
        ,car_id
        ,COUNT(1) 
            OVER (PARTITION BY mvc_id) as count_participant
        ,SUM(case when lower(status) like '%скончался%' then 1 else 0 end) 
            OVER (PARTITION BY mvc_id) as count_death
        ,SUM(case when d_participant.status != 'Не пострадал' then 1 else 0 end)
            OVER (PARTITION BY mvc_id) as count_suffer
        ,SUM(case when lower(d_participant.role) like '%пассажир%' then 1 else 0 end) 
            OVER (PARTITION BY mvc_id, car_id) as count_car_passengers
        ,SUM(case when lower(d_participant.role) like '%велосипед%' then 1 else 0 end) 
            OVER (PARTITION BY mvc_id) as count_bicyclist
        ,SUM(case when lower(d_participant.role) = 'пешеход' then 1 else 0 end) 
            OVER (PARTITION BY mvc_id) as count_pedestrian
        ,SUM(CASE WHEN d_participant.role = 'Водитель' then 1 else 0 end) 
            OVER (PARTITION BY mvc_id) as count_drivers
FROM public.dtpmapapp_participant d_participant
	WHERE car_id IS NOT NULL
) t
WHERE count_death>0
ORDER BY count_participant DESC, mvc_id;

-- Аналитические функции. Для каждого участника ДТП выбрать количество общее количество участников, количество машин, учавствовавших в ДТП и тип участника
SELECT d_participant.mvc_id,
		d_participant.role,
		d_participant.gender,
		d_participant.status,
		COUNT(1) OVER (PARTITION BY mvc_id) as count_participants,
		SUM(CASE WHEN d_participant.role = 'Водитель' then 0 else 1 end) 
			OVER (PARTITION BY mvc_id, car_id) as count_passengers,
		SUM(CASE WHEN d_participant.role = 'Водитель' then 1 else 0 end)
			OVER (PARTITION BY mvc_id) as count_cars
FROM public.dtpmapapp_participant d_participant;

-- Аналитические функции. Установить, с какой средней частотой происходят аварии на различных улицах москвы.
WITH t as (
SELECT split_part(address, ',', 2) as street,
	    COALESCE(LEAD(datetime) OVER 
				(PARTITION BY split_part(address, ',', 1), 
							   split_part(address, ',', 2)
				 ORDER BY datetime
				), datetime)
		- datetime as interval_between
FROM public.dtpmapapp_mvc f_accident
	WHERE address IS NOT NULL
		  AND lower(split_part(address, ',', 1)) like '%москва%'
	)
SELECT street, AVG(interval_between) as avg_interval FROM t
        WHERE interval_between > 0 * interval '1 day'
		GROUP BY street
		ORDER BY 2;

-- 5. Выбрать среднее количество участников ДТП и среднее количество смертей на 1 ДТП
SELECT AVG(sum_participant) as avg_participant, AVG(sum_death) as avg_death
FROM (SELECT  mvc_id
		,SUM(1) as sum_participant
		,SUM(CASE WHEN lower(status) like '%скончался%' THEN 1 ELSE 0 END) as sum_death
	FROM public.dtpmapapp_participant d_participant
			LEFT JOIN public.dtpmapapp_car d_car
				ON d_car.id = d_participant.car_id
		GROUP BY mvc_id) t;


-- 6. Выбрать ТОП-5 цветов машин, которые участвовали в ДТП
SELECT d_car.color, COUNT(1) cnt
	FROM dtpmapapp_participant d_participant
		 LEFT JOIN dtpmapapp_car d_car
		 	ON d_car.id = d_participant.car_id
	WHERE d_car.color IS NOT NULL
	GROUP BY color
	ORDER BY 2 DESC
	LIMIT 5;


-- 7. Выбрать максимальный, минимальный, средний стаж водителя
SELECT MIN(driving_experience), MAX(driving_experience), AVG(driving_experience)
		FROM public.dtpmapapp_participant d_participant
        WHERE d_participant.role = 'Водитель';


-- 8. Выбрать улицу (шоссе, проезд), на которой чаще всего происходит ДТП
SELECT split_part(address, ',', 2), COUNT(1) as count_accident 
FROM public.dtpmapapp_mvc f_accident
	WHERE lower(split_part(address, ',', 1)) like '%москва%'
	GROUP BY split_part(address, ',', 2)
	ORDER BY 2 DESC
	LIMIT 5;


-- 9. Выбрать все ДТП, в которых участвовали животные
SELECT f_accident.id, f_accident.datetime, f_accident.longitude, 
		f_accident.latitude, f_accident_type.name
FROM public.dtpmapapp_mvc f_accident
	LEFT JOIN public.dtpmapapp_mvctype f_accident_type
		ON f_accident.type_id = f_accident_type.id
WHERE name = 'Наезд на животное'


-- 10. Выбрать все ДТП в которых погиб пассажир 
WITH t as
(SELECT mvc_id, 
 		 SUM(case when lower(status) like '%скончался%' then 1 else 0 end) as count_death
 	FROM public.dtpmapapp_participant d_participant
	GROUP BY mvc_id
)
SELECT f_accident.id, datetime, longitude, latitude, count_death 
FROM public.dtpmapapp_mvc f_accident
	LEFT JOIN t 
		ON f_accident.id = t.mvc_id
		WHERE count_death > 0;
