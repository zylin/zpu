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

#include <stdio.h>
#include "parse.h"
#include "response.h"

typedef char WORD[40];
typedef WORD SENTENCE[200];

int numwords;
SENTENCE s;
WORD fam_member;    /* If mentioned a member of family, save for later. */
int fam;

main() {
   int x, y, loop = 1, fact = 0;
   char instring[200], outstring[200], sub[200], vrb[200], rst[200], qwd[200];
   char osub[200], ovrb[200], orst[200];
   fam = 0;
   printf("Hello there.  My name is Eliza and I was written by Mohan Embar.\n");
   printf("Please type \"END\" to end this session.\n");
   printf("I'm here to help you if I can.  What seems to be the trouble?\n");
   while (loop) {
      printf("\n");
      gets(instring);
      printf("\n");
      parse(instring);
      if (numwords == 0) {
         switch (x = randnum(2)) {
            case 1 : printf("Don't you have anything to say?\n");
               break;
            case 2 : printf("Cat got your tongue?\n");
               break;
         }
         continue;
      }
      if (!strcmp(s[1],"END")) {
         printf("Goodbye.  Please come again.\n");
         break;
      }
      agree();
      if (bad_word())
         printf(b_word_resp());
      else if (naughty_word())
         printf(n_word_resp());
      else if (x = family()) {
         fam = x;
         printf(fam_resp());
         strcpy(fam_member,s[fam]);
      }
      else if (sword("ALIKE",1))
         printf(alike_resp());
      else if (sword("ALWAYS",1))
         printf(always_resp());
      else if (sword("BECAUSE",1))
         printf(because_resp());
      else if (sword("YES",1))
         printf(yes_resp());
      else if (sword("NO",1) || sword("NOT",1))
         printf(neg_resp());
      else if (x = i_am()) { /* If occurrence of I AM x.. */
         get_til_stop(x,outstring);    /* Get I AM x .. into outstring */
         printf(i_am_resp(),outstring); /* Print reponse for this */
      }
      else if (real_quest() ||
              (is_helper(s[1]) && is_sub_pronoun(s[2])) ||
              sub_and_helper()) {
         if (real_quest()) {
            strcpy(qwd,s[1]);
            strcpy(vrb,s[2]);
            strcpy(sub,s[3]);
            get_til_stop(4,rst);
         }
         else if (is_helper(s[1]) && is_sub_pronoun(s[2])) {
            strcpy(vrb,s[1]);
            strcpy(sub,s[2]);
            get_til_stop(3,rst);
            strcpy(qwd,"YES");
         }
         else if (sub_and_helper()) {
            x = find_helper();
            y = search_back_sub(x);
            strcpy(vrb,s[x]);
            get_til_stop(x+1,rst);
            getrange(y,x-1,sub);
            strcpy(qwd,"NO");
         }
         make_lower(qwd);
         if (strcmp(sub,"I")) make_lower(sub);
         make_lower(vrb);
         make_lower(rst);
         /* First do x verb y responses */

         /*
	 printf("\n*** %s\n",sub);
         */
	 
	 if (!strcmp(sub," I") || !strcmp(sub,"I")) {
            printf(you_resp());
         }
         else if (!strcmp(qwd,"no")) {
            /* Record this statement for later use. */
            fact = 1;
            strcpy(osub,sub); strcpy(ovrb,vrb); strcpy(orst,rst);
            if (is_be(vrb) && !strcmp(sub," you") && (y = sad_word())) {
               getrange(y,y,outstring);
               x = randnum(5)+6;
            }
            else if (is_be(vrb) && (y = sad_word())) {
               getrange(y,y,outstring);
               x = randnum(2)+11;
            }
            else if (is_be(vrb))
               x = randnum(6);
            else x = randnum(4);
            switch (x) {
               case 1 : printf("How do you feel about%s?\n",cnnv(sub));
                  break;
               case 2 : printf("Why %s%s%s?\n",vrb,sub,rst);
                  break;
               case 3 : for (y=1;sub[y]=sub[y--];y=y+2);
                  sub[0] = toupper(sub[0]);
                  printf("%s %s%s?\n",sub,vrb,rst);
                  break;
               case 4 : printf("Could you describe%s for me?\n",cnnv(sub));
                  break;
               case 5 : printf("What if%s were not%s?\n",sub,rst);
                  break;
               case 6 : printf("Would you be happy if%s were not%s?\n",sub,
                                rst);
                  break;
               case 7 : printf("I'm sorry to hear that you are%s.\n",outstring);
                  break;
               case 8 : printf("Do you think that coming here will help you not to be%s?\n",outstring);
                  break;
               case 9 : printf("Let's talk about why you feel%s.\n",outstring);
                  break;
               case 10 : printf("What happened that made you feel%s?\n",outstring);
                  break;
               case 11 : printf("What could be the reason for your feeling%s?\n",outstring);
                  break;
               case 12 : printf("What could cause%s to be%s?\n",cnnv(sub),outstring);
                  break;
               case 13 : printf("If%s came here, would it help%s not to be%s?\n",sub,cnnv(sub),outstring);
                  break;
            }
         }
         else if (!strcmp(sub,"you"))
            printf(you_know());
         else if (!strcmp(qwd,"yes")) {
            x = randnum(8);
            switch (x) {
               case 1 : printf("You want to know if %s %s%s.\n",sub,vrb,rst);
                  break;
               case 2 : printf("If %s %s%s, does that concern you?\n",sub,vrb,rst);
                  break;
               case 3 : printf("What are the consequences if %s %s%s?\n",sub,vrb,rst);
                  break;
               case 4 : printf("Why does %s concern you?\n",sub);
                  break;
               case 5 : printf("Why are you thinking of %s?\n",cnnv(sub));
                  break;
               case 6 : printf("Tell me more about %s.\n",cnnv(sub));
                  break;
               case 7 : printf("To answer that, I'd need to know more about %s.\n",cnnv(sub));
                  break;
               case 8 : printf("What is the relationship between you and %s?\n",cnnv(sub));
                  break;
               case 9 : printf("Why don't you ask %s?\n",cnnv(sub));
                  break;
            }
         }
         else {
            x = randnum(8);
            switch (x) {
               case 1 : printf("You want to know %s %s %s%s.\n",qwd,sub,vrb,rst);
                  break;
               case 2 : printf("If %s %s%s, does that concern you?\n",sub,vrb,rst);
                  break;
               case 3 : printf("What are the consequences if %s %s%s?\n",sub,vrb,rst);
                  break;
               case 4 : printf("Why does %s concern you?\n",sub);
                  break;
               case 5 : printf("Why are you thinking of %s?\n",cnnv(sub));
                  break;
               case 6 : printf("Tell me more about %s.\n",cnnv(sub));
                  break;
               case 7 : printf("To answer that, I'd need to know more about %s.\n",cnnv(sub));
                  break;
               case 8 : printf("What is the relationship between you and %s?\n",cnnv(sub));
                  break;
               case 9 : printf("Why don't you ask %s?\n",cnnv(sub));
                  break;
            }
         }
      }
      else if (is_command())
         printf(command_resp());
      else if (vague_quest())
         printf(question());
      else if ((s[numwords][0] == '?') && !real_quest())
         printf(question());
      else if (x = sad_word()) {
         getrange(x,x,outstring);
         for (y=1;outstring[y]=outstring[y--];y=y+2);
         outstring[0] = toupper(outstring[0]);
         printf("%s?\n",outstring);
      }
      else if (x = can_spit_out()) {
         if (x<=(numwords-2) && is_sub_pronoun(s[x])
                             && (matches("NEED",s[x+1]) ||
                                 matches("WANT",s[x+1]))) {
            get_til_stop(x+2,outstring);
            strcpy(sub,s[x]);
            if (strcmp(sub,"I")) make_lower(sub);
            if (strcmp(s[x],"I")) make_lower(s[x]);
            x = randnum(6);
            switch (x) {
               case 1 : printf("What would it mean to %s if %s got%s?\n",cnnv2(s[x]),sub,outstring);
                  break;
               case 2 : printf("Would %s really be happy if %s got%s?\n",sub,sub,outstring);
                  break;
               case 3 : printf("Why is getting%s so desirable?\n",outstring);
                  break;
               case 4 : printf("Okay.  Suppose %s got%s.  Then what?\n",sub,outstring);
                  break;
               case 5 : printf("Why is this important to %s?\n",cnnv2(sub));
                  break;
               case 6 : printf("What price would %s pay to achieve this?\n",sub);
                  break;
            }
         }
         else {
            get_til_stop(x,outstring);
            outstring[1]=toupper(outstring[1]);
            printf("%s.\n",outstring+1);
         }
      }
      else if (fam) {
         make_lower(fam_member);
         printf(family_resp(),fam_member);
         fam = 0;
      }
      else if (fact && (randnum(5)==3)) {
         printf(old_fact(),osub,ovrb,orst);
         fact = 0;
      }
      else {
         printf(go_on());
      }
   }
}
