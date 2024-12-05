/**
 * # Header
 */

#include <YSI_Coding\y_hooks>

#define MAX_LOGIN_ATTEMPTS          (5)

#define MIN_PASSWORD_LENGTH         (4)
#define MAX_PASSWORD_LENGTH         (16)

enum E_ACCOUNT_DATA {
    DBID:E_ACCOUNT_DATABASE_ID,

    E_ACCOUNT_NAME[MAX_PLAYER_NAME],
    E_ACCOUNT_HASH[BCRYPT_HASH_LENGTH],

    bool:E_ACCOUNT_LOGGED,
    E_ACCOUNT_LOGGED_CHARACTER
};

new
    AccountData[MAX_PLAYERS][E_ACCOUNT_DATA];

static
    playerLoginAttemptCount[MAX_PLAYERS char];

/**
 * # Forwards
 */

forward OnPlayerRegister(playerid);
forward OnPlayerLogIn(playerid);

forward OnPlayerHashPassword(playerid);
forward OnAccountInsertDatabase(playerid);
forward OnPlayerPasswordHashCheck(playerid, bool:success);

/**
 * # External
 */

stock Account_SetDatabaseID(playerid, DBID:id) {
    AccountData[playerid][E_ACCOUNT_DATABASE_ID] = id;
}

stock DBID:Account_GetDatabaseID(playerid) {
    return AccountData[playerid][E_ACCOUNT_DATABASE_ID];
}

stock Account_SetHash(playerid, const hash[]) {
    format(AccountData[playerid][E_ACCOUNT_HASH], _, hash);
}

stock Account_GetHash(playerid, hash[], size = sizeof(hash)) {
    format(hash, size, AccountData[playerid][E_ACCOUNT_HASH]);
}

stock Account_SetName(playerid, const name[]) {
    format(AccountData[playerid][E_ACCOUNT_NAME], _, name);
}

stock Account_GetName(playerid) {
    new name[MAX_PLAYER_NAME];

    format(name, sizeof(name), AccountData[playerid][E_ACCOUNT_NAME]);
    return name;
}

stock Account_GetLoggedCharacter(playerid)
    return AccountData[playerid][E_ACCOUNT_LOGGED_CHARACTER];

/**
 * # Hooks
 */

hook OnPlayerRequestRegister(playerid) {
    ShowPlayerDialog(playerid, DIALOG_ACCOUNT_REGISTRATION, DIALOG_STYLE_PASSWORD, "����������� - ������� ���� ������",
        "{FFFFFF}����� ���������� �� {F3E5AB}"GAMEMODE_NAME"{DEDEDE}, {FFFFFF}%s.\n\n\
		\n����� � ����� ������������ {EEC650}��� ������{DEDEDE} �� �����������.\n\n",
        "����������", Account_GetName(playerid)
    );
    
    return 1;
}

hook OnPlayerRequestLogIn(playerid) {
    ShowPlayerDialog(playerid, DIALOG_ACCOUNT_LOGIN, DIALOG_STYLE_PASSWORD, "����������� - ������� ���� ������",
        "{FFFFFF}����� ���������� �� {F3E5AB}"GAMEMODE_NAME"{DEDEDE}, {FFFFFF}%s.\n\n\
		{DEDEDE}������ ��� ����� ������ �������� � {E03232}���������� ��� � �������{DEDEDE}.\n����� � ����� ������������ {EEC650}��� ������{DEDEDE} �� �����������.\n\n\
        ����� ����������, ������� {EEC650}������{DEDEDE} ��� ����������� (��� �����������).",
        "����������", "��������", Account_GetName(playerid)
    );
    
    return 1;
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
    switch (dialogid) {
        case DIALOG_ACCOUNT_REGISTRATION: {
            if (!response) {
                DelayedKick(playerid, "����� �� �����������");

                return 1;
            }

            if (!(MIN_PASSWORD_LENGTH <= strlen(inputtext) <= MAX_PASSWORD_LENGTH)) {
                ShowPlayerDialog(playerid, DIALOG_ACCOUNT_LOGIN, DIALOG_STYLE_PASSWORD, "����������� - ������� ���� ������",
                    "{FFFFFF}����� ���������� �� {F3E5AB}"GAMEMODE_NAME"{DEDEDE}, {FFFFFF}%s.\n\n\
                    {DEDEDE}������ ��� ����� ������ �������� � {E03232}���������� ��� � �������{DEDEDE}.\n����� � ����� ������������ {EEC650}��� ������{DEDEDE} �� �����������.\n\n\
                    ����� ����������, ������� {EEC650}������{DEDEDE} ��� ����������� (��� �����������).",
                    "����������", "��������", Account_GetName(playerid)
                );

                return 1;
            }

            bcrypt_hash(playerid, "OnPlayerHashPassword", inputtext, BCRYPT_COST);
        }

        case DIALOG_ACCOUNT_LOGIN: {
            if (!response) {
                DelayedKick(playerid, "����� �� �����������");

                return 1;
            }

            bcrypt_verify(playerid, "OnPlayerPasswordHashCheck", inputtext, AccountData[playerid][E_ACCOUNT_HASH]);
        }
    }

    return 1;
}

hook OnCharacterLogOut(playerid) {
    static const
        ACCOUNT_DATA_CLEAN[E_ACCOUNT_DATA];

    AccountData[playerid] = ACCOUNT_DATA_CLEAN;

    return 1;
}

hook OnPlayerDisconnect(playerid, reason) {
    playerLoginAttemptCount{playerid} = 0;

    return 1;
}

/**
 * # Calls
 */

public OnPlayerHashPassword(playerid) {
    new
        hash[BCRYPT_HASH_LENGTH],
        query[256];

    bcrypt_get_hash(hash);

    mysql_format(MYSQL_DEFAULT_HANDLE, query, sizeof (query), "INSERT INTO `accounts` (`name`, `hash`) VALUES ('%e', '%s');", Account_GetName(playerid), hash);
    mysql_tquery(MYSQL_DEFAULT_HANDLE, query, "OnAccountInsertDatabase", "i", playerid);

    return 1;
}

public OnAccountInsertDatabase(playerid) {
    AccountData[playerid][E_ACCOUNT_DATABASE_ID] = DBID:cache_insert_id();

    CallLocalFunction("OnPlayerRegister", "i", playerid);

    return 1;
}

public OnPlayerPasswordHashCheck(playerid, bool:success) {
    if (success) {
        CallLocalFunction("OnPlayerLogIn", "i", playerid);

        return 1;
    }

    if (++playerLoginAttemptCount{playerid} >= MAX_LOGIN_ATTEMPTS) {
        DelayedKick(playerid, "�������� ����� �� ���� ������");

        return 1;
    }

    new const
        attemptCount = (MAX_LOGIN_ATTEMPTS - playerLoginAttemptCount{playerid});

    ShowPlayerDialog(playerid, DIALOG_ACCOUNT_LOGIN, DIALOG_STYLE_PASSWORD, "����������� - ������� ���� ������",
        "{FFFFFF}����� ���������� �� {F3E5AB}"GAMEMODE_NAME"{DEDEDE}, {FFFFFF}%s.\n\n\
		{DEDEDE}������ ��� ����� ������ �������� � {E03232}���������� ��� � �������{DEDEDE}.\n����� � ����� ������������ {EEC650}��� ������{DEDEDE} �� �����������.\n\n\
        ��������� ���� ������ {E03232}�������{DEDEDE} (%d / 5). ��������� �������.",
        "����������", "��������", Account_GetName(playerid), attemptCount
    );

    return 1;
}