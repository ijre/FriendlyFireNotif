#include <sourcemod>
#include <sdkhooks>

public Plugin myinfo =
{
  author = "ijre",
  name = "Friendly Fire Notification",
  version = "1.0.0"
};

#define strSize 192

static char generalQuotes[57][strSize] =
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
  "\"GET GOOD. GET LMAO BOX.\" - %V",
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
  "\"And boom goes the dynamite\" - the dynamite"
}

static char incapQuotes[54][strSize] =
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
  "\"I have become death, the destroyer of %V\" - %O"
}

int MAX_GENERAL = 0;
int MAX_INCAP = 0;
static bool lateLoad;

public APLRes AskPluginLoad2(Handle plugin, bool late, char[] error, int errorLen)
{
  lateLoad = late;

  return APLRes_Success;
}

public void OnPluginStart()
{
  if (lateLoad)
  {
    for (int i = 1; i < 18; i++)
    {
      if (IsValidEntity(i))
      {
        SDKHook(i, SDKHook_OnTakeDamagePost, OnPlayerDamagePost);
      }
    }
  }

  MAX_GENERAL = sizeof(generalQuotes) - 1;
  MAX_INCAP = sizeof(incapQuotes) - 1;
  // sizeof() currently returns the incorrect size, probably a good ol breaking change from 1.10 -> 1.11
}

public void OnClientConnected(int client)
{
  SDKHook(client, SDKHook_OnTakeDamagePost, OnPlayerDamagePost);
}

char[] GetQuote(int victim, int attacker, int dmg, int health)
{
  char quote[strSize];
  char victimName[32];
  char attackerName[32];
  Format(victimName, 32, "%N", victim);
  Format(attackerName, 32, "%N", attacker);

  if (health - dmg <= 0 && !IsPlayerAlive(victim))
  {
    quote = "%V when they take %d damage from %O be like: *dies*";
  }
  else if (health - dmg <= 0)
  {
    PrintToChatAll("%N dealt %d lethal damage to %N", attacker, dmg, victim);
    quote = incapQuotes[GetRandomInt(0, MAX_INCAP)];
  }
  else
  {
    PrintToChatAll("%N dealt %d damage to %N", attacker, dmg, victim);
    quote = generalQuotes[GetRandomInt(0, MAX_GENERAL)];
  }

  ReplaceString(quote, strSize, "%V", victimName);
  ReplaceString(quote, strSize, "%O", attackerName);

  return quote;
}

static int dmgTotal[MAXPLAYERS][MAXPLAYERS];

void OnPlayerDamagePost(int victim, int attacker, int inflictor, float damage, int dmgType, int wep, float dmgForce[3], float dmgPosition[3], int dmgCustom)
{
  if (attacker == 0 || attacker > 18 || victim == attacker || GetClientTeam(victim) != GetClientTeam(attacker) || !damage)
  {
    return;
  }

  int health = GetClientHealth(victim);
  int dmg = RoundToNearest(damage);

  if (!dmgTotal[attacker][victim])
  {
    DataPack data = CreateDataPack();
    CreateDataTimer(0.1, PlayerHurtTimer, data, TIMER_FLAG_NO_MAPCHANGE);

    data.WriteCell(victim);
    data.WriteCell(attacker);
    data.WriteCell(health);
  }

  dmgTotal[attacker][victim] += dmg;
}

Action PlayerHurtTimer(Handle timer, DataPack data)
{
  data.Reset();
  int victim = data.ReadCell();
  int attacker = data.ReadCell();
  int health = data.ReadCell();

  PrintToChatAll(GetQuote(victim, attacker, dmgTotal[attacker][victim], health), dmgTotal[attacker][victim]);
  dmgTotal[attacker][victim] = 0;

  return Plugin_Continue;
}

public Action OnPlayerRunCmd(int client, int& buttons)
{
  if (GetEntPropEnt(client, Prop_Send, "m_hGroundEntity") == -1 && buttons & IN_JUMP)
  {
    buttons &= ~IN_JUMP;
    return Plugin_Changed;
  }

  return Plugin_Continue;
}