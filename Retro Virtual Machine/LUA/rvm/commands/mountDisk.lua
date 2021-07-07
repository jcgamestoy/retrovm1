--[[
Copyright (c) 2014 Juan Carlos González Amestoy

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

local dsk=require('rvm.decoders.dsk')
local path=require('h.io.path')

local id=require('rvm.parsers.id').parser

return {
  name='mountDisk',
  abbr='md',
  --g=g,
  doCmd=function(self,cs,p,selfPtr)
    local n,pos=id:match(p)

    if not n then
      cs.red('Error: Sintax Error.')
      return 0
    end

    if diskCache[n] then
      cs.red('Error: Disk already mounted in slot "').white('%s',n).red('"\n')
      return 0
    end
  
    return function(filename)
      --print(path)
      local pt=ffi.C.rvmCommandAddDisc(selfPtr,filename)

      diskCache[n]={name=n,ptr=pt,filename=path.filename(filename),path=filename}
      cs.lime('Disk mounted in slot "').white('%s',n).lime('"\n')  
    end
    ,{'dsk'}
    ,1
  end
}