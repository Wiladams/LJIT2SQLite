--[[
** 2001 September 15
**
** The author disclaims copyright to this source code.  In place of
** a legal notice, here is a blessing:
**
**    May you do good and not evil.
**    May you find forgiveness for yourself and forgive others.
**    May you share freely, never taking more than you give.
**
--]]

--[[
	A note about the LuaJIT implementation of this interface.
	Some liberties and simplifications were taken.  Primarily
	all the deprecated and obsolete functions were removed.  Similarly,
	all of the documentation has been removed to reduce the size
	of the file.

	In the cases where there were ifdef's around using double
	vs long long, the double was favored, and the references
	to long long were just removed.

	The hundreds of constants are not defined outright, rather,
	they are in tables, which are then used to generate the constants.
	This allows the programmer to decide whether they want the
	constants to be regular Lua number values, or if they should be
	static const int within the ffi.cdef section.  The CreateTokens()
	function can be used to generate whatever is desired.

	If it is desirable to reduce the size of the file, these tables
	can be removed once the desired values are generated.

	This is the most raw interface to SQLite3.  More friendly interfaces
	should be constructed in other wrapper files.
--]]



local ffi = require "ffi"
local bit = require "bit"
local lshift = bit.lshift
local bor = bit.bor


--[[
	Created from this version:

	#define SQLITE_VERSION        "3.7.12.1"
	#define SQLITE_VERSION_NUMBER 3007012
	#define SQLITE_SOURCE_ID      "2012-05-22 02:45:53 6d326d44fd1d626aae0e8456e5fa2049f1ce0789"
--]]


function GetEnumTokens(tokentable,enumname)
	enumname = enumname or "";

	local res = {};

	table.insert(res, string.format("typedef enum %s {\n", enumname));
	for i,v in ipairs(tokentable) do
		table.insert(res, string.format("    %s = %d,\n", v[1], v[2]));
	end
	table.insert(res, "};");

	return table.concat(res);
end

function GetLuaTokens(tokentable)
	local res = {};

	for i,v in ipairs(tokentable) do
		table.insert(res, string.format("%s = %d;\n", v[1], v[2]));
	end

	return table.concat(res);
end

function CreateTokens(tokentable, driver)
	local str = driver(tokentable)
	local f = loadstring(str)
	f();
end



local sqliteerrorcodes = {
{"SQLITE_OK",           0   ," Successful result "};

-- beginning-of-error-codes

{"SQLITE_ERROR",        1   ," SQL error or missing database "};
{"SQLITE_INTERNAL",     2   ," Internal logic error in SQLite "};
{"SQLITE_PERM",         3   ," Access permission denied "};
{"SQLITE_ABORT",        4   ," Callback routine requested an abort "};
{"SQLITE_BUSY",         5   ," The database file is locked "};
{"SQLITE_LOCKED",       6   ," A table in the database is locked "};
{"SQLITE_NOMEM",        7   ," A malloc() failed "};
{"SQLITE_READONLY",     8   ," Attempt to write a readonly database "};
{"SQLITE_INTERRUPT",    9   ," Operation terminated by sqlite3_interrupt()"};
{"SQLITE_IOERR",       10   ," Some kind of disk I/O error occurred "};
{"SQLITE_CORRUPT",     11   ," The database disk image is malformed "};
{"SQLITE_NOTFOUND",    12   ," Unknown opcode in sqlite3_file_control() "};
{"SQLITE_FULL",        13   ," Insertion failed because database is full "};
{"SQLITE_CANTOPEN",    14   ," Unable to open the database file "};
{"SQLITE_PROTOCOL",    15   ," Database lock protocol error "};
{"SQLITE_EMPTY",       16   ," Database is empty "};
{"SQLITE_SCHEMA",      17   ," The database schema changed "};
{"SQLITE_TOOBIG",      18   ," String or BLOB exceeds size limit "};
{"SQLITE_CONSTRAINT",  19   ," Abort due to constraint violation "};
{"SQLITE_MISMATCH",    20   ," Data type mismatch "};
{"SQLITE_MISUSE",      21   ," Library used incorrectly "};
{"SQLITE_NOLFS",       22   ," Uses OS features not supported on host "};
{"SQLITE_AUTH",        23   ," Authorization denied "};
{"SQLITE_FORMAT",      24   ," Auxiliary database format error "};
{"SQLITE_RANGE",       25   ," 2nd parameter to sqlite3_bind out of range "};
{"SQLITE_NOTADB",      26   ," File opened that is not a database file "};
{"SQLITE_ROW",         100  ," sqlite3_step() has another row ready "};
{"SQLITE_DONE",        101  ," sqlite3_step() has finished executing "};
};

-- end-of-error-codes
CreateTokens(sqliteerrorcodes, GetLuaTokens);


local sqlitecodes = {
{"SQLITE_IOERR_READ",              bor(SQLITE_IOERR , lshift(1,8))};
{"SQLITE_IOERR_SHORT_READ",        bor(SQLITE_IOERR , lshift(2,8))};
{"SQLITE_IOERR_WRITE",             bor(SQLITE_IOERR , lshift(3,8))};
{"SQLITE_IOERR_FSYNC",             bor(SQLITE_IOERR , lshift(4,8))};
{"SQLITE_IOERR_DIR_FSYNC",         bor(SQLITE_IOERR , lshift(5,8))};
{"SQLITE_IOERR_TRUNCATE",          bor(SQLITE_IOERR , lshift(6,8))};
{"SQLITE_IOERR_FSTAT",             bor(SQLITE_IOERR , lshift(7,8))};
{"SQLITE_IOERR_UNLOCK",            bor(SQLITE_IOERR , lshift(8,8))};
{"SQLITE_IOERR_RDLOCK",            bor(SQLITE_IOERR , lshift(9,8))};
{"SQLITE_IOERR_DELETE",            bor(SQLITE_IOERR , lshift(10,8))};
{"SQLITE_IOERR_BLOCKED",           bor(SQLITE_IOERR , lshift(11,8))};
{"SQLITE_IOERR_NOMEM",             bor(SQLITE_IOERR , lshift(12,8))};
{"SQLITE_IOERR_ACCESS",            bor(SQLITE_IOERR , lshift(13,8))};
{"SQLITE_IOERR_CHECKRESERVEDLOCK", bor(SQLITE_IOERR , lshift(14,8))};
{"SQLITE_IOERR_LOCK",              bor(SQLITE_IOERR , lshift(15,8))};
{"SQLITE_IOERR_CLOSE",             bor(SQLITE_IOERR , lshift(16,8))};
{"SQLITE_IOERR_DIR_CLOSE",         bor(SQLITE_IOERR , lshift(17,8))};
{"SQLITE_IOERR_SHMOPEN",           bor(SQLITE_IOERR , lshift(18,8))};
{"SQLITE_IOERR_SHMSIZE",           bor(SQLITE_IOERR , lshift(19,8))};
{"SQLITE_IOERR_SHMLOCK",           bor(SQLITE_IOERR , lshift(20,8))};
{"SQLITE_IOERR_SHMMAP",            bor(SQLITE_IOERR , lshift(21,8))};
{"SQLITE_IOERR_SEEK",              bor(SQLITE_IOERR , lshift(22,8))};
{"SQLITE_LOCKED_SHAREDCACHE",      bor(SQLITE_LOCKED ,  lshift(1,8))};
{"SQLITE_BUSY_RECOVERY",           bor(SQLITE_BUSY   ,  lshift(1,8))};
{"SQLITE_CANTOPEN_NOTEMPDIR",      bor(SQLITE_CANTOPEN , lshift(1,8))};
{"SQLITE_CANTOPEN_ISDIR",          bor(SQLITE_CANTOPEN , lshift(2,8))};
{"SQLITE_CORRUPT_VTAB",            bor(SQLITE_CORRUPT , lshift(1,8))};
{"SQLITE_READONLY_RECOVERY",       bor(SQLITE_READONLY , lshift(1,8))};
{"SQLITE_READONLY_CANTLOCK",       bor(SQLITE_READONLY , lshift(2,8))};
{"SQLITE_ABORT_ROLLBACK",          bor(SQLITE_ABORT , lshift(2,8))};


{"SQLITE_OPEN_READONLY",         0x00000001  ," Ok for sqlite3_open_v2() "};
{"SQLITE_OPEN_READWRITE",        0x00000002  ," Ok for sqlite3_open_v2() "};
{"SQLITE_OPEN_CREATE",           0x00000004  ," Ok for sqlite3_open_v2() "};
{"SQLITE_OPEN_DELETEONCLOSE",    0x00000008  ," VFS only "};
{"SQLITE_OPEN_EXCLUSIVE",        0x00000010  ," VFS only "};
{"SQLITE_OPEN_AUTOPROXY",        0x00000020  ," VFS only "};
{"SQLITE_OPEN_URI",              0x00000040  ," Ok for sqlite3_open_v2() "};
{"SQLITE_OPEN_MAIN_DB",          0x00000100  ," VFS only "};
{"SQLITE_OPEN_TEMP_DB",          0x00000200  ," VFS only "};
{"SQLITE_OPEN_TRANSIENT_DB",     0x00000400  ," VFS only "};
{"SQLITE_OPEN_MAIN_JOURNAL",     0x00000800  ," VFS only "};
{"SQLITE_OPEN_TEMP_JOURNAL",     0x00001000  ," VFS only "};
{"SQLITE_OPEN_SUBJOURNAL",       0x00002000  ," VFS only "};
{"SQLITE_OPEN_MASTER_JOURNAL",   0x00004000  ," VFS only "};
{"SQLITE_OPEN_NOMUTEX",          0x00008000  ," Ok for sqlite3_open_v2() "};
{"SQLITE_OPEN_FULLMUTEX",        0x00010000  ," Ok for sqlite3_open_v2() "};
{"SQLITE_OPEN_SHAREDCACHE",      0x00020000  ," Ok for sqlite3_open_v2() "};
{"SQLITE_OPEN_PRIVATECACHE",     0x00040000  ," Ok for sqlite3_open_v2() "};
{"SQLITE_OPEN_WAL",              0x00080000  ," VFS only "};

-- Reserved:                         0x00F00000

{"SQLITE_IOCAP_ATOMIC",                 0x00000001};
{"SQLITE_IOCAP_ATOMIC512",              0x00000002};
{"SQLITE_IOCAP_ATOMIC1K",               0x00000004};
{"SQLITE_IOCAP_ATOMIC2K",               0x00000008};
{"SQLITE_IOCAP_ATOMIC4K",               0x00000010};
{"SQLITE_IOCAP_ATOMIC8K",               0x00000020};
{"SQLITE_IOCAP_ATOMIC16K",              0x00000040};
{"SQLITE_IOCAP_ATOMIC32K",              0x00000080};
{"SQLITE_IOCAP_ATOMIC64K",              0x00000100};
{"SQLITE_IOCAP_SAFE_APPEND",            0x00000200};
{"SQLITE_IOCAP_SEQUENTIAL",             0x00000400};
{"SQLITE_IOCAP_UNDELETABLE_WHEN_OPEN",  0x00000800};
{"SQLITE_IOCAP_POWERSAFE_OVERWRITE",    0x00001000};


{"SQLITE_LOCK_NONE",           0};
{"SQLITE_LOCK_SHARED",         1};
{"SQLITE_LOCK_RESERVED",       2};
{"SQLITE_LOCK_PENDING",        3};
{"SQLITE_LOCK_EXCLUSIVE",      4};


{"SQLITE_SYNC_NORMAL",        0x00002};
{"SQLITE_SYNC_FULL",          0x00003};
{"SQLITE_SYNC_DATAONLY",      0x00010};

{"SQLITE_FCNTL_LOCKSTATE",               1};
{"SQLITE_GET_LOCKPROXYFILE",             2};
{"SQLITE_SET_LOCKPROXYFILE",             3};
{"SQLITE_LAST_ERRNO",                    4};
{"SQLITE_FCNTL_SIZE_HINT",               5};
{"SQLITE_FCNTL_CHUNK_SIZE",              6};
{"SQLITE_FCNTL_FILE_POINTER",            7};
{"SQLITE_FCNTL_SYNC_OMITTED",            8};
{"SQLITE_FCNTL_WIN32_AV_RETRY",          9};
{"SQLITE_FCNTL_PERSIST_WAL",            10};
{"SQLITE_FCNTL_OVERWRITE",              11};
{"SQLITE_FCNTL_VFSNAME",                12};
{"SQLITE_FCNTL_POWERSAFE_OVERWRITE",    13};
{"SQLITE_FCNTL_PRAGMA",                 14};

{"SQLITE_ACCESS_EXISTS",     0};
{"SQLITE_ACCESS_READWRITE",  1};
{"SQLITE_ACCESS_READ",       2};

{"SQLITE_SHM_UNLOCK",        1};
{"SQLITE_SHM_LOCK",          2};
{"SQLITE_SHM_SHARED",        4};
{"SQLITE_SHM_EXCLUSIVE",     8};

{"SQLITE_SHM_NLOCK",         8};



{"SQLITE_CONFIG_SINGLETHREAD",   1  ," nil "};
{"SQLITE_CONFIG_MULTITHREAD",    2  ," nil "};
{"SQLITE_CONFIG_SERIALIZED",     3  ," nil "};
{"SQLITE_CONFIG_MALLOC",         4  ," sqlite3_mem_methods* "};
{"SQLITE_CONFIG_GETMALLOC",      5  ," sqlite3_mem_methods* "};
{"SQLITE_CONFIG_SCRATCH",        6  ," void*, int sz, int N "};
{"SQLITE_CONFIG_PAGECACHE",      7  ," void*, int sz, int N "};
{"SQLITE_CONFIG_HEAP",           8  ," void*, int nByte, int min "};
{"SQLITE_CONFIG_MEMSTATUS",      9  ," boolean "};
{"SQLITE_CONFIG_MUTEX",         10  ," sqlite3_mutex_methods* "};
{"SQLITE_CONFIG_GETMUTEX",      11  ," sqlite3_mutex_methods* "};

-- previously SQLITE_CONFIG_CHUNKALLOC 12 which is now unused.

{"SQLITE_CONFIG_LOOKASIDE",     13  ," int int "};
{"SQLITE_CONFIG_PCACHE",        14  ," no-op "};
{"SQLITE_CONFIG_GETPCACHE",     15  ," no-op "};
{"SQLITE_CONFIG_LOG",           16  ," xFunc, void* "};
{"SQLITE_CONFIG_URI",           17  ," int "};
{"SQLITE_CONFIG_PCACHE2",       18  ," sqlite3_pcache_methods2* "};
{"SQLITE_CONFIG_GETPCACHE2",    19  ," sqlite3_pcache_methods2* "};

{"SQLITE_DBCONFIG_LOOKASIDE",        1001  ," void* int int "};
{"SQLITE_DBCONFIG_ENABLE_FKEY",      1002  ," int int* "};
{"SQLITE_DBCONFIG_ENABLE_TRIGGER",   1003  ," int int* "};

{"SQLITE_DENY",    1   ," Abort the SQL statement with an error "};
{"SQLITE_IGNORE",  2   ," Don't allow access, but don't generate an error "};


--[[****************************************** 3rd ************ 4th **********--]]
{"SQLITE_CREATE_INDEX",          1   ," Index Name      Table Name      "};
{"SQLITE_CREATE_TABLE",          2   ," Table Name      NULL            "};
{"SQLITE_CREATE_TEMP_INDEX",     3   ," Index Name      Table Name      "};
{"SQLITE_CREATE_TEMP_TABLE",     4   ," Table Name      NULL            "};
{"SQLITE_CREATE_TEMP_TRIGGER",   5   ," Trigger Name    Table Name      "};
{"SQLITE_CREATE_TEMP_VIEW",      6   ," View Name       NULL            "};
{"SQLITE_CREATE_TRIGGER",        7   ," Trigger Name    Table Name      "};
{"SQLITE_CREATE_VIEW",           8   ," View Name       NULL            "};
{"SQLITE_DELETE",                9   ," Table Name      NULL            "};
{"SQLITE_DROP_INDEX",           10   ," Index Name      Table Name      "};
{"SQLITE_DROP_TABLE",           11   ," Table Name      NULL            "};
{"SQLITE_DROP_TEMP_INDEX",      12   ," Index Name      Table Name      "};
{"SQLITE_DROP_TEMP_TABLE",      13   ," Table Name      NULL            "};
{"SQLITE_DROP_TEMP_TRIGGER",    14   ," Trigger Name    Table Name      "};
{"SQLITE_DROP_TEMP_VIEW",       15   ," View Name       NULL            "};
{"SQLITE_DROP_TRIGGER",         16   ," Trigger Name    Table Name      "};
{"SQLITE_DROP_VIEW",            17   ," View Name       NULL            "};
{"SQLITE_INSERT",               18   ," Table Name      NULL            "};
{"SQLITE_PRAGMA",               19   ," Pragma Name     1st arg or NULL "};
{"SQLITE_READ",                 20   ," Table Name      Column Name     "};
{"SQLITE_SELECT",               21   ," NULL            NULL            "};
{"SQLITE_TRANSACTION",          22   ," Operation       NULL            "};
{"SQLITE_UPDATE",               23   ," Table Name      Column Name     "};
{"SQLITE_ATTACH",               24   ," Filename        NULL            "};
{"SQLITE_DETACH",               25   ," Database Name   NULL            "};
{"SQLITE_ALTER_TABLE",          26   ," Database Name   Table Name      "};
{"SQLITE_REINDEX",              27   ," Index Name      NULL            "};
{"SQLITE_ANALYZE",              28   ," Table Name      NULL            "};
{"SQLITE_CREATE_VTABLE",        29   ," Table Name      Module Name     "};
{"SQLITE_DROP_VTABLE",          30   ," Table Name      Module Name     "};
{"SQLITE_FUNCTION",             31   ," NULL            Function Name   "};
{"SQLITE_SAVEPOINT",            32   ," Operation       Savepoint Name  "};
{"SQLITE_COPY",                  0   ," No longer used "};


{"SQLITE_LIMIT_LENGTH",                    0};
{"SQLITE_LIMIT_SQL_LENGTH",                1};
{"SQLITE_LIMIT_COLUMN",                    2};
{"SQLITE_LIMIT_EXPR_DEPTH",                3};
{"SQLITE_LIMIT_COMPOUND_SELECT",           4};
{"SQLITE_LIMIT_VDBE_OP",                   5};
{"SQLITE_LIMIT_FUNCTION_ARG",              6};
{"SQLITE_LIMIT_ATTACHED",                  7};
{"SQLITE_LIMIT_LIKE_PATTERN_LENGTH",       8};
{"SQLITE_LIMIT_VARIABLE_NUMBER",           9};
{"SQLITE_LIMIT_TRIGGER_DEPTH",            10};


{"SQLITE_INTEGER",  1};
{"SQLITE_FLOAT",    2};
{"SQLITE_BLOB",     4};
{"SQLITE_NULL",     5};
{"SQLITE_TEXT",     3};



{"SQLITE_UTF8",           1};
{"SQLITE_UTF16LE",        2};
{"SQLITE_UTF16BE",        3};
{"SQLITE_UTF16",          4    ," Use native byte order "};
{"SQLITE_ANY",            5    ," sqlite3_create_function only "};
{"SQLITE_UTF16_ALIGNED",  8    ," sqlite3_create_collation only "};


{"SQLITE_INDEX_CONSTRAINT_EQ",    2};
{"SQLITE_INDEX_CONSTRAINT_GT",    4};
{"SQLITE_INDEX_CONSTRAINT_LE",    8};
{"SQLITE_INDEX_CONSTRAINT_LT",    16};
{"SQLITE_INDEX_CONSTRAINT_GE",    32};
{"SQLITE_INDEX_CONSTRAINT_MATCH", 64};


{"SQLITE_MUTEX_FAST",             0};
{"SQLITE_MUTEX_RECURSIVE",        1};
{"SQLITE_MUTEX_STATIC_MASTER",    2};
{"SQLITE_MUTEX_STATIC_MEM",       3  ," sqlite3_malloc() "};
{"SQLITE_MUTEX_STATIC_MEM2",      4  ," NOT USED "};
{"SQLITE_MUTEX_STATIC_OPEN",      4  ," sqlite3BtreeOpen() "};
{"SQLITE_MUTEX_STATIC_PRNG",      5  ," sqlite3_random() "};
{"SQLITE_MUTEX_STATIC_LRU",       6  ," lru page list "};
{"SQLITE_MUTEX_STATIC_LRU2",      7  ," NOT USED "};
{"SQLITE_MUTEX_STATIC_PMEM",      7  ," sqlite3PageMalloc() "};


{"SQLITE_TESTCTRL_FIRST",                    5};
{"SQLITE_TESTCTRL_PRNG_SAVE",                5};
{"SQLITE_TESTCTRL_PRNG_RESTORE",             6};
{"SQLITE_TESTCTRL_PRNG_RESET",               7};
{"SQLITE_TESTCTRL_BITVEC_TEST",              8};
{"SQLITE_TESTCTRL_FAULT_INSTALL",            9};
{"SQLITE_TESTCTRL_BENIGN_MALLOC_HOOKS",     10};
{"SQLITE_TESTCTRL_PENDING_BYTE",            11};
{"SQLITE_TESTCTRL_ASSERT",                  12};
{"SQLITE_TESTCTRL_ALWAYS",                  13};
{"SQLITE_TESTCTRL_RESERVE",                 14};
{"SQLITE_TESTCTRL_OPTIMIZATIONS",           15};
{"SQLITE_TESTCTRL_ISKEYWORD",               16};
{"SQLITE_TESTCTRL_SCRATCHMALLOC",           17};
{"SQLITE_TESTCTRL_LOCALTIME_FAULT",         18};
{"SQLITE_TESTCTRL_EXPLAIN_STMT",            19};
{"SQLITE_TESTCTRL_LAST",                    19};

{"SQLITE_STATUS_MEMORY_USED",          0};
{"SQLITE_STATUS_PAGECACHE_USED",       1};
{"SQLITE_STATUS_PAGECACHE_OVERFLOW",   2};
{"SQLITE_STATUS_SCRATCH_USED",         3};
{"SQLITE_STATUS_SCRATCH_OVERFLOW",     4};
{"SQLITE_STATUS_MALLOC_SIZE",          5};
{"SQLITE_STATUS_PARSER_STACK",         6};
{"SQLITE_STATUS_PAGECACHE_SIZE",       7};
{"SQLITE_STATUS_SCRATCH_SIZE",         8};
{"SQLITE_STATUS_MALLOC_COUNT",         9};

{"SQLITE_DBSTATUS_LOOKASIDE_USED",       0};
{"SQLITE_DBSTATUS_CACHE_USED",           1};
{"SQLITE_DBSTATUS_SCHEMA_USED",          2};
{"SQLITE_DBSTATUS_STMT_USED",            3};
{"SQLITE_DBSTATUS_LOOKASIDE_HIT",        4};
{"SQLITE_DBSTATUS_LOOKASIDE_MISS_SIZE",  5};
{"SQLITE_DBSTATUS_LOOKASIDE_MISS_FULL",  6};
{"SQLITE_DBSTATUS_CACHE_HIT",            7};
{"SQLITE_DBSTATUS_CACHE_MISS",           8};
{"SQLITE_DBSTATUS_CACHE_WRITE",          9};
{"SQLITE_DBSTATUS_MAX",                  9   ," Largest defined DBSTATUS "};

{"SQLITE_STMTSTATUS_FULLSCAN_STEP",     1};
{"SQLITE_STMTSTATUS_SORT",              2};
{"SQLITE_STMTSTATUS_AUTOINDEX",         3};


{"SQLITE_CHECKPOINT_PASSIVE", 0};
{"SQLITE_CHECKPOINT_FULL",    1},
{"SQLITE_CHECKPOINT_RESTART", 2},

{"SQLITE_VTAB_CONSTRAINT_SUPPORT", 1},

{"SQLITE_ROLLBACK", 1};
{"SQLITE_FAIL",     3};
{"SQLITE_REPLACE",  5};

{"SQLITE_IGNORE", 2, "Also used by sqlite3_authorizer() callback "};
{"SQLITE_ABORT", 4,  "Also an error code "};


{"SQLITE_STATIC", 0};
{"SQLITE_TRANSIENT",-1};
}


CreateTokens(sqlitecodes, GetLuaTokens);



ffi.cdef[[

const char sqlite3_version[];
const char *sqlite3_libversion(void);
const char *sqlite3_sourceid(void);
int sqlite3_libversion_number(void);



int sqlite3_threadsafe(void);


typedef struct sqlite3 sqlite3;


typedef int64_t sqlite3_int64;
typedef uint64_t sqlite3_uint64;



 int sqlite3_close(sqlite3 *);



 int sqlite3_exec(
  sqlite3*,                                  /* An open database */
  const char *sql,                           /* SQL to be evaluated */
  int (*callback)(void*,int,char**,char**),  /* Callback function */
  void *,                                    /* 1st argument to callback */
  char **errmsg                              /* Error msg written here */
);


typedef struct sqlite3_file sqlite3_file;
struct sqlite3_file {
  const struct sqlite3_io_methods *pMethods;
};


typedef struct sqlite3_io_methods sqlite3_io_methods;
struct sqlite3_io_methods {
  int iVersion;
  int (*xClose)(sqlite3_file*);
  int (*xRead)(sqlite3_file*, void*, int iAmt, sqlite3_int64 iOfst);
  int (*xWrite)(sqlite3_file*, const void*, int iAmt, sqlite3_int64 iOfst);
  int (*xTruncate)(sqlite3_file*, sqlite3_int64 size);
  int (*xSync)(sqlite3_file*, int flags);
  int (*xFileSize)(sqlite3_file*, sqlite3_int64 *pSize);
  int (*xLock)(sqlite3_file*, int);
  int (*xUnlock)(sqlite3_file*, int);
  int (*xCheckReservedLock)(sqlite3_file*, int *pResOut);
  int (*xFileControl)(sqlite3_file*, int op, void *pArg);
  int (*xSectorSize)(sqlite3_file*);
  int (*xDeviceCharacteristics)(sqlite3_file*);
  int (*xShmMap)(sqlite3_file*, int iPg, int pgsz, int, void volatile**);
  int (*xShmLock)(sqlite3_file*, int offset, int n, int flags);
  void (*xShmBarrier)(sqlite3_file*);
  int (*xShmUnmap)(sqlite3_file*, int deleteFlag);
};








typedef struct sqlite3_mutex sqlite3_mutex;


typedef struct sqlite3_vfs sqlite3_vfs;
typedef void (*sqlite3_syscall_ptr)(void);
struct sqlite3_vfs {
  int iVersion;
  int szOsFile;
  int mxPathname;
  sqlite3_vfs *pNext;
  const char *zName;
  void *pAppData;
  int (*xOpen)(sqlite3_vfs*, const char *zName, sqlite3_file*,
               int flags, int *pOutFlags);
  int (*xDelete)(sqlite3_vfs*, const char *zName, int syncDir);
  int (*xAccess)(sqlite3_vfs*, const char *zName, int flags, int *pResOut);
  int (*xFullPathname)(sqlite3_vfs*, const char *zName, int nOut, char *zOut);
  void *(*xDlOpen)(sqlite3_vfs*, const char *zFilename);
  void (*xDlError)(sqlite3_vfs*, int nByte, char *zErrMsg);
  void (*(*xDlSym)(sqlite3_vfs*,void*, const char *zSymbol))(void);
  void (*xDlClose)(sqlite3_vfs*, void*);
  int (*xRandomness)(sqlite3_vfs*, int nByte, char *zOut);
  int (*xSleep)(sqlite3_vfs*, int microseconds);
  int (*xCurrentTime)(sqlite3_vfs*, double*);
  int (*xGetLastError)(sqlite3_vfs*, int, char *);

  int (*xCurrentTimeInt64)(sqlite3_vfs*, sqlite3_int64*);

  int (*xSetSystemCall)(sqlite3_vfs*, const char *zName, sqlite3_syscall_ptr);
  sqlite3_syscall_ptr (*xGetSystemCall)(sqlite3_vfs*, const char *zName);
  const char *(*xNextSystemCall)(sqlite3_vfs*, const char *zName);

};






 int sqlite3_initialize(void);
 int sqlite3_shutdown(void);
 int sqlite3_os_init(void);
 int sqlite3_os_end(void);


 int sqlite3_config(int, ...);


 int sqlite3_db_config(sqlite3*, int op, ...);


typedef struct sqlite3_mem_methods sqlite3_mem_methods;
struct sqlite3_mem_methods {
  void *(*xMalloc)(int);         /* Memory allocation function */
  void (*xFree)(void*);          /* Free a prior allocation */
  void *(*xRealloc)(void*,int);  /* Resize an allocation */
  int (*xSize)(void*);           /* Return the size of an allocation */
  int (*xRoundup)(int);          /* Round up request size to allocation size */
  int (*xInit)(void*);           /* Initialize the memory allocator */
  void (*xShutdown)(void*);      /* Deinitialize the memory allocator */
  void *pAppData;                /* Argument to xInit() and xShutdown() */
};







 int sqlite3_extended_result_codes(sqlite3*, int onoff);


 sqlite3_int64 sqlite3_last_insert_rowid(sqlite3*);


 int sqlite3_changes(sqlite3*);


 int sqlite3_total_changes(sqlite3*);


 void sqlite3_interrupt(sqlite3*);


 int sqlite3_complete(const char *sql);
 int sqlite3_complete16(const void *sql);


 int sqlite3_busy_handler(sqlite3*, int(*)(void*,int), void*);


 int sqlite3_busy_timeout(sqlite3*, int ms);

/*
// Legacy, don't want to use this in new code
 int sqlite3_get_table(
  sqlite3 *db,          // An open database
  const char *zSql,     // SQL to be evaluated
  char ***pazResult,    // Results of the query
  int *pnRow,           // Number of result rows written here
  int *pnColumn,        // Number of result columns written here
  char **pzErrmsg       // Error msg written here
);
 void sqlite3_free_table(char **result);
*/

 char *sqlite3_mprintf(const char*,...);
 char *sqlite3_vmprintf(const char*, va_list);
 char *sqlite3_snprintf(int,char*,const char*, ...);
 char *sqlite3_vsnprintf(int,char*,const char*, va_list);


 void *sqlite3_malloc(int);
 void *sqlite3_realloc(void*, int);
 void sqlite3_free(void*);


 sqlite3_int64 sqlite3_memory_used(void);
 sqlite3_int64 sqlite3_memory_highwater(int resetFlag);


 void sqlite3_randomness(int N, void *P);


int sqlite3_set_authorizer(sqlite3*,
  int (*xAuth)(void*,int,const char*,const char*,const char*,const char*),
  void *pUserData
);



 void *sqlite3_trace(sqlite3*, void(*xTrace)(void*,const char*), void*);
 void *sqlite3_profile(sqlite3*,
 void(*xProfile)(void*,const char*,sqlite3_uint64), void*);


 void sqlite3_progress_handler(sqlite3*, int, int(*)(void*), void*);

 int sqlite3_open(
  const char *filename,   /* Database filename (UTF-8) */
  sqlite3 **ppDb          /* OUT: SQLite db handle */
);
int sqlite3_open16(
  const void *filename,   /* Database filename (UTF-16) */
  sqlite3 **ppDb          /* OUT: SQLite db handle */
);
int sqlite3_open_v2(
  const char *filename,   /* Database filename (UTF-8) */
  sqlite3 **ppDb,         /* OUT: SQLite db handle */
  int flags,              /* Flags */
  const char *zVfs        /* Name of VFS module to use */
);


const char *sqlite3_uri_parameter(const char *zFilename, const char *zParam);
int sqlite3_uri_boolean(const char *zFile, const char *zParam, int bDefault);
sqlite3_int64 sqlite3_uri_int64(const char*, const char*, sqlite3_int64);



int sqlite3_errcode(sqlite3 *db);
int sqlite3_extended_errcode(sqlite3 *db);
const char *sqlite3_errmsg(sqlite3*);
const void *sqlite3_errmsg16(sqlite3*);


typedef struct sqlite3_stmt sqlite3_stmt;


int sqlite3_limit(sqlite3*, int id, int newVal);




int sqlite3_prepare(
  sqlite3 *db,            /* Database handle */
  const char *zSql,       /* SQL statement, UTF-8 encoded */
  int nByte,              /* Maximum length of zSql in bytes. */
  sqlite3_stmt **ppStmt,  /* OUT: Statement handle */
  const char **pzTail     /* OUT: Pointer to unused portion of zSql */
);
 int sqlite3_prepare_v2(
  sqlite3 *db,            /* Database handle */
  const char *zSql,       /* SQL statement, UTF-8 encoded */
  int nByte,              /* Maximum length of zSql in bytes. */
  sqlite3_stmt **ppStmt,  /* OUT: Statement handle */
  const char **pzTail     /* OUT: Pointer to unused portion of zSql */
);
 int sqlite3_prepare16(
  sqlite3 *db,            /* Database handle */
  const void *zSql,       /* SQL statement, UTF-16 encoded */
  int nByte,              /* Maximum length of zSql in bytes. */
  sqlite3_stmt **ppStmt,  /* OUT: Statement handle */
  const void **pzTail     /* OUT: Pointer to unused portion of zSql */
);
 int sqlite3_prepare16_v2(
  sqlite3 *db,            /* Database handle */
  const void *zSql,       /* SQL statement, UTF-16 encoded */
  int nByte,              /* Maximum length of zSql in bytes. */
  sqlite3_stmt **ppStmt,  /* OUT: Statement handle */
  const void **pzTail     /* OUT: Pointer to unused portion of zSql */
);


const char *sqlite3_sql(sqlite3_stmt *pStmt);
int sqlite3_stmt_readonly(sqlite3_stmt *pStmt);
int sqlite3_stmt_busy(sqlite3_stmt*);


typedef struct Mem sqlite3_value;


typedef struct sqlite3_context sqlite3_context;


 int sqlite3_bind_blob(sqlite3_stmt*, int, const void*, int n, void(*)(void*));
 int sqlite3_bind_double(sqlite3_stmt*, int, double);
 int sqlite3_bind_int(sqlite3_stmt*, int, int);
 int sqlite3_bind_int64(sqlite3_stmt*, int, sqlite3_int64);
 int sqlite3_bind_null(sqlite3_stmt*, int);
 int sqlite3_bind_text(sqlite3_stmt*, int, const char*, int n, void(*)(void*));
 int sqlite3_bind_text16(sqlite3_stmt*, int, const void*, int, void(*)(void*));
 int sqlite3_bind_value(sqlite3_stmt*, int, const sqlite3_value*);
 int sqlite3_bind_zeroblob(sqlite3_stmt*, int, int n);
 int sqlite3_bind_parameter_count(sqlite3_stmt*);
 const char *sqlite3_bind_parameter_name(sqlite3_stmt*, int);
 int sqlite3_bind_parameter_index(sqlite3_stmt*, const char *zName);
 int sqlite3_clear_bindings(sqlite3_stmt*);
 int sqlite3_column_count(sqlite3_stmt *pStmt);
 const char *sqlite3_column_name(sqlite3_stmt*, int N);
 const void *sqlite3_column_name16(sqlite3_stmt*, int N);
 const char *sqlite3_column_database_name(sqlite3_stmt*,int);
 const void *sqlite3_column_database_name16(sqlite3_stmt*,int);
 const char *sqlite3_column_table_name(sqlite3_stmt*,int);
 const void *sqlite3_column_table_name16(sqlite3_stmt*,int);
 const char *sqlite3_column_origin_name(sqlite3_stmt*,int);
 const void *sqlite3_column_origin_name16(sqlite3_stmt*,int);
 const char *sqlite3_column_decltype(sqlite3_stmt*,int);
 const void *sqlite3_column_decltype16(sqlite3_stmt*,int);
 int sqlite3_step(sqlite3_stmt*);
 int sqlite3_data_count(sqlite3_stmt *pStmt);
 const void *sqlite3_column_blob(sqlite3_stmt*, int iCol);
 int sqlite3_column_bytes(sqlite3_stmt*, int iCol);
 int sqlite3_column_bytes16(sqlite3_stmt*, int iCol);
 double sqlite3_column_double(sqlite3_stmt*, int iCol);
 int sqlite3_column_int(sqlite3_stmt*, int iCol);
 sqlite3_int64 sqlite3_column_int64(sqlite3_stmt*, int iCol);
 const unsigned char *sqlite3_column_text(sqlite3_stmt*, int iCol);
 const void *sqlite3_column_text16(sqlite3_stmt*, int iCol);
 int sqlite3_column_type(sqlite3_stmt*, int iCol);
 sqlite3_value *sqlite3_column_value(sqlite3_stmt*, int iCol);
 int sqlite3_finalize(sqlite3_stmt *pStmt);
 int sqlite3_reset(sqlite3_stmt *pStmt);


 int sqlite3_create_function(
  sqlite3 *db,
  const char *zFunctionName,
  int nArg,
  int eTextRep,
  void *pApp,
  void (*xFunc)(sqlite3_context*,int,sqlite3_value**),
  void (*xStep)(sqlite3_context*,int,sqlite3_value**),
  void (*xFinal)(sqlite3_context*)
);
 int sqlite3_create_function16(
  sqlite3 *db,
  const void *zFunctionName,
  int nArg,
  int eTextRep,
  void *pApp,
  void (*xFunc)(sqlite3_context*,int,sqlite3_value**),
  void (*xStep)(sqlite3_context*,int,sqlite3_value**),
  void (*xFinal)(sqlite3_context*)
);
 int sqlite3_create_function_v2(
  sqlite3 *db,

  const char *zFunctionName,
  int nArg,
  int eTextRep,
  void *pApp,
  void (*xFunc)(sqlite3_context*,int,sqlite3_value**),
  void (*xStep)(sqlite3_context*,int,sqlite3_value**),
  void (*xFinal)(sqlite3_context*),
  void(*xDestroy)(void*)
);






 const void *sqlite3_value_blob(sqlite3_value*);
 int sqlite3_value_bytes(sqlite3_value*);
 int sqlite3_value_bytes16(sqlite3_value*);
 double sqlite3_value_double(sqlite3_value*);
 int sqlite3_value_int(sqlite3_value*);
 sqlite3_int64 sqlite3_value_int64(sqlite3_value*);
 const unsigned char *sqlite3_value_text(sqlite3_value*);
 const void *sqlite3_value_text16(sqlite3_value*);
 const void *sqlite3_value_text16le(sqlite3_value*);
 const void *sqlite3_value_text16be(sqlite3_value*);
 int sqlite3_value_type(sqlite3_value*);
 int sqlite3_value_numeric_type(sqlite3_value*);


 void *sqlite3_aggregate_context(sqlite3_context*, int nBytes);


 void *sqlite3_user_data(sqlite3_context*);


 sqlite3 *sqlite3_context_db_handle(sqlite3_context*);


 void *sqlite3_get_auxdata(sqlite3_context*, int N);
 void sqlite3_set_auxdata(sqlite3_context*, int N, void*, void (*)(void*));





 void sqlite3_result_blob(sqlite3_context*, const void*, int, void(*)(void*));
 void sqlite3_result_double(sqlite3_context*, double);
 void sqlite3_result_error(sqlite3_context*, const char*, int);
 void sqlite3_result_error16(sqlite3_context*, const void*, int);
 void sqlite3_result_error_toobig(sqlite3_context*);
 void sqlite3_result_error_nomem(sqlite3_context*);
 void sqlite3_result_error_code(sqlite3_context*, int);
 void sqlite3_result_int(sqlite3_context*, int);
 void sqlite3_result_int64(sqlite3_context*, sqlite3_int64);
 void sqlite3_result_null(sqlite3_context*);
 void sqlite3_result_text(sqlite3_context*, const char*, int, void(*)(void*));
 void sqlite3_result_text16(sqlite3_context*, const void*, int, void(*)(void*));
 void sqlite3_result_text16le(sqlite3_context*, const void*, int,void(*)(void*));
 void sqlite3_result_text16be(sqlite3_context*, const void*, int,void(*)(void*));
 void sqlite3_result_value(sqlite3_context*, sqlite3_value*);
 void sqlite3_result_zeroblob(sqlite3_context*, int n);


 int sqlite3_create_collation(
  sqlite3*,
  const char *zName,
  int eTextRep,
  void *pArg,
  int(*xCompare)(void*,int,const void*,int,const void*)
);
 int sqlite3_create_collation_v2(
  sqlite3*,
  const char *zName,
  int eTextRep,
  void *pArg,
  int(*xCompare)(void*,int,const void*,int,const void*),
  void(*xDestroy)(void*)
);
 int sqlite3_create_collation16(
  sqlite3*,
  const void *zName,
  int eTextRep,
  void *pArg,
  int(*xCompare)(void*,int,const void*,int,const void*)
);


 int sqlite3_collation_needed(
  sqlite3*,
  void*,
  void(*)(void*,sqlite3*,int eTextRep,const char*)
);
 int sqlite3_collation_needed16(
  sqlite3*,
  void*,
  void(*)(void*,sqlite3*,int eTextRep,const void*)
);




 int sqlite3_sleep(int);


  char *sqlite3_temp_directory;


 int sqlite3_get_autocommit(sqlite3*);


 sqlite3 *sqlite3_db_handle(sqlite3_stmt*);


 const char *sqlite3_db_filename(sqlite3 *db, const char *zDbName);

 int sqlite3_db_readonly(sqlite3 *db, const char *zDbName);


 sqlite3_stmt *sqlite3_next_stmt(sqlite3 *pDb, sqlite3_stmt *pStmt);


 void *sqlite3_commit_hook(sqlite3*, int(*)(void*), void*);
 void *sqlite3_rollback_hook(sqlite3*, void(*)(void *), void*);


 void *sqlite3_update_hook(
  sqlite3*,
  void(*)(void *,int ,char const *,char const *,sqlite3_int64),
  void*
);


 int sqlite3_enable_shared_cache(int);


 int sqlite3_release_memory(int);


 int sqlite3_db_release_memory(sqlite3*);


 sqlite3_int64 sqlite3_soft_heap_limit64(sqlite3_int64 N);


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


 int sqlite3_load_extension(
  sqlite3 *db,          /* Load the extension into this database connection */
  const char *zFile,    /* Name of the shared library containing extension */
  const char *zProc,    /* Entry point.  Derived from zFile if 0 */
  char **pzErrMsg       /* Put error message here if not 0 */
);


 int sqlite3_enable_load_extension(sqlite3 *db, int onoff);


 int sqlite3_auto_extension(void (*xEntryPoint)(void));


 void sqlite3_reset_auto_extension(void);




typedef struct sqlite3_vtab sqlite3_vtab;
typedef struct sqlite3_index_info sqlite3_index_info;
typedef struct sqlite3_vtab_cursor sqlite3_vtab_cursor;
typedef struct sqlite3_module sqlite3_module;


struct sqlite3_module {
  int iVersion;
  int (*xCreate)(sqlite3*, void *pAux,
               int argc, const char *const*argv,
               sqlite3_vtab **ppVTab, char**);
  int (*xConnect)(sqlite3*, void *pAux,
               int argc, const char *const*argv,
               sqlite3_vtab **ppVTab, char**);
  int (*xBestIndex)(sqlite3_vtab *pVTab, sqlite3_index_info*);
  int (*xDisconnect)(sqlite3_vtab *pVTab);
  int (*xDestroy)(sqlite3_vtab *pVTab);
  int (*xOpen)(sqlite3_vtab *pVTab, sqlite3_vtab_cursor **ppCursor);
  int (*xClose)(sqlite3_vtab_cursor*);
  int (*xFilter)(sqlite3_vtab_cursor*, int idxNum, const char *idxStr,
                int argc, sqlite3_value **argv);
  int (*xNext)(sqlite3_vtab_cursor*);
  int (*xEof)(sqlite3_vtab_cursor*);
  int (*xColumn)(sqlite3_vtab_cursor*, sqlite3_context*, int);
  int (*xRowid)(sqlite3_vtab_cursor*, sqlite3_int64 *pRowid);
  int (*xUpdate)(sqlite3_vtab *, int, sqlite3_value **, sqlite3_int64 *);
  int (*xBegin)(sqlite3_vtab *pVTab);
  int (*xSync)(sqlite3_vtab *pVTab);
  int (*xCommit)(sqlite3_vtab *pVTab);
  int (*xRollback)(sqlite3_vtab *pVTab);
  int (*xFindFunction)(sqlite3_vtab *pVtab, int nArg, const char *zName,
                       void (**pxFunc)(sqlite3_context*,int,sqlite3_value**),
                       void **ppArg);
  int (*xRename)(sqlite3_vtab *pVtab, const char *zNew);
  /* The methods above are in version 1 of the sqlite_module object. Those
  ** below are for version 2 and greater. */
  int (*xSavepoint)(sqlite3_vtab *pVTab, int);
  int (*xRelease)(sqlite3_vtab *pVTab, int);
  int (*xRollbackTo)(sqlite3_vtab *pVTab, int);
};


struct sqlite3_index_info {
  /* Inputs */
  int nConstraint;           /* Number of entries in aConstraint */
  struct sqlite3_index_constraint {
     int iColumn;              /* Column on left-hand side of constraint */
     unsigned char op;         /* Constraint operator */
     unsigned char usable;     /* True if this constraint is usable */
     int iTermOffset;          /* Used internally - xBestIndex should ignore */
  } *aConstraint;            /* Table of WHERE clause constraints */
  int nOrderBy;              /* Number of terms in the ORDER BY clause */
  struct sqlite3_index_orderby {
     int iColumn;              /* Column number */
     unsigned char desc;       /* True for DESC.  False for ASC. */
  } *aOrderBy;               /* The ORDER BY clause */
  /* Outputs */
  struct sqlite3_index_constraint_usage {
    int argvIndex;           /* if >0, constraint is part of argv to xFilter */
    unsigned char omit;      /* Do not code a test for this constraint */
  } *aConstraintUsage;
  int idxNum;                /* Number used to identify the index */
  char *idxStr;              /* String, possibly obtained from sqlite3_malloc */
  int needToFreeIdxStr;      /* Free idxStr using sqlite3_free() if true */
  int orderByConsumed;       /* True if output is already ordered */
  double estimatedCost;      /* Estimated cost of using this index */
};





 int sqlite3_create_module(
  sqlite3 *db,               /* SQLite connection to register module with */
  const char *zName,         /* Name of the module */
  const sqlite3_module *p,   /* Methods for the module */
  void *pClientData          /* Client data for xCreate/xConnect */
);
 int sqlite3_create_module_v2(
  sqlite3 *db,               /* SQLite connection to register module with */
  const char *zName,         /* Name of the module */
  const sqlite3_module *p,   /* Methods for the module */
  void *pClientData,         /* Client data for xCreate/xConnect */
  void(*xDestroy)(void*)     /* Module destructor function */
);


struct sqlite3_vtab {
  const sqlite3_module *pModule;  /* The module for this virtual table */
  int nRef;                       /* NO LONGER USED */
  char *zErrMsg;                  /* Error message from sqlite3_mprintf() */
  /* Virtual table implementations will typically add additional fields */
};


struct sqlite3_vtab_cursor {
  sqlite3_vtab *pVtab;      /* Virtual table of this cursor */
  /* Virtual table implementations will typically add additional fields */
};


 int sqlite3_declare_vtab(sqlite3*, const char *zSQL);


 int sqlite3_overload_function(sqlite3*, const char *zFuncName, int nArg);




typedef struct sqlite3_blob sqlite3_blob;


 int sqlite3_blob_open(
  sqlite3*,
  const char *zDb,
  const char *zTable,
  const char *zColumn,
  sqlite3_int64 iRow,
  int flags,
  sqlite3_blob **ppBlob
);


  int sqlite3_blob_reopen(sqlite3_blob *, sqlite3_int64);


 int sqlite3_blob_close(sqlite3_blob *);


 int sqlite3_blob_bytes(sqlite3_blob *);


 int sqlite3_blob_read(sqlite3_blob *, void *Z, int N, int iOffset);


 int sqlite3_blob_write(sqlite3_blob *, const void *z, int n, int iOffset);


 sqlite3_vfs *sqlite3_vfs_find(const char *zVfsName);
 int sqlite3_vfs_register(sqlite3_vfs*, int makeDflt);
 int sqlite3_vfs_unregister(sqlite3_vfs*);


 sqlite3_mutex *sqlite3_mutex_alloc(int);
 void sqlite3_mutex_free(sqlite3_mutex*);
 void sqlite3_mutex_enter(sqlite3_mutex*);
 int sqlite3_mutex_try(sqlite3_mutex*);
 void sqlite3_mutex_leave(sqlite3_mutex*);


typedef struct sqlite3_mutex_methods sqlite3_mutex_methods;
struct sqlite3_mutex_methods {
  int (*xMutexInit)(void);
  int (*xMutexEnd)(void);
  sqlite3_mutex *(*xMutexAlloc)(int);
  void (*xMutexFree)(sqlite3_mutex *);
  void (*xMutexEnter)(sqlite3_mutex *);
  int (*xMutexTry)(sqlite3_mutex *);
  void (*xMutexLeave)(sqlite3_mutex *);
  int (*xMutexHeld)(sqlite3_mutex *);
  int (*xMutexNotheld)(sqlite3_mutex *);
};





 sqlite3_mutex *sqlite3_db_mutex(sqlite3*);

 int sqlite3_file_control(sqlite3*, const char *zDbName, int op, void*);


 int sqlite3_test_control(int op, ...);



 int sqlite3_status(int op, int *pCurrent, int *pHighwater, int resetFlag);


 int sqlite3_db_status(sqlite3*, int op, int *pCur, int *pHiwtr, int resetFlg);





 int sqlite3_stmt_status(sqlite3_stmt*, int op,int resetFlg);





typedef struct sqlite3_pcache sqlite3_pcache;


typedef struct sqlite3_pcache_page sqlite3_pcache_page;
struct sqlite3_pcache_page {
  void *pBuf;        /* The content of the page */
  void *pExtra;      /* Extra information associated with the page */
};


typedef struct sqlite3_pcache_methods2 sqlite3_pcache_methods2;
struct sqlite3_pcache_methods2 {
  int iVersion;
  void *pArg;
  int (*xInit)(void*);
  void (*xShutdown)(void*);
  sqlite3_pcache *(*xCreate)(int szPage, int szExtra, int bPurgeable);
  void (*xCachesize)(sqlite3_pcache*, int nCachesize);
  int (*xPagecount)(sqlite3_pcache*);
  sqlite3_pcache_page *(*xFetch)(sqlite3_pcache*, unsigned key, int createFlag);
  void (*xUnpin)(sqlite3_pcache*, sqlite3_pcache_page*, int discard);
  void (*xRekey)(sqlite3_pcache*, sqlite3_pcache_page*,
      unsigned oldKey, unsigned newKey);
  void (*xTruncate)(sqlite3_pcache*, unsigned iLimit);
  void (*xDestroy)(sqlite3_pcache*);
  void (*xShrink)(sqlite3_pcache*);
};




typedef struct sqlite3_backup sqlite3_backup;


 sqlite3_backup *sqlite3_backup_init(
  sqlite3 *pDest,                        /* Destination database handle */
  const char *zDestName,                 /* Destination database name */
  sqlite3 *pSource,                      /* Source database handle */
  const char *zSourceName                /* Source database name */
);
 int sqlite3_backup_step(sqlite3_backup *p, int nPage);
 int sqlite3_backup_finish(sqlite3_backup *p);
 int sqlite3_backup_remaining(sqlite3_backup *p);
 int sqlite3_backup_pagecount(sqlite3_backup *p);


 int sqlite3_unlock_notify(
  sqlite3 *pBlocked,                          /* Waiting connection */
  void (*xNotify)(void **apArg, int nArg),    /* Callback function to invoke */
  void *pNotifyArg                            /* Argument to pass to xNotify */
);



 int sqlite3_stricmp(const char *, const char *);
 int sqlite3_strnicmp(const char *, const char *, int);


 void sqlite3_log(int iErrCode, const char *zFormat, ...);


 void *sqlite3_wal_hook(
  sqlite3*,
  int(*)(void *,sqlite3*,const char*,int),
  void*
);


 int sqlite3_wal_autocheckpoint(sqlite3 *db, int N);


 int sqlite3_wal_checkpoint(sqlite3 *db, const char *zDb);


 int sqlite3_wal_checkpoint_v2(
  sqlite3 *db,                    /* Database handle */
  const char *zDb,                /* Name of attached database (or NULL) */
  int eMode,                      /* SQLITE_CHECKPOINT_* value */
  int *pnLog,                     /* OUT: Size of WAL log in frames */
  int *pnCkpt                     /* OUT: Total number of frames checkpointed */
);


 int sqlite3_vtab_config(sqlite3*, int op, ...);

 int sqlite3_vtab_on_conflict(sqlite3 *);






// RTree Geometry Queries
typedef struct sqlite3_rtree_geometry sqlite3_rtree_geometry;


 int sqlite3_rtree_geometry_callback(
  sqlite3 *db,
  const char *zGeom,
  int (*xGeom)(sqlite3_rtree_geometry*, int n, double *a, int *pRes),
  void *pContext
);


struct sqlite3_rtree_geometry {
  void *pContext;
  int nParam;
  double *aParam;
  void *pUser;
  void (*xDelUser)(void *);
};
]]





