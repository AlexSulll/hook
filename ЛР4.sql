CREATE TABLE trigger_log
(
    log_id NUMBER PRIMARY KEY,
    user_name VARCHAR2(50),
    date_oper DATE,
    INN VARCHAR2(256),
    type_change VARCHAR2(20)
);

CREATE TABLE uch_vse_test AS SELECT * FROM sh.uch_vse WHERE rownum<1;

CREATE SEQUENCE trigger_log_seq
START WITH 1
INCREMENT BY 1
NOCACHE;

CREATE OR REPLACE TRIGGER check_inn_trg_update
BEFORE UPDATE ON uch_vse_test FOR EACH ROW
DECLARE
    PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    IF LENGTHB(:new.inn) <> 10 AND LENGTHB(:new.inn) <> 12 THEN
        RAISE_APPLICATION_ERROR(-20202,'Неверная структура ИНН. Слишком велико (фактическое: ' || TO_CHAR(LENGTHB(:new.inn)) ||', должно быть 10 или 12)');
    END IF;
    INSERT INTO trigger_log VALUES(trigger_log_seq.nextval,USER,SYSDATE,:new.inn,'UPDATE');
    COMMIT;
END check_inn_trg;

CREATE OR REPLACE TRIGGER check_inn_trg_insert
BEFORE INSERT ON uch_vse_test FOR EACH ROW
DECLARE
    PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    IF LENGTHB(:new.inn) <> 10 AND LENGTHB(:new.inn) <> 12 THEN
        RAISE_APPLICATION_ERROR(-20202,'Неверная структура ИНН. Слишком велико (фактическое: ' || TO_CHAR(LENGTHB(:new.inn)) ||', должно быть 10 или 12)');
    END IF;
    INSERT INTO trigger_log VALUES(trigger_log_seq.nextval,USER,SYSDATE,:new.inn,'INSERT');
    COMMIT;
END check_inn_trg;

--11 цифр
INSERT INTO uch_vse_test (INN) VALUES 
('12345678910');

--10 цифр
INSERT INTO uch_vse_test (INN) VALUES 
('1234567899');

--12 цифр
INSERT INTO uch_vse_test (INN) VALUES 
('123456789101');

--255 байтов
INSERT INTO uch_vse_test (INN) VALUES 
('121231321350680123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789Ы01A2345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234560');

UPDATE uch_vse_test SET INN='1234567812' WHERE INN='1234567899';

select * FROM uch_vse_test;
SELECT * FROM trigger_log;

DROP TABLE trigger_log;
DROP TABLE uch_vse_test;
DROP TRIGGER check_inn_trg;
DROP SEQUENCE trigger_log_seq;
