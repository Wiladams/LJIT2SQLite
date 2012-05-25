
local ffi = require "ffi"

require "sqlite3"
local sql3 = ffi.load("sqlite3",true)


sqlite3_conn = {};
sqlite3_conn.__index = sqlite3_conn;

sqlite3_table = {};
sqlite3_table.__index = sqlite3_table;

sqlite3_stmt = {}
sqlite3_stmt.__index = sqlite3_stmt;


--[[
sqlite3_conn.__gc(self)
		if self.conn then
			self:Close()
		end
end
--]]

function sqlite3_conn.Open(dbname, mode)
	local lpdb = ffi.new("sqlite3*[1]")
	local err = sql3.sqlite3_open(dbname, lpdb);
	local conn = lpdb[0]

	if err == 0 then
		return setmetatable({conn=conn, dbname=dbname}, sqlite3_conn), 0
	end

	return nil, err
end;

function sqlite3_conn:Close()
	local rc = sql3.sqlite3_close(self.conn)
	if rc == SQLITE_OK then
		self.conn = nil
	end

	return rc
end

function sqlite3_conn:Exec(statement, callbackfunc, userdata)
--print("Exec: ", statement);
	local lperrMsg = ffi.new("char *[1]");
	local rc = sql3.sqlite3_exec(self.conn, statement, callbackfunc, userdata, lperrMsg);
	local errmsg = lperrMsg[0]

	if rc ~= SQLITE_OK then
		errmsg = ffi.string(errmsg);

		-- Free this to avoid a memory leak
		sql3.sqlite3_free(lperrMsg[0])
	end

	return rc, errmsg
end

function sqlite3_conn:GetLastRowID()
	return sql3.sqlite3_last_insert_rowid(self.conn);
end

function sqlite3_conn:Prepare(statement)
	local lpTail = ffi.new("const char *[1]");
	local lpsqlstmnt = ffi.new("sqlite3_stmt*[1]")

	local rc = sql3.sqlite3_prepare_v2(self.conn, statement, string.len(statement)+1, lpsqlstmnt, lpTail)

	if rc ~= SQLITE_OK then
		return nil, rc;
	end

	stmtstruct = lpsqlstmnt[0];

	local stmt = setmetatable(
	{
		conn = self,
		stmt = stmtstruct,
		PositionedOnRow = false,
	},sqlite3_stmt)

	return stmt, rc
end

function sqlite3_conn:Interrupt()
	local rc = sql3.sqlite3_interrupt(self.conn)
end

-- DDL
function sqlite3_conn:CreateTable(tablename, columns)
	local stmnt = string.format("CREATE TABLE %s (%s) ", tablename, columns);
	local rc, errmsg = self:Exec(stmnt)

	if rc ~= SQLITE_OK then
		return nil, rc, errmsg
	end

	return setmetatable({conn = self, tablename = tablename}, sqlite3_table)
end

function sqlite3_conn:DropTable(tablename)
	local stmnt = string.format("DROP TABLE %s ", tablename);
	local rc, errmsg = self:Exec(stmnt)

	if rc ~= SQLITE_OK then
		return nil, rc, errmsg
	end
end


--[[
==============================================
		CRUD Operations with Tables
==============================================
--]]

function sqlite3_table:InsertValues(values, columns)
	local stmnt
	if columns then
		stmnt = string.format("INSERT INTO %s (%s) VALUES (%s)", self.tablename, columns, values);
	else
		stmnt = string.format("INSERT INTO %s VALUES (%s)", self.tablename, values);
	end

	return self.conn:Exec(stmnt)
end

function sqlite3_table:Delete(expr)
	if not expr then return 0 end

	local stmnt = string.format("DELETE FROM %s WHERE %s ", self.tablename, expr)

	return self.conn:Exec(stmnt)
end

function sqlite3_table:Retrieve(expr, columns)
	local stmnt

	if expr then
		stmnt = string.format("SELECT %s FROM %s", columns, self.tablename)
	else
		stmnt = string.format("SELECT %s FROM %s WHERE %s", columns, self.tablename, expr)
	end

	return self.conn:Exec(stmnt)
end

--[[
int sqlite3_table_column_metadata(
  sqlite3 *db,                /* Connection handle */
  const char *zDbName,        /* Database name or NULL */
  const char *zTableName,     /* Table name */
  const char *zColumnName,    /* Column name */
  char const **pzDataType,    /* OUTPUT: Declared data type */
  char const **pzCollSeq,     /* OUTPUT: Collation sequence name */
  int *pNotNull,              /* OUTPUT: True if NOT NULL constraint exists */
  int *pPrimaryKey,           /* OUTPUT: True if column part of PK */
  int *pAutoinc               /* OUTPUT: True if column is auto-increment */
);

		-- Handy CRUD operations



		Update = function(self, tablename, columns, values)
		end;



		GetErrorMessage = function(self)
			return ffi.string(sql3.sqlite3_errmsg(self.conn))
		end;
--]]

--[[
==============================================
		Statements
==============================================
--]]
local value_handlers = {
	[SQLITE_INTEGER] = function(stmt, n) return sql3.sqlite3_column_int(stmt, n) end,
	[SQLITE_FLOAT] = function(stmt, n) return sql3.sqlite3_column_double(stmt, n) end,
	[SQLITE_TEXT] = function(stmt, n) return ffi.string(sql3.sqlite3_column_text(stmt,n)) end,
	[SQLITE_BLOB] = function(stmt, n) return sql3.sqlite3_column_blob(stmt,n), sql3.sqlite3_column_bytes(stmt,n) end,
	[SQLITE_NULL] = function() return nil end
}

function sqlite3_stmt:GetColumnValue(n)
	return value_handlers[sql3.sqlite3_column_type(self.stmt,n)](self.stmt,n)
end

function sqlite3_stmt:GetRowTable()
	if not self.PositionedOnRow then return nil end

	local res = {}
	local nCols = self:DataRowColumnCount()
	for i=0,nCols-1 do
		table.insert(res, self:GetColumnValue(i))
	end

	return res;
end

--[[
	This is an iterator
	It will call the Step() function before
	returning rows as lua tables

	Usage:

	for row in stmt:Results() do
	    printRow(row)
	end
--]]

function sqlite3_stmt:Results()
	-- Assume the statement has already been Prepared

	return function()
		local rc = self:Step()

		if rc ~= SQLITE_ROW then
			return nil
		end

		return self:GetRowTable();
	end
end

function sqlite3_stmt:Finish()
	local rc = sql3.sqlite3_finalize(self.stmt);
	self.PositionedOnRow = false;
end

function sqlite3_stmt:Step()
	local rc = sql3.sqlite3_step(self.stmt);
	self.PositionedOnRow = rc == SQLITE_ROW;

	return rc
end

function sqlite3_stmt:Reset()
	local rc = sql3.sqlite3_reset(self.stmt);
	self.PositionedOnRow = false;

	return rc
end

-- Some attributes of the statement
-- Get number of columns from the prepared statement
function sqlite3_stmt:PreparedColumnCount()
	return sql3.sqlite3_column_count(self.stmt);
end

function sqlite3_stmt:DataRowColumnCount()
	return sql3.sqlite3_data_count(self.stmt);
end

function sqlite3_stmt:IsBusy()
	local rc = sql3.sqlite3_busy(self.stmt);
	return rc ~= 0
end

function sqlite3_stmt:IsReadOnly()
	local rc = sql3.sqlite3_stmt_readonly(self.stmt);
	return rc ~= 0
end












return sql3
