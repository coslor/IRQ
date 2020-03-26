A Commodore 64 project for experimenting with various subjects in C64 6502 assembler. 

It's pretty much all done in the Relaunch64 IDE, using KickAssembler

-Current Relaunch64 build optiona are:
	"C:\Program Files (x86)\Common Files\Oracle\Java\javapath\java" -jar "C:\Users\chris\KickAssembler\kickass.jar" -libdir "C:\Users\chris\Projects\Relaunch 64\IRQ" -libdir "C:\Users\chris\Projects\Relaunch 64\IRQ\includes" -libdir "C:\Users\chris\Projects\Relaunch 64\IRQ\tests" -o bin/ROUTFILE -bytedump -showmem -debug -debugdump -afo -asminfo all -vicesymbols  SOURCEFILE
	
-The const.asm file is pretty comprehensive for any C64 constant you could ask for, along with notes on proper usage

- I'm also building up a comprehensive macro library, to allow for easier text-based applications, as well as for easier debug logging or apps during development.

- Among the code I'm putting together:
	+ IRQ handling
	+ BRK handling
	+ A functional cut-and-paste for the C64
	+ tinydir, a small-footprint directory lister
