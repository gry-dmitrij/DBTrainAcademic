-- Найдем доступные 2-х комнатные квартиры
-- в определенном городе, выведем доступный 
-- способ связи

SELECT 
    ht.name AS 'type',
    u.firstname AS 'firstname',
    u.lastname AS 'lastname',
    p.mobile_phone AS 'phone1',
    p.landline_phone AS 'phone2',
    p.email AS 'email',
    c.name AS 'city',
    r.name AS 'region',
    cr.name AS 'country'
FROM 
    houses h
    JOIN (house_type ht, users u, profiles p, 
        cities c, regions r, countries cr)
    ON (h.type_id = ht.id 
        AND u.id = h.owner_id 
        AND u.id = p.user_id
        AND c.id = h.city_id
        AND r.id = h.region_id
        AND cr.id = h.country_id)
WHERE 
    ht.name = '2-к. квартира' 
    AND cr.name = 'Россия'
    AND r.name ='autem'
    AND c.name = 'ab';


-- подсчитаем кол-во различных квартир в разных странах
SELECT cr.name AS 'страна', 
       ht.name AS 'тип', 
       count(*) AS 'количество'
FROM houses h
    JOIN (house_type ht,
          countries cr)
    ON (h.type_id = ht.id
        AND h.country_id = cr.id)
GROUP BY cr.name, ht.name;

