# File:		sub_ascii_numbers.asm
# Author:	K. Reek
# Contributors:	P. White, W. Carithers
#		Sarah Strickman sxs4599
#
# Updates:
#		3/2004	M. Reek, named constants
#		10/2007 W. Carithers, alignment
#		09/2009 W. Carithers, separate assembly
#
# Description:	sub two ASCII numbers and store the result in ASCII.
#
# Arguments:	a0: address of parameter block.  The block consists of
#		four words that contain (in this order):
#
#			address of first input string
#			address of second input string
#			address where result should be stored
#			length of the strings and result buffer
#
#		(There is actually other data after this in the
#		parameter block, but it is not relevant to this routine.)
#
# Returns:	The result of the subtraction, in the buffer specified by
#		the parameter block.
#

	.globl	sub_ascii_numbers

sub_ascii_numbers:
A_FRAMESIZE = 40

#
# Save registers ra and s0 - s7 on the stack.
#
	addi 	$sp, $sp, -A_FRAMESIZE
	sw 	$ra, -4+A_FRAMESIZE($sp)
	sw 	$s7, 28($sp)
	sw 	$s6, 24($sp)
	sw 	$s5, 20($sp)
	sw 	$s4, 16($sp)
	sw 	$s3, 12($sp)
	sw 	$s2, 8($sp)
	sw 	$s1, 4($sp)
	sw 	$s0, 0($sp)
	
# ##### BEGIN STUDENT CODE BLOCK 1 #####
        
        lw      $s1, 0($a0)             # s1 = address of minuend
        lw      $s2, 4($a0)             # s2 = address of subtractahend
        lw      $s3, 8($a0)             # s3 = address of difference
        lw      $s4, 12($a0)            # s4 = length of strings
        
        add     $t1, $s1, $s4           # t1 = addr of last index of minuend
        addi    $t1, $t1, -1

        add     $t2, $s2, $s4           # t2 = addr of last
        addi    $t2, $t2, -1            #      index of subtractahend

        add     $t3, $s3, $s4           # t3 = addr of last index of
        addi    $t3, $t3, -1            #      difference

        add     $t4, $s4, $zero         # counter for length of strings
        add     $s7, $zero, $zero       # carry bit. 0 at first


subtract_loop:                          # loop to subtract and put into result
        # stop looping when all has been read
        beq     $t4, $zero, finish_function

        lbu     $t9, 0($t1)             # t9 = char in minuend
        lbu     $t8, 0($t2)             # t8 = char in subtractahend
        
        sub     $t9, $t9, $s7           # take carry bit into account
        add     $s7, $zero, $zero       # reset carry bit

        # do subtraction
        sub     $t7, $t9, $t8           # t7 = difference

        slt     $t5, $t7, $zero
        bne     $t5, $zero, borrow      # borrow if needed

continue_subtraction:
        addi    $t7, $t7, 48            # add back ascii offset

        sb      $t7, 0($t3)             # store it in t3

        addi    $t1, $t1, -1            # move up 1 character in numbers\
        addi    $t2, $t2, -1            # to the next number that hasn't been\
        addi    $t3, $t3, -1            # seen or next empty space

        addi    $t4, $t4, -1            # decrement length counter

        j subtract_loop


borrow:                                 # borrow from the character before
        addi    $t7, $t7, 10            # add 10 to difference
        addi    $s7, $zero, 1           # gotta carry again
        j continue_subtraction 


finish_function:

         
# ###### END STUDENT CODE BLOCK 1 ######

#
# Restore registers ra and s0 - s7 from the stack.
#
	lw 	$ra, -4+A_FRAMESIZE($sp)
	lw 	$s7, 28($sp)
	lw 	$s6, 24($sp)
	lw 	$s5, 20($sp)
	lw 	$s4, 16($sp)
	lw 	$s3, 12($sp)
	lw 	$s2, 8($sp)
	lw 	$s1, 4($sp)
	lw 	$s0, 0($sp)
	addi 	$sp, $sp, A_FRAMESIZE

	jr	$ra			# Return to the caller.
