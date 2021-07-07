--(C)2015 Juan Carlos González Amestoy

local file=require('h.io.file')
local meta=require('h.text.meta')
local o=require('h.io.console').o

o.lime("Amstrad generator\n").gold("©2015 Juan Carlos González Amestoy\n\n\n").reset()

local hAmstrad=table.concat(file.readLines('amstrad.lh'),'\n')
local mAmstrad=table.concat(file.readLines('amstrad.lm'),'\n')

local hCrtc=table.concat(file.readLines('crtc.lh'),'\n')
local mCrtc=table.concat(file.readLines('crtc.lm'),'\n')

local machine

function machineIs(...)
  for k,v in ipairs({...}) do
    for kk,vv in ipairs(machine) do
      if vv==v then return true end
    end
  end

  return false
end

local hMeta,_,e,c1=meta.compile(hAmstrad)
if e  then o.red("h:%s\n",e).white("Code:%s",c1).reset() return end
local mMeta,_,e2,c2=meta.compile(mAmstrad)
if e2 then o.red("m:%s\n",e).white(c2).reset() return end

local mCrtcm,_,e2,c2=meta.compile(mCrtc)
if e2 then o.red("m:%s\n",e2).white(c2).reset() return end
local hCrtcm,_,e2,c2=meta.compile(hCrtc)
if e2 then o.red("m:%s\n",e2).white(c2).reset() return end



o.pink("Generating Headers...\n\n")

o.cyan("Generating CRTC Type 0 Header...\n").reset()

machine={'crtc0'}
name='Crtc0'
path='compiled/crtc0.h'

file.writeLines(path,hCrtcm())

o.cyan("Generating CPC464 Header...\n").reset()

machine={'464'}
name='Cpc464'
structName='rvmCpc464S'
path='compiled/cpc464.h'

file.writeLines(path,hMeta())

o.cyan("Generating CPC664 Header...\n").reset()

machine={'664'}
name='Cpc664'
structName='rvmCpc664S'
path='compiled/cpc664.h'

file.writeLines(path,hMeta())

o.cyan("Generating CPC6128 Header...\n").reset()

machine={'6128'}
name='Cpc6128'
structName='rvmCpc6128S'
path='compiled/cpc6128.h'

file.writeLines(path,hMeta())

--------------------------------------------------

o.pink("Generating Code...\n\n")

o.cyan("Generating CRTC Type 0 Code...\n").reset()

machine={'crtc0'}
name='Crtc0'
path='compiled/crtc0.m'

file.writeLines(path,mCrtcm())

o.cyan("Generating CPC464 Code...\n").reset()

machine={'464'}
include='cpc464.h'
name='Cpc464'
structName='rvmCpc464S'
path='compiled/cpc464.m'

file.writeLines(path,mMeta())

o.cyan("Generating CPC664 Code...\n").reset()

machine={'664'}
include='cpc664.h'
name='Cpc664'
structName='rvmCpc664S'
path='compiled/cpc664.m'

file.writeLines(path,mMeta())

o.cyan("Generating CPC6128 Code...\n").reset()

machine={'6128'}
include='cpc6128.h'
name='Cpc6128'
structName='rvmCpc6128S'
path='compiled/cpc6128.m'

file.writeLines(path,mMeta())


