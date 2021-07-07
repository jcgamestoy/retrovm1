
--(C)2014 Juan Carlos Gonzalez Amestoy
local ffi=require('ffi')

ffi.cdef[[

typedef void* rvmTapeDecoderProtocolS;
typedef void z80;
typedef void rvmAY3819XT;
typedef void rvmUpd765S;
typedef void rvmAudioMixerS;

struct _spectrumPlus3;
typedef uint32_t* (*rvmSpeccyStep)(void *speccy,bool fast,uint32_t* buffer);
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
]]

local r={}
local mMgr=require("rvm.architectures.zxspectrum.memoryPlus2A")

function r.new(hardPtr)
  local rr={}
  rr.machine=ffi.cast("spectrumPlus3*",hardPtr)
  rr.mem=mMgr.new(rr.machine)

  return rr
end

return r

