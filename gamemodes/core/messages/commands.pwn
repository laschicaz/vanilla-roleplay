/**
* # Calls
*/

public OnPlayerCommandPerformed(playerid, cmd[], params[], result, flags) {
	if (result == -1)
	{
		SendClientMessage(playerid, COLOR_ERROR, "* ¬веденной ¬ами команды не существует (/help).");
		return 0;
	}

	return 1;
}
