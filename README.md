LJIT2SQLite
===========

A LuaJIT FFI binding to sqlite3

This binding has two faces.  The first face is the raw interface to the sqlite3.dll library.  Using this raw interface, you can write programs similar to the way you would do things in C.

The second face of the interface makes things a bit more Lua like.  Things start from the sqlite3_conn 'object' which contains various methods to handle creating connections, and managing that connection.  There is a sqlite3_stmt object, and a sqlite3_table object, which manages operations on a single table.

Here are some examples:

License
-------
sqlite-ffi is in the Public Domain, as sqlite itself is.

Example
-------
```lua
local sql3 = require "sqlite-ffi"

-- Establish a database connection to an in-memory database
local dbconn, err = sqlite3_conn.open(":memory:");

-- Create a table in the database
local tbl, rc, errormsg = dbconn:createTable("People", "First, Middle, Last");

-- Insert some rows
tbl:insertValues("'Bill', 'Albert', 'Gates'");
tbl:insertValues("'Larry', 'Devon', 'Ellison'");
tbl:insertValues("'Steve', 'Jahangir', 'Jobs'");
tbl:insertValues("'Jack', '', 'Sprat'");
tbl:insertValues("'Marry', '', 'Lamb'");
tbl:insertValues("'Peter', '', 'Piper'");

-- This routine is used as a callback from the Exec() function
-- It is just an example of one way of interacting with the
-- thing.  All values come back as strings.
function dbcallback(userdata, dbargc, dbvalues, dbcolumns)
	-- print values
	for i=0,dbargc-1 do
		if dbvalues[i] == nil then
			io.write("NULL");
		else
			io.write(ffi.string(dbvalues[i]))
		end

		if i<dbargc-1 then
			io.write(",");
		end

		if i==dbargc-1 then
			io.write("\n");
		end
	end

	return 0;
end

-- Perform a seclect operation using the Exec() function
dbconn:exec("SELECT * from People", dbcallback)

-- Using prepared statements, do the same connect again
stmt, rc = dbconn:prepare("SELECT * from People");

print("Prepared: ", stmt, rc);

-- Prepared columns tells you how many columns should be
-- in the result set once you start getting results
print("Prepared Cols: ", stmt:preparedColumnCount());

-- DataRow Columns is the number of columns that actually
-- exist for a given row, after you've started getting
-- rows back.
print("Data Row Cols: ", stmt:dataRowColumnCount());

-- Using the results() iterator to return individual
-- rows as Lua tables.
for row in stmt:results() do
	-- row:getTable() converts the row into a
	-- key=value table, usable with pairs
	--
	-- NOTE: do not use pairs() or print() in
	-- performance-critical places, as they cannot be
	-- JIT-compiled. Their usage here is only an example.
	for k, v in pairs(row:getTable()) do
		print(string.format("%s: %s", k, v))
	end
	print()
end

-- Finish off the statement
stmt:finish()

-- Close the database connection
dbconn:close()
```
