	.file	"profile_me_1.c"
	.text
	.globl	first_assign
	.type	first_assign, @function
first_assign:
.LFB6:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movl	%edi, -4(%rbp)
	movl	%esi, -8(%rbp)
	movq	%rdx, -16(%rbp)
	movq	%rcx, -24(%rbp)
	movq	%r8, -32(%rbp)
	movl	-8(%rbp), %eax
	imull	$5000, %eax, %edx
	movl	-4(%rbp), %eax
	addl	%edx, %eax
	cltq
	leaq	0(,%rax,8), %rdx
	movq	-16(%rbp), %rax
	addq	%rdx, %rax
	movsd	(%rax), %xmm1
	movl	-8(%rbp), %eax
	imull	$5000, %eax, %edx
	movl	-4(%rbp), %eax
	addl	%edx, %eax
	cltq
	leaq	0(,%rax,8), %rdx
	movq	-24(%rbp), %rax
	addq	%rdx, %rax
	movsd	(%rax), %xmm0
	addsd	%xmm0, %xmm1
	movl	-8(%rbp), %eax
	imull	$5000, %eax, %edx
	movl	-4(%rbp), %eax
	addl	%edx, %eax
	cltq
	leaq	0(,%rax,8), %rdx
	movq	-32(%rbp), %rax
	addq	%rdx, %rax
	movsd	(%rax), %xmm0
	movl	-8(%rbp), %eax
	imull	$5000, %eax, %edx
	movl	-4(%rbp), %eax
	addl	%edx, %eax
	cltq
	leaq	0(,%rax,8), %rdx
	movq	-16(%rbp), %rax
	addq	%rdx, %rax
	addsd	%xmm1, %xmm0
	movsd	%xmm0, (%rax)
	nop
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE6:
	.size	first_assign, .-first_assign
	.globl	second_assign
	.type	second_assign, @function
second_assign:
.LFB7:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movl	%edi, -4(%rbp)
	movl	%esi, -8(%rbp)
	movq	%rdx, -16(%rbp)
	movq	%rcx, -24(%rbp)
	movq	%r8, -32(%rbp)
	movl	-4(%rbp), %eax
	imull	$5000, %eax, %edx
	movl	-8(%rbp), %eax
	addl	%edx, %eax
	cltq
	leaq	0(,%rax,8), %rdx
	movq	-16(%rbp), %rax
	addq	%rdx, %rax
	movsd	(%rax), %xmm1
	movl	-4(%rbp), %eax
	imull	$5000, %eax, %edx
	movl	-8(%rbp), %eax
	addl	%edx, %eax
	cltq
	leaq	0(,%rax,8), %rdx
	movq	-24(%rbp), %rax
	addq	%rdx, %rax
	movsd	(%rax), %xmm0
	addsd	%xmm0, %xmm1
	movl	-4(%rbp), %eax
	imull	$5000, %eax, %edx
	movl	-8(%rbp), %eax
	addl	%edx, %eax
	cltq
	leaq	0(,%rax,8), %rdx
	movq	-32(%rbp), %rax
	addq	%rdx, %rax
	movsd	(%rax), %xmm0
	movl	-4(%rbp), %eax
	imull	$5000, %eax, %edx
	movl	-8(%rbp), %eax
	addl	%edx, %eax
	cltq
	leaq	0(,%rax,8), %rdx
	movq	-16(%rbp), %rax
	addq	%rdx, %rax
	addsd	%xmm1, %xmm0
	movsd	%xmm0, (%rax)
	nop
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE7:
	.size	second_assign, .-second_assign
	.globl	main
	.type	main, @function
main:
.LFB8:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$600000048, %rsp
	movl	%edi, -600000036(%rbp)
	movq	%rsi, -600000048(%rbp)
	movq	%fs:40, %rax
	movq	%rax, -8(%rbp)
	xorl	%eax, %eax
	movl	$0, -600000024(%rbp)
	jmp	.L4
.L7:
	movl	$0, -600000020(%rbp)
	jmp	.L5
.L6:
	movl	-600000020(%rbp), %eax
	cltq
	movl	-600000024(%rbp), %edx
	movslq	%edx, %rdx
	imulq	$5000, %rdx, %rdx
	addq	%rdx, %rax
	movsd	.LC0(%rip), %xmm0
	movsd	%xmm0, -600000016(%rbp,%rax,8)
	movl	-600000020(%rbp), %eax
	cltq
	movl	-600000024(%rbp), %edx
	movslq	%edx, %rdx
	imulq	$5000, %rdx, %rdx
	addq	%rdx, %rax
	movsd	.LC1(%rip), %xmm0
	movsd	%xmm0, -400000016(%rbp,%rax,8)
	movl	-600000020(%rbp), %eax
	cltq
	movl	-600000024(%rbp), %edx
	movslq	%edx, %rdx
	imulq	$5000, %rdx, %rdx
	addq	%rdx, %rax
	movsd	.LC2(%rip), %xmm0
	movsd	%xmm0, -200000016(%rbp,%rax,8)
	addl	$1, -600000020(%rbp)
.L5:
	cmpl	$4999, -600000020(%rbp)
	jle	.L6
	addl	$1, -600000024(%rbp)
.L4:
	cmpl	$4999, -600000024(%rbp)
	jle	.L7
	movl	$0, -600000024(%rbp)
	jmp	.L8
.L11:
	movl	$0, -600000020(%rbp)
	jmp	.L9
.L10:
	leaq	-200000016(%rbp), %rdi
	leaq	-400000016(%rbp), %rcx
	leaq	-600000016(%rbp), %rdx
	movl	-600000020(%rbp), %esi
	movl	-600000024(%rbp), %eax
	movq	%rdi, %r8
	movl	%eax, %edi
	call	first_assign
	addl	$1, -600000020(%rbp)
.L9:
	cmpl	$4999, -600000020(%rbp)
	jle	.L10
	addl	$1, -600000024(%rbp)
.L8:
	cmpl	$4999, -600000024(%rbp)
	jle	.L11
	movl	$0, -600000024(%rbp)
	jmp	.L12
.L15:
	movl	$0, -600000020(%rbp)
	jmp	.L13
.L14:
	leaq	-200000016(%rbp), %rdi
	leaq	-400000016(%rbp), %rcx
	leaq	-600000016(%rbp), %rdx
	movl	-600000020(%rbp), %esi
	movl	-600000024(%rbp), %eax
	movq	%rdi, %r8
	movl	%eax, %edi
	call	second_assign
	addl	$1, -600000020(%rbp)
.L13:
	cmpl	$4999, -600000020(%rbp)
	jle	.L14
	addl	$1, -600000024(%rbp)
.L12:
	cmpl	$4999, -600000024(%rbp)
	jle	.L15
	movl	$0, %eax
	movq	-8(%rbp), %rcx
	xorq	%fs:40, %rcx
	je	.L17
	call	__stack_chk_fail@PLT
.L17:
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE8:
	.size	main, .-main
	.section	.rodata
	.align 8
.LC0:
	.long	0
	.long	1072693248
	.align 8
.LC1:
	.long	0
	.long	1073741824
	.align 8
.LC2:
	.long	0
	.long	1074266112
	.ident	"GCC: (GNU) 9.1.0"
	.section	.note.GNU-stack,"",@progbits
