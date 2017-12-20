	.include "io.s"

	.text
	.global _start

_start:

Initialize:	
	// Constants
	adr x0, INV_TAU
	ldr d19, [x0]
	adr x0, V_LEAK
	ldr d20, [x0]
	adr x0, V_INIT
	ldr d21, [x0]
	adr x0, V_RESET
	ldr d22, [x0]
	adr x0, THETA
	ldr d23, [x0]
	adr x0, R_M
	ldr d24, [x0]
	adr x0, I_EXT
	ldr d25, [x0]

	// Variables
	mov x26, xzr // nt = 0
	fmov d26, d20 // v = V_LEAK
	fmov d27, xzr // i_ext = 0.0

Loop:
	mov x1, x26
	fmov d0, d26
	bl PrintMBP

	fmov d9, xzr // i_ext = 0.0
	cmp x26, #100
	ble Calculation
	cmp x26, #900
	bgt Calculation
	fmov d9, d25 // i_ext = I_EXT
	
Calculation: //double dv = ( DT / TAU ) * ( - ( v - V_LEAK ) + R_M * i_ext );
Version_0:
	//fmul d9, d24, d25 // R_M * i_ext
	//fsub d10, d26, d20 // v - V_LEAK
	//fsub d11, d9, d10 // ( R_M * i_ext ) - ( v - V_LEAK )
	//fmul d12, d19, d11 // ( INV_TAU ) * ( R_M * i_ext ) - ( v - V_LEAK ) = dv
	//fadd d26, d26, d12 // v += dv
Version_1:	
	//fmul d9, d24, d25 // R_M * i_ext
	//fsub d10, d26, d20 // v - V_LEAK
	//fsub d11, d9, d10 // dvx = ( R_M * i_ext ) - ( v - V_LEAK )
	//fmadd d26, d19, d11, d26
Version_2:
	fsub d10, d20, d26 // ( V_LEAK - v ) == - ( v - V_LEAK )
	fmadd d11, d24, d9, d10 // dvx = ( R_M * i_ext ) + ( - ( v - V_LEAK ) )
	fmadd d26, d19, d11, d26 // v = v + INV_TAU * dvx

	fcmp d26, d23 // ( comp v vs theta )
	ble LowerThanThreshold
	mov x1, x26
	bl PrintSPIKE
	fmov d26, d20 // v = V_RESET
	
LowerThanThreshold:
	add x26, x26, #1
	cmp x26, #1000
	bge Finalize
	b Loop

Finalize:
	exit

	.data

INV_TAU: .double 0.05 
V_LEAK:	 .double -65.0
V_INIT:	 .double -65.0
V_RESET: .double -65.0
THETA:	 .double -55.0
R_M:	 .double 1.0
DT:	 .double 1.0
T:	 .double 1000.0
I_EXT:	 .double 12.0

	.text
	.type PrintMBP, %function
PrintMBP:
	stp	x29, x30, [sp, #-16]!
	adr	x0, PrintMBP_fmt
	bl	printf
	ldp	x29, x30, [sp], #16
	ret

	.data
PrintMBP_fmt:	.string "%d %f\n"

	.text
	.type PrintSPIKE, %function
PrintSPIKE:
	stp	x29, x30, [sp, #-16]!
	adr	x0, PrintSPIKE_fmt
	bl	printf
	ldp	x29, x30, [sp], #16
	ret

	.data
PrintSPIKE_fmt:	.string "%d 0\n"
