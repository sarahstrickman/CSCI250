# File:		traverse_tree.asm
# Author:	K. Reek
# Contributors:	P. White,
#		W. Carithers,
#		Sarah Strickman
#
# Description:	Binary tree traversal functions.
#
# Revisions:	$Log$


# CONSTANTS
#

# traversal codes
PRE_ORDER  = 0
IN_ORDER   = 1
POST_ORDER = 2

	.text			# this is program code
	.align 2		# instructions must be on word boundaries

#***** BEGIN STUDENT CODE BLOCK 3 *****************************
#
# Put your traverse_tree subroutine here.
#

# syscall codes
PRINT_INT = 1
PRINT_STRING = 4

        .globl  traverse_tree

#
# Name:         traverse_tree
#
# Description:  Based on a parameter, determine the traversal type to perform.
#               Delegate this responsibility to a different function.
#
# Arguments:    a0: address of the tree node
#               a1: address of the function that will process all of the nodes 
#                   in the tree
#               a2: constant that specifies what type of traversal to perform
#
# Returns:      none
#
traverse_tree:
        addi    $sp, $sp, -40                   # move stack pointer
        sw      $ra, 32($sp)                    # store ra
        sw      $s7, 28($sp)                    # store s registers
        sw      $s6, 24($sp)
        sw      $s5, 20($sp)
        sw      $s4, 16($sp)
        sw      $s3, 12($sp)
        sw      $s2, 8($sp)
        sw      $s1, 4($sp)
        sw      $s0, 0($sp)
        
        add     $s0, $a0, $zero                 # keep track of args in
        add     $s1, $a1, $zero                 # s registers
        add     $s2, $a2, $zero

        beq     $s0, $zero, done_recursion      # if s0 points to null, don't 
                                                # do anything. (base case is
                                                # the same for all traversal
                                                # orders)

        li      $t0, PRE_ORDER                  # jump to the traversal method
        li      $t1, IN_ORDER                   # specified by a0
        li      $t2, POST_ORDER
        beq     $s2, $t0, traverse_pre_order
        beq     $s2, $t1, traverse_in_order
        beq     $s2, $t2, traverse_post_order
        j       done_recursion                  # order specification is invalid

# if a2 is 0: traverse pre-order
traverse_pre_order:

        # PROCESS VALUE
        add     $a0, $s0, $zero                 # set a0 for processing
        jalr    $s1                             # process a0

        # TRAVERSE LEFT
        lw      $a0, 4($s0)                     # 4(s0) points to left branch
        jal traverse_tree

        # TRAVERSE RIGHT
        lw      $a0, 8($s0)                     # 8(s0) points to right branch
        jal traverse_tree

        j done_recursion

# if a2 is 1: traverse in-order
traverse_in_order:

        # TRAVERSE LEFT
        lw      $a0, 4($s0)                     # 4(s0) points to left branch
        jal traverse_tree

        # PROCESS VALUE
        add     $a0, $s0, $zero                 # set a0 for processing 
        jalr    $s1                             # process a

        # TRAVERSE RIGHT
        lw      $a0, 8($s0)                     # 8(s0) points to right branch
        jal traverse_tree

        j done_recursion

# if a2 is 2: traverse post-order
traverse_post_order:

        # TRAVERSE LEFT
        lw      $a0, 4($s0)                     # 4(s0) points to left branch
        jal traverse_tree

        # TRAVERSE RIGHT
        lw      $a0, 8($s0)                     # 8(s0) points to right branch
        jal traverse_tree

        # PROCESS VALUE
        add     $a0, $s0, $zero                 # set a0 for processing 
        jalr    $s1                             # process a0

        j done_recursion


done_recursion:
        add     $a0, $s0, $zero                 # restore a0, a1, and a2
        add     $a1, $s1, $zero                 # to their original values
        add     $a2, $a2, $zero

        lw      $s0, 0($sp)                     # restore s registers
        lw      $s1, 4($sp)
        lw      $s2, 8($sp)
        lw      $s3, 12($sp)
        lw      $s4, 16($sp)
        lw      $s5, 20($sp)
        lw      $s6, 24($sp)
        lw      $s7, 28($sp)
        lw      $ra, 32($sp)                    # restore ra
        addi    $sp, $sp, 40                    # move stack pointer back
        jr      $ra 


#***** END STUDENT CODE BLOCK 3 *****************************
