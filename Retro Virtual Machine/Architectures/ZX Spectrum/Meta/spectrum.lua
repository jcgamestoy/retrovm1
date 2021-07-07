--(C)2014 Juan Carlos González Amestoy

local file=require('h.io.file')
local meta=require('h.text.meta')
local o=require('h.io.console').o

o.lime("Spectrum generator\n").gold("©2014 Juan Carlos González Amestoy\n\n\n").reset()

local hTemplate=table.concat(file.readLines('spectrum.lh'),'\n')

local mTemplate=table.concat(file.readLines('spectrum.lm'),'\n')

local machine

function machineIs(...)
  for k,v in ipairs({...}) do
    for kk,vv in ipairs(machine) do
      if vv==v then return true end
    end
  end

  return false
end

local hMeta,_,e,c1=meta.compile(hTemplate)
if e  then o.red("h:%s\n",e).white("Code:%s",c1).reset() return end
local mMeta,_,e2,c2=meta.compile(mTemplate)
if e2 then o.red("m:%s\n",e2).white('Code:%s',c2).reset() return end

o.pink("Generating Headers...\n\n")

o.cyan("Generating Spectrum 48k header...\n").reset()

machine={'48k'}
structName='spectrum'
name='48k'
path='Compiled/spectrum48k.h'

file.writeLines(path,hMeta())

o.cyan("Generating Spectrum 48k lua header...\n").reset()

machine={'48k'}
structName='spectrum'
name='48k'
path='Compiled/spectrum48k.lua'
isLua=true
memMgrName='rvm.architectures.zxspectrum.memory48k'

file.writeLines(path,hMeta())

o.cyan("Generating Spectrum 16k lua header...\n").reset()

machine={'16k'}
structName='spectrum'
name='16k'
path='Compiled/spectrum16k.lua'
isLua=true
memMgrName='rvm.architectures.zxspectrum.memory16k'

file.writeLines(path,hMeta())

o.cyan("Generating Spectrum 128k header...\n").reset()

machine={'128k','late'}
structName='spectrum128'
name='128k'
path='Compiled/spectrum128k.h'
isLua=false

file.writeLines(path,hMeta())

o.cyan("Generating Spectrum 128k lua header...\n").reset()

machine={'128k'}
structName='spectrum128'
name='128k'
path='Compiled/spectrum128k.lua'
isLua=true
memMgrName='rvm.architectures.zxspectrum.memory128k'

file.writeLines(path,hMeta())

o.cyan("Generating Spectrum +2A header...\n").reset()

machine={'128k','+2A'}
structName='spectrumPlus2A'
name='Plus2A'
path='Compiled/spectrumPlus2A.h'
isLua=false

file.writeLines(path,hMeta())

o.cyan("Generating Spectrum +2A lua header...\n").reset()

machine={'128k','+2A'}
structName='spectrumPlus2A'
name='Plus2A'
path='Compiled/spectrumPlus2A.lua'
isLua=true
memMgrName='rvm.architectures.zxspectrum.memoryPlus2A'

file.writeLines(path,hMeta())

o.cyan("Generating Spectrum +3 header...\n").reset()

machine={'128k','+2A','+3'}
structName='spectrumPlus3'
name='Plus3'
path='Compiled/spectrumPlus3.h'
isLua=false

file.writeLines(path,hMeta())

o.cyan("Generating Spectrum Inves header...\n").reset()

machine={'inves'}
structName='spectrumInves'
name='Inves'
path='Compiled/spectrumInves.h'
isLua=false

file.writeLines(path,hMeta())

o.cyan("Generating Spectrum +3 lua header...\n").reset()

machine={'128k','+2A','+3'}
structName='spectrumPlus3'
name='Plus3'
path='Compiled/spectrumPlus3.lua'
isLua=true
memMgrName='rvm.architectures.zxspectrum.memoryPlus2A'

file.writeLines(path,hMeta())

o.pink("Generating Code...\n\n")

o.cyan("Generating Spectrum 48k code...\n").reset()

machine={'48k','snow'}
name='48k'
include='spectrum48k.h'
structName='spectrum'
path='Compiled/spectrum48k.m'

file.writeLines(path,mMeta())

o.cyan("Generating Spectrum 16k code...\n").reset()

machine={'16k'}
name='16k'
include='spectrum48k.h'
structName='spectrum'
path='Compiled/spectrum16k.m'

file.writeLines(path,mMeta())

o.cyan("Generating Spectrum 48k issue2 code...\n").reset()

machine={'issue2'}
name='48kIssue2'
include='spectrum48k.h'
structName='spectrum'
path='Compiled/spectrum48kIssue2.m'

file.writeLines(path,mMeta())

o.cyan("Generating Spectrum 128k code...\n").reset()

machine={'128k','snow'}
name='128k'
include='spectrum128k.h'
structName='spectrum128'
path='Compiled/spectrum128k.m'

file.writeLines(path,mMeta())

o.cyan("Generating Spectrum +2A code...\n").reset()

machine={'+2A'}
name='Plus2A'
include='spectrumPlus2A.h'
structName='spectrumPlus2A'
path='Compiled/spectrumPlus2A.m'

file.writeLines(path,mMeta())

o.cyan("Generating Spectrum +3 code...\n").reset()

machine={'+2A','+3'}
name='Plus3'
include='spectrumPlus3.h'
structName='spectrumPlus3'
path='Compiled/spectrumPlus3.m'

file.writeLines(path,mMeta())

o.cyan("Generating Inves code...\n").reset()

machine={'inves'}
name='Inves'
include='spectrumInves.h'
structName='spectrumInves'
path='Compiled/spectrumInves.m'

file.writeLines(path,mMeta())
