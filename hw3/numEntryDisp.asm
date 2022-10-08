
.data
prompt1: .asciiz "Begin entering 20 integers: "
prompt2: .asciiz "Enter next integer: "
prompt3: .asciiz "Enter n (size of each subset of numbers to be printed out): "
newline: .asciiz "\n"
space: .asciiz " "
.align 2
arr: .space 80
.globl main

.text
main:
    jal     loadArray                                           # call loadArray
    li      $a1,            1                                   # load input values for printing 1 - 20
    li      $a2,            20
    jal     printNumsNL   
    li      $a1,            1                                   # load input values for printing 1 - 20
    li      $a2,            20
    jal     printNums                                           # call printNums
    jal     printSubsetN                                        # call printSubsetN
    li      $v0,            10                                  # exit program
    syscall 


loadArray:
    li      $t0,            20                                  # initialize counter for loop.
    li      $v0,            4                                   # prepare to print prompt 1 follow by newline
    la      $a0,            prompt1
    syscall 
    la      $a0,            newline
    syscall 
    la      $t1,            arr                                 # load array address into t1
    la      $a0,            prompt2                             # prepare for printing user prompt 2
loadArrayLp:
    beqz    $t0,            loadArrayEnd
    li      $v0,            4                                   # printing user prompt
    syscall 
    li      $v0,            5                                   # prepare to accept integer
    syscall 
    sw      $v0,            0($t1)                              # store data to memory
    addiu   $t1,            $t1,            4                   # increment pointer to array
    addi    $t0,            $t0,            -1                  # decrement loop counter
    j       loadArrayLp                                         # jump to loop
loadArrayEnd:
    jr      $ra                                                 # return


printNumsNL:
    la      $t1,            arr                                 # load array pointer
    li      $t5,            -1                                  # initalize value to use to calculate memory offset required by beginning index
    add     $t5,            $t5,            $a1
    li      $t6,            4                                   # size of memory for integers
    mult    $t5,            $t6                                 # get amount of offset needed for array
    mflo    $t5                                                 # get product out of lo - this shouldn't exceed 80, so it won't go into hi
    addu    $t1,            $t1,            $t5                 # memory location + offset(which is 4*(firstIndex - 1))
printNLLoop:
    beq     $a1,            $a2,            lastIndexNL           # if they are equal, jump to last step.
    lw      $a0,            0($t1)                              # they are not equal, print nums until they are.
    li      $v0,            1
    syscall 
    la      $a0,            newline                               # printing newline
    li      $v0,            4
    syscall 
    addi    $t1,            $t1,            4                   # increment array pointer
    addi    $a1,            $a1,            1                   # increment first index
    j       printNLLoop                                           # loop
lastIndexNL:
    lw      $a0,            0($t1)                              # print last num followed by newline character
    li      $v0,            1
    syscall 
    la      $a0,            newline
    li      $v0,            4
    syscall 
    jr      $ra                                                 # return

# input a1 = firstindex, a2 = endindex
printNums:
    la      $t1,            arr                                 # load array pointer
    li      $t5,            -1                                  # initalize value to use to calculate memory offset required by beginning index
    add     $t5,            $t5,            $a1
    li      $t6,            4                                   # size of memory for integers
    mult    $t5,            $t6                                 # get amount of offset needed for array
    mflo    $t5                                                 # get product out of lo - this shouldn't exceed 80, so it won't go into hi
    addu    $t1,            $t1,            $t5                 # memory location + offset(which is 4*(firstIndex - 1))
printLoop:
    beq     $a1,            $a2,            lastIndex           # if they are equal, jump to last step.
    lw      $a0,            0($t1)                              # they are not equal, print nums until they are.
    li      $v0,            1
    syscall 
    la      $a0,            space                               # printing space
    li      $v0,            4
    syscall 
    addi    $t1,            $t1,            4                   # increment array pointer
    addi    $a1,            $a1,            1                   # increment first index
    j       printLoop                                           # loop
lastIndex:
    lw      $a0,            0($t1)                              # print last num followed by newline character
    li      $v0,            1
    syscall 
    la      $a0,            newline
    li      $v0,            4
    syscall 
    jr      $ra                                                 # return


printSubsetN:
    la      $a0,            prompt3                             # ask user to put in n
    li      $v0,            4
    syscall 
    li      $v0,            5                                   # get n from user
    syscall 
    move    $t3,            $v0                                 # copy end index to t3 (end index = n)
    li      $t2,            1                                   # initialize beginning index
    li      $t4,            20                                  # store max possible index
    bgt     $t3,            $t4,            endSubset           # if the last index is greater than max, then there is no subarray to print.
printSubsetLoop:
    move    $a1,            $t2                                 # load beginning and end address to pass to print
    move    $a2,            $t3
    jal     printNums                                           # call printnums
    addi    $t2,            $t2,            1                   # increment beginning index
    addi    $t3,            $t3,            1                   # increment end index
    ble     $t3,            $t4,            printSubsetLoop     # check if we are past the last index. if we aren't, then continue looping.
endSubset:
    jr      $ra                                                 # return


















