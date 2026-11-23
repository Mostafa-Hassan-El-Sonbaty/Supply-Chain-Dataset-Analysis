Olist Database: Setup Instructions
==================================

PostgreSQL database for the Olist supply chain analysis project (2017-2018 data, about 8000 orders).
It has two schemas: raw (the original Excel data, no constraints) and clean (after cleaning, with keys and constraints).


Requirements
------------
- PostgreSQL and pgAdmin.
- Code file: olist_code.sql
- A raw folder (8 CSV files) and a clean folder (8 CSV files).


Steps
-----
1. Open pgAdmin, right-click Databases, then Create, then Database. Type any name (for example olist) and click Save.
2. Copy the raw and clean folders to C:/Database, so the paths look like C:/Database/raw/Customers.csv and C:/Database/clean/Customers.csv.
3. Select the new database, open Query Tool, and open olist_code.sql.
4. If your folder is not C:/Database: press Ctrl+H and replace C:/Database with your path. Use forward slashes (/), not backslashes (\).
5. Click Execute (F5). It should finish with no ERROR.


If you have an old copy of the tables
-------------------------------------
Run this command alone first, then run the whole file:

    DROP SCHEMA IF EXISTS raw, clean CASCADE;

This only deletes the old tables. The original data stays in the CSV files and is loaded again.

To check:

    SELECT count(*) FROM clean.order_items;   -- should be 8942


Notes
-----
- The file is safe to run more than once: TRUNCATE only deletes the rows, then they are loaded again from the CSV files. Any manual changes to the tables will be lost.
- The file does not contain any DROP command.
- Cleaning was done in Python. The clean tables are loaded directly from the cleaned CSV files. There is no SQL transfer from raw to clean.
- There is no FK between products and translation. They are joined at analysis time with a LEFT JOIN on product_category_name.


Common errors
-------------
1) could not open file ... No such file or directory
   Cause: wrong path, or the folders are not in place.
   Fix: make sure the files are in C:/Database/raw and C:/Database/clean, or change the path with Ctrl+H.

2) Permission denied
   Cause: the folder is in Desktop or Documents, or on an external drive.
   Fix: move the folder directly to an internal drive, such as C:/Database.

3) must be superuser or have privileges of the pg_read_server_files role
   Cause: the user does not have permission to read files.
   Fix: run it as the postgres user.

4) extra data after last expected column   or   duplicate key
   Cause: old tables from a previous version.
   Fix: run DROP SCHEMA IF EXISTS raw, clean CASCADE; then the whole file.