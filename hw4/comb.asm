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
    jal     comb                            # call comb
    move    $a0,        $v0                 # printing result
    li      $v0,        1
    syscall 
    li      $v0,        10                  # exit
    syscall 

# a0 has n, a1 has r.
comb:
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
    jal     comb
    sw      $v0,        12($sp)             # store result to stack
    lw      $a0,        4($sp)              # load n again and decrement
    addi    $a0,        $a0,        -1
    lw      $a1,        8($sp)              # load r and decrement
    addi    $a1,        $a1,        -1
    jal     comb                            # second recursive call for comb(n-1, r-1)
    lw      $t1,        12($sp)             # get value from first comb call
    add     $v0,        $v0,        $t1     # compute comb(n-1, r) + comb(n-1, r-1)
    lw      $ra,        0($sp)              # restore return address
    addiu   $sp,        $sp,        16      # restore stack pointer to original position
    jr      $ra                             # return







