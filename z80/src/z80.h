/*
Copyright (c) 2013 Juan Carlos González Amestoy

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

#ifndef __z80
#define __z80

#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>

//REMOVE ME!!!
//#define nil nop

#define PAGEBITS 2
typedef struct _z80 z80;
typedef uint8_t (*z80get)(z80*,uint16_t);
typedef void (*z80set)(z80*,uint16_t,uint8_t);
typedef uint8_t (*z80in)(z80*,uint16_t);
typedef void (*z80out)(z80*,uint16_t,uint8_t);
typedef uint8_t (*z80busInt)(z80*);
typedef uint32_t (*z80Contention)(z80*,uint16_t);
typedef void (*z80Aknowlegde)(z80*);

typedef union 
{
  struct
  {
    uint16_t bc,de,hl,af,sp,ix,iy,pc,ir,bcp,dep,hlp,afp,tm,aux,iffw,imodew,mptr;
  };

  struct
  {
    uint8_t c,b,e,d,l,h,f,a,spl,sph,ixl,ixh,iyl,iyh,pcl,pch,r,i,cp,bp,ep,dp,lp,hp,fp,ap,tm1,tm2,auxl,auxh,iff,iff2,iMode,q,mptrl,mptrh;
  };
} regs;

typedef void (*inst)(z80*);

struct _z80
{
  regs r;
  uint32_t T;


  uint8_t** mem;
  uint8_t** memw;


  uint8_t flags;

  inst *uops; //uop list

  z80get get;
  z80set set;
  z80in in;
  z80out out;
  z80busInt busInt;
  z80Contention con1;
  z80Contention con2;
  z80Contention conIO;
  z80Aknowlegde iAknowlegde;
  
  void* tag;
};

#define z80RUNING 0x0
#define z80HALTED 0x1
#define z80FETCH  0x2

extern inst nInst[0x100];
extern inst ddInst[0x100];
extern inst fdInst[0x100];
extern inst edInst[0x100];
extern inst cbInst[0x100];
extern inst ddcbInst[0x100];
extern inst fdcbInst[0x100];

void z80_nmi(z80* z);
void z80_i0(z80* z);
void z80_i1(z80* z);
void z80_i2(z80* z);

void z80_init(void);
void z80_reset(z80* z);
void z80_step(z80* z,uint32_t,uint32_t);

#endif
