BEGIN
DBMS_SCHEDULER.CREATE_JOB (
    job_name => 'MY_JOB',
    job_type => 'PLSQL_BLOCK',
    job_action => 'BEGIN DBMS_STATS.GATHER_TABLE_STATS(''SH'', ''SALES'', method_opt => ''FOR COLUMNS (empno, deptno)''); END;',
    job_class => 'DBMS_JOB$',
    start_date => TRUNC(SYSDATE),
    repeat_interval => 'FREQ=WEEKLY; INTERVAL=2; BYDAY=MON,THU,SUN; BYHOUR=8; BYMINUTE=0',
    enabled => TRUE);
END;
    
    
SELECT * FROM DBA_SCHEDULER_JOBS;
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
    use_current_session => FALSE
  );
END;
--Логи выполнений
SELECT log_date, status
FROM USER_SCHEDULER_JOB_LOG 
WHERE job_name = 'MY_JOB' 
ORDER BY log_date DESC;
