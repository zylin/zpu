/*    Govern ancient Sumeria.    Heavily modified by Mike Arnautov 1975.
 *    Converted from Basic to PR1ME Fortran (mode 32R) MLA 1979.
 *    Rev.19.1, GGR version 14 Oct 83. MLA
 *    Converted to ANSI C December 2001. MLA
 */

#include <stdio.h>
#include <time.h>
#include <math.h>

int year_term;
int year_abs;
int percent_starved;
int dead_total;
int starved;
int population;

char reply [160];

void try_again (int reason)
{
   if (reason == 1)
      puts ("For the extreme folly of soft - heartedness and");
   if (reason)
   {
      printf ("%considering ", reason == 3 ? 'C' : 'c');
      puts ("the mess you would leave the city in,");
      puts ("you are hereby commanded to remain in office for");
      puts ("another ten years. May your fate be a lesson and");
      puts ("a warning for generations to come.");
   }
   else
   {
      puts ("Hamurabe, you are either a politico-economic genius");
      puts ("or just a lucky bastard. There being but one way to");
      puts ("settle the question, you are hereby requested to stay");
      puts ("in office for another ten years.");
   }
   year_term = 0;
   year_abs--;
   percent_starved = starved * 100.0 / population;
   dead_total = starved;
}

float rnd (void)
{
   return ((rand () % 1000) / 1000.0);
}

int iabs (int value)
{
   return ((value >= 0) ? value : -value);
}

void terminate (int abort)
{
   if (abort == 2)
   {
      puts ("For this extreme mismanagement you have been");
      puts ("deposed, flayed alive and publicly beheaded.");
      puts ("\nMay Ashtaroth preserve your Ka.\n");
   }
   else if (abort == 1)
   {
      puts ("\nHamurabe:  I find myself unable to fulfil your wish.");
      puts ("You will have to find yourself another kingdom.");
   }
   if (abort != 2)
      puts ("\nMay Baal be with you.\n");
   exit (0);
}
   
void think_again (char *what, int quantity)
{
   if (*what == 'l' || *what == 'g')
      printf ("Hamurabe, think again. ");
   if (*what == 'l')
      printf ("You own %d acres of land.", quantity);
   else if (*what == 'g')
      printf ("You have only %d bushels of grain.", quantity);
   else
      printf ("But you only have %d people to tend the fields.", population);
   puts (" Now then,");
}
int query (char *prompt)
{
   while (1)
   {
      int sign;
      int value;
      char * cptr;
      
      printf (prompt);
      fgets (reply, sizeof (reply) - 1, stdin);
      value = 0;
      sign = 1;
      cptr = reply;
      while (*cptr == ' ' || *cptr == '\t') cptr++;
      if (*cptr == '-')
      {
         cptr++;
         sign = -1;
      }
      if (*cptr == 'q' || *cptr == 'Q')
         terminate (1);
      while (*cptr && *cptr != '\n')
      {
         if (*cptr >= '0' && *cptr <= '9')
            value = 10 * value + *cptr - '0';
         else if (*cptr == '.')
            break;
         else if (*cptr != '.')
         {
            sign = 0;
            break;
         }
         cptr++;
      }
      if (sign)
         return (sign * value);
      puts ("Hamurabe, your command has not been understood!");
   }   
}

int main ()
{
   int acreage;
   int immigration;
   int second_term;
   int dead_total;
   int stores;
   int harvest;
   int rat_food;
   int yield;
   int rounded_price;
   int sell;
   int buy;
   int plant;
   int food;
   int transaction;
   int rats;
   int plague_deaths;
   int survived;
   int dead_rats;
   int tmp_int;

   float price;
   float breadline;
   float provisions;
   float plague;
   float acres_per_head;
   float acres_per_init;
   float stores_per_head;
   float rats_ate;
   float rat_log;
   float percent_starved;
   float tmp_float;
   
   printf ("[Sumeria (Primos) rev.19.1, GGR (MLA) version 14 Oct 83]\n");
   puts ("[Conversion to ANSI C: MLA, Feb 2002]\n");
   while (1)
   {
      printf ("Do you know how to play? ");
      fgets (reply, sizeof(reply) - 1, stdin);
      if (*reply == '\n') break;
      *reply += (*reply < 'a') ? 'a' - 'A' : 0;
      if (*reply == 'y') break;
      if (*reply != 'n' && *reply != 'q') continue;
      puts ("\nToo bad!\n");
      break;
   }
  
   srand (time (NULL));
   *(reply + sizeof (reply) - 1) = '\0';
   
   puts ("Try your hand at governing ancient Sumeria");
   puts ("for a ten year term of office.");

   second_term = 0;
   dead_total = 0;
   percent_starved = 0;
   year_term = 0;
   year_abs = 0;
   acres_per_init = 10;
   population = 100;
   stores = 2800;
   harvest = 3000;
   rat_food = 200;
   yield = 3;
   acreage = 1000;
   immigration = 5;
   transaction = 0;
   price = 18 + 6 * rnd ();
   breadline = 19 + 4 * rnd ();
   provisions = breadline;
   rats = 1000;
   rat_log = 3;
   plague = rnd () / 2;
   starved = 0;

year_term = year_abs = 9;
   while (1)
   {
      
      while (1)
      {
         year_term++;
         year_abs++;
         putchar ('\n');
         acres_per_head = ((float) acreage) / population;
         stores_per_head = ((float) stores) /population;
         puts ("Hamurabe: I beg to report to you,");
         printf ("In year %d, ", year_abs);
         if (starved > 0)
            printf ("%ld", starved);
         else
            printf ("no");
         printf (" %s starved, %ld came to the city.\n", 
            starved <= 1 ? "person" : "people", immigration);
         if (plague >= 0.85)
            printf ("A horrible plague struck! %d people died.\n", 
               plague_deaths);
         printf ("Population is now %ld.\n", population);
         printf ("The city owns %ld acres.\n", acreage);
         printf ("You harvested %ld bushels per acre.\n", yield);
         printf ("Rats ate %ld bushels.\n", rat_food);
         printf ("You now have %ld bushels in store.\n\n", stores);

         if (year_term == 11) 
            break;
         rounded_price = price + 0.5;
         printf ("Land is trading at %ld bushels per acre.\n\n", rounded_price);

         while (1)
         {
            buy = query ("How many acres do you wish to buy? ");
            if (rounded_price * buy <= stores)
               break;
            think_again ("grain", stores);
         }
         if (buy > 0)
         {
            acreage += + buy;
            stores -= rounded_price * buy;
            transaction = buy;
         }
         else
         {
            while (1)
            {
               sell = query ("How many acres do you wish to sell? ");
               if (sell <= acreage)
                  break;
               think_again ("land", acreage);
            }
            acreage -= sell;
            stores += rounded_price * sell;
            transaction = -sell;
         }
      
         putchar ('\n');
         while (1)
         {
            food = query ("How many bushels do you wish to feed your people? ");
            if (food <= stores)
               break;
            think_again ("grain", stores);
         }
         stores -= food;
         putchar ('\n');
         while (1)
         {
            plant = query ("How many acres do you wish to plant with seed? ");
            if (plant <= acreage && plant <= 2 * stores && 
                plant <= 10 * population)
               break;
            if (plant > acreage)
               think_again ("land", acreage);
            else if (plant > 2 * stores)
               think_again ("grain", stores);
            else
               think_again ("people", population);
         }
   
         stores -= plant / 2;
         yield = 4 * rnd() + 1.65;
         harvest = plant * yield;
         rat_food = 0;
         rats_ate = stores * (rat_log - 2.2) / 3.6;
         dead_rats = rats - 4 * rats_ate;
         rats = 3 * rats;
         if (dead_rats > 0) rats = rats - dead_rats;
   
         if (plague >= 0.3) 
         {
            if (plague >= 0.85)
            {
               if (plague > 1) plague = 1;
               rats = 500 + 5000 * (plague - 0.7);
            }
            else
               rats *= 1.225 - 0.75 * plague;
         }
   
         if (rats < 500)
            rats = 500;
         rat_food = rats / 4;
         if (rats_ate < rat_food)
            rat_food = rats_ate;
         rat_food *= 7;
         if (rat_food <= 20) 
            rat_food = 20 + 30 * rnd();
         stores += harvest - rat_food;
         rat_log = log10 (1.0 * rats);
         if (stores + stores <= harvest)
         {
            rat_food = harvest * (1 + rnd()) / 4.0;
            stores = harvest - rat_food;
         }
   
         tmp_int = 100 + iabs (100 - population);
         immigration = tmp_int * ((acres_per_head + 
            stores_per_head - 36) / 250.0 + 
               (provisions - breadline + 2.5) / 40) + .5;
         if (immigration <= 0) 
            immigration = 5 * rnd() + 1;
         survived = food / breadline;
         provisions = (1.0 * food) / population;
         plague = (2 * rnd() + rat_log - 3) / 3.0;
         if (population < survived) 
            survived = population;
         else
         {
            starved = population - survived;
            if (starved >= 0.45 * population)
            {
               printf ("\nYou starved %d people in one year!\n", starved);
               terminate (2);
            }
            percent_starved = ((year_term - 1) * percent_starved + 
               100.0 * starved / population) / year_term;
            population = survived;
            dead_total += starved;
         }
         population += immigration;
         price = (price + 15 + (stores_per_head - acres_per_head) / 3) / 2 + 
            transaction / 50 + 3 * rnd() - 2;
         if (price <1.0) price = 1.0;
         if (plague >= 0.85)
         {
            plague_deaths = population * (0.429 * plague - 0.164);
            population -= plague_deaths;
         }
      }
   
      printf ("In your ten year term of office %d people starved.\n",
         dead_total);
      printf ("You started with %0.2f acres per person and ended\n",
         acres_per_init);
      acres_per_head = (1.0 * acreage) / population;
      acres_per_init = acres_per_head;
      printf ("with %0.2f acres per person.\n\n", acres_per_head);
   
      tmp_float = 10 * acres_per_head / 3;
      if (percent_starved > 25)
         terminate (2);
      if (percent_starved <= 7)
      {
         try_again (1);
         continue;
      }
      if (tmp_float < 7) 
         terminate (2);
      if (tmp_float > 10)
      {
         puts ("Your heavy handed performance smacks of Nabuchodonoser");
         puts ("and Asurbanipal II. The surviving populace hates your");
         puts ("guts and your eventual assasination is just a matter of");
         puts ("time.");
         terminate (0);
      }
      puts ("Consequently you have been deposed and disgraced");
      puts ("and only avoided a public punishment because");
      puts ("of mitigating circumstances. While it may be");
      puts ("admitted in private that you had a rotten deal");
      tmp_int = 3 * rnd();
      if (tmp_int == 0)
         puts ("try explaining that to a mob looking for scape-goats.");
      if (tmp_int == 1)
         puts ("history is not interested in such petty excuses.");
      if (tmp_int == 2)
      {
         puts ("you should have considered such occupational hazards");
         puts ("before applying for the job.");
      }
      terminate (0);
      
      if (acres_per_head < 7)
      {
         try_again (1);
         continue;
      }
      if (acres_per_head < 9)
      {
         puts ("Your performance has been satisfactory and, in the");
         puts ("perspective of history, actually quite good.");
         if (rnd() >= 0.5) 
         {
            puts ("You may not be exactly popular, but given a good");
            puts ("body-guard there is nothing to be really worried about.");
         }
         else
         {
            puts ("While not exactly loved, you are at least respected.");
            puts ("What more can a realistic ruler ask for?");
         }
      }
      else if (second_term == 0)

      if (second_term == 0)
      {
         if (stores <= 10 * population)
         {
            try_again (3);
            continue;
         }
         second_term = 1;
         try_again (0);
         continue;
      }
      else
      {
         puts ("Hamurabe, your name will be remembered through the");
         puts ("ages to come with admiration and respect.\n");
         puts ("(So you did get away with it you lucky sod!)");
      }
      if (stores > 10 * population)
         terminate (0);
      puts ("\n                            HOWEVER\n\n");
      second_term = 0;
      try_again (2);
      continue;
   }
}
