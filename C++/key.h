/****************************************************************************
  File       [ key.h ]
  Synopsis   [ Definitions for keyboard mapping ]
  Package    [ General purpose ]
  Author     [ Kung-Nien Yang, B99901027, NTUEE ]
****************************************************************************/

#ifndef KEY_H
#define KEY_H

#include <climits>  // INT_MAX

#define FLAG_MASK ((int)-0x100)  // = 0xffffff00 for 32-bit int
#define CHAR_MASK (~FLAG_MASK)   // = 0x000000ff for 32-bit int

enum Key
{
   // simple keys
   KEY_LINE_BEGIN   = 1,          // Ctrl-a
   KEY_LINE_END     = 5,          // Ctrl-e
   KEY_INPUT_END    = 4,          // Ctrl-d
   KEY_BACKSPACE    = int('\b'),  // 8, BACKSPACE or Ctrl-h
   KEY_TAB          = int('\t'),  // 9, TAB or Ctrl-i
   KEY_NEW_LINE     = int('\n'),  // 10, Ctrl-ENTER or Ctrl-j
   KEY_ENTER        = int('\r'),  // 13, ENTER or Ctrl-m
   KEY_ESC          = 27,


   // combo keys
   COMBO_PREFIX     = 224,

   // - flags
   FLAG_NAV         = 1 << 8,   // navigation
   FLAG_ARROW       = 1 << 9,   // arrow
   FLAG_EDIT        = 1 << 10,  // editing
   //FLAG_PRINT       = 1 << 11,  // printable

   // - navigation keys
   KEY_HOME         = 71 + FLAG_NAV,
   KEY_END          = 79 + FLAG_NAV,
   KEY_PG_UP        = 73 + FLAG_NAV,
   KEY_PG_DOWN      = 81 + FLAG_NAV,

   // - arrow keys
   KEY_ARROW_UP     = 72 + FLAG_ARROW,
   KEY_ARROW_DOWN   = 80 + FLAG_ARROW,
   KEY_ARROW_LEFT   = 75 + FLAG_ARROW,
   KEY_ARROW_RIGHT  = 77 + FLAG_ARROW,

   // - editing keys
   KEY_INSERT       = 82 + FLAG_EDIT,
   KEY_DELETE       = 83 + FLAG_EDIT,


   // special characters
   CHAR_BEEP        = int('\a'),  // 7, Ctrl-g

   // undefined keys
   KEY_UNDEF        = INT_MAX - 1,

   // dummy end
   KEY_DUMMY_END
};

int  getc();           // interface for _getch()
Key  getKeyPress();    // get pressed key
char key2Char(Key);    // convert Key to char
bool isPrintKey(Key);
bool isArrowKey(Key);
void clearKbBuf();     // clear keyboard buffer



#endif // KEY_H
