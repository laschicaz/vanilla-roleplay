/**
 * # Header
 */
 
#include <YSI_Coding\y_hooks>
#include <YSI_Data\y_iterate>

#define MAX_INVENTORY_OBJECTS               (150)

#define INVENTORY_NONE                      (-1)
#define INVENTORY_WEAPON 					(0)
#define INVENTORY_DISASSEMBLED 				(1)
#define INVENTORY_AMMO               		(2)
#define INVENTORY_CLOTHES 					(3)
#define INVENTORY_BUSINESS 					(4)
#define INVENTORY_PHONE              		(5)
#define INVENTORY_DRUG               		(6)
#define INVENTORY_INGREDIENT         		(7)
#define INVENTORY_PACKAGE					(8)
#define INVENTORY_OTHER		         		(9)

#define ENTITY_TYPE_CHARACTER				(1)

/**
 * # Variables
 */

enum E_INVENTORY_OBJECTS_DATA {
	E_INVENTORY_OBJECT_TYPE,
	E_INVENTORY_OBJECT_NAME[64],
	E_INVENTORY_OBJECT_MODEL,
	E_INVENTORY_OBJECT_AMOUNT_TYPE[8]
};

new 
    InventoryObjectsData[MAX_INVENTORY_OBJECTS][E_INVENTORY_OBJECTS_DATA];

new
    Iterator:InventoryObjects<MAX_INVENTORY_OBJECTS>;

/**
 * # Internal
 */

static Inventory_CreateObject(type, const name[], model, const amounttype[]) {
	new const
        id = Iter_Free(InventoryObjects);

	InventoryObjectsData[id][E_INVENTORY_OBJECT_TYPE] = type;

	format(InventoryObjectsData[id][E_INVENTORY_OBJECT_NAME], 64, name);
	format(InventoryObjectsData[id][E_INVENTORY_OBJECT_AMOUNT_TYPE], 6, amounttype);

	InventoryObjectsData[id][E_INVENTORY_OBJECT_MODEL] = model;

	Iter_Add(InventoryObjects, id);

	return id;
}

static Inventory_SetupObjects(){
    Inventory_CreateObject(INVENTORY_NONE, "Пустой слот", -1, "шт.");

    Inventory_CreateObject(INVENTORY_BUSINESS, "Пачка сигарет", 19896, "шт");
    Inventory_CreateObject(INVENTORY_BUSINESS, "Бутылка водки", 19896, "шт");

	return 1;
}

/**
 * # External
 */

stock Inventory_HasCharacterItem(playerid, const item[], type) {
	for (new i; i < MAX_CHARACTER_INVENTORY_ITEMS; i++) {
	    new 
            listid = CharacterData[playerid][Account_GetLoggedCharacter(playerid)][E_CHARACTER_INVENTORY_LIST][i];

	    if (!CharacterData[playerid][Account_GetLoggedCharacter(playerid)][E_CHARACTER_INVENTORY_LIST][i] || InventoryObjectsData[listid][E_INVENTORY_OBJECT_TYPE] != type) continue;

		if (type == INVENTORY_INGREDIENT || type == INVENTORY_PHONE) {
			if (strfind(InventoryObjectsData[listid][E_INVENTORY_OBJECT_NAME], item, true) != -1)
				return i;
		}

		if (strcmp(InventoryObjectsData[listid][E_INVENTORY_OBJECT_NAME], item, true) == 0) return i;
	}

	return -1;
}

stock Inventory_ListItemID(const name[]) {
	for (new i, is = sizeof(InventoryObjectsData); i < is; i++)
	    if (strcmp(InventoryObjectsData[i][E_INVENTORY_OBJECT_NAME], name, false) == 0) 
            return i;
	
	return -1;
}

stock Inventory_FreeSlotCount(playerid) {
	new 
		count;

	for(new i; i < MAX_CHARACTER_INVENTORY_ITEMS; i++) {
		if (!CharacterData[playerid][Account_GetLoggedCharacter(playerid)][E_CHARACTER_INVENTORY_LIST][i]) count++;
	}

	return count;
}

stock Inventory_AddCharacterItem(playerid, item, const name[], amount = 0, Float:drugAmount = 0.0, extra = 0, Float:extraAmount = 0.0) {
	new 
        listid = Inventory_ListItemID(name);

	if (listid == -1 || !amount) 
        return 1;

    new 
        type = InventoryObjectsData[listid][E_INVENTORY_OBJECT_TYPE],
        item_exists = Inventory_HasCharacterItem(playerid, InventoryObjectsData[listid][E_INVENTORY_OBJECT_NAME], type);

	if (item_exists != -1 && type == INVENTORY_DRUG)
		CharacterData[playerid][Account_GetLoggedCharacter(playerid)][E_CHARACTER_INV_DRUG_AMOUNT][item_exists] += drugAmount + 0.000001;

	if (item_exists != -1 && type != INVENTORY_WEAPON && type != INVENTORY_CLOTHES && type != INVENTORY_PHONE && type != INVENTORY_OTHER && type != INVENTORY_PACKAGE)
		CharacterData[playerid][Account_GetLoggedCharacter(playerid)][E_CHARACTER_INVENTORY_AMOUNT][item_exists] += amount;
	else {
	    CharacterData[playerid][Account_GetLoggedCharacter(playerid)][E_CHARACTER_INVENTORY_LIST][item] = listid;

		if (type == INVENTORY_DRUG)
			CharacterData[playerid][Account_GetLoggedCharacter(playerid)][E_CHARACTER_INV_DRUG_AMOUNT][item] += drugAmount + 0.000001;
		else
        	CharacterData[playerid][Account_GetLoggedCharacter(playerid)][E_CHARACTER_INVENTORY_AMOUNT][item] += amount;

		CharacterData[playerid][Account_GetLoggedCharacter(playerid)][E_CHARACTER_INVENTORY_EXTRA][item] = extra;
		CharacterData[playerid][Account_GetLoggedCharacter(playerid)][E_CHARACTER_INV_EXTRA_AMOUNT][item] = extraAmount;
		//CharacterData[playerid][Account_GetLoggedCharacter(playerid)][pInvCredit][item] = (type == ITEM_PHONE) ? extra : 0;
	}

	CharacterData[playerid][Account_GetLoggedCharacter(playerid)][E_CHARACTER_INVENTORY_ITEM] = -1;

	return (CharacterData[playerid][Account_GetLoggedCharacter(playerid)][E_CHARACTER_INVENTORY_LIST][item]) ? item : item_exists;
}

stock Inventory_DecraseCharacterItem(playerid, item, amount = 1, Float:drugAmount = 1.0) {
	new 
		id = CharacterData[playerid][Account_GetLoggedCharacter(playerid)][E_CHARACTER_INVENTORY_LIST][item],
		type = InventoryObjectsData[id][E_INVENTORY_OBJECT_TYPE];

	drugAmount -= 0.000010;
	
	if (type == INVENTORY_DRUG) {
		CharacterData[playerid][Account_GetLoggedCharacter(playerid)][E_CHARACTER_INV_DRUG_AMOUNT][item] -= drugAmount;

		if (CharacterData[playerid][Account_GetLoggedCharacter(playerid)][E_CHARACTER_INV_DRUG_AMOUNT][item] < 0.1) {
			CharacterData[playerid][Account_GetLoggedCharacter(playerid)][E_CHARACTER_INVENTORY_LIST][item] = 0;
			CharacterData[playerid][Account_GetLoggedCharacter(playerid)][E_CHARACTER_INV_DRUG_AMOUNT][item] = 0.0;
			CharacterData[playerid][Account_GetLoggedCharacter(playerid)][E_CHARACTER_INVENTORY_EXTRA][item] = 0;
			
			//CharacterData[playerid][Account_GetLoggedCharacter(playerid)][InvCredit][itemid] = 0;
		}
	}
	else {
		CharacterData[playerid][Account_GetLoggedCharacter(playerid)][E_CHARACTER_INVENTORY_AMOUNT][item] -= amount;

		if (CharacterData[playerid][Account_GetLoggedCharacter(playerid)][E_CHARACTER_INVENTORY_AMOUNT][item] <= 0) {
			CharacterData[playerid][Account_GetLoggedCharacter(playerid)][E_CHARACTER_INVENTORY_LIST][item] = 0;
			CharacterData[playerid][Account_GetLoggedCharacter(playerid)][E_CHARACTER_INVENTORY_AMOUNT][item] = 0;
			CharacterData[playerid][Account_GetLoggedCharacter(playerid)][E_CHARACTER_INVENTORY_EXTRA][item] = 0;
		
			//CharacterData[playerid][Account_GetLoggedCharacter(playerid)][InvCredit][itemid] = 0;
		}
	}
	
    CharacterData[playerid][Account_GetLoggedCharacter(playerid)][E_CHARACTER_INVENTORY_ITEM] = -1;
	
	return 1;
}

stock Inventory_FreeCharacterID(playerid) {
	for (new x; x < MAX_CHARACTER_INVENTORY_ITEMS; x++) {
		if (!CharacterData[playerid][Account_GetLoggedCharacter(playerid)][E_CHARACTER_INVENTORY_LIST][x])
			return x;
	}

	return -1;
}

stock Inventory_UseCharacterItem(playerid, itemid) {
	new 
		list = CharacterData[playerid][Account_GetLoggedCharacter(playerid)][E_CHARACTER_INVENTORY_LIST][itemid],
		type = InventoryObjectsData[list][E_INVENTORY_OBJECT_TYPE];

	switch (type) {
		case INVENTORY_BUSINESS: {
			if (!strcmp(InventoryObjectsData[list][E_INVENTORY_OBJECT_NAME], "Пачка сигарет", false)) {

				// if(CharacterData[playerid][Account_GetLoggedCharacter(playerid)][Smoking] && CharacterData[playerid][Account_GetLoggedCharacter(playerid)][SmokingThrows]) return
				//     SendClientMessage(playerid, COLOR_ERROR, ""MESSAGE_PREFIX" Вы уже курите.");

				// if(CharacterData[playerid][Account_GetLoggedCharacter(playerid)][Drinking])
				// 	return SendClientMessage(playerid, COLOR_ERROR, ""MESSAGE_PREFIX" Вы уже пьете.");
				
				SetPlayerAttachedObject(playerid, 1, 3027, 6, 0.0852, 0.0303, 0.0194, 88.7970, 53.3082, 162.5791);
				SetPlayerAttachedObject(playerid, 2, 18673, 6, 0.1570, -0.0588, -1.6079, 0.0000, 0.0000, 0.0000, 1.0000, 1.0000, 1.0000);

				///ApplyAnimation(playerid, "SMOKING", "M_smk_in", 4.1, 0, 0, 0, 0, 0, 0);
 	  			SendClientMessage(playerid, COLOR_YELLOW, ""MESSAGE_PREFIX" Вы использовали предмет \"%s\" из своего инвентаря (-1).", InventoryObjectsData[list][E_INVENTORY_OBJECT_NAME]);

				// CharacterData[playerid][Account_GetLoggedCharacter(playerid)][Smoking] = 1;
				// CharacterData[playerid][Account_GetLoggedCharacter(playerid)][SmokingThrows] = 8;
				// CharacterData[playerid][Account_GetLoggedCharacter(playerid)][SmokingType] = SMOKING_TYPE_CIGARETTE;
				return Inventory_DecraseCharacterItem(playerid, itemid);
			}
		}
	}

	CharacterData[playerid][Account_GetLoggedCharacter(playerid)][E_CHARACTER_INVENTORY_AMOUNT][itemid] = 0;
	CharacterData[playerid][Account_GetLoggedCharacter(playerid)][E_CHARACTER_INVENTORY_LIST][itemid] = 0;
	CharacterData[playerid][Account_GetLoggedCharacter(playerid)][E_CHARACTER_INVENTORY_ITEM] = -1;

	return 1;
}

stock Inventory_ReturnString(playerid, entity, slot, amount = 0, Float:drugAmount = 0.0, dialog = 0) {
	new 
		item,
	    extra_value, 
		Float:extra_amount_value;
		
	if (entity == ENTITY_TYPE_CHARACTER) {
	    item = CharacterData[playerid][Account_GetLoggedCharacter(playerid)][E_CHARACTER_INVENTORY_LIST][slot];

		if (InventoryObjectsData[item][E_INVENTORY_OBJECT_TYPE] == INVENTORY_DRUG) {
			if (!drugAmount)
				drugAmount = CharacterData[playerid][Account_GetLoggedCharacter(playerid)][E_CHARACTER_INV_DRUG_AMOUNT][slot];
		} 
		else {
			if (!amount) 
				amount = CharacterData[playerid][Account_GetLoggedCharacter(playerid)][E_CHARACTER_INVENTORY_AMOUNT][slot];
		}

	    extra_value = CharacterData[playerid][Account_GetLoggedCharacter(playerid)][E_CHARACTER_INVENTORY_EXTRA][slot];
	    extra_amount_value = CharacterData[playerid][Account_GetLoggedCharacter(playerid)][E_CHARACTER_INV_EXTRA_AMOUNT][slot];
	}

	new 
		type = InventoryObjectsData[item][E_INVENTORY_OBJECT_TYPE],
		string[90];

	// if(extra_value && (type == ITEM_DRUG || type == ITEM_PHONE) && item)
	// {
	//     format(string, sizeof(string), (type == ITEM_DRUG) ? ("%d%s") : ("$%d"), extra_value, "%");
	// 	format(string, sizeof(string), " (%s: %s)", (type == ITEM_DRUG) ? ("качество") : ("баланс"), string);
	// }
	
	if (dialog) {
		if(type == INVENTORY_DRUG)
			format(string, sizeof(string), "%s\t%.1f %s%s", InventoryObjectsData[item][E_INVENTORY_OBJECT_NAME], drugAmount, InventoryObjectsData[item][E_INVENTORY_OBJECT_AMOUNT_TYPE], string);
		else if(type == INVENTORY_PACKAGE && extra_value && extra_amount_value)
			format(string, sizeof(string), "%s\t%d %s (внутри: %s - %.1f %s)%s", InventoryObjectsData[item][E_INVENTORY_OBJECT_NAME], amount, InventoryObjectsData[item][E_INVENTORY_OBJECT_AMOUNT_TYPE], InventoryObjectsData[extra_value][E_INVENTORY_OBJECT_NAME], extra_amount_value, InventoryObjectsData[extra_value][E_INVENTORY_OBJECT_AMOUNT_TYPE], string);
		else
		format(string, sizeof(string), "%s в кол-ве %d %s.%s", InventoryObjectsData[item][E_INVENTORY_OBJECT_NAME], amount, InventoryObjectsData[item][E_INVENTORY_OBJECT_AMOUNT_TYPE], string);
	}
	// else
	// {
	// 	if(type == ITEM_DRUG)
	// 		format(string, sizeof(string), "%s (%.1f %s)%s", InventoryObjectsData[item][E_INVENTORY_OBJECT_NAME], drugAmount, InventoryObjectsData[item][E_INVENTORY_OBJECT_AMOUNT_TYPE], string);
	// 	else
	// 		format(string, sizeof(string), "%s (%d %s)%s", InventoryObjectsData[item][E_INVENTORY_OBJECT_NAME], amount, InventoryObjectsData[item][E_INVENTORY_OBJECT_AMOUNT_TYPE], string);
	// }

	return string;
}


/**
 * # Hooks
 */

hook OnGameModeInit() {
    Inventory_SetupObjects();

    return 1;
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
    switch (dialogid) {	
		case DIALOG_CHARACTER_INVENTORY: {
			if (!response) return 1;
			if (!listitem) return pc_cmd_inventory(playerid, "");

			new 
				caption[32];
				
			format(caption, sizeof(caption), InventoryObjectsData[CharacterData[playerid][Account_GetLoggedCharacter(playerid)][E_CHARACTER_INVENTORY_LIST][listitem - 1]][E_INVENTORY_OBJECT_NAME]);

			CharacterData[playerid][Account_GetLoggedCharacter(playerid)][E_CHARACTER_CURRENT_INV_LIST] = listitem;

			ShowPlayerDialog(playerid, DIALOG_CHARACTER_INV_OPTIONS, DIALOG_STYLE_LIST, caption, "Использовать предмет\nУдалить предмет", "Выбрать", "Отменить");
		}
		case DIALOG_CHARACTER_INV_OPTIONS: {
			if (!response) return pc_cmd_inventory(playerid, "");

			new 
				slot = CharacterData[playerid][Account_GetLoggedCharacter(playerid)][E_CHARACTER_CURRENT_INV_LIST],
				params[24];
				
			switch (listitem) {
				case 0: {
					format(params, sizeof(params), "%d use", slot);
					pc_cmd_inventory(playerid, params);
				}
			}
		}
	}
	return 1;
}

/**
 * # Commands
 */

CMD:inventorylist(playerid, params[]) {
    foreach (new i: InventoryObjects)
        SendClientMessage(playerid, COLOR_CLIENT, ""MESSAGE_PREFIX" [Отладка]: Тип: %d, Название: %s, Модель: %d, Тип количества: %s.", \
        InventoryObjectsData[i][E_INVENTORY_OBJECT_TYPE], InventoryObjectsData[i][E_INVENTORY_OBJECT_NAME], InventoryObjectsData[i][E_INVENTORY_OBJECT_MODEL],\
        InventoryObjectsData[i][E_INVENTORY_OBJECT_AMOUNT_TYPE]);

    return 1;
}

CMD:useitem(playerid, params[]) {
	new
		slot;

	if (sscanf(params, "d", slot)) return
		SendClientMessage(playerid, COLOR_GRAD0, ""MESSAGE_PREFIX" /useitem [слот]");

	if (!CharacterData[playerid][Account_GetLoggedCharacter(playerid)][E_CHARACTER_INVENTORY_LIST][slot]) return
		SendClientMessage(playerid, COLOR_ERROR, ""MESSAGE_PREFIX" Выбранный Вами слот пустой.");

	CharacterData[playerid][Account_GetLoggedCharacter(playerid)][E_CHARACTER_INVENTORY_ITEM] = slot;

	Inventory_UseCharacterItem(playerid, slot);
	return 1;
}

CMD:giveitem(playerid, params[]) {
	new 
        id, 
        name[32], 
        amount;

	if(sscanf(params, "uds[32]", id, amount, name)) return
		SendClientMessage(playerid, COLOR_GRAD0, ""MESSAGE_PREFIX" /giveitem [id / никнейм] [количество] [предмет]");

	if(isnull(name) || strlen(name) > 32) return
		SendClientMessage(playerid, COLOR_ERROR, ""MESSAGE_PREFIX" Вы ввели несуществующее название предмета.");


	Inventory_AddCharacterItem(id, Inventory_FreeCharacterID(id), name, amount);

	SendClientMessage(id, COLOR_GREEN, ""MESSAGE_PREFIX" %s выдал(-а) Вам предмет \"%s\" (%d шт).", Account_GetName(playerid), name, amount);
	SendClientMessage(playerid, COLOR_WHITE, ""MESSAGE_PREFIX" Вы выдали %s (%d) предмет \"%s\" (%d шт).", Character_GetName(id), id, name, amount);
	
	return 1;
}

CMD:returnvalue(playerid, params[])
	return SendClientMessage(playerid, COLOR_CLIENT, ""MESSAGE_PREFIX" [Отладка]: E_CHARACTER_INVENTORY_ITEM = %d", CharacterData[playerid][Account_GetLoggedCharacter(playerid)][E_CHARACTER_INVENTORY_ITEM]);

CMD:inventory(playerid, params[])
{
	// if(CharacterData[playerid][Account_GetLoggedCharacter(playerid)][Death]) return
	// 	SendClientMessage(playerid, COLOR_ERROR, ""MESSAGE_PREFIX" В данный момент Вы не можете использовать эту команду.");
		
    new
		slot,
		option[24], 
		secoption[24], 
		type, 
		listid, 
		id;

	if (sscanf(params, "ds[24]S()[24]", slot, option, secoption)) {
	    new 
			string[1024],
			caption[16 + MAX_PLAYER_NAME];

		strcat(caption, "Инвентарь ");
		strcat(caption, Character_GetName(playerid));
		format(string, sizeof(string), "%sНаличные в кол-ве $%d\n", string, Character_GetMoney(playerid));

		for (new i; i < MAX_CHARACTER_INVENTORY_ITEMS; i++) {
			if (CharacterData[playerid][Account_GetLoggedCharacter(playerid)][E_CHARACTER_INVENTORY_LIST][i])
				format(string, sizeof(string), "%s%s\n", string, Inventory_ReturnString(playerid, ENTITY_TYPE_CHARACTER, i, 0, 0.0, 1));
		}
		
		ShowPlayerDialog(playerid, DIALOG_CHARACTER_INVENTORY, DIALOG_STYLE_LIST, caption, string, "Выбрать", "Отменить");
		return 1;
	}

	slot--;

	if (slot < 0 || slot >= MAX_CHARACTER_INVENTORY_ITEMS) return
	    SendClientMessage(playerid, COLOR_ERROR, ""MESSAGE_PREFIX" Выбранный Вами слот не существует. (1 - 10)");

	listid = CharacterData[playerid][Account_GetLoggedCharacter(playerid)][E_CHARACTER_INVENTORY_LIST][slot];
    type = InventoryObjectsData[listid][E_INVENTORY_OBJECT_TYPE];

	new 
		amount, 
		Float:drugAmount;

	if (!strcmp(option, "use", true)) {
 		if (!CharacterData[playerid][Account_GetLoggedCharacter(playerid)][E_CHARACTER_INVENTORY_LIST][slot]) return
			SendClientMessage(playerid, COLOR_ERROR, ""MESSAGE_PREFIX" Выбранный Вами слот пустой.");

        CharacterData[playerid][Account_GetLoggedCharacter(playerid)][E_CHARACTER_INVENTORY_ITEM] = slot;
		return Inventory_UseCharacterItem(playerid, slot);
	}

	// if(CharacterData[playerid][Account_GetLoggedCharacter(playerid)][FactionDuty]) return
	// 	SendFormattedMessage(playerid, COLOR_ERROR, CANT_USE_ONDUTY);

	// if (!strcmp(option, "drop", true))
	// {
 	// 	if (!CharacterData[playerid][Account_GetLoggedCharacter(playerid)][E_CHARACTER_INVENTORY_LIST][slot])return
	// 		SendClientMessage(playerid, COLOR_ERROR, ""MESSAGE_PREFIX" Выбранный Вами слот пустой.");

   	// 	if (InventoryObjects[listid][invObject] == 18911 && CharacterData[playerid][Account_GetLoggedCharacter(playerid)][Masked])
	// 		ToggleMask(playerid);

	// 	if(IsPlayerInAnyVehicle(playerid) > 0) return
	// 		SendClientMessage(playerid, COLOR_ERROR, ""MESSAGE_PREFIX" Вы не можете использовать эту функцию внутри транспортного средства.");

	// 	if(gettime() < CharacterData[playerid][Account_GetLoggedCharacter(playerid)][GiveTime])return
	// 		SendFormattedMessage(playerid, COLOR_ERROR, CANT_USE_WAIT);

	// 	CharacterData[playerid][Account_GetLoggedCharacter(playerid)][GiveTime] = gettime()+3;

	// 	if(type == ITEM_DRUG) SendFormattedMessage(playerid, COLOR_GREEN, "> Вы выбросили \"%s\" (%.1f %s) на зелмю.", InventoryObjectsData[listid][E_INVENTORY_OBJECT_NAME], CharacterData[playerid][E_CHARACTER_INV_DRUG_AMOUNT][slot], InventoryObjects[listid][E_INVENTORY_OBJECT_AMOUNT_TYPE]);
	// 	else SendFormattedMessage(playerid, COLOR_GREEN, "> Вы выбросили \"%s\" (%d %s) на землю.", InventoryObjectsData[listid][E_INVENTORY_OBJECT_NAME], (type == ITEM_WEAPON ||
	// 		type == ITEM_CLOTHES ||
	// 		type == ITEM_PHONE ||
	// 		type == ITEM_AMMO ||
	// 		type == ITEM_INGREDIENT ||
	// 		type == ITEM_OTHER) ?
	// 		CharacterData[playerid][E_CHARACTER_INVENTORY_AMOUNT][slot] : 1, InventoryObjects[listid][E_INVENTORY_OBJECT_AMOUNT_TYPE]);

    //     CharacterData[playerid][Account_GetLoggedCharacter(playerid)][ItemID] = slot;
	// 	Item_Drop(playerid, slot);

	// 	Log(playerid, "/inv drop", -1, listid, -1);
	// }
	else if (!strcmp(option, "remove", true)) {
 		if (!CharacterData[playerid][Account_GetLoggedCharacter(playerid)][E_CHARACTER_INVENTORY_LIST][slot]) return
			SendClientMessage(playerid, COLOR_ERROR, ""MESSAGE_PREFIX" Выбранный Вами слот пустой.");

		// if (gettime() < CharacterData[playerid][Account_GetLoggedCharacter(playerid)][GiveTime])return
		// 	SendFormattedMessage(playerid, COLOR_ERROR, CANT_USE_WAIT);

		// CharacterData[playerid][Account_GetLoggedCharacter(playerid)][GiveTime] = gettime()+3;

		if (type == INVENTORY_DRUG) {
			SendClientMessage(playerid, COLOR_GREEN, ""MESSAGE_PREFIX" Вы удалили \"%s\" (%.1f %s) из своего инвентаря.", InventoryObjectsData[listid][E_INVENTORY_OBJECT_NAME], CharacterData[playerid][Account_GetLoggedCharacter(playerid)][E_CHARACTER_INV_DRUG_AMOUNT][slot], InventoryObjectsData[listid][E_INVENTORY_OBJECT_AMOUNT_TYPE]);
			//Log(playerid, "/inv remove", -1, listid, CharacterData[playerid][E_CHARACTER_INVENTORY_AMOUNT][slot]);
			Inventory_DecraseCharacterItem(playerid, slot, 0, CharacterData[playerid][Account_GetLoggedCharacter(playerid)][E_CHARACTER_INV_DRUG_AMOUNT][slot]);	
		}
		else
		{
			SendClientMessage(playerid, COLOR_GREEN, "> Вы удалили \"%s\" (%d %s) из своего инвентаря.", InventoryObjectsData[listid][E_INVENTORY_OBJECT_NAME], CharacterData[playerid][Account_GetLoggedCharacter(playerid)][E_CHARACTER_INVENTORY_AMOUNT][slot], InventoryObjectsData[listid][E_INVENTORY_OBJECT_AMOUNT_TYPE]);
			//Log(playerid, "/inv remove", -1, listid, CharacterData[playerid][E_CHARACTER_INVENTORY_AMOUNT][slot]);
			Inventory_DecraseCharacterItem(playerid, slot, CharacterData[playerid][Account_GetLoggedCharacter(playerid)][E_CHARACTER_INVENTORY_AMOUNT][slot]);
		}
	}
	// else if(!strcmp(option, "give", true))
	// {
 	// 	if(!CharacterData[playerid][Account_GetLoggedCharacter(playerid)][E_CHARACTER_INVENTORY_LIST][slot]) return
	// 		SendClientMessage(playerid, COLOR_ERROR, ""MESSAGE_PREFIX" Выбранный Вами слот пустой.");

	// 	if(CharacterData[playerid][Account_GetLoggedCharacter(playerid)][E_CHARACTER_GIVE_ITEM] != -1) return
	// 		SendClientMessage(playerid, COLOR_ERROR, ""MESSAGE_PREFIX" Вы уже отправили запрос на передачу предмета.", slot + 1);

	// 	if(gettime() < CharacterData[playerid][Account_GetLoggedCharacter(playerid)][E_CHARACTER_GIVE_TIME])return
	// 		SendFormattedMessage(playerid, COLOR_ERROR, CANT_USE_WAIT);

	// 	if(type == ITEM_DRUG)
	// 	{
	// 		if(sscanf(secoption, "df", id, drugAmount))return	
	// 			SendFormattedMessage(playerid, COLOR_GREY, "> (/inv)entory <%d> <give> <id игрока> <количество>", slot + 1, id);

	// 		if(id == -1)return 
	// 			SendFormattedMessage(playerid, COLOR_GREY, "> (/inv)entory <%d> <give> <id игрока> <количество>", slot + 1);
			
	// 		if(!IsPlayerConnected(id) || id == playerid) return
	// 			SendFormattedMessage(playerid, COLOR_ERROR, INV_P_ID);

	// 		if(!ProxDetectorS(5.0, playerid, id)) return
	// 			SendFormattedMessage(playerid, COLOR_ERROR, NO_RANGE_P);

	// 		if(drugAmount < 0.1) return
   	// 			SendFormattedMessage(playerid, COLOR_GREY, "> (/inv)entory <%d> <give> <%d> <количество>", slot + 1, id);

	// 		if(drugAmount > CharacterData[playerid][Account_GetLoggedCharacter(playerid)][E_CHARACTER_INV_DRUG_AMOUNT][slot] || drugAmount < 0.1)return
   	// 			SendClientMessage(playerid, COLOR_ERROR, ""MESSAGE_PREFIX" Вы ввели неверное количество.");

	// 		drugAmount += 0.000001;

	// 		CharacterData[playerid][Account_GetLoggedCharacter(playerid)][E_CHARACTER_GIVE_DRUG_AMOUNT] = drugAmount;

	// 		if(CharacterData[playerid][Account_GetLoggedCharacter(playerid)][E_CHARACTER_GIVE_DRUG_AMOUNT] <= 0.0) return
	// 			SendFormattedMessage(playerid, COLOR_GREY, "> (/inv)entory <%d> <give> <%d> <количество>", slot + 1, id);

	// 		if(CharacterData[playerid][Account_GetLoggedCharacter(playerid)][E_CHARACTER_GIVE_DRUG_AMOUNT] > CharacterData[playerid][E_CHARACTER_INV_DRUG_AMOUNT][slot] || CharacterData[playerid][Account_GetLoggedCharacter(playerid)][GiveDrugAmount] <= 0.0) return
	// 			SendClientMessage(playerid, COLOR_ERROR, ""MESSAGE_PREFIX" Вы ввели неверное количество.");
	// 	}
	// 	else
	// 	{
	// 		if(sscanf(secoption, "dd", id, amount))return	
	// 			SendFormattedMessage(playerid, COLOR_GREY, "> (/inv)entory <%d> <give> <id игрока> <количество>", slot + 1, id);

	// 		if(id == -1)return 
	// 			SendFormattedMessage(playerid, COLOR_GREY, "> (/inv)entory <%d> <give> <id игрока> <количество>", slot + 1);
			
	// 		if(!IsPlayerConnected(id) || id == playerid) return
	// 			SendFormattedMessage(playerid, COLOR_ERROR, INV_P_ID);

	// 		if(!ProxDetectorS(5.0, playerid, id)) return
	// 			SendFormattedMessage(playerid, COLOR_ERROR, NO_RANGE_P);

	// 		if(type == ITEM_WEAPON || type == ITEM_CLOTHES || type == ITEM_PHONE || type == ITEM_OTHER) CharacterData[playerid][Account_GetLoggedCharacter(playerid)][GiveAmount] = CharacterData[playerid][E_CHARACTER_INVENTORY_AMOUNT][slot];
	// 		else
	// 		{
	// 			if(amount <= 0) return
	// 				SendFormattedMessage(playerid, COLOR_GREY, "> (/inv)entory <%d> <give> <%d> <количество>", slot + 1, id);

	// 			if(amount > CharacterData[playerid][E_CHARACTER_INVENTORY_AMOUNT][slot] || amount <= 0) return
	// 				SendClientMessage(playerid, COLOR_ERROR, ""MESSAGE_PREFIX" Вы ввели неверное количество.");

	// 			CharacterData[playerid][Account_GetLoggedCharacter(playerid)][GiveAmount] = amount;
	// 		}

	// 		if(CharacterData[playerid][Account_GetLoggedCharacter(playerid)][GiveAmount] <= 0) return
	// 			SendFormattedMessage(playerid, COLOR_GREY, "> (/inv)entory <%d> <give> <%d> <количество>", slot + 1, id);

	// 		if(CharacterData[playerid][Account_GetLoggedCharacter(playerid)][GiveAmount] > CharacterData[playerid][E_CHARACTER_INVENTORY_AMOUNT][slot] || CharacterData[playerid][Account_GetLoggedCharacter(playerid)][GiveAmount] <= 0) return
	// 			SendClientMessage(playerid, COLOR_ERROR, ""MESSAGE_PREFIX" Вы ввели неверное количество.");
	// 	}

	// 	if(CharacterData[playerid][Account_GetLoggedCharacter(playerid)][Mobile] != -1 && id == CharacterData[playerid][Account_GetLoggedCharacter(playerid)][PhoneID])
	//         Phone_HangupCall(playerid);

    //     CharacterData[playerid][Account_GetLoggedCharacter(playerid)][GiveTime] = gettime() + 2;
    //     CharacterData[playerid][Account_GetLoggedCharacter(playerid)][ItemID] = slot;
	// 	CharacterData[playerid][Account_GetLoggedCharacter(playerid)][GiveItem] = id;
	// 	CharacterData[id][pGiveItem] = playerid;

	// 	if(type == ITEM_DRUG)
	// 	{
	// 		SendFormattedMessage(id, COLOR_GREEN, "> %s отправил(-а) Вам запрос на передачу \"%s\".", ReturnRoleplayName(playerid), Inventory_ReturnString(playerid, ENTITY_TYPE_PLAYER, slot, 0, CharacterData[playerid][Account_GetLoggedCharacter(playerid)][GiveDrugAmount]));
	// 		SendFormattedMessage(playerid, COLOR_WHITE, "> Вы отправили %s запрос на передачу предмета \"%s\".", ReturnRoleplayName(id), Inventory_ReturnString(playerid, ENTITY_TYPE_PLAYER, slot, 0, CharacterData[playerid][Account_GetLoggedCharacter(playerid)][GiveDrugAmount]));
	// 	}
	// 	else
	// 	{
	// 		SendFormattedMessage(id, COLOR_GREEN, "> %s отправил(-а) Вам запрос на передачу \"%s\".", ReturnRoleplayName(playerid), Inventory_ReturnString(playerid, ENTITY_TYPE_PLAYER, slot, CharacterData[playerid][Account_GetLoggedCharacter(playerid)][GiveAmount]));
	// 		SendFormattedMessage(playerid, COLOR_WHITE, "> Вы отправили %s запрос на передачу предмета \"%s\".", ReturnRoleplayName(id), Inventory_ReturnString(playerid, ENTITY_TYPE_PLAYER, slot, CharacterData[playerid][Account_GetLoggedCharacter(playerid)][GiveAmount]));
	// 	}

	// 	SendFormattedMessage(id, COLOR_WHITE, "> Используйте команду \"/accept item\" чтобы подтвердить.");
	// }
	// else if(!strcmp(option, "cancel", true))
	// {
 	// 	id = CharacterData[playerid][Account_GetLoggedCharacter(playerid)][GiveItem];

	// 	if(id == -1) return
	// 		SendClientMessage(playerid, COLOR_ERROR, ""MESSAGE_PREFIX" Вы не имеете активных запросов на передачу предмета.");

	// 	if(CharacterData[playerid][Account_GetLoggedCharacter(playerid)][ItemID] != slot) return
	// 	    SendClientMessage(playerid, COLOR_ERROR, ""MESSAGE_PREFIX" Вы выбрали не тот слот, что участвует в запросе на передачу.");

	// 	if(IsPlayerConnected(id) && CharacterData[id][pGiveItem] == playerid)
	// 	{
	// 		SendFormattedMessage(id, COLOR_ERROR, "> %s отменил(-а) запрос на передачу предмета.", ReturnRoleplayName(playerid));
	// 		CharacterData[id][pGiveAmount] = 0;
	// 		CharacterData[id][pGiveItem] = -1;
	// 	}

	// 	if(gettime() < CharacterData[playerid][Account_GetLoggedCharacter(playerid)][GiveTime])return
	// 		SendFormattedMessage(playerid, COLOR_ERROR, CANT_USE_WAIT);

	// 	CharacterData[playerid][Account_GetLoggedCharacter(playerid)][GiveTime] = gettime()+3;

	// 	SendFormattedMessage(playerid, COLOR_GREEN, "> Вы отменили последний запрос на передачу предмета.");

	// 	CharacterData[playerid][Account_GetLoggedCharacter(playerid)][ItemID] = -1;
	// 	CharacterData[playerid][Account_GetLoggedCharacter(playerid)][GiveItem] = -1;
	// }
	// else if(!strcmp(option, "put", true))
	// {
 	// 	if(CharacterData[playerid][Account_GetLoggedCharacter(playerid)][E_CHARACTER_INVENTORY_LIST][slot]) return
	// 		SendClientMessage(playerid, COLOR_ERROR, ""MESSAGE_PREFIX" Выбранный Вами слот уже занят другим предметом.");
			
	// 	if(sscanf(secoption, "d", id))
	// 	{
	// 		SendFormattedMessage(playerid, COLOR_GREY, "> (/inv)entory <%d> <put> <тип>", slot + 1);
	// 		return SendFormattedMessage(playerid, COLOR_GREY, "> [ТИПЫ] 1: Оружие, 2: Оружие и патроны (разделить), 3: Одежда.");
	// 	}

	// 	if(id < 1 || id > 3) return
	// 	    SendFormattedMessage(playerid, COLOR_ERROR, ""INV_PARAM" (1 - 3)");

	// 	new weaponid = AC_GetPlayerWeapon(playerid);
	// 	new ammo = AC_GetPlayerAmmo(playerid);

	// 	if(gettime() < CharacterData[playerid][Account_GetLoggedCharacter(playerid)][GiveTime])return
	// 		SendFormattedMessage(playerid, COLOR_ERROR, CANT_USE_WAIT);

	// 	CharacterData[playerid][Account_GetLoggedCharacter(playerid)][GiveTime] = gettime()+3;

	// 	switch(id)
	// 	{
	// 	    case 1:
	// 	    {
	// 	        if(!weaponid) return
	// 	            SendClientMessage(playerid, COLOR_ERROR, ""MESSAGE_PREFIX" Вы должны держать оружие в руках.");

	// 			if(Inventory_FreeID(playerid) == -1) return
	// 			    SendFormattedMessage(playerid, COLOR_ERROR, INVENTORY_NO_SLOTS);

	// 			CharacterData[playerid][Account_GetLoggedCharacter(playerid)][ItemID] = slot;

	// 			slot = Inventory_AddItem(playerid, slot, WeaponInfo[weaponid][wName], ammo);
	// 			amount = ammo;

	// 			AC_RemovePlayerWeapon(playerid, weaponid);
	// 			Log(playerid, "/inv put", -1, weaponid);
	// 		}
	// 		case 2:
	// 		{
	// 			if(!weaponid) return
	// 				SendClientMessage(playerid, COLOR_ERROR, ""MESSAGE_PREFIX" Вы должны держать оружие в руках.");

	// 			if(Inventory_FreeSlotCount(playerid) < 2 || Inventory_FreeID(playerid) == -1)return
	// 				SendClientMessage(playerid, COLOR_ERROR, ""MESSAGE_PREFIX" В инвентаре недостаточно места. Требуется два слота, для оружия и патрон.");

	// 			if(WeaponInfo[weaponid][wOriginallyID] < 22 || WeaponInfo[weaponid][wOriginallyID] > 34) return
	// 				SendClientMessage(playerid, COLOR_ERROR, ""MESSAGE_PREFIX" Оружие, которое Вы держите в руках, невозможно разобрать.");

	// 			CharacterData[playerid][Account_GetLoggedCharacter(playerid)][ItemID] = slot;

	// 			slot = Inventory_AddItem(playerid, slot, Weapon_GetNameEx(weaponid, true), 1); amount++;
	// 			Inventory_AddItem(playerid, Inventory_FreeID(playerid), Weapon_GetAmmoName(weaponid), ammo);

	// 			AC_ResetPlayerWeapons(playerid);
	// 			Log(playerid, "/inv put", -1, weaponid);
	// 		}

	// 		case 3:
	// 		{
	// 		    if(GetPlayerSkinEx(playerid) == CharacterData[playerid][Account_GetLoggedCharacter(playerid)][OriginalSkin] || !CharacterData[playerid][Account_GetLoggedCharacter(playerid)][OriginalSkin]) return
	// 		        SendClientMessage(playerid, COLOR_ERROR, ""MESSAGE_PREFIX" Вы не можете снять Вашу стандартную одежду.");

    //             CharacterData[playerid][Account_GetLoggedCharacter(playerid)][ItemID] = slot;

	// 			slot = Inventory_AddItem(playerid, slot, "Одежда", CharacterData[playerid][Account_GetLoggedCharacter(playerid)][Skin]);
	// 			amount = CharacterData[playerid][Account_GetLoggedCharacter(playerid)][Skin];
	// 			CharacterData[playerid][Account_GetLoggedCharacter(playerid)][Skin] = CharacterData[playerid][Account_GetLoggedCharacter(playerid)][OriginalSkin];

	// 			SetPlayerSkinEx(playerid, CharacterData[playerid][Account_GetLoggedCharacter(playerid)][OriginalSkin]);

	// 			ApplyAnimation(playerid, "CLOTHES", "CLO_Buy", 4.1, 0, 0, 0, 0, 0);
	// 		}
	// 		default: return 1;
	// 	}

	// 	SendFormattedMessage(playerid, COLOR_GREEN, "> Вы убрали \"%s\" в свой инвентарь.", Inventory_ReturnString(playerid, ENTITY_TYPE_PLAYER, slot, amount));
	// }
	// else if(!strcmp(option, "puth", true))
	// {
	// 	if(CharacterData[playerid][Account_GetLoggedCharacter(playerid)][EditingMode]) return 1;

	//     if(!CharacterData[playerid][Account_GetLoggedCharacter(playerid)][E_CHARACTER_INVENTORY_LIST][slot]) return
	//         SendClientMessage(playerid, COLOR_ERROR, ""MESSAGE_PREFIX" Выбранный Вами слот пустой.");

	// 	new houseid = GetPlayerMenuHouse(playerid);

	// 	if(houseid == -1) return
	// 	    SendFormattedMessage(playerid, COLOR_ERROR, NO_RANGE_HOUSE);

	// 	if(GetPlayerMenuHouse(playerid) != houseid) return
	// 	    SendClientMessage(playerid, COLOR_ERROR, ""MESSAGE_PREFIX" Вы должны находиться в Вашем личном жилом помещении.");

	// 	if(Storage_GetCount(houseid) >= MAX_STORAGE_ITEMS) return
	// 	    SendClientMessage(playerid, COLOR_ERROR, ""MESSAGE_PREFIX" В инвентаре жилого помещения недостаточно места.");

	// 	if(type == ITEM_DRUG)
	// 	{
	// 		if(sscanf(secoption, "f", drugAmount))return	
	// 			SendFormattedMessage(playerid, COLOR_GREY, "> (/inv)entory <%d> <puth> <количество>", slot + 1);

	// 		if(drugAmount < 0.1) return
   	// 			SendFormattedMessage(playerid, COLOR_GREY, "> (/inv)entory <%d> <puth> <количество>", slot + 1);

	// 		if(drugAmount > CharacterData[playerid][E_CHARACTER_INV_DRUG_AMOUNT][slot] || drugAmount < 0.1)return
   	// 			SendClientMessage(playerid, COLOR_ERROR, ""MESSAGE_PREFIX" Вы ввели неверное количество.");
	// 	}
	// 	else
	// 	{
	// 		if(sscanf(secoption, "d", amount))return	
	// 			SendFormattedMessage(playerid, COLOR_GREY, "> (/inv)entory <%d> <puth> <количество>", slot + 1);

	// 		if(type == ITEM_WEAPON || type == ITEM_CLOTHES || type == ITEM_PHONE || type == ITEM_OTHER) amount = CharacterData[playerid][E_CHARACTER_INVENTORY_AMOUNT][slot];
	// 		else
	// 		{
	// 			if(amount <= 0) return
	// 				SendFormattedMessage(playerid, COLOR_GREY, "> (/inv)entory <%d> <puth> <количество>", slot + 1);

	// 			if(amount > CharacterData[playerid][E_CHARACTER_INVENTORY_AMOUNT][slot] || amount <= 0) return
	// 				SendClientMessage(playerid, COLOR_ERROR, ""MESSAGE_PREFIX" Вы ввели неверное количество.");
	// 		}
	// 	}
	
	// 	if(type == ITEM_DRUG) 
	// 	{
	// 		drugAmount += 0.000001;
	// 		SendFormattedMessage(playerid, COLOR_GREEN, "> Вы убрали \"%s\" в инвентарь жилого помещения.", Inventory_ReturnString(playerid, ENTITY_TYPE_PLAYER, slot, 0, drugAmount));
	// 		Storage_AddItem(playerid, houseid, Storage_FreeID(houseid), slot, 0, drugAmount);
	// 	}
	// 	else
	// 	{
	// 		SendFormattedMessage(playerid, COLOR_GREEN, "> Вы убрали \"%s\" в инвентарь жилого помещения.", Inventory_ReturnString(playerid, ENTITY_TYPE_PLAYER, slot, amount));
	// 		Storage_AddItem(playerid, houseid, Storage_FreeID(houseid), slot, amount);
	// 	}
		
    //     SaveCharacter(playerid);
        
    //     Log(playerid, "/inv puth", houseid, id, listid);
	// }
	// else if(!strcmp(option, "putv", true))
	// {
	//     if(CharacterData[playerid][Account_GetLoggedCharacter(playerid)][EditingMode]) return 1;
	    
	//     if(!CharacterData[playerid][Account_GetLoggedCharacter(playerid)][E_CHARACTER_INVENTORY_LIST][slot])return
	//         SendClientMessage(playerid, COLOR_ERROR, ""MESSAGE_PREFIX" Выбранный Вами слот пустой.");

	// 	new vehicleid = GetNearestVehicleBoot(playerid);
		
	// 	if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) return
	// 		SendClientMessage(playerid, COLOR_ERROR, ""MESSAGE_PREFIX" Вы не можете использовать инвентарь, если находитесь в транспорте.");

    // 	if(VehicleInfo[vehicleid][vBoot] != VEHICLE_PARAMS_ON) return
	// 		SendClientMessage(playerid, COLOR_ERROR, ""MESSAGE_PREFIX" Багажник транспортного средства закрыт.");

	// 	if(vehicleid == -1) return
	// 	    SendFormattedMessage(playerid, COLOR_ERROR, NO_RANGE_VEH);
		    
	// 	if(VehicleInfo[vehicleid][vTemporary]) return
	// 	    SendClientMessage(playerid, COLOR_ERROR, ""MESSAGE_PREFIX" Вы не можете поместить предметы в транспортное средство, которое не сохраняется в базе данных.");

	// 	new vCapacity = Trunk_GetSlot(vehicleid);

	// 	if(Trunk_GetCount(vehicleid) >= vCapacity) return
	// 	    SendClientMessage(playerid, COLOR_ERROR, ""MESSAGE_PREFIX" В инвентаре транспорта недостаточно места.");

	// 	switch(type)
	// 	{
	// 		case ITEM_DISASSEMBLED, ITEM_AMMO, ITEM_BIZ, ITEM_DRUG, ITEM_INGREDIENT:
	// 		{
	// 			if(id == -1)return
	// 			    SendFormattedMessage(playerid, COLOR_GREY, "> (/inv)entory <%d> <putv> <количество>", slot + 1);

	// 			if(id < 1 || id > CharacterData[playerid][E_CHARACTER_INVENTORY_AMOUNT][slot])return
	// 			    SendClientMessage(playerid, COLOR_ERROR, ""MESSAGE_PREFIX" Вы ввели неверное количество.");
	// 		}
	// 		case ITEM_WEAPON, ITEM_CLOTHES, ITEM_PHONE, ITEM_OTHER: id = CharacterData[playerid][E_CHARACTER_INVENTORY_AMOUNT][slot];
	// 	}

	// 	SendFormattedMessage(playerid, COLOR_GREEN, "> Вы убрали \"%s\" в инвентарь транспорта.", Inventory_ReturnString(playerid, ENTITY_TYPE_PLAYER, slot, id));

    //     Trunk_AddItem(playerid, vehicleid, Trunk_FreeID(vehicleid), slot, id);
        
    //     SaveCharacter(playerid);
        
    //     Log(playerid, "/inv putv", VehicleInfo[vehicleid][vID], id, listid);
	// }
	// else if(!strcmp(option, "putgb", true))
	// {
	// 	if(CharacterData[playerid][Account_GetLoggedCharacter(playerid)][EditingMode]) return 1;
		
	// 	if(!CharacterData[playerid][Account_GetLoggedCharacter(playerid)][E_CHARACTER_INVENTORY_LIST][slot])return
	// 		SendClientMessage(playerid, COLOR_ERROR, ""MESSAGE_PREFIX" Выбранный Вами слот пустой.");

		
	// 	if(!IsPlayerInAnyVehicle(playerid))return
	//    	 SendFormattedMessage(playerid, COLOR_ERROR, NOT_IN_CAR);
		
	// 	new vehicleid = GetPlayerVehicleID(playerid);

	// 	if(VehicleInfo[vehicleid][vTemporary]) return
	// 		SendClientMessage(playerid, COLOR_ERROR, ""MESSAGE_PREFIX" Вы не можете поместить предметы в транспортное средство, которое не сохраняется в базе данных.");

	// 	if(Glovebox_FreeID(vehicleid) == -1) return
	// 		SendClientMessage(playerid, COLOR_ERROR, ""MESSAGE_PREFIX" В бардачке транспорта недостаточно места.");

	// 	switch(type)
	// 	{
	// 		case ITEM_DISASSEMBLED, ITEM_AMMO, ITEM_BIZ, ITEM_DRUG, ITEM_INGREDIENT:
	// 		{
	// 			if(id == -1)return
	// 				SendFormattedMessage(playerid, COLOR_GREY, "> (/inv)entory <%d> <putgb> <количество>", slot + 1);

	// 			if(id < 1 || id > CharacterData[playerid][E_CHARACTER_INVENTORY_AMOUNT][slot])return
	// 				SendClientMessage(playerid, COLOR_ERROR, ""MESSAGE_PREFIX" Вы ввели неверное количество.");
	// 		}
	// 		case ITEM_WEAPON, ITEM_CLOTHES, ITEM_PHONE, ITEM_OTHER: id = CharacterData[playerid][E_CHARACTER_INVENTORY_AMOUNT][slot];
	// 	}

	// 	SendFormattedMessage(playerid, COLOR_GREEN, "> Вы убрали \"%s\" в бардачок транспорта.", Inventory_ReturnString(playerid, ENTITY_TYPE_PLAYER, slot, id));

	// 	Glovebox_AddItem(playerid, vehicleid, Glovebox_FreeID(vehicleid), slot, id);
		
	// 	SaveCharacter(playerid);
		
	// 	Log(playerid, "/inv putgb", VehicleInfo[vehicleid][vID], id, listid);
	// }
	// else if(!strcmp(option, "putp", true))
	// {
	// 	if(sscanf(secoption, "df", id, drugAmount))return	
	// 		SendFormattedMessage(playerid, COLOR_GREY, "> (/inv)entory <%d> <putp> <%d> <количество>", slot + 1, id + 1);

	// 	if(CharacterData[playerid][Account_GetLoggedCharacter(playerid)][EditingMode]) return 1;

	// 	if(type != ITEM_DRUG)return
	// 		SendClientMessage(playerid, COLOR_ERROR, ""MESSAGE_PREFIX" Вы не можете поместить в емкость данный предмет.");
		
	// 	if(!CharacterData[playerid][Account_GetLoggedCharacter(playerid)][E_CHARACTER_INVENTORY_LIST][slot])return
	// 		SendClientMessage(playerid, COLOR_ERROR, ""MESSAGE_PREFIX" Выбранный Вами слот пустой.");

	// 	if(drugAmount < 0.1) return
   	// 			SendFormattedMessage(playerid, COLOR_GREY, "> (/inv)entory <%d> <putp> <количество>", slot + 1);

	// 	if(drugAmount > CharacterData[playerid][E_CHARACTER_INV_DRUG_AMOUNT][slot] || drugAmount < 0.1)return
   	// 		SendClientMessage(playerid, COLOR_ERROR, ""MESSAGE_PREFIX" Вы ввели неверное количество.");

	// 	if(CharacterData[playerid][Account_GetLoggedCharacter(playerid)][InvExtra] && (CharacterData[playerid][Account_GetLoggedCharacter(playerid)][InvExtra][id] != CharacterData[playerid][Account_GetLoggedCharacter(playerid)][E_CHARACTER_INVENTORY_LIST][slot]))return
	// 		SendClientMessage(playerid, COLOR_ERROR, ""MESSAGE_PREFIX" Вы не можете мешать в одной емкости разные виды наркотиков.");
		
	// 	if(Inventory_HasItem(playerid, "Зиплок", ITEM_PACKAGE) == -1 && Inventory_HasItem(playerid, "Пузырек", ITEM_PACKAGE) == -1 && Inventory_HasItem(playerid, "Сверток", ITEM_PACKAGE) == -1)return
	// 		SendClientMessage(playerid, COLOR_ERROR, ""MESSAGE_PREFIX" У Вас должна быть какая-либо емкость (Зиплок / Пузырек / Сверток).");

	// 	if(InventoryObjects[CharacterData[playerid][Account_GetLoggedCharacter(playerid)][E_CHARACTER_INVENTORY_LIST][id]][invType] != ITEM_PACKAGE)return
	// 		SendClientMessage(playerid, COLOR_ERROR, ""MESSAGE_PREFIX" В выбранном Вами слоте отсутствует емкость.");
			
	// 	drugAmount += 0.000001;

	// 	SendFormattedMessage(playerid, COLOR_GREEN, "> Вы поместили \"%s (%.1f %s)\" в \"%s\".", InventoryObjects[CharacterData[playerid][Account_GetLoggedCharacter(playerid)][E_CHARACTER_INVENTORY_LIST][slot]][invName], drugAmount, InventoryObjects[CharacterData[playerid][Account_GetLoggedCharacter(playerid)][E_CHARACTER_INVENTORY_LIST][slot]][E_INVENTORY_OBJECT_AMOUNT_TYPE], Inventory_ReturnString(playerid, ENTITY_TYPE_PLAYER, id));
	
	// 	CharacterData[playerid][Account_GetLoggedCharacter(playerid)][InvExtra][id] = CharacterData[playerid][Account_GetLoggedCharacter(playerid)][E_CHARACTER_INVENTORY_LIST][slot];
	// 	CharacterData[playerid][Account_GetLoggedCharacter(playerid)][InvExtraAmount][id] += drugAmount;

	// 	Inventory_DecraseAmount(playerid, slot, 0, drugAmount);

	// 	SaveCharacter(playerid);
		
	// 	Log(playerid, "/inv putp", id, id, listid);
	// }
	// else if(!strcmp(option, "takep", true))
	// {
	// 	if(sscanf(secoption, "f", drugAmount))return	
	// 		SendFormattedMessage(playerid, COLOR_GREY, "> (/inv)entory <%d> <takep> <количество>", slot + 1);

	// 	if(CharacterData[playerid][Account_GetLoggedCharacter(playerid)][EditingMode]) return 1;
		
	// 	if(!CharacterData[playerid][Account_GetLoggedCharacter(playerid)][E_CHARACTER_INVENTORY_LIST][slot])return
	// 		SendClientMessage(playerid, COLOR_ERROR, ""MESSAGE_PREFIX" Выбранный Вами слот пустой.");

	// 	if(!CharacterData[playerid][Account_GetLoggedCharacter(playerid)][InvExtra][slot])return
	// 		SendClientMessage(playerid, COLOR_ERROR, ""MESSAGE_PREFIX" Выбранная Вами емкость пуста.");

	// 	if(CharacterData[playerid][Account_GetLoggedCharacter(playerid)][InvExtraAmount][slot] < drugAmount)return
	// 		SendClientMessage(playerid, COLOR_ERROR, ""MESSAGE_PREFIX" Вы ввели неверное количество.");

	// 	drugAmount += 0.000001;

	// 	SendFormattedMessage(playerid, COLOR_GREEN, "> Вы достали \"%s (%.1f %s)\" из \"%s\".", InventoryObjects[CharacterData[playerid][Account_GetLoggedCharacter(playerid)][InvExtra][slot]][invName], drugAmount, InventoryObjects[CharacterData[playerid][Account_GetLoggedCharacter(playerid)][InvExtra][slot]][E_INVENTORY_OBJECT_AMOUNT_TYPE], Inventory_ReturnString(playerid, ENTITY_TYPE_PLAYER, slot));

	// 	Inventory_AddItem(playerid, Inventory_FreeID(playerid), InventoryObjects[CharacterData[playerid][Account_GetLoggedCharacter(playerid)][InvExtra][slot]][invName], 0, drugAmount);

	// 	CharacterData[playerid][Account_GetLoggedCharacter(playerid)][InvExtraAmount][slot] -= drugAmount;

	// 	if(CharacterData[playerid][Account_GetLoggedCharacter(playerid)][InvExtraAmount][slot] <= 0.0)
	// 	{
	// 		CharacterData[playerid][Account_GetLoggedCharacter(playerid)][InvExtra][slot] = 0;
	// 		CharacterData[playerid][Account_GetLoggedCharacter(playerid)][InvExtraAmount][slot] = 0.0;
	// 	} 

	// 	SaveCharacter(playerid);
		
	// 	Log(playerid, "/inv takep", id, id, listid);
	// }
	else return
	    SendClientMessage(playerid, COLOR_ERROR, ""MESSAGE_PREFIX" Вы ввели несуществующий параметр.");

	return 1;
}

CMD:inv(playerid, params[]) return pc_cmd_inventory(playerid,params);
