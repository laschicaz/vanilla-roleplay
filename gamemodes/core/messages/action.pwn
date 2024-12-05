/**
 * # Header
 */

static
    logString[150];

/**
 * # Internal
 */

static Action_SendPlayerMe(playerid, const text[144], bool:islow = false) {
	if (!IsPlayerSpawned(playerid)) {
		SendClientMessage(playerid, COLOR_ERROR, ""MESSAGE_PREFIX" ¬ы должны авторизоватьс€, прежде чем использовать чат.");
        return 0;
    }

	new 
        Float: range = 15.0, 
        color = COLOR_ACTION;

	if (islow) {
		range = 30.0;
		color = COLOR_ACTION_LOW;
	}

	format(logString, sizeof(logString), "%s", text);
	ProxDetectorEx(playerid, range, color, "*", logString);
	return 1;
}

static Action_SendPlayerDo(playerid, const text[144], bool:islow = false) {
	if (!IsPlayerSpawned(playerid)) {
		SendClientMessage(playerid, COLOR_ERROR, ""MESSAGE_PREFIX" ¬ы должны авторизоватьс€, прежде чем использовать чат.");
        return 0;
    }

	new
        Float: range = 15.0,
        color = COLOR_ACTION;

	if (islow) {
		range = 30.0;
		color = COLOR_ACTION_LOW;
	}

	ProxDetectorEx(playerid, range, color, "*", text, .inverted = true);

	return 1;
}

/**
 * # Commands
 */

CMD:me(playerid, params[]) {
	new 
        text[144];

	if (sscanf(params, "s[144]", text)) 
		return SendClientMessage(playerid, COLOR_GRAD0, ""MESSAGE_PREFIX" /me [текст]");

	Action_SendPlayerMe(playerid, text);
	return 1;
}

CMD:melow(playerid, params[]) {
	new 
        text[144];

	if (sscanf(params, "s[144]", text)) 
		return SendClientMessage(playerid, COLOR_GRAD0, ""MESSAGE_PREFIX" /melow [текст]");

	Action_SendPlayerMe(playerid, text, true);
	return 1;
}


CMD:do(playerid, params[]) {
	new 
		text[144];

	if (sscanf(params, "s[144]", text)) 
		return SendClientMessage(playerid, COLOR_GRAD0, ""MESSAGE_PREFIX" /do [текст]");


	Action_SendPlayerDo(playerid, text);
	return 1;
}

CMD:dolow(playerid, params[]) {
	new 
		text[144];

	if (sscanf(params, "s[144]", text)) 
		return SendClientMessage(playerid, COLOR_GRAD0, ""MESSAGE_PREFIX" /dolow [текст]");


	Action_SendPlayerDo(playerid, text, true);
	return 1;
}

CMD:my(playerid, params[]) {
	new 
		text[144];

	if (sscanf(params, "s[144]", text)) 
		return SendClientMessage(playerid, COLOR_GRAD0, ""MESSAGE_PREFIX" /my [текст]");

	new 
		string[256];

	format(string, sizeof(string), " %s", text);
	ProxDetectorEx(playerid, 30.0, COLOR_ACTION, ""MESSAGE_PREFIX" ”", string, .autospacing=false);

	return true;
}
