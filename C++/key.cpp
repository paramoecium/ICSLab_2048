/****************************************************************************
  File       [ key.cpp ]
  Synopsis   [ Utility functions for keyboard mapping ]
  Package    [ General purpose ]
  Author     [ Kung-Nien Yang, B99901027, NTUEE ]
****************************************************************************/

#include <conio.h>
#include <cctype>  // isprint()
#include "key.h"

#ifdef KEY_TEST
#include <iostream>
#include <iomanip>
using namespace std;
#endif // KEY_TEST

int getc()
{
   int c = _getch();
   #ifdef KEY_TEST
   cout << setw(5) << left << c;
   cout << right;  // default
   #endif // KEY_TEST
   return c;
}

Key getKeyPress()
{
   int ch = getc();
   switch(ch)
   {
      case KEY_LINE_BEGIN:
      case KEY_LINE_END:
      case KEY_INPUT_END:
      case KEY_BACKSPACE:
      case KEY_TAB:
      case KEY_NEW_LINE:
      case KEY_ENTER:
      case KEY_ESC:
         return Key(ch);

      case COMBO_PREFIX:
      {
         ch = getc();
         switch(ch + FLAG_NAV)
         {
            case KEY_HOME:
            case KEY_END:
            case KEY_PG_UP:
            case KEY_PG_DOWN:
               return Key(ch + FLAG_NAV);
         }
         switch(ch + FLAG_ARROW)
         {
            case KEY_ARROW_UP:
            case KEY_ARROW_DOWN:
            case KEY_ARROW_LEFT:
            case KEY_ARROW_RIGHT:
               return Key(ch + FLAG_ARROW);
         }
         switch(ch + FLAG_EDIT)
         {
            case KEY_INSERT:
            case KEY_DELETE:
               return Key(ch + FLAG_EDIT);
         }
         return KEY_UNDEF;
      }  // case COMBO_PREFIX

      default:
      {
         if(isprint(ch))
            //return Key(ch + FLAG_PRINT);
            return Key(ch);
         clearKbBuf();
         return KEY_UNDEF;
      }
   }  // switch(ch)
}

char key2Char(Key k)
{
   return char(CHAR_MASK & k);
}

bool isPrintKey(Key k)
{
   int flag = FLAG_MASK & k;
   int ch = CHAR_MASK & k;
   return (flag == 0 && isprint(ch));
}

bool isArrowKey(Key k)
{
   return ((FLAG_MASK & k) == FLAG_ARROW);
}

void clearKbBuf()
{
   while(_kbhit()) getc();
}

