# PostgreSQL Database Users' Read/Write Privileges

Creating or giving existing user privileges is not big deal but not a peace of cake for PostgreSQL and it doesn't have specific functions for user privileges like making user readonly, copy user role without make a member of a role yet.  

You can find four functions here to response this requests and it allows you to do easily.

- create_user_readonly.sql
- make_user_readonly.sql
- create_writable_user.sql
- make_user_writable.sql

PostgreSQL has ROLE and USER concepts. Both of them is database USER but there is a main difference between them. When you create a USER, in default it has LOGIN privilege but ROLE doesn't have.

You can use ROLE for grouping your users therefore you give privileges only ROLEs and under these group members can have same privileges. If you have lots of database user, you can seperate them as readonly and writable. So, it's easier way to manage their privileges.

>Database USER should have INHERIT privilage. 
>Do not forget, database USER or ROLE are global objects but database objects (table, sequence, indexes, etc.) are local. So you can create any USER/ROLE in any database once but you should run following steps in every database if you need.

This four SQL files help you to do it.

## Make user readonly

First, run create_user_readonly.sql and make_user_readonly.sql SQL files in your database. You may copy them into database server. These SQL files will create functions you'll need.

```
psql -h <host> -p <port> -d <database> -f create_user_readonly.sql
psql -h <host> -p <port> -d <database> -f make_user_readonly.sql
```

Second step is running bellow SQL script in your database

```
SELECT dba.make_user_readonly('<user name>'); 
```

## Make user writable

Copy create_writable_user.sql and make_user_writable.sql files into your database server and run in your database as bellow.

```
psql -h <host> -p <port> -d <database> -f create_writable_user.sql
psql -h <host> -p <port> -d <database> -f make_user_writable.sql
```

Now, you are ready to add your database USER into dbwriter ROLE. 

```
SELECT dba.make_user_writable('<user name>');
```

*PS: Some of funtions were created for workaround.*
