DROP DATABASE IF EXISTS rent;
CREATE DATABASE IF NOT EXISTS rent;

USE rent;

/* Удаляем таблицы.
 * Делаем это вначале, потому что некоторые зависят друг от друга,
 * и в другом порядке не удалятся*/
DROP TABLE IF EXISTS car_brands;
DROP TABLE IF EXISTS car_models;
DROP TABLE IF EXISTS cars_booking;
DROP TABLE IF EXISTS cars;
DROP TABLE IF EXISTS house_booking;
DROP TABLE IF EXISTS houses;
DROP TABLE IF EXISTS house_type;
DROP TABLE IF EXISTS streets;
DROP TABLE IF EXISTS cities;
DROP TABLE IF EXISTS regions;
DROP TABLE IF EXISTS countries;
DROP TABLE IF EXISTS profiles;
DROP TABLE IF EXISTS users;

/* Таблица users*/
CREATE TABLE users(
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    firstname VARCHAR(255) NOT NULL,
    lastname VARCHAR(255) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT now(),
    updated_at datetime NOT NULL DEFAULT now() ON UPDATE now(),
    INDEX idx_name(lastname, firstname)
);

/* Профили пользователей*/
CREATE TABLE profiles(
    user_id BIGINT UNSIGNED NOT NULL UNIQUE,
    /*т.к. не всегда пользователь хочет оставлять информацию о себе,
    то позволим некоторым полям быть NULL*/
    birthday DATE,
    gender ENUM('male', 'female'),
    mobile_phone BIGINT,
    landline_phone BIGINT,
    email VARCHAR(150),
    created_at DATETIME NOT NULL DEFAULT now(),
    updated_at datetime NOT NULL DEFAULT now() ON UPDATE now(),
    /* нужна возможность связаться с человеком, поэтому
    хотя бы одно из полей для связи должно быть заполнено*/
    CHECK (mobile_phone IS NOT NULL 
        OR landline_phone IS NOT NULL
        OR email IS NOT NULL),
    CONSTRAINT `fk_user_id` FOREIGN KEY (user_id) 
        REFERENCES users(id) ON UPDATE CASCADE ON DELETE RESTRICT
);

/* Страны для адресов*/
CREATE TABLE countries(
    id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE
);

/* Регионы (области) для адресов*/
CREATE TABLE regions(
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    country_id SMALLINT UNSIGNED NOT NULL,
    UNIQUE INDEX idx_country_region(country_id, name),
    CONSTRAINT `fk_country_id` FOREIGN KEY (country_id)
        REFERENCES countries(id) ON UPDATE CASCADE ON DELETE RESTRICT
);

/* Города для адресов*/
CREATE TABLE cities(
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL, 
    region_id BIGINT UNSIGNED NOT NULL,
    UNIQUE INDEX idx_region_city (region_id, name),
    CONSTRAINT `fk_region_id` FOREIGN KEY (region_id)
        REFERENCES regions(id) ON UPDATE CASCADE ON DELETE RESTRICT
);

/* Улицы для адресов*/
CREATE TABLE streets(
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    city_id BIGINT UNSIGNED NOT NULL,
    UNIQUE INDEX idx_streets (city_id, name),
    CONSTRAINT `fk_city_id` FOREIGN KEY (city_id)
        REFERENCES cities(id) ON UPDATE CASCADE ON DELETE RESTRICT
);

/*Виды квартир*/
CREATE TABLE house_type(
    id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) UNIQUE 
);

/*Квартиры для аренды*/
CREATE TABLE houses(
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    type_id TINYINT UNSIGNED NOT NULL,
    owner_id BIGINT UNSIGNED NOT NULL COMMENT 'собственник жилья',
    country_id SMALLINT UNSIGNED,
    region_id BIGINT UNSIGNED NOT NULL,
    city_id BIGINT UNSIGNED NOT NULL,
    street_id BIGINT UNSIGNED NOT NULL,
    house_number INT UNSIGNED NOT NULL,
    apartment_number INT UNSIGNED, -- может быть NULL, например, для дома
    /*время аренды задаваемое пользователем,
     * если rent_end = null, то бессрочная,
     * если rent_begin = null, то снята с аренды*/
    rent_begin DATETIME COMMENT 'время начало аренды',
    rent_end DATETIME COMMENT 'время окончания аренды',
    created_at DATETIME NOT NULL DEFAULT now(),
    updated_at datetime NOT NULL DEFAULT now() ON UPDATE now(),
    /*наиболее часто пользователи будут искать определенные типы
    недвижимости в определенном регионе, поэтому создаем индекс 
    для этого*/
    INDEX idx_region (country_id, region_id, city_id, type_id),
    CONSTRAINT `fk_house_type` FOREIGN KEY (type_id)
        REFERENCES house_type(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT `fk_house_owner` FOREIGN KEY (owner_id)
        REFERENCES users(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT `fk_country` FOREIGN KEY (country_id)
        REFERENCES countries(id) ON UPDATE CASCADE ON DELETE RESTRICT, 
    CONSTRAINT `fk_region` FOREIGN KEY (region_id)
        REFERENCES regions(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT `fk_city` FOREIGN KEY (city_id)
        REFERENCES cities(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT `fk_street` FOREIGN KEY (street_id)
        REFERENCES streets(id) ON UPDATE CASCADE ON DELETE RESTRICT
);

/* Таблица бронирования жилья*/
CREATE TABLE house_booking(
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    rented_house_id BIGINT UNSIGNED NOT NULL,
    tenant_id BIGINT UNSIGNED NOT NULL,
    rent_begin DATETIME COMMENT 'время начало аренды',
    rent_end DATETIME COMMENT 'время окончания аренды',
    status ENUM('requested', 'approved', 'declined'),
    created_at DATETIME NOT NULL DEFAULT now(),
    updated_at datetime NOT NULL DEFAULT now() ON UPDATE now(),
    CONSTRAINT `fk_rented_house` FOREIGN KEY (rented_house_id)
        REFERENCES houses(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT `fk_house_tenant` FOREIGN KEY (tenant_id)
        REFERENCES users(id) ON UPDATE CASCADE ON DELETE RESTRICT
);

/*марки авто*/
CREATE TABLE car_brands(
    id INT UNSIGNED NOT NULL PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE 
);

/*модели авто*/
CREATE TABLE car_models(
    id BIGINT UNSIGNED NOT NULL PRIMARY KEY,
    brand_id INT UNSIGNED NOT NULL,
    name VARCHAR(255) NOT NULL,
    UNIQUE INDEX (brand_id, name),
    CONSTRAINT `fk_brand_id` FOREIGN KEY (brand_id)
        REFERENCES car_brands(id) ON UPDATE CASCADE ON DELETE RESTRICT
);

/*сдаваемые в аренду авто*/
CREATE TABLE cars(
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    user_own_id BIGINT UNSIGNED NOT NULL,
    -- марка и модель авто
    brand_id INT UNSIGNED NOT NULL,
    model_id BIGINT UNSIGNED NOT NULL,
    -- регион, в котором сдается авто
    country_id SMALLINT UNSIGNED,
    region_id BIGINT UNSIGNED NOT NULL,
    city_id BIGINT UNSIGNED NOT NULL,
    /*время аренды задаваемое пользователем,
     * если rent_end = null, то бессрочная,
     * если rent_begin = null, то снята с аренды*/
    rent_begin DATETIME COMMENT 'время начало аренды',
    rent_end DATETIME COMMENT 'время окончания аренды',
    created_at DATETIME NOT NULL DEFAULT now(),
    updated_at datetime NOT NULL DEFAULT now() ON UPDATE now(),
    CONSTRAINT `fk_user_own` FOREIGN KEY (user_own_id)
        REFERENCES users(id) ON UPDATE CASCADE ON DELETE RESTRICT,
   CONSTRAINT `fk_cars_country` FOREIGN KEY (country_id)
        REFERENCES countries(id) ON UPDATE CASCADE ON DELETE RESTRICT, 
    CONSTRAINT `fk_cars_region` FOREIGN KEY (region_id)
        REFERENCES regions(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT `fk_cars_city` FOREIGN KEY (city_id) 
        REFERENCES cities(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT `fk_brand` FOREIGN KEY (brand_id)
        REFERENCES car_brands(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT `fk_model` FOREIGN KEY (model_id)
        REFERENCES car_models(id) ON UPDATE CASCADE ON DELETE RESTRICT
);

/*таблица бронирования авто*/
CREATE TABLE cars_booking(
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    car_id BIGINT UNSIGNED NOT NULL,
    tenant_id BIGINT UNSIGNED NOT NULL,
    rent_begin DATETIME COMMENT 'время начало аренды',
    rent_end DATETIME COMMENT 'время окончания аренды',
    status ENUM('requested', 'approved', 'declined'),
    created_at DATETIME NOT NULL DEFAULT now(),
    updated_at datetime NOT NULL DEFAULT now() ON UPDATE now(),
    CONSTRAINT `fk_car_id` FOREIGN KEY (car_id)
        REFERENCES cars(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT `fk_car_tenant` FOREIGN KEY (tenant_id)
        REFERENCES users(id) ON UPDATE CASCADE ON DELETE RESTRICT
);


