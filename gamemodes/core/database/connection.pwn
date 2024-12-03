#include <YSI_Coding\y_hooks>

/**
 * # Header
 */

#define INVALID_DATABASE_ID (DBID:0)

static
    MySQL:handle
;

/**
 * # External
 */

stock MySQL:MySQL_GetHandle() {
    return handle;
}

/**
 * # Hooks
 */

hook OnGameModeInit() {
    handle = mysql_connect("localhost", "root", "root", "new");

    if(mysql_errno(handle   ) != 0)
        return print("* [Database] Could not connect to database.\n");
	
    print("* [Database] Connected to database.");
    
    return 1;
}

hook OnGameModeExit() {
    mysql_close(handle);

    return 1;
}