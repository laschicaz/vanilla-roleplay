/**
 * # Forwards
 */

forward DelayedKickInternal(playerid);

/**
 * # External
 */

stock DelayedKick(playerid, const reason[]) {
    SendClientMessage(playerid, -1, "You have been kicked out of the server. Reason: %s.", reason);

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