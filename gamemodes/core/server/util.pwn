/**
 * # Forwards
 */

forward DelayedKickInternal(playerid);

/**
 * # External
 */

stock DelayedKick(playerid, const reason[]) {
    SendClientMessage(playerid, COLOR_ERROR, ""MESSAGE_PREFIX" %s отключил(-а) Вас от сервера по причине: %s.", GAMEMODE_NAME, reason);

    TogglePlayerSpectating(playerid, true);
    
    SetTimerEx("DelayedKickInternal", 1000, false, "i", playerid);
}

/**
 * # Calls
 */

public DelayedKickInternal(playerid) {
    Kick(playerid);

    return 1;
}