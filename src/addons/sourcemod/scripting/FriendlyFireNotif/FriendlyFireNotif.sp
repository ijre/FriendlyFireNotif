#include <sourcemod>
#include <sdkhooks>
#include <left4dhooks>

#include "Globals.sp"

public Plugin myinfo =
{
  author = "ijre",
  name = "Friendly Fire Notification",
  version = "1.0.0"
};


static char generalQuotes[59][strSize] =
{
  "\"So it was wabbit season after all...\" - %V",
  "\"Tis but a scratch.\" - %V",
  "\"Ouchies.\" - %V",
  "\"New bottom surgery just dropped.\" - %V",
  "\"There's some weight off my shoulders.\" - %V",
  "\"I guess you CAN hit a bull's behind with a shovel.\" - %V",
  "\"Pretend I'm the messanger (don't shoot the messanger).\" - %V",
  "\"I see eyes aren't a part of the Valve Complete Pack bundle.\" - %V",
  "\"I will pay you 50 dollars to not shoot me again.\" - %V",
  "\"Ow.\" - %V",
  "\"%O, I'll take that gun away from you!\" - %V",
  "\"%O could never win the gnome game on their own.\" - %V",
  "\"Blimey.\" - %V",
  "\"And they said that college was going to cost me an arm and a leg.\" - %V",
  "\"I will never biologically recover from this.\" - %V",
  "\"At least you'll be safe from the zombies, since they go after people with brains.\" - %V",
  "\"Shotgun mains should pay higher taxes.\" - %V",
  "\"Jeff Bezos is a shotgun main.\" - %V",
  "\"Hey, I am not Kurt Cobain, direct that shotgun somewhere else.\" - %V",
  "\"Excuseeeeeeeeeeeeeeeeeeeeeeeeee me, princess?! EXCUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUSE ME, PRINCESS?!\" - %V",
  "\"If my ears weren't blown off, they'd be ringing.\" - %V",
  "\"GET GOOD. GET LMAOBOX.\" - %V",
  "\"Stop shooting me.\" - %V",
  "\"Stop that.\" - %V",
  "\"You're lucky I don't have burst.\" - %V",
  "\"Ahh...! My suit...!\" - %V",
  "\"Damnit, that was my good leg.\" - %V",
  "\"Not my right arm, I need that to play The Elder Scrolls: Blades!\" - %V",
  "\"So much for aimbot accusations.\" - %V",
  "\"If you shoot me one more time, I'm kicking you 10 seconds before the end of the campaign.\" - %V",
  "\"Like Charles Xavier, I am both smarter than you and now wheelchair bound.\" - %V",
  "\"I needed that liver to pay for my loanshark debts.\" - %V",
  "\"You shot my pinkie finger! How am I supposed to look pretentious while drinking coffee now?\" - %V",
  "\"The zombies would never be able to eat your smooth brain, their teeth would glide off.\" - %V",
  "\"%O Are you being /srs or /j right now??\" - %V",
  "\"My ass is grass, and you're the lawnmower.\" - %V",
  "\"Tis but a flesh wound.\" - %V",
  "\"Pain pills don't help if you have no limbs in which to feel pain.\" - %V",
  "\"I feel like an American journalist, and %O is the CIA.\" - %V",
  "\"That does it. [Continue]\" - %V",
  "\"That could have gone better, but it definitely could have gone worse.\" - %V",
  "\"Someone patch me up.\" - %V",
  "\"If only I could evade your shots half as well as I evade my taxes.\" - %V",
  "\"I got a new breathing hole!\" - %V",
  "\"Thanks for the sinus rinse.\" - %V",
  "\"I have become a blood soda fountain\" - %V",
  "\"Even vampires leave me with more blood.\" - %V",
  "\"Not my left arm, I need that to hold my Coffee!\" - Todd Howard",
  "\"Just a few more shots and you can play me like a pan flute.\" - %V",
  "\"Now I know what a hot pocket feels like.\" - %V",
  "\"I see my zombie cosplay is working out.\" - %V",
  "\"And here I thought you couldn't hit anything at all.\" - %V",
  "\"...And that's how I lost my medical license.",
  "\"Oof.\" - %V",
  "\"Holy uncanny photographic mental processes, %O! Who do you think you're shooting at?!\" - %V",
  "\"Shoutouts to Simpleflips\" - %V",
  "\"And boom goes the dynamite\" - the dynamite",
  "\"Balls\" - Zeli",
  "\"Do backstabbing motherfuckers experience the passage of time differently?\" - %V"
};

static char incapQuotes[55][strSize] =
{
  "\"ARGH I'M DYING- I NEED A MEDIC BAG!\" - %V",
  "\"Making a strategic retreat.\" - %V",
  "\"BWUARGH!\" - %V",
  "\"Green, Green, what's your problem, Green?\" - %V",
  "\"Amän KUKEN!\" - %V",
  "\"That hurt.\" - %V",
  "\"I am not a barn door, so stop LARPing as a banjo.\" - %V",
  "\"There goes my benefits.\" - %V",
  "\"So much for that medkit.\" - %V",
  "\"And here I was hoping to retire in peace.\" - %V",
  "\"Get me back up, or I'll haunt you in the afterlife.\" - %V",
  "\"Soon I can't tell my tales anymore.\" - %V",
  "\"That could have gone better, and it definitely couldn't have gone worse.\" - %V",
  "\"So this is what the Boomer feels like.\" - %V",
  "\"Did you know that it's really easy to hack your 3DS?\" - %V",
  "\"Cowa-bummer, dude\" - %O",
  "\"I hope I can get back to my bloodstain before I die again.\" - %V",
  "\"You better heal me once you res me.\" - %V",
  "\"Do you have pain pills in your inventory?\" - %V",
  "\"I'll settle for an adrenaline shot.\" - %V",
  "\"Someone kiss my boo-boo to make the pain go away.\" - %V",
  "\"If this was CS:GO you'd be kicked already.\" - %V",
  "\"You'd make a great versus player (as the infected).\" - %V",
  "\"My ass is being ravaged and all I can do is transmute my melee weapon into a dinky pistol.\" - %V",
  "\"If only I could aim straight after having my pelvis blown off.\" - %V",
  "\"I'd shoot you back if you didn't sever my spine. \" - %V",
  "\"homer is ded.\" - %V",
  "\"Someone glue me back together. Preferably here, but Hell will do fine.\" - %V",
  "\"Somebody get Shenlong, 'cause I'm about to fucking die.\" - %V",
  "\"If there were Mario Party bonus stars in Left 4 Dead 2, you'd get one for most friendly fire incidents.\" - %V",
  "\"God damnit. Stop that (past tense).\" - %V",
  "\"They're a 10 but they can't stop team killing.\" - %V",
  "\"Mmmm yummy dirt and blood haha smaskens mumsfilibaba.\" - %V",
  "\"Urghhh... I better call Saul...\" - %V",
  "\"Thanks, Obama.\" - %V",
  "\"MAMMA MIA!... WAAAAOOOOOOHHHHHHHH!\" - %V",
  "\"No-no-no-no!\" - Bain",
  "\"Guys, I told you to be careful with that stuff!\" - Bain",
  "\"%O, what have you done? You changed the future!! You've created a time paradox!\" - Colonel Roy Campbell",
  "\"Screw you guys. I'm gonna go play Minecraft.\" - %V",
  "\"Please don't let two white women make a podcast about my death!\" - %V",
  "\"Does this count as sick leave?\" - My boss",
  "\"Walk it off.\" - %O",
  "\"Guess I'll die.\" - %V",
  "\"Take me to the land of U.M.A...!\" - %V",
  "\"Erectin' a statue of a moron.\" - %O",
  "\"%V be like 'I have my whole life ahead of me' No you don't, the %O is coming :laughingcryingemoji:",
  "\"My i-frames ran out.\" - %V",
  "\"I saw my life flash before %O's eyes.\" - %V",
  "\"MEDIC!\" - %V",
  "\"My blood! %O shot out all my blood!\" - %V",
  "\"%O wasn't lying, that ass can fart.\" - %V",
  "\"I feel like a rat in a KFC frier.\" - %V",
  "\"I have become death, the destroyer of %V\" - %O",
  "\"%V is in a pickle!\" - Bain"
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

  MAX_GENERAL = sizeof(generalQuotes) - 1;
  MAX_INCAP = sizeof(incapQuotes) - 1;
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
    if (GetEntProp(victim, Prop_Send, "m_isIncapacitated") && !RoundToFloor(damage))
    {
      DmgTotal[attacker][victim] += -1.0; // if you meatshot at specific moments there's a pretty solid chance it will absolutely flood the chat with phantoms; this is a hack to get around it
    }
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
    DataPack data = CreateDataPack();
    CreateDataTimer(0.01, PlayerHurtTimer, data, TIMER_FLAG_NO_MAPCHANGE);

    data.WriteCell(victim);
    data.WriteCell(attacker);
    data.WriteCell(causedIncap);
  }

  DmgTotal[attacker][victim] += dmg;
}

char[] GetQuote(int victim, int attacker, int dmg, bool causedIncap)
{
  char quote[strSize];
  char victimName[32];
  char attackerName[32];
  Format(victimName, 32, "\x05%N\x01", victim);
  Format(attackerName, 32, "\x03%N\x01", attacker);

  if (!dmg && IsFakeClient(attacker))
  {
    quote = "";
    return quote;
  }
  else if (!dmg && !IsFakeClient(attacker))
  {
    quote = "%O landed a Phantom Hit on %V!";
  }
  else if (!IsPlayerAlive(victim))
  {
    quote = "%V when they take \x04%d\x01 damage from %O be like: *dies*";
  }
  else if (causedIncap)
  {
    PrintToChatAll("%s dealt \x04%d\x01 lethal damage to %s", attackerName, dmg, victimName);
    quote = incapQuotes[GetRandomInt(0, MAX_INCAP)];
  }
  else
  {
    PrintToChatAll("%s dealt \x04%d\x01 damage to %s", attackerName, dmg, victimName);
    quote = generalQuotes[GetRandomInt(0, MAX_GENERAL)];
  }

  ReplaceString(quote, strSize, "%V", victimName);
  ReplaceString(quote, strSize, "%O", attackerName);

  Format(quote, sizeof(quote), "\x01%s", quote);
  return quote;
}

Action PlayerHurtTimer(Handle timer, DataPack data)
{
  data.Reset();
  int victim = data.ReadCell();
  int attacker = data.ReadCell();
  bool causedIncap = data.ReadCell();

  if (AttackWillActuallyHit(victim, DmgTotal[attacker][victim], causedIncap))
  {
    char quote[strSize];
    quote = GetQuote(victim, attacker, ClampLower(DmgTotal[attacker][victim], 0), causedIncap);

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