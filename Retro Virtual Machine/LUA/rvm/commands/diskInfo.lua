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

local id=require('rvm.parsers.id').parser

return {
  name='diskInfo',
  abbr='di',
  --g=g,
  doCmd=function(self,cs,p,selfPtr)
    local n,pos=id:match(p)

    if not n then
      cs.red('Error: Sintax Error.\n')
      return 0
    end

    local d=diskCache[n]

    if not d then
      cs.red('Error: Disk "').white('%s',n).red('" not found.\n')
      return 0
    end

    cs.paleGreen('Disk Information\n')
    cs.cyan('Tracks: ').yellow('%d\n',d.ptr.tracksN)
    cs.cyan('Sides: ').yellow('%d\n',d.ptr.sidesN)

    local t=d.ptr.tracksN*d.ptr.sidesN

    for i=0,t-1 do
      local tr=d.ptr.tracks[i]
      
      if tr~=nil then 
        cs.darkSeaGreen('Track ').yellow('%d ',tr.trackN).darkSeaGreen('side ').yellow('%d ',tr.sideN) 
        --local spt=ffi.new('rvmDskSectorInfoS*',ffi.cast('rvmDskSectorInfoS*',ffi.cast('uint8_t*',tr)+0x18))

        for j=0,tr.nsector-1 do
          cs.cyan('%.2x(',tr.sectors[j].sID).orange('%d',bit.lshift(1,7+tr.sectors[j].sSize)).yellow('/').lime('%d',tr.sectors[j].rsize).cyan(') ')
          --spt=spt+1
        end

        cs('\n')
      else
        cs.fireBrick('Track #%d Unformated\n',i)
      end
    end

    return 0
  end
}