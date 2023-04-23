#include <sourcemod>

#include "QuoteSys_Globals.sp"
#include "Helpers.sp"

#define PHANTOM_LOCK_OUT_CD 1.0
static float LastPhantom[L4D2_MAX][L4D2_MAX];

#define FAILSAFE_NAMES_SIZE 9
static char FailsafeNames[FAILSAFE_NAMES_SIZE][32] =
{
  "worldspawn",
  "Dyllon Stejakoski",
  "Freddy Fazbear",
  "Sentient 1f98c Emoji",
  "Mic-san",
  "ijre (real)",
  "ijre (fake)",
  "Lyra Lynx (real)",
  "Lyra Lynx (fake)"
};

static char[] GetRandomQuoteFromCategory(int category, int context)
{
  if (QuoteSizes[category][context] <= 0)
  {
    context = !!!context;
  }

  return Quotes[category][context][GetRandomInt(0, QuoteSizes[category][context])];
}

static char[] GetQuoteFromCategories(int wep, int dmgType, bool causedIncap)
{
  char buff[STR_SIZE];

  bool forceGeneralLine = GetRandomInt(1, 4) == 4 && !(dmgType & DMG_MELEE);
  bool doSpecialLine = !forceGeneralLine && (wep != -1 || dmgType & DMG_BLAST);

  int categoryToUse = GENERAL;
  int quoteContext = causedIncap ? CONTEXT_INCAP : CONTEXT_HURT;

  if (doSpecialLine && wep == -1)
  {
    categoryToUse = EXPLOSION;
  }
  else if (doSpecialLine)
  {
    char cName[128];
    GetEntityClassname(wep, cName, sizeof(cName));

    if (StrEqual(cName, "weapon_melee"))
    {
      GetEntPropString(wep, Prop_Data, "m_strMapSetScriptName", cName, sizeof(cName));
    }
    else
    {
      ReplaceString(cName, sizeof(cName), "weapon_", "", false);
    }

    int cNameLength = strlen(cName);

    for (int category = 0; category < MAX_CATEGORIES; category++)
    {
      if (!strncmp(cName, Categories[category], cNameLength, false) || StrContains(cName, Categories[category], false) != -1)
      {
        categoryToUse = category;
        break;
      }
    }
  }

  buff = GetRandomQuoteFromCategory(categoryToUse, quoteContext);
  return buff;
}

char[] GetQuote(int victim, int attacker, int dmg, int wep, int dmgType, bool causedIncap)
{
  char quote[STR_SIZE];
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
    if (!(dmgType & DMG_MELEE) && LastPhantom[attacker][victim] < GetGameTime())
    {
      quote = "%O landed a Phantom Hit on %V!";
      LastPhantom[attacker][victim] = GetGameTime() + PHANTOM_LOCK_OUT_CD;
    }
    else
    {
      quote = "";
      return quote;
    }
  }
  else if (!IsPlayerAlive(victim))
  {
    quote = "%V when they take \x04%d\x01 damage from %O be like: *dies*";
  }
  else if (causedIncap)
  {
    PrintToChatAll("%s dealt \x04%d\x01 lethal damage to %s", attackerName, dmg, victimName);
    quote = GetQuoteFromCategories(wep, dmgType, true);
  }
  else
  {
    PrintToChatAll("%s dealt \x04%d\x01 damage to %s", attackerName, dmg, victimName);
    quote = GetQuoteFromCategories(wep, dmgType, false);
  }

  ReplaceString(quote, STR_SIZE, "%V", victimName);
  ReplaceString(quote, STR_SIZE, "%O", attackerName);

  if (StrContains(quote, "%R") != -1)
  {
    bool usedFallback;
    int speaker = GetRandomSpeaker(victim, attacker, usedFallback);

    if (!usedFallback)
    {
      char speakerName[32];
      Format(speakerName, sizeof(speakerName), "\x04%N\x01", speaker);
      ReplaceString(quote, STR_SIZE, "%R", speakerName);
    }
    else
    {
      char speakerName[64];
      Format(speakerName, sizeof(speakerName), "\x04%s\x01", FailsafeNames[speaker]);
      ReplaceString(quote, STR_SIZE, "%R", speakerName);
    }
  }

  Format(quote, sizeof(quote), "\x01%s", quote);
  return quote;
}

static int GetRandomSpeaker(int victim, int attacker, bool& usedFallback = false)
{
  int speaker = -1;

  int team = GetClientTeam(victim);

  int friendlyTeamAlive[L4D2_MAX];
  int friendlyTeamAliveSize;
  friendlyTeamAlive = GetAlivePlayersOnTeam(team, friendlyTeamAliveSize);

  int enemyTeam = team == 2 ? 3 : 2;
  int enemyTeamSize = GetTeamClientCount(enemyTeam);

  if (friendlyTeamAliveSize > 2)
  {
    friendlyTeamAlive[victim] = -1;
    friendlyTeamAlive[attacker] = -1;

    int tries = 0;

    do
    {
      speaker = friendlyTeamAlive[GetRandomInt(0, friendlyTeamAliveSize - 1)];
    } while (speaker <= 0 && ++tries < 100); // surely if it fails that much it's simply destined to fail
  }
  else if (enemyTeamSize > 0)
  {
    speaker = GetRandomClient(enemyTeam);
  }

  if (speaker <= 0)
  {
    speaker = GetRandomInt(0, FAILSAFE_NAMES_SIZE - 1);
    usedFallback = true;
  }

  return speaker;
}

static int[] GetAlivePlayersOnTeam(int team, int& count)
{
  int ret[L4D2_MAX];

  for (int i = 1; i < L4D2_MAX; i++)
  {
    if (IsValidEntity(i) && IsClientInGame(i) && GetClientTeam(i) == team && IsPlayerAlive(i))
    {
      ret[count++] = i;
    }
  }

  return ret;
}