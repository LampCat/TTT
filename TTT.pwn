// This is a comment
// uncomment the line below if you want to write a filterscript
//#define FILTERSCRIPT

#include <a_samp>
#include <foreach>

#if defined FILTERSCRIPT



public OnFilterScriptInit()
{
	print("\n--------------------------------------");
	print(" Blank Filterscript by your name here");
	print("--------------------------------------\n");
	return 1;
}

public OnFilterScriptExit()
{
	return 1;
}

#else

main()
{
	print("\n----------------------------------");
	print(" Trouble in Terrorist Town Indev");
	print("----------------------------------\n");
}

#endif



//Teams Detective, Traitor, Innocent
#define Detective 1
#define Innocent 2
#define Traitor 3

new Team[MAX_PLAYERS];
new InMap[MAX_PLAYERS];
new MapPlaying = 0;
new AdminLevel[MAX_PLAYERS];

new Text3D:OverHeadText[MAX_PLAYERS];
new Text:TextdrawGetingReady;
new Text:TextdrawDetictive;
new Text:TextdrawTraitor;
new Text:TextdrawInnocent;

new Game = 0;

new Detectives = 0;
new Innocents = 0;
new Traitors = 0;

forward StartRound();
forward Tick();
//forward SwitchPlayerTeam(playerid, );
new RandomTeam[][] =
{
    0,
    1,
    2
};
new Float:RandomSpawns[][] = 
{
	{2220.26, -1148.01, 1025.80, 15}, // Jefferson Motel
	{286.148987, -40.644398, 1001.569946, 1}, // Ammunation 1
	{-2637.69, 1404.24, 906.46, 3}, //Pleasures Dome/Jizzy's
	{318.565, 1110.210, 1082.98, 5}, // Crack Den
	{372.3520, -131.6510, 1001.4922, 5}, // Well Stacked Pizza
	{363.4129, -74.5786, 1001.5078, 10}, // Burger Shot
	{2496.65, -1696.55, 1014.74, 3}, // Johnsons House, The
	{2567.52, -1294.59, 1063.25, 2} // Big Smoke's Crack Palace
};
public OnGameModeInit()
{
	// Don't use these lines if it's a filterscript
	SetGameModeText("TTT 1.2.9 Indev");
	AllowInteriorWeapons(1);
	EnableStuntBonusForAll(0);
	SetNameTagDrawDistance(30.0);
	DisableInteriorEnterExits();
	AddPlayerClass(285,2193.5051,-1140.4023,1029.7969,183.0940,0,0,0,0,0,0);
	SetTimer("Tick", 1000, true);
	
	//When Loading a new round
	TextdrawGetingReady = TextDrawCreate(499.5, 100, "Preparing...");
    TextDrawFont(TextdrawGetingReady , 1);
    TextDrawLetterSize(TextdrawGetingReady , 0.5, 4.8999999999999995);
    TextDrawColor(TextdrawGetingReady , 0x050505FF);
    TextDrawSetOutline(TextdrawGetingReady , false);
    TextDrawSetProportional(TextdrawGetingReady , true);
    TextDrawSetShadow(TextdrawGetingReady , 1);
    TextDrawUseBox(TextdrawGetingReady, 0);
	
	//When a detective.
	TextdrawDetictive = TextDrawCreate(499.5, 100, "Detective");
    TextDrawFont(TextdrawDetictive , 1);
    TextDrawLetterSize(TextdrawDetictive , 0.5, 4.8999999999999995);
    TextDrawColor(TextdrawDetictive , 0x0b03ffFF);
    TextDrawSetOutline(TextdrawDetictive , false);
    TextDrawSetProportional(TextdrawDetictive , true);
    TextDrawSetShadow(TextdrawDetictive , 1);
    TextDrawUseBox(TextdrawDetictive, 0);
	
	//When a traitor
	TextdrawTraitor = TextDrawCreate(499.5, 100, "Traitor");
    TextDrawFont(TextdrawTraitor , 1);
    TextDrawLetterSize(TextdrawTraitor , 0.5, 4.8999999999999995);
    TextDrawColor(TextdrawTraitor , 0xff0303FF);
    TextDrawSetOutline(TextdrawTraitor , false);
    TextDrawSetProportional(TextdrawTraitor , true);
    TextDrawSetShadow(TextdrawTraitor , 1);
    TextDrawUseBox(TextdrawTraitor, 0);
	
	//When a innocent
	TextdrawInnocent = TextDrawCreate(499.5, 100, "Innocent");
    TextDrawFont(TextdrawInnocent , 1);
    TextDrawLetterSize(TextdrawInnocent , 0.5, 4.8999999999999995);
    TextDrawColor(TextdrawInnocent , 0x10ff03FF);
    TextDrawSetOutline(TextdrawInnocent , false);
    TextDrawSetProportional(TextdrawInnocent , true);
    TextDrawSetShadow(TextdrawInnocent , 1);
    TextDrawUseBox(TextdrawInnocent, 0);
	
	return 1;
}

public OnGameModeExit()
{
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	//SetPlayerPos(playerid, 1958.3783, 1343.1572, 15.3746);
	//SetPlayerCameraPos(playerid, 1958.3783, 1343.1572, 15.3746);
	//SetPlayerCameraLookAt(playerid, 1958.3783, 1343.1572, 15.3746);
	return 1;
}

public OnPlayerConnect(playerid)
{
    
    new string[64], pName[MAX_PLAYER_NAME], plrIP[16];
    GetPlayerName(playerid,pName,MAX_PLAYER_NAME);
    format(string,sizeof string,"%s joined the game.",pName);
    SendClientMessageToAll(0xFFFFFFAA,string);
    GetPlayerIp(playerid, plrIP, sizeof(plrIP));
    if(!strcmp(plrIP, "127.0.0.1"))
	{
	AdminLevel[playerid] = 5;
	}
	
	
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    new
    string[64],
    name[MAX_PLAYER_NAME];
    GetPlayerName(playerid,name,MAX_PLAYER_NAME);
    switch(reason)
    {
        case 0: format(string,sizeof string,"%s left the server. (Connection Lost)",name);
        case 1: format(string,sizeof string,"%s left the server. (Leaving)",name);
        case 2: format(string,sizeof string,"%s left the server. (Kicked/Banned)",name);
    }
    SendClientMessageToAll(0xFFFFFFAA,string);
	if(Team[playerid] == 1)
	{
		Detectives--;
	}
	if(Team[playerid] == 2)
	{ 
		Innocents--;
	}
	if(Team[playerid] == 3)
	{
	    Traitors--;
	}
    return 1;
}

public OnPlayerSpawn(playerid)
{
    SetPlayerPos(playerid, 2220.26,-1148.01,1025.80);
	SetPlayerInterior(playerid, 15);
	SetPlayerHealth(playerid, 50);
	SetPlayerArmour(playerid, 0);
	SetPlayerColor(playerid, 0xE0FFFFAA);
    SetPlayerSkin(playerid, 185);
	SetPlayerScore(playerid, 1000);
	if(Game == 1)
	{
	//Make the player spec any other alive player.
	}
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
    switch(Team[playerid])
	{
	    case 1: 
		{
		    SendClientMessage(killerid, 0xE0FFFFAA, "You just killed an Detective.");
			if(Game != 0)
		    Detectives--;
		}
		case 2: 
		{
		    SendClientMessage(killerid, 0xE0FFFFAA, "You just killed an Innocent man.");
			if(Game != 0)
		    Innocents--;
		}
		case 3: 
		{
		    SendClientMessage(killerid, 0xE0FFFFAA, "You just killed an Traitor");
			if(Game != 0)
		    Traitors--;
		}
	}
	//spec the killer.
	TogglePlayerSpectating(playerid, 1);
    PlayerSpectatePlayer(playerid, killerid);
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	return 1;
}

public OnPlayerText(playerid, text[])
{
	return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
    if (strcmp("/startround", cmdtext, true, 10) == 0)
	{
	print("Starting Round.....");
	SetTimer("StartRound", 20000, false);
	return 1;
    }
	if (strcmp("/me", cmdtext, true, 10) == 0)
	{
	switch(Team[playerid])
	{
	    case 0: SendClientMessage(playerid, 0xFFFFFFAA, "You have yet to join a team or you are dead.");
		case 1: SendClientMessage(playerid, 0xFFFFFFAA, "You are a detective.");
		case 2: SendClientMessage(playerid, 0xFFFFFFAA, "You are a innocent.");
		case 3: SendClientMessage(playerid, 0xFFFFFFAA, "You are a traitor.");
	}
	return 1;
	}
	return 0;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid)
{
	return 1;
}

public OnRconCommand(cmd[])
{
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	return 1;
}

public OnObjectMoved(objectid)
{
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	return 1;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
	return 1;
}

public OnPlayerExitedMenu(playerid)
{
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	return 1;
}

public OnPlayerUpdate(playerid)
{
	return 1;
}

public OnPlayerStreamIn(playerid, forplayerid)
{
	return 1;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	return 1;
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}
public SwitchPlayerMap(playerid, mapid)
{
    new string[128];
	format(string, sizeof(string), "Switching Map called, %i", mapid);
    print(string);
    SetPlayerPos(playerid, RandomSpawns[mapid][0], RandomSpawns[mapid][1], RandomSpawns[mapid][2]);
    SetPlayerInterior(playerid, RandomSpawns[mapid][3]);
}
public SwitchPlayerTeam(playerid, teamid)
{
    if(playerid != INVALID_PLAYER_ID)
    {
	new string[128];
	format(string, sizeof(string), "Switching team called, with teamid: %i", teamid);
    print(string);
    if(teamid == 0)
    { 
        OverHeadText[playerid] = Create3DTextLabel("Detective", 0x0b03ffFF, 30.0, 40.0, 50.0, 40.0, 0);
        Attach3DTextLabelToPlayer(OverHeadText[playerid], playerid, 0.0, 0.0, 0.3);
		SetPlayerColor(playerid, 0x0b03ffFF);
	    TextDrawHideForPlayer(playerid, TextdrawGetingReady);
	    TextDrawHideForPlayer(playerid, TextdrawInnocent);
	    TextDrawHideForPlayer(playerid, TextdrawTraitor);
		
        TextDrawShowForPlayer(playerid, TextdrawDetictive);
	    Team[playerid] = Detective;
		Detectives++;
		return;
   }
   if(teamid == 1)
   {
        TextDrawHideForPlayer(playerid, TextdrawGetingReady);
	    TextDrawHideForPlayer(playerid, TextdrawDetictive);
	    TextDrawHideForPlayer(playerid, TextdrawTraitor);

	    TextDrawShowForPlayer(playerid, TextdrawInnocent);
		Team[playerid] = Innocent;
		Innocents++;
		return;
   }
   if(teamid == 2)
   {
        TextDrawHideForPlayer(playerid, TextdrawGetingReady);
	    TextDrawHideForPlayer(playerid, TextdrawDetictive);
	    TextDrawHideForPlayer(playerid, TextdrawInnocent);

	    TextDrawShowForPlayer(playerid, TextdrawTraitor);
		Team[playerid] = Traitor;
		Traitors++;
		return;
   }
   }
}
public StartRound()
{
print("Selecting the Traitor's"); 
new Random = random(sizeof(RandomSpawns));
MapPlaying = Random;
foreach(Player, i)
{
    Team[i] = 0;
	TogglePlayerSpectating(i, 0);
	SetPlayerColor(i, 0xE0FFFFAA);
	SetPlayerHealth(i, 50);
	GivePlayerWeapon(i, 4, 1);
	GivePlayerWeapon(i, 25, 20);
	DeletePlayer3DTextLabel(i, OverHeadText[i]);
	Delete3DTextLabel(OverHeadText[i]);
	
	SwitchPlayerMap(i, Random);
	SwitchPlayerTeam(i, random(sizeof(RandomTeam)));
}
Game = 1;
}

// TickRate: 1 second.
public Tick()
{
	new string[128];
	format(string, sizeof(string), "Detectives: %i Innocents: %i Traitors: %i this round. game = %i", Detectives, Innocents, Traitors, Game);
	//SendClientMessageToAll(0xFFFFFFAA, string);
	print(string);
	foreach(Player, i)
    {
	   if(InMap[i] != MapPlaying)
	   {
	        SwitchPlayerMap(i, MapPlaying);
	   }
	}
    if(Innocents <= 0 && Detectives <= 0)
    {
	    if(Game == 1)
	    {
		Game = 0;
	    SetTimer("StartRound", 20000, false);
		SendClientMessageToAll(0xff0303FF, "Traitors Win this round.");
	    print("Traitors Win!");
		Detectives = 0;
        Innocents = 0;
        Traitors = 0;
	    } 
    }   
	if(Traitors <= 0)
	{
	    if(Game == 1)
	    {
		Game = 0;
		SetTimer("StartRound", 20000, false);
		SendClientMessageToAll(0x10ff03FF, "Innocents Win this round.");
		print("Innocents Win!");
		Detectives = 0;
        Innocents = 0;
        Traitors = 0;
	    }
	//Innocents win & round end
	}
}
