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
    handle = mysql_connect("localhost", "root", "", "base");

    return 1;
}

hook OnGameModeExit() {
    mysql_close(handle);

    return 1;
}