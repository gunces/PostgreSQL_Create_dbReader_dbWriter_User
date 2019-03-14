CREATE OR REPLACE FUNCTION make_user_readonly(__username TEXT)
RETURNS VOID LANGUAGE plpgsql AS
$$

DECLARE 
usage_string TEXT;
select_string TEXT;
granted_schemas TEXT;
granted_tables TEXT;

BEGIN

	IF NOT EXISTS (SELECT 1 FROM pg_catalog.pg_roles WHERE rolname=$1) THEN 
		RAISE EXCEPTION 'Invalid user: %',$1; 
	ELSE
	
		BEGIN
			SELECT string_agg(DISTINCT (schemaname), ', '),
					'GRANT USAGE ON SCHEMA ' || string_agg(DISTINCT (schemaname), ', ') || ' TO '|| $1 || ';',
					string_agg(DISTINCT (schemaname||'.'||relname), ', '),
					'GRANT SELECT ON TABLE ' || string_agg(DISTINCT (schemaname||'.'||relname), ', ') || ' TO '|| $1 || ';' INTO granted_schemas, usage_string, granted_tables, select_string
			FROM pg_catalog.pg_stat_user_tables;

			EXECUTE usage_string USING $1;
			EXECUTE select_string USING $1; 
			RAISE NOTICE '% is read-only user from now.', $1;
			RAISE NOTICE '% is granted for schemas: %', $1, granted_schemas;
			RAISE NOTICE '% is granted for tables: %', $1, granted_tables;
		END;
		
	END IF;
	
END;
$$;

-- SELECT make_user_readonly('guncek');
