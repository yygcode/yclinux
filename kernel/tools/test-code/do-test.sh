as -o simple.o simple.s
ld -T simple.lds -o simple simple.o
./simple
objdump -D simple
