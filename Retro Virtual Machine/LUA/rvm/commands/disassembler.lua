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

local dis=require('z80.disassembler')

local addressParser=require('rvm.parsers.address').parser
local numberParser=require('rvm.parsers.number').parser

return {
  name='disassemble',
  abbr='d',
  --g=g,
  doCmd=function(self,cs,str)
    local lines
    local ad,pos=addressParser:match(str)         --get the address
    local t,b,a,m=machine.mem.selectMemory(ad,cs) --select the memory
    --print(t,b,a,m)

    if str=='' then
      t=self.lastType
      a=self.lastAddress
      m=self.lastMask
      b=self.lastBlock
    end

    str=str(pos)
    lines,pos=numberParser:match(str) --get the lines to dissasembly
    lines=lines and lines-1 or 7

    local mem={ --mem wrapper
    }

    function mem:gets(a)
      return tonumber(ffi.cast('int8_t',self:get(a)))
    end

    if t~=nil then
      if t==0 or t==1 then
        mem.get=function(self,a)
          a=bit.band(a,m)
          return tonumber(machine.mem.blockMem[t][b](machine.mem,a))
        end
      elseif t==2 then
        mem.get=function(self,a)
          a=bit.band(a,m)
          return tonumber(machine.mem:get(a))
        end
      else
        return
      end

      for i=0,lines do
        local pc,k,j=dis.disassemble(mem,a,1) --Disassemble one

        cs.yellow('0x%.4x ',pc)

        for ii=0,j-1 do
          cs.lime('%.2x ',mem:get(pc+ii))
        end

        cs(string.rep(' ',(4-j)*3))

        cs.lightCyan('%s\n',k)

        a=bit.band(a+j,m)
      end

      self.lastType=t
      self.lastBlock=b
      self.lastMask=m
      self.lastAddress=a
    end

    return 0
  end
}