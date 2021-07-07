local bit=require('bit')

local ls,rs,band,bor,tohex=bit.lshift,bit.rshift,bit.band,bit.bor,bit.tohex

local _help={}

local function compact(s,t)
	local l,c={},0
	for y=0,s.lines-1 do
		local tt={}
		for x=1,s.llen do
			tt[x]='0x'..tohex(t[c])
			c=c+1
		end
		l[#l+1]=("%s, //(%d %d)"):format(table.concat(tt,','),y,y*s.llen)
	end

	return table.concat(l,'\n')
end

function _help.doReadTable(s)
	local t={}

	local tmax=s.lines*s.llen

	for i=0,tmax-1 do t[i]=0 end --clear the table

	local ii=s.first-32-(s.upborder*s.llen) --first border
	if ii<0 then ii=tmax+ii end
	--first the border
	local cc=0
	for y=0,287 do --each line
		for x=0,s.llen-1,4 do
			if x<192 then
				t[ii]=0xFFFFFFFF --read border
				--print(ii)
				cc=cc+1
				
			end
			ii=math.mod(ii+4,tmax)
		end
	end
	--print('cc',cc)

	ii=s.first

	for y=0,191 do
		for x=0,s.llen-1,4 do
			if x<128 then
				--tLine[(i<<6)+(j<<3)+k]=(i<<11)+(j<<5)+(k<<8);
				--0x1800+((y>>3)<<5)+x;
				local i,j,k=rs(y,6),band(rs(y,3),0x7),band(y,0x7)
				local p=ls(i,11)+ls(j,5)+ls(k,8)+rs(x,2)
				local b=0x1800+ls(rs(y,3),5)+rs(x,2)
				t[ii]=bor(ls(b,16),p)
				
			end
			ii=math.mod(ii+4,tmax)
		end
	end

	return compact(s,t)
end

function _help.doWriteTable(s)
	local t={}

	local tmax=s.lines*s.llen

	for i=0,tmax-1 do t[i]=0xFFFFFFFF end --clear the table

	local ii=s.first-32-(s.upborder*s.llen)+4 --first border
	if ii<0 then ii=tmax+ii end

	--first the border
	local c=0;
	for y=0,287 do --each line
		for x=0,s.llen-1 do
			if x<192 then
				--local d=ls(y*s.llen+x,1) --write border
				t[ii]=c
				c=c+2
				--print(ii)
				
			end
			ii=math.mod(ii+1,tmax)
		end
	end
	
	return compact(s,t)
end

return _help