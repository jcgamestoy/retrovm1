--[[
Copyright (c) 2011-13 Juan Carlos González Amestoy

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
local z80c=require('z80.z80c')

local z80={}
local _z80Methods={}
local _z80Metatable={__index=_z80Methods}

function _z80Methods:step()
  --local o=self.get(self,self.r.pc)
  --self.r.pc=self.r.pc+1
  z80c.z80_step(self,0,0)
  --z80c.z80_stubIO(self)
  
  return self.T
end

function _z80Methods:run(n)
  n=tonumber(n)
  if n==nil then n=math.huge end

  local t,m=0,0
  local i=0
  repeat
    --print(1,self,self.get)
    --local o=self.get(self,self.r.pc)
    --print(2,o)
    --print('pc:',self.r.pc)
    --self.r.pc=self.r.pc+1
    --print('pc:',self.r.pc)
    --print(3,self.r.pc)
    --print(i)
    z80c.z80_step(self,0,0)
    --print(self.flags)
    --print(4)
    --print(self.opsO1,self.opsS1,self.opsD1,self.opsT1)
    --z80c.z80_stubIO(self)
    --t,m=t+self.rr.t,m+self.rr.m

    --print(self.cpu.flags)
    if self.flags==1 then break end
    i=i+1
  until i==n

  return self.T,i
end

-- function _z80Methods:run2(n)
--   local t,m=ffi.new('int[1]'),ffi.new('int[1]')
--   z80c.z80_run(self,n,t,m)
--   return t[0],m[0]
-- end

function _z80Methods:reset()
  local r=self.r
  r.af,r.bc,r.de,r.hl,r.afp,r.bcp,r.dep,r.hlp,r.pc,r.sp,r.ix,r.iy,r.ir,r.iffw,r.imodew=0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  self.flags=0 --running
end

function z80.new(mem)
  local r=ffi.new('z80')
  r.mem=mem.mr
  r.memw=mem.mw
  z80c.z80_stub(r)

  ffi.metatype(r,_z80Metatable)

  --setmetatable(r,_z80Metatable)

  return r
end

return z80