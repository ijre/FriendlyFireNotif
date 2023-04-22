#include <sourcemod>

#include "Globals.sp"
#include "Helpers.sp"

#define PHANTOM_LOCK_OUT_CD 1.0
static float LastPhantom[L4D2_MAX][L4D2_MAX];

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

  Format(quote, sizeof(quote), "\x01%s", quote);
  return quote;
}