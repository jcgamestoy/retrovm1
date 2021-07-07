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

require('h.string')
local ffi=require('ffi')
local bit=require('bit')
local file=require('h.io.file')

ffi.cdef[[
  typedef uint16_t uint16;
  typedef uint8_t uint8;
  typedef uint32_t uint32;

  typedef struct
  {
    char sig[8];
    uint8_t major;
    uint8_t minor;
  }rvmTZXHeader;

  typedef struct
  {
    uint16 pause;
    uint16 length;
    uint8 data[];
  }rvmTZX10Block;

  typedef struct __attribute__ ((__packed__))
  {
    uint16 pilotL;
    uint16 sync1;
    uint16 sync2;
    uint16 l0;
    uint16 l1;
    uint16 pilotC;
    uint8 usedBits; //Unimplemented for now.
    uint16 pause;
    uint8 length[3];
    uint8 data[];
  }rvmTZX11Block;

  typedef struct __attribute__ ((__packed__))
  {
    uint16 length;
    uint16 n;
  }rvmTZX12Block;

  typedef struct __attribute__ ((__packed__))
  {
    uint16 l0;
    uint16 l1;
    uint8 ub;
    uint16 pause;
    uint8 length[3];
    uint8 data[];
  }rvmTZX14Block;

  typedef struct __attribute__ ((__packed__))
  {
    uint16 T;
    uint16 pause;
    uint8 used;
    uint8 length[3];
    uint8 data[];
  }rvmTZX15Block;

  typedef struct __attribute__ ((__packed__))
  {
    uint32 length;
    uint16 pause;
    uint8 sampling[3];
    uint8 compression;
    uint32 pulses;
    uint8 data[];
  }rvmTZX18Block;

  typedef struct __attribute__ ((__packed__))
  {
    uint32 length;
    uint16 pause;
    uint32 totp;
    uint8 npp;
    uint8 asp;
    uint32 totd;
    uint8 npd;
    uint8 asd;
    uint8 data[];
  }rvmTZX19Block;
]]

local function b10L(p)
  local b10=ffi.cast('rvmTZX10Block*',p)

  return p+4+b10.length
end

local function b11L(p)
  local b11=ffi.cast('rvmTZX11Block*',p)
  local l=b11.length[0]+b11.length[1]*0x100+b11.length[2]*0x10000
  return p+ffi.sizeof('rvmTZX11Block')+l
end

local function b12L(p)
  return p+ffi.sizeof('rvmTZX12Block')
end

local function b13L(p)
  local n=ffi.cast('uint8*',p)

  return p+n[0]*2+1
end

local function b14L(p)
  local b14=ffi.cast('rvmTZX14Block*',p)
  local l=b14.length[0]+b14.length[1]*0x100+b14.length[2]*0x10000
  return p+ffi.sizeof('rvmTZX14Block')+l
end

local function b15L(p)
  local b15=ffi.cast('rvmTZX15Block*',p)
  local l=b15.length[0]+b15.length[1]*0x100+b15.length[2]*0x10000
  return p+ffi.sizeof('rvmTZX15Block')+l
end

local function b18L(p)
  local n=ffi.cast('uint32*',p)

  return p+n[0]+4
end

local function b19L(p)
  local b19=ffi.cast('rvmTZX19Block*',p)
  
  return p+b19.length+4
end

local function b20L(p)
  return p+2
end

local function b21L(p)
  local n=ffi.cast('uint8*',p)

  return p+n[0]+1
end

local function b22L(p)
  return p
end

local function b26L(p)
  local n=ffi.cast('uint16*',p)

  return p+(n[0]+1)*2
end

local function b2bL(p)
  return p+5
end

local function b31L(p)
  local n=ffi.cast('uint8*',p+1)

  return p+n[0]+2
end

local function b32L(p)
  local n=ffi.cast('uint16*',p)

  return p+n[0]+2
end

local function b33L(p)
  local n=ffi.cast('uint8*',p)

  return p+n[0]*3+1
end

local function b35L(p)
  local pp=p+0x10
  local n=ffi.cast('uint32*',pp)
  
  return pp+4+n[0]
end


local function b5aL(p)
  return p+9
end

local function b2aL(p)
  return p+4
end

local bl={}

for i=0,255 do
  bl[i]=b22L
end

local BlockNames={
  [0x10]='Standard',
  [0x11]='Turbo',
  [0x12]='Pure Tone',
  [0x13]='Sequence of pulses',
  [0x14]='Pure data',
  [0x15]='Direct Recording',
  [0x18]='CSW Recording',
  [0x19]='Generalized data',
  [0x20]='Pause / Stop',
  [0x21]='Group Start',
  [0x22]='Group End',
  [0x23]='Jump',
  [0x24]='Loop start',
  [0x25]='Loop end',
  [0x26]='Call',
  [0x27]='Return',
  [0x28]='Select',
  [0x2a]='Stop 48k',
  [0x2b]='Set signal',
  [0x30]='Text Description',
  [0x31]='Message block',
  [0x32]='Archive Info',
  [0x33]='Hardware type',
  [0x35]='Custom info',
  [0x5a]='Glue'
}

bl[0x10]=b10L
bl[0x11]=b11L
bl[0x12]=b12L
bl[0x13]=b13L
bl[0x14]=b14L
bl[0x15]=b15L
bl[0x18]=b18L
bl[0x19]=b19L
bl[0x20]=b20L
bl[0x23]=b20L
bl[0x24]=b20L
bl[0x2a]=b2aL
bl[0x21]=b21L
bl[0x30]=b21L
bl[0x26]=b26L
bl[0x2b]=b2bL
bl[0x31]=b31L
bl[0x32]=b32L
bl[0x28]=b32L
bl[0x33]=b33L
bl[0x35]=b35L
bl[0x5a]=b5aL


local parser={}
local parserM={}

function parserM.__tostring(p)
  local lines={}

  for k,v in ipairs(p) do
    lines[#lines+1]=('Block type: 0x%.2x - %s'):format(v.id,v.name)
  end

  return table.concat(lines,'\n')
end

--return a list of blocks nil on error
local function parseFile(path)
  local r={}

  setmetatable(r,parserM)

  local data=file.readAll(path)
  if data==nil then return end

  --print(data)
  r.data=data

  --print(1)
  local pt=ffi.cast('uint8*',data)
  --print(2)
  local sig=ffi.string(pt,8)
  --print(3,sig,sig:begins('ZXTape!'),pt[7]~=26,not sig:begins('ZXTape!') or pt[7]~=26)
  if (not sig:begins('ZXTape!')) or pt[7]~=26 then return end
  --print(4)
  local last=pt+#data

  pt=pt+10

  while pt<last do
    local id=pt[0]
    pt=pt+1
    --print(id)

    r[#r+1]={id=id,pt=pt+1,name=BlockNames[id] and BlockNames[id] or 'unknow block'}
    pt=bl[id](pt)
  end

  return r
end

local function newHeader()
  local h=ffi.new('rvmTZXHeader')

  h.major=1
  h.minor=20

  h.sig='ZXTape!'
  h.sig[7]=0x1a

  return h
end


return {
  parse=parseFile,
  newHeader=newHeader
}



