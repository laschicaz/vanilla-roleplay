/**
* # Calls
*/

public OnPlayerCommandPerformed(playerid, cmd[], params[], result, flags) {
	if (result == -1)
	{
		SendClientMessage(playerid, COLOR_ERROR, "* ��������� ���� ������� �� ���������� (/help).");
		return 0;
	}

	return 1;
}
