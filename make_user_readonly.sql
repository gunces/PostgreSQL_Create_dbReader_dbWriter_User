CREATE SCHEMA IF NOT EXISTS dba;

CREATE OR REPLACE FUNCTION dba.make_user_readonly(f_username text)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE 
AS $BODY$

BEGIN
	IF NOT EXISTS(SELECT rolname FROM pg_catalog.pg_roles WHERE rolname='dbreader') THEN 
		RAISE EXCEPTION 'First create dbreader role than execute dba.dbf_make_readonly(text) function';
	END IF;

	EXECUTE 'ALTER USER "'|| f_username || '" INHERIT';
	RAISE NOTICE 'ALTER USER "%" INHERIT', f_username;
	EXECUTE 'GRANT dbreader TO "'|| f_username || '"';
	RAISE NOTICE 'GRANT dbreader TO "%"', f_username;

END;

$BODY$;

-- SELECT dba.make_user_readonly('<user name>'); 
