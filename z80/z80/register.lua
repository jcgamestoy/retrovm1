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

local ffi=require("ffi")
--local C=require("h.lib.c")

--[==[
id={
	bc=0,
	de=1,
	hl=2,
	af=3,
	pc=4,
	sp=5,
	ix=6,
	iy=7,
	ir=8,
	bcp=9,
	dep=10,
	hlp=11,
	afp=12,
	tm=13
}

is={
	c=0,
	b=1,
	e=2,
	d=3,
	l=4,
	h=5,
	f=6,
	a=7,
	pcl=8,
	pch=9,
	spl=10,
	sph=11,
	ixl=12,
	ixh=13,
	iyl=14,
	iyh=15,
	r=16,
	i=17,
	cp=18,
	bp=19,
	ep=20,
	dp=21,
	lp=22,
	hp=23,
	fp=24,
	ap=25,
	tm1=26,
	tm2=27
}

local function new()
	rd=ffi.new("uint16_t[?]",14)
	rs=ffi.cast("uint8_t*",rd)

	r={}

	mt={
		__index=function(t,k)
			if id[k] then return rd[id[k]] else return rs[is[k]] end
		end,

		__newindex=function(t,k,v)

			if id[k] then
				rd[id[k]]=v
			else
				rs[is[k]]=v
			end
		end
	}

	setmetatable(r,mt)

	return r
end
---]==]
---[[
ffi.cdef([=[
	typedef union 
	{
		struct
		{
			uint16_t bc,de,hl,af,sp,ix,iy,pc,ir,bcp,dep,hlp,afp,tm,iffw,imodew;
		};

		struct
		{
			uint8_t c,b,e,d,l,h,f,a,spl,sph,ixl,ixh,iyl,iyh,pcl,pch,r,i,cp,bp,ep,dp,lp,hp,fp,ap,tm1,tm2,iff,iff2,iMode,nul;
		};
	} regs;
]=])
--]]
local r={
	
}

function r.new()
	return ffi.new("regs")
end

return r