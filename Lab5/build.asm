# File:		build.asm
# Author:	K. Reek
# Contributors:	P. White,
#		W. Carithers,
#		Sarah Strickman
#
# Description:	Binary tree building functions.
#
# Revisions:	$Log$


	.text			# this is program code
	.align 2		# instructions must be on word boundaries

# 
# Name:		add_elements
#
# Description:	loops through array of numbers, adding each (in order)
#		to the tree
#
# Arguments:	a0 the address of the array
#   		a1 the number of elements in the array
#		a2 the address of the root pointer
# Returns:	none
#

	.globl	add_elements
	
add_elements:
	addi 	$sp, $sp, -16
	sw 	$ra, 12($sp)
	sw 	$s2, 8($sp)
	sw 	$s1, 4($sp)
	sw 	$s0, 0($sp)

#***** BEGIN STUDENT CODE BLOCK 1 ***************************
#
# Insert your code to iterate through the array, calling build_tree
# for each value in the array.  Remember that build_tree requires
# two parameters:  the address of the variable which contains the
# root pointer for the tree, and the number to be inserted.
#
# Feel free to save extra "S" registers onto the stack if you need
# more for your function.
#
        .globl  allocate_mem



        add     $s0, $a0, $zero                 # s0 = addr of array
        add     $s2, $a1, $zero                 # s2 = array length
        add     $s1, $zero, $zero               # s1 = index in the array

        
        lw      $t0, 0($a2)
        add     $a0, $t0, $zero                 # a0 has addr of tree root

loop_add_elements:
        slt     $t9, $s1, $s2                   # If you have reached the end
        beq     $t9, $zero, done_add_elements   # of the array, stop.

        lw      $t0, 0($s0)                     # get the item in the array
        add     $a1, $t0, $zero                 # a1 will have the number to
                                                # put into the tree.
        jal build_tree
       
        addi    $s1, $s1, 1                     # increment counter and your
        addi    $s0, $s0, 4                     # space in memory of the array.
        j       loop_add_elements

done_add_elements:
        sw      $a0, 0($a2)                     # head of tree is stored in a2 again
        add     $a0, $s0, $zero                 # restore a0 and a1
        add     $a1, $s2, $zero
        sub     $a0, $s1, $t9                   # move a0 back the beginning
                                                # of the array

#
# If you saved extra "S" reg to stack, make sure you restore them
#

#***** END STUDENT CODE BLOCK 1 *****************************

add_done:

	lw 	$ra, 12($sp)
	lw 	$s2, 8($sp)
	lw 	$s1, 4($sp)
	lw 	$s0, 0($sp)
	addi 	$sp, $sp, 16
	jr 	$ra

#***** BEGIN STUDENT CODE BLOCK 2 ***************************
#
# Put your build_tree subroutine here.
#

# 
# Name:		build_tree
#
# Description:	Adds a single element into the binary search tree
#
# Arguments:	a0 : the address of the tree's root
#               a1 : the number to put into the tree
#
# Returns:	none
#
build_tree:
        addi    $sp, $sp, -40                   # allocate sp
        sw      $ra, 32($sp)                    # store return addr
        sw      $s7, 28($sp)                    # store s registers
        sw      $s6, 24($sp)
        sw      $s5, 20($sp)
        sw      $s4, 16($sp)
        sw      $s3, 12($sp)
        sw      $s2, 8($sp)
        sw      $s1, 4($sp)
        sw      $s0, 0($sp)

        add     $s0, $a0, $zero                 # store a0 and a1
        add     $s1, $a1, $zero

        beq     $s0, $zero, build_new_node      # if root is null, build 
                                                # new node

        lw      $s2, 0($s0)                     # get value at current node

        beq     $s1, $s2, done_build            # if current val is = val in
                                                # node, don't do anything
                                                # (tree can't have duplicates)

        slt     $t9, $s1, $s2                   # if s1 < s2, recurse left
        bne     $t9, $zero, build_left

        slt     $t9, $s2, $s1                   # if s1 > s2, recurse right
        bne     $t9, $zero, build_right

build_left:
        lw      $a0, 4($s0)                     # a0 points to left tree
        
        jal     build_tree                      # call build_tree on the left
                                                # branch.
                                                
        sw      $a0, 4($s0)                     # store root of edited tree
                                                # back into left side

        add     $a0, $s0, $zero                 # a0 = original root

        j done_build

build_right:
        lw      $a0, 8($s0)                     # a0 points to right tree

        jal     build_tree                      # call build_tree on the right
                                                # branch

        sw      $a0, 8($s0)                     # store root of edited tree
                                                # back into right side

        add     $a0, $s0, $zero                 # a0 = original root


        j done_build

build_new_node:
        li      $a0, 3                          # allocate 3 words: one for
                                                # left, right, value

        jal     allocate_mem                    # v0 will now have the 
                                                # addr of the memory
        
        sw      $s1, 0($v0)                     # set val, left, and right
        sw      $zero, 4($v0)                   # of newly created node
        sw      $zero, 8($v0)

        add     $a0, $v0, $zero                 # a0 points to new node

        j done_build

done_build:

        lw      $s0, 0($sp)                     # restore s registers
        lw      $s1, 4($sp)
        lw      $s2, 8($sp)
        lw      $s3, 12($sp)
        lw      $s4, 16($sp)
        lw      $s5, 20($sp)
        lw      $s6, 24($sp)
        lw      $s7, 28($sp)
        lw      $ra, 32($sp)                    # restore ra
        addi    $sp, $sp, 40                    # move stack ptr back
        jr      $ra                             # return

#***** END STUDENT CODE BLOCK 2 *****************************
