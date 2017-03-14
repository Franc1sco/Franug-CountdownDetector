/*  SM Console Chat Manager
 *
 *  Copyright (C) 2017 Francisco 'Franc1sco' García
 * 
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option) 
 * any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT 
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS 
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with 
 * this program. If not, see http://www.gnu.org/licenses/.
 */

#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
 
#define DATA "1.1.3"

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
	LoadTranslations("countdown_detector.phrases");
	
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
			if((buffer[i] == 's' || buffer[i] == 'S') && (strlen(buffer) <= i+1 || buffer[i+1] == 'e' || buffer[i+1] == 'E' || IsCharSpace(buffer[i+1]) || buffer[i+1] == '!' || buffer[i+1] == '*'))
			{
				number = StringToInt(buffer2);
				CountDown();
				return;
			}
			numeric = false;
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
	PrintHintTextToAll("%t", "opening", number);
}

public Action Repeater(Handle timer)
{
	number--;
	if(number <= 0)
	{
		PrintHintTextToAll("%t", "opened");	
		if(timers != INVALID_HANDLE)
		{
			KillTimer(timers);
			timers = INVALID_HANDLE;
		}
		return;
	}
	PrintHintTextToAll("%t", "opening", number);
}