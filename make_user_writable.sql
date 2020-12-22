CREATE SCHEMA IF NOT EXISTS dba;

CREATE OR REPLACE FUNCTION dba.make_user_writable(f_username TEXT)
RETURNS void 
LANGUAGE PLPGSQL
AS $$

BEGIN
	
	IF NOT EXISTS (SELECT rolname FROM pg_catalog.pg_roles WHERE rolname=f_username) THEN 
		RAISE EXCEPTION '% user is not exists. Check user name or if not exists % user please create before execute dba.make_user_writable(TEXT) function', f_username, f_username ;
	END IF;

	EXECUTE 'ALTER USER "'|| f_username || '" INHERIT';
	RAISE NOTICE 'ALTER USER "%" INHERIT', f_username;
	EXECUTE 'GRANT dbwriter TO "'|| f_username || '"';
	RAISE NOTICE 'GRANT dbwriter TO "%"', f_username;
	
END;
$$;

-- SELECT dba.make_user_writable('<user name>');
