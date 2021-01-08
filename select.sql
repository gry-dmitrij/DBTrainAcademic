-- Найдем доступные 2-х комнатные квартиры
-- в определенном городе, выведем доступный 
-- способ связи

SELECT
    u.lastname AS 'lastname',
    u.firstname AS 'firstname',
    p.mobile_phone AS 'mobile phone',
    p.landline_phone AS 'phone',
    p.email AS 'email'
FROM 
    houses h
    LEFT JOIN (users u, profiles p, house_type ht)
    ON (p.user_id = u.id 
        AND h.owner_id = u.id
        AND h.id = ht.id)
WHERE ht.name = '1-к. квартира';
    
SELECT 
    ht.name,
    u.firstname,
    u.lastname,
    h.id,
    h.type_id,
    p.mobile_phone,
    p.landline_phone,
    p.email
FROM 
    houses h
    JOIN house_type ht 
    JOIN (users u, profiles p)
    ON (h.type_id = ht.id 
        AND u.id = h.owner_id 
        AND u.id = p.user_id)
WHERE ht.name = '1-к. квартира';

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

