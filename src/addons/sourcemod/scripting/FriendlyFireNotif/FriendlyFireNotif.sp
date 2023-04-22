#include <sourcemod>
#include <sdkhooks>
#include <left4dhooks>

#include "Globals.sp"
#include "QuoteSystem/QuoteSystem.sp"

public Plugin myinfo =
{
  author = "ijre",
  name = "Friendly Fire Notification",
  version = "1.0.0.0"
};

static int DmgTotal[L4D2_MAX][L4D2_MAX];
static int PrevHealth[L4D2_MAX] = { -1, ... };
static bool PrevIncapState[L4D2_MAX];

static bool LateLoad;

public APLRes AskPluginLoad2(Handle plugin, bool late, char[] error, int errorLen)
{
  if (GetEngineVersion() != Engine_Left4Dead2)
  {
    StrCat(error, errorLen, "[Friendly Fire Notification] This plugin is for Left 4 Dead 2 only!");
    return APLRes_Failure;
  }

  LateLoad = late;

  return APLRes_Success;
}

public void OnPluginStart()
{
  Test = CreateConVar("sm_ffn_test", "0", "", FCVAR_NOTIFY);

  SetupQuotes();

  if (LateLoad)
  {
    for (int i = 1; i < 18; i++)
    {
      if (IsValidEntity(i))
      {
        SDKHook(i, SDKHook_OnTakeDamage, OnPlayerDamage);
        SDKHook(i, SDKHook_OnTakeDamagePost, OnPlayerDamagePost);
      }
    }
  }
}

public void OnClientPutInServer(int client)
{
  SDKHook(client, SDKHook_OnTakeDamage, OnPlayerDamage);
  SDKHook(client, SDKHook_OnTakeDamagePost, OnPlayerDamagePost);
}

void PrintToChatAllLog(const char[] msgRaw, any ...)
{
  char msg[1280];
  VFormat(msg, sizeof(msg), msgRaw, 2);

  PrintToChatAll(msg);
  LogMessage(msg);
}

int ClampLower(int val, int min)
{
  return val < min ? min : val;
}

int GetRealClientHealth(int client)
{
  return GetClientHealth(client) + RoundToNearest(L4D_GetTempHealth(client));
}

Action OnPlayerDamage(int victim, int& attacker, int& inflictor, float& damage, int& dmgType, int& wep, float dmgForce[3], float dmgPosition[3], int dmgCustom)
{
#if defined _debug
  if (attacker == 0 || victim == attacker)
  {
    return Plugin_Continue;
  }

  if (attacker > L4D2_MAX)
  {
    return Plugin_Stop;
  }

  int attackerTeam = GetClientTeam(attacker);
  int victimTeam = GetClientTeam(victim);

  if (attackerTeam == L4D_TEAM_INFECTED && attackerTeam != victimTeam)
  {
    return Plugin_Stop;
  }

  if (victimTeam != attackerTeam || victimTeam != L4D_TEAM_SURVIVOR)
  {
    return Plugin_Continue;
  }

#else

  if (attacker == 0 || attacker > L4D2_MAX || victim == attacker || GetClientTeam(victim) != GetClientTeam(attacker))
  {
    return Plugin_Continue;
  }
#endif

  if (!DmgTotal[attacker][victim])
  {
    PrevHealth[victim] = GetRealClientHealth(victim);
  }

  return Plugin_Continue;
}

void OnPlayerDamagePost(int victim, int attacker, int inflictor, float damage, int dmgType, int wep, float dmgForce[3], float dmgPosition[3], int dmgCustom)
{
  bool currentlyIncapped = !!GetEntProp(victim, Prop_Send, "m_isIncapacitated");
  bool causedIncap = false;
  if (PrevIncapState[victim] != currentlyIncapped)
  {
    causedIncap = PrevIncapState[victim] == false && currentlyIncapped;
    PrevIncapState[victim] = !PrevIncapState[victim];
  }

  if (attacker == 0 || attacker > 18 || victim == attacker || GetClientTeam(victim) != GetClientTeam(attacker))
  {
    return;
  }

  int dmg = RoundToFloor(damage);

  if (!DmgTotal[attacker][victim])
  {
    DataPack data;
    CreateDataTimer(0.01, PlayerHurtTimer, data, TIMER_FLAG_NO_MAPCHANGE);

    data.WriteCell(victim);
    data.WriteCell(attacker);
    data.WriteCell(wep);
    data.WriteCell(dmgType);
    data.WriteCell(causedIncap);
  }

  DmgTotal[attacker][victim] += dmg;
}

Action PlayerHurtTimer(Handle timer, DataPack data)
{
  data.Reset();
  int victim = data.ReadCell();
  int attacker = data.ReadCell();
  int wep = data.ReadCell();
  int dmgType = data.ReadCell();
  bool causedIncap = data.ReadCell();

  if (AttackWillActuallyHit(victim, DmgTotal[attacker][victim], causedIncap))
  {
    char quote[STR_SIZE];
    quote = GetQuote(victim, attacker, ClampLower(DmgTotal[attacker][victim], 0), wep, dmgType, causedIncap);

    if (strncmp(quote, "-1", 2))
    {
      PrintToChatAll(quote, DmgTotal[attacker][victim]);
    }
  }

  DmgTotal[attacker][victim] = 0;

  return Plugin_Continue;
}

bool AttackWillActuallyHit(int client, int dmg, bool& causedIncap)
{
  return \
  GetEntPropEnt(client, Prop_Send, "m_pounceAttacker") == -1
  &&
  GetEntPropEnt(client, Prop_Send, "m_pummelAttacker") == -1
  &&
  GetEntPropEnt(client, Prop_Send, "m_tongueOwner") == -1
  &&
  GetEntPropEnt(client, Prop_Send, "m_carryAttacker") == -1
  &&
  GetEntPropEnt(client, Prop_Send, "m_jockeyAttacker") == -1
  &&
  GetEntPropEnt(client, Prop_Send, "m_reviveOwner") == -1
  &&
  GetEntPropFloat(client, Prop_Send, "m_knockdownTimer") < GetGameTime()
  &&
  ValidateVictimHealth(client, dmg, causedIncap);
}

bool ValidateVictimHealth(int victim, int dmg, bool& causedIncap)
{
  if (dmg == -1)
  {
    return true;
  }

  int currentHealth = GetRealClientHealth(victim);
  int expectedHealth = PrevHealth[victim] - dmg;

  bool trulyHit = currentHealth == expectedHealth;
  if (!trulyHit)
  {
    if (expectedHealth < 0 || currentHealth > PrevHealth[victim])
    {
      trulyHit = true;
      causedIncap = true;
    }
  }

  if (Test.BoolValue)
  {
    char ending[128] = "";
    if (trulyHit && Test.BoolValue)
    {
      ending = " \nFORCED TO PRINT BY \"sm_ffn_test\"";
    }

    int diff = currentHealth - expectedHealth;

    PrintToChatAllLog(
    "\ntarget: \"%N\" \ndmg: %d \nhp: %d, was: %d, expected: %d (differs by %d)%s",
    victim, dmg,
    currentHealth, PrevHealth[victim], expectedHealth, diff, ending
    );
    PrintToChatAll("----");
  }

  return trulyHit;
}