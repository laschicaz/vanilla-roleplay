#include <YSI_Coding\y_hooks>

/**
 * # Header
 */

#define MAX_LOGIN_ATTEMPTS          (5)

#define MIN_PASSWORD_LENGTH         (4)
#define MAX_PASSWORD_LENGTH         (16)

static enum E_ACCOUNT_DATA {
    DBID:E_ACCOUNT_DATABASE_ID,
    E_ACCOUNT_HASH[BCRYPT_HASH_LENGTH]
};

static
    AccountData[MAX_PLAYERS][E_ACCOUNT_DATA]
;

static
    playerLoginAttemptCount[MAX_PLAYERS char]
;

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

stock SetAccountDatabaseID(playerid, DBID:id) {
    AccountData[playerid][E_ACCOUNT_DATABASE_ID] = id;
}

stock DBID:GetAccountDatabaseID(playerid) {
    return AccountData[playerid][E_ACCOUNT_DATABASE_ID];
}

stock SetAccountHash(playerid, const hash[]) {
    format(AccountData[playerid][E_ACCOUNT_HASH], _, hash);
}

stock GetAccountHash(playerid, hash[], size = sizeof (hash)) {
    format(hash, size, AccountData[playerid][E_ACCOUNT_HASH]);
}

/**
 * # Hooks
 */

hook OnPlayerRequestRegister(playerid) {
    ShowPlayerDialog(playerid, DIALOG_ACCOUNT_REGISTRATION, DIALOG_STYLE_PASSWORD, "Account Registration",
        "{FFFFFF}Welcome {98FB98}%s{FFFFFF},\n{FFFFFF}Enter a password below to register your account:",
        "Submit", "Leave", ReturnPlayerName(playerid)
    );
    
    return 1;
}

hook OnPlayerRequestLogIn(playerid) {
    ShowPlayerDialog(playerid, DIALOG_ACCOUNT_LOGIN, DIALOG_STYLE_PASSWORD, "Account Log In",
        "{FFFFFF}Hello {98FB98}%s{FFFFFF},\nEnter the password below to log in to the account:",
        "Submit", "Leave", ReturnPlayerName(playerid)
    );
    
    return 1;
}

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
    switch (dialogid) {
        case DIALOG_ACCOUNT_REGISTRATION: {
            if (!response) {
                DelayedKick(playerid, "Decided to leave");

                return 1;
            }

            if (!(MIN_PASSWORD_LENGTH <= strlen(inputtext) <= MAX_PASSWORD_LENGTH)) {
                ShowPlayerDialog(playerid, DIALOG_ACCOUNT_REGISTRATION, DIALOG_STYLE_PASSWORD, "Account Registration",
                    "{FFFFFF}Welcome {98FB98}%s{FFFFFF},\n{FFFFFF}Enter a password below to register your account:\n\n{FF0000}Enter a password between %i to %i characters.",
                    "Submit", "Leave", ReturnPlayerName(playerid), MIN_PASSWORD_LENGTH, MAX_PASSWORD_LENGTH
                );

                return 1;
            }

            bcrypt_hash(playerid, "OnPlayerHashPassword", inputtext, BCRYPT_COST);
        }

        case DIALOG_ACCOUNT_LOGIN: {
            if (!response) {
                DelayedKick(playerid, "Decided to leave");

                return 1;
            }

            bcrypt_verify(playerid, "OnPlayerPasswordHashCheck", inputtext, account[playerid][E_ACCOUNT_HASH]);
        }
    }

    return 1;
}

hook OnCharacterLogOut(playerid) {
    static const
        ACCOUNT_DATA_CLEAN[E_ACCOUNT_DATA]
    ;

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
        query[256]
    ;

    bcrypt_get_hash(hash);

    mysql_format(MYSQL_DEFAULT_HANDLE, query, sizeof (query), "INSERT INTO `accounts` (`name`, `hash`) VALUES ('%e', '%s');", ReturnPlayerName(playerid), hash);
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
        DelayedKick(playerid, "Exceeded login limit");

        return 1;
    }

    new const
        attemptCount = (MAX_LOGIN_ATTEMPTS - playerLoginAttemptCount{playerid})
    ;

    ShowPlayerDialog(playerid, DIALOG_ACCOUNT_LOGIN, DIALOG_STYLE_PASSWORD, "Account Log In",
        "{FFFFFF}Hello {98FB98}%s{FFFFFF},\nEnter the password below to log in to the account:\n\n{FF0000}Wrong password. You have %i login attempts left.",
        "Submit", "Leave", ReturnPlayerName(playerid), attemptCount
    );

    return 1;
}