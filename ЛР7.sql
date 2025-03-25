SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

EXPLAIN PLAN FOR--4732 Cost HASH UNIQUE
    SELECT t.passenger_name, t.passenger_id
        FROM tickets t
        JOIN ticket_flights tf ON t.ticket_no = tf.ticket_no
        JOIN flights f ON tf.flight_id = f.flight_id;

EXPLAIN PLAN FOR--9706 Cost
    SELECT DISTINCT t.passenger_name, t.passenger_id
        FROM tickets t
        JOIN ticket_flights tf ON t.ticket_no = tf.ticket_no
        JOIN flights f ON tf.flight_id = f.flight_id;
        
        
EXPLAIN PLAN FOR--2513 Cost
    SELECT DISTINCT t.passenger_name, t.passenger_id
        FROM tickets t
        JOIN ticket_flights tf ON t.ticket_no = tf.ticket_no
        JOIN flights f ON tf.flight_id = f.flight_id
        --WHERE f.flight_no IN ('PG0405', 'PG0045');

EXPLAIN PLAN FOR--2512 Cost HASH UNIQUE
    SELECT t.passenger_name, t.passenger_id
        FROM tickets t
        JOIN ticket_flights tf ON t.ticket_no = tf.ticket_no
        JOIN flights f ON tf.flight_id = f.flight_id
        --WHERE f.flight_no IN ('PG0405', 'PG0045');

EXPLAIN PLAN FOR --2513 Cost
SELECT DISTINCT t.passenger_name, t.passenger_id
FROM tickets t
WHERE t.ticket_no IN (
    SELECT tf.ticket_no
    FROM ticket_flights tf
    JOIN flights f ON tf.flight_id = f.flight_id
    WHERE f.flight_no IN ('PG0405', 'PG0045')
);

EXPLAIN PLAN FOR --2513 
SELECT DISTINCT t.passenger_name, t.passenger_id
FROM tickets t
WHERE t.ticket_no IN (
    SELECT tf.ticket_no
    FROM ticket_flights tf
    WHERE tf.flight_id IN (
        SELECT flight_id
        FROM flights
        WHERE flight_no IN ('PG0405', 'PG0045')
    )
);

EXPLAIN PLAN FOR --2513 
SELECT DISTINCT *
FROM tickets t
WHERE t.ticket_no IN (
    SELECT tf.ticket_no
    FROM ticket_flights tf
    WHERE tf.flight_id IN (
        SELECT flight_id
        FROM flights
        WHERE flight_no IN ('PG0405', 'PG0045')
    )
);

EXPLAIN PLAN FOR-- 47G Cost
    SELECT DISTINCT t.passenger_name, t.passenger_id
        FROM tickets t,ticket_flights,flights f
        WHERE f.flight_no IN ('PG0405', 'PG0045');

--Создадим индексы на столбцы, которые учавствую в запросе (нет привилегий((((
CREATE INDEX idx_flights_flight_no ON flights(flight_no);
CREATE INDEX idx_ticket_flights_flight_id ON ticket_flights(flight_id);
CREATE INDEX idx_tickets_ticket_no ON tickets(ticket_no);

CREATE MATERIALIZED VIEW ticket_mv
    AS SELECT DISTINCT t.passenger_name, t.passenger_id
         FROM tickets t
         JOIN ticket_flights tf ON t.ticket_no = tf.ticket_no
         JOIN flights f ON tf.flight_id = f.flight_id
         WHERE f.flight_no in  ('PG0405', 'PG0045');

DROP MATERIALIZED VIEW ticket_mv;

SELECT * FROM ticket_mv;

CREATE MATERIALIZED VIEW mv_passenger
    BUILD IMMEDIATE
    REFRESH COMPLETE
    ON DEMAND
    START WITH SYSDATE
    NEXT SYSDATE + 7
AS
    SELECT DISTINCT t.passenger_name, t.passenger_id
        FROM tickets t
        JOIN ticket_flights tf ON t.ticket_no = tf.ticket_no
        JOIN flights f ON tf.flight_id = f.flight_id
        WHERE f.flight_no IN ('PG0405', 'PG0045');

BEGIN
    DBMS_MVIEW.REFRESH('mv_passenger');
END;

SELECT * FROM mv_passenger;

EXPLAIN PLAN FOR
SELECT * FROM mv_passenger;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

DROP MATERIALIZED VIEW ticket_mv;
DROP MATERIALIZED VIEW mv_passenger;


--Уменьшение стоимость за счет использования индексов
CREATE INDEX idx_flights_flight_no ON flights(flight_no);
CREATE INDEX idx_ticket_flights_flight_id ON ticket_flights(flight_id);
CREATE INDEX idx_tickets_ticket_no ON tickets(ticket_no);

DROP INDEX idx_flights_flight_no;
DROP INDEX idx_ticket_flights_flight_id;

EXPLAIN PLAN FOR
SELECT DISTINCT t.passenger_name, t.passenger_id
FROM tickets t
WHERE t.ticket_no IN (
    SELECT tf.ticket_no
    FROM ticket_flights tf
    JOIN flights f ON tf.flight_id = f.flight_id
    WHERE f.flight_no IN ('PG0405', 'PG0045')
);

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);
