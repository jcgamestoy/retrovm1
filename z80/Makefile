#Copyright (c) 2011-13 Juan Carlos González Amestoy
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in
#all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#THE SOFTWARE.

uname=$(shell uname)
cc=clang
ifeq ($(uname),Darwin)
	objdir=src/build/osx/
	exename=build/osx/z80.dylib
	cflags=-Isrc/ -O3 -g
else
	objdir=src/build/linux/
	exename=build/linux/z80.so
	cflags=-Isrc/ -O3 -fPIC
endif

ldflags=-O2
#_obj=inst.o z80.o
_obj=z.o z80.o

all: pre $(addprefix $(objdir),$(_obj))
	$(cc) -o $(exename) $(addprefix $(objdir),$(_obj)) --shared $(ldflags)

$(objdir)z80.o: src/z80.c src/z80.h
	$(cc) -c  -Dz80STUB src/z80.c -o $@ $(cflags) 

# $(objdir)zuops.o: $(objdir)zuops.c src/z80.h
# 	$(cc) -c  -Dz80STUB $(objdir)zuops.c -o $@ $(cflags)

$(objdir)z.o: $(objdir)z.c src/z80.h
	$(cc) -c  -Dz80STUB $(objdir)z.c -o $@ $(cflags)

pre:
	H src/z80uops.lua $(objdir)/z	
#$(objdir)inst.o: src/z80.lua src/z80.h
#	H src/z80.lua $(objdir)inst.c
#	$(cc) -c $(objdir)inst.c -o $@ $(cflags)

clean:
	rm -rf $(objdir)*
	rm -rf $(exename)