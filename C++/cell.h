/****************************************************************************
  File       [ cell.h ]
  Synopsis   [ Class Cell for 2048 game ]
  Package    [ 2048 ]
  Author     [ Kung-Nien Yang, B99901027, NTUEE ]
****************************************************************************/

#ifndef CELL_H
#define CELL_H

class Cell
{
public:
   Cell(int i = 0) : _val(i), _ref(0) {}
   ~Cell() {}

   int getVal() const { return _val; }

   //int   operator () () { return _val; }
   Cell& operator = (const Cell& c)
   {
      _val = c._val;
      _ref = c._ref;
      return (*this);
   }
   Cell& operator = (int i)
   {
      _val = i;
      return (*this);
   }
   Cell operator + (const Cell& c) const
   {
      return Cell(_val + c._val);
   }
   Cell& operator += (const Cell& c)
   {
      *this = *this + c;
      return (*this);
   }
   bool operator == (const Cell& c) const
   {
      return (_val == c._val);
   }
   bool operator == (int i) const
   {
      return (_val == i);
   }

   static void resetGlobalRef() { ++_globalRef; }
   void mark() { _ref = _globalRef; }
   bool isMarked() { return _ref == _globalRef; }

   static void setMoved(bool b) { _moved = b; }
   static bool getMoved() { return _moved; }

private:
   int               _val;
   unsigned          _ref;

   static unsigned   _globalRef;
   static bool       _moved;
};


#endif // CELL_H
