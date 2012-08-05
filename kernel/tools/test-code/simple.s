.section .data
output:
	.ascii "Hello Linker Script !\n"
.equ len, . - output
.section .text
.global main
main:
	movl $output, %ecx
	movl $len, %edx
	movl $4, %eax
	movl $1, %ebx
	int $0x80
	movl $1, %eax
	movl $0, %ebx
	sysenter

