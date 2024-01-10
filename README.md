# 1- Create Supabase project
# 2 - Setup custom claims for Supabase

Go the following link : https://github.com/supabase-community/supabase-custom-claims, and open the install.sql file. 
Then copy the content of the file and paste it in the SQL editor of your Supabase project.

# 3- Create the first Admin user

Go to the Supabase admin panel and create a new user and copy the id of this user. Then go to the SQL editor and run the following query:

```sql
select set_claim('03acaa13-7989-45c1-8dfb-6eeb7cf0b92e', 'role', '"ADMIN"');
```

