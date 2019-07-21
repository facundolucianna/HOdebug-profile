	.file	"profile_me_1.c"
	.text
	.p2align 4
	.globl	first_assign
	.type	first_assign, @function
first_assign:
.LFB11:
	.cfi_startproc
	imull	$5000, %esi, %esi
	addl	%edi, %esi
	movslq	%esi, %rdi
	leaq	(%rdx,%rdi,8), %rax
	movsd	(%rcx,%rdi,8), %xmm0
	addsd	(%rax), %xmm0
	addsd	(%r8,%rdi,8), %xmm0
	movsd	%xmm0, (%rax)
	ret
	.cfi_endproc
.LFE11:
	.size	first_assign, .-first_assign
	.p2align 4
	.globl	second_assign
	.type	second_assign, @function
second_assign:
.LFB12:
	.cfi_startproc
	imull	$5000, %edi, %edi
	addl	%esi, %edi
	movslq	%edi, %rsi
	leaq	(%rdx,%rsi,8), %rax
	movsd	(%rcx,%rsi,8), %xmm0
	addsd	(%rax), %xmm0
	addsd	(%r8,%rsi,8), %xmm0
	movsd	%xmm0, (%rax)
	ret
	.cfi_endproc
.LFE12:
	.size	second_assign, .-second_assign
	.section	.text.startup,"ax",@progbits
	.p2align 4
	.globl	main
	.type	main, @function
main:
.LFB13:
	.cfi_startproc
	xorl	%eax, %eax
	ret
	.cfi_endproc
.LFE13:
	.size	main, .-main
	.ident	"GCC: (GNU) 9.1.0"
	.section	.note.GNU-stack,"",@progbits
