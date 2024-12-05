/**
 * # Header
 */

#include <YSI_Coding\y_hooks>

DEFINE_HOOK_REPLACEMENT(Download, Dwning);
DEFINE_HOOK_REPLACEMENT(Pickup, Pp);
DEFINE_HOOK_REPLACEMENT(Vehicle, Veh);

#if defined DEBUGGING
    hook OnPlayerConnect(playerid)
    {
        SendClientMessageToAll(COLOR_YELLOW, ""MESSAGE_PREFIX" [Отладка]: OnPlayerConnect(%d)", playerid);
        return 1;
    }

    hook OnPlayerDisconnect(playerid, reason)
    {
        SendClientMessageToAll(COLOR_YELLOW, ""MESSAGE_PREFIX" [Отладка]: OnPlayerDisconnect(%d, %d)", playerid, reason);
        return 1;
    }

    hook OnPlayerRequestClass(playerid, classid)
    {
        SendClientMessageToAll(COLOR_YELLOW, ""MESSAGE_PREFIX" [Отладка]: OnPlayerRequestClass(%d, %d)", playerid, classid);
        return 1;
    }

    hook OnPlayerSpawn(playerid)
    {
        SendClientMessageToAll(COLOR_YELLOW, ""MESSAGE_PREFIX" [Отладка]: OnPlayerSpawn(%d)", playerid);
        return 1;
    }

    hook OnPlayerDeath(playerid, killerid, WEAPON:reason)
    {
        SendClientMessageToAll(COLOR_YELLOW, ""MESSAGE_PREFIX" [Отладка]: OnPlayerDeath(%d, %d, %d)", playerid, killerid, reason);
        return 1;
    }

    hook OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
    {
        SendClientMessageToAll(COLOR_YELLOW, ""MESSAGE_PREFIX" [Отладка]: OnPlayerEnterVehicle(%d, %d, %d)", playerid, vehicleid, ispassenger);
        return 1;
    }

    hook OnPlayerExitVehicle(playerid, vehicleid)
    {
        SendClientMessageToAll(COLOR_YELLOW, ""MESSAGE_PREFIX" [Отладка]: OnPlayerExitVehicle(%d, %d)", playerid, vehicleid);
        return 1;
    }

    hook OnVehicleSpawn(vehicleid)
    {
        SendClientMessageToAll(COLOR_YELLOW, ""MESSAGE_PREFIX" [Отладка]: OnVehicleSpawn(%d)", vehicleid);
        return 1;
    }

    hook OnVehicleDeath(vehicleid, killerid)
    {
        SendClientMessageToAll(COLOR_YELLOW, ""MESSAGE_PREFIX" [Отладка]: OnVehicleDeath(%d, %d)", vehicleid, killerid);
        return 1;
    }

    /*
        ___              _      _ _    _
        / __|_ __  ___ __(_)__ _| (_)__| |_
        \__ \ '_ \/ -_) _| / _` | | (_-<  _|
        |___/ .__/\___\__|_\__,_|_|_/__/\__|
            |_|
    */

    hook OnPlayerRequestSpawn(playerid)
    {
        SendClientMessageToAll(COLOR_YELLOW, ""MESSAGE_PREFIX" [Отладка]: OnPlayerRequestSpawn(%d)", playerid);
        return 1;
    }

    hook OnPlayerCommandText(playerid, cmdtext[])
    {
        SendClientMessageToAll(COLOR_YELLOW, ""MESSAGE_PREFIX" [Отладка]: OnPlayerCommandText(%d, %s)", playerid, cmdtext);
        return 0;
    }

    hook OnPlayerText(playerid, text[])
    {
        SendClientMessageToAll(COLOR_YELLOW, ""MESSAGE_PREFIX" [Отладка]: OnPlayerText(%d, %s)", playerid, text);
        return 1;
    }

    hook OnPlayerUpdate(playerid)
    {
       // SendClientMessageToAll(COLOR_YELLOW, ""MESSAGE_PREFIX" [Отладка]: OnPlayerUpdate(%d)", playerid);
        return 1;
    }

    hook OnPlayerKeyStateChange(playerid, KEY:newkeys, KEY:oldkeys)
    {
        SendClientMessageToAll(COLOR_YELLOW, ""MESSAGE_PREFIX" [Отладка]: OnPlayerKeyStateChange(%d, %d, %d)", playerid, newkeys, oldkeys);
        return 1;
    }

    hook OnPlayerStateChange(playerid, PLAYER_STATE:newstate, PLAYER_STATE:oldstate)
    {
        return 1;
    }

    hook OnPlayerEnterCheckpoint(playerid)
    {
        return 1;
    }

    hook OnPlayerLeaveCheckpoint(playerid)
    {
        return 1;
    }

    hook OnPlayerEnterRaceCP(playerid)
    {
        return 1;
    }

    hook OnPlayerLeaveRaceCP(playerid)
    {
        return 1;
    }

    hook OnPlayerGiveDamageActor(playerid, damaged_actorid, Float:amount, WEAPON:weaponid, bodypart)
    {
        return 1;
    }

    hook OnActorStreamIn(actorid, forplayerid)
    {
        return 1;
    }

    hook OnActorStreamOut(actorid, forplayerid)
    {
        return 1;
    }

    hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
    {
        SendClientMessageToAll(COLOR_YELLOW, ""MESSAGE_PREFIX" [Отладка]: OnDialogResponse(%d, %d, %d, %d, %s)", playerid, dialogid, response, listitem, inputtext);
        return 1;
    }

    hook OnPlayerEnterGangZone(playerid, zoneid)
    {
        return 1;
    }

    hook OnPlayerLeaveGangZone(playerid, zoneid)
    {
        return 1;
    }

    hook OnPlayerEnterPlayerGZ(playerid, zoneid)
    {
        return 1;
    }

    hook OnPlayerLeavePlayerGZ(playerid, zoneid)
    {
        return 1;
    }

    hook OnPlayerClickGZ(playerid, zoneid)
    {
        return 1;
    }

    hook OnPlayerClickPlayerGZ(playerid, zoneid)
    {
        return 1;
    }

    hook OnPlayerSelectedMenuRow(playerid, row)
    {
        return 1;
    }

    hook OnPlayerExitedMenu(playerid)
    {
        return 1;
    }

    hook OnClientCheckResponse(playerid, actionid, memaddr, retndata)
    {
        return 1;
    }

    hook OnRconLoginAttempt(ip[], password[], success)
    {
        return 1;
    }

    hook OnPlayerFinishedDwning(playerid, virtualworld)
    {
        return 1;
    }

    hook OnPlayerRequestDownload(playerid, DOWNLOAD_REQUEST:type, crc)
    {
        return 1;
    }

    hook OnRconCommand(cmd[])
    {
        return 0;
    }

    hook OnPlayerSelectObject(playerid, SELECT_OBJECT:type, objectid, modelid, Float:fX, Float:fY, Float:fZ)
    {
        return 1;
    }

    hook OnPlayerEditObject(playerid, playerobject, objectid, EDIT_RESPONSE:response, Float:fX, Float:fY, Float:fZ, Float:fRotX, Float:fRotY, Float:fRotZ)
    {
        return 1;
    }

    hook OnPlayerEditAttachedObj(playerid, EDIT_RESPONSE:response, index, modelid, boneid, Float:fOffsetX, Float:fOffsetY, Float:fOffsetZ, Float:fRotX, Float:fRotY, Float:fRotZ, Float:fScaleX, Float:fScaleY, Float:fScaleZ)
    {
        return 1;
    }

    hook OnObjectMoved(objectid)
    {
        return 1;
    }

    hook OnPlayerObjectMoved(playerid, objectid)
    {
        return 1;
    }

    hook OnPlayerPickUpPickup(playerid, pickupid)
    {
        return 1;
    }

    hook OnPlayerPickUpPlayerPp(playerid, pickupid)
    {
        return 1;
    }

    hook OnPickupStreamIn(pickupid, playerid)
    {
        return 1;
    }

    hook OnPickupStreamOut(pickupid, playerid)
    {
        return 1;
    }

    hook OnPlayerPickupStreamIn(pickupid, playerid)
    {
        return 1;
    }

    hook OnPlayerPickupStreamOut(pickupid, playerid)
    {
        return 1;
    }

    hook OnPlayerStreamIn(playerid, forplayerid)
    {
        return 1;
    }

    hook OnPlayerStreamOut(playerid, forplayerid)
    {
        return 1;
    }

    hook OnPlayerTakeDamage(playerid, issuerid, Float:amount, WEAPON:weaponid, bodypart)
    {
        return 1;
    }

    hook OnPlayerGiveDamage(playerid, damagedid, Float:amount, WEAPON:weaponid, bodypart)
    {
        return 1;
    }

    hook OnPlayerClickPlayer(playerid, clickedplayerid, CLICK_SOURCE:source)
    {
        return 1;
    }

    hook OnPlayerWeaponShot(playerid, WEAPON:weaponid, BULLET_HIT_TYPE:hittype, hitid, Float:fX, Float:fY, Float:fZ)
    {
        return 1;
    }

    hook OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ)
    {
        return 1;
    }

    hook OnIncomingConnection(playerid, ip_address[], port)
    {
        return 1;
    }

    hook OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
    {
        return 1;
    }

    hook OnPlayerClickTextDraw(playerid, Text:clickedid)
    {
        return 1;
    }

    hook OnPlayerClickPlayerTD(playerid, PlayerText:playertextid)
    {
        return 1;
    }

    hook OnTrailerUpdate(playerid, vehicleid)
    {
        return 1;
    }

    hook OnVehSirenStateChange(playerid, vehicleid, newstate)
    {
        return 1;
    }

    hook OnVehicleStreamIn(vehicleid, forplayerid)
    {
        return 1;
    }

    hook OnVehicleStreamOut(vehicleid, forplayerid)
    {
        return 1;
    }

    hook OnVehicleMod(playerid, vehicleid, componentid)
    {
        return 1;
    }

    hook OnEnterExitModShop(playerid, enterexit, interiorid)
    {
        return 1;
    }

    hook OnVehiclePaintjob(playerid, vehicleid, paintjobid)
    {
        return 1;
    }

    hook OnVehicleRespray(playerid, vehicleid, color1, color2)
    {
        return 1;
    }

    hook OnVehDamageStatusUpdate(vehicleid, playerid)
    {
        return 1;
    }

    hook OnUnoccupiedVehUpdate(vehicleid, playerid, passenger_seat, Float:new_x, Float:new_y, Float:new_z, Float:vel_x, Float:vel_y, Float:vel_z)
    {
        return 1;
    }
#endif