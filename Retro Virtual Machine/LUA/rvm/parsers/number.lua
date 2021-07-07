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
local re=require('h.text.re')

local g=re.compile([[
  p<- %s* (hex / bin / dec) {}
  dec<- ([0-9]+) -> dec
  hex<- ('0x' / '&' / '$') (hexDigit+)->hex
  hexDigit <- [0-9a-fA-F]
  bin<- ('0b' / [%]) (binDigit+)->bin
  binDigit <- [01]
]],{
  dec=function(n)
    return tonumber(n)
  end,
  hex=function(n)
    return tonumber(n,16)
  end,
  bin=function(n)
    return tonumber(n,2)
  end
})

return {
  parser=g
}