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

local ffi=require('ffi')
local re=require('h.text.re')
local colors=require('h.color').colors

ffi.cdef[[
  void rvmCommandResultAddLine(void* string,double r,double g,double b,const char* str);
]]

local g=re.compile([[
  c<-%s* {[^%s]+} %s* {.*}
]])

local dispatcher={}

local commandCache={}
local lastCommand

diskCache={}

local function doColorStream(ptr)
  local r={}
  local rmt={}
  local color=colors.white()

  function rmt.__index(t,k)
    --print(t,k)
    local c=colors[k]
    if c then
      color=c()
      return t
    else
      return nil
    end
  end

  function rmt.__call(o,str,...)
    --print(o,str,...)
    --print('pre print')
    dispatcher.print(ptr,str:format(...),color)
    --print('post print')
    return o
  end

  setmetatable(r,rmt)
  return r
end

function dispatcher.register(command)
  local cmd=require(command)
  commandCache[cmd.name]=cmd
  commandCache[cmd.abbr]=cmd
end

function dispatcher.doCmd(ptr,selfPtr,command)
  local n,p=g:match(command)
  
  local c=commandCache[n]
  ptr=ffi.cast('void*',ptr)
  selfPtr=ffi.cast('void*',selfPtr)

  local cs=doColorStream(ptr)

  if c then
    lastCommand=c
    return c:doCmd(cs,p,selfPtr)
  else
    if not command or command=='' then
      return lastCommand:doCmd(cs,'',selfPtr)
    else
      cs.red('Unrecognized command "').white('%s',command).red('"\n')
    end
  end

  return 0;
end

function dispatcher.print(ptr,str,color)
  color=color and color or colors.white()
  ffi.C.rvmCommandResultAddLine(ptr,color.r,color.g,color.b,str);
end

return dispatcher