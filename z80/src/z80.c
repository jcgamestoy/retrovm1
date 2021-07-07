/*
Copyright (c) 2013-14 Juan Carlos González Amestoy

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

#include "z80.h"
#include <string.h>

inst nInst[0x100];
inst ddInst[0x100];
inst edInst[0x100];
inst fdInst[0x100];
inst cbInst[0x100];
inst ddcbInst[0x100];
inst fdcbInst[0x100];

static inst zNull[]={NULL};

#ifdef z80STUB
uint8_t last=0xff;

uint8_t get(z80*z,uint16_t a)
{
  uint8_t* pt=z->mem[a>>14];
  return pt[a & 0x3fff];
}

void set(z80* z,uint16_t a,uint8_t v)
{
  uint8_t* pt=z->memw[a>>14];
  pt[a & 0x3fff]=v;
}

uint8_t in(z80* z,uint16_t a)
{
  //printf("in: %x %x\n",a,last);
  return last;
}

uint32_t con(z80*z,uint16_t s)
{
  return 0;
}

void out(z80* z,uint16_t a,uint8_t v)
{
  //printf("out: %x %x\n",a,v);
  last=v;
}

uint8_t busInt(z80* z)
{
  return 0xff;
}

void z80_stub(z80* z)
{
  z->get=get;
  z->set=set;

  z->in=in;
  z->out=out;

  z->con1=con;
  z->con2=con;
  z->conIO=con;

  z80_reset(z);
}

#endif
void z80_reset(z80* z)
{
  memset(&z->r, 0xff, sizeof(regs));
  
  z->uops=zNull;
  z->r.iMode=0;
  z->r.iff=z->r.iff2=z->r.ir=0;
  z->r.pc=0;
  
  z->flags=0;
}

void z80_step(z80* z,uint32_t i,uint32_t n)
{
  if(*z->uops)
  {
    z->flags&=0x1;
    (*(z->uops++))(z);
    return;
  }
  else
  {
    if(n)
    {
      z->r.iff2=z->r.iff;
      z->r.iff=0;
      z->r.r=((z->r.r+1) & 0x7f) | (z->r.r & 0x80);

      z80_nmi(z);

      return;
    }

    if(i && z->r.iff)
    {
      z->r.iff=0; z->r.iff2=0; //?? Seguro...
      z->r.r=((z->r.r+1) & 0x7f) | (z->r.r & 0x80);

      switch(z->r.iMode)
      {
        case 0:
          //z->r.tm1=z->busInt(z);
          z80_i0(z);
          break;
        case 1:
          z80_i1(z);
          break;
        case 2:
          //z->r.tm1=z->busInt(z);
          z80_i2(z);
          break;
      }

      z->iAknowlegde(z);
      z->flags=0;

      return;
    }

    uint8_t c=z->con1(z,z->r.pc);
    if(z->flags & 0x1)
    {
      z->T=4+c;
      return;
    }
    
    uint8_t opc=z->get(z,z->r.pc++);
    //printf("pc:%4x op:%2x bc:%4x\n",z->r.pc,opc,z->r.bc);
    z->r.r=((z->r.r+1) & 0x7f) | (z->r.r & 0x80);
    z->flags|=0x2;
    nInst[opc](z);
    z->T+=c;

    return;
  }
}