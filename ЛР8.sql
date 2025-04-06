МБ понадобится: set ORACLE_SID=XE

1. 
sqlplus sys as sysdba
Password: ???

2. 
ALTER SESSION SET CONTAINER = XEPDB1;

Посмотри где находятся файлы .dbf? У тебя на компе как в примере
3. 
ALTER TABLESPACE USERS
ADD DATAFILE 'C:\app\Acer\product\21c\oradata\XE\USERS03.dbf'
SIZE 550M
AUTOEXTEND ON
MAXSIZE 3330M;

4. 
SELECT s.sid, s.serial#, q.sql_text
FROM v$session s
JOIN v$sql q ON s.sql_id = q.sql_id
WHERE s.status = 'ACTIVE'
  AND s.username IS NOT NULL;

5. Я делал так sqlplus sys/password@localhost:1521/XEPDB1 as sysdba
sqlplus sys@XEPDB1 as sysdba

6.
CREATE USER RU_MY IDENTIFIED BY qwerty;

7.
CREATE ROLE loc_users;

8.
GRANT CREATE SESSION TO loc_users;

9.
GRANT loc_users TO RU_MY;

10.
Username: RU_MY
Password: qwerty
Hostname: ???
Port: ???
Service name: XEPDB1
