
delimiter //
-- функция исправляет неверные даты в нужной таблице
DROP PROCEDURE IF EXISTS fix_updated_at//
CREATE PROCEDURE fix_updated_at(IN table_name VARCHAR(255))
BEGIN 
    SET @sql_string = CONCAT('UPDATE ', table_name,
        ' SET created_at = updated_at WHERE created_at > updated_at');
    PREPARE query FROM @sql_string;
    EXECUTE query;
    DROP PREPARE query;
END//

delimiter ;

-- исправим даты во всех таблицах
CALL fix_updated_at('users');
CALL fix_updated_at('house_booking');
CALL fix_updated_at('houses');
CALL fix_updated_at('profiles');
CALL fix_updated_at('cars');
CALL fix_updated_at('cars_booking');