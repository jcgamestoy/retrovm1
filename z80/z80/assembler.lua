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

local h=require('h')
local parser=require('z80.assemblerParser')
local util=require('h.text.util')
local errors=require('z80.assemblerErrors')
local nm,inst,last={},{}

--misc

local function error(code,...)
  --print(code,errors[code],debug.traceback())
  --print(nil,util.format('Error in line %d: %s\n',parser.line(),util.format(errors[code],...)))
  return nil,util.format('Error in line %d: %s\n',parser.line(),util.format(errors[code],...))
end

local function writePrefix(o,mem,pc)
  --print('prefix',o.type,o.value)
  local reg
  if o.type=='regi' then 
    reg=o.reg
  elseif
    o.type=='reg16' then
    reg=o.value
  elseif o.type=='reg' then
    reg=o.value
  else
    return pc
  end

  if h.eqAny(reg,'ix','ixh','ixl') then mem:set(pc,0xdd) elseif h.eqAny(reg,'iy','iyh','iyl') then mem:set(pc,0xfd) else return pc end
  return pc+1
end

local function parseE16(e,mem,pc)
  local v=parser.eval(e)

  if v then 
    mem:set16(pc,v)
  else
    parser.setUnresolved16(e,pc)
  end
  return pc+2
end

local function parseE(e,mem,pc,desp)
  --print(e,mem,pc)
  local v=parser.eval(e)

  if v then 
    if desp then v=(v-pc+1)+desp end
    mem:set(pc,v)
  else
    if desp then
      --print(e,pc,desp)
      parser.setUnresolvedD(e,pc,desp)
    else
      parser.setUnresolved(e,pc)
    end
  end

  return pc+1
end

local function runEmitI(t,mem,pc)
  --print(t,mem,pc)
  if type(t)~='table' then t={t} end
  if #t==0 then return error(-1) end
  
  for k,v in pairs(t) do
    --print(mem,pc,k,v)
    mem:set(pc,v)
    pc=pc+1
  end

  return pc
end

local function emitI(...)
  local t={...}
  
  if type(t[1])=='table' then t=t[1] end

  return function(text,pos,mem,pc)
    pc=runEmitI(t,mem,pc)
    return pc,pos
  end
end

local function runEmit1(op,t,name,mem,pc,otype)
  local err

  if t==nil then return error(-1) end

  if h.eqAny(op.type,'reg','reg16','reg16i','flag') then
    --print(op.type,op.value,t[op.value])
    pc=writePrefix(op,mem,pc)
    pc,err=runEmitI(t[op.value],mem,pc)
    return pc,err
  elseif op.type=='regi' then
    pc=writePrefix(op,mem,pc)
    local opc=t[op.type]
    --if opc== nil then return error(-1) end

    if type(opc)=='table' and opc[1]==0xcb then
      mem:set(pc,0xcb)
      pc=parseE(op.des,mem,pc+1)
      pc,err=runEmitI(opc[2],mem,pc)
      if not pc then return nil,err end
    else
      pc,err=runEmitI(t[op.type],mem,pc)
      
      if not pc then return nil,err end
      
      pc=parseE(op.des,mem,pc)
    end

    return pc
  elseif h.eqAny(op.type,'exp','expi') then
    if (op.type=='expi' and otype~=1) or otype==1 then
      pc,err=runEmitI(t[op.type],mem,pc)
      if not pc then return nil,err end
      if op.type=='expi' then op=op.value end
      pc=parseE16(op.value,mem,pc)
      return pc
    elseif otype==2 then
      pc,err=runEmitI(t[op.type],mem,pc)
      if not pc then return nil,err end
      pc=parseE(op.value,mem,pc,-2)
      return pc
    elseif otype==3 then
      local v=parser.eval(op.value)
      if not v then return error(5,op.value) end
      -- *Todo: El error debe ser 'invalid value'
      if (v % 8)~=0 or v<0 or v>0x38 then return error(-1) end
      
      pc,err=runEmitI(t[op.type]+v,mem,pc)
      return pc,pos
    else
      pc,err=runEmitI(t[op.type],mem,pc)
      if not pc then return nil,err end
      pc=parseE(op.value,mem,pc)
      return pc
    end
  else
    return error(-1)
  end
end

local function emit01(t,name)
  return function(text,pos,mem,pc)
    local ops,pc2=parser.parse(text,pos)

    --print(ops)
    if ops and ops.value[1].type=='flag' then
      --print(ops.value[1],ops.value[1].value,ops.value[1].type)
      pc,err=runEmit1(ops.value[1],t,name,mem,pc,otype)
      if not pc then return nil,err else return pc,pc2 end
    else
      pc,err=runEmitI(t['_'],mem,pc)
      if not pc then return nil,err else return pc,pos end
    end
  end
end

local function emit1(t,name,otype)
  return function(text,pos,mem,pc)
    local ops,pos,err=parser.parse(text,pos)

    if ops.type~='eList' or #ops.value~=1 then
      return error(2,name,ops.str)
    else
      pc,err=runEmit1(ops.value[1],t,name,mem,pc,otype)
      if not pc then return nil,err else return pc,pos end
    end
  end
end

local function runEmit2(ops,t,name,mem,pc,otype)
  local err
 
  local o1,o2=ops.value[1],ops.value[2]
  --print(o1.value,o2.value)
  if h.eqAny(o1.type,'reg','reg16','reg16i','flag') then
    local tt=t[o1.value]

    if not h.eqAny(o1.value,'ix','iy','ixl','ixh','iyh','iyl') or not h.eqAny(o2.value,'ix','iy','ixl','ixh','iyh','iyl') then
      --print('prefix',tt)
      --for k,v in pairs(tt) do print(k,v) end
      pc=writePrefix(o1,mem,pc)
    end
    if not otype then
      otype=(o1.type=='reg16' and 1 or nil)
    end

    pc,err=runEmit1(o2,tt,name,mem,pc,otype)
    if not pc then return nil,err else return pc end
  elseif o1.type=='regi' then
    local tt=t['regi']
    pc=writePrefix(o1,mem,pc)
    
    pc,err=runEmit1(o2,tt,name,mem,pc,otype)
    if not pc then return nil,err end
    if h.eqAny(o2.type,'exp','expi') then
      if o2.type=='expi' or o1.type=='reg16' then
        mem:set(pc,mem:get(pc-2))
        mem:set(pc+1,mem:get(pc-1))
        parseE16(o1.des,mem,pc-2)
        return pc+2
      else
        mem:set(pc,mem:get(pc-1))
        parseE(o1.des,mem,pc-1)
        return pc+1
      end
    else
      parseE(o1.des,mem,pc)
      return pc+1
    end

    return pc
  elseif o1.type=='expi' then
    local tt=t['expi']
    pc,err=runEmit1(o2,tt,name,mem,pc,otype)
    if not pc then return nil,err end
    if otype==1 then
      pc=parseE(o1.value.value,mem,pc)
    else
      pc=parseE16(o1.value.value,mem,pc)
    end
    return pc
  elseif o1.type=='exp' then
    --print('entro')
    local v=parser.eval(o1.value)

    if v then
      local tt=t[v]
      pc,err=runEmit1(o2,tt,name,mem,pc,otype)
      if not pc then return nil,err end
      return pc
    else
      return error(5,o1.value)
    end
  else
    return error(-1)
  end
end

local function emit2(t,name)
  return function(text,pos,mem,pc)
    local ops,pos,err=parser.parse(text,pos)

    if ops.type~='eList' or #ops.value~=2 then
      return error(2,name,ops.str)
    else
      -- print('elist')
      -- for k,v in pairs(ops.value) do
      --   if type(v.value)=='string' then print(v.type..'-'..v.value) end
      -- end
      pc,err=runEmit2(ops,t,name,mem,pc)
      if not pc then return nil,err else return pc,pos end
    end
  end
end

local function emit21(t,name,otype)
  return function(text,pos,mem,pc)
    local ops,pos,err=parser.parse(text,pos)

    --print(ops,pos,err)
    if ops.type~='eList' or #ops.value<1 or #ops.value>2 then
      return error(2,name,ops.str)
    else
      if #ops.value==1 then
        --print(ops.value[1].value,ops.value[1].type)
        local o,tt=ops.value[1],t
        if ops.value=='a' then 
          o,tt=ops.value[2],t['a']
        end
        --table.insert(ops.value,1,{type='reg',value='a'})
        pc,err=runEmit1(o,tt,name,mem,pc,otype)
      else
        --print(2)
        pc,err=runEmit2(ops,t,name,mem,pc,otype)  
      end

      
      if not pc then return nil,err else return pc,pos end
    end
  end
end

--inst
inst.equ=function(text,pos,mem,pc)
  local e
  e,pos=parser.parse(text,pos)
  if e.type~='eList' then
    return error(3,'expression list',e.type,e.value)
  elseif #e.value~=1 then 
    return error(4,'equ',e.str)
  else
    e=parser.eval(e.value[1].value)

    if last then
      parser.set(last,e)
      last=nil
    end

    return pc,pos
  end
end

inst.byte=function(text,pos,mem,pc)
  local e
  e,pos=parser.parse(text,pos)

  if e.type~='eList' then
    return error(3,'expression list',e.type,e.value)
  else
    for k,v in pairs(e.value) do
      if v.type~='exp' then
        return error(3,'expression',e.type,e.value)
      else
        pc=parseE(v.value,mem,pc)
      end
    end

    return pc,pos
  end
end

inst.word=function(text,pos,mem,pc)
  local e
  e,pos=parser.parse(text,pos)

  if e.type~='eList' then
    return error(3,'expression list',e.type,e.value)
  else
    for k,v in pairs(e.value) do
      if v.type~='exp' then
        return error(3,'expression',e.type,e.value)
      else
        pc=parseE16(v.value,mem,pc)
      end
    end

    return pc,pos
  end
end

inst.org=function(text,pos,mem,pc)
  local e
  e,pos=parser.parse(text,pos)

  if e.type~='eList' or #e.value~=1 then
    return error(3,'expression list',e.type,e.value)
  else
    local v=parser.eval(e.value[1].value)

    if v then
      return v % 0x10000,pos
    else
      return error(5,e.str)
    end
  end
end

--nm
--ld

--tables
local ld={regi={}}
local r={[0]='b','c','d','e','h','l','(hl)','a'}
local r8ix={b='b',c='c',d='d',e='e',h='ixh',l='ixl',a='a'}
local r8iy={b='b',c='c',d='d',e='e',h='iyh',l='iyl',a='a'}
local rr={[0]='bc','de','hl','sp'}


for i,v in pairs(r) do
  ld[v]={}
  if h.eqAny(v,'h','l') then
    ld[r8ix[v]]={}
    ld[r8iy[v]]={}
  end

  for ii,vv in pairs(r) do
    ld[v][vv]=0x40+i*0x8+ii
    if h.eqAny(v,'h','l') or h.eqAny(vv,'h','l') then
      if v~='(hl)' and  vv~='(hl)' then
        ld[r8ix[v]][r8ix[vv]]=0x40+i*0x8+ii
        ld[r8iy[v]][r8iy[vv]]=0x40+i*0x8+ii
      end
    end
  end
  ld[v]['exp']=i*8+6
  ld[v]['regi']=64+i*8+6
  ld['regi'][v]=0x70+i

  if h.eqAny(v,'h','l') then
    ld[r8ix[v]]['exp']=i*8+6
    ld[r8iy[v]]['exp']=i*8+6
  end
end

ld['(bc)']={}
ld['(de)']={}
ld['i'],ld['r'],ld['expi']={},{},{}
ld['a']['(bc)']=0x0a
ld['a']['(de)']=0x1a
ld['(bc)']['a']=0x02
ld['(de)']['a']=0x12
ld['regi']['exp']=0x36 
ld['a']['i']={0xed,0x57}
ld['a']['r']={0xed,0x5f}
ld['i']['a']={0xed,0x47}
ld['r']['a']={0xed,0x4f}

for i,v in pairs(rr) do
  ld[v]={}
  ld[v]['exp']=i*16+1
  ld[v]['expi']={0xed,64+i*16+11}
  ld['expi'][v]={0xed,64+i*16+3}
end

ld['ix']={}
ld['ix']['exp']=ld['hl']['exp']
ld['iy']={}
ld['iy']['exp']=ld['hl']['exp']

ld['hl']['expi']=0x2a
ld['ix']['expi']=0x2a
ld['iy']['expi']=0x2a

ld['expi']['hl']=0x22
ld['expi']['ix']=0x22
ld['expi']['iy']=0x22

ld['expi']['a']=0x32
ld['a']['expi']=0x3a

-- push / pop
local push,pop={},{}
local pushr={[0]='bc','de','hl','af'}

for k,v in pairs(pushr) do
  push[v]=0xc5+k*0x10
  pop[v]=0xc1+k*0x10
end

push['ix']=push['hl']
push['iy']=push['hl']
pop['ix']=pop['hl']
pop['iy']=pop['hl']

--ex
local ex={de={},af={},['(sp)']={}}
ex['de']['hl']=0xeb
ex['af']["af'"]=0x08
ex['(sp)']['hl']=0xe3
ex['(sp)']['ix']=0xe3
ex['(sp)']['iy']=0xe3

local add,adc,sub,sbc,andi,ori,xor,cp,inc,dec,rlc,rl,rrc,rri,sla,sll,sra,srl={a={},hl={},ix={},iy={}},{a={},hl={}},{a={}},{a={},hl={}},{a={}},{a={}},{a={}},{a={}},{a={}},{a={}},{a={}},{a={}},{a={}},{a={}},{a={}},{a={}},{a={}},{a={}}
local bit,set,res,ini,out={},{},{},{},{}

for k,v in pairs(r) do
  add['a'][v]=0x80+k
  
  adc['a'][v]=0x88+k
  
  sub['a'][v]=0x90+k
  sbc['a'][v]=0x98+k
  andi['a'][v]=0xa0+k
  ori['a'][v]=0xb0+k
  xor['a'][v]=0xa8+k
  cp['a'][v]=0xb8+k
  inc[v]=k*8+4
  dec[v]=k*8+5
  rlc[v]={0xcb,k}
  rl[v]={0xcb,0x10+k}
  rrc[v]={0xcb,0x8+k}
  rri[v]={0xcb,0x18+k}
  sla[v]={0xcb,0x20+k}
  sll[v]={0xcb,0x30+k}
  sra[v]={0xcb,0x28+k}
  srl[v]={0xcb,0x38+k}

  if h.eqAny(v,'h','l') then
    add['a'][r8ix[v]]=0x80+k
    add['a'][r8iy[v]]=0x80+k

    adc['a'][r8ix[v]]=0x88+k
    adc['a'][r8iy[v]]=0x88+k

    sub['a'][r8ix[v]]=0x90+k
    sub['a'][r8iy[v]]=0x90+k

    sbc['a'][r8ix[v]]=0x98+k
    sbc['a'][r8iy[v]]=0x98+k

    andi['a'][r8ix[v]]=0xa0+k
    andi['a'][r8iy[v]]=0xa0+k

    ori['a'][r8ix[v]]=0xb0+k
    ori['a'][r8iy[v]]=0xb0+k

    xor['a'][r8ix[v]]=0xa8+k
    xor['a'][r8iy[v]]=0xa8+k

    cp['a'][r8ix[v]]=0xb8+k
    cp['a'][r8iy[v]]=0xb8+k

    inc[r8ix[v]]=0x4+k*8
    inc[r8iy[v]]=0x4+k*8

    dec[r8ix[v]]=0x5+k*8
    dec[r8iy[v]]=0x5+k*8
  end

  for i=0,7 do 
    if not bit[i] then bit[i],set[i],res[i]={},{},{} end
    bit[i][v]={0xcb,0x40+i*0x8+k}
    set[i][v]={0xcb,0xc0+i*0x8+k}
    res[i][v]={0xcb,0x80+i*0x8+k}
    if v=='(hl)' then
      bit[i]['regi']=bit[i]['(hl)']
      set[i]['regi']=set[i]['(hl)']
      res[i]['regi']=res[i]['(hl)']
    end
  end

  if v~='a' then
    add[v]=add['a'][v]
    adc[v]=adc['a'][v]
    sub[v]=sub['a'][v]
    sbc[v]=sbc['a'][v]
    andi[v]=andi['a'][v]
    ori[v]=ori['a'][v]
    xor[v]=xor['a'][v]
    cp[v]=cp['a'][v]

    if h.eqAny(v,'h','l') then
      add[r8ix[v]]=add['a'][r8ix[v]]
      adc[r8ix[v]]=adc['a'][r8ix[v]]
      sub[r8ix[v]]=sub['a'][r8ix[v]]
      sbc[r8ix[v]]=sbc['a'][r8ix[v]]
      andi[r8ix[v]]=andi['a'][r8ix[v]]
      ori[r8ix[v]]=ori['a'][r8ix[v]]
      xor[r8ix[v]]=xor['a'][r8ix[v]]
      cp[r8ix[v]]=cp['a'][r8ix[v]]

      add[r8iy[v]]=add['a'][r8iy[v]]
      adc[r8iy[v]]=adc['a'][r8iy[v]]
      sub[r8iy[v]]=sub['a'][r8iy[v]]
      sbc[r8iy[v]]=sbc['a'][r8iy[v]]
      andi[r8iy[v]]=andi['a'][r8iy[v]]
      ori[r8iy[v]]=ori['a'][r8iy[v]]
      xor[r8iy[v]]=xor['a'][r8iy[v]]
      cp[r8iy[v]]=cp['a'][r8iy[v]]
    end
  end

  if v=='(hl)' then
    ini['f']={}
    ini['f']['(c)']={0xed,0x40+k*0x8}
  else
    ini[v],out['(c)']={},{}
    ini[v]['(c)']={0xed,0x40+k*0x8}
    out['(c)'][v]={0xed,0x41+k*0x8}
  end
end

add['exp']=0xc6
adc['exp']=0xce
sub['exp']=0xd6
sbc['exp']=0xde
andi['exp']=0xe6
ori['exp']=0xf6
xor['exp']=0xee
cp['exp']=0xfe

local tables={add,adc,sub,sbc,andi,ori,xor,cp,inc,dec,rlc,rl,rrc,rri,sla,sll,sra,srl}
local t21={add,adc,sub,sbc,andi,ori,xor,cp}

for k,v in pairs(tables) do
  v['regi']=v['(hl)']
end

for k,v in pairs(t21) do
  v['a']['regi']=v['regi']
  v['a']['exp']=v['exp']
end

for k,v in pairs(rr) do
  add['hl'][v]=k*0x10+0x9
  add['ix'][v]=k*0x10+0x9
  add['iy'][v]=k*0x10+0x9
  adc['hl'][v]={0xed,k*0x10+0x4a}
  sbc['hl'][v]={0xed,k*0x10+0x42}
  inc[v]=k*0x10+0x3
  dec[v]=k*0x10+0xb
end

inc['ix']=inc['hl']
inc['iy']=inc['hl']
dec['ix']=dec['hl']
dec['iy']=dec['hl']

add['ix']['ix']=add['ix']['hl']
add['ix']['hl']=nil
add['iy']['iy']=add['iy']['hl']
add['iy']['hl']=nil

local ff={[0]='nz','z','nc','c','po','pe','p','m'}

local jp,jr,djnz,call,ret={},{},{},{},{}

for k,v in pairs(ff) do
  jp[v]={exp=0xc2+k*0x8}
  call[v]={exp=0xc4+k*0x8}
  ret[v]=0xc0+k*0x8
  if k<4 then
    jr[v]={exp=0x20+k*0x8}
  end
end

-- for k,v in pairs(ret) do
--   print(k,v)
-- end

jp['exp']=0xc3
jp['(hl)']=0xe9
jp['(ix)']=0xe9
jp['(iy)']=0xe9
jp['hl']=0xe9
jp['ix']=0xe9
jp['iy']=0xe9

jr['exp']=0x18

djnz['exp']=0x10

call['exp']=0xcd
ret['_']=0xc9
local rst={exp=0xc7}

ini['a']={expi=0xdb}
out['expi']={a=0xd3}

nm.ld=emit2(ld,'ld')
nm.push=emit1(push,'push')
nm.pop=emit1(pop,'pop')
nm.ex=emit2(ex,'ex')
nm.exx=emitI(0xd9)
nm.ldi=emitI(0xed,0xa0)
nm.ldir=emitI(0xed,0xb0)
nm.ldd=emitI(0xed,0xa8)
nm.lddr=emitI(0xed,0xb8)
nm.cpi=emitI(0xed,0xa1)
nm.cpir=emitI(0xed,0xb1)
nm.cpd=emitI(0xed,0xa9)
nm.cpdr=emitI(0xed,0xb9)

nm.add=emit21(add,'add')
nm.adc=emit21(adc,'adc')
nm.sub=emit21(sub,'sub')
nm.sbc=emit21(sbc,'sbc')
nm['and']=emit21(andi,'and')
nm['or']=emit21(ori,'ori')
nm.xor=emit21(xor,'xor')
nm.cp=emit21(cp,'cp')
nm.inc=emit1(inc,'inc')
nm.dec=emit1(dec,'dec')

nm.daa=emitI(0x27)
nm.cpl=emitI(0x2f)
nm.neg=emitI(0xed,0x44)
nm.ccf=emitI(0x3f)
nm.scf=emitI(0x37)
nm.nop=emitI(0x00)
nm.halt=emitI(0x76)
nm.di=emitI(0xf3)
nm.ei=emitI(0xfb)
nm['im 0']=emitI(0xed,0x46)
nm['im 1']=emitI(0xed,0x56)
nm['im 2']=emitI(0xed,0x5e)

nm.rlca=emitI(0x7)
nm.rla=emitI(0x17)
nm.rrca=emitI(0xf)
nm.rra=emitI(0x1f)
nm.rlc=emit1(rlc,'rlc')
nm.rl=emit1(rl,'rl')
nm.rrc=emit1(rrc,'rrc')
nm.rr=emit1(rri,'rr')
nm.sla=emit1(sla,'sla')
nm.sll=emit1(sll,'sll')
nm.sra=emit1(sra,'sra')
nm.srl=emit1(srl,'srl')

nm.rld=emitI(0xed,0x6f)
nm.rrd=emitI(0xed,0x67)

nm.bit=emit2(bit,'bit')
nm.set=emit2(set,'set')
nm.res=emit2(res,'res')
nm.jp=emit21(jp,'jp',1)
nm.jr=emit21(jr,'jr',2)
nm.djnz=emit1(djnz,'djnz',2)
nm.call=emit21(call,'call',1)
nm.ret=emit01(ret,'ret')
nm.reti=emitI(0xed,0x4d)
nm.retn=emitI(0xed,0x45)
nm.rst=emit1(rst,'rst',3)

nm['in']=emit2(ini,'in',1)

nm.ini=emitI(0xed,0xa2)
nm.inir=emitI(0xed,0xb2)
nm.ind=emitI(0xed,0xaa)
nm.indr=emitI(0xed,0xba)

nm.out=emit2(out,'out',1)

nm.outi=emitI(0xed,0xa3)
nm.otir=emitI(0xed,0xb3)
nm.outd=emitI(0xed,0xab)
nm.otdr=emitI(0xed,0xbb)

local function assembler(text,mem)
  local pc,pos,tok=0,1
  parser.reset()

  while true do
    --print(text,pos)
    tok,pos=parser.parse(text,pos)
    --if tok then print(tok.type,pos) end
    if not tok then break end

    --print(tok.type,tok.value)
    if tok.type=='nm' then
      --print(tok.value)
      if last then parser.set(last,pc) last=nil end
      pc,pos=nm[tok.value](text,pos,mem,pc)
    elseif tok.type=='inst' then
      --print(tok.value)
      local pc2=pc
      pc,pos=inst[tok.value](text,pos,mem,pc)
      if pc2<pc and last then parser.set(last,pc2) last=nil end
    elseif tok.type=='label' then
      last=tok.value
    else
      return error(-1)
    end

    if pc==nil then return nil,pos end
  end

  parser.resolve(mem)

  return true
end

return {
  assemble=assembler
}