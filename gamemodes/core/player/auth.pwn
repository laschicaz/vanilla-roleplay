/**
 * # Header
 */
 
#include <YSI_Coding\y_hooks>

/**
 * # Forwards
 */

forward OnPlayerRequestRegister(playerid);
forward OnPlayerRequestLogIn(playerid);

forward OnAccountCheck(playerid);

/**
 * # Hooks
 */

hook OnPlayerRequestClass(playerid, classid) {
    TogglePlayerSpectating(playerid, true);

    new
        query[256]
    ;
    
	mysql_format(MYSQL_DEFAULT_HANDLE, query, sizeof(query), "SELECT accounts.*, characters.* FROM `accounts`, `characters` WHERE (accounts.name = '%e' OR characters.name = '%e') AND accounts.id = characters.account_id", ReturnPlayerName(playerid), ReturnPlayerName(playerid));
    mysql_tquery(MYSQL_DEFAULT_HANDLE, query, "OnAccountCheck", "i", playerid);

    return 1;
}

/**
 * # Calls
 */

public OnAccountCheck(playerid) {
    if (!cache_num_rows()) {
        CallLocalFunction("OnPlayerRequestRegister", "i", playerid);
    
        return 1;
    }

    new
        DBID:id,
        name[MAX_PLAYER_NAME],
        hash[BCRYPT_HASH_LENGTH]
    ;

    cache_get_value_int(0, "id", _:id);
    cache_get_value(0, "name", name);
    cache_get_value(0, "hash", hash);

    Account_SetDatabaseID(playerid, id);
    Account_SetName(playerid, name);
    Account_SetHash(playerid, hash);

    SetPlayerName(playerid, Account_GetName(playerid));

    CallLocalFunction("OnPlayerRequestLogIn", "i", playerid);

    return 1;
}
