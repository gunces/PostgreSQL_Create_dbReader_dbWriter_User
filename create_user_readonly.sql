CREATE SCHEMA IF NOT EXISTS dba;

CREATE OR REPLACE FUNCTION dba.create_user_readonly()
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE 
AS $BODY$

DECLARE
schemanames TEXT;
exclude_schemanames TEXT;
cur_database TEXT;

BEGIN

  IF NOT EXISTS(SELECT rolname FROM pg_catalog.pg_roles WHERE rolname='dbreader') THEN 
	EXECUTE format('CREATE ROLE dbreader NOLOGIN');
	RAISE NOTICE 'CREATE ROLE dbreader NOLOGIN';
  END IF;
	SELECT string_agg(distinct '"' || schema_name || '"', ',') INTO schemanames 
	  FROM information_schema.schemata 
	 WHERE schema_name not like 'pg\_%'
	   AND schema_name not in ('information_schema');

	SELECT string_agg(distinct '"' || schema_name || '"', ',') INTO exclude_schemanames 
	  FROM information_schema.schemata 
	 WHERE schema_name like 'pg\_%'
	   OR schema_name in ('information_schema');

	RAISE NOTICE 'All schemas: %', schemanames;	
	
	select current_database() INTO cur_database;	
	RAISE NOTICE 'Current Database: %', cur_database;

	EXECUTE 'REVOKE ALL ON DATABASE "'|| cur_database || '" from dbreader';
	RAISE NOTICE 'REVOKE ALL ON DATABASE "%" from dbreader', cur_database;

	EXECUTE 'ALTER DEFAULT PRIVILEGES IN SCHEMA ' || schemanames || ',' || exclude_schemanames || ' revoke all privileges ON TABLES from dbreader';
	RAISE NOTICE 'ALTER DEFAULT PRIVILEGES IN SCHEMA % revoke all privileges ON TABLES from dbreader', schemanames;

	EXECUTE 'revoke all privileges ON ALL SEQUENCES IN SCHEMA ' || schemanames || ',' || exclude_schemanames || ' from dbreader';
	RAISE NOTICE 'revoke all privileges ON ALL SEQUENCES IN SCHEMA % from dbreader', schemanames;

	EXECUTE 'revoke all privileges ON SCHEMA ' || schemanames || ',' || exclude_schemanames || ' from dbreader';
	RAISE NOTICE 'revoke all privileges ON SCHEMA % from dbreader', schemanames;

	EXECUTE 'revoke all privileges ON ALL TABLES in SCHEMA ' || schemanames || ',' || exclude_schemanames || ' from dbreader';
	RAISE NOTICE 'revoke all privileges ON ALL TABLES in SCHEMA % from dbreader', schemanames;

	-- EXECUTE 'REVOKE SELECT ON ALL TABLES IN SCHEMA '|| exclude_schemanames || ' FROM PUBLIC;';
	-- RAISE NOTICE 'REVOKE SELECT ON ALL TABLES IN SCHEMA % FROM PUBLIC', exclude_schemanames ;

	EXECUTE 'GRANT USAGE ON SCHEMA ' || schemanames || ' TO dbreader';
	RAISE NOTICE 'GRANT USAGE ON SCHEMA % TO dbreader', schemanames;

	EXECUTE 'GRANT SELECT ON ALL TABLES in SCHEMA ' || schemanames || ' TO dbreader';
	RAISE NOTICE 'GRANT SELECT ON ALL TABLES in SCHEMA % TO dbreader', schemanames;

	EXECUTE 'ALTER DEFAULT PRIVILEGES IN SCHEMA ' || schemanames || ' GRANT SELECT ON TABLES TO dbreader';
	RAISE NOTICE 'ALTER DEFAULT PRIVILEGES IN SCHEMA % GRANT SELECT ON TABLES TO dbreader', schemanames;

	EXECUTE 'GRANT SELECT ON ALL SEQUENCES IN SCHEMA ' || schemanames || ' TO dbreader';
	RAISE NOTICE 'GRANT SELECT ON ALL SEQUENCES IN SCHEMA % TO dbreader', schemanames;

END;
$BODY$;

select dba.create_user_readonly();
