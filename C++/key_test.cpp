#include <iostream>
#include "key.h"
using namespace std;

int main()
{
   Key k;
   cout << "Press Ctrl-d to quit." << endl;
   while(1)
   {
      k = getKeyPress();
      switch(k)
      {
         case KEY_LINE_BEGIN:  cout << "Line begin" << endl; break;
         case KEY_LINE_END:    cout << "Line end" << endl; break;
         case KEY_INPUT_END:   cout << "End of input" << endl; break;
         case KEY_BACKSPACE:   cout << "BACKSPACE" << endl; break;
         case KEY_TAB:         cout << "TAB" << endl; break;
         case KEY_NEW_LINE:    cout << "New line" << endl; break;
         case KEY_ENTER:       cout << "ENTER" << endl; break;
         case KEY_ESC:         cout << "ESC" << endl; break;

         case KEY_HOME:        cout << "HOME" << endl; break;
         case KEY_END:         cout << "END" << endl; break;
         case KEY_PG_UP:       cout << "PAGE UP" << endl; break;
         case KEY_PG_DOWN:     cout << "PAGE DOWN" << endl; break;

         case KEY_ARROW_UP:    cout << "ARROW UP" << endl; break;
         case KEY_ARROW_DOWN:  cout << "ARROW DOWN" << endl; break;
         case KEY_ARROW_LEFT:  cout << "ARROW LEFT" << endl; break;
         case KEY_ARROW_RIGHT: cout << "ARROW RIGHT" << endl; break;

         case KEY_INSERT:      cout << "INSERT" << endl; break;
         case KEY_DELETE:      cout << "DELETE" << endl; break;

         case KEY_UNDEF:       cout << "Undefined key" << endl; break;

         default: cout << key2Char(k) << endl;
      }

      if(k == KEY_INPUT_END) break;
   }

   return 0;
}

