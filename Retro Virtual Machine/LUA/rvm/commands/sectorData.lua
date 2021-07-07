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
local num=require('rvm.parsers.number').parser

local function findSector(tr,sID)
  --local spt=ffi.new('rvmDskSectorInfoS*',ffi.cast('rvmDskSectorInfoS*',ffi.cast('uint8_t*',tr)+0x18))
  --local dpt=ffi.new('uint8_t*',ffi.cast('uint8_t*',tr)+0x100)

  for i=0,tr.nsector-1 do
    if tr.sectors[i].sID==sID then
      return tr.sectors[i].data,tr.sectors[i]
    --else
      --dpt=dpt+sectors[j].rsize
    end
  end

  return nil
end

local function toBin(n)
  local a=''

  while(n~=0) do
    a=bit.band(n,0x1)==0x1 and '1'..a or '0'..a 
    n=bit.rshift(n,1)
  end

  return '0x'..(a=='' and '0' or a)
end

local function gchar(c)
  if c<32 or c>=128 then return '.' end
  return string.char(c)
end

return {
  name='sectorData',
  abbr='sd',
  --g=g,
  doCmd=function(self,cs,str,selfPtr)
    local n,pos=id:match(str)
    str=str(pos)
    local track,sID
    track,pos=num:match(str)
    str=str(pos)
    sID,pos=num:match(str)

    print(n,track,sID)
    if not n or not track or not sID then
      cs.red('Error: Sintax Error.\n')
      return 0
    end

    local side
    str=str(pos)
    side,pos=num:match(str)

    side=side and side or 0

    local d=diskCache[n]

    if not d then
      cs.red('Error: Disk "').white('%s',n).red('" not found.\n')
      return 0
    end

    --Check track and side is in bounds
    if track>=d.ptr.tracksN then
      cs.red('Error: Track "').white('%s',track).red('" out of bounds (max track=%d).\n',d.ptr.tracksN-1)
    end

    if side>d.ptr.sidesN-1 then
      cs.red('Error: Side "').white('%s',side).red('" out of bounds (max side=%d).\n',d.ptr.sidesN-1)
    end

    local ptr=d.ptr.sidesN==1 and track or track*2+side
    local tr=d.ptr.tracks[ptr]

    if tr~=nil then
      local data,ss=findSector(tr,sID)

      if data==nil then
        cs.orange('Unknow sector %d for track %d\n',sID,track)
        return 0
      end  

      cs.paleGreen('Sector Data\n')
      cs.cyan('Physical Track: %d, side %d (%d)\n',track,side,ptr)
      cs.cyan('Size: ').yellow('%d\n',bit.lshift(1,7+ss.sSize))
      cs.cyan('Real Size: ').yellow('%d\n',ss.rsize)
      cs.cyan('Logical track: ').yellow('%d\n',ss.track)
      cs.cyan('Logical side: ').yellow('%d\n',ss.side)
      cs.cyan('Logical sector: ').yellow('%d\n',ss.sID)

      cs.cyan('Status 1: ').yellow('%s ',toBin(ss.st1)).cyan('(').orange('%x',ss.st1).cyan(')\n')
      cs.cyan('Status 2: ').yellow('%s ',toBin(ss.st2)).cyan('(').orange('%x',ss.st2).cyan(')\n')

      if ss.rsize==0 then ss.rsize=bit.lshift(1,7+ss.sSize) end
      local a=0

      while a<ss.rsize do
        cs.yellow('0x%.4x ',a)
        local ascii={}

        
        for j=0,15 do
          if a<ss.rsize then
            local d=data[a]
            ascii[#ascii+1]=gchar(d)
            cs.lime('%.2x ',d)
            a=a+1
          end
        end

        cs.moccasin('%s\n',table.concat(ascii))
      end

      return 0
    else
      cs.orange('Track %d Unformated\n',track)
      return 0
    end
  end
}