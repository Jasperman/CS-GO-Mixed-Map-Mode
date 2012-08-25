#include <sourcemod>
#include <sdktools>
#pragma semicolon 1
#define VERSION "0.0.1"
#define AUTHOR "Jasperman"
#define TBC_URL "http://www.totalbantercommunity.com"
#define OUTPUT_PREFIX "MMGM"

//new Handle:<HANDLE_NAME> = INVALID_HANDLE;
new Handle:PLUGIN_ENABLED = INVALID_HANDLE;
new Handle:PLUGIN_MESSAGES = INVALID_HANDLE;
new Handle:PLUGIN_DEFAULTMODE = INVALID_HANDLE;
new Handle:PLUGIN_MAPS_CASUAL = INVALID_HANDLE;
new Handle:PLUGIN_MAPS_COMPETITIVE= INVALID_HANDLE;
new Handle:PLUGIN_MAPS_ARMSRACE= INVALID_HANDLE;
new Handle:PLUGIN_MAPS_DEMOLITION= INVALID_HANDLE;
new Handle:PLUGIN_NEXTMAP_SETMODE = INVALID_HANDLE;
new Handle:SERVER_GAME_TYPE= INVALID_HANDLE;
new Handle:SERVER_GAME_MODE = INVALID_HANDLE;
new Handle:SOURCEMOD_NEXTMAP = INVALID_HANDLE;

new bool:printmessages = true;
new bool:pluginenable = true;
new overwritenextmapMode = false;
new nextmapMode = 0;
new gametype = 0;
new gamemode = 0;

public Plugin:myinfo = 
{
	name = "Next Map Mode",
	author = AUTHOR,
	description = "This plugin will allow a server to configure a Game Type and Mode for the next map",
	version = VERSION,
	url = TBC_URL
};


public OnPluginStart()
{
	//Set up Custom CVARS
	//<HANDLE_NAME> = CreateConVar("<CVAR>", "<DEFAULT_VALUE>", "<DESCRIPTION>");
	PLUGIN_ENABLED = CreateConVar("sm_nmm_enable", "1", "Enable(1) or Disable(0) plugin. Default:1");
	PLUGIN_MESSAGES = CreateConVar("sm_nmm_messages", "1", "Enable(1) or Disable(0) plugin messages. Default:1");
	PLUGIN_DEFAULTMODE = CreateConVar("sm_nmm_defaultmode", "1", "Default Mode for plugin. 1-Casual, 2-Competitive, 3-Armsrace, 4-Demolition. Default:1");
	PLUGIN_MAPS_CASUAL = CreateConVar("sm_nmm_maps_casual", "", "List of Comma(,) Seperated Maps for casual games");
	PLUGIN_MAPS_COMPETITIVE = CreateConVar("sm_nmm_maps_competitive", "", "List of Comma(,) Seperated Maps for competitive games");
	PLUGIN_MAPS_ARMSRACE = CreateConVar("sm_nmm_maps_armsrace", "", "List of Comma(,) Seperated Maps for armsrace games");
	PLUGIN_MAPS_DEMOLITION = CreateConVar("sm_nmm_maps_demolition", "", "List of Comma(,) Seperated Maps for demolition games");
	PLUGIN_NEXTMAP_SETMODE = CreateConVar("sm_nmm_nextmap_setmode", "1", "Set the next maps mode 1-Casual, 2-Competitive, 3-Armsrace, 4-Demolition This will Overwrite the next maps mode. Default:1");
	
	//Get Server CVARS
	SERVER_GAME_TYPE = FindConVar("game_type");
	SERVER_GAME_MODE = FindConVar("game_mode");
	SOURCEMOD_NEXTMAP = FindConVar("sm_nextmap");
	
//	if (<HANDLE_NAME> != INVALID_HANDLE)
//	{
//		HookConVarChange(<HANDLE_NAME>, <METHOD_CALL>);
//	}

	if (PLUGIN_MESSAGES != INVALID_HANDLE)
	{
		HookConVarChange(PLUGIN_MESSAGES, pluginmessages_event);
	}
	if (PLUGIN_ENABLED != INVALID_HANDLE)
	{
		HookConVarChange(PLUGIN_ENABLED, pluginenable_event);
	}
	if (PLUGIN_NEXTMAP_SETMODE != INVALID_HANDLE)
	{
		HookConVarChange(PLUGIN_NEXTMAP_SETMODE, pluginsetnextmapmode_event);
	}
	if (SERVER_GAME_TYPE != INVALID_HANDLE && SERVER_GAME_MODE != INVALID_HANDLE)
	{
		HookConVarChange(SERVER_GAME_TYPE, type_event);
		HookConVarChange(SERVER_GAME_MODE, mode_event);
	}
	if (SOURCEMOD_NEXTMAP != INVALID_HANDLE)
	{
		HookConVarChange(SOURCEMOD_NEXTMAP, nextmap);
	}
}


//HookEvent("round_start", roundstart_event);
public pluginmessages_event(Handle:cvar, const String:oldVal[], const String:newVal[])
{
	new convar_value = GetConVarInt(PLUGIN_MESSAGES);
	decl String:convar_name[64];
	GetConVarName(PLUGIN_MESSAGES,convar_name,64);
	printmessages = (convar_value == 1);
	PrintToServer("[%s] %s set to %s",OUTPUT_PREFIX,convar_name,newVal);
	if(printmessages)
	{
		PrintToServer("[%s] Will now Print Messages",OUTPUT_PREFIX);
	}
	else
	{
		PrintToServer("[%s] Will stop Printing Messages",OUTPUT_PREFIX,newVal);
	}
}

public pluginenable_event(Handle:cvar, const String:oldVal[], const String:newVal[])
{
	new convar_value = GetConVarInt(PLUGIN_ENABLED);
	pluginenable = (convar_value == 1);
	if(printmessages)
	{
		decl String:convar_name[64];
		GetConVarName(PLUGIN_ENABLED,convar_name,64);
		PrintToServer("[%s] %s set to %s",OUTPUT_PREFIX,convar_name,newVal);
		if(pluginenable)
		{
			PrintToServer("[%s] Plugin Enabled",OUTPUT_PREFIX);
		}
		else
		{
			PrintToServer("[%s] Plugin Disabled",OUTPUT_PREFIX,newVal);
		}
	}
}

public pluginsetnextmapmode_event(Handle:cvar, const String:oldVal[], const String:newVal[])
{
	nextmapMode = GetConVarInt(PLUGIN_NEXTMAP_SETMODE);
	overwritenextmapMode = (nextmapMode > 0 && nextmapMode < 5 );
	if(printmessages)
	{
		decl String:convar_name[64];
		GetConVarName(PLUGIN_NEXTMAP_SETMODE,convar_name,64);
		PrintToServer("[%s] %s set to %s",OUTPUT_PREFIX,convar_name,newVal);
	}
}

public type_event(Handle:cvar, const String:oldVal[], const String:newVal[])
{
	gametype = GetConVarInt(SERVER_GAME_TYPE);
	if(printmessages)
	{
		decl String:convar_name[64];
		GetConVarName(SERVER_GAME_TYPE,convar_name,64);
		PrintToServer("[%s] %s set to %s",OUTPUT_PREFIX,convar_name,newVal);
	}
}

public mode_event(Handle:cvar, const String:oldVal[], const String:newVal[])
{
	gamemode = GetConVarInt(SERVER_GAME_MODE);
	if(printmessages)
	{
		decl String:convar_name[64];
		GetConVarName(SERVER_GAME_MODE,convar_name,64);
		PrintToServer("[%s] %s set to %s",OUTPUT_PREFIX,convar_name,newVal);
	}
}

public nextmap(Handle:cvar, const String:oldVal[], const String:newVal[])
{
	if(!overwritenextmapMode)
	{
		nextmapMode = getNextMapMode();
	}
	else
	{
		overwritenextmapMode = false;
	}
}

getNextMapMode()
{
	decl String:casualmaps[512];
	decl String:competitivemaps[512];
	decl String:armsracemaps[512];
	decl String:demolitionmaps[512];
	decl String:smnextmap[64];
	GetConVarString(PLUGIN_MAPS_CASUAL,casualmaps,512);
	GetConVarString(PLUGIN_MAPS_COMPETITIVE,competitivemaps,512);
	GetConVarString(PLUGIN_MAPS_ARMSRACE,armsracemaps,512);
	GetConVarString(PLUGIN_MAPS_DEMOLITION,demolitionmaps,512);
	GetConVarString(SOURCEMOD_NEXTMAP,smnextmap,64);
	new theNextMapMode = 0;
	new bool:iscasual = (StrContains(casualmaps,smnextmap,false) != -1);
	new bool:iscompetitive = (StrContains(competitivemaps,smnextmap,false) != -1);
	new bool:isarmsrace = (StrContains(armsracemaps,smnextmap,false) != -1);
	new bool:isdemolotion = (StrContains(demolitionmaps,smnextmap,false) != -1);

	if(iscasual)
	{
		theNextMapMode = 1;
	}
	else if(iscompetitive)
	{
		theNextMapMode = 2;
	}	
	else if(isarmsrace)
	{
		theNextMapMode = 3;
	}	
	else if(isdemolotion)
	{
		theNextMapMode = 4;
	}
	else
	{
		theNextMapMode = GetConVarInt(PLUGIN_DEFAULTMODE);
	}
	return theNextMapMode;
}

public OnMapEnd()
{
	switch(nextmapMode)
	{
		case 1: 
		{
			gametype = 0;
			gamemode = 0;
		}
		case 2: 
		{
			gametype = 0;
			gamemode = 1;
		}
		case 3: 
		{
			gametype = 1;
			gamemode = 0;
		}
		case 4: 
		{
			gametype = 1;
			gamemode = 1;
		}
	}
	SetConVarInt(SERVER_GAME_TYPE, gametype);
	SetConVarInt(SERVER_GAME_MODE, gamemode);
}



