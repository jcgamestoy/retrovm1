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

o=require"h.io.console".o

o.seaGreen("Bench of the z80 core\n")
o.peru("(C)2011-12 Juan Carlos González Amestoy\n")

z80=require("z80.z80")
mem=require("z80.mem")
dis=require("z80.disassembler")

clock=require("h.os.clock")

local m=mem.new()
local z=z80.new(m)

local n

if #arg>0 then
	n=arg[1]
else
	n=100
end

m:set(0,0x21)
m:set(1,0x00)
m:set(2,0x00) -- ld hl,0000

m:set(3,0x11)
m:set(4,0x00)
m:set(5,0x40) -- ld de,4000

m:set(6,0x01)
m:set(7,0x00)
m:set(8,0x40) -- ld bc,4000

m:set(9,0xed)
m:set(10,0xb0) -- ldir


local c=clock.new()
local mm,t=0,0
for i=1,n do
z:reset()
t,mm=z:run(0x4003)
end
local e=c.ellapsed()

--local mhz=(1/(((e/n)/t)))/10^6
local ti=e/n
local tit=(ti/t)*10^6
local mhz=1/tit
--print(ti,tit)

--dis.list(m,0x4000,16)

o.red("16384 bytes moved. %.0f m-states %.0f t-states %.2fs %.2fmhz\n",mm,t,e,mhz)