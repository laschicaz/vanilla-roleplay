/**
 * # Header
 */
 
#include <YSI_Coding\y_hooks>

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
        return print(""MESSAGE_PREFIX" [Database] Не удалось подключиться к базе данных.\n");
	
    print(""MESSAGE_PREFIX" [Database] Успешно подключено к базе данных.");
    
    return 1;
}

hook OnGameModeExit() {
    mysql_close(handle);

    return 1;
}