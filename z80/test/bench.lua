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
local bit=require("bit")
local band=bit.band

clock=require("h.os.clock")

local m=mem.new()
local z=z80.new(m)

for i=0,0x7fff do
  m:set(i,math.random(255))
end

local n

if #arg>0 then
	n=arg[1]
else
	n=100
end

m:set(0,0xdd)
m:set(1,0x21)
m:set(2,0x00)
m:set(3,0x00) -- ld ix,0000

m:set(4,0xfd)
m:set(5,0x21)
m:set(6,0x00)
m:set(7,0x40) -- ld iy,4000

m:set(8,0x21)
m:set(9,0x00)
m:set(10,0xc0) -- ld hl,c000

m:set(11,0xdd)
m:set(12,0x7e) 
m:set(13,0x00) --ld a,(ix+0)

m:set(14,0xfd)
m:set(15,0x86)
m:set(16,0x00) --add (iy+0)

m:set(17,0x77) --ld (hl),a

m:set(18,0xdd)
m:set(19,0x23) --inc ix

m:set(20,0xfd)
m:set(21,0x23) --inc iy

m:set(22,0x2c) --inc l

m:set(23,0xc2)
m:set(24,0x0b) -- jr nz ,0
m:set(25,0x00)

m:set(26,0x24) --inc h

m:set(27,0xc2)
m:set(28,0x0b) -- jr nz ,0
m:set(29,0x00)

m:set(30,0x76) -- halt

--dis.list(m,0,20)

z:run()

for i=0,0x3fff do
  assert(band(m:get(i)+m:get(i+0x4000),0xff)==m:get(i+0xc000))
end
---[[
local c=clock.new()
local mm,t,iii=0,0,0
for i=1,n do
z:reset()
local tt,mmm,ii=z:run(0x4003)

mm,t,iii=mm+mmm,t+tt,iii+ii
end
local e=c.ellapsed()

o.crimson('%d instructions, %.2f Minstructions/second\n',iii,(iii/e)/10^6)
o.lime("%d T-states in %.2f seconds\n",t,e)
o.brown("%.2f T-States estimated- %.2f Mhz (x%.2f)\n",t/e,(t/e)/10^6,((t/e)/10^6)/4)
o.yellowGreen("4 Mhz emulated in %.5f ms\n",(e/t)*4*10^3)
--local mhz=(1/(((e/n)/t)))/10^6

--dis.list(m,0x4000,16)

--o.red("%d bytes moved. %.0f m-states %.0f t-states %.2fs %.2fmhz\n",0x4000*n,mm*n,t*n,e,mhz)
