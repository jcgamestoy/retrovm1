
local ffi=require('ffi')

ffi.cdef[[
  typedef uint16_t uint16;
  typedef uint8_t uint8;
  typedef uint32_t uint32;

  typedef struct __attribute__ ((__packed__))
  {
    char sig[22];
    uint8 terminator;
    uint8 major;
    uint8 minor;
    uint32 sampleRate;
    uint32 total;
    uint8 compression;
    uint8 flags;
    uint8 hdr;
    char tool[16];
    uint8 data[];
  }rvmCSWBlock2S;
]]

local file=require('h.io.file')

local function load(path)
  local data=file.readAll(path)

  local pt=ffi.cast('rvmCSWBlock2S*',data)

  if pt.major~=2 then return nil end

  return pt,data
end

return {
  load=load
}