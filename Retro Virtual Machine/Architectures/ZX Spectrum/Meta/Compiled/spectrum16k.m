//(C)2014 Juan Carlos González Amestoy


#import "spectrum48k.h"




uint8_t s16k_get(z80* z,uint16_t a)
{
  if(a>=0x8000) return floatingBus48k(z);

  uint8_t* pt=z->mem[a>>14];
  return pt[a & 0x3fff];
}

void s16k_set(z80* z,uint16_t a,uint8_t v)
{

  if(a<0x4000 || a>=0x8000) return;

  uint8_t* pt=z->memw[a>>14];
  pt[a & 0x3fff]=v;
}







