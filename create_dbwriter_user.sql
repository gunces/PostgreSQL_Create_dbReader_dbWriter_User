CREATE SCHEMA IF NOT EXISTS dba;

CREATE OR REPLACE FUNCTION dba.create_writable_user()
RETURNS void 
LANGUAGE PLPGSQL
AS $$

DECLARE
schemanames TEXT;
f_username TEXT := 'dbwriter';

BEGIN

	SELECT string_agg(distinct schemaname, ',') INTO schemanames
	  FROM pg_catalog.pg_tables
	 WHERE schemaname != 'pg_catalog'
	   AND schemaname != 'information_schema';  
	RAISE NOTICE 'All schemas: %', schemanames;		
	
	IF NOT EXISTS (SELECT rolname FROM pg_catalog.pg_roles WHERE rolname=f_username) THEN 
		EXECUTE 'CREATE ROLE ' || f_username || ' NOLOGIN';
		RAISE NOTICE 'CREATE ROLE dbwriter NOLOGIN';
	ELSE
		EXECUTE 'GRANT USAGE ON SCHEMA "'|| schemanames || '" TO "' || f_username || '"';
		RAISE NOTICE 'GRANT USAGE ON SCHEMA % TO %', schemanames, f_username;
		
		EXECUTE 'GRANT SELECT ON ALL SEQUENCES IN SCHEMA "'|| schemanames || '" TO "' || f_username || '"';
		RAISE NOTICE 'GRANT SELECT ON ALL SEQUENCES IN SCHEMA % TO %', schemanames, f_username;
		
		EXECUTE 'GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA "'|| schemanames || '" TO "' || f_username || '"';
		RAISE NOTICE 'GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA % TO %', schemanames, f_username;
		
		EXECUTE 'GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA "'|| schemanames || '" TO "' || f_username || '"';
		RAISE NOTICE 'GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA % TO %', schemanames, f_username;
		
		EXECUTE 'GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA "' || schemanames || '" TO "' || f_username || '"';
		RAISE NOTICE 'GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA %  TO  %', schemanames, f_username;

		EXECUTE 'ALTER DEFAULT PRIVILEGES IN SCHEMA "' || schemanames || '" GRANT SELECT, UPDATE, DELETE, INSERT ON TABLES TO "' || f_username || '"';
		RAISE NOTICE 'ALTER DEFAULT PRIVILEGES IN SCHEMA % GRANT SELECT ON TABLES TO %', schemanames, f_username;
		
		EXECUTE 'ALTER DEFAULT PRIVILEGES FOR ROLE "' || f_username || '" IN SCHEMA "' || schemanames || '" GRANT EXECUTE ON FUNCTIONS TO "' || f_username || '"';
		RAISE NOTICE 'ALTER DEFAULT PRIVILEGES FOR ROLE "%" IN SCHEMA "%" GRANT EXECUTE ON FUNCTIONS TO "%"', f_username, schemanames, f_username;

	END IF;

END;
$$;

-- SELECT dba.create_writable_user();
