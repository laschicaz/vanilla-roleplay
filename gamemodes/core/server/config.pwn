/**
 * # Header
 */

#include <YSI_Coding\y_hooks>

#define GAMEMODE_SITE					    "vanilla.gg"
#define GAMEMODE_NAME                       "Vanilla Roleplay"
#define	GAMEMODE_VERSION  				    "Vanilla 0.1"

#define MESSAGE_PREFIX						"->"
#define NULL                    			"\1"

/**
 * # Hooks
 */

hook OnGameModeInit()
{
	print(""MESSAGE_PREFIX" "GAMEMODE_VERSION" запущен...");

    DisableInteriorEnterExits(); 
    AllowInteriorWeapons(false);
    SetNameTagDrawDistance(20.0);

	ShowPlayerMarkers(PLAYER_MARKERS_MODE_OFF);
	SetGameModeText(GAMEMODE_VERSION);

	SendRconCommand("name "GAMEMODE_NAME"");
	return 1;
}