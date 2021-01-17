/* Представления для квартир выставленных на 
 * аренду сегодня квартир*/
CREATE OR REPLACE VIEW 
    new_houses(`type`, 
                `begin`,
                own_name,
                phone1,
                phone2,
                email,
                country, 
                region, 
                city,
                street,
                `number`
                )
AS SELECT 
    ht.name,
    h.rent_begin,
    u.firstname,
    p.mobile_phone,
    p.landline_phone,
    p.email,
    cr.name,
    r.name,
    c.name,
    s.name,
    h.house_number
FROM houses h
    JOIN (house_type ht, 
          users u, 
          profiles p,
          countries cr,
          regions r,
          cities c,
          streets s)
    ON (h.type_id = ht.id 
        AND h.owner_id = u.id
        AND h.owner_id = p.user_id
        AND h.country_id = cr.id
        AND h.region_id = r.id
        AND h.city_id = c.id
        AND h.street_id = s.id)
WHERE DATE(h.rent_begin) = CURDATE(); 

-- сделаем несколько домов с текущей датой для проверки
UPDATE houses 
SET rent_begin = now(),
    rent_end  = NULL 
WHERE id = 96 OR id = 98 OR id = 100;





