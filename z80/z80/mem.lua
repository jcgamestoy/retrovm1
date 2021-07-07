--[[
Copyright (c) 2012-13 Juan Carlos González Amestoy

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

local ffi=require("ffi")
local bit=require("bit")

local band,bor,rs,ls=bit.band,bit.bor,bit.rshift,bit.lshift

local mem={}
local _memMethods={}
local _memMetatable={__index=_memMethods}

function _memMethods:get(a)
  return self.m[band(a,0xffff)]
end

function _memMethods:gets(a)
  return self.ms[band(a,0xffff)]
end

function _memMethods:set(a,v)
  --print(self,a,v)
  self.m[band(a,0xffff)]=v
end

function _memMethods:set16(a,v)
  self.m[band(a,0xffff)]=band(v,0xff)
  self.m[band(a+1,0xffff)]=rs(band(v,0xff00),8)
end

function _memMethods:get16(a)
  return self.m[band(a,0xffff)]+ls(self.m[band(a+1,0xffff)],8)
end

function _memMethods:reset()
  for i=0,0xffff do
    self.m[i]=0
  end
end

function mem.new()
  local self={}
  self.m=ffi.new("uint8_t[0x10000]")
  self.ms=ffi.new('int8_t*')
  self.ms=self.m
  self.mr=ffi.new("uint8_t*[4]")
  self.mw=ffi.new("uint8_t*[4]")

  for i=0,3 do
    self.mr[i]=self.m+0x4000*i
    self.mw[i]=self.m+0x4000*i
  end

  setmetatable(self,_memMetatable)
  return self
end

return mem