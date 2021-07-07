//(C)2014 Juan Carlos González Amestoy


#import "spectrum48k.h"






uint8_t s48kIssue2_in(z80* z,uint16_t a)
{
  spectrum* s=(spectrum*)z->tag;

  if(a&0x1)
  {



    if((a&0xff)==0x1f) //Kempston
      return s->joyState;
      return floatingBus48k(s->cpu);
  }

  uint8_t r=0xff;

  for(int i=0;i<8;i++)
    if(!(a & (0x100<<i)))
      r&=s->keyboard[i];
  r=(s->ear || s->mic)?r|0x40:r&0xbf;
  r=s->level?r^0x40:r;

  return r;
}






