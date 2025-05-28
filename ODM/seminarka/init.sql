CREATE TABLE product_dim (
    product_id BIGINT PRIMARY KEY,
    category_id BIGINT,
    category_code TEXT,
    brand TEXT
);

CREATE TABLE date_dim (
    date_id SERIAL PRIMARY KEY,
    full_date TIMESTAMP,
    day INT,
    month INT,
    year INT,
    hour INT
);

CREATE TABLE events_fact (
    id SERIAL PRIMARY KEY,
    event_time TIMESTAMP,
    event_type TEXT,
    product_id BIGINT,
    user_id BIGINT,
    user_session TEXT,
    price NUMERIC,
    FOREIGN KEY (product_id) REFERENCES product_dim(product_id)
);


COPY product_dim FROM 'D:\Programko\UJEP\ODM\seminarka\product_dim.csv' DELIMITER ',' CSV HEADER;

COPY events_fact(event_time, event_type, product_id, user_id, user_session, price)
FROM 'D:\Programko\UJEP\ODM\seminarka\events_fact.csv'
DELIMITER ',' CSV HEADER;

COPY date_dim(full_date, day, month, year, hour, date_id)
FROM 'D:\Programko\UJEP\ODM\seminarka\date_dim.csv'
DELIMITER ',' CSV HEADER;


