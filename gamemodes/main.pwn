#pragma warning disable 208

#define MAX_PLAYERS (150)

#include <open.mp>
#include <a_mysql>
#include <samp_bcrypt>
#include <Pawn.CMD>
#include <sscanf2>

/**
 * # Core
 */

#include ".\core\server\config.pwn"
#include ".\core\server\colors.pwn"
#include ".\core\server\util.pwn"
#include ".\core\server\dialog.pwn"

#include ".\core\database\connection.pwn"

#include ".\core\player\auth.pwn"
#include ".\core\player\account.pwn"
#include ".\core\player\character.pwn"

#include ".\core\messages\proxdetector.pwn"
#include ".\core\messages\chat.pwn"
#include ".\core\messages\action.pwn"

main()
{

}

