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

local addressParser=require('rvm.parsers.address').parser
local numberParser=require('rvm.parsers.number').parser

local function gchar(c)
  if c<32 or c>=128 then return '.' end
  return string.char(c)
end


return {
  name='memory',
  abbr='m',
  lastAddress=0,
  lastMask=0,
  lastType=0,
  lastBlock=0,
  lastLines=10,
  lastSize=8,
  doCmd=function(self,cs,str)
    local lines,g
    local ad,pos=addressParser:match(str)
    local t,b,a,m=machine.mem.selectMemory(ad,cs)

    if str=='' then
      t=self.lastType
      a=self.lastAddress
      m=self.lastMask
      b=self.lastBlock
      lines=self.lastLines
      g=self.lastSize
    else    

      str=str(pos)
      lines,pos=numberParser:match(str)
      str=str(pos)
      g,pos=numberParser:match(str)

      g=g and g or 8
    end

    if not h.eqAny(g,8,16,32) then
      cs.red('Error width must be 8 16 or 32 not "').white('%d',g).red('"\n')
      return 
    end

    local f

    if t~=nil then
      self.lastLines=lines

      if t==0 or t==1 then
        print(t,b,machine.mem.blockMem[t][b])
        f=machine.mem.blockMem[t][b]
      elseif t==2 then
        f=machine.mem.get
      else
        return
      end

      lines=lines and lines-1 or 9

      for i=0,lines do
        cs.yellow('0x%.4x ',a)
        local ascii={}

        if g==8 then
          for j=0,15 do
            local d=f(machine.mem,a)
            ascii[#ascii+1]=gchar(d)
            cs.lime('%.2x ',d)
            a=bit.band(a+1,m)
          end
        elseif g==16 then
          for j=0,7 do
            local d=f(machine.mem,a)
            local v=d
            ascii[#ascii+1]=gchar(d)
            a=bit.band(a+1,m)
            d=f(machine.mem,a)
            ascii[#ascii+1]=gchar(d)
            v=v+d*0x100
            a=bit.band(a+1,m)
            cs.lime('%.4x ',v)
          end
        else
          for j=0,7 do
            local d=f(machine.mem,a)
            local v=d
            ascii[#ascii+1]=gchar(d)
            a=bit.band(a+1,m)
            d=f(machine.mem,a)
            ascii[#ascii+1]=gchar(d)
            v=v+d*0x100
            a=bit.band(a+1,m)
            d=f(machine.mem,a)
            ascii[#ascii+1]=gchar(d)
            v=v+d*0x10000
            a=bit.band(a+1,m)
            d=f(machine.mem,a)
            ascii[#ascii+1]=gchar(d)
            v=v+d*0x1000000
            a=bit.band(a+1,m)
            cs.lime('%.8x ',v)
          end
        end

        cs.moccasin('%s\n',table.concat(ascii))
      end

      self.lastType=t
      self.lastBlock=b
      self.lastMask=m
      self.lastAddress=a
      self.lastSize=g
    else
      cs.red('Error: Sintax error.\n')
    end

    return 0
  end
}
