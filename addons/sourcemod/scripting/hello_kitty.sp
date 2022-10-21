#include <sourcemod>
#include <multicolors>
#include <sdktools>

#define PREFIX " \x02[SCREAMER]\x01"

public Plugin myinfo = 
{
	name = "Screamer", 
	author = "0-BuTaJIuK-0", 
	description = "Пугалка, Luqs", 
	version = "1.0", 
	url = "https://vk.com/butajiuk_7"
};

Handle TS[MAXPLAYERS + 1];
Handle TS2[MAXPLAYERS + 1];
float g_ScareTime[MAXPLAYERS + 1];

public OnPluginStart()
{
	RegAdminCmd("sm_screamer", Command_Screamer, ADMFLAG_GENERIC);
}

public void OnMapStart()
{
	// Skr
	if (!IsDecalPrecached("gcgcat/kitty.vtf"))
	{
		PrecacheDecal("gcgcat/kitty.vtf", true);
		AddFileToDownloadsTable("materials/gcgcat/kitty.vmt");
		AddFileToDownloadsTable("materials/gcgcat/kitty.vtf");
	}
	
	// Skr
	AddFileToDownloadsTable("sound/gcgcat/meow1.mp3");
	PrecacheSound("gcgcat/meow1.mp3");
	
	// Sred
	AddFileToDownloadsTable("sound/gcgcat/meow2.mp3");
	PrecacheSound("gcgcat/meow2.mp3");
}

//______________________________________________________________________________________________________
public Action Command_Screamer(int client, int argc)
{
	g_ScareTime[client] = 1.5;
	MainMenu(client);
}

public Action MainMenu(int client)
{
	Menu hMenu = new Menu(MainMenuHandler, MenuAction_Select | MenuAction_Cancel);
	hMenu.SetTitle("Screamer Menu:\n ");
	
	hMenu.AddItem("item0", "Select a player");
	hMenu.AddItem("item1", "Scare time (Duration to play)");
	
	hMenu.Display(client, MENU_TIME_FOREVER);
}

public int MainMenuHandler(Menu hMenu, MenuAction action, int client, int item)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			if (item == 0)
			{
				ShowSkrimerMenu(client);
			}
			else if (item == 1)
			{
				TimerMenu(client);
			}
		}
		case MenuAction_End:
		{
			delete hMenu;
		}
	}
}

void ShowSkrimerMenu(int client)
{
	Menu menu = new Menu(Skrimer_List);
	menu.SetTitle("Choose a player to scare:\n ");
	
	menu.AddItem("-1", "Everyone");
	
	char id[3], name[MAX_NAME_LENGTH];
	for (int current_client = 1; current_client <= MaxClients; ++current_client)
	{
		if (IsClientInGame(current_client) && current_client != client)
		{
			GetClientName(current_client, name, sizeof(name))
			IntToString(current_client, id, sizeof(id));
			menu.AddItem(id, name);
		}
	}
	
	if (!menu.ItemCount)
	{
		PrintToChat(client, "%s \x02There are no players to choose from!\x01", PREFIX);
	}
	
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Skrimer_List(Menu menu, MenuAction action, int client, int slot)
{
	switch (action)
	{
		case MenuAction_Cancel:
		{
			MainMenu(client);
		}
		case MenuAction_Select:
		{
			char info[4];
			menu.GetItem(slot, info, sizeof(info));
			int target = StringToInt(info);
			
			
			if (target == -1)
			{
				for (int current_client = 1; current_client <= MaxClients; ++current_client)
				{
					if (IsClientInGame(current_client) /*&& current_client != client*/)
					{
						ScarePlayerStart(client, current_client);
					}
				}
			}
			else
			{
				if (IsClientInGame(target))
				{
					ScarePlayerStart(client, target);
				}
			}
			
			ShowSkrimerMenu(client);
		}
		
		case MenuAction_End:
		{
			delete menu;
		}
	}
}

public Action TimerMenu(int client)
{
	Menu menu = new Menu(TimerMenuHandler, MenuAction_Select | MenuAction_Cancel);
	menu.SetTitle("Choose scare time:\n ");
	
	menu.AddItem("1.5", "1.5 (Optimal)");
	menu.AddItem("5.0", "5");
	menu.AddItem("10.0", "10");
	menu.AddItem("30.0", "30");
	
	menu.ExitBackButton = true;
	menu.ExitButton = false;
	
	menu.Display(client, MENU_TIME_FOREVER);
}

public int TimerMenuHandler(Menu menu, MenuAction action, int client, int item)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			// save time
			char scare_time_str[6];
			menu.GetItem(item, scare_time_str, sizeof(scare_time_str));
			g_ScareTime[client] = StringToFloat(scare_time_str);
			
			// alert player
			PrintToChat(client, "%s Screamer will play for \x02%.2f\x06 seconds!", PREFIX, g_ScareTime[client]);
			
			// show menu
			TimerMenu(client);
		}
		
		case MenuAction_Cancel:
		{
			if (item == MenuCancel_ExitBack)
			{
				MainMenu(client);
			}
		}
		
		case MenuAction_End:
		{
			delete menu;
		}
	}
} 

void ScarePlayerStart(int client, int target)
{
	ClientCommand(target, "r_screenoverlay gcgcat/kitty.vmt");
	EmitSoundToClient(target, "gcgcat/meow1.mp3", .level = 0);
	
	TS[target] = CreateTimer(1.5, Timer_Repeat, target, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	TS2[target] = CreateTimer(g_ScareTime[client], Timer_Kill, target, TIMER_FLAG_NO_MAPCHANGE);
}

public Action Timer_Repeat(Handle time, int target)
{
	EmitSoundToClient(target, "gcgcat/meow1.mp3", .level = 0);
}

public Action Timer_Kill(Handle timer, int target)
{
	KillTimer(TS[target]);
	KillTimer(TS2[target]);
	
	ClientCommand(target, "r_screenoverlay 0");
	EmitSoundToClient(target, "gcgcat/meow2.mp3", .level = 0);
}