BEGIN
DBMS_SCHEDULER.CREATE_JOB (
    job_name => 'moning_job',
    jobtype => 'PLSQL_BLOCK',
    job_action => DBMS_STATS.GATHER_TABLE_STATS('SH', 'SALES', method_opt => 'FOR COLUMNS (empno, deptno)'),
    
);
END;
DBMS_STATS.GATHER_TABLE_STATS(
    'SH', 'SALES', method_opt => 'FOR COLUMNS (empno, deptno)'); 
