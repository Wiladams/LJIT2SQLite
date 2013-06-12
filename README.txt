LJIT2SQLite
===========

A LuaJIT FFI binding to sqlite3

This binding has two faces.  The first face is the raw interface to the sqlite3.dll library.  Using this raw interface, you can write programs similar to the way you would do things in C.

The second face of the interface makes things a bit more Lua like.  Things start from the sqlite3_conn 'object' which contains various methods to handle creating connections, and managing that connection.  There is a sqlite3_stmt object, and a sqlite3_table object, which manages operations on a single table.

Here are some examples:

local sql3 = require "ljit2sqlite"

-- Establish a database connection to an in memory database
local dbconn,err = sqlite3_conn.Open(":memory:");

-- Create a table in the 'main' database
local tbl, rc, errormsg = dbconn:CreateTable("People", "First, Middle, Last");

tbl:InsertValues("'Bill', 'Albert', 'Gates'");
tbl:InsertValues("'Larry', 'Devon', 'Ellison'");
tbl:InsertValues("'Steve', 'Jahangir', 'Jobs'");
tbl:InsertValues("'Jack', '', 'Sprat'");
tbl:InsertValues("'Marry', '', 'Lamb'");
tbl:InsertValues("'Peter', '', 'Piper'");


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
dbconn:Exec("SELECT * from People", dbcallback)

-- Using prepared statements, do the same connect again
stmt, rc = dbconn:Prepare("SELECT * from People");

print("Prepared: ", stmt, rc);

-- Prepared columns tells you how many columns should be
-- in the result set once you start getting results
print("Prepared Cols: ", stmt:PreparedColumnCount());

-- DataRow Columns is the number of columns that actually
-- exist for a given row, after you've started getting
-- rows back.
print("Data Row Cols: ", stmt:dataRowColumnCount());


-- A simple utility routine to print out the values of a row
function printRow(row)
	local cols = #row;
	for i,value in ipairs(row) do
		io.write(value);
		if i<cols then
			io.write(',');
		end
	end
	io.write('\n');
end

-- Using the Results() iterator to return individual
-- rows as Lua tables.
for row in stmt:Results() do
	printRow(row);
end

-- Finish off the statement
stmt:finish();

-- Close the database connection
dbconn:Close();



In the last example, a statement is created, and it's Results() function returns an interator, which can easily be used in a typical Lua 'for' loop.
