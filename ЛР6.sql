SELECT * FROM DICT_COLUMNS;

SELECT index_name
FROM all_indexes
WHERE table_name = 'EMPLOYEES' AND table_owner = 'HR';

SELECT * FROM all_indexes;

SELECT * FROM all_tab_columns WHERE owner = 'SH' AND REGEXP_LIKE(DATA_TYPE, 'CHAR');

SELECT at.table_name,ac.constraint_name FROM all_tables at
LEFT JOIN all_constraints ac
    ON at.table_name = ac.table_name AND ac.constraint_type = 'R'
WHERE ac.constraint_name IS NULL;

SELECT * FROM all_constraints;
SELECT * FROM all_tables;

DECLARE
    sqlscript VARCHAR2(1000);
BEGIN
    FOR colume IN (SELECT * FROM all_tab_columns WHERE owner = 'SH' AND REGEXP_LIKE(DATA_TYPE, 'CHAR'))
    LOOP
        IF colume.data_length * 2 < 4000 then
            DBMS_OUTPUT.PUT_LINE('ALTER TABLE SH.' || colume.table_name || ' MODIFY ' || colume.column_name || ' ' || colume.data_type || '(' || colume.data_length * 2 || ')');
        ELSE 
            DBMS_OUTPUT.PUT_LINE('ALTER TABLE SH.' || colume.table_name || ' MODIFY ' || colume.column_name || ' ' || colume.data_type || '(' || 4000 || ')');
        END IF;
    END LOOP;
END;

CREATE TABLE test (
    per1 VARCHAR2(100),
    per2048 VARCHAR2(2048)
)

DROP TABLE test;
DECLARE
    sqlscript VARCHAR2(1000);
BEGIN
    FOR colume IN (SELECT * FROM user_tab_columns WHERE TABLE_NAME='TEST' AND REGEXP_LIKE(DATA_TYPE, 'CHAR'))
     LOOP
        IF colume.data_length * 2 < 4000 then
            sqlscript := 'ALTER TABLE ' || colume.table_name || ' MODIFY ' || colume.column_name || ' ' || colume.data_type || '(' || colume.data_length * 2 || ')';
            EXECUTE IMMEDIATE sqlscript;
        ELSE 
            sqlscript := 'ALTER TABLE ' || colume.table_name || ' MODIFY ' || colume.column_name || ' ' || colume.data_type || '(' || 4000 || ')';
            EXECUTE IMMEDIATE sqlscript;
        END IF;
    END LOOP;
END;

SELECT * FROM user_tab_columns WHERE owner = 'KC2203-20'


sqlscript := 'ALTER TABLE ' || colume.table_name || ' MODIFY ' || colume.column_name || ' ' || colume.data_type || '(' || colume.data_length * 2 || ')';
        EXECUTE IMMEDIATE sqlscript;
        DBMS_OUTPUT.PUT_LINE('Изменена колонка: ' || colume.table_name || '.' || colume.column_name || ' Был размер: ' || colume.data_length || ' Новый размер: ' || colume.data_length * 2);
