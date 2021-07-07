
//(C)2014 Juan Carlos González Amestoy
#import <Foundation/Foundation.h>
#import "rvmMachineProtocol.h"

#import "z80.h"
#import "rvmTapeDecoderProtocol.h"
#import "rvmAY3819X.h"
#import "rvmAudioMixer.h"
#import "spectrum48k.h"

#import "rvmUpd765.h"


struct _spectrumPlus3;
typedef struct _spectrumPlus3{
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
  double soundChannels[4];


//Spectrum128
//
  uint8_t memory7f; //last 0x7ffd
  uint8_t aySelect;
  rvmAY3819XT *ay;
//Spectrum +2A
//
  uint8_t memory1f;

//Spectrum +3
//
  rvmUpd765S *upd765;
  int16_t *motorSound,*motorLast,*motor;
  int16_t *seekSound,*seekLast,*seek;
  uint32_t ledA,ledB;

}spectrumPlus3;
void initPlus3(void);
uint32_t sPlus3_cont4T(uint32_t l,uint32_t t);
uint32_t sPlus3_contention(z80 *z,uint16 a);
uint32_t sPlus3_contentionIO(z80 *z,uint16 a);
uint32_t floatingBusPlus3(z80 * z);

uint32_t* stepPlus3(spectrumPlus3 *speccy,bool fast,uint32_t* buffer);
uint32_t* framePlus3(spectrumPlus3 *speccy,bool fast,uint32_t* buffer);
void sPlus3_set(z80* z,uint16_t a,uint8_t v);
uint8_t sPlus3_get(z80* z,uint16_t a);
void sPlus3_out(z80* z,uint16_t a,uint8_t v);
uint8_t sPlus3_busInt(z80* z);
uint8_t sPlus3_in(z80* z,uint16_t a);
void sPlus3_ack(z80*z);
void sPlus2A_memoryConfig(spectrum *s,uint8 m7f,uint8 m1f);

uint8_t s128k_AYin(rvmAY3819XT *h,uint16 a);



