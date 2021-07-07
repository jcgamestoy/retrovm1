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

local o=require"h.io.console".o

o.seaGreen("Test of the z80 core\n")
o.peru("(C)2011-13 Juan Carlos González Amestoy\n")

local z80=require("z80.z80")
local mem=require("z80.mem")
local dis=require("z80.disassembler")
local bit=require("bit")
local io=require("z80.io")
local as=require("z80.assembler")
local proc=require('h.os.process')
local m,i=mem.new(),io.new()
local cpu=z80.new(m,i)

local band,bor,bxor=bit.band,bit.bor,bit.bxor

local function state()
	local r=cpu.r
	o.white("\n--------------------------------\n")
	dis.list(m,r.pc,1)
	o.white("\n--------------------------------\n")
	o.turquoise('a').white(':').lightSalmon(bit.tohex(r.a,2))(" | ").turquoise("a'").white(':').lightSalmon(bit.tohex(r.ap,2))("\n")
	o.turquoise('b').white(':').lightSalmon(bit.tohex(r.b,2))(" | ").turquoise("b'").white(':').lightSalmon(bit.tohex(r.bp,2))("\n")
	o.turquoise('c').white(':').lightSalmon(bit.tohex(r.c,2))(" | ").turquoise("c'").white(':').lightSalmon(bit.tohex(r.cp,2))("\n")
	o.turquoise('d').white(':').lightSalmon(bit.tohex(r.d,2))(" | ").turquoise("d'").white(':').lightSalmon(bit.tohex(r.dp,2))("\n")
	o.turquoise('e').white(':').lightSalmon(bit.tohex(r.e,2))(" | ").turquoise("e'").white(':').lightSalmon(bit.tohex(r.ep,2))("\n")
	o.turquoise('h').white(':').lightSalmon(bit.tohex(r.h,2))(" | ").turquoise("h'").white(':').lightSalmon(bit.tohex(r.hp,2))("\n")
	o.turquoise('l').white(':').lightSalmon(bit.tohex(r.l,2))(" | ").turquoise("l'").white(':').lightSalmon(bit.tohex(r.lp,2))("\n")
	o.turquoise('f').white(':').lightSalmon(bit.tohex(r.f,2))(" | ").turquoise("f'").white(':').lightSalmon(bit.tohex(r.fp,2))("\n")
	o.turquoise('r').white(':').lightSalmon(bit.tohex(r.r,2))(" | ").turquoise("i'").white(':').lightSalmon(bit.tohex(r.i,2))("\n")

	o.turquoise('bc').white(':').lightSalmon(bit.tohex(r.b*0x100+r.c,4))(" | ").turquoise("bc'").white(':').lightSalmon(bit.tohex(r.bp*0x100+r.cp,4))("\n")
	o.turquoise('de').white(':').lightSalmon(bit.tohex(r.d*0x100+r.e,4))(" | ").turquoise("de'").white(':').lightSalmon(bit.tohex(r.dp*0x100+r.ep,4))("\n")
	o.turquoise('hl').white(':').lightSalmon(bit.tohex(r.h*0x100+r.l,4))(" | ").turquoise("hl'").white(':').lightSalmon(bit.tohex(r.hp*0x100+r.lp,4))("\n")
	o.turquoise('af').white(':').lightSalmon(bit.tohex(r.a*0x100+r.f,4))(" | ").turquoise("af'").white(':').lightSalmon(bit.tohex(r.ap*0x100+r.fp,4))("\n")
	o.turquoise('ix').white(':').lightSalmon(bit.tohex(r.ix,4))(" | ").turquoise("iy").white(':').lightSalmon(bit.tohex(r.iy,4))("\n")
	o.turquoise('sp').white(':').lightSalmon(bit.tohex(r.sp,4))(" | ").turquoise("pc").white(':').lightSalmon(bit.tohex(r.pc,4))("\n")
	o.white("\n--------------------------------\n")
	if band(r.f,0x1)~=0 then o.lime('C ') else o.red('C ') end
	if band(r.f,0x2)~=0 then o.lime('N ') else o.red('N ') end
	if band(r.f,0x4)~=0 then o.lime('P/V ') else o.red('P/V ') end
	if band(r.f,0x8)~=0 then o.lime('X ') else o.red('X ') end
	if band(r.f,0x10)~=0 then o.lime('H ') else o.red('H ') end
	if band(r.f,0x20)~=0 then o.lime('X ') else o.red('X ') end
	if band(r.f,0x40)~=0 then o.lime('Z ') else o.red('Z ') end
	if band(r.f,0x80)~=0 then o.lime('S ') else o.red('S ') end
	o.white("\n--------------------------------\n")
end

local function run(n)
	if n==nil then n=math.huge end
	for i=1,n do
		--state()
		cpu:step()
		state()

		if cpu.flags==1 then return end
	end
end

local function assemble(text)
	--print(text)
	local r,err=as.assemble(text,m)
	--print(text)
	if r==nil then 
		o.lime("%s",text)('\n')
		o.red("%s\n%s\n",err,debug.traceback())
		proc.exit(-1)
	end
end

o.gold("\nTesting.\n")

--[[m.set(0,62)
m.set(1,255) -- ld a,255
m.set(2,71) -- ld b,a--]]

assemble([[
	
	ld a,var
	ld b,a
	halt

	.var equ %11111111
]])

---[[cpu:reset()
--dis.list(m,0,10)
--state()
cpu:run()


--state()
assert(cpu.r.a==cpu.r.b and cpu.r.a==255)
--]]

o.orangeRed("  ld (ix+d),n\n")
--print(cpu.r.pc)
cpu:reset()
--print(cpu.r.pc)

assemble([[
	byte 0xfd,0xfd,0xdd,0xfd
	ld iy,0x4000
	ld (iy+2),0xfe
	halt
]])

--dis.list(m,0,20)
cpu:run()
--state()

--print(cpu.r.pc,cpu.r.iy,m:get(0x4002))
assert(cpu.r.iy==0x4000 and m:get(0x4002)==0xfe)

o.orangeRed("  ld a<->i/r\n")
--print(cpu.r.pc)
cpu:reset()
--print(cpu.r.pc)

assemble([[
	ld a,0xff
	ld i,a
	ld a,0
	ld a,i
	halt
]])

--dis.list(m,0,20)
cpu:run()
--state()

--print(cpu.r.pc,cpu.r.iy,m:get(0x4002))
assert(cpu.r.a==0xff and cpu.r.i==0xff and band(cpu.r.f,0x80)==0x80)

o.orangeRed("  push xx\n")
cpu:reset()

assemble([[
	ld sp,&4000
	ld hl,&1000
	ld bc,&2000
	ld iy,&3000
	push hl
	push bc
	push iy
	halt
]])

--dis.list(m,0,10)

cpu:run()
--dis.list(m,0x3f00,0x100)

assert(m:get(0x3fff)==0x10 and m:get(0x3ffd)==0x20 and m:get(0x3ffb)==0x30)

o.orangeRed("  pop xx\n")
cpu:reset()

assemble([[
	ld sp,&4000
	ld hl,&1000
	ld bc,&2000
	ld iy,&3000
	push hl
	push bc
	push iy
	pop bc
	pop de
	pop ix
	halt
]])

--dis.list(m,0,10)

cpu:run()
--cpu.state()
--dis.list(m,0x3f00,0x100)

assert(cpu.r.bc==0x3000 and cpu.r.de==0x2000 and cpu.r.ix==0x1000 and m:get(0x3fff)==0x10 and m:get(0x3ffd)==0x20 and m:get(0x3ffb)==0x30)

----------------------------------------------
--Exchange, Block Transfer, and Search Group--
----------------------------------------------

o.orangeRed("  ex de,hl\n")
-- ex de,hl
---[[
cpu:reset()

assemble([[
	ld hl,0x2f4f
	ld de,0x1f3f
	ex de,hl
	halt
]])

cpu:run()

--dis.list(m,0,10)
--state(cpu)

assert(cpu.r.d==0x2f and cpu.r.e==0x4f and cpu.r.h==0x1f and cpu.r.l==0x3f)
--]]
-- ex af,af'
o.orangeRed("  ex af,af'\n")

cpu:reset()

assemble([[
	ld hl,0x2f4f
	push hl
	pop af
	ex af,af'
	ld hl,0x0201
	push hl
	pop af
	halt
]])

cpu:run()

--dis.list(m,0,10)
--cpu.state()

assert(cpu.r.a==0x02 and cpu.r.f==0x01 and cpu.r.ap==0x2f and cpu.r.fp==0x4f)

-- exx

o.orangeRed("  exx\n")
cpu:reset()

assemble([[
	ld hl,0x2f4f
	ld bc,0x2211
	ld de,0x5544
	exx
	ld hl,0x0201
	ld bc,0x0403
	ld de,0x0605
	exx
	halt
]])


cpu:run()

--dis.list(m,0,10)
--cpu.state()

assert(cpu.r.h==0x2f and cpu.r.l==0x4f and cpu.r.hp==0x02 and cpu.r.lp==0x01)
assert(cpu.r.b==0x22 and cpu.r.c==0x11 and cpu.r.bp==0x04 and cpu.r.cp==0x03)
assert(cpu.r.d==0x55 and cpu.r.e==0x44 and cpu.r.dp==0x06 and cpu.r.ep==0x05)

-- ex (sp),hl

o.orangeRed("  ex (sp),hl\n")

cpu:reset()

assemble([[
	ld hl,0x2f4f
	push hl
	ld hl,0x1122
	ex (sp),hl
	pop bc
	halt
]])

cpu:run()

--dis.list(m,0,10)
--state()

assert(cpu.r.h==0x2f and cpu.r.l==0x4f and cpu.r.b==0x11 and cpu.r.c==0x22)

-- ex (sp),ix

o.orangeRed("  ex (sp),ix\n")

cpu:reset()

assemble([[
	ld ix,0x2f4f
	push ix
	ld ix,0x1122
	ex (sp),ix
	pop bc
	halt
]])

cpu:run()

--dis.list(m,0,10)
--cpu.state()

assert(cpu.r.ix==0x2f4f and cpu.r.b==0x11 and cpu.r.c==0x22)

-- ex (sp),iy

o.orangeRed("  ex (sp),iy\n")

cpu:reset()

assemble([[
	ld iy,0x2f4f
	push iy
	ld iy,0x1122
	ex (sp),iy
	pop bc
	halt
]])

cpu:run()

--dis.list(m,0,10)
--cpu.state()

assert(cpu.r.iy==0x2f4f and cpu.r.b==0x11 and cpu.r.c==0x22)

-- ldi

o.orangeRed("  ldi\n")

cpu:reset()

assemble([[
	ld a,0xff
	ld (0x4000),a
	ld hl,0x4000
	ld bc,0x0002
	ld de,0x8000
	ldi
	ldi
	ld a,(0x8000)
	halt
]])

cpu:run()

--dis.list(m,0,10)
--state()

assert(cpu.r.hl==0x4002 and cpu.r.de==0x8002 and cpu.r.bc==0 and cpu.r.a==0xff and bit.band(cpu.r.f,0x4)==0)

o.orangeRed("  ldir\n")

cpu:reset()

assemble([[
	ld hl,0x0000
	ld bc,0x000d
	ld de,0x4000
	ldir
	ld a,0x44
	halt
]])

cpu:run()

--dis.list(m,0,10)
--dis.list(m,0x4000,10)
--cpu.state()

assert(cpu.r.hl==0x000d)
assert(cpu.r.de==0x400d)
assert(cpu.r.bc==0x0000)
assert(cpu.r.a==0x44)
assert(m:get(0x4001)==0)
assert(m:get(0x4009)==0xed)
assert(m:get(0x400c)==0x44)


-- ldd

o.orangeRed("  ldd\n")
cpu:reset()

assemble([[
	ld a,0xff
	ld (0x4000),a
	ld hl,0x4001
	ld bc,0x0002
	ld de,0x8001
	ldd
	ldd
	ld a,(0x8000)
	halt
]])

cpu:run()

--dis.list(m,0,10)
--cpu.state()

assert(cpu.r.hl==0x3fff and cpu.r.de==0x7fff and cpu.r.bc==0 and cpu.r.a==0xff and bit.band(cpu.r.f,0x4)==0)

-- lddr
o.orangeRed("  lddr\n")

cpu:reset()

assemble([[
	ld hl,0x000c
	ld bc,0x000d
	ld de,0x400c
	lddr
	ld a,0x44
	halt
]])

cpu:run()

--dis.list(m,0,10)
--dis.list(m,0x4000,10)
--cpu.state()

assert(cpu.r.hl==0xffff)
assert(cpu.r.de==0x3fff)
assert(cpu.r.bc==0x0000)
assert(cpu.r.a==0x44)
assert(m:get(0x4001)==0xc)
assert(m:get(0x4009)==0xed)
assert(m:get(0x400c)==0x44)

-- cpi
o.orangeRed("  cpi\n")
cpu:reset()

assemble([[
	ld hl,0x0000
	ld bc,0x0002
	ld a,0x21
	cpi
	halt
]])

cpu:run()

--dis.list(m,0,10)
--state()
--print(cpu.r)
assert(cpu.r.hl==0x0001)
assert(cpu.r.bc==0x0001)
assert(band(cpu.r.f,0x80)==0)
assert(band(cpu.r.f,0x40)~=0)

--cpu:step()

--state()

-- assert(cpu.r.hl==0x0002)
-- assert(cpu.r.bc==0x0000)
-- assert(band(cpu.r.f,0x80)==0)
-- assert(band(cpu.r.f,0x40)==0)

-- cpd
o.orangeRed("  cpd\n")

cpu:reset()

assemble([[
	ld hl,0x0000
	ld bc,0x0002
	ld a,0x21
	cpd
	halt

	org &ffff
	byte &24
]])

cpu:run()

--dis.list(m,0,10)
--cpu.state()
--print(cpu.r)
assert(cpu.r.hl==0xffff)
assert(cpu.r.bc==0x0001)
assert(band(cpu.r.f,0x80)==0)
assert(band(cpu.r.f,0x40)~=0)

-- cpu:step()

-- --cpu.state()

-- assert(cpu.r.hl==0xfffe)
-- assert(cpu.r.bc==0x0000)
-- assert(band(cpu.r.f,0x80)~=0)
-- assert(band(cpu.r.f,0x40)==0)

-- cpir
o.orangeRed("  cpir\n")

cpu:reset()

assemble([[
	ld hl,0x0000
	ld bc,0x0003
	ld a,0x00
	cpir
	ld a,0x44
	halt
]])

cpu:run()
--state()
--dis.list(m,0,10)
--cpu.state()
--print(cpu.r)
assert(cpu.r.hl==0x0002)
assert(cpu.r.bc==0x0001)
assert(band(cpu.r.f,0x80)==0)
assert(band(cpu.r.f,0x40)~=0)
assert(cpu.r.a==0x44)

-- cpdr
o.orangeRed("  cpdr\n")

cpu:reset()
m:reset()

assemble([[
	ld hl,0x0000
	ld bc,0x0003
	ld a,0x00
	cpdr
	ld a,0x44
	halt
]])

cpu:run()

--print(cpu.r.a)
assert(cpu.r.hl==0xfffe)
assert(cpu.r.bc==0x0001)
assert(band(cpu.r.f,0x80)==0)
assert(band(cpu.r.f,0x40)~=0)
assert(cpu.r.a==0x44)

o.orangeRed("  add a,r\n")

cpu:reset()

assemble([[
	ld hl,0x0102
	ld bc,0x0304
	add a,b
	add c
	add a,h
	add a,l
	halt
]])

cpu:run()

--dis.list(m,0,10)
--state()

assert(cpu.r.a==10)

-- add a,n
o.orangeRed("  add a,n\n")

cpu:reset()

assemble([[
	ld hl,0x0102 
	ld bc,0x0304 
	add a,b 
	add c 
	add a,h 
	add a,l 
	add a,0x80
	halt
]])

cpu:run()

--dis.list(m,0,10)
--state()

assert(cpu.r.a==0x8a)

-- add a,(hl)
o.orangeRed("  add a,(hl)\n")

cpu:reset()

as.assemble([[
	org &100
	byte 0,0,&10

	org &0
	ld hl,0x0102
	ld bc,0x0304
	add a,b
	add a,c
	add a,h
	add a,l
	add a,0x7f+&1
	add a,(hl)
	halt
]],m)

cpu:run()

--dis.list(m,0,10)
--dis.list(m,0x102,10)
--cpu.state()

assert(cpu.r.a==0x9a)

-- add a,(ix+n)
o.orangeRed("  add a,(ix+n)\n")

cpu:reset()

--m.set(0x102,0x10)

assemble([[
	org &102
	word &0010

	org &0
	ld hl,&0102
	ld bc,&0304
	ld ix,&0003
	add b
	add c
	add h
	add l
	add 0x80
	add (hl)
	add a,(ix+1+3-2)
	halt
]])



--dis.list(m,0,15)
cpu:run()
--dis.list(m,0x100,10)
--cpu.state()

assert(cpu.r.a==0x9d)

-- add a,(ix+n)
o.orangeRed("  add a,(iy+n)\n")

cpu:reset()

assemble([[
.test equ 2
.var equ 0x10
	org &100
	byte var,var,var

	org &0
	ld hl,&0102
	ld bc,&0304
	ld iy,&0003
	add b
	add c
	add h
	add l
	add 0x80
	add (hl)
	add a,(iy+test)
	halt
]])

cpu:run()

--dis.list(m,0,10)
--dis.list(m,0x102,10)
--cpu.state()

assert(cpu.r.a==0x9d)

-- adc a,r
o.orangeRed("  adc a,r\n")

cpu:reset()

assemble([[
	ld hl,&0102
	ld bc,&03ff
	adc c
	adc l
	ld c,a
	ld a,0
	adc a,h
	adc a,b
	halt
]])

cpu:run()

--dis.list(m,0,8)
--dis.list(m,0x102,10)
--cpu.state()

assert(cpu.r.a==0x05 and cpu.r.c==0x01)

-- adc a,n
o.orangeRed("  adc a,n\n")

cpu:reset()

assemble([[
	ld hl,&ff02
	ld bc,&03ff
	adc a,c
	adc l
	ld c,a
	ld a,0
	adc a,h
	adc a,b
	adc a,3
	halt
]])

cpu:run()

--dis.list(m,0,9)
--dis.list(m,0x102,10)
--cpu.state()

assert(cpu.r.a==0x07 and cpu.r.c==0x01)

-- adc a,(hl)
o.orangeRed("  adc a,(hl)\n")

cpu:reset()

assemble([[
	ld hl,&0001
	ld bc,&03ff
	adc c
	adc l
	ld c,a
	ld a,0
	adc a,h
	adc a,b
	adc a,&3
	adc a,(hl)
	halt
]])

cpu:run()

--dis.list(m,0,10)
--dis.list(m,0x102,10)
--cpu.state()

assert(cpu.r.a==0x08 and cpu.r.c==0x00)

-- adc a,(ix+n)
o.orangeRed("  adc a,(ix+d)\n")

cpu:reset()

assemble([[
	ld hl,&0001
	ld bc,&03ff
	adc c
	adc l
	ld c,a
	ld a,0
	adc a,h
	adc a,b
	adc a,3
	adc (hl)
	ld ix,3
	adc a,(ix+0)
	halt
]])

cpu:run()

--dis.list(m,0,20)
--state()
--dis.list(m,0x102,10)
--cpu.state()

assert(cpu.r.a==0x09 and cpu.r.c==0x00)

-- adc a,(iy+n)
o.orangeRed("  adc a,(iy+d)\n")

cpu:reset()

assemble([[
	ld hl,&0001
	ld bc,&03ff
	adc c
	adc l
	ld c,a
	ld a,0
	adc a,h
	adc a,b
	adc a,3
	adc (hl)
	ld iy,3
	adc a,(iy+0)
	halt
]])

cpu:run()

--dis.list(m,0,10)
--dis.list(m,0x102,10)
--cpu.state()

assert(cpu.r.a==0x09 and cpu.r.c==0x00)

-- sub r
o.orangeRed("  sub r\n")

cpu:reset()

assemble([[
	ld a,&80
	ld hl,&0102
	ld bc,&0304
	sub b
	sub a,c
	sub h
	sub l
	halt
]])


cpu:run()

--dis.list(m,0,10)
--cpu.state()

assert(cpu.r.a==118)

-- sub n
o.orangeRed("  sub n\n")

cpu:reset()

assemble([[
	ld a,&80
	ld hl,&0102
	ld bc,&0304
	sub b
	sub c
	sub h
	sub l
	sub a,5
	halt
]])

cpu:run()

--dis.list(m,0,10)
--cpu.state()

assert(cpu.r.a==113)

-- sub (hl)
o.orangeRed("  sub (hl)\n")

cpu:reset()

assemble([[
	ld a,&80
	ld hl,&0002
	ld bc,&0304
	sub b
	sub c
	sub h
	sub l
	sub 5
	sub (hl)
	halt
]])

cpu:run()

--dis.list(m,0,10)
--cpu.state()

assert(cpu.r.a==81)

-- sub (ix+d)
o.orangeRed("  sub (ix+d)\n")

cpu:reset()

assemble([[
	ld a,&80
	ld hl,&0002
	ld bc,&0304
	sub b
	sub c
	sub h
	sub l
	sub 5
	sub (hl)
	sub (ix+2)
	halt
]])

cpu:run()

--dis.list(m,0,10)
--cpu.state()

assert(cpu.r.a==48)

-- sub (iy+d)
o.orangeRed("  sub (iy+d)\n")

cpu:reset()

assemble([[
	ld a,&80
	ld hl,&0002
	ld bc,&0304
	sub b
	sub c
	sub h
	sub l
	sub 5
	sub (hl)
	sub (iy+2)
	halt
]])

cpu:run()

--dis.list(m,0,10)
--cpu.state()

assert(cpu.r.a==48)

-- sbc a,r
o.orangeRed("  sbc a,r\n")

cpu:reset()

assemble([[
	ld hl,&0302
	ld bc,&01ff
	add a,l
	sbc a,c
	ld c,a
	ld a,06
	sbc a,h
	sbc a,b
	halt
]])

cpu:run()

--dis.list(m,0,8)
--dis.list(m,0x102,10)
--cpu.state()

assert(cpu.r.a==0x01 and cpu.r.c==0x03)

-- sbc a,n
o.orangeRed("  sbc a,n\n")

cpu:reset()

assemble([[
	ld hl,&0302
	ld bc,&01ff
	add a,l
	sbc a,c
	ld c,a
	ld a,06
	sbc a,h
	sbc a,b
	sbc a,3
	halt

	org &302
	byte 0x01
]])

cpu:run()

--dis.list(m,0,9)
--dis.list(m,0x102,10)
--cpu.state()

assert(cpu.r.a==0xfe and cpu.r.c==0x03)

-- sbc a,(hl)
o.orangeRed("  sbc a,(hl)\n")

cpu:reset()

assemble([[
	ld hl,&0302
	ld bc,&01ff
	add a,l
	sbc a,c
	ld c,a
	ld a,6
	sbc a,h
	sbc a,b
	sbc a,02
	sbc a,(hl)
	halt

	org &302
	byte 0x01
]])

cpu:run()

--dis.list(m,0,10)
--dis.list(m,0x102,10)
--state()

assert(cpu.r.a==0xfd and cpu.r.c==0x03)

-- sbc a,(ix+d)
o.orangeRed("  sbc a,(ix+d)\n")

cpu:reset()

assemble([[
	ld hl,&0302
	ld bc,&01ff
	add a,l
	sbc a,c
	ld c,a
	ld a,6
	sbc h
	sbc b
	sbc %10
	sbc a,(hl)
	sbc (ix+2-1)
	halt

	org &302
	byte 0x01
]])

cpu:run()
--state()
--dis.list(m,0,10)
--dis.list(m,0x102,10)
--state()

assert(cpu.r.a==0xfb and cpu.r.c==0x03)

-- sbc a,(iy+d)
o.orangeRed("  sbc a,(iy+d)\n")

cpu:reset()

assemble([[
	ld hl,&0302
	ld bc,&01ff
	add a,l
	sbc a,c
	ld c,a
	ld a,6
	sbc h
	sbc b
	sbc %10
	sbc a,(hl)
	sbc (iy+2-1)
	halt

	org &302
	byte 0x01
]])

cpu:run()

--dis.list(m,0,10)
--dis.list(m,0x102,10)
--cpu.state()

assert(cpu.r.a==0xfb and cpu.r.c==0x03)

-- and r
o.orangeRed("  and r\n")

cpu:reset()

assemble([[
	ld a,&ff
	ld bc,&0f00
	and a,b
	halt
]])

cpu:run()

--dis.list(m,0,5)
--cpu.state()

assert(cpu.r.a==0x0f)

-- and n
o.orangeRed("  and n\n")

cpu:reset()

assemble([[
	ld a,&ff
	ld bc,&0f00
	and b
	and 3
	halt
]])

cpu:run()

--dis.list(m,0,5)
--cpu.state()

assert(cpu.r.a==0x03)

-- and (hl)
o.orangeRed("  and (hl)\n")

cpu:reset()

assemble([[
	ld a,&ff
	ld bc,&0f00
	and b
	and (hl)
	halt
]])

cpu:run()

--dis.list(m,0,5)
--cpu.state()

assert(cpu.r.a==0x0e)

-- and (ix+d)
o.orangeRed("  and (ix+d)\n")

cpu:reset()

assemble([[
	ld a,&ff
	ld bc,&0f00
	and b
	and (ix+2)
	halt
]])

cpu:run()

--dis.list(m,0,5)
--cpu.state()

assert(cpu.r.a==0x01)

-- and (iy+d)
o.orangeRed("  and (iy+d)\n")

cpu:reset()

assemble([[
	ld a,&ff
	ld bc,&0f00
	and b
	and a,(iy+3-1)
	halt
]])

cpu:run()

--dis.list(m,0,5)
--cpu.state()

assert(cpu.r.a==0x01)

-- or r
o.orangeRed("  or r\n")

cpu:reset()

assemble([[
	ld a,0
	ld bc,&0f00
	or b
	halt
]])

cpu:run()

--dis.list(m,0,5)
--cpu.state()

assert(cpu.r.a==0x0f)

-- or n
o.orangeRed("  or n\n")

cpu:reset()

assemble([[
	ld a,0
	ld bc,&f00
	or b
	or a,&30
	halt
]])

cpu:run()

--dis.list(m,0,5)
--cpu.state()

assert(cpu.r.a==0x3f)

-- or (hl)
o.orangeRed("  or (hl)\n")

cpu:reset()

assemble([[
	ld a,0
	ld bc,&f00
	or b
	or (hl)
	halt
]])

cpu:run()

--dis.list(m,0,5)
--cpu.state()

assert(cpu.r.a==0x3f)

-- or (ix+d)
o.orangeRed("  or (ix+d)\n")

cpu:reset()

assemble([[
	ld a,0
	ld bc,&f00
	or b
	or (ix+0)
	halt
]])

cpu:run()

--dis.list(m,0,5)
--cpu.state()

assert(cpu.r.a==0x3f)

-- or (iy+d)
o.orangeRed("  or (iy+d)\n")

cpu:reset()

assemble([[
	ld a,0
	ld bc,&f00
	or b
	or (iy+5)
	halt
]])

cpu:run()

--dis.list(m,0,5)
--cpu.state()

assert(cpu.r.a==0xbf)

-- xor r
o.orangeRed("  xor r\n")

cpu:reset()

assemble([[
	ld a,0
	ld bc,&f00
	xor b
	halt
]])

cpu:run()

--dis.list(m,0,5)
--cpu.state()

assert(cpu.r.a==0x0f)

-- xor n
o.orangeRed("  xor n\n")

cpu:reset()

assemble([[
	ld a,0
	ld bc,&f00
	xor b
	xor &30
	halt
]])

cpu:run()

--dis.list(m,0,5)
--cpu.state()

assert(cpu.r.a==0x3f)

-- xor (hl)
o.orangeRed("  xor (hl)\n")

cpu:reset()

assemble([[
	ld a,&ff
	ld bc,&f00
	xor b
	xor (hl)
	halt
]])

cpu:run()

--dis.list(m,0,5)
--cpu.state()

assert(cpu.r.a==0xce)

-- xor (ix+d)
o.orangeRed("  xor (ix+d)\n")

cpu:reset()

assemble([[
	ld a,0
	ld bc,&f00
	xor b
	xor (ix+0)
	halt
]])

cpu:run()

--dis.list(m,0,5)
--cpu.state()

assert(cpu.r.a==0x31)

-- xor (iy+d)
o.orangeRed("  xor (iy+d)\n")

cpu:reset()

assemble([[
	ld a,0
	ld bc,&f00
	xor b
	xor (iy+5)
	halt
]])

cpu:run()

--dis.list(m,0,5)
--cpu.state()

assert(cpu.r.a==0xa7)

-- cp r
o.orangeRed("  cp r\n")

cpu:reset()

assemble([[
	ld a,0
	ld bc,&f00
	cp b
	halt
]])

cpu:run()

--dis.list(m,0,5)
--cpu.state()

assert(band(0x01,cpu.r.f)~=0 and band(0x40,cpu.r.f)==0 and cpu.r.a==0)

-- xor n
o.orangeRed("  cp n\n")

cpu:reset()

assemble([[
	ld a,0
	ld bc,&f00
	cp &30
	halt
]])

cpu:run()

--dis.list(m,0,5)
--cpu.state()

assert(band(0x01,cpu.r.f)~=0 and band(0x40,cpu.r.f)==0 and cpu.r.a==0)

-- cp (hl)
o.orangeRed("  cp (hl)\n")

cpu:reset()

assemble([[
	ld a,&ff
	ld hl,&1
	cp (hl)
	halt
]])

cpu:run()

--dis.list(m,0,5)
--cpu.state()

assert(band(0x01,cpu.r.f)==0 and band(0x40,cpu.r.f)~=0 and cpu.r.a==0xff)

-- cp (ix+d)
o.orangeRed("  cp (ix+d)\n")

cpu:reset()

assemble([[
	ld a,&ff
	ld bc,&f00

	cp (ix+0)
	halt
]])

cpu:run()

--dis.list(m,0,5)
--cpu.state()

assert(band(0x01,cpu.r.f)==0 and band(0x40,cpu.r.f)==0 and cpu.r.a==0xff)

-- cp (iy+d)
o.orangeRed("  cp (iy+d)\n")

cpu:reset()

assemble([[
	ld a,0
	ld bc,&f00
	cp (iy+5)
	halt
]])

cpu:run()

--dis.list(m,0,5)
--cpu.state()

assert(band(0x01,cpu.r.f)~=0 and band(0x40,cpu.r.f)==0 and cpu.r.a==0x0)

-- inc r
o.orangeRed("  inc r\n")

cpu:reset()

assemble([[
	ld a,&10
	inc a
	halt
]])

cpu:run()

--dis.list(m,0,2)
--cpu.state()

assert(cpu.r.a==0x11)

-- inc (hl)
o.orangeRed("  inc (hl)\n")

cpu:reset()

assemble([[
	ld a,0x10
	inc a
	inc (hl)
	halt
]])

cpu:run()

--dis.list(m,0,2)
--cpu.state()

assert(cpu.r.a==0x11 and m:get(0x0)==0x3f)

-- inc (ix+d)
o.orangeRed("  inc (ix+d)\n")

cpu:reset()

assemble([[
	ld a,&10
	inc a
	inc (ix+2)
	halt
]])

cpu:run()

--dis.list(m,0,2)
--cpu.state()

assert(cpu.r.a==0x11 and m:get(0x02)==0x3d)


-- inc (iy+d)
o.orangeRed("  inc (iy+d)\n")

cpu:reset()

assemble([[
	ld a,&10
	inc a
	inc (iy+3)
	halt
]])

cpu:run()

--dis.list(m,0,2)
--cpu.state()

assert(cpu.r.a==0x11 and m:get(0x03)==0xfe)

-- dec r
o.orangeRed("  dec r\n")

cpu:reset()

assemble([[
	ld a,&10
	dec a
	halt
]])

cpu:run()

--dis.list(m,0,2)
--cpu.state()

assert(cpu.r.a==0x0f)

-- dec (hl)
o.orangeRed("  dec (hl)\n")

cpu:reset()

assemble([[
	ld a,&10
	dec a
	dec (hl)
	halt
]])

cpu:run()

--dis.list(m,0,2)
--cpu.state()

assert(cpu.r.a==0x0f and m:get(0x0)==0x3d)

-- dec (ix+d)
o.orangeRed("  dec (ix+d)\n")

cpu:reset()

assemble([[
	ld a,&10
	dec a
	dec (ix+2)
	halt
]])

cpu:run()

--dis.list(m,0,2)
--cpu.state()

assert(cpu.r.a==0x0f and m:get(0x02)==0x3c)


-- dec (iy+d)
o.orangeRed("  dec (iy+d)\n")

cpu:reset()

assemble([[
	ld a,&10
	dec a
	dec (iy+3)
	halt
]])

cpu:run()

--dis.list(m,0,2)
--cpu.state()

assert(cpu.r.a==0x0f and m:get(0x03)==0xfc)

-- daa
o.orangeRed("  daa\n")

cpu:reset()

assemble([[
	ld a,&15
	ld b,&27
	add a,b
	daa
	halt
]])

--dis.list(m,0,10)
cpu:run()
assert(cpu.r.a==0x42)

-- cpl
o.orangeRed("  cpl\n")

cpu:reset()

assemble([[
	ld a,&bb
	cpl
	halt
]])

cpu:run()


--dis.list(m,0,2)
--cpu.state()
assert(cpu.r.a==0x44)
-- neg
o.orangeRed("  neg\n")

cpu:reset()

assemble([[
	ld a,&98
	neg
	halt
]])

cpu:run()

--dis.list(m,0,2)
--cpu.state()


assert(cpu.r.a==0x68)

-- ccf
o.orangeRed("  ccf\n")

cpu:reset()

assemble([[
	ld a,&98
	neg
	ccf
	halt
]])

cpu:run()

--dis.list(m,0,3)
--cpu.state()


assert(cpu.r.a==0x68 and band(cpu.r.f,0x1)==0 and band(cpu.r.f,0x10)~=0)

-- scf
o.orangeRed("  scf\n")

cpu:reset()

assemble([[
	ld a,0x98
	neg
	ccf
	scf
	halt
]])

cpu:run()

--dis.list(m,0,4)
--cpu.state()


assert(cpu.r.a==0x68 and band(cpu.r.f,0x1)~=0 and band(cpu.r.f,0x10)==0)

-- halt
o.orangeRed("  halt\n")

cpu:reset()

assemble([[
	ld a,0x98
	neg
	ccf
	scf
	halt
]])

cpu:run()

--dis.list(m,0,4)
--cpu.state()


assert(cpu.r.a==0x68)
assert(band(cpu.r.f,0x1)~=0)
assert(band(cpu.r.f,0x10)==0)
assert(cpu.r.pc==0x7)

-- di
o.orangeRed("  di\n")

cpu:reset()

assemble([[
	di
	halt
]])

cpu:run(10)

--dis.list(m,0,4)
--cpu.state()

--print(cpu.r.iff,cpu.r.iff2)
assert(cpu.r.iff==0 and cpu.r.iff2==0)

-- ei
o.orangeRed("  ei\n")

cpu:reset()

assemble([[
	ei
	halt
]])

cpu:run(1000)

--dis.list(m,0,4)
--state()


assert(cpu.r.iff==1 and cpu.r.iff2==1)

-- im 0
o.orangeRed("  im 0\n")

cpu:reset()

assemble([[
	im 0
	halt
]])

cpu:run(1000)

--dis.list(m,0,4)
--cpu.state()


assert(cpu.r.iMode==0)

-- im 1
o.orangeRed("  im 1\n")

cpu:reset()

assemble([[
	im 1
	halt
]])

cpu:run(1000)

--dis.list(m,0,4)
--cpu.state()


assert(cpu.r.iMode==1)

-- im 2
o.orangeRed("  im 2\n")

cpu:reset()

assemble([[
	im 2
	halt
]])

cpu:run(1000)

--dis.list(m,0,4)
--cpu.state()


assert(cpu.r.iMode==2)

-- add hl,rr
o.orangeRed("  add hl,rr\n")

cpu:reset()

assemble([[
	ld hl,0x4000
	ld bc,0x1000
	add hl,bc
	halt
]])

cpu:run(1000)

--dis.list(m,0,4)
--cpu.state()

assert(cpu.r.hl==0x5000)

-- adc hl,rr
o.orangeRed("  adc hl,rr\n")

cpu:reset()

assemble([[
	ld hl,&4000
	ld bc,&1000
	scf
	adc hl,bc
	halt
]])

cpu:run(1000)

--dis.list(m,0,4)
--cpu.state()

assert(cpu.r.hl==0x5001)

-- sbc hl,rr
o.orangeRed("  sbc hl,rr\n")

cpu:reset()

assemble([[
	ld hl,&4000
	ld de,&1000
	scf
	sbc hl,de
	halt
]])

cpu:run(1000)

--dis.list(m,0,4)
--cpu.state()

assert(cpu.r.hl==0x2fff)

-- add ix,rr
o.orangeRed("  add ix,rr\n")

cpu:reset()

assemble([[
	ld ix,&4000
	ld bc,&1000
	add ix,bc
	halt
]])

cpu:run()

--dis.list(m,0,4)
--cpu.state()

assert(cpu.r.ix==0x5000)


-- add iy,rr
o.orangeRed("  add iy,rr\n")

cpu:reset()

assemble([[
	ld iy,&4000
	ld de,&1000
	add iy,iy
	halt
]])

--dis.list(m,0,4)

cpu:run(1000)

--dis.list(m,0,4)
--cpu.state()

assert(cpu.r.iy==0x8000)

-- inc rr
o.orangeRed("  inc rr\n")

cpu:reset()

assemble([[
	ld hl,&4000
	ld bc,&1000
	inc bc
	inc hl
	halt
]])

cpu:run()

--dis.list(m,0,4)
--cpu.state()

assert(cpu.r.hl==0x4001 and cpu.r.bc==0x1001)


-- inc ix
o.orangeRed("  inc ix\n")

cpu:reset()

assemble([[
	ld ix,&4000
	ld bc,&1000
	inc bc
	inc ix
	halt
]])

cpu:run(1000)

--dis.list(m,0,4)
--cpu.state()

assert(cpu.r.ix==0x4001 and cpu.r.bc==0x1001)

-- inc iy
o.orangeRed("  inc iy\n")

cpu:reset()

assemble([[
	ld iy,&4000
	ld bc,&1000
	inc bc
	inc iy
	halt
]])

cpu:run(1000)

--dis.list(m,0,4)
--cpu.state()

assert(cpu.r.iy==0x4001 and cpu.r.bc==0x1001)

-- dec rr
o.orangeRed("  dec rr\n")

cpu:reset()

assemble([[
	ld hl,&4000
	ld bc,&1000
	dec bc
	dec hl
	halt
]])

cpu:run()

--dis.list(m,0,5)
--cpu.state()

assert(cpu.r.hl==0x3fff and cpu.r.bc==0x0fff)


-- dec ix
o.orangeRed("  dec ix\n")

cpu:reset()

assemble([[
	ld ix,&4000
	ld bc,&1000
	dec bc
	dec ix
	halt
]])

cpu:run()

--dis.list(m,0,4)
--cpu.state()

assert(cpu.r.ix==0x3fff and cpu.r.bc==0x0fff)

-- dec iy
o.orangeRed("  dec iy\n")

cpu:reset()

assemble([[
	ld iy,&4000
	ld bc,&1000
	dec bc
	dec iy
	halt
]])

cpu:run()

--dis.list(m,0,4)
--cpu.state()

assert(cpu.r.iy==0x3fff and cpu.r.bc==0x0fff)

-- rlca
o.orangeRed("  rlca\n")

cpu:reset()

assemble([[
	ld a,&80
	rlca
	rlca
	halt
]])

cpu:run()

--dis.list(m,0,4)
--cpu.state()

assert(cpu.r.a==0x02 and band(cpu.r.f,0x1)==0)

-- rla
o.orangeRed("  rla\n")

cpu:reset()

assemble([[
	ld a,&80
	rla
	rla
	halt
]])

cpu:run()

--dis.list(m,0,4)
--cpu.state()

assert(cpu.r.a==0x01 and band(cpu.r.f,0x1)==0)

-- rrca
o.orangeRed("  rrca\n")

cpu:reset()

assemble([[
	ld a,&81
	rrca
	rrca
	halt
]])

cpu:run()

--dis.list(m,0,4)
--cpu.state()

assert(cpu.r.a==0x60 and band(cpu.r.f,0x1)==0)

-- rra
o.orangeRed("  rra\n")

cpu:reset()

assemble([[
	ld a,&81
	rra
	rra
	halt
]])

cpu:run()

--dis.list(m,0,4)
--cpu.state()

assert(cpu.r.a==0xa0 and band(cpu.r.f,0x1)==0)

-- rlc r 
o.orangeRed("  rlc r\n")

cpu:reset()

assemble([[
	ld b,&80
	rlc b
	rlc b
	halt
]])

cpu:run()

--dis.list(m,0,4)
--cpu.state()

assert(cpu.r.b==0x02 and band(cpu.r.f,0x1)==0)

-- rlc (hl)
o.orangeRed("  rlc (hl)\n")

cpu:reset()

assemble([[
	ld hl,&4001
	rlc (hl)
	rlc (hl)
	halt

	org &4001
	byte &80
]])

cpu:run()

--dis.list(m,0,4)
--cpu.state()

assert(m:get(0x4001)==0x02 and band(cpu.r.f,0x1)==0)

-- rlc (ix+d)
o.orangeRed("  rlc (ix+d)\n")

cpu:reset()
--state()
assemble([[
	ld ix,&4003
	rlc (ix-2)
	rlc (ix-2)
	halt

	org &4001
	byte &80
]])

--dis.list(m,0,10)
cpu:run()
--state()
--dis.list(m,0,4)
--cpu.state()

assert(m:get(0x4001)==0x02 and band(cpu.r.f,0x1)==0)

-- rlc (iy+d)
o.orangeRed("  rlc (iy+d)\n")

cpu:reset()

assemble([[
	ld iy,&0001
	rlc (iy-2)
	rlc (iy-2)
	halt

	org &1ffff
	byte &80
]])

--dis.list(m,0,4)
cpu:run()

--dis.list(m,0,4)
--cpu.state()

assert(m:get(0xffff)==0x02 and band(cpu.r.f,0x1)==0)

-- rl r 
o.orangeRed("  rl r\n")

cpu:reset()

assemble([[
	ld b,&80
	rl b
	rl b
	halt
]])

cpu:run()

--dis.list(m,0,4)
--cpu.state()

assert(cpu.r.b==0x01 and band(cpu.r.f,0x1)==0)

-- rl (hl)
o.orangeRed("  rl (hl)\n")

cpu:reset()

assemble([[
	ld hl,&4001
	rl (hl)
	rl (hl)
	halt

	org &4001
	byte 128
]])

cpu:run(1000)

--dis.list(m,0,4)
--cpu.state()

assert(m:get(0x4001)==0x01 and band(cpu.r.f,0x1)==0)

-- rl (ix+d)
o.orangeRed("  rl (ix+d)\n")

cpu:reset()

assemble([[
	ld ix,&4003
	rl (ix-2)
	rl (ix-2)
	halt

	org &4001
	byte &80
]])

cpu:run(1000)

--dis.list(m,0,4)
--cpu.state()

assert(m:get(0x4001)==0x01 and band(cpu.r.f,0x1)==0)

-- rl (iy+d)
o.orangeRed("  rl (iy+d)\n")

cpu:reset()

assemble([[
	ld iy,1
	rl (iy-2)
	rl (iy-2)
	halt

	org &ffff
	byte &80
]])

cpu:run(1000)

--dis.list(m,0,4)
--cpu.state()

assert(m:get(0xffff)==0x01 and band(cpu.r.f,0x1)==0)

-- rrc r 
o.orangeRed("  rrc r\n")

cpu:reset()

assemble([[
	ld b,&80
	rrc b
	rrc b
	halt
]])

cpu:run()

--dis.list(m,0,4)
--cpu.state()

assert(cpu.r.b==0x20 and band(cpu.r.f,0x1)==0)

-- rrc (hl)
o.orangeRed("  rrc (hl)\n")

cpu:reset()

assemble([[
	ld hl,&4001
	rrc (hl)
	rrc (hl)
	halt

	org &4001
	byte &81
]])

cpu:run(1000)

--dis.list(m,0,4)
--cpu.state()

assert(m:get(0x4001)==0x60 and band(cpu.r.f,0x1)==0)

-- rrc (ix+d)
o.orangeRed("  rrc (ix+d)\n")

cpu:reset()

assemble([[
	ld ix,&4003
	rrc (ix-2)
	rrc (ix-2)
	halt

	org &4001
	byte &80
]])

cpu:run(1000)

--dis.list(m,0x4000,10)
--cpu.state()

assert(m:get(0x4001)==0x20 and band(cpu.r.f,0x1)==0)

-- rrc (iy+d)
o.orangeRed("  rrc (iy+d)\n")

cpu:reset()

assemble([[
	ld iy,&1
	rrc (iy-2)
	rrc (iy-2)
	halt

	org &ffff
	byte &80
]])


cpu:run(1000)

--dis.list(m,0,4)
--cpu.state()

assert(m:get(0xffff)==0x20 and band(cpu.r.f,0x1)==0)

-- rr r 
o.orangeRed("  rr r\n")

cpu:reset()

assemble([[
	ld b,&80
	rr b
	rr b
	halt
]])

cpu:run(1000)

--dis.list(m,0,4)
--cpu.state()
--state()

--print(band(cpu.r.f,0x1),cpu.r.b)
assert(cpu.r.b==0x20 and band(cpu.r.f,0x1)==0)

-- rr (hl)
o.orangeRed("  rr (hl)\n")

cpu:reset()

assemble([[
	ld hl,&4001
	rr (hl)
	rr (hl)
	halt

	org &4001
	byte &81
]])

cpu:run(1000)

--dis.list(m,0,4)
--state()
--print(m:get(0x4001))
assert(m:get(0x4001)==0xa0 and band(cpu.r.f,0x1)==0)

-- rr (ix+d)
o.orangeRed("  rr (ix+d)\n")

cpu:reset()

assemble([[
	ld ix,&4003
	rr (ix-2)
	rr (ix-2)
	halt

	org &4001
	byte &80
]])

cpu:run(1000)

--dis.list(m,0x4000,10)
--cpu.state()

assert(m:get(0x4001)==0x20 and band(cpu.r.f,0x1)==0)

-- rr (iy+d)
o.orangeRed("  rr (iy+d)\n")

cpu:reset()

assemble([[
	ld iy,1
	rr (iy-2)
	rr (iy-2)
	halt

	org &ffff
	byte &80
]])

cpu:run(1000)

--dis.list(m,0,4)
--cpu.state()

assert(m:get(0xffff)==0x20 and band(cpu.r.f,0x1)==0)

-- sla r 
o.orangeRed("  sla r\n")

cpu:reset()

assemble([[
	ld b,&80
	sla b
	sla b
	halt
]])

cpu:run(1000)

--dis.list(m,0,4)
--cpu.state()

assert(cpu.r.b==0x00 and band(cpu.r.f,0x1)==0)

-- sla (hl)
o.orangeRed("  sla (hl)\n")

cpu:reset()

assemble([[
	ld hl,&4001
	sla (hl)
	sla (hl)
	halt

	org &4001
	byte &81
]])

cpu:run(1000)

--dis.list(m,0,4)
--cpu.state()

assert(m:get(0x4001)==0x04 and band(cpu.r.f,0x1)==0)

-- sla (ix+d)
o.orangeRed("  sla (ix+d)\n")

cpu:reset()

assemble([[
	ld ix,&4003
	sla (ix-2)
	sla (ix-2)
	halt

	org &4001
	byte &82
]])

cpu:run(1000)

--dis.list(m,0x4000,10)
--cpu.state()

assert(m:get(0x4001)==0x8 and band(cpu.r.f,0x1)==0)

-- sla (iy+d)
o.orangeRed("  sla (iy+d)\n")

cpu:reset()

assemble([[
	ld iy,&0001
	sla (iy-2)
	sla (iy-2)
	halt

	org &ffff
	byte &90
]])

cpu:run(1000)

--dis.list(m,0,4)
--cpu.state()

assert(m:get(0xffff)==0x40 and band(cpu.r.f,0x1)==0)

-- sra r 
o.orangeRed("  sra r\n")

cpu:reset()

assemble([[
	ld b,&80
	sra b
	sra b
	halt
]])

cpu:run(1000)

--dis.list(m,0,4)
--cpu.state()

assert(cpu.r.b==0xe0 and band(cpu.r.f,0x1)==0)

-- sra (hl)
o.orangeRed("  sra (hl)\n")

cpu:reset()

assemble([[
	ld hl,&4001
	sra (hl)
	sra (hl)
	halt

	org &4001
	byte &81
]])

cpu:run(1000)

--dis.list(m,0,4)
--cpu.state()

assert(m:get(0x4001)==0xe0 and band(cpu.r.f,0x1)==0)

-- sra (ix+d)
o.orangeRed("  sra (ix+d)\n")

cpu:reset()

assemble([[
	ld ix,&4003
	sra (ix-2)
	sra (ix-2)
	halt

	org &4001
	byte &82
]])


m:set(12,0x76) -- halt

cpu:run(1000)

--dis.list(m,0x4000,10)
--cpu.state()
--dis.list(m,0x4000,10)

assert(m:get(0x4001)==0xe0 and band(cpu.r.f,0x1)~=0)

-- sra (iy+d)
o.orangeRed("  sra (iy+d)\n")

cpu:reset()

assemble([[
	ld iy,&0001
	sra (iy-2)
	sra (iy-2)
	halt

	org &ffff
	byte &90
]])

--dis.list(m,0xffff,4)
cpu:run(1000)
--dis.list(m,0xffff,4)

--dis.list(m,0,4)
--cpu.state()

assert(m:get(0xffff)==0xe4 and band(cpu.r.f,0x1)==0)

-- srl r 
o.orangeRed("  srl r\n")

cpu:reset()

assemble([[
	ld b,&80
	srl b
	srl b
	halt
]])

cpu:run(1000)

--dis.list(m,0,4)
--cpu.state()

assert(cpu.r.b==0x20 and band(cpu.r.f,0x1)==0)

-- srl (hl)
o.orangeRed("  srl (hl)\n")

cpu:reset()

assemble([[
	ld hl,&4001
	srl (hl)
	srl (hl)
	halt

	org &4001
	byte &81
]])

cpu:run(1000)

--dis.list(m,0,4)
--cpu.state()

assert(m:get(0x4001)==0x20 and band(cpu.r.f,0x1)==0)

-- srl (ix+d)
o.orangeRed("  srl (ix+d)\n")

cpu:reset()

assemble([[
	ld ix,&4003
	srl (ix-2)
	srl (ix-2)
	halt

	org &4001
	byte &82
]])

--dis.list(m,0,10)
cpu:run(1000)


--dis.list(m,0x4001,10)
--cpu.state()

assert(m:get(0x4001)==0x20 and band(cpu.r.f,0x1)==1)

-- srl (iy+d)
o.orangeRed("  srl (iy+d)\n")

cpu:reset()

assemble([[
	ld iy,&1
	srl (iy-2)
	srl (iy-2)
	halt

	org &ffff
	byte &90
]])


cpu:run(1000)

--dis.list(m,0,4)
--cpu.state()

assert(m:get(0xffff)==0x24 and band(cpu.r.f,0x1)==0)

-- rld
o.orangeRed("  rld\n")

cpu:reset()

assemble([[
	org &ffff
	byte &95
	ld hl,&ffff
	ld a,&12
	rld
	halt
]])

cpu:run(1000)

--dis.list(m,0,4)
--cpu.state()
--dis.list(m,0xfff0,0x10)

assert(cpu.r.a==0x19 and m:get(0xffff)==0x52)

-- rrd
o.orangeRed("  rrd\n")

cpu:reset()

assemble([[
	org &ffff
	byte &95
	ld hl,&ffff
	ld a,&12
	rrd
	halt
]])

cpu:run()

--dis.list(m,0xffff,10)
--cpu.state()
--dis.list(m,0xfff0,0x10)

assert(cpu.r.a==0x15 and m:get(0xffff)==0x29)

-- bit r,n
o.orangeRed("  bit b,r\n")

cpu:reset()

assemble([[
	ld a,&f0
	bit 0,a
	halt
]])

cpu:run(1000)

--dis.list(m,0,4)
--cpu.state()
--dis.list(m,0xfff0,0x10)

assert(band(cpu.r.f,0x40)~=0)

cpu:reset()

assemble([[
	ld a,&f0
	bit 7,a
	halt
]])

cpu:run()

--dis.list(m,0,4)
--cpu.state()
--dis.list(m,0xfff0,0x10)

assert(band(cpu.r.f,0x40)==0)

-- bit b,(hl)
o.orangeRed("  bit b,(hl)\n")

cpu:reset()

assemble([[
	ld hl,&ffff
	bit 0,(hl)
	halt

	org &ffff
	byte &95
]])

cpu:run()

--dis.list(m,0,4)
--cpu.state()
--dis.list(m,0xfff0,0x10)

assert(band(cpu.r.f,0x40)==0)

cpu:reset()

assemble([[
	ld hl,&ffff
	bit 6,(hl)
	halt

	org &ffff
	byte &95
]])

cpu:run()

--dis.list(m,0,4)
--cpu.state()
--dis.list(m,0xfff0,0x10)

assert(band(cpu.r.f,0x40)~=0 and m:get(0xffff)==0x95)

-- bit b,(ix+d)
o.orangeRed("  bit b,(ix+d)\n")

cpu:reset()

assemble([[
	ld ix,&ffff
	bit 6,(ix+0)
	halt

	org &ffff
	byte &95
]])

cpu:run()

--dis.list(m,0,4)
--cpu.state()
--dis.list(m,0xfff0,0x10)

assert(band(cpu.r.f,0x40)~=0)

-- bit b,(iy+d)
o.orangeRed("  bit b,(iy+d)\n")

cpu:reset()

assemble([[
	ld iy,&0001
	bit 6,(iy-2)
	halt

	org &ffff
	byte &95
]])

cpu:run()

--dis.list(m,0,4)
--cpu.state()
--dis.list(m,0xfff0,0x10)

assert(band(cpu.r.f,0x40)~=0)

-- set r,n
o.orangeRed("  set b,r\n")

cpu:reset()

assemble([[
	ld a,&f0
	set 0,a
	halt
]])

cpu:run(1000)

--dis.list(m,0,4)
--cpu.state()
--dis.list(m,0xfff0,0x10)

assert(cpu.r.a==0xf1)

-- set b,(hl)
o.orangeRed("  set b,(hl)\n")

cpu:reset()

assemble([[
	ld hl,&ffff
	set 6,(hl)
	halt

	org &ffff
	byte &95
]])

cpu:run(1000)

--dis.list(m,0,4)
--cpu.state()
--dis.list(m,0xfff0,0x10)

assert(m:get(0xffff)==0xd5)

-- set b,(ix+d)
o.orangeRed("  set b,(ix+d)\n")

cpu:reset()

assemble([[
	ld ix,&ffff
	set 0,(ix+0)
	halt

	org &ffff
	byte &94
]])

cpu:run(1000)

--dis.list(m,0,4)
--cpu.state()
--dis.list(m,0xfff0,0x10)

assert(m:get(0xffff)==0x95)

-- set b,(iy+d)
o.orangeRed("  set b,(iy+d)\n")

cpu:reset()

assemble([[
	ld iy,&0001
	set 6,(iy-2)
	halt

	org &ffff
	byte &95
]])

cpu:run(1000)

--dis.list(m,0,4)
--cpu.state()
--dis.list(m,0xfff0,0x10)

assert(m:get(0xffff)==0xd5)

-- res r,n
o.orangeRed("  res b,r\n")

cpu:reset()

assemble([[
	ld a,&f0
	res 0,a
	halt
]])

cpu:run(1000)

--dis.list(m,0,4)
--cpu.state()
--dis.list(m,0xfff0,0x10)

assert(cpu.r.a==0xf0)

-- res b,(hl)
o.orangeRed("  res b,(hl)\n")

cpu:reset()

assemble([[
	ld hl,&ffff
	res 0,(hl)
	halt

	org &ffff
	byte &95
]])

cpu:run(1000)

--dis.list(m,0,4)
--cpu.state()
--dis.list(m,0xfff0,0x10)

assert(m:get(0xffff)==0x94)

-- res b,(ix+d)
o.orangeRed("  res b,(ix+d)\n")

cpu:reset()

assemble([[
	ld ix,&ffff
	res 7,(ix+0)
	halt

	org &ffff
	byte &94
]])

cpu:run(1000)

--dis.list(m,0,4)
--cpu.state()
--dis.list(m,0xfff0,0x10)

assert(m:get(0xffff)==0x14)

-- res b,(iy+d)
o.orangeRed("  res b,(iy+d)\n")

cpu:reset()

assemble([[
	ld iy,&0001
	res 6,(iy-2)
	halt

	org &ffff
	byte &95
]])

cpu:run(1000)

--dis.list(m,0,4)
--cpu.state()
--dis.list(m,0xfff0,0x10)

assert(m:get(0xffff)==0x95)

-- jp nn
o.orangeRed("  jp nn\n")

cpu:reset()

assemble([[
	ld a,&21
	jp salto
	ld a,&22
.salto
	halt
]])

cpu:run(1000)

--dis.list(m,0,4)
--cpu.state()
--dis.list(m,0xfff0,0x10)

assert(cpu.r.a==0x21)

-- jp cc,nn
o.orangeRed("  jp cc,nn\n")

cpu:reset()

assemble([[
	ld a,&21
	ld b,&ff
	add a,b
	jp c,salto
	ld a,0
.salto 	halt
]])

cpu:run(1000)

--dis.list(m,0,6)
--cpu.state()
--dis.list(m,0xfff0,0x10)

assert(cpu.r.a==0x20)

-- jr nn
o.orangeRed("  jr nn\n")

cpu:reset()

assemble([[
	ld a,&21
	jr salto
	ld a,&22
.salto
	halt
]])

--dis.list(m,0,4)
cpu:run(1000)

--dis.list(m,0,4)
--cpu.state()
--dis.list(m,0xfff0,0x10)

assert(cpu.r.a==0x21)

-- jr cc,nn
o.orangeRed("  jr cc,nn\n")

cpu:reset()

assemble([[
	ld a,&f0
	ld b,&10
.salto
	add a,b
	jr c,salto
	halt
]])


--dis.list(m,0,5)
cpu:run(1000)

--cpu.state()
--dis.list(m,0xfff0,0x10)

assert(cpu.r.a==0x10)

-- jp (hl)
o.orangeRed("  jp (hl)\n")

cpu:reset()

assemble([[
	org &fffd
.salto
	ld a,0
	halt
	ld a,&ff
	ld b,a
	ld hl,salto
	jp (hl)
	ld a,38
	halt
]])


--dis.list(m,0xfffd,10)
cpu:run()

--cpu.state()
--dis.list(m,0xfff0,0x10)

assert(cpu.r.a==0x0 and cpu.r.pc==0 and cpu.r.b==0xff)

-- jp (ix)
o.orangeRed("  jp (ix)\n")

cpu:reset()

assemble([[
	ld a,&99
	ld b,a
	ld ix,salto
	jp ix
	ld a,0
.salto
	halt
]])


--dis.list(m,0,5)
cpu:run()

--cpu.state()
--dis.list(m,0xfff0,0x10)

assert(cpu.r.a==0x99 and cpu.r.b==0x99)

-- jp (iy)
o.orangeRed("  jp (iy)\n")

cpu:reset()

assemble([[
	ld a,&99
	ld b,a
	ld iy,salto
	jp iy
	ld a,0
.salto
	halt
]])


--dis.list(m,0,10)
cpu:run()

--cpu.state()
--dis.list(m,0xfff0,0x10)

assert(cpu.r.a==0x99 and cpu.r.b==0x99)

-- djnz d
o.orangeRed("  djnz d\n")

cpu:reset()

assemble([[
	ld a,0
	ld b,5
.salto
	add a,b
	djnz salto
	halt
]])

--dis.list(m,0,5)
cpu:run()

--cpu.state()
--dis.list(m,0xfff0,0x10)

assert(cpu.r.a==0xf)

-- call d
o.orangeRed("  call nn\n")
o.orangeRed("  ret\n")

cpu:reset()

assemble([[
	ld a,1
	call function 
	halt

.function 
	ld a,&fe
	ret
]])

--dis.list(m,0,10)
--dis.list(m,0x4000,2)
cpu:run()

--cpu.state()
--dis.list(m,0xfff0,0x10)

assert(cpu.r.a==0xfe)

-- call cc,nn
o.orangeRed("  call cc,nn\n")

cpu:reset()

assemble([[
	ld a,1
	ld c,&ff
	add a,c
	call c,salto
	halt
.salto
	ld a,&fe
	ret
]])

--dis.list(m,0,10)
--dis.list(m,0x4000,2)
cpu:run()

--cpu.state()
--dis.list(m,0xfff0,0x10)

assert(cpu.r.a==0xfe)

-- ret cc
o.orangeRed("  ret cc\n")

cpu:reset()

assemble([[
	ld a,1
	ld b,&ff
	add a,b
	call c,&4000
	halt

	org &4000
	ld a,&fe
	ld b,&02
	add a,b
	ret nz
	ld a,&21
	ret
]])

--dis.list(m,0,5)
--dis.list(m,0x4000,6)
cpu:run()

--cpu.state()
--dis.list(m,0xfff0,0x10)

assert(cpu.r.a==0x21)

-- reti
o.orangeRed("  reti\n")

cpu:reset()

assemble([[
	ld a,1
	call salto
	halt

.salto
	ld a,&fe
	reti
]])

--dis.list(m,0,10)
--dis.list(m,0x4000,2)
cpu:run()

--cpu.state()
--dis.list(m,0xfff0,0x10)

assert(cpu.r.a==0xfe)

-- retn
o.orangeRed("  retn\n")

cpu:reset()

assemble([[
	ld a,1
	call salto
	halt

.salto
	ld a,&fe
	retn
]])

--dis.list(m,0,10)
--dis.list(m,0x4000,2)
cpu:run()

--cpu.state()
--dis.list(m,0xfff0,0x10)

assert(cpu.r.a==0xfe)

-- rst n
o.orangeRed("  rst n\n")

cpu:reset()

assemble([[
	ld a,1
	call &4000
	rst &38
	add a,b
	halt

	org &38
	ld a,&80
	ret

	org &4000
	ld b,1
	ret
]])

-- dis.list(m,0,5)
-- dis.list(m,0x4000,5)
-- dis.list(m,0x38,5)
cpu:run()

--cpu.state()
--dis.list(m,0xfff0,0x10)

assert(cpu.r.a==0x81)

-- in a,(n)
o.orangeRed("  in a,(n)\n")

cpu:reset()

assemble([[
	ld a,1
	in a,(0)
	halt
]])

--dis.list(m,0,5)
--dis.list(m,0x4000,2)
cpu:run()

--cpu.state()
--dis.list(m,0xfff0,0x10)

assert(cpu.r.a==0xff)

-- in r,(n)
o.orangeRed("  in r,(n)\n")

cpu:reset()

assemble([[
	ld bc,&4000
	in b,(c)
	halt
]])


--dis.list(m,0,5)
--dis.list(m,0x4000,2)
cpu:run()

--cpu.state()
--dis.list(m,0xfff0,0x10)

assert(cpu.r.b==0xff)

-- ini
o.orangeRed("  ini\n")

cpu:reset()

assemble([[
	ld bc,&8fe
	ld hl,&4000
	ini
	halt
]])

--dis.list(m,0,5)
--dis.list(m,0x4000,2)
cpu:run()
--state()

--cpu.state()
--dis.list(m,0xfff0,0x10)

assert(cpu.r.hl==0x4001 and cpu.r.b==0x7 and m:get(0x4000)==0xff)

-- inir
o.orangeRed("  inir\n")

cpu:reset()

assemble([[
	ld bc,&8fe
	ld hl,&4000
	inir
	halt
]])

--dis.list(m,0,5)
--dis.list(m,0x4000,2)
cpu:run()
--state()
--cpu.state()
--dis.list(m,0xfff0,0x10)

for i=0x4000,0x4007 do
	assert(m:get(i)==0xff)
end

assert(cpu.r.hl==0x4008 and cpu.r.b==0x0)

-- ind
o.orangeRed("  ind\n")

cpu:reset()

assemble([[
	ld bc,&8fe
	ld hl,&4000
	ind
	halt
]])

--dis.list(m,0,5)
--dis.list(m,0x4000,2)
cpu:run()

--cpu.state()
--dis.list(m,0xfff0,0x10)

assert(cpu.r.hl==0x3fff and cpu.r.b==0x7 and m:get(0x4000)==0xff)

-- indr
o.orangeRed("  indr\n")

cpu:reset()

assemble([[
	ld bc,&8fe
	ld hl,&4000
	indr
	halt
]])

--dis.list(m,0,5)
--dis.list(m,0x4000,2)
cpu:run()
--state()
--cpu.state()
--dis.list(m,0xfff0,0x10)

for i=0x4000,0x3ff9,-1 do
	--print(m:get(i))
	assert(m:get(i)==0xff)
end

assert(cpu.r.hl==0x3ff8 and cpu.r.b==0x0)

-- out (n),a
o.orangeRed("  out (n),a\n")

cpu:reset()

assemble([[
	ld a,&8f
	out (0),a
	ld a,&ff
	in a,(0)
	halt
]])

--dis.list(m,0,5)
--dis.list(m,0x4000,2)
cpu:run(10)

--cpu.state()
--dis.list(m,0xfff0,0x10)

assert(cpu.r.a==0x8f)

-- out r,(n)
o.orangeRed("  out r,(n)\n")

cpu:reset()
i.reset()

assemble([[
	ld bc,&4000
	ld a,&dd
	out (c),a
	in b,(c)
	halt
]])

--dis.list(m,0,5)
--dis.list(m,0x4000,2)
cpu:run()

--cpu.state()
--dis.list(m,0xfff0,0x10)

assert(cpu.r.b==0xdd)

-- outi
o.orangeRed("  outi\n")

cpu:reset()
i.reset()

assemble([[
	org &4000
	byte &dd,&0

	org &0
	ld bc,&8fe
	ld hl,&4000
	outi
	ini
	halt
]])

--dis.list(m,0,5)
--dis.list(m,0x4000,2)
cpu:run()

--cpu.state()
--dis.list(m,0xfff0,0x10)

assert(cpu.r.hl==0x4002 and cpu.r.b==0x6 and m:get(0x4001)==0xdd)

-- otir
o.orangeRed("  otir\n")

cpu:reset()

assemble([[
	ld bc,&8fe
	ld hl,&0000
	otir
	in a,(0)
	halt
]])

--dis.list(m,0,20)
--dis.list(m,0x4000,2)
cpu:run()
--state()
--cpu.state()
--dis.list(m,0xfff0,0x10)

assert(cpu.r.hl==0x0008 and cpu.r.a==0xb3 and cpu.r.b==0x0)

-- outd
o.orangeRed("  outd\n")

cpu:reset()
i.reset()

assemble([[
	org &4000
	byte &ee

	org &0
	ld bc,&8fe
	ld hl,&4000
	ld a,&10
	outd
	ind
	halt
]])

--dis.list(m,0,20)
--dis.list(m,0x4000,2)
cpu:run()
--state()
--cpu.state()
--dis.list(m,0xfff0,0x10)
--print(bit.tohex(m:get(0x3fff)))
assert(cpu.r.hl==0x3ffe and cpu.r.b==0x6 and m:get(0x3fff)==0xee)

-- otdr
o.orangeRed("  otdr\n")

cpu:reset()
i.reset()

assemble([[
	ld bc,&8fe
	ld hl,8
	otdr
	in a,(0)
	halt
]])

--dis.list(m,0,5)
--dis.list(m,0x4000,2)

cpu:run()
--state()
--cpu.state()
--dis.list(m,0xfff0,0x10)

assert(cpu.r.hl==0x0 and cpu.r.b==0x0 and cpu.r.a==0xfe)

o.lime('\nUNDOCUMENTED\n\n')

-- otdr
o.orangeRed("  sll\n")

cpu:reset()
i.reset()

assemble([[
	ld a,0x1
	sll a

	ld ix,0x4000

	ld (ix+1),a

	sll (ix+1)
	halt
]])

--dis.list(m,0,20)

cpu:run()
--dis.list(m,0x4000,2)
--state()
--cpu.state()
--dis.list(m,0xfff0,0x10)

assert(cpu.r.a==0x3 and m:get(0x4001)==0x7)

o.orangeRed("  ld r,r' (ixl/h iyl/h)\n")

cpu:reset()
i.reset()

assemble([[
	ld ix,0x4000
	ld iy,0
	ld a,0x80
	ld ixl,a
	ld iyh,a
	halt
]])

--dis.list(m,0,6)
--dis.list(m,0x4000,2)
cpu:run()

--state()
--dis.list(m,0xfff0,0x10)

assert(cpu.r.a==0x80 and cpu.r.ix==0x4080 and cpu.r.iy==0x8000)


o.orangeRed("  ld r,n' (ixl/h iyl/h)\n")

cpu:reset()
i.reset()

assemble([[
	ld ix,0x4000
	ld iy,0
	ld a,0x80
	ld ixl,a
	ld iyh,a
	ld iyl,0x22
	halt
]])

--dis.list(m,0,7)
--dis.list(m,0x4000,2)
cpu:run(100)

--state()
--dis.list(m,0xfff0,0x10)

assert(cpu.r.a==0x80 and cpu.r.ix==0x4080 and cpu.r.iy==0x8022)

o.orangeRed("  add a,r' (ixl/h iyl/h)\n")

cpu:reset()
i.reset()

assemble([[
	ld ix,0x4000
	ld iy,0
	ld a,0x80
	ld ixl,a
	ld iyh,a
	ld iyl,0x22
	add a,iyl
	halt
]])

--dis.list(m,0,7)
--dis.list(m,0x4000,2)
cpu:run(100)

--state()
--dis.list(m,0xfff0,0x10)

assert(cpu.r.a==0xa2 and cpu.r.ix==0x4080 and cpu.r.iy==0x8022)

o.orangeRed("  adc a,r' (ixl/h iyl/h)\n")

cpu:reset()
i.reset()

assemble([[
	ld ix,0x4000
	ld iy,0
	ld a,0x80
	ld ixl,a
	ld iyh,a
	ld iyl,0x22
	add a,iyl
	scf
	adc a,ixh
	halt
]])

--dis.list(m,0,10)
--dis.list(m,0x4000,2)
cpu:run(100)

--state()
--dis.list(m,0xfff0,0x10)

assert(cpu.r.a==0xe3 and cpu.r.ix==0x4080 and cpu.r.iy==0x8022)

o.orangeRed("  sub a,r' (ixl/h iyl/h)\n")

cpu:reset()
i.reset()

assemble([[
	ld ix,0x4000
	ld iy,0
	ld a,0x80
	ld ixl,a
	ld iyh,a
	ld iyl,0x22
	sub a,iyl
	halt
]])

--dis.list(m,0,10)
--dis.list(m,0x4000,2)
cpu:run(100)

--state()
--dis.list(m,0xfff0,0x10)

assert(cpu.r.a==0x5e and cpu.r.ix==0x4080 and cpu.r.iy==0x8022)

o.orangeRed("  sbc a,r' (ixl/h iyl/h)\n")

cpu:reset()
i.reset()

assemble([[
	ld ix,0x4000
	ld iy,0
	ld a,0x80
	ld ixl,a
	ld iyh,a
	ld iyl,0x22
	scf
	sbc a,iyl
	halt
]])

--dis.list(m,0,10)
--dis.list(m,0x4000,2)
cpu:run(100)

--state()
--dis.list(m,0xfff0,0x10)

assert(cpu.r.a==0x5d and cpu.r.ix==0x4080 and cpu.r.iy==0x8022)

o.orangeRed("  and r' (ixl/h iyl/h)\n")

cpu:reset()
i.reset()

assemble([[
	ld ix,0x4000
	ld iy,0
	ld a,0x20
	ld ixl,a
	ld iyh,a
	ld iyl,0x22
	and a,iyl
	halt
]])

--dis.list(m,0,10)
--dis.list(m,0x4000,2)
cpu:run(100)

--state()
--dis.list(m,0xfff0,0x10)

assert(cpu.r.a==0x20 and cpu.r.ix==0x4020 and cpu.r.iy==0x2022)

o.orangeRed("  or r' (ixl/h iyl/h)\n")

cpu:reset()
i.reset()

assemble([[
	ld ix,0x4000
	ld iy,0
	ld a,0x20
	ld ixl,a
	ld iyh,a
	ld iyl,0x22
	or a,iyl
	halt
]])

--dis.list(m,0,10)
--dis.list(m,0x4000,2)
cpu:run(100)

--state()
--dis.list(m,0xfff0,0x10)

assert(cpu.r.a==0x22 and cpu.r.ix==0x4020 and cpu.r.iy==0x2022)

o.orangeRed("  xor r' (ixl/h iyl/h)\n")

cpu:reset()
i.reset()

assemble([[
	ld ix,0x4000
	ld iy,0
	ld a,0x20
	ld ixl,a
	ld iyh,a
	ld iyl,0x22
	xor a,iyl
	halt
]])

--dis.list(m,0,10)
--dis.list(m,0x4000,2)
cpu:run(100)

--state()
--dis.list(m,0xfff0,0x10)

assert(cpu.r.a==0x02 and cpu.r.ix==0x4020 and cpu.r.iy==0x2022)

o.orangeRed("  cp r' (ixl/h iyl/h)\n")

cpu:reset()
i.reset()

assemble([[
	ld ix,0x4000
	ld iy,0
	ld a,0x20
	ld ixl,a
	ld iyh,a
	ld iyl,0x22
	cp iyl
	halt
]])

--dis.list(m,0,10)
--dis.list(m,0x4000,2)
cpu:run(100)

--state()
--dis.list(m,0xfff0,0x10)

assert(cpu.r.a==0x20 and band(cpu.r.f,0x1)==0x1 and cpu.r.ix==0x4020 and cpu.r.iy==0x2022)

o.orangeRed("  inc r' (ixl/h iyl/h)\n")

cpu:reset()
i.reset()

assemble([[
	ld ix,0x4000
	ld iy,0
	ld a,0x20
	ld ixl,a
	ld iyh,a
	ld iyl,0x22
	inc iyl
	halt
]])

--dis.list(m,0,10)
--dis.list(m,0x4000,2)
cpu:run(100)

--state()
--dis.list(m,0xfff0,0x10)

assert(cpu.r.a==0x20 and cpu.r.iyl==0x23 and cpu.r.ix==0x4020 and cpu.r.iy==0x2023)

o.orangeRed("  dec r' (ixl/h iyl/h)\n")

cpu:reset()
i.reset()

assemble([[
	ld ix,0x4000
	ld iy,0
	ld a,0x20
	ld ixl,a
	ld iyh,a
	ld iyl,0x22
	dec iyl
	halt
]])

--dis.list(m,0,10)
--dis.list(m,0x4000,2)
cpu:run(100)

--state()
--dis.list(m,0xfff0,0x10)

assert(cpu.r.a==0x20 and cpu.r.iyl==0x21 and cpu.r.ix==0x4020 and cpu.r.iy==0x2021)

o.white("\nAll done.\n")