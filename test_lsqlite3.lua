local ffi = require "ffi"

local sql3 = require "ljit2sqlite"


-- A simple function to report errors
-- This will hault the program if there
-- is an error
-- Use this when you consider an error to
-- be an exception
-- But really, it's just to test things out
function dbcheck(rc, errormsg)
	if rc ~=  SQLITE_OK then
		print("Error Code: ", rc)
		error(errormsg)
	end

	return rc, errormsg
end



print("Version: ", ffi.string(sql3.sqlite3_libversion()));
--print("Source ID: ", ffi.string(sql3.sqlite3_sourceid()));

-- Establish a database connection to an in memory database
local dbconn,err = sqlite3_conn.Open(":memory:");

print(dbconn, err);


-- Create a table in the 'main' database
local tbl, rc, errormsg = dbconn:CreateTable("People", "First, Middle, Last");


-- Insert some rows into the table
dbcheck(tbl:InsertValues("'Bill', 'Albert', 'Gates'"));
dbcheck(tbl:InsertValues("'Larry', 'Devon', 'Ellison'"));
dbcheck(tbl:InsertValues("'Steve', 'Jahangir', 'Jobs'"));
dbcheck(tbl:InsertValues("'Jack', '', 'Sprat'"));
dbcheck(tbl:InsertValues("'Marry', '', 'Lamb'"));
dbcheck(tbl:InsertValues("'Peter', '', 'Piper'"));

-- This routine is used as a callback from the Exec() function
-- It is just an example of one way of interacting with the
-- thing.  All values come back as strings.
function dbcallback(userdata, dbargc, dbvalues, dbcolumns)
	--print("dbcallback", dbargc);
	local printheadings = userdata ~= nil

	if printheadings then
		-- print column names
		for i=0,dbargc-1 do
			io.write(ffi.string(dbcolumns[i]))
			if i<dbargc-1 then
				io.write(", ");
			end

			if i==dbargc-1 then
				io.write("\n");
			end
		end
	end

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
print("Data Row Cols: ", stmt:DataRowColumnCount());


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
stmt:Finish();

-- Close the database connection
dbconn:Close();

