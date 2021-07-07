#!/usr/bin/luajit
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

local h=require('h')
local o=require('h.io.console').o
local params=require('tools.misc.params')
local file=require('h.io.file')
local path=require('h.io.path')
local ffi=require('ffi')

function script_path()
   local str = debug.getinfo(2, "S").source:sub(2)
   return str:match("(.*/)")
end

--print(script_path())

--print('path',file.scriptPath())
package.path=package.path..';'..path.path(file.realPath(file.scriptPath()))..'?.lua'

local tzx=require('tzx')
local csw=require('csw')

local state='list'
local searchBlock=nil
local searchPath=nil
local filenameCSW,filenameTZX=nil,nil

local p=params.new()
p:addParam("version","v","","Display the version string",0,function() state="version" end)
p:addParam("search","s","","Search Tzx files with a block recursively.",2,function(p)
  searchBlock=tonumber(p[1]) 
  searchPath=p[2] and p[2] or '.'
  state="search" 
end)

p:addParam("convertCSW","c","","Convert CSW file to TZX",2,function(p)
  state='convert'
  filenameCSW=p[1]
  filenameTZX=p[2]
end)

local s=p:parse(arg)

if state=='version' then
  o.lime('TZXTool v0.1\n').gold('©2014 Juan Carlos González Amestoy.\n\n').reset()
elseif state=='search' then
  o.cyan('Searching block 0x%.2x in path %s\n',searchBlock,searchPath)

  local dirStack={}
  local d=searchPath

  local c=0

  while true do
    local dd=file.dir(d)

    if dd then
      for i,f in ipairs(dd) do
        if f.isDir then
          dirStack[#dirStack+1]=f.path
        else 
          c=c+1
          --o.pink('%d:file:%s\n',c,f.path)
          --file
          local lpath=f.path:toLower()
          if lpath:ends('.tzx') then
            local tzxf=tzx.parse(f.path)

            for ii,b in ipairs(tzxf) do
              if b.id==searchBlock then 
                o.lime("Found!!! ").white('%s\n',f.path)
                for iii,b in ipairs(tzxf) do
                  o.gold('Block 0x%.2x: %s\n',b.id,b.name)
                end
                break
              end
            end
          end

          if (c%1000)==0 then
            o.cyan('%d Files.\n',c)
          end
        end
      end
    end

    if #dirStack>0 then
      d=dirStack[#dirStack]
      dirStack[#dirStack]=nil
    else
      break
    end
  end

--Convert csw
elseif state=='convert' then
  if filenameTZX and filenameCSW then
    local header=tzx.newHeader()
    local csw,data=csw.load(filenameCSW)
    local f=file.open(filenameTZX,'w')
    f:write(ffi.string(header,ffi.sizeof(header)))

    f:write(string.char(0x18))
    local b=ffi.new('rvmTZX18Block')
    b.pause=0
    b.sampling[0]=bit.band(csw.sampleRate,0xff)
    b.sampling[1]=bit.band(bit.rshift(csw.sampleRate,8),0xff)
    b.sampling[2]=bit.band(bit.rshift(csw.sampleRate,16),0xff)

    b.compression=csw.compression
    b.pulses=csw.total
    b.length=#data-ffi.sizeof('rvmCSWBlock2S')+ffi.sizeof('rvmTZX18Block')-4

    o('Length: %d bytes, sizeof: %d %d\n',b.length,ffi.sizeof(b),ffi.sizeof(csw))

    f:write(ffi.string(b,ffi.sizeof(b)))
    f:write(ffi.string(csw.data,#data-ffi.sizeof('rvmCSWBlock2S')))
    f:close()
  else
    o.red('Sintax Error\n').reset()
  end
elseif state=='list' then
  local t=tzx.parse(s[1])

  if t then
    o.lime('File: ').white('%s\n\n',s[1])

    for i,b in ipairs(t) do
      o.gold('Block 0x%.2x: ',b.id).white('%s\n',b.name)
    end
  else
    o.red('Error: ').white('Error open tzx file: ').yellow('%s\n')
  end
end