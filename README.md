# Retro Virtual Machine 1.1.x 

This is the code for version 1.1.x of my emulator for the ZX Spectrum, Retro Virtual Machine.

The current version (v2.0.7) that supports more machines (Amstrad CPC...) and more operating systems (macOS, Windows, Linux) is not yet open source, and you can find it at www.retrovirtualmachine.org.

## How to build

To compile you need Xcode v12.5.1+ simply open the "Retro virtual machine.xcodeproj" file and compile

This project generates a universal executable that will contain both x86_64 and arm64 versions, so it is already adapted for the new Apple Silicon processors.

## Binary executable

In the Releases section you have the latest public release 1.1.9 of this emulator branch already compiled.

## How it works

In the original development, both the .c files for the different machines and the .c file for the z80 emulation were generated automatically through a loa script, using my own tool.

As this tool is not provided, the pre-generated .c versions are used for both the machine code and the code. However, the .lua files that generated these .c files are included (although the tool is not included) for educational purposes.

I don't intend to continue with this branch of the emulator, so this will probably be the last commit to the repository. I hope you find the code instructive.
