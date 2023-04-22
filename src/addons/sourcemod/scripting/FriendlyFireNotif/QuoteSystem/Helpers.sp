#include <sourcemod>

void SetupQuotes()
{
  if (QuoteSizes[0][0])
  {
    return;
  }

  for (int category = 0; category < MAX_CATEGORIES; category++)
  {
    File file;
    GetCategoryFile(Categories[category], file);

    if (file == null)
    {
      continue;
    }

    int quoteContext = CONTEXT_HURT;

    do
    {
      char buff[10000];
      file.ReadLine(buff, sizeof(buff));
      TrimString(buff);

      if (ShouldSkipLine(buff, quoteContext))
      {
        continue;
      }

      if (quoteContext != CONTEXT_INCAP + 1)
      {
        strcopy(Quotes[category][quoteContext][QuoteSizes[category][quoteContext]], STR_SIZE, buff);
        QuoteSizes[category][quoteContext]++;
      }
      else if (quoteContext == CONTEXT_INCAP + 1 && category != GENERAL)
      {
        strcopy(Quotes[category][CONTEXT_HURT][QuoteSizes[category][CONTEXT_HURT]], STR_SIZE, buff);
        QuoteSizes[category][CONTEXT_HURT]++;

        strcopy(Quotes[category][CONTEXT_INCAP][QuoteSizes[category][CONTEXT_INCAP]], STR_SIZE, buff);
        QuoteSizes[category][CONTEXT_INCAP]++;
      }
    } while (!file.EndOfFile());

    delete file;
    QuoteSizes[category][CONTEXT_HURT]--;
    QuoteSizes[category][CONTEXT_INCAP]--;
  }
}

static void GetCategoryFile(const char[] category, File& file)
{
  int catSTRSize = strlen(category);
  if (catSTRSize >= QUOTE_STR_SIZE)
  {
    ThrowError("[Friendly Fire Notif] GetCategoryFile attempted to get category \"%s\", which has length %d when we only support up to %d!", category, catSTRSize, QUOTE_STR_SIZE);
  }

  char filePath[128] = QUOTES_PATH;
  Format(filePath, sizeof(filePath), "%s\\%s.txt", QUOTES_PATH, category);

  file = OpenFile(filePath, "r");
}

static bool ShouldSkipLine(const char[] lineString, int& newContext = -1)
{
  if (
    !strncmp(lineString, "", 1) || !strncmp(lineString, "//", 2) || !strncmp(lineString, "{", 1) || !strncmp(lineString, "}", 1))
  {
    return true;
  }

  if (newContext != -1 && !strncmp(lineString, "\"incap\"", 7, false))
  {
    newContext = CONTEXT_INCAP;
    return true;
  }

  if (newContext != -1 && !strncmp(lineString, "\"hurt\"", 6, false))
  {
    newContext = CONTEXT_HURT;
    return true;
  }

  if (newContext != -1 && !strncmp(lineString, "\"both\"", 6, false))
  {
    newContext = CONTEXT_INCAP + 1;
    return true;
  }

  return false;
}