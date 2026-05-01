MEMORY
{
    MEM : ORIGIN = 0x00000000, LENGTH = 0x4000
    RAM : ORIGIN = 0x20000000, LENGTH = 0x2000
}

SECTIONS
{
    .text : {
        *(.vectors*)
        *(.text*)
    } > MEM

    .data : {
        *(.data*)
    } > RAM

    _stack_top = ORIGIN(RAM) + LENGTH(RAM);
}
