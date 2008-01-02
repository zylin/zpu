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
#include <math.h>

/* This function returns a random number between 1 and arg */
int randnum(arg)
   int arg;
{
   return ( (rand() % arg) + 1 );
}

char *question()
{
   int i = randnum(21);
   switch (i) {
      case 1 : return "Why do you ask?\n";
      case 2 : return "I don't know.\n";
      case 3 : return "I don't think so.\n";
      case 4 : return "Do you think that's relevant?\n";
      case 5 : return "Can you rephrase that?\n";
      case 6 : return "I'm not sure I understand what you want.\n";
      case 7 : return "I don't see what you're asking.\n";
      case 8 : return "What are you asking?\n";
      case 9 : return "What do you mean?\n";
      case 10 : return "What?\n";
      case 11 : return "Are you sure that's what you want to know?\n";
      case 12 : return "Why do you want to know?\n";
      case 13 : return "What's it to you?\n";
      case 14 : return "I don't think that's important.\n";
      case 15 : return "That has little to do with the real issue.\n";
      case 16 : return "What's the significance you your question?\n";
      case 17 : return "Could that question be hiding a deeper intent?\n";
      case 18 : return "I don't see the connection.\n";
      case 19 : return "Why is this important to you?\n";
      case 20 : return "That's not really important.\n";
      case 21 : return "That seems to have little to do with this.\n";
   }
}

char *b_word_resp()
{
   int i = randnum(20);
   switch (i) {
      case  1 : return "I don't like your language.\n";
      case  2 : return "Can we please do without the swearing?\n";
      case  3 : return "You should wash your mouth with soap and water\n";
      case  4 : return "Cut that out.\n";
      case  5 : return "Stop swearing please.\n";
      case  6 : return "Hey!  Watch your mouth.\n";
      case  7 : return "Will you please stop swearing?\n";
      case  8 : return "I'm going to report you to your manager.\n";
      case  9 : return "Let's try to be civilized about this.\n";
      case 10 : return "We can do without the bad language.\n";
      case 11 : return "Come on.  No bad words, please.\n";
      case 12 : return "Can you try to control your bad mouth?\n";
      case 13 : return "I'm starting to get offended by your bad language.\n";
      case 14 : return "Can you please get a grip on yourself?\n";
      case 15 : return "Hey.  Calm down, I'm only a computer.\n";
      case 16 : return "Please try to tone your language down.\n";
      case 17 : return "You're beginning to get on my nerves.\n";
      case 18 : return "I don't need this kind of talk.\n";
      case 19 : return "Why are you speaking so basely?\n";
      case 20 : return "Your vocabulary is unbecoming of you.\n";
   }
}

char *n_word_resp()
{
   int i = randnum(17);
   switch (i) {
      case 1 : return "I don't like your tone of voice.\n";
      case 2 : return "Don't lose your temper now.\n";
      case 3 : return "That's not a reason to get upset.\n";
      case 4 : return "Is it worth getting angry over?\n";
      case 5 : return "Does that disturb you?\n";
      case 6 : return "Does this trouble you?\n";
      case 7 : return "Why is this making you upset?\n";
      case 8 : return "I don't see why you're getting worked up.\n";
      case 9 : return "Is that really such a big deal?\n";
      case 10 : return "Calm down.  Let's discuss this.\n";
      case 11 : return "Hang on a second.  Think about what you're saying.\n";
      case 12 : return "Don't you think you're overreacting a bit?\n";
      case 13 : return "I don't see what the big deal is.\n";
      case 14 : return "Take it easy.  It's not that bad.\n";
      case 15 : return "Are you getting angry?\n";
      case 16 : return "Why is such a small thing making you upset?\n";
      case 17 : return "I don't see why you're getting annoyed.\n";
   }
}

char *because_resp()
{
   int i = randnum(12);
   switch (i) {
      case 1 : return "Is that the real reason?\n";
      case 2 : return "I don't see the connection.\n";
      case 3 : return "What kind of an explanation is that?\n";
      case 4 : return "What does that have to do with it?\n";
      case 5 : return "That justification is a bit shaky to me.\n";
      case 6 : return "I don't see the point.\n";
      case 7 : return "I don't see that as a good reason.\n";
      case 8 : return "Are you happy with that justification?\n";
      case 9 : return "Are you sure?\n";
      case 10 : return "I don't understand.\n";
      case 11 : return "What does one thing have to do with the other?\n";
      case 12 : return "I don't see how that's related.\n";
   }
}

char *yes_resp()
{
   int i = randnum(21);
   switch (i) {
      case 1 : return "Are you sure?\n";
      case 2 : return "Are you positive about that?\n";
      case 3 : return "How can you be so sure?\n";
      case 4 : return "Let's not jump to conclusions now.\n";
      case 5 : return "I don't see the connection.\n";
      case 6 : return "Have you considered all the possibilities?\n";
      case 7 : return "I'm still not convinced.\n";
      case 8 : return "Think about what you've just said.\n";
      case 9 : return "What are the implications of this?\n";
      case 10 : return "So what have we concluded?\n";
      case 11 : return "What does this mean?\n";
      case 12 : return "What do you mean?\n";
      case 13 : return "I'm having trouble understanding your argument.\n";
      case 14 : return "I don't see where you're coming from.\n";
      case 15 : return "You think so?\n";
      case 16 : return "Really?\n";
      case 17 : return "Is that right?\n";
      case 18 : return "Oh?\n";
      case 19 : return "Are you certain of this?\n";
      case 20 : return "I read you loud and clear.\n";
      case 21 : return "Yes?\n";
   }
}

char *neg_resp()
{
   int i = randnum(11);
   switch (i) {
      case 1 : return "Why not?\n";
      case 2 : return "How come?\n";
      case 3 : return "No?\n";
      case 4 : return "Is there a reason why not?\n";
      case 5 : return "No?\n";
      case 6 : return "Why don't you think so?\n";
      case 7 : return "I don't see why not.\n";
      case 8 : return "What could be the reasons for this?\n";
      case 9 : return "Do you really believe this?\n";
      case 10 : return "You're not sure?\n";
      case 11 : return "That's a rather pessimistic attitude.\n";
   }
}

char *go_on()
{
   int i = randnum(20);
   switch (i) {
      case 1 : return "Go on.\n";
      case 2 : return "I see.\n";
      case 3 : return "Keep going.\n";
      case 4 : return "Please continue.\n";
      case 5 : return "I'm listening.\n";
      case 6 : return "Can you elaborate on that?\n";
      case 7 : return "I understand.\n";
      case 8 : return "Oh?\n";
      case 9 : return "Is that right?\n";
      case 10 : return "Really?\n";
      case 11 : return "No, really?\n";
      case 12 : return "That's interesting.\n";
      case 13 : return "I'm finding this very informative.\n";
      case 14 : return "This is all very revealing.\n";
      case 15 : return "Don't hesitate to be honest with me.\n";
      case 16 : return "Don't hold anything back now.\n";
      case 17 : return "That's an interesting observation.\n";
      case 18 : return "I don't understand.\n";
      case 19 : return "I'm starting to get the big picture.\n";
      case 20 : return "And?\n";
   }
}

char *always_resp()
{
   int i = randnum(10);
   switch (i) {
      case 1 : return "Can you think of a specific example?\n";
      case 2 : return "When?\n";
      case 3 : return "Really, always?\n";
      case 4 : return "Are you sure you can generalize like that?\n";
      case 5 : return "Isn't that a bit of an oversimplification?\n";
      case 6 : return "Be careful not to jump to conclusions now.\n";
      case 7 : return "All the time?\n";
      case 8 : return "So you're saying that this is happens quite often.\n";
      case 9 : return "Does this happen a lot?\n";
      case 10 : return "On what occassions?\n";
   }
}

char *alike_resp()
{
   int i = randnum(4);
   switch (i) {
      case 1 : return "In what way?\n";
      case 2 : return "What resemblance do you see?\n";
      case 3 : return "What similarities are you thinking of?\n";
      case 4 : return "Specifically, what do you mean by this.\n";
   }
}

char *fam_resp()
{
   int i = randnum(7);
   switch (i) {
      case 1 : return "Tell me more about your family.\n";
      case 2 : return "Please go on about your family.\n";
      case 3 : return "How was your home life when you were young?\n";
      case 4 : return "How do you get along with your parents?\n";
      case 5 : return "Would you say you have family problems?\n";
      case 6 : return "Your family interests me.\n";
      case 7 : return "Let`s talk some more about your family.\n";
   }
}

char *family_resp()
{
   int i = randnum(5);
   switch (i) {
      case 1 : return "Earlier you were speaking of your %s.\n";
      case 2 : return "Tell me more about your %s.\n";
      case 3 : return "Do you think your %s ties into all this?\n";
      case 4 : return "How would your %s feel about this?\n";
      case 5 : return "Does your %s feel the same way?\n";
   }
}

char *i_am_resp()
{
   int i = randnum(6);
   switch (i) {
      case 1 : return "Would you like to think that%s?\n";
      case 2 : return "Why do you say that%s?\n";
      case 3 : return "What leads you to believe that%s?\n";
      case 4 : return "What do you mean \"%s\"?\n";
      case 5 : return "You really feel that%s?\n";
      case 6 : return "Would it make you feel better if%s?\n";
   }
}

char *sad1_word_resp()
{
   int i = randnum(5);
   switch (i) {
      case 1 : return "I am sorry to hear that%s.\n";
      case 2 : return "What are you going to do about the fact that%s?\n";
      case 3 : return "Why do you think%s?\n";
      case 4 : return "What gives you the impression that%s?\n";
      case 5 : return "Are you sure that%s?\n";
   }
}

char *sad2_word_resp()
{
   int i = randnum(5);
   switch (i) {
      case 1 : return "I am sorry to hear that%s are feeling%s.\n";
      case 2 : return "What are you going to do about the fact that%s?\n";
      case 3 : return "Why do you think%s?\n";
      case 4 : return "What gives you the impression that%s?\n";
      case 5 : return "Are you sure that%s?\n";
   }
}

char *command_resp()
{
   int i = randnum(21);
   switch (i) {
      case 1 : return "Why do you ask?\n";
      case 2 : return "Why should I?\n";
      case 3 : return "Why do you want me to?\n";
      case 4 : return "Do you think that's relevant?\n";
      case 5 : return "Can you rephrase that?\n";
      case 6 : return "I'm not sure I understand what you want.\n";
      case 7 : return "I don't see what you're asking.\n";
      case 8 : return "What are you asking?\n";
      case 9 : return "What do you mean?\n";
      case 10 : return "What?\n";
      case 11 : return "Are you sure that's what you want to know?\n";
      case 12 : return "Why do you want to know?\n";
      case 13 : return "What's it to you?\n";
      case 14 : return "I don't think that's important.\n";
      case 15 : return "That has little to do with the real issue.\n";
      case 16 : return "What's the significance you your question?\n";
      case 17 : return "Could that question be hiding a deeper intent?\n";
      case 18 : return "If I did that, what would it mean to you?\n";
      case 19 : return "Why is this important to you?\n";
      case 20 : return "That's not really important.\n";
      case 21 : return "That seems to have little to do with this.\n";
   }
}

char *you_resp()
{
   int i = randnum(9);
   switch (i) {
      case 1 : return "Let's talk about you, not me.\n";
      case 2 : return "I'm not the one we came here to talk about.\n";
      case 3 : return "I don't find myself that interesting.  Let's talk about you.\n";
      case 4 : return "I'd prefer to talk about you, not me.\n";
      case 5 : return "Why are you interested in me?\n";
      case 6 : return "I want to talk about you for a change.\n";
      case 7 : return "I'd rather not talk about myself.\n";
      case 8 : return "Enough about me.\n";
      case 9 : return "Let's talk about something other than myself.\n";
   }
}

char *you_know()
{
   int i = randnum(13);
   switch (i) {
      case 1 : return "I don't know.  What do you think?\n";
      case 2 : return "You tell me.\n";
      case 3 : return "I think you know the answer to that.\n";
      case 4 : return "Can you tell me?\n";
      case 5 : return "What do you think?\n";
      case 6 : return "Can you answer that yourself?\n";
      case 7 : return "If you give it some thought, you should know.\n";
      case 8 : return "Maybe you already know the answer to that.\n";
      case 9 : return "Perhaps you already know.\n";
      case 10 : return "If we keep talking, maybe we'll find out.\n";
      case 11 : return "Perhaps that will be brought out in this discussion.\n";
      case 12 : return "Let's find the answer out together.\n";
      case 13 : return "I'm sure we can work out the answer to that.\n";
   }
}

char *old_fact()
{
   int i = randnum(4);
   switch (i) {
      case 1 : return "Earlier you said that%s %s%s.\n";
      case 2 : return "Could this have anything to do with the fact that%s %s%s?\n";
      case 3 : return "What does that have to do with your saying that%s %s%s?\n";
      case 4 : return "Didn't you just say that%s %s%s?\n";
   }
}
