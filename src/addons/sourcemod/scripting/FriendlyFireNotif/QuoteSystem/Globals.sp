#define QUOTES_PATH "addons\\sourcemod\\configs\\FriendlyFireNotif_Quotes"

#define DMG_MELEE (DMG_CLUB | DMG_SLASH)

#define GENERAL         0
#define SHOTGUN         1
#define SNIPER          2
#define EXPLOSION       3
#define UZI             4
#define RIFLE           5
#define SHOVEL          6
#define PITCHFORK       7
#define FIREAXE         8
#define BASEBALL_BAT    9
#define CRICKET_BAT     10
#define CROWBAR         11
#define FRYING_PAN      12
#define GOLFCLUB        13
#define ELECTRIC_GUITAR 14
#define KATANA          15
#define MACHETE         16
#define TONFA           17
#define KNIFE           18
#define CHAINSAW        19
#define MAX_CATEGORIES  20

#define CONTEXT_HURT 0
#define CONTEXT_INCAP 1
#define MAX_CONTEXTS 2

char Quotes[MAX_CATEGORIES][MAX_CONTEXTS][1000][STR_SIZE];
int QuoteSizes[MAX_CATEGORIES][MAX_CONTEXTS];

#define QUOTE_STR_SIZE 20
char Categories[MAX_CATEGORIES][QUOTE_STR_SIZE] =
{
  "general",
  "shotgun",
  "sniper",
  "explosion",
  "uzi",
  "rifle",
  "shovel",
  "pitchfork",
  "fireaxe",
  "baseball_bat",
  "cricket_bat",
  "crowbar",
  "frying_pan",
  "golfclub",
  "electric_guitar",
  "katana",
  "machete",
  "tonfa",
  "knife",
  "chainsaw"
};