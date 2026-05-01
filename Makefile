PROJECT = scheduler
CPU    ?= cortex-m3
BOARD  ?= stm32vldiscovery

qemu:
	arm-none-eabi-as -mthumb -mcpu=$(CPU) -ggdb -c $(PROJECT).s -o $(PROJECT).o
	arm-none-eabi-ld -Tmap.ld $(PROJECT).o -o $(PROJECT).elf
	arm-none-eabi-objdump -D -S $(PROJECT).elf > $(PROJECT).lst
	arm-none-eabi-readelf -a $(PROJECT).elf > $(PROJECT).debug
	qemu-system-arm -S -M $(BOARD) -cpu $(CPU) -nographic -kernel $(PROJECT).elf -gdb tcp::1234

gdb:
	gdb-multiarch -q $(PROJECT).elf \
	  -ex "target remote localhost:1234" \
	  -ex "break pendsv_handler" \
	  -ex "break task0" \
	  -ex "break task1" \
	  -ex "break task2"

clean:
	rm -rf *.o *.elf *.lst *.debug .gdb_history
