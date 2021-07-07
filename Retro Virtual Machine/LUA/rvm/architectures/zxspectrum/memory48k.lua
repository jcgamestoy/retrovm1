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

local bit=require('bit')

local h=require('h')
local re=require('h.text.re')
--local spectrum=require('rvm.architectures.zxspectrum.spectrum48k')

local mem={}
local memM={}
local memT={__index=memM}

function mem.new(ptr)
  local r={ptr=ptr}

  setmetatable(r,memT)
  return r
end

function memM.selectMemory(o,cs)
  if not o then return nil end

  local t

  if o.bank then  
    if o.bank.type=='ram' then
      if o.bank.value>=0x3  then
        cs.red('Error: Ram bank ').white('0x%x ',o.bank.value).red('out of range.\n')
        return -1
      end

      t=1
    else
      if o.bank.value~=0x0  then
        cs.red('Error: Rom bank ').white('0x%x ',o.bank.value).red('out of range.\n')
        return -1
      end

      t=0
    end

    if o.address>=0x4000 then
      cs.red('Error: Adress ').white('0x%x ',o.address).red('out of range.\n')
      return -1
    end

    return t,o.bank.value,o.address,0x3fff
  else
    if o.address>=0x10000 then
      cs.red('Error: Adress ').white('0x%x ',o.address).red('out of range.\n')
      return -1
    end    

    return 2,nil,o.address,0xffff
  end
end

function memM:get(a)
  if a<=0x4000 then
    return self.ptr.rom[0][a]
  else
    local b=bit.rshift(bit.band(a,0xc000),14)-1
    return self.ptr.ram[b][bit.band(a,0x3fff)]
  end
end

function memM:gets(a)
  return ffi.cast('int8_t',self:get(a))
end

local function bMemg(t,b)
  if t==0 then
    return function(self,a)
      return self.ptr.rom[b][a]
    end
  else
    return function(self,a)
      return self.ptr.ram[b][a]
    end
  end
end

memM.blockMem={[0]={[0]=bMemg(0,0)},[1]={[0]=bMemg(1,0),[1]=bMemg(1,1),[2]=bMemg(1,2)}}

function memM:memoryMap(cs)
  cs.aquamarine('Block ').white('0: ').orange('Rom: ').white('0\n')
  cs.aquamarine('Block ').white('1: ').paleGreen('Ram: ').white('0\n')
  cs.aquamarine('Block ').white('2: ').paleGreen('Ram: ').white('1\n')
  cs.aquamarine('Block ').white('3: ').paleGreen('Ram: ').white('2\n')
end

return mem