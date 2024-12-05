/**
 * # Header
 */

#include <YSI_Coding\y_hooks>

/**
 * # External
 */

stock Chat_SendPlayerText(playerid, text[]) {
	if (!IsPlayerSpawned(playerid)) {
		SendClientMessage(playerid, COLOR_ERROR, ""MESSAGE_PREFIX" Вы должны авторизоваться, прежде чем использовать чат.");
		return 0;
	}
	
	new 
        string[256],
        Float:range = 15.0;

    if (GetPlayerVirtualWorld(playerid) != 0) range = 10.0; 

    format(string, sizeof(string), "говорит: %s", text);
    ProxDetectorEx(playerid, range, 0xDEDEDEFF, "", string, .showtagcolor=true, .annonated=true, .chat=true);

	return 1;
}

/**
 * # Hooks
 */

hook OnPlayerText(playerid, text[]) {
    if (!IsPlayerSpawned(playerid))
		return 0;

	Chat_SendPlayerText(playerid, text);
    return 0;
}
