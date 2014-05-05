/****************************************************************************
  File       [ main.cpp ]
  Synopsis   [ Main function for 2048 game ]
  Package    [ 2048 ]
  Author     [ Kung-Nien Yang, B99901027, NTUEE ]
  Version    [ 1.0 (2014/04/17) ]
****************************************************************************/

#include <iostream>
#include <iomanip>
#include <cstdlib>    // rand(), srand()
#include <ctime>      // time()
#include <cassert>    // assert()
#include <windows.h>  // for moveCursor()
#include "key.h"
#include "cell.h"
#include "clearscreen.h"
using namespace std;

/***********************
/ Constant definitions /
***********************/
#define HEI        4     // height
#define WID        4     // width
#define MAX_NUM    2048  // maximum number

#define RAND_SEED  (time(0))

//#define CLS_CMD    "cls"

/*******************
/ Global variables /
*******************/
Cell **mat = 0;  // cell matrix

enum Status
{
   INVALID = 0,
   MOVE_UP,
   MOVE_DOWN,
   MOVE_LEFT,
   MOVE_RIGHT,
   QUIT,
   RESTART
}
stat;

/************************
/ Function declarations /
************************/
void    initMat();        // initialize the matrix
bool    moveCell(Cell*, Cell*);  // move the cell from A to B
bool    genRand24();      // generate random 2 or 4
void    printMat();       // print matrix
void    printInstr();     // print instruction
Status  parseKey(Key);    // parse input key
bool    gameOver();
int     randInt(int);     // random integer
void    beep();           // output beep sound
void    moveCursor(int, int);  // move the cursor to specified point

/****************
/ Main function /
****************/
int main()
{
   // initialization
   mat = new Cell*[HEI];
   for(int i = 0; i < HEI; ++i)
      mat[i] = new Cell[WID];
   initMat();
   srand(RAND_SEED);

   // game starts
   ClearScreen();
   while(1)
   {
      //system(CLS_CMD);
      moveCursor(0, 0);
      printMat();
      cout << endl;
      printInstr();

      if(gameOver())
      {
         cout << "Restart? (y/N) ";
         if(getKeyPress() == Key(int('y')))
            stat = RESTART;
         else
            break;
      }
      else
      {
         Key kpress = getKeyPress();
         while((stat = parseKey(kpress)) == INVALID)
            kpress = getKeyPress();
      }

      if(stat == QUIT) break;

      if(stat == RESTART) initMat();
      else  // arrow keys
      {
         assert(stat == MOVE_UP || stat == MOVE_DOWN ||
                stat == MOVE_LEFT || stat == MOVE_RIGHT);

         Cell::setMoved(false);
         Cell::resetGlobalRef();
         switch(stat)
         {
         case MOVE_UP:
            for(int i = 1; i < HEI; ++i)
               for(int j = 0; j < WID; ++j)
               {
                  int k = 0;
                  while(moveCell(&mat[i-k][j], &mat[i-k-1][j]))
                  {
                     ++k;
                     if(i-k-1 < 0) break;
                  }
               }
            break;
         case MOVE_DOWN:
            for(int i = HEI - 2; i >= 0; --i)
               for(int j = 0; j < WID; ++j)
               {
                  int k = 0;
                  while(moveCell(&mat[i+k][j], &mat[i+k+1][j]))
                  {
                     ++k;
                     if(i+k+1 > HEI - 1) break;
                  }
               }
            break;
         case MOVE_LEFT:
            for(int i = 0; i < HEI; ++i)
               for(int j = 1; j < WID; ++j)
               {
                  int k = 0;
                  while(moveCell(&mat[i][j-k], &mat[i][j-k-1]))
                  {
                     ++k;
                     if(j-k-1 < 0) break;
                  }
               }
            break;
         case MOVE_RIGHT:
            for(int i = 0; i < HEI; ++i)
               for(int j = WID - 2; j >= 0; --j)
               {
                  int k = 0;
                  while(moveCell(&mat[i][j+k], &mat[i][j+k+1]))
                  {
                     ++k;
                     if(j+k+1 > WID - 1) break;
                  }
               }
            break;
         default:
            break;
         } // switch(stat)

         if(Cell::getMoved())
         {
            Cell::resetGlobalRef();
            genRand24();
         }
         else
            ;//beep();
      } // arrow keys

   } // while(1)
   // game ends

   // delete dynamic arrays
   for(int i = 0; i < HEI; ++i)
      delete [] mat[i];
   delete [] mat;

   return 0;
}

/***********************
/ Function Definitions /
***********************/
void initMat()
{
   Cell::resetGlobalRef();
   for(int i = 0; i < HEI; ++i)
      for(int j = 0; j < WID; ++j)
         mat[i][j] = 0;
   genRand24();
   genRand24();
}

bool moveCell(Cell *from, Cell *to)
{
   // return true if the cell is moved to an empty cell
   // Cell::_moved = true if the cell is moved
   // Cell::_moved = unchange if no movement is performed
   if(*from == 0)
      return false;
   if(*to == 0)
   {
      *to = *from;
      *from = 0;
      Cell::setMoved(true);
      return true;
   }
   if(*from == *to && !to->isMarked())
   {
      *to += *from;
      *from = 0;
      Cell::setMoved(true);
      to->mark();
      return false;
   }
   return false;
}

bool genRand24()
{
   int step = -1, rn = randInt(HEI * WID * 4);
   // note: the higher the bound for rn, the more uniform the
   //       probabilities of the cells being chosen

   while(1)
   {
      for(int i = 0; i < HEI; ++i)
      {
         for(int j = 0; j < WID; ++j)
         {
            if(mat[i][j] == 0) ++step;
            if(step == rn)
            {
               // the probability of generating a 4 is 1/8
               if(randInt(8)) mat[i][j] = 2;
               else mat[i][j] = 4;
               mat[i][j].mark();
               return true;
            }
         } // for j
      } // for i
      if(step == -1) break;  // no more empty cells
   } // while(1)

   return false;
}

void printMat()
{
   for(int i = 0; i < HEI; ++i)
   {
      for(int j = 0; j < WID; ++j) cout << "+------";
      cout << "+" << endl;
      for(int j = 0; j < WID; ++j) cout << "|      ";
      cout << "|" << endl;
      for(int j = 0; j < WID; ++j)
      {
         cout << "|";
         if(mat[i][j].getVal())
            cout << setw(5) << right << mat[i][j].getVal();
         else
            cout << "     ";
         cout << ((mat[i][j].isMarked()) ? "*" : " ");
      }
      cout << "|" << endl;
      for(int j = 0; j < WID; ++j) cout << "|      ";
      cout << "|" << endl;
   }
   for(int j = 0; j < WID; ++j) cout << "+------";
      cout << "+" << endl;
}

void printInstr()
{
   cout << "|  Arrows: Move  "
        << "|  Ctrl-d: Quit  "
        << "|  r: Restart  "
        << "|  " << endl;
}

Status parseKey(Key k)
{
   switch(k)
   {
   case KEY_ARROW_UP:    return MOVE_UP;
   case KEY_ARROW_DOWN:  return MOVE_DOWN;
   case KEY_ARROW_LEFT:  return MOVE_LEFT;
   case KEY_ARROW_RIGHT: return MOVE_RIGHT;
   case KEY_INPUT_END:   return QUIT;
   case Key(int('r')):   return RESTART;
   default:              return INVALID;
   }
}

bool gameOver()
{
   for(int i = 0; i < HEI; ++i)
      for(int j = 0; j < WID; ++j)
         if(mat[i][j] == MAX_NUM)
         {
            cout << endl << "Congratulations! You win!" << endl;
            return true;
         }

   // return false if there are empty cells ...
   // ... or cells that can be eliminated
   for(int i = 0; i < HEI; ++i)
      for(int j = 0; j < WID; ++j)
      {
         if(mat[i][j] == 0) return false;
         if(i < HEI - 1)
            if(mat[i][j] == mat[i+1][j]) return false;
         if(j < WID - 1)
            if(mat[i][j] == mat[i][j+1]) return false;
      }

   cout << endl << "Sorry, you lose!" << endl;
   return true;
}

int randInt(int bound)
{
   int randNum = rand();
   if(randNum == RAND_MAX) return (bound - 1);
   return int(bound * (double(randNum) / RAND_MAX));
}

void moveCursor(int x, int y)
{
   COORD co = {x, y};
   SetConsoleCursorPosition(GetStdHandle(STD_OUTPUT_HANDLE), co);
}

void beep()
{
   cout << '\a';
}

