--Выбрать TOP-5 марок машины, с которыми чаще всего происходит ДТП
CREATE OR REPLACE VIEW top5_dtp_cars AS
SELECT d_car.brand, COUNT(d_car.id)
	FROM public.d_participant LEFT JOIN 
			public.d_car
			ON d_participant.car_id = d_car.id
			WHERE d_participant.role = 'Водитель'
			GROUP BY d_car.brand
			ORDER BY 2 DESC
			LIMIT 5;
            
-- 2. Гендерное разделение. Посмотреть, сколько пострадавших среди мужчин и среди женщин и сколько погибших мужчин и женщин.
CREATE OR REPLACE VIEW dtp_participant_ch AS
SELECT d_participant.mvc_id,
		d_participant.role,
		d_participant.gender,
		d_participant.status,
		COUNT(1) OVER (PARTITION BY mvc_id) as count_participants,
		SUM(CASE WHEN d_participant.role = 'Водитель' then 0 else 1 end) 
			OVER (PARTITION BY mvc_id, car_id) as count_passengers,
		SUM(CASE WHEN d_participant.role = 'Водитель' then 1 else 0 end)
			OVER (PARTITION BY mvc_id) as count_cars
FROM public.d_participant;