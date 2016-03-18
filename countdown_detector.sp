#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
 
#define DATA "1.0"

int number;
Handle timers;

public Plugin:myinfo =
{
	name = "SM Console chat countdown detector",
	description = "",
	author = "Franc1sco franug",
	version = DATA,
	url = "http://steamcommunity.com/id/franug"
};
 
public OnPluginStart()
{
	CreateConVar("sm_countdowndetector_version", DATA, "", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
	AddCommandListener(SayConsole, "say");
	
	HookEvent("round_start", Resett);
}

public Action:Resett(Handle:event, const String:name[], bool:dontBroadcast)
{
	if(timers != INVALID_HANDLE)
	{
		KillTimer(timers);
		timers = INVALID_HANDLE;
	}
}
 
public Action:SayConsole(client,const char[] command, args)
{
	if (client != 0)return;
	
	
	decl String:buffer[255], String:buffer2[255];
	GetCmdArgString(buffer,sizeof(buffer));
	StripQuotes(buffer);
	bool numeric = false;
	
	for (new i=1; i < strlen(buffer); i++)
	{    
        if (IsCharNumeric(buffer[i]))
        {
        	if (!numeric) Format(buffer2, 255, "");
        	numeric = true;
        	Format(buffer2, 255, "%s%c",buffer2, buffer[i]);
        	
        }
        else if (IsCharSpace(buffer[i])) continue;
        else if(numeric)
		{
			if(buffer[i] == 's' && (strlen(buffer) <= i+1 || buffer[i+1] == 'e' || IsCharSpace(buffer[i+1])))
			{
				number = StringToInt(buffer2);
				CountDown();
				return;
			}
			
		}   
		else numeric = false;

	}	
}

CountDown()
{
	if(timers != INVALID_HANDLE)
	{
		KillTimer(timers);
		timers = INVALID_HANDLE;
	}
	timers = CreateTimer(1.0, Repeater, _, TIMER_REPEAT);
	PrintCenterTextAll("Doors will open in %i seconds", number);
}

public Action Repeater(Handle timer)
{
	number--;
	if(number <= 0)
	{
		PrintCenterTextAll("DOORS OPENED! GO GO GO!");	
		if(timers != INVALID_HANDLE)
		{
			KillTimer(timers);
			timers = INVALID_HANDLE;
		}
		return;
	}
	PrintCenterTextAll("Doors will open in %i seconds", number);
}