BEGIN
DBMS_SCHEDULER.CREATE_JOB (
    job_name => 'MY_JOB',
    job_type => 'PLSQL_BLOCK',
    job_action => 'BEGIN payment_rent_pr(TO_DATE(''01.01.2001''),TO_DATE(''01.01.2010'')); END;',
    job_class => 'DBMS_JOB$',
    start_date => TRUNC(sysdate),
    repeat_interval => 'FREQ=WEEKLY; INTERVAL=2; BYDAY=MON,THU,SUN; BYHOUR=8; BYMINUTE=0',
    enabled => TRUE);
END;

DECLARE
    l_next_run_date TIMESTAMP;
BEGIN
DBMS_SCHEDULER.EVALUATE_CALENDAR_STRING (
    'FREQ=WEEKLY; INTERVAL=2; BYDAY=MON,THU,SUN; BYHOUR=8; BYMINUTE=0',
    to_date('15.07.2025'),
    NULL,
    l_next_run_date
);
    DBMS_OUTPUT.PUT_LINE('Следующая дата выполнения: ' || TO_CHAR(l_next_run_date));
END;

SET SERVEROUTPUT ON;

SELECT job_name, enabled, state, next_run_date, last_start_date 
FROM USER_SCHEDULER_JOBS 
WHERE job_name = 'MY_JOB';


BEGIN
  DBMS_SCHEDULER.DISABLE('MY_JOB');
END;

BEGIN
  DBMS_SCHEDULER.DROP_JOB('MY_JOB');
END;

--Принудительный запуск

BEGIN
  DBMS_SCHEDULER.RUN_JOB(
    job_name => 'MY_JOB',
    use_current_session => TRUE
  );
END;

CREATE TABLE Payment_rent AS SELECT * FROM sh.test_operation WHERE rownum<1;
CREATE TABLE loggin_proc
(
    ID NUMBER PRIMARY KEY,
    DATE_PROC_START DATE NOT NULL,
    DATE_FROM DATE NOT NULL,
    DATE_TO DATE NOT NULL,
    COUNT_INSERT NUMBER NOT NULL,
    DATE_PROC_END DATE NOT NULL,
    FLAG NUMBER NOT NULL
);

CREATE SEQUENCE loggin_proc_seq
START WITH 1
INCREMENT BY 1
NOMAXVALUE;

CREATE OR REPLACE PROCEDURE payment_rent_pr(DateFrom IN DATE, DateTo IN DATE)
IS 
    c_insert NUMBER := 0;
    v_start_proc DATE;
BEGIN
    SELECT SYSDATE INTO v_start_proc FROM DUAL;
    DELETE Payment_rent;
    COMMIT;
    FOR oper_rec IN (SELECT top.KOD, top.DOG, top.DATA_DOG, top.SUMMA_DOG, top.BIC_PL, top.KORCH_PL, top.RASCH_PL, top.INN_PL, top.BIC_POL, top.KORSCH_POL, top.RASCH_POL, top.INN_POL, top.DESCR, top.DATA_OP, top.SUMMA_OP, top.RULE, top.PRIZ 
                        FROM sh.test_operation top 
                        JOIN sh.test_uchast tuc ON top.INN_POL = tuc.INN 
                        WHERE DATA_OP>=DateFrom AND DATA_OP<=DateTo AND REGEXP_LIKE(UPPER(DESCR), 'АРЕНД') AND REGEXP_LIKE(UPPER(NAIMEN), 'БАНК')
                    ) LOOP
        c_insert := c_insert+1;
        INSERT INTO Payment_rent VALUES (oper_rec.KOD, oper_rec.DOG, oper_rec.DATA_DOG, oper_rec.SUMMA_DOG, oper_rec.BIC_PL, oper_rec.KORCH_PL, oper_rec.RASCH_PL, oper_rec.INN_PL, oper_rec.BIC_POL, oper_rec.KORSCH_POL, oper_rec.RASCH_POL, oper_rec.INN_POL, oper_rec.DESCR, oper_rec.DATA_OP, oper_rec.SUMMA_OP, oper_rec.RULE, oper_rec.PRIZ);
        COMMIT;
    END LOOP;
    INSERT INTO loggin_proc(ID,DATE_PROC_START,DATE_FROM,DATE_TO,COUNT_INSERT,DATE_PROC_END,FLAG)
    VALUES (loggin_proc_seq.nextval,v_start_proc,DateFrom,DateTo,c_insert,SYSDATE,1);
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        BEGIN
            INSERT INTO loggin_proc(ID,DATE_PROC_START,DATE_FROM,DATE_TO,COUNT_INSERT,DATE_PROC_END,FLAG)
            VALUES (loggin_proc_seq.nextval,v_start_proc,DateFrom,DateTo,c_insert,SYSDATE,0);
            COMMIT;
        END;
END;

BEGIN
 payment_rent_pr(TO_DATE('01.01.2001'),TO_DATE('01.01.2001'));
END;

SELECT * FROM loggin_proc;
SELECT * FROM Payment_rent;


select * from sh.test_uchast where REGEXP_LIKE(UPPER(NAIMEN), 'БАНК$');
SELECT * FROM sh.test_operation top
JOIN sh.test_uchast tuc ON top.INN_POL = tuc.INN
WHERE REGEXP_LIKE(UPPER(top.DESCR), 'АРЕНД') AND REGEXP_LIKE(UPPER(tuc.NAIMEN), 'БАНК');
SELECT CURRENT_DATE FROM DUAL;

SELECT * FROM sh.test_operation top JOIN sh.test_uchast tuc ON top.INN_POL = tuc.INN WHERE DATA_OP>=TO_DATE('01.01.1900') AND DATA_OP<=TO_DATE('01.01.2010') AND REGEXP_LIKE(UPPER(DESCR), 'АРЕНД') AND REGEXP_LIKE(UPPER(NAIMEN), 'БАНК');

DROP TABLE Payment_rent;
DROP PROCEDURE payment_rent_pr;
DROP TABLE loggin_proc;
