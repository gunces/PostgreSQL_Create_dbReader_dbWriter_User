
-- If you don't want to make some specific user to member of any role and want to copy from a user privileges to another user you can use this function.
-- In the other way you can create a new role/user and make member of any role with INHERIT option.
-- Or you can use GRANT primary_user to secondary_user script to make role/user member of a role. 
-- PS: This script will not work if user is inherited(one or more)
-- PS: This script will not revoke privileges of secondary user.  

CREATE OR REPLACE FUNCTION copy_user_privileges(__primary_user TEXT, __secondary_user TEXT)
RETURNS VOID LANGUAGE plpgsql AS
$$

DECLARE 
usage_string TEXT;
select_string TEXT;
granted_schemas TEXT;
granted_tables TEXT;
inherit_from TEXT;

BEGIN

	IF NOT EXISTS (SELECT 1 FROM pg_catalog.pg_roles WHERE rolname=$1) or NOT EXISTS (SELECT 1 FROM pg_catalog.pg_roles WHERE rolname=$2)  THEN 
		RAISE EXCEPTION 'Invalid user: %',$1; 
	ELSE
	
		BEGIN 
			-- This scripts will generate GRANT USAGE and GRANT scripts for secondary user as primary user has.
			SELECT string_agg(DISTINCT (rg.table_schema), ', '),
					'GRANT USAGE ON SCHEMA ' || string_agg(DISTINCT (rg.table_schema), ', ') || ' TO '|| $2 || ';', -- Generate GRANT USAGE script 
					string_agg(rg.table_schema||'.'||rg.table_name, ', '),
					'GRANT ' ||rg.privilege_type || ' ON TABLE ' || string_agg(rg.table_schema||'.'||rg.table_name, ', ') ||' TO '|| $2 ||';'  -- Generate GRANT script
					INTO granted_schemas, usage_string, granted_tables, select_string
			FROM information_schema.role_table_grants rg 
			INNER JOIN pg_catalog.pg_stat_user_tables st ON (st.schemaname,st.relname)=(rg.table_schema,rg.TABLE_NAME)
			WHERE grantee=$1
			GROUP BY privilege_type;
		
			EXECUTE usage_string USING $1;
			RAISE NOTICE '% has USAGE privilege for schemas: %', $2, granted_schemas;
			
			EXECUTE select_string USING $1; 
			RAISE NOTICE '% has privileges for tables: %', $2, granted_tables;
		END;

	END IF;
	
END;
$$;

--
--
-- USAGE
--
-- SELECT copy_user_privileges('guncek3','guncek4');
--
--
