# homebrew-c64

A repository for **C64 Development** related brews.

## Requirements:
* [Homebrew](https://github.com/mxcl/homebrew)

## Installation:

### Tap the repository
	brew tap pacav69/c64

## Formulas:

### [vasm65](http://sun.hasenbraten.de/vasm/) v1.8e
	brew install pacav69/c64/vasm65

### [vlink](http://sun.hasenbraten.de/vlink/) v0.16b
	brew install pacav69/c64/vlink
	


### [amitools](https://github.com/cnvogelg/amitools) v0.2.0
	brew install python@2
	$(brew --prefix python@2)/bin/pip2 install amitools

### [Modpack](https://github.com/amigadev/modpack)
	brew install tditlu/amiga/modpack
> **Player:**
> [http://aminet.net/package/mus/misc/P6108](http://aminet.net/package/mus/misc/P6108)

### [IRA](http://aminet.net/package/dev/asm/ira) v2.09
	brew install tditlu/amiga/ira

### [RNC ProPackED](https://github.com/lab313ru/rnc_propack_source) v1.4
	brew install tditlu/amiga/rnc
> **Unpacker:**
> [http://aminet.net/package/util/pack/RNC_ProPack](http://aminet.net/package/util/pack/RNC_ProPack)

### [GCC](https://github.com/BartmanAbyss/gcc/tree/amiga-8_3_0) v8.3.0
	brew install tditlu/amiga/amiga-gcc
> **GDB is disabled for now...**
> Example project can be found [here](https://github.com/pacv69/homebrew-c64/blob/master/examples/amiga-gcc/)
