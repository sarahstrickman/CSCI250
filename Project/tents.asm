# File:         tents.asm
# Author:       Sarah Strickman (sxs4599)
# Contributors: Sarah Strickman
#
# Description:  Runs the tents program.
#               Specifications can be found on the CSCI250 website.
#
# Revisions:    $Log$


######### CONSTANTS ##########

# syscall codes
PRINT_INT = 1
PRINT_STRING = 4
READ_INT = 5
READ_STRING = 8
TERMINATE_PGRM = 10
PRINT_CHAR = 11
READ_CHAR = 12

# board codes
EMPTY_SPACE = 1         # empty space (just grass here)
TREE_EMPTY = 2          # tree without tent attached
TREE_TOP = 3            # tree with tent attached above it
TREE_LEFT = 4           # tree with tent attached left of it
TREE_RIGHT = 5          # tree with tent attached right of it
TREE_BOT = 6            # tree with tent attached below it
TENT = 7                # tent (there's a tent here!)

# min/max values
MAX_BUFFER_SIZE = 20    # max size of an input line
MIN_BOARD_SIZE = 2      # min board size
MAX_BOARD_SIZE = 12     # max board size

# char values
SPACE_CHAR = 32         # ascii value for ' '
NEWLINE_CHAR = 10       # ascii value for '\n'
TREE_CHAR = 84          # ascii value for 'T'
EMPTY_SPACE_CHAR = 46   # ascii value for '.'
TENT_CHAR = 65          # ascii value for 'A'

########## DATA AREAS ##########
        .data
        .align  2

#
# memory for the arrays
#

board:
        .space  MAX_BOARD_SIZE*MAX_BOARD_SIZE*4 # double array of the board

rowMax:
        .space  MAX_BOARD_SIZE*4

colMax:
        .space  MAX_BOARD_SIZE*4

#
# print strings
#
        .align	0               # string data doesn't have to be aligned

buffer:
        .asciiz "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"

# useful characters
newline_char:
        .asciiz "\n"

space_char:
        .asciiz " "

# banner/title strings
tents_banner_string:
        .asciiz "\n******************\n**     Tents    **\n******************\n\n"

# error messages
error_msg_board_size:
        .asciiz "Invalid board size, Tents terminating\n"

error_msg_illegal_sum:
        .asciiz "Illegal sum value, Tents terminating\n"

error_msg_illegal_char:
        .asciiz "Illegal board character, Tents terminating\n"

error_msg_impossible_puzzle:
        .asciiz "Impossible Puzzle\n\n"

# printing the board
board_title_initial:
        .asciiz "Initial Puzzle\n\n"

board_title_final:
        .asciiz "Final Puzzle\n\n"

board_border_unit_beg:
        .asciiz "+-"

board_border_unit_mid:
        .asciiz "--"

board_border_unit_end:
        .asciiz "+\n"

board_contents_side:
        .asciiz "| "

board_contents_grass:
        .asciiz ". "

board_contents_tent:
        .asciiz "A "

board_contents_tree:
        .asciiz "T "

################################################################
# Code segments -------------
################################################################

	.text
        .align 2
        .globl  main

#
# Name:         main
#
# Description:  EXECUTION STARTS HERE
#
# Arguments:    None
#
# Returns:      None
#
main:
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

        li      $a0, MAX_BOARD_SIZE             # initialize the board with 0
        mul     $a0, $a0, $a0
        la      $a1, board
        jal     initialize_words

        li      $a0, MAX_BOARD_SIZE             # initialize the col capacity
        la      $a1, colMax                     # array with 0
        jal     initialize_words

        li      $a0, MAX_BOARD_SIZE             # initialize the row capacity
        la      $a1, rowMax                     # array with 0
        jal     initialize_words
        
        li      $a0, MAX_BUFFER_SIZE            # initialize the string buffer
        la      $a1, buffer                     # array with 0's
        jal     initialize_bytes

        la      $a0, tents_banner_string        # print the title banner
        li      $v0, PRINT_STRING
        syscall
        
        li      $v0, READ_INT                   # get boardSize
        syscall                                 # int is in v0
 
        add     $s0, $v0, $zero                 # s0 = boardSize

        add     $a0, $zero, $s0                 # validate board size
        jal     validate_boardsize
        bne     $v0, $zero, main_done

        li      $v0, READ_STRING                # read the line for the
        la      $a0, buffer                     # row max's
        li      $a1, MAX_BUFFER_SIZE
        syscall

        add     $a0, $s0, $zero
        la      $a1, rowMax
        jal     populate_max_sums
        bne     $v0, $zero, main_done           # validate sums for rows

        li      $a0, MAX_BUFFER_SIZE            # initialize the string buffer
        la      $a1, buffer                     # array with 0's
        jal     initialize_bytes

        li      $v0, READ_STRING                # read the line for the
        la      $a0, buffer                     # col max's
        li      $a1, MAX_BUFFER_SIZE
        syscall

        add     $a0, $s0, $zero
        la      $a1, colMax
        jal     populate_max_sums
        bne     $v0, $zero, main_done           # validate sums for col

        add     $a0, $s0, $zero                 # read, populate, validate
        la      $a1, board                      # board
        jal     populate_board
        bne     $v0, $zero, main_done           # validate chars for board

        la      $a0, board_title_initial        # print "Initial Board"
        li      $v0, PRINT_STRING
        syscall

        add     $a0, $s0, $zero                 # print the board
        la      $a1, board
        la      $a2, rowMax
        la      $a3, colMax
        jal     print_board

        li      $v0, PRINT_CHAR
        li      $a0, NEWLINE_CHAR
        syscall

        add     $a0, $s0, $zero                 # solve the board.
        la      $a1, board                      # is_solution will return 0
        jal     is_solution                     # if there is no solution.
        beq     $v0, $zero, main_done

        li      $v0, PRINT_STRING
        la      $a0, board_title_final
        syscall

        add     $a0, $s0, $zero                 # print the solved board
        la      $a1, board
        la      $a2, rowMax
        la      $a3, colMax
        jal     print_board

        li      $v0, PRINT_CHAR
        li      $a0, NEWLINE_CHAR
        syscall

#---

main_done:
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

	jr	$ra				# return from main and exit
#------------------

# Name:         is_solution
#
# Description:  Attempts to solve the board. If there is no solution to
#               the puzzle, print the error message. Board will be modified
#               to contain the solution if one is found.
#
# Parameters:   a0: boardSize
#               a1: pointer to board
#
# Returns:      0 if no solution exists (impossible board)
#               2 if valid solution is found
is_solution:
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

        add     $a0, $a0, $zero                 # attempt to solve the board
        li      $a1, 0
        li      $a2, 0
        jal     solve

        bne     $v0, $zero, is_solution_done    # a valid solution was found

is_solution_none:                               # no solution found
        li      $v0, PRINT_STRING
        la      $a0, error_msg_impossible_puzzle
        syscall
        li      $v0, 0                          # restore v0

                                                # no need to make any changes
                                                # to v0, as it will already 
                                                # return 0 if no sol, and 
                                                # different number otherwise
is_solution_done:
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

	jr	$ra				# return

#------------------

# Name:         solve
#
# Description:  Recursively tries to solve the maze.
#
# Parameters:   a0: boardSize
#               a1: row to start iterating from
#               a2: col to start iterating from
#
# Returns:      0 if there is no solution
#               1 if this is a valid configuration
#               2 if this is configuration is the solution
solve:
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

        add     $s0, $a0, $zero                 # s0 = boardSize
        la      $s1, board                      # s1 = pointer to board
        add     $s2, $a1, $zero                 # s2 = index of rows
        add     $s3, $a2, $zero                 # s3 = index of cols

        la      $a2, rowMax
        la      $a3, colMax
        la      $t0, board
        mul     $t1, $s2, $s0                   # t1 = idx of board
        add     $t1, $t1, $s3
        mul     $t1, $t1, 4

        add     $s1, $s1, $t1                   # s1 = pointer to new 
                                                #      idx at board

                                                # Loop until you find the next
                                                # tree
solve_loop1:
        slt     $t0, $s2, $s0                   # No more trees. Treat this
        beq     $t0, $zero, solve_solution      # as solution

solve_loop2:
        slt     $t0, $s3, $s0                   # finished looking at this row
        beq     $t0, $zero, solve_done2

        li      $t0, TREE_EMPTY                 # there is no tree here. Keep
        lw      $t1, 0($s1)                     # looping through the board

       bne     $t1, $t0, solve_skip_space

solve_left:
        beq     $s3, $zero, solve_top

        add     $a0, $s0, $zero                 # check validity of space
        addi    $a2, $s2, 0                     # left of this tree
        addi    $a3, $s3, -1
        jal     space_valid

        beq     $v0, $zero, solve_top           # space is invalid. v0 is 0
       
        li      $t0, TREE_LEFT
        sw      $t0, 0($s1)

        li      $t0, TENT
        la      $t1, board
        addi    $t2, $s2, 0                     # t2 = row of left space
        addi    $t3, $s3, -1                    # t3 = col of left space

        mul     $t4, $s0, $t2
        add     $t4, $t4, $t3
        mul     $t4, $t4, 4
        add     $t1, $t1, $t4                   # t1 points to left space
        sw      $t0, 0($t1)                     # put a tent in this space

        add     $a0, $s0, $zero                 # check if this tree is the
        add     $a1, $s2, $zero                 # last one.
        add     $a2, $s3, $zero
        jal     is_last_tree
        bne     $v0, $zero, solve_solution      # if space is valid and this
                                                # the last tree, then this is
                                                # the solution.

        add     $a0, $s0, $zero                 # make recursive call.
        add     $a1, $s2, $zero
        add     $a2, $s3, $zero
        jal     solve

        li      $t0, 2                          # if solution has been found,
        beq     $t0, $v0, solve_solution        # bubble back up!

        li      $t0, 1                          # shouldn't actually return 1
        beq     $t0, $v0, solve_top

        li      $t0, 0
        beq     $t0, $v0, solve_left_dead_end
        j       solve_invalid

solve_left_dead_end:
        li      $t0, TREE_EMPTY                 # reset tree to empty
        sw      $t0, 0($s1)

        addi    $t2, $s2, 0
        addi    $t3, $s3, -1

        mul     $t4, $t2, $s0
        add     $t4, $t4, $t3
        mul     $t4, $t4, 4
        la      $t1, board
        add     $t1, $t1, $t4                   # t1 points to left space

        li      $t0, EMPTY_SPACE                # remove tent from left space
        sw      $t0, 0($t1)

solve_top:
        beq     $s2, $zero, solve_right

        add     $a0, $s0, $zero                 # check validity of space
        add     $a2, $s2, -1                    # left of this tree
        addi    $a3, $s3, 0
        jal     space_valid

        beq     $v0, $zero, solve_right         # space is invalid. v0 is 0

        li      $t0, TREE_TOP                   # PLACE THE TENT
        sw      $t0, 0($s1)                     # reassign tree

        li      $t0, TENT
        la      $t1, board
        addi    $t2, $s2, -1                    # t2 = row of top space
        addi    $t3, $s3, 0                     # t3 = col of top space

        mul     $t4, $s0, $t2
        add     $t4, $t4, $t3
        mul     $t4, $t4, 4
        add     $t1, $t1, $t4                   # t1 points to top space
        sw      $t0, 0($t1)                     # put a tent in this space

        add     $a0, $s0, $zero                 # check if this tree is the
        add     $a1, $s2, $zero                 # last one.
        add     $a2, $s3, $zero
        jal     is_last_tree
        bne     $v0, $zero, solve_solution      # if space is valid and this
                                                # the last tree, then this is
                                                # the solution.

        add     $a0, $s0, $zero                 # make recursive call.
        add     $a1, $s2, $zero
        add     $a2, $s3, $zero
        jal     solve

        li      $t0, 2                          # if solution has been found,
        beq     $t0, $v0, solve_solution        # bubble back up!

        li      $t0, 1                          # shouldn't actually return 1
        beq     $t0, $v0, solve_right

        li      $t0, 0                          # recursive calls from this
        beq     $t0, $v0, solve_top_dead_end    # position had no solution

        j       solve_invalid                   # some invalid code

solve_top_dead_end:
        li      $t0, TREE_EMPTY                 # reset tree to empty
        sw      $t0, 0($s1)

        la      $t1, board
        addi    $t2, $s2, -1
        addi    $t3, $s3, 0

        mul     $t4, $t2, $s0
        add     $t4, $t4, $t3
        mul     $t4, $t4, 4
        add     $t1, $t1, $t4                   # t1 points to left space

        li      $t0, EMPTY_SPACE                # remove tent from left space
        sw      $t0, 0($t1)

solve_right:
        beq     $s3, $s0, solve_bottom
        add     $a0, $s0, $zero                 # check validity of space
        addi    $a2, $s2, 0                     # right of this tree
        addi    $a3, $s3, 1
        jal     space_valid
        beq     $v0, $zero, solve_bottom        # space is invalid. v0 is 0

        li      $t0, TREE_RIGHT                 # PLACE THE TENT
        sw      $t0, 0($s1)                     # reassign tree

        li      $t0, TENT
        la      $t1, board
        addi    $t2, $s2, 0                     # t2 = row of right space
        addi    $t3, $s3, 1                     # t3 = col of right space

        mul     $t4, $s0, $t2
        add     $t4, $t4, $t3
        mul     $t4, $t4, 4
        add     $t1, $t1, $t4                   # t1 points to right space
        sw      $t0, 0($t1)                     # put a tent in this space

        add     $a0, $s0, $zero                 # check if this tree is the
        add     $a1, $s2, $zero                 # last one.
        add     $a2, $s3, $zero
        jal     is_last_tree
        bne     $v0, $zero, solve_solution      # if space is valid and this
                                                # the last tree, then this is
                                                # the solution.

        add     $a0, $s0, $zero                 # make recursive call.
        add     $a1, $s2, $zero
        add     $a2, $s3, $zero
        jal     solve

        li      $t0, 2                          # if solution has been found,
        beq     $t0, $v0, solve_solution        # bubble back up!

        li      $t0, 1                          # shouldn't actually return 1
        beq     $t0, $v0, solve_bottom

        li      $t0, 0                          # recursive calls from this
        beq     $t0, $v0, solve_right_dead_end  # position had no solution

        j       solve_invalid                   # some invalid code

solve_right_dead_end:
        li      $t0, TREE_EMPTY                 # reset tree to empty
        sw      $t0, 0($s1)

        la      $t1, board
        addi    $t2, $s2, 0
        addi    $t3, $s3, 1

        mul     $t4, $t2, $s0
        add     $t4, $t4, $t3
        mul     $t4, $t4, 4
        add     $t1, $t1, $t4                   # t1 points to left space

        li      $t0, EMPTY_SPACE                # remove tent from left space
        sw      $t0, 0($t1)

solve_bottom:
        beq     $s2, $s0, solve_invalid         # all directions failed

        add     $a0, $s0, $zero                 # check validity of space
        addi    $a2, $s2, 1                     # right of this tree
        addi    $a3, $s3, 0
        jal     space_valid
        add     $t0, $v0, $zero
        beq     $v0, $zero, solve_invalid       # space is invalid. v0 is 0

        li      $t0, TREE_BOT                   # PLACE THE TENT
        sw      $t0, 0($s1)                     # reassign tree

        li      $t0, TENT
        la      $t1, board
        addi    $t2, $s2, 1                     # t2 = row of right space
        addi    $t3, $s3, 0                     # t3 = col of right space

        mul     $t4, $s0, $t2
        add     $t4, $t4, $t3
        mul     $t4, $t4, 4
        add     $t1, $t1, $t4                   # t1 points to right space
        sw      $t0, 0($t1)                     # put a tent in this space

        add     $a0, $s0, $zero                 # check if this tree is the
        add     $a1, $s2, $zero                 # last one.
        add     $a2, $s3, $zero
        jal     is_last_tree
        bne     $v0, $zero, solve_solution      # if space is valid and this
                                                # the last tree, then this is
                                                # the solution.

        add     $a0, $s0, $zero                 # make recursive call.
        add     $a1, $s2, $zero
        add     $a2, $s3, $zero
        jal     solve

        li      $t0, 2                          # if solution has been found,
        beq     $t0, $v0, solve_solution        # bubble back up!

        li      $t0, 1                          # shouldn't actually return 1
        beq     $t0, $v0, solve_invalid

        li      $t0, 0                          # recursive calls from this
        beq     $t0, $v0, solve_bottom_dead_end # position had no solution

        j       solve_invalid                   # some invalid code

solve_bottom_dead_end:
        li      $t0, TREE_EMPTY                 # reset tree to empty
        sw      $t0, 0($s1)

        la      $t1, board
        addi    $t2, $s2, 1
        addi    $t3, $s3, 0

        mul     $t4, $t2, $s0
        add     $t4, $t4, $t3
        mul     $t4, $t4, 4
        add     $t1, $t1, $t4                   # t1 points to left space

        li      $t0, EMPTY_SPACE                # remove tent from left space
        sw      $t0, 0($t1)

        j       solve_invalid                   # all 4 directions could not
                                                # find a solution

solve_skip_space:

        addi    $s3, $s3, 1                     # incr col
        addi    $s1, $s1, 4                     # incr pointer in board
        j       solve_loop2

solve_done2:
        li      $s3, 0                          # reset col idx to 0
        addi    $s2, $s2, 1                     # incr row
        j       solve_loop1

solve_solution:
        li      $v0, 2
        j       solve_done

solve_valid:
        li      $v0, 1
        j       solve_done

solve_invalid:
        li      $v0, 0
        j       solve_done

solve_done:
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

	jr	$ra				# return from main and exit


#------------------

# Name:         space_valid
#
# Description:  Given a board and the coordinates of a space, check if a tent
#               can be placed. If yes, place the tent onto the board and return
#               1. If no, do not place the tent / remove the tent at this space
#               and return 0.
#
# Parameters:   a0: boardSize
#               a1: pointer to board
#               a2: row coordinate
#               a3: col coordinate
#
# Returns:      0 if a tent cannot be placed at this space
#               1 if a tent can be placed at this space
space_valid:
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
        
        li      $v0, 1
        add     $s0, $a0, $zero                 # s0 = boardSize
        la      $s1, board                      # s1 = pointer to board
        add     $s2, $a2, $zero                 # s2 = row number
        add     $s3, $a3, $zero                 # s3 = col number
        la      $s4, rowMax                     # s4 = pointer to rowMax
        la      $s5, colMax                     # s5 = pointer to colMax

        mul     $t0, $s2, 4
        add     $s4, $s4, $t0
        mul     $t0, $s3, 4
        add     $s5, $s5, $t0

        mul     $t0, $s2, $s0
        add     $t0, $t0, $s3
        mul     $t0, $t0, 4
        add     $s1, $s1, $t0                   # s1 points to this space

        lw      $t0, 0($s1)                     # item at current location
        li      $t1, EMPTY_SPACE                # must be EMPTY_SPACE
        bne     $t0, $t1, space_valid_false

        add     $a0, $s0, $zero                 # get current number of tents
        add     $a1, $s2, $zero                 # in this row/col
        add     $a2, $s3, $zero
        jal     rowcol_amt

        lw      $t0, 0($s4)                     # cannot >= max
        slt     $t1, $v0, $t0
        beq     $t1, $zero, space_valid_false

        lw      $t0, 0($s5)                     # cannot >= max
        slt     $t1, $v1, $t0
        beq     $t1, $zero, space_valid_false
        li      $v0, 1                          # set v0 back to prev

                                                # check adjacent (all 8 
                                                # directions, including 
                                                # diagonals) for another tent
space_valid_1_1:
        beq     $s2, $zero, space_valid_2_1
        beq     $s3, $zero, space_valid_1_2
        la      $t0, board
        
        la      $t1, board
        addi    $t2, $s2, -1
        addi    $t3, $s3, -1

        mul     $t4, $t2, $s0                   # move pointer to this space
        add     $t4, $t4, $t3
        mul     $t4, $t4, 4
        add     $t1, $t1, $t4
        
        lw      $t4, 0($t1)
        li      $t5, TENT
        beq     $t4, $t5, space_valid_false

space_valid_1_2:
        la      $t1, board
        addi    $t2, $s2, -1
        addi    $t3, $s3, 0

        mul     $t4, $t2, $s0                   # move pointer to this space
        add     $t4, $t4, $t3
        mul     $t4, $t4, 4
        add     $t1, $t1, $t4
        
        lw      $t4, 0($t1)
        li      $t5, TENT
        beq     $t4, $t5, space_valid_false

space_valid_1_3:
        beq     $s3, $s0, space_valid_2_1

        la      $t1, board
        addi    $t2, $s2, -1
        addi    $t3, $s3, 1

        mul     $t4, $t2, $s0                   # move pointer to this space
        add     $t4, $t4, $t3
        mul     $t4, $t4, 4
        add     $t1, $t1, $t4

        lw      $t4, 0($t1)
        li      $t5, TENT
        beq     $t4, $t5, space_valid_false

space_valid_2_1:
        beq     $s3, $zero, space_valid_2_3

        la      $t1, board
        addi    $t2, $s2, 0
        addi    $t3, $s3, -1

        mul     $t4, $t2, $s0                   # move pointer to this space
        add     $t4, $t4, $t3
        mul     $t4, $t4, 4
        add     $t1, $t1, $t4

        lw      $t4, 0($t1)
        li      $t5, TENT
        beq     $t4, $t5, space_valid_false

space_valid_2_3:
        beq     $s3, $s0, space_valid_3_1

        la      $t1, board
        addi    $t2, $s2, 0
        addi    $t3, $s3, 1

        mul     $t4, $t2, $s0                   # move pointer to this space
        add     $t4, $t4, $t3
        mul     $t4, $t4, 4
        add     $t1, $t1, $t4
        
        lw      $t4, 0($t1)
        li      $t5, TENT
        beq     $t4, $t5, space_valid_false

space_valid_3_1:
        beq     $s2, $s0, space_valid_done
        beq     $s3, $zero, space_valid_3_2

        la      $t1, board
        addi    $t2, $s2, 1
        addi    $t3, $s3, -1

        mul     $t4, $t2, $s0                   # move pointer to this space
        add     $t4, $t4, $t3
        mul     $t4, $t4, 4
        add     $t1, $t1, $t4
        
        lw      $t4, 0($t1)
        li      $t5, TENT
        beq     $t4, $t5, space_valid_false

space_valid_3_2:

        la      $t1, board
        addi    $t2, $s2, 1
        addi    $t3, $s3, 0

        mul     $t4, $t2, $s0                   # move pointer to this space
        add     $t4, $t4, $t3
        mul     $t4, $t4, 4
        add     $t1, $t1, $t4
        
        lw      $t4, 0($t1)
        li      $t5, TENT
        beq     $t4, $t5, space_valid_false

space_valid_3_3:
        beq     $s3, $s0, space_valid_done

        la      $t1, board
        addi    $t2, $s2, 1
        addi    $t3, $s3, 1

        mul     $t4, $t2, $s0                   # move pointer to this space
        add     $t4, $t4, $t3
        mul     $t4, $t4, 4
        add     $t1, $t1, $t4
        
        lw      $t4, 0($t1)
        li      $t5, TENT
        beq     $t4, $t5, space_valid_false

        j       space_valid_done                # all tests pass!

space_valid_false:
        li      $v0, 0

space_valid_done:
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

	jr	$ra				# return from main and exit

#------------------

#
# Name:         is_last_tree
#
# Description:  Iterates from the location of this tree
#               to the end of the board. Returns whether
#               or not this is the last tree on the board.
#
# Parameters:   a0: boardsize
#               a1: row of this tree
#               a2: col of this tree
#
# Returns:      0 if this is NOT the last tree (another tree was found)
#               1 if no future trees were found
is_last_tree:
        addi    $sp, $sp, -8                    # allocate sp
        sw      $ra, 0($sp)                     # store return addr

        add     $t0, $a0, $zero                 # t0 = boardSize
        la      $t1, board                      # t1 = pointer to board
        add     $t2, $a1, $zero                 # t2 = row to start at
        add     $t3, $a2, $zero                 # t3 = col to start at
        
        mul     $t4, $t2, $t0
        add     $t4, $t4, $t3                   # t4 = cur idx in board array

        mul     $t5, $t4, 4
        add     $t1, $t5                        # t1 now points to cur idx

        mul     $t5, $t0, $t0                   # t5 = total idx in board

        addi    $t4, $t4, 1                     # move 1 ahead of the tree
        addi    $t1, $t1, 4
        li      $v0, 1

is_last_tree_loop:
        slt     $t6, $t4, $t5
        beq     $t6, $zero, is_last_tree_done

        lw      $t6, 0($t1)
        li      $t7, TREE_EMPTY
        beq     $t6, $t7, is_last_tree_false

        li      $t7, TREE_TOP
        beq     $t6, $t7, is_last_tree_false

        li      $t7, TREE_LEFT
        beq     $t6, $t7, is_last_tree_false

        li      $t7, TREE_BOT
        beq     $t6, $t7, is_last_tree_false

        li      $t7, TREE_RIGHT
        beq     $t6, $t7, is_last_tree_false

        addi    $t4, $t4, 1
        addi    $t1, $t1, 4
        j       is_last_tree_loop

is_last_tree_false:
        li      $v0, 0

is_last_tree_done:
        lw      $ra, 0($sp)                     # restore ra
        addi    $sp, $sp, 8                     # move stack ptr back
        jr      $ra                             # return

#------------------

#
# Name:         rowcol_amt
#
# Description:  Given a certain coordinate on the board,
#               find the existing amount of tents in this
#               row and column.
#
# Parameters:   a0: boardSize
#               a1: row number
#               a2: col number
#
# Returns:      v0: number of tents in this row
#               v1: number of tents in this column
rowcol_amt:
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

        add     $s0, $a0, $zero                 # s0 = boardSize
        la      $s1, board                      # s1 = pointer to board
        add     $s2, $a1, $zero                 # s2 = row index (of board)
        add     $s3, $a2, $zero                 # s3 = col index (of board)

        add     $v0, $zero, $zero               # v0 = amt in this row
        add     $v1, $zero, $zero               # v1 = amt in this col

        mul     $t0, $s2, $s0                   # point to beginning of this row
        mul     $t0, $t0, 4
        add     $s1, $s1, $t0

        li      $t1, 0                          # t1 = counter
rowcol_amt_row_loop:
        slt     $t0, $t1, $s0
        beq     $t0, $zero, rowcol_amt_row_done

        lw      $t2, 0($s1)
        li      $t3, TENT

        bne     $t2, $t3, rowcol_amt_no_tent_row
        add     $v0, $v0, 1

rowcol_amt_no_tent_row:
        addi    $t1, $t1, 1
        add     $s1, $s1, 4
        j       rowcol_amt_row_loop

rowcol_amt_row_done:
        la      $s1, board                      # point back to board[0][0]
        mul     $t0, $s3, 4                     # point to top of this col
        add     $s1, $t0, $s1

        li      $t1, 0                          # t1 = counter

rowcol_amt_col_loop:
        slt     $t0, $t1, $s0
        beq     $t0, $zero, rowcol_amt_col_done

        lw      $t2, 0($s1)
        li      $t3, TENT
        
        bne     $t2, $t3, rowcol_amt_no_tent_col
        add     $v1, $v1, 1

rowcol_amt_no_tent_col:
        addi    $t1, $t1, 1
        mul     $t0, $s0, 4
        add     $s1, $s1, $t0
        j       rowcol_amt_col_loop

rowcol_amt_col_done:
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

	jr	$ra				# return from main and exit

#------------------

#
# Name:         populate_board
#
# Description:  Does some syscalls. Takes each line, validates the 
#               characters, and puts corresponding numbers into the 
#
# Parameters:   a0: boardSize
#               a1: pointer to board
#
# Returns:      0 if the board is populated successfully
#               1 if there is an error in populating the board
populate_board:
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

        add     $s7, $zero, $zero               # s7 = return value

        add     $s0, $a0, $zero                 # s0 = boardSize
        add     $s1, $a1, $zero                 # move a1 to s1
        add     $t0, $zero, $zero               # t0 = row counter
        add     $t1, $zero, $zero               # t1 = col counter

populate_board_loop1:
        slt     $t2, $s4, $s0
        beq     $t2, $zero, populate_board_done1# done looping through board #+

        li      $a0, MAX_BUFFER_SIZE            # initialize buffer
        la      $a1, buffer
        jal     initialize_bytes
        
        la      $s2, buffer                     # s2 = pointer to buffer

        li      $v0, READ_STRING                # read the line for the
        la      $a0, buffer                     # board characters
        li      $a1, MAX_BUFFER_SIZE
        syscall

        li      $a0, MAX_BUFFER_SIZE            # check strlen for any
        la      $a1, buffer                     # lines with bad length
        jal     strlen
        
        addi    $v0, $v0, -1                    # subtract 1 for newline char
        bne     $v0, $s0, populate_board_err    # line was bad length

populate_board_loop2:
        slt     $t2, $s5, $s0
        beq     $t2, $zero, populate_board_done2# finished reading line

        lbu     $s3, 0($s2)                     # get item in buffer

        li    $t9, TREE_CHAR                    # t9 = dec value for T
        li    $t8, EMPTY_SPACE_CHAR             # t8 = dec value for .

                                                # place grass or tree onto the
                                                # board accordingly
        beq     $s3, $t9, populate_board_content_tree
        beq     $s3, $t8, populate_board_content_grass

        j       populate_board_err              # it was not a tree OR grass
                                                # (invalid)

populate_board_content_tree:
        li      $t3, TREE_EMPTY                 # place an empty tree
        sw      $t3, 0($s1)                     # onto the board space
        j       populate_board_content_done

populate_board_content_grass:
        li      $t3, EMPTY_SPACE                # place grass onto a 
        sw      $t3, 0($s1)                     # board space
        j       populate_board_content_done

populate_board_content_done:
        addi    $s5, $s5, 1
        addi    $s2, $s2, 1                     # move forward in buffer
        addi    $s1, $s1, 4                     # move forward in board
        j       populate_board_loop2

populate_board_done2:
        add     $s5, $zero, $zero               # reset col counter
        addi    $s4, $s4, 1                     # incr. row
        j       populate_board_loop1

populate_board_err:
        la      $a0, error_msg_illegal_char     # print error message
        li      $v0, PRINT_STRING
        syscall

        addi    $s7, $s7, 1                     # return error code

populate_board_done1:
        addi    $v0, $s7, 0                     # move s7 to v0 for return

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

	jr	$ra				# return from main and exit
#------------------


#
# Name:         print_board
#
# Description:  Print the contents of the board.
#               Prints the board border, contents, and row/col capacities.
#
# Parameters:   a0: boardSize
#               a1: pointer to board
#               a2: pointer to rowMax
#               a3: pointer to colMax
#
# Returns:      None
#
print_board:
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

        add     $s0, $a0, $zero                 # s0 = boardSize

        li      $v0, PRINT_STRING               # print first unit of border
        la      $a0, board_border_unit_beg
        syscall

        add     $s1, $zero, $zero

print_board_border_loop:
        beq     $s1, $s0, print_board_border_done

        li      $v0, PRINT_STRING               # print unit of border
        la      $a0, board_border_unit_mid
        syscall
       
        addi    $s1, $s1, 1
        j       print_board_border_loop

print_board_border_done:
        li      $v0, PRINT_STRING               # print last unit of border
        la      $a0, board_border_unit_end
        syscall

#---
        la      $s1, board                      # s1 = pointer to board
        add     $s2, $zero, $zero               # idx of rows
        add     $s3, $zero, $zero               # idx of cols

print_board_loop:
        slt     $t0, $s2, $s0                   # stop looping when you run out
        beq     $t0, $zero, print_board_done    # of rows

        li      $v0, PRINT_STRING               # print side of board
        la      $a0, board_contents_side
        syscall

print_board_loop2:
        slt     $t0, $s3, $s0                   # stop looping when you run out
        beq     $t0, $zero, print_board_done2   # of columns

        # print stuff here
        li      $v0, PRINT_CHAR
        
        add     $t1, $zero, $zero               # 0 is not valid
        lw      $s4, 0($s1)
        beq     $t1, $s4, print_board_err

        # check if character is grass
        li      $t1, EMPTY_SPACE
        beq     $t1, $s4, print_board_content_grass

        # check if character is a tree
        li      $t1, TREE_EMPTY
        beq     $t1, $s4, print_board_content_tree

        li      $t1, TREE_TOP
        beq     $t1, $s4, print_board_content_tree

        li      $t1, TREE_LEFT
        beq     $t1, $s4, print_board_content_tree

        li      $t1, TREE_RIGHT
        beq     $t1, $s4, print_board_content_tree
        
        li      $t1, TREE_LEFT
        beq     $t1, $s4, print_board_content_tree

        # check if character is a tent
        li      $t1, TENT
        beq     $t1, $s4, print_board_content_tent

        j       print_board_content_tree

        li      $v0, PRINT_INT
        add     $a0, $s4, $zero
        syscall
        
print_board_content_grass:
        li      $a0, EMPTY_SPACE_CHAR
        j       print_board_content_done

print_board_content_tree:
        li      $a0, TREE_CHAR
        j       print_board_content_done

print_board_content_tent:
        li      $a0, TENT_CHAR
        j       print_board_content_done

print_board_content_done:
        syscall

        li      $v0, PRINT_CHAR
        li      $a0, SPACE_CHAR                 # print space
        syscall

        addi    $s1, $s1, 4                     # increment board
        addi    $s3, $s3, 1                     # also counter
        j       print_board_loop2

print_board_done2:

        # print newline and end border here
        li      $v0, PRINT_STRING               # print side of board
        la      $a0, board_contents_side
        syscall
 
        lw      $a0, 0($a2)                     # print num in row
        li      $v0, PRINT_INT
        syscall

        li      $v0, PRINT_CHAR
        li      $a0, NEWLINE_CHAR               # print newline
        syscall

        add     $s3, $zero, $zero               # reset col iterator
        addi    $s2, $s2, 1                     # increment row
        addi    $a2, $a2, 4                     # increment place in rowMax
        j       print_board_loop

#--------

print_board_done:
        li      $v0, PRINT_STRING
        la      $a0, board_border_unit_beg
        syscall

        add     $s1, $zero, $zero

print_board_border_loop2:
        beq     $s1, $s0, print_board_border_done2

        li      $v0, PRINT_STRING               # print unit of border
        la      $a0, board_border_unit_mid
        syscall

        addi    $s1, $s1, 1
        j       print_board_border_loop2

print_board_border_done2:
        li      $v0, PRINT_STRING               # print last unit of border
        la      $a0, board_border_unit_end
        syscall

#--------

        li      $s1, 0

        li      $v0, PRINT_CHAR
        li      $a0, SPACE_CHAR
        syscall


print_board_col_nums:                           # print col capacities
        beq     $s1, $s0, print_board_col_nums_done

        li      $v0, PRINT_CHAR
        li      $a0, SPACE_CHAR
        syscall

        li      $v0, PRINT_INT
        lw      $a0, 0($a3)
        syscall

        addi    $a3, $a3, 4
        addi    $s1, $s1, 1
        j       print_board_col_nums

print_board_col_nums_done:                      # print newline char at the end
        li      $v0, PRINT_CHAR
        li      $a0, NEWLINE_CHAR
        syscall

print_board_success:                            # everything went smoothly
        add     $v0, $zero, $zero
        j       print_board_exit

print_board_err:
        li      $v0, PRINT_STRING
        la      $a0, error_msg_illegal_char
        syscall
        add     $v0, $zero, 1                   # 1 = error code

print_board_exit:
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

	jr	$ra				# return from main and exit
#------------------


#
# Name:         strlen
#
# Description:  Gets the length of a string
#
# Arguments:    a0 : length of buffer
#               a1 : pointer to beginning of string
#
# Returns:      length of string
#               returns -1 if the string is not nul terminated
#
strlen:
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
        
        add     $s1, $a1, $zero                 # s1 is the addr of the string
        add     $v0, $zero, $zero
        add     $t0, $zero, $zero
        add     $t1, $zero, $zero

strlen_loop:
        beq     $a0, $t0, strlen_done           # finished reading string
        lb      $s0, 0($s1)                     # get value at a1
        beq     $s0, $zero, strlen_nul_read     # nul char is read
        j       strlen_nul_not_read             # nul char is not read

strlen_nul_read:
        addi    $t0, $t0, 1
        j       strlen_done

strlen_nul_not_read:
        addi    $v0, $v0, 1                     # increment
        addi    $s1, $s1, 1
        addi    $t1, $t1, 1
        j       strlen_loop

strlen_done:
        bne     $t0, $zero, strlen_exit
        addi    $v0, $zero, -1

strlen_exit:
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
#------------------

#
# Name:         initialize_words
#
# Description:  Initialize a certain amount of words to 0
#
# Parameters:   a0: number of words to initialize
#               a1: pointer to beginning of space
#
# Returns:      None
#
initialize_words:
        addi    $sp, $sp, -8                    # allocate sp
        sw      $ra, 0($sp)                     # store return addr

        add     $t0, $zero, $zero

initialize_words_loop:
        beq     $t0, $a0, initialize_words_done
        sw      $zero, 0($a1)
        addi    $t0, $t0, 1
        addi    $a1, $a1, 4
        j       initialize_words_loop

initialize_words_done:
        lw      $ra, 0($sp)                     # restore ra
        addi    $sp, $sp, 8                     # move stack ptr back
        jr      $ra                             # return
#------------------

#
# Name:         initialize_bytes
#
# Description:  Initialize a certain amount of bytes to 0
#
# Parameters:   a0: number of words to initialize
#               a1: pointer to beginning of space
#
# Returns:      None
#
initialize_bytes:
        addi    $sp, $sp, -8                    # allocate sp
        sw      $ra, 0($sp)                     # store return addr

        add     $t0, $zero, $zero

initialize_bytes_loop:
        beq     $t0, $a0, initialize_bytes_done
        sb      $zero, 0($a1)
        addi    $t0, $t0, 1
        addi    $a1, $a1, 1
        j       initialize_bytes_loop

initialize_bytes_done:
        lw      $ra, 0($sp)                     # restore ra
        addi    $sp, $sp, 8                     # move stack ptr back
        jr      $ra                             # return
#------------------

#
# Name:         populate_max_sums
#
# Description:  Populates a 1D array with digits from stdin. This
#               is used for finding the max tent capacities for 
#               each row and column.
#
# Parameters:   a0: boardSize (size of the board)
#               a1: pointer to first thing in array
#
# Returns:      0 if array has been populated successfully
#               1 if an error occured somewhere in this function
#
populate_max_sums:
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

        add     $v0, $zero, $zero
        addi    $s1, $a0, 1                     # s1 = max sum.
        li      $t0, 2                          # (a0 + 1) / 2
        div     $s1, $t0
        mflo    $s1
        
        add     $s2, $a1, $zero                 # s2 = index of a1
        add     $s0, $zero, $a0                 # s0 = boardSize
         
        li      $a0, MAX_BUFFER_SIZE            # check strlen for any
        la      $a1, buffer                     # sums >= 10
        jal     strlen
        
        addi    $v0, $v0, -1                    # subtract 1 for newline
        bne     $v0, $s0, populate_max_sums_err # there was a sum >= 10

        add     $v0, $zero, $zero               # success by default        
        add     $t0, $zero, $zero               # counts through array

populate_max_sums_loop:
        beq     $t0, $s0, populate_max_sums_done
        lb      $t1, 0($a1)                     # t1 = number at index
        addi    $t1, $t1, -48                   # in buffer
        slt     $t2, $s1, $t1
                                                # if any of the digits are
                                                # bigger than they should be,
                                                # error.
        bne     $t2, $zero, populate_max_sums_err
        sw      $t1, 0($s2)                     # store in specified array
        add     $s2, $s2, 4
        add     $t0, $t0, 1
        add     $a1, $a1, 1
        j       populate_max_sums_loop

populate_max_sums_err:
        la      $a0, error_msg_illegal_sum      # print error message
        li      $v0, PRINT_STRING
        syscall

        addi     $v0, $zero, 1                  # v0 = error code

populate_max_sums_done:
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
#------------------

#
# Name:         validate_boardsize
#
# Description:  Makes sure that the size of the board that is inputted
#               is a valid one. The boardsize must be >= 2 AND <= 12.
#               If boardsize is invalid, print error message and return 1.
#
# Parameters:   a0: boardSize
#
# Returns:      0 if boardSize is valid
#               1 if boardsize is not valid
#
validate_boardsize:
        addi    $sp, $sp, -8
        sw      $ra, 0($sp)

        li      $v0, 0                          # true by default

        li      $t0, MIN_BOARD_SIZE
        li      $t1, MAX_BOARD_SIZE
        
        slt     $t2, $a0, $t0                   # check that a0 >= 2
        bne     $t2, $zero, validate_boardsize_false
        slt     $t2, $t1, $a0                   # check that a0 <= 12
        bne     $t2, $zero, validate_boardsize_false

        j       validate_boardsize_done         # both checks passed

validate_boardsize_false:
        la      $a0, error_msg_board_size       # print error message
        li      $v0, PRINT_STRING
        syscall

        addi    $v0, $zero, 1                   # return 1 for error

validate_boardsize_done:
        lw      $ra, 0($sp)
        addi    $sp, $sp, 8
        jr      $ra


###############################################################################

