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

local h=require("h")
require("h.string")
local re=require("h.text.re")
local util=require("h.text.util")

--defs
local line=1
local symbols,unresolved={},{}

local function capt(type)
  return function(s)
    return {type=type,value=s,str=s}
  end
end
--opers <- (oper space* ',' space* oper) -> opers
local g=[[
  tok <- space* (label / inst / nm / eList / unknow ) {}
  nm <- ('ld'(('i''r'?)/('d''r'?))? / 'push' / 'pop' / 'ex''x'? / 'cp'(('i''r'?)/('d''r'?)/'l'?)? / 'ad'[cd] / 'sub' / 'sbc' / 'and' / 'or' / 'xor' / 'in'('c' / 'i''r'? / 'd''r'?)? / 'dec' / 'daa' / 'neg' / 'ccf' / 'scf' / 'nop' / 'halt' / 'di' / 'ei' / 'im '[012] / 'rlca' / 'rl'[ad] / 'rr'('ca' / 'a' / 'c' / 'd')? / 'rl''c'? / 'sl'[al] / 'sr'[al] / 'bit' / 'set' / 'res' / 'jp' / 'jr' / 'djnz' / 'call' / 'ret'[in]? / 'rst' / 'out'[id]? / 'ot'('ir' / 'dr')) -> nm
   
  inst <- ('org' / 'equ' / 'byte' / 'word') ->inst
  oper <- (reg /  reg16 / flag / reg16i / regi / expi / E ) ->oper
  
  space <- %s -> ln
  eList <- ({oper (space* ',' space* oper)*}) -> eList
  id <- ([a-zA-Z]([a-zA-Z0-9_]*))
  label <- (({id} ':') / ('.' {id})) -> label

  unknow <- [^%s] -> unknow

  number <-  numH / numB / numD
  numD <- ([+-]?([0-9])+)
  numH <- ('&' / '0x') (([0-9a-fA-f])+)
  numB <- ('%' / '0b') ([01]+)

  reg <- (('a' / 'b' / 'c' / 'd' / 'e' / 'h' / 'l' / 'r' / 'ixl' / 'ixh' / 'iyl' / 'iyh' / 'i' / 'f' ) & %W) -> reg
  reg16 <- (('hl' / 'bc' / 'de' / 'af'"'"? / 'sp' / 'ix' / 'iy' ) & %W) -> reg16
  reg16i <- ('(' space* ('hl' / 'bc' / 'de' / 'sp' / 'ix' / 'iy' / 'c') space* ')') -> reg16i
  regi <- ({'(' space* {('ix' / 'iy')} space* {E} space* ')'}) -> regi
  flag <- (('n'?[cz] / 'p'[oe]? / 'm' ) & %W) -> flag

  expi <- ('(' space* E  space* ')') -> expi

  E <- (T (space* To space* T)*) -> E
  T <- (F (space* Fo space* F)*) 
  F <- ([+-]? (number / id / ('[' space* E space* ']'))) 
  To <- [+-]
  Fo <- [/*] 
]]

local gc=re.compile(g,{
  ln=function(s)
    --print('x:',s:byte(),s=='\n')
    if s=='\n' then line=line+1 end
    --print('line',line)
  end,
  nm=capt('nm'),
  inst=capt('inst'),
  label=function(id)
    symbols[id]=0
    return {type='label',value=id,str=s}
  end,
  E=function(s)
  --print(s)
    return {type='exp',value=s,str=s}
  end,

  reg=capt('reg'),
  reg16=capt('reg16'),
  reg16i=capt('reg16i'),
  flag=capt('flag'),
  regi=function(v,r,d)
    --print(v,r,d)
    return {type='regi',value=v,reg=r,des=d,str=v}
  end,
  expi=function(e)
    return {type='expi',value=e,str='('..e.value..')'}
  end,

  oper=function(o)
    return o --{type='oper',value=o}
  end,

  --[[opers=function(o1,o2,o3,o4)
  --print(o1.value.value,o2.value.value,o3,o4)
    return {type='opers',value={o1.value,o2.value}}
  end,]]
  eList=function(...)
    --[[for k,v in pairs({...}) do 
      print(k,type(v),v)
      if type(v)=='table' then print(v.type,v.value) end
    end]]
    local t={...}
    return {type='eList',str=table.remove(t,1),value=t}
  end,

  unknow=capt('unknow'),
})


local gE=[[
  E <- (T (space* To space* T)*) -> E

  space <- %s

  id <- ({[a-zA-Z]([a-zA-Z0-9_]*)})=>id

  number <- numH / numB / numD
  numD <- ([+-]?([0-9])+) -> numD
  numH <- ('&' / '0x') (([0-9a-fA-f])+) ->numH
  numB <- ('%' / '0b') ([01]+) -> numB

  T <- (F (space* Fo space* F)*) -> T
  F <- ({[+-]?} (number / id / ('[' space* E space* ']'))) -> F
  To <- {[+-]}
  Fo <- {[/*]} 
]]

local gcE=re.compile(gE,{
  id=function(s,pos,c)
    --print('id',s,pos,c)
    local v=symbols[c]
    if v==nil then return nil end
    return pos,v --{type='iden',value=v}
  end,

  numD=function(s)
    return tonumber(s) --{type='number',value=tonumber(s)}
  end,
  numH=function(s)
    return tonumber(s,16) --{type='number',value=tonumber(s,16)}
  end,
  numB=function(s)
    return tonumber(s,2) --{type='number',value=tonumber(s,2)}
  end,
  E=function(...)
    local t={...}

    local op1=t[1]
    for i=2,#t,2 do
      local op2=t[i+1]
      if t[i]=='+' then op1=op1+op2
      else op1=op1-op2 end
    end

    return op1 --{type='exp',value=op1}
  end,

  T=function(...)
    local t={...}

    local op1=t[1]
    for i=2,#t,2 do
      local op2=t[i+1]
      if t[i]=='*' then op1=op1*op2
      else op1=op1/op2 end
    end

    return op1 --{type='exp',value=op1}
  end,

  F=function(ss,c)
    --print(ss,c)
    if ss=='-' then c=-c end
    return c
  end,
})

local function setUnresolved(e,pc)
  unresolved[pc]={type=8,v=e}
end

local function setUnresolved16(e,pc)
  unresolved[pc]={type=16,v=e}
end

local function setUnresolvedD(e,pc,desp)
  unresolved[pc]={type=0,v=e,d=desp}
end

local function resolve(mem)
  --
  for k,v in pairs(unresolved) do
    --for kk,vv in pairs(v) do print(kk,vv) end
    --print(v.type,v.v,value)
    local value=gcE:match(v.v)

    if v.type==8 then
      mem:set(k,value)
    elseif v.type==16 then
      mem:set16(k,value)
    else
      --print(value,k,v.d)
      value=(value-k+1)+v.d
      --if value>127 or value<-128 then error("branch out of range") end
      mem:set(k,value)
    end
  end
end

local function parse(text,pos)
  return gc:match(text,pos)
end

local function evalu(text)
  return gcE:match(text)
end

local function set(key,value)
  ---print(key,value)
  symbols[key]=value
end

local function checkTypeValue(text,pos,type,value)
  local tok
  tok,pos=gc:match(text,pos)
  if tok.type==type and tok.value==value then return true,pos else return false,pos end
end

local function getLine()
  return line
end

local function reset()
  line=1
  symbols,unresolved={},{}
end

-- *Todo: Resolve debe devolver errores.
return {
  parse=parse,
  eval=evalu,
  set=set,
  checkTypeValue=checkTypeValue,
  resolve=resolve,
  setUnresolved=setUnresolved,
  setUnresolved16=setUnresolved16,
  setUnresolvedD=setUnresolvedD,
  line=getLine,
  reset=reset,
  ge=gcE,
  g=gc
}