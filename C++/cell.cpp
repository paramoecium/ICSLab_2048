/****************************************************************************
  File       [ cell.cpp ]
  Synopsis   [ Class Cell for 2048 game ]
  Package    [ 2048 ]
  Author     [ Kung-Nien Yang, B99901027, NTUEE ]
****************************************************************************/

#include "cell.h"

unsigned Cell::_globalRef = 0;
bool     Cell::_moved = false;

