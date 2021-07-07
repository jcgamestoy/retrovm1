
//(C)2014 Juan Carlos González Amestoy
#import <Foundation/Foundation.h>
#import "rvmMachineProtocol.h"

#import "z80.h"
#import "rvmTapeDecoderProtocol.h"
#import "rvmAY3819X.h"
#import "rvmAudioMixer.h"



struct _spectrum;
typedef uint32_t* (*rvmSpeccyStep)(void *speccy,bool fast,uint32_t* buffer);
typedef struct _spectrum{
  uint32_t border,bcol,bl;
  uint32_t fg,bg;
  int t,flash,T,M,frame,so,soundIndex;
  double soc;
  uint8_t pixel,attr,pl,al;
  uint32_t palette[16];
  uint8_t keyboard[8];
  uint8_t mic,ear;
  uint32_t level;
  uint8_t joyState;
  uint32_t cassetteT;
  //bool cassetteRunning;
  rvmTapeDecoderProtocolS *cassetteDecoder;
  //int16_t audioBuffer[882<<1];
  int16_t audioBuffer[3840<<1];
  //double audioLevelL,audioLevelR;

  rvmSpeccyStep step;
  rvmSpeccyStep frameF;
  uint8_t **ram;
  uint8_t **rom;

  z80* cpu;
  rvmAudioMixerS *mixer;
  double soundChannels[1];


}spectrum;
void init48k(void);
uint32_t s48k_cont4T(uint32_t l,uint32_t t);
uint32_t s48k_contention(z80 *z,uint16 a);
uint32_t s48k_contentionIO(z80 *z,uint16 a);
uint32_t floatingBus48k(z80 * z);

uint32_t* step48k(spectrum *speccy,bool fast,uint32_t* buffer);
uint32_t* frame48k(spectrum *speccy,bool fast,uint32_t* buffer);
void s48k_set(z80* z,uint16_t a,uint8_t v);
uint8_t s48k_get(z80* z,uint16_t a);
void s48k_out(z80* z,uint16_t a,uint8_t v);
uint8_t s48k_busInt(z80* z);
uint8_t s48k_in(z80* z,uint16_t a);
void s48k_ack(z80*z);


uint32* snap48k(spectrum *speccy,uint32* buffer,uint8* mem,uint8 border);
void s48k_ack(z80* z);


