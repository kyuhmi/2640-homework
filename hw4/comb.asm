#########################################################################################################################
# Program: comb                                 Programmer: Kyung Ho Min
# Due Date: Nov 8, 2022                         Course: CS2640
########################################################################################################################
# Overall Program Functional Description:
#   This program asks the user to put in values of n and r where n >= 0, r >=0, and n >= r.
#   (n and r are both integers.)
#   Then, the program will recursively calculate the value of comb(n, r) and will print the
#   output of this to the user.
#########################################################################################################################
# Register usage in Main:
#   $a0, $a2, $v0 - used to pass values into subroutines
#   $t0, $t1 - used to store values for n and r before calling subroutine
#########################################################################################################################
# Pseudocode Description:
#     1. Print prompt and get the value of n from the user (n >= 0)
#     2. Print prompt and get the value of r from the user (r >= 0 && n >= r)
#     3. Call subroutine combRec
#     4. Print output to user
#########################################################################################################################

.data
message1: .asciiz "Please enter a number for n: "
message2: .asciiz "Please enter a number for r: "
message3: .asciiz "Error: n > r. Try again. \n"
message4: .asciiz "Error: n < 0. Try again. \n"
message5: .asciiz "Error: r < 0. Try again. \n"
.align 2
.globl main

.text
main:
getn:
    la      $a0,        message1            # print prompt for n for the user
    li      $v0,        4
    syscall 
    li      $v0,        5                   # get int from user
    syscall 
    move    $t0,        $v0
    bgez    $t0,        getr                # n >= 0, we can move to getting r.
    la      $a0,        message4            # else print prompt 4 and ask user for int again.
    li      $v0,        4
    syscall 
    j       getn

getr:
    la      $a0,        message2            # print prompt for n for the user
    li      $v0,        4
    syscall 
    li      $v0,        5                   # get int from user
    syscall 
    move    $t1,        $v0
    bgez    $t1,        test2               # r >= 0, we can move to next test
    la      $a0,        message5            # else print prompt 4 and ask user for int again.
    li      $v0,        4
    syscall 
    j       getr
test2:
    bge     $t0,        $t1,        call    # n >= r, so we can move on.
    la      $a0,        message3            # else print prompt 3 and ask user for int again.
    li      $v0,        4
    syscall 
    j       getr
call:
    move    $a0,        $t0                 # load values for calling comb
    move    $a1,        $t1
    jal     combRec                         # call comb
    move    $a0,        $v0                 # printing result
    li      $v0,        1
    syscall 
    li      $v0,        10                  # exit
    syscall 


#########################################################################################################################
# Function Name: combRec(int n, int r)
#########################################################################################################################
# Functional Description:
#   Recursively caluclates the number of combinations of n items choosing r items.
#   The recursive formula used is Comb(n, r) = Comb(n-1, r) + Comb(n-1, r-1).
#########################################################################################################################
# Register Usage in the Function:
#     $v0 - used for syscalls and return values
#     $a0, $a1 - input values for the function, used for recursive calls too
#     $sp - stack pointer, we will store 4 words on the stack.
#     $ra - return address, must be recorded on the stack if there is further recursion. 
#########################################################################################################################
# Algoritmic Description in Pseudocode:
#     1. if (n == r || r == 0), return 1.
#     2. else, make space on the stack for 4 words
#     3. store $ra, n, and r on the stack. 
#     4. make recursive call of combRec(n-1, r), and then store its return value to the stack.
#     5. set up call for comb(n-1, r-1) by retrieving n and r from the stack, then call combRec.
#     6. get teh value of combRec(n-1, r) and add it to $v0, which has combRec(n-1, r-1)
#     7. return the value in v0, which is comb(n, r)
#########################################################################################################################

combRec:
    beq     $a0,        $a1,        base    # n == r, base case.
    beqz    $a1,        base                # r == 0, base case.
    j       recurse                         # else, follow recursive rule.
base:
    li      $v0,        1                   # return 1
    jr      $ra
recurse:
    addiu   $sp,        $sp,        -16     # make space for 4 words on the stack
    sw      $ra,        0($sp)              # store return address on stack
    sw      $a0,        4($sp)              # store n to the stack
    sw      $a1,        8($sp)              # store r to the stack
    addi    $a0,        $a0,        -1      # prepare for recursive call of comb(n-1, r)
    jal     combRec
    sw      $v0,        12($sp)             # store result to stack
    lw      $a0,        4($sp)              # load n again and decrement
    addi    $a0,        $a0,        -1
    lw      $a1,        8($sp)              # load r and decrement
    addi    $a1,        $a1,        -1
    jal     combRec                         # second recursive call for comb(n-1, r-1)
    lw      $t1,        12($sp)             # get value from first comb call
    add     $v0,        $v0,        $t1     # compute comb(n-1, r) + comb(n-1, r-1)
    lw      $ra,        0($sp)              # restore return address
    addiu   $sp,        $sp,        16      # restore stack pointer to original position
    jr      $ra                             # return







