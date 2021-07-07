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

local r={}

local h=require('h')
local o=require("h.io.console").o
local bit=require("bit")

local inst,ddInst,fdInst,edInst,cbInst,ddcbInst,fdcbInst={},{},{},{},{},{},{}

local function loadr(s,d,disp)
	if disp==nil then disp=1 end
	return function(mem,pc)
		return 'ld ' .. d .. ',' .. s,disp
	end
end

local function loadrn(s,disp)
	if disp==nil then disp=2 end
	return function(mem,pc)
		local n=mem:get(pc+(disp-1))
		return 'ld ' .. s .. ',' .. bit.tohex(n,2) .. 'h  #(' .. n .. ')',disp
	end
end

local function loadri(s,d)
	return function(mem,pc)
		return 'ld ' .. d .. ',(' .. s .. ')',1
	end
end

local function loadrid(s,d)
	return function(mem,pc)
		local n=mem:gets(pc+2)
		n=n>=0 and '+'..n or n

		return 'ld ' .. d .. ',(' .. s .. n .. ')',3
	end
end

local function storeri(s,d)
	return function(mem,pc)
		return 'ld (' .. d ..'),' .. s,1
	end
end

local function storerid(s,d)
	return function(mem,pc)
		local n=mem:gets(pc+2)
		n=n>=0 and '+'..n or n
		
		return 'ld (' .. d ..n..'),' .. s,3
	end
end

inst[0x0]=function()
	return 'nop',1
end

local r8={[0]='b','c','d','e','h','l',[7]='a'}
local r8ix={b='b',c='c',d='d',e='e',h='ixh',l='ixl',a='a'}
local r8iy={b='b',c='c',d='d',e='e',h='iyh',l='iyl',a='a'}

for i,s in pairs(r8) do
	for j,d in pairs(r8) do
		inst[64+j*8+i]=loadr(s,d)
		if h.eqAny(s,'h','l') or h.eqAny(d,'h','l') then
			ddInst[64+j*8+i]=loadr(r8ix[s],r8ix[d],2)
			fdInst[64+j*8+i]=loadr(r8iy[s],r8iy[d],2)
		end
	end
end

for i,s in pairs(r8) do
	inst[i*8+6]=loadrn(s)
	inst[64+i*8+6]=loadri('hl',s)
	ddInst[64+i*8+6]=loadrid('ix',s)
	fdInst[64+i*8+6]=loadrid('iy',s)
	inst[64+6*8+i]=storeri(s,'hl')
	ddInst[64+6*8+i]=storerid(s,'ix')
	fdInst[64+6*8+i]=storerid(s,'iy')

	if h.eqAny(s,'h','l') then 
		ddInst[i*8+6]=loadrn(r8ix[s],3)
		fdInst[i*8+6]=loadrn(r8iy[s],3)
	end
end

inst[0x36]=function(mem,pc)
	local n=mem:get(pc+1)
	return 'ld (hl),' .. bit.tohex(n,2) .. "h  #("..n..")",2
end

ddInst[0x36]=function(mem,pc)
	local d,n=mem:get(pc+2),mem:get(pc+3)
	d=d>0 and '+'..d or d
	return 'ld (ix'..d..'),' .. bit.tohex(n,2) .. "h  #("..n..")",4
end

fdInst[0x36]=function(mem,pc)
	local d,n=mem:get((pc+2)),mem:get(pc+3)
	d=d>0 and '+'..d or d
	return 'ld (iy'..d..'),' .. bit.tohex(n,2) .. "h  #("..n..")",4
end

inst[0xa]=loadri('bc','a')
inst[0x1a]=loadri('de','a')

inst[0x3a]=function(mem,pc)
	local d=mem:get(pc+1)+mem:get(pc+2)*0x100
	return 'ld a,(' .. bit.tohex(d,4) .. 'h)  #('..d..')',3
end

inst[0x2]=storeri('a','bc')
inst[0x12]=storeri('a','de')

inst[0x32]=function(mem,pc)
	local d=mem:get(pc+1)+mem:get(pc+2)*0x100
	return 'ld (' .. bit.tohex(d,4) .. 'h),a  #(' .. d .. ')',3
end

edInst[0x57]=function()
	return 'ld a,i',2
end

edInst[0x5f]=function()
	return 'ld a,r',2
end

edInst[0x47]=function()
	return 'ld i,a',2
end

edInst[0x4f]=function()
	return 'ld r,a',2
end



----------------------
--16-bits load group--
----------------------

local function load16r(d,o)
	return function(mem,pc)
		local dd=mem:get(pc+o)+mem:get(pc+o+1)*0x100

		return 'ld ' ..  d .. ',' .. bit.tohex(dd,4).. 'h  #(' .. dd .. ')',o+2
	end
end

inst[0x01]=load16r('bc',1) -- ld bc,nn
inst[0x11]=load16r('de',1) -- ld de,nn
inst[0x21]=load16r('hl',1) -- ld hl,nn
inst[0x31]=load16r('sp',1) -- ld sp,nn
ddInst[0x21]=load16r('ix',2) -- ld ix,nn
fdInst[0x21]=load16r('iy',2) -- ld iy,nn
	
local function load16ri(d,o)
	return function(mem,pc)
		local dd=mem:get(pc+o)+mem:get(pc+o+1)*0x100

		return 'ld ' .. d .. ',(' .. bit.tohex(dd,4).. 'h)  #(' .. dd .. ')',o+2
	end
end

inst[0x2a]=load16ri('hl',1) --ld hl,(nn)
edInst[0x4b]=load16ri('bc',2) --ld bc,(nn)
edInst[0x5b]=load16ri('de',2) --ld de,(nn)
edInst[0x6b]=load16ri('hl',2) --ld hl,(nn)
edInst[0x7b]=load16ri('sp',2) --ld sp,(nn)
ddInst[0x2a]=load16ri('ix',2) --ld ix,(nn)
fdInst[0x2a]=load16ri('iy',2) --ld iy,(nn)

local function storer16i(s,o)
	return function(mem,pc)
		local d=mem:get(pc+o)+mem:get(pc+o+1)*0x100

		return 'ld (' .. bit.tohex(d,4) .. 'h),' .. s .. '  --#(' .. d .. ')',o+2
	end
end

inst[0x22]=storer16i('hl',1) --ld (nn),hl
edInst[0x43]=storer16i('bc',2) --ld (nn),bc
edInst[0x53]=storer16i('de',2) --ld (nn),de
edInst[0x63]=storer16i('hl',2) --ld (nn),hl
edInst[0x73]=storer16i('sp',2) --ld (nn),sp
ddInst[0x22]=storer16i('ix',2) --ld (nn),bc
fdInst[0x22]=storer16i('iy',2) --ld (nn),bc

inst[0xf9]=function() return 'ld sp,hl',1 end
ddInst[0xf9]=function() return 'ld sp,ix',2 end
fdInst[0xf9]=function() return 'ld sp,iy',2 end

local function pushr(r,l)
	return function()
		return 'push '..r,l
	end
end

inst[0xc5]=pushr('bc',1) --push bc
inst[0xd5]=pushr('de',1) --push de
inst[0xe5]=pushr('hl',1) --push hl
inst[0xf5]=pushr('af',1) --push af
ddInst[0xe5]=pushr('ix',2) --push ix
fdInst[0xe5]=pushr('iy',2) --push iy

local function popr(r,l)
	return function()
		return 'pop '..r,l
	end
end

inst[0xc1]=popr('bc',1) --pop bc
inst[0xd1]=popr('de',1) --pop de
inst[0xe1]=popr('hl',1) --pop hl
inst[0xf1]=popr('af',1) --pop af
ddInst[0xe1]=popr('ix',2) --pop ix
fdInst[0xe1]=popr('iy',2) --pop iy

----------------------------------------------
--Exchange, Block Transfer, and Search Group--
----------------------------------------------

inst[0xeb]=function() return 'ex de,hl',1 end
inst[0x08]=function() return "ex af,af'",1 end
inst[0xd9]=function() return "exx",1 end
inst[0xe3]=function() return 'ex (sp),hl',1 end
ddInst[0xe3]=function() return 'ex (sp),ix',2 end
fdInst[0xe3]=function() return 'ex (sp),iy',2 end
edInst[0xa0]=function() return 'ldi',2 end
edInst[0xb0]=function() return 'ldir',2 end
edInst[0xa8]=function() return 'ldd',2 end
edInst[0xb8]=function() return 'lddr',2 end
edInst[0xa1]=function() return 'cpi',2 end
edInst[0xa9]=function() return 'cpd',2 end
edInst[0xb1]=function() return 'cpir',2 end
edInst[0xb9]=function() return 'cpdr',2 end

--------------------------
--8-Bit Arithmetic Group--
--------------------------

for i,o in pairs(r8) do
	inst[0x80+i]=function() -- add a,r
		return 'add a,' .. o,1 
	end
	inst[0x88+i]=function() -- adc a,r
		return 'adc a,' .. o,1 
	end
	inst[0x90+i]=function() -- sub r
		return 'sub ' .. o,1 
	end
	inst[0x98+i]=function() -- sbc a,r
		return 'sbc a,' .. o,1 
	end
	inst[0xa0+i]=function() -- and r
		return 'and ' .. o,1 
	end
	inst[0xb0+i]=function() -- or r
		return 'or ' .. o,1 
	end
	inst[0xa8+i]=function() -- xor r
		return 'xor ' .. o,1 
	end
	inst[0xb8+i]=function() -- cp r
		return 'cp ' .. o,1 
	end
	inst[0x8*i+4]=function() -- inc r
		return 'inc ' .. o,1 
	end
	inst[0x8*i+5]=function() -- dec r
		return 'dec ' .. o,1 
	end

	if h.eqAny(o,'h','l') then
		ddInst[0x80+i]=function()
			return 'add a,'..r8ix[o],2
		end
		fdInst[0x80+i]=function()
			return 'add a,'..r8iy[o],2
		end

		ddInst[0x88+i]=function()
			return 'adc a,'..r8ix[o],2
		end
		fdInst[0x88+i]=function()
			return 'adc a,'..r8iy[o],2
		end

		ddInst[0x90+i]=function()
			return 'sub '..r8ix[o],2
		end
		fdInst[0x90+i]=function()
			return 'sub '..r8iy[o],2
		end

		ddInst[0x98+i]=function()
			return 'sbc a,'..r8ix[o],2
		end
		fdInst[0x98+i]=function()
			return 'sbc a,'..r8iy[o],2
		end

		ddInst[0xa0+i]=function()
			return 'and '..r8ix[o],2
		end
		fdInst[0xa0+i]=function()
			return 'and '..r8iy[o],2
		end

		ddInst[0xb0+i]=function()
			return 'or '..r8ix[o],2
		end
		fdInst[0xb0+i]=function()
			return 'or '..r8iy[o],2
		end

		ddInst[0xa8+i]=function()
			return 'xor '..r8ix[o],2
		end
		fdInst[0xa8+i]=function()
			return 'xor '..r8iy[o],2
		end

		ddInst[0xb8+i]=function()
			return 'cp '..r8ix[o],2
		end
		fdInst[0xb8+i]=function()
			return 'cp '..r8iy[o],2
		end

		ddInst[0x4+i*8]=function()
			return 'inc '..r8ix[o],2
		end
		fdInst[0x4+i*8]=function()
			return 'inc '..r8iy[o],2
		end

		ddInst[0x5+i*8]=function()
			return 'dec '..r8ix[o],2
		end
		fdInst[0x5+i*8]=function()
			return 'dec '..r8iy[o],2
		end
	end
end

inst[0xc6]=function(mem,pc)
	local n=mem:get(pc+1)
	return 'add a,' .. bit.tohex(n,2) .. 'h  #('..n..')',2
end


inst[0xd6]=function(mem,pc)
	local n=mem:get(pc+1)
	return 'sub ' .. bit.tohex(n,2) .. 'h  #('..n..')',2
end

inst[0xce]=function(mem,pc)
  local n=mem:get(pc+1)
  return 'adc a,' .. bit.tohex(n,2) .. 'h  #('..n..')',2
end

inst[0xde]=function(mem,pc)
  local n=mem:get(pc+1)
  return 'sbc a,' .. bit.tohex(n,2) .. 'h  #('..n..')',2
end

inst[0xe6]=function(mem,pc)
  local n=mem:get(pc+1)
  return 'and ' .. bit.tohex(n,2) .. 'h  #('..n..')',2
end

inst[0xf6]=function(mem,pc)
  local n=mem:get(pc+1)
  return 'or ' .. bit.tohex(n,2) .. 'h  #('..n..')',2
end

inst[0xee]=function(mem,pc)
  local n=mem:get(pc+1)
  return 'xor ' .. bit.tohex(n,2) .. 'h  #('..n..')',2
end

inst[0xfe]=function(mem,pc)
  local n=mem:get(pc+1)
  return 'cp ' .. bit.tohex(n,2) .. 'h  #('..n..')',2
end

inst[0x86]=function() return 'add a,(hl)',1 end
inst[0x96]=function() return 'sub (hl)',1 end
inst[0x8e]=function() return 'adc a,(hl)',1 end
inst[0x9e]=function() return 'sbc a,(hl)',1 end
inst[0xa6]=function() return 'and (hl)',1 end
inst[0xb6]=function() return 'or (hl)',1 end
inst[0xae]=function() return 'xor (hl)',1 end
inst[0xbe]=function() return 'cp (hl)',1 end
inst[0x34]=function() return 'inc (hl)',1 end
inst[0x35]=function() return 'dec (hl)',1 end

local function addrd(d)
	return function(mem,pc)
		local n=mem:gets(pc+2)
		n=n>=0 and '+'..n or n
		return 'add a,('..d..n..')',3
	end
end

ddInst[0x86]=addrd('ix')
fdInst[0x86]=addrd('iy')

local function adcrd(d)
	return function(mem,pc)
		local n=mem:gets(pc+2)
		n=n>=0 and '+'..n or n
		return 'adc a,('..d..n..')',3
	end
end

ddInst[0x8e]=adcrd('ix')
fdInst[0x8e]=adcrd('iy')


local function subrd(d)
	return function(mem,pc)
		local n=mem:gets(pc+2)
		n=n>=0 and '+'..n or n
		return 'sub ('..d..n..')',3
	end
end

ddInst[0x96]=subrd('ix')
fdInst[0x96]=subrd('iy')

local function sbcrd(d)
	return function(mem,pc)
		local n=mem:gets(pc+2)
		n=n>=0 and '+'..n or n
		return 'sbc a,('..d..n..')',3
	end
end

ddInst[0x9e]=sbcrd('ix')
fdInst[0x9e]=sbcrd('iy')

local function andrd(d)
	return function(mem,pc)
		local n=mem:gets(pc+2)
		n=n>=0 and '+'..n or n
		return 'and ('..d..n..')',3
	end
end

ddInst[0xa6]=andrd('ix')
fdInst[0xa6]=andrd('iy')

local function orrd(d)
	return function(mem,pc)
		local n=mem:gets(pc+2)
		n=n>=0 and '+'..n or n
		return 'or ('..d..n..')',3
	end
end

ddInst[0xb6]=orrd('ix')
fdInst[0xb6]=orrd('iy')

local function xorrd(d)
	return function(mem,pc)
		local n=mem:gets(pc+2)
		n=n>=0 and '+'..n or n
		return 'xor ('..d..n..')',3
	end
end

ddInst[0xae]=xorrd('ix')
fdInst[0xae]=xorrd('iy')

local function cprd(d)
	return function(mem,pc)
		local n=mem:gets(pc+2)
		n=n>=0 and '+'..n or n
		return 'cp ('..d..n..')',3
	end
end

ddInst[0xbe]=cprd('ix')
fdInst[0xbe]=cprd('iy')

local function incd(d)
	return function(mem,pc)
		local n=mem:gets(pc+2)
		n=n>=0 and '+'..n or n
		return 'inc ('..d..n..')',3
	end
end

ddInst[0x34]=incd('ix')
fdInst[0x34]=incd('iy')

local function decd(d)
	return function(mem,pc)
		local n=mem:gets(pc+2)
		n=n>=0 and '+'..n or n
		return 'dec ('..d..n..')',3
	end
end

ddInst[0x35]=decd('ix')
fdInst[0x35]=decd('iy')

-----------------------------------------------------
--General-Purpose Arithmetic and CPU Control Groups--
-----------------------------------------------------

inst[0x27]=function() return 'daa',1 end
inst[0x2f]=function() return 'cpl',1 end
edInst[0x44]=function() return 'neg',2 end
inst[0x3f]=function() return 'ccf',1 end
inst[0x37]=function() return 'scf',1 end
inst[0x0]=function() return 'nop',1 end
inst[0x76]=function() return 'halt',1 end
inst[0xf3]=function() return 'di',1 end
inst[0xfb]=function() return 'ei',1 end
edInst[0x46]=function() return 'im 0',2 end
edInst[0x56]=function() return 'im 1',2 end
edInst[0x5e]=function() return 'im 2',2 end

---------------------------
--16-Bit Arithmetic Group--
---------------------------

r16={[0]='bc','de','hl','sp'}

local function addhl16(o,o2,l)
	return function()
		return 'add '..o2..',' .. o,l
	end
end

local function adchl16(o)
	return function()
		return 'adc hl,' .. o,2
	end
end

local function sbchl16(o)
	return function()
		return 'sbc hl,' .. o,2
	end
end


local function inc16(o,l)
	return function()
		return 'inc ' .. o,l
	end
end


local function dec16(o,l)
	return function()
		return 'dec ' .. o,l
	end
end

for i,d in pairs(r16) do
	inst[i*0x10+9]=addhl16(d,'hl',1) 			-- add hl,rr
	edInst[i*0x10+0x4a]=adchl16(d)	-- adc hl,rr
	edInst[i*0x10+0x42]=sbchl16(d)	-- sbc hl,rr
	ddInst[i*0x10+9]=addhl16(d==2 and 'ix' or d,'ix',2)
	fdInst[i*0x10+9]=addhl16(d==2 and 'iy' or d,'iy',2)
	inst[i*16+3]=inc16(d,1)
	inst[i*16+0xb]=dec16(d,1)
end

ddInst[0x23]=inc16('ix',2)
fdInst[0x23]=inc16('iy',2)

ddInst[0x2b]=dec16('ix',2)
fdInst[0x2b]=dec16('iy',2)

--------------------------
--Rotate and Shift Group--
--------------------------

inst[0x7]=function() return 'rlca',1 end
inst[0x17]=function() return 'rla',1 end

inst[0xf]=function() return 'rrca',1 end
inst[0x1f]=function() return 'rra',1 end

local function rot(d,n)
	return function()
		return n ..d,2
	end
end

for i,d in pairs(r8) do
	cbInst[i]=rot(d,'rlc ')
	cbInst[i+0x10]=rot(d,'rl ')
	cbInst[i+0x8]=rot(d,'rrc ')
	cbInst[i+0x18]=rot(d,'rr ')
	cbInst[i+0x20]=rot(d,'sla ')
	cbInst[i+0x30]=rot(d,'sll ')
	cbInst[i+0x28]=rot(d,'sra ')
	cbInst[i+0x38]=rot(d,'srl ')
end

local function rotd(d,nn)
	return function(mem,pc)
		local n=mem:gets(pc+2)
		n=n>=0 and '+'..n or n
		return nn..'('..d..n..')',4
	end
end

ddcbInst[0x6]=rotd('ix','rlc ')
fdcbInst[0x6]=rotd('iy','rlc ')

ddcbInst[0x16]=rotd('ix','rl ')
fdcbInst[0x16]=rotd('iy','rl ')

ddcbInst[0x0e]=rotd('ix','rrc ')
fdcbInst[0x0e]=rotd('iy','rrc ')

ddcbInst[0x1e]=rotd('ix','rr ')
fdcbInst[0x1e]=rotd('iy','rr ')

ddcbInst[0x26]=rotd('ix','sla ')
fdcbInst[0x26]=rotd('iy','sla ')

ddcbInst[0x36]=rotd('ix','sll ')
fdcbInst[0x36]=rotd('iy','sll ')

ddcbInst[0x2e]=rotd('ix','sra ')
fdcbInst[0x2e]=rotd('iy','sra ')

ddcbInst[0x3e]=rotd('ix','srl ')
fdcbInst[0x3e]=rotd('iy','srl ')

cbInst[0x06]=function() return 'rlc (hl)',2 end
cbInst[0x16]=function() return 'rl (hl)',2 end
cbInst[0x0e]=function() return 'rrc (hl)',2 end
cbInst[0x1e]=function() return 'rr (hl)',2 end
cbInst[0x26]=function() return 'sla (hl)',2 end
cbInst[0x2e]=function() return 'sra (hl)',2 end
cbInst[0x3e]=function() return 'srl (hl)',2 end

edInst[0x6f]=function() return 'rld ',2 end
edInst[0x67]=function() return 'rrd ',2 end

----------------------------------
--Bit Set, Reset, and Test Group--
----------------------------------

local function bitr(b,r,n)
	return function()
		return n..b..','..r,2
	end
end

local function bitrd(b,d,nn)
	return function(mem,pc)
		local n=mem:gets(pc+2)
		n=n>=0 and '+'..n or n
		return nn..b..',('..d..n..')',4
	end
end

for b=0,7 do
	for i,d in pairs(r8) do
		cbInst[0x40+b*0x8+i]=bitr(b,d,'bit ')
		cbInst[0xc0+b*0x8+i]=bitr(b,d,'set ')
		cbInst[0x80+b*0x8+i]=bitr(b,d,'res ')
	end
	cbInst[0x40+b*0x8+6]=bitr(b,'(hl)','bit ')
	cbInst[0xc0+b*0x8+6]=bitr(b,'(hl)','set ')
	cbInst[0x80+b*0x8+6]=bitr(b,'(hl)','res ')

	ddcbInst[0x40+b*0x8+6]=bitrd(b,'ix','bit ')
	fdcbInst[0x40+b*0x8+6]=bitrd(b,'iy','bit ')

	ddcbInst[0xc0+b*0x8+6]=bitrd(b,'ix','set ')
	fdcbInst[0xc0+b*0x8+6]=bitrd(b,'iy','set ')

	ddcbInst[0x80+b*0x8+6]=bitrd(b,'ix','res ')
	fdcbInst[0x80+b*0x8+6]=bitrd(b,'iy','res ')
end
	
--------------
--Jump Group--
--------------

local function jump(nn)
	return function(mem,pc)
		local n=mem:get(pc+1)+mem:get(pc+2)*0x100
		return nn .. bit.tohex(n,4) .. 'h  #(' .. n .. ')',3
	end
end

inst[0xc3]=jump('jp ')

jf={[0]='nz','z','nc','c','po','pe','p','m'}

local function jumpcc(j,nn)
	return function(mem,pc)
		local n=mem:get(pc+1)+mem:get(pc+2)*0x100
		return nn..j..',' .. bit.tohex(n,4) .. 'h  #(' .. n .. ')',3
	end
end

for i,j in pairs(jf) do
	inst[i*8+0xc2]=jumpcc(j,'jp ')
end

inst[0x18]=function(mem,pc)
	local n=mem:gets(pc+1)
	--n=n>=0 and '+'..n or n
	n=pc+(n+2)
	return 'jr ' .. bit.tohex(n,4),2
end

inst[0x10]=function(mem,pc)
	local n=mem:gets(pc+1)
	--n=n>=0 and '+'..n or n
	n=pc+(n+2)
	return 'djnz ' .. bit.tohex(n,4),2
end

local function jrcc(j)
	return function(mem,pc)
		local n=mem:gets(pc+1)
		--n=n>=0 and '+'..n or n
		n=pc+(n+2)
		return 'jr '..j..','..bit.tohex(n,4),2
	end
end

for i=0,3 do
	inst[0x20+i*8]=jrcc(jf[i])
end

inst[0xe9]=function() return 'jp (hl)',1 end
ddInst[0xe9]=function() return 'jp (ix)',2 end
fdInst[0xe9]=function() return 'jp (iy)',2 end

-------------------------
--Call And Return Group--
-------------------------

inst[0xcd]=jump('call ')

local function retcc(j)
	return function(mem,pc)
		return 'ret '..j,1
	end
end

for i,j in pairs(jf) do
	inst[i*8+0xc4]=jumpcc(j,'call ')
	inst[i*8+0xc0]=retcc(j)
end

inst[0xc9]=function() return 'ret',1 end
edInst[0x4d]=function() return 'reti',2 end
edInst[0x45]=function() return 'retn',2 end

local function dis(mem,pc)
	local o=mem:get(pc)
	local f
	
	if o==0xdd then
		o=mem:get(pc+1)
		if o==0xcb then
			o=mem:get(pc+3)
			f=ddcbInst[o]
		else
			f=ddInst[o]
		end
	elseif o==0xfd then
		o=mem:get(pc+1)
		if o==0xcb then
			o=mem:get(pc+3)
			f=fdcbInst[o]
		else
			f=fdInst[o]
		end
	elseif o==0xed then
		o=mem:get(pc+1)
		f=edInst[o]
	elseif o==0xcb then
		o=mem:get(pc+1)
		f=cbInst[o]
	else
		f=inst[o]
	end

	local a,b
	if f then
		a,b=f(mem,pc)
		if b==0 then return nil end
		return a,b
	else
		return 'error',1
	end 
	--if f then return f(mem,pc) else return 'error',1 end
end

rstd={[0]=0x0,0x8,0x10,0x18,0x20,0x28,0x30,0x38}

for i,d in pairs(rstd) do
	inst[0xc7+i*8]=function()
		return 'rst '.. bit.tohex(d,2)..'h',1
	end
end

--------------------------
--Input and Output Group--
--------------------------

inst[0xdb]=function(mem,pc) 
	local n=mem:get(pc+1)
	return 'in a,('..bit.tohex(n,2)..'h)',2
end

inst[0xd3]=function(mem,pc) 
	local n=mem:get(pc+1)
	return 'out ('..bit.tohex(n,2)..'h),a',2
end

for i,d in pairs(r8) do
	edInst[0x40+i*8]=function() return 'in '..d..',(c)',2 end
	edInst[0x41+i*8]=function() return 'out (c),'..d,2 end
end

edInst[0xa2]=function() return 'ini',2 end
edInst[0xb2]=function() return 'inir',2 end
edInst[0xaa]=function() return 'ind',2 end
edInst[0xba]=function() return 'indr',2 end

edInst[0xa3]=function() return 'outi',2 end
edInst[0xb3]=function() return 'otir',2 end
edInst[0xab]=function() return 'outd',2 end
edInst[0xbb]=function() return 'otdr',2 end

-- if n==1 return line else table
function r.disassemble(mem,pc,n)
	--print(pc)

	if n==nil or n==1 then
		local i,n=dis(mem,pc)
		return pc,i,n
	else
		local ret,c={},pc
		for i=1,n do
			local i,n=dis(mem,pc)
			ret[#ret+1]={pc,i,n}
			pc=pc+n
		end

		--print(pc,c)
		return ret,(pc-c)
	end
end

function r.list(mem,pc,n)
	for i=1,n do
		local i,j=dis(mem,pc)
		
		o.lightSeaGreen(bit.tohex(pc,4))("  ")
		for ii=0,j-1 do
			o.pink(bit.tohex(mem:get((pc+ii)),2))(" ")
		end

		o(string.rep(" ",(4-j)*3))

		o.springGreen(i)("\n")
		pc=(pc+j)
	end
	o.white("\n")
end

local function disI(mem,pc)
	for i=1,4 do
		local s,j=dis(mem,pc-i)
		if i==j then return s,j end
	end

	return '????',1
end

--Disasembles -r 0 r instructions from pc, returns list and pc of first
function r.disassembleR(mem,pc,rr)
	local f,npc=r.disassemble(mem,pc,rr+1) --forward instructions...
	
	local re,pcc={},pc
	for i=1,rr do
		local s,j=disI(mem,pcc)
		re[#re+1]={(pcc-j),s,j}
		pcc=pcc-j
	end

	local ree={}
	for i=#re,1,-1 do ree[#ree+1]=re[i] end
	for k,v in pairs(f) do ree[#ree+1]=v end

	return ree,pcc
end

function r.listR(mem,pc,rr)
	t=r.disassembleR(mem,pc,rr)

	for k,v in pairs(t) do
		o.cyan("0x%04x",v[1])("  ").lime(v[2])("\n")
	end
end

return r