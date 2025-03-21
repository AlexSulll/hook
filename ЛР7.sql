EXPLAIN PLAN FOR
SELECT t.passenger_name, t.passenger_id, f.flight_no
       FROM tickets t
       JOIN ticket_flights tf ON t.ticket_no = tf.ticket_no
       JOIN flights f ON tf.flight_id = f.flight_id
       WHERE f.flight_no IN ('PG0405', 'PG0045')
       GROUP BY t.passenger_name, t.passenger_id, f.flight_no;


SELECT * FROM TABLE(dbms_xplan.display);

CREATE MATERIALIZED VIEW ticket_mv
    AS SELECT DISTINCT t.passenger_name, t.passenger_id
    FROM tickets t
    JOIN ticket_flights tf ON t.ticket_no = tf.ticket_no
    JOIN flights f ON tf.flight_id = f.flight_id
    WHERE f.flight_no IN ('PG0405', 'PG0045');
       
CREATE MATERIALIZED VIEW ticket_mv
    AS SELECT t.passenger_name, t.passenger_id, f.flight_no
       FROM tickets t
       JOIN ticket_flights tf ON t.ticket_no = tf.ticket_no
       JOIN flights f ON tf.flight_id = f.flight_id
       WHERE f.flight_no IN ('PG0405', 'PG0045')
       GROUP BY t.passenger_name, t.passenger_id, f.flight_no;
        
BEGIN
    DBMS_MVIEW.REFRESH('ticket_mv','C');
END;

EXPLAIN PLAN FOR --11215 cost
    SELECT DISTINCT t.passenger_name, t.passenger_id
    FROM tickets t
    JOIN ticket_flights tf ON t.ticket_no = tf.ticket_no
    JOIN flights f ON tf.flight_id = f.flight_id
    WHERE f.flight_no IN ('PG0405', 'PG0045');
    
