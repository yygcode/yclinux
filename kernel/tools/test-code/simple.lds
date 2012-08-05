SECTIONS {
	. = 0x10000;
	.text : { *(.text) }
	. = 0x20000;
	.data : { LONG(.); *(.data) }
	.bss  : { *(.bss) }

}

ENTRY(main)
