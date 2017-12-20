	//	Learned and modified from:
	// 	https://stackoverflow.com/questions/39845288/cant-print-sum-in-armv8-assembly
	
	.text
	
        // macro
        // exit
        .macro exit
        .exit\@:
        mov x8, #93             // exit see /usr/include/asm-generic/unistd.h
        svc 0
        .endm

	.text
	.global print1d
	.type print1d, %function
print1d:
	stp	x29, x30, [sp, #-16]!
	adr	x0, print1d_fmt
	bl	printf
	ldp	x29, x30, [sp], #16
	ret
	.data
print1d_fmt:	.string "%d\n"

	.text
	.global print0f
	.type print0f, %function
print0f:
	stp	x29, x30, [sp, #-16]!
	adr	x0, print0f_fmt
	bl	printf
	ldp	x29, x30, [sp], #16
	ret
	.global print0fs
	.type print0fs, %function
print0fs:
	stp	x29, x30, [sp, #-16]!
	adr	x0, print0f_fmt
	fcvt	d0, s0
	bl	printf
	ldp	x29, x30, [sp], #16
	ret
	.data
print0f_fmt:	.string "%f\n"

	.text
	.global print0s
	.type print0s, %function
print0s:
	stp	x29, x30, [sp, #-16]!
	bl	puts
	ldp	x29, x30, [sp], #16
	ret
