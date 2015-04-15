/*
Copyright (C) 1988-2003 by Mohan Embar

http://www.thisiscool.com/
DISCLAIMER: This was written in 1988. I don't code like this anymore!

This program is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. See the GNU General Public License for more details. 

You should have received a copy of the GNU General Public License along with
this program; if not, write to the Free Software Foundation, Inc., 675 Mass Ave,
Cambridge, MA 02139, USA. 
*/

/* Program defined abstract data type called list.  A list contains
 * character strings each of which has a maximum length of 20 characters.
 *
 * Operations supported are:
 *
 *    
 */
typedef char WORD[40];
typedef WORD SENTENCE[200];

extern int numwords;
extern SENTENCE s;

/* Returns upper case value of c */
char upcase(c)
   char c;
{
   if (islower(c)) return toupper(c); else return c;
}

/* This function converts string1 into lowercase. */
void make_lower(string1)
   char *string1;
{
   char c;
   while (c = *string1) *string1++ = tolower(c);
}

/* Parses words in instring into WORD array s
 * Automatically translates n't to not, 're to are
 * Stores all letters in uppercase.  Sets numwords to number of tokens in
 * s.  Valid indices are from 1 .. numwords.
 */
void parse(instring)
   char *instring;
{
   char c; int i;
   int read_word = 0;
   int offset = -1;
   numwords = 0;
   while (c = *instring++) {
      switch(c) {
         case ' ' :
         case '\t' :
            read_word = 0;
            continue;
         case ',' :
         case '?' :
         case '.' :
         case ':' :
         case '"' :
            s[numwords++][++offset] = '\0';
            read_word = 0;
            s[numwords][offset = 0] = c;
            break;
         case '\'' :
            if ((s[numwords][offset] == 'N') && (upcase(*instring) == 'T')) {
               s[numwords++][offset]='\0';
               s[numwords][0] = 'N';
               s[numwords][offset = 1] = 'O';
               read_word = 1;
            }
            else if (upcase(*instring) == 'R') {
               s[numwords++][++offset] = '\0';
               s[numwords][offset = 0] = 'A';
               read_word = 1;
            }
            else if (upcase(*instring) == 'V') {
               s[numwords++][++offset] = '\0';
               s[numwords][offset = 0] = 'H';
               s[numwords][++offset] = 'A';
               read_word = 1;
            }
            else if (upcase(*instring) == 'M') {
               s[numwords++][++offset] = '\0';
               s[numwords][offset = 0] = 'A';
               read_word = 1;
            }
            else if (upcase(*instring) == 'L') {
               s[numwords++][++offset] = '\0';
               s[numwords][offset = 0] = 'W';
               s[numwords][++offset] = 'I';
               read_word = 1;
            }
            else if (upcase(*instring) == 'S') {
               s[numwords][offset+1] = '\0';
               if (!strcmp(s[numwords],"HE") || !strcmp(s[numwords],"SHE") 
                                             || !strcmp(s[numwords],"IT")) {
                  s[++numwords][offset = 0] = 'I';
                  read_word = 1;
               }
               else s[numwords][++offset] = '\'';
            }
            break;
         default :
            if (isalpha(c))
               if (read_word) {
                  s[numwords][++offset] = upcase(c);
               }
               else {
                  s[numwords++][++offset] = '\0';
                  ++read_word;
                  s[numwords][offset = 0] = upcase(c);
               }
            else {
               read_word = 0;
            }
      }  
   }
   s[numwords][++offset] = '\0';
   return;
}

/* Self-explanatory.  Used when computer spits back the sentence */
void agree()
{
   int i;
   for(i=1;i<=numwords;i++) {
      if (!strcmp(s[i],"I")) {
         strcpy(s[i],"YOU");
      }
      else if (!strcmp(s[i],"YOU")) {
         strcpy(s[i],"I");
      }
      else if (!strcmp(s[i],"YOUR")) {
         strcpy(s[i],"MY");
      }
      else if (!strcmp(s[i],"MY")) {
         strcpy(s[i],"YOUR");
      }
      else if (!strcmp(s[i],"YOU")) {
         strcpy(s[i],"ME");
      }
      else if (!strcmp(s[i],"ME")) {
         strcpy(s[i],"YOU");
      }
      else if (!strcmp(s[i],"MINE")) {
         strcpy(s[i],"YOURS");
      }
      else if (!strcmp(s[i],"YOURS")) {
         strcpy(s[i],"MINE");
      }
      else if (!strcmp(s[i],"WE")) {
         strcpy(s[i],"YOU");
      }
      else if (!strcmp(s[i],"YOURSELF")) {
         strcpy(s[i],"MYSELF");
      }
      else if (!strcmp(s[i],"MYSELF")) {
         strcpy(s[i],"YOURSELF");
      }
      else if (!strcmp(s[i],"OURSELVES")) {
         strcpy(s[i],"YOURSELVES");
      }
      else if (!strcmp(s[i],"OURS")) {
         strcpy(s[i],"YOURS");
      }
      else if (!strcmp(s[i],"OUR")) {
         strcpy(s[i],"YOUR");
      }
   }
   for (i=1;i<=numwords;i++) {
      if (!strcmp(s[i],"AM")) {
         strcpy(s[i],"ARE");
      }
      else if ( (!strcmp(s[i],"ARE")) &&
                (((i>0) && (!strcmp(s[i-1],"I"))) ||
                 ((i<numwords) && (!strcmp(s[i+1],"I"))) ) ) {
         strcpy(s[i],"AM");
      }
      else if ( (!strcmp(s[i],"WERE")) &&
                (((i>0) && (!strcmp(s[i-1],"I"))) ||
                 ((i<numwords) && (!strcmp(s[i+1],"I"))) ) ) {
         strcpy(s[i],"WAS");
      }
      else if ( (!strcmp(s[i],"WAS")) &&
                (((i>0) && (!strcmp(s[i-1],"YOU"))) ||
                 ((i<numwords) && (!strcmp(s[i+1],"YOU"))) ) ) {
         strcpy(s[i],"WERE");
      }
   }
}

/* Returns 1 if string1 matches first length(string1) characters of string2
 * and 0 if not.
 */
int matches(string1, string2)
   char *string1, *string2;
{
   int c;
   if (strlen(string1)>strlen(string2))
      return 0;
   else { /* length(string1)<=length(string2) */
      while (c = *string1++) {
         if (c != *string2++) return 0;
      }
      return 1;
   }   
}

/* Search WORD array s for search_string.  If exact = 1, enforce exact match.
 * Otherwise, return positive match if all characters of search_string match
 * the first length(search_string) characters of a WORD in s.  Assumes legal
 * values for exact are 0 or 1.  Returns index of match in s if match, 0 if
 * no match.
 */
int sword(s_string, exact)
   char *s_string;
   int exact;
{
   int i;
   for (i=1;i<=numwords;i++) {
      if (exact) {
         if (!strcmp(s_string,s[i])) return i;
      }
      else {
         if (matches(s_string,s[i])) return i;
      }
   }
   /* No match */
   return 0;
}

int bad_word()
{
   if (sword("\115\117\124\110\105\122\106\125\103\113",0))
      return 1;
   else if (sword("\106\125\103\113",0))
      return 1;
   else if (sword("\123\110\111\124",0))
      return 1;
   else if (sword("\101\123\123\110\117\114\105",1))
      return 1;
   else if (sword("\101\123\123",1))
      return 1;
   else return  0;
}

int naughty_word()
{
   if (sword("DAMN",0))
      return 1;
   else if (sword("STUPID",0))
      return 1;
   else if (sword("IDIOT",0))
      return 1;
   else if (sword("MORON",0))
      return 1;
   else if (sword("NUMBSKULL",0))
      return 1;
   else if (sword("IMBECILE",0))
      return 1;
   else if (sword("OBNOXIOUS",0))
      return 1;
   else return 0;
}

/* Return the index to a form of be or helping verb, if one exists
 * Otherwise, return 0.
 */
int find_helper()
{
   int x;
   if (x = sword("AM",1))
      return x;
   else if (x = sword("IS",1))
      return x;
   else if (x = sword("ARE",1))
      return x;
   else if (x = sword("WAS",1))
      return x;
   else if (x = sword("WERE",1))
      return x;
   else if (x = sword("WILL",1))
      return x;
   else if (x = sword("DO",1))
      return x;
   else if (x = sword("DID",1))
      return x;
   else if (x = sword("DOES",1))
      return x;
   else if (x = sword("HAVE",1))
      return x;
   else if (x = sword("HAD",1))
      return x;
   else if (x = sword("HAS",1))
      return x;
   else if (x = sword("SHALL",1))
      return x;
   else if (x = sword("SHOULD",1))
      return x;
   else if (x = sword("CAN",1))
      return x;
   else if (x = sword("COULD",1))
      return x;
   else if (x = sword("MAY",1))
      return x;
   else if (x = sword("MIGHT",1))
      return x;
   else return 0;
}

/* Returns 1 is string1 is pronoun.  0 if not. */
int is_sub_pronoun(string1)
   char *string1;
{
   if (!strcmp("I",string1))
      return 1;
   else if (!strcmp("YOU",string1))
      return 1;
   else if (!strcmp("WE",string1))
      return 1;
   else if (!strcmp("HE",string1))
      return 1;
   else if (!strcmp("SHE",string1))
      return 1;
   else if (!strcmp("IT",string1))
      return 1;
   else if (!strcmp("THEY",string1))
      return 1;
   else return 0;
}

int is_possesive(string1)
   char *string1;
{
   if (!strcmp("MY",string1))
      return 1;
   else if (!strcmp("YOUR",string1))
      return 1;
   else if (!strcmp("OUR",string1))
      return 1;
   else if (!strcmp("HIS",string1))
      return 1;
   else if (!strcmp("HER",string1))
      return 1;
   else if (!strcmp("ITS",string1))
      return 1;
   else if (!strcmp("THEIR",string1))
      return 1;
   else return 0;
}

int is_article(string1)
   char *string1;
{
   if (!strcmp("A",string1))
      return 1;
   else if (!strcmp("AN",string1))
      return 1;
   else if (!strcmp("THE",string1))
      return 1;
   else return 0;
}

/* Tries to find reference to a family member */
int family()
{
   int x;
   if (x = sword("MOTHER",1))
      return x;
   else if (x = sword("FATHER",1))
      return x;
   else if (x = sword("SISTER",1))
      return x;
   else if (x = sword("BROTHER",1))
      return x;
   else if (x = sword("DAD",1))
      return x;
   else if (x = sword("MOM",1))
      return x;
   else if (x = sword("UNCLE",1))
      return x;
   else if (x = sword("AUNT",1))
      return x;
   else if (x = sword("GRANDMOTHER",1))
      return x;
   else if (x = sword("GRANDFATHER",1))
      return x;
   else if (x = sword("COUSIN",1))
      return x;
   else if (x = sword("GRANDMA",1))
      return x;
   else if (x = sword("GRANDPA",1))
      return x;
   else return 0;
}

int i_am()
{
   int x, e=1;
   while (e) {
      for (x=e;x<=numwords;x++) if (!strcmp("I",s[x])) break;
      if (x >= numwords)
         return 0;
      else if (!strcmp("AM",s[x+1]))
         return x;
      else e = ++x;
   }
}

void get_til_stop(x,string1)
   int x;
   char *string1;
{
   char c, *temp;
   int e = 1;  /* Exit test */
   while (e) {
      if (x>numwords) {
         e--;
         *string1 = '\0';
      }
      else if (!isalpha(s[x][0])) {
         e--;
         *string1 = '\0';
      }
      else if (!strcmp("AND",s[x]) || !strcmp("OR",s[x])
                                   || !strcmp("BUT",s[x])) {
         e--;
         *string1 = '\0';
      }
      else {
         *string1++ = ' ';
         if (!strcmp("I",s[x]))
            *string1++ = 'I';
         else {
            temp = s[x];
            while (c = *temp++) *string1++ = tolower(c);
         }
         x++;
      }
   }
   *string1 = '\0';
}

int sad_word()
{
   int x;
   if (x = sword("DEPRESS",0))
      return x;
   else if (x = sword("UNHAPPY",1))
      return x;
   else if (x = sword("SAD",1))
      return x;
   else if (x = sword("MISERABLE",1))
      return x;
   else if (x = sword("AWFUL",1))
      return x;
   else if (x = sword("UPSET",1))
      return x;
   else if (x = sword("TERRIBLE",1))
      return x;
   else return 0;
}

int search_back_sub(x)
   int x;
{
   int y = --x;
   while (y) {
      if (is_possesive(s[y]) || is_sub_pronoun(s[y]) || is_article(s[y]))
         return y;
      else
         y--;
   }
   return y;
}

/* Returns 1 if string is a form of be or helping verb,
 * Otherwise, returns 0.
 */
int is_helper(string1)
   char *string1;
{
   if (!strcmp(string1,"AM"))
      return 1;
   else if (!strcmp(string1,"IS"))
      return 1;
   else if (!strcmp(string1,"ARE"))
      return 1;
   else if (!strcmp(string1,"WAS"))
      return 1;
   else if (!strcmp(string1,"WERE"))
      return 1;
   else if (!strcmp(string1,"WILL"))
      return 1;
   else if (!strcmp(string1,"DO"))
      return 1;
   else if (!strcmp(string1,"DID"))
      return 1;
   else if (!strcmp(string1,"DOES"))
      return 1;
   else if (!strcmp(string1,"HAVE"))
      return 1;
   else if (!strcmp(string1,"HAD"))
      return 1;
   else if (!strcmp(string1,"HAS"))
      return 1;
   else if (!strcmp(string1,"SHALL"))
      return 1;
   else if (!strcmp(string1,"SHOULD"))
      return 1;
   else if (!strcmp(string1,"CAN"))
      return 1;
   else if (!strcmp(string1,"COULD"))
      return 1;
   else if (!strcmp(string1,"MAY"))
      return 1;
   else if (!strcmp(string1,"MIGHT"))
      return 1;
   else if (matches(string1,"FEEL"))
      return 1;
   else return 0;
}

void getrange(y,x,string1)
   int y, x;
   char *string1;
{
   char c, *temp;
   while (y<=x) {
      *string1++ = ' ';
      if (!strcmp("I",s[y]))
         *string1++ = 'I';
      else {
         temp = s[y];
         while (c = *temp++) *string1++ = tolower(c);
      }
      y++;
   }
   *string1 = '\0';
}

/* Returns 1 if s[1] is a command.  0 if not. */
int is_command()
{
   if (!strcmp("GIVE",s[1]))
      return 1;
   else if (!strcmp("TELL",s[1]))
      return 1;
   else if (!strcmp("SHOW",s[1]))
      return 1;
   else if (!strcmp("EXPLAIN",s[1]))
      return 1;
   else return 0;
}

int four_ws()
{
   if (!strcmp(s[1],"WHO"))
      return 1;
   else if (!strcmp(s[1],"WHAT"))
      return 1;
   else if (!strcmp(s[1],"WHERE"))
      return 1;
   else if (!strcmp(s[1],"WHY"))
      return 1;
   else if (!strcmp(s[1],"WHEN"))
      return 1;
   else if (!strcmp(s[1],"HOW"))
      return 1;
   else return 0;
}

int vague_quest()
{
   return (four_ws() && (!is_helper(s[2]) || !is_sub_pronoun(s[3])));
}

int real_quest()
{
   return (four_ws() && is_helper(s[2]) && is_sub_pronoun(s[3]));
}

int sub_and_helper()
{
   int x;
   return ((x = find_helper()) && search_back_sub(x));
}

char *cnnv(string1)
   char *string1;
{
   if (!strcmp(string1," i")) {
      return " myself";
   }
   else if (!strcmp(string1," you")) {
      return " yourself";
   }
   else if (!strcmp(string1," we")) {
      return " ourselves";
   }
   else if (!strcmp(string1," he")) {
      return " him";
   }
   else if (!strcmp(string1," she")) {
      return " her";
   }
   else if (!strcmp(string1," it")) {
      return " it";
   }
   else if (!strcmp(string1," they")) {
      return " them";
   }
   if (!strcmp(string1,"i")) {
      return "myself";
   }
   else if (!strcmp(string1,"you")) {
      return "yourself";
   }
   else if (!strcmp(string1,"we")) {
      return "ourselves";
   }
   else if (!strcmp(string1,"he")) {
      return "him";
   }
   else if (!strcmp(string1,"she")) {
      return "her";
   }
   else if (!strcmp(string1,"it")) {
      return "it";
   }
   else if (!strcmp(string1,"they")) {
      return "them";
   }
   else return string1;
}

int is_be(string1)
   char *string1;
{
   if (!strcmp("am",string1))
      return 1;
   else if (!strcmp("is",string1))
      return 1;
   else if (!strcmp("are",string1))
      return 1;
   else if (!strcmp("was",string1))
      return 1;
   else if (!strcmp("were",string1))
      return 1;
   else return 0;
}

int can_spit_out()
{
   int x;
   for (x=1;x<=numwords;x++)
      if (is_possesive(s[x]) || is_sub_pronoun(s[x]) || is_article(s[x]))
         return x;
   return 0;
}

char *cnnv2(string1)
   char *string1;
{
   if (!strcmp(string1," i")) {
      return " me";
   }
   else if (!strcmp(string1," you")) {
      return " you";
   }
   else if (!strcmp(string1," we")) {
      return " us";
   }
   else if (!strcmp(string1," he")) {
      return " him";
   }
   else if (!strcmp(string1," she")) {
      return " her";
   }
   else if (!strcmp(string1," it")) {
      return " it";
   }
   else if (!strcmp(string1," they")) {
      return " them";
   }
   if (!strcmp(string1,"i")) {
      return "me";
   }
   else if (!strcmp(string1,"you")) {
      return "you";
   }
   else if (!strcmp(string1,"we")) {
      return "us";
   }
   else if (!strcmp(string1,"he")) {
      return "him";
   }
   else if (!strcmp(string1,"she")) {
      return "her";
   }
   else if (!strcmp(string1,"it")) {
      return "it";
   }
   else if (!strcmp(string1,"they")) {
      return "them";
   }
   else return string1;
}
