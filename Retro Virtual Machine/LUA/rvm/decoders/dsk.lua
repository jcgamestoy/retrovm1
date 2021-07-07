--[[
Copyright (c) 2014 Juan Carlos González Amestoy

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
--]]

local ffi=require('ffi')


ffi.cdef[[

typedef uint8_t* (*rvmDskSeek)(void *disk,bool skipD,uint8_t side,uint8_t track,uint8_t sideId,uint8_t trackId,uint8_t sectorId,void **sector);
typedef void* (*rvmDskFirstSector)(void *disk,uint8_t track,uint8_t side);

typedef void* (*rvmDskFormatTrack)(void *disk,uint8_t track,uint8_t side,uint8_t n,uint32_t sc,uint8_t gap3,uint8_t fill);

typedef void (*rvmDskFormatSector)(void *disk,void *track,uint32_t i,uint8_t c,uint8_t h,uint8_t r,uint8_t n);

typedef struct
{
  uint8_t track;
  uint8_t side;
  uint8_t sID;
  uint8_t sSize;
  uint8_t st1;
  uint8_t st2;
  uint16_t rsize;
  uint8_t *data;
}rvmDskSectorInfoS;

typedef struct
{
  char sig[0x10];
  uint8_t trackN;
  uint8_t sideN;
  uint16_t unused1;
  uint8_t sectorSize;
  uint8_t nsector;
  uint8_t gap3;
  uint8_t filler;
  //rvmDskSectorInfoS sectorList[1];
  rvmDskSectorInfoS **sectors;
}rvmDskTrackS;

typedef struct
{
  uint8_t tracksN;
  uint8_t sidesN;
  uint16_t sizeOfTrack;
  
  rvmDskTrackS **tracks;
  
  rvmDskSeek seek;
  rvmDskFirstSector first;
  rvmDskFormatTrack ftrack;
  rvmDskFormatSector fsector;
  
  uint32_t type;
  uint32_t writeProtect;
}rvmDskS;

rvmDskS* rvmCommandAddDisc(void *c,const char* path);
void rvmCommandRemoveDisk(void *c,rvmDskS *pt);

]]


