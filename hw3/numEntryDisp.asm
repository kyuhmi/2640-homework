#########################################################################################################################
# Program: numEntryDisp                         Programmer: Kyung Ho Min
# Due Date: Oct 11, 2022                        Course: CS2640
#########################################################################################################################
# Overall Program Functional Description:
#   The program asks the user to enter 20 integers and will store them to an array.
#   Then, it will print the numbers the user entered line by line and on one line delimited by spaces.
#   It will ask the user to enter some integer n, and will then print all the sequential subarrays of
#   length n. (Note that if n > 20, there exists no subarray of that length)
#########################################################################################################################
# Register usage in Main:
#   $a1, $a2, $v0 - used to pass values into subroutines
#########################################################################################################################
# Pseudocode Description:
#     1. Call subroutine to load the array with integers.
#     2. Call the printNumsNL subroutine to print numbers of array on each line (elements 1-20).
#     3. Call the printNums subroutine to print numbers of array on a single line delimited by spaces (elements 1-20).
#     4. Call the printSubsetN subroutine to print out all the sequential subsets of the array of length n.
#     5. Terminate the program
#########################################################################################################################

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

#########################################################################################################################
# Function Name: loadArray()
#########################################################################################################################
# Functional Description:
#   Loads the array in memory with 20 integers which are entered by the user.
#########################################################################################################################
# Register Usage in the Function:
#     $v0 - used for syscalls and returns from syscalls
#     $a0 - used for passing things to syscall
#     $t0, $t1 - temporary values to store (loop counter and array address)
#########################################################################################################################
# Algoritmic Description in Pseudocode:
#     1. Load coutner for loop into $t0
#     2. Load array address into $t1
#     3. While loop counter
#     4. Print prompt1 to the user
#     5. While $t0 != 0
#         a. Print prompt 2
#         b. Get data from user and store it at array pointer
#         c. increment array pointer by 4 and decrement $t0 counter
#     6. Return
#########################################################################################################################

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

#########################################################################################################################
# Function Name: printNumsNL(int beginningIndex, int endIndex)
#########################################################################################################################
# Functional Description:
#     Prints the elements of the array starting from beginningIndex and ending at endIndex delimited by "\n" 
#     (NOTE: index starts at 1)
#########################################################################################################################
# Register Usage in the Function:
#     $t1, $t5, $t6 - temporary values for function operation
#     LO - for multiplication when calculating offset for beginning array iteration
#     $a1, $a2 - input values for function (beginningIndex and endIndex)
#     $v0 - used with syscalls
#     $ra - return address
#########################################################################################################################
# Algoritmic Description in Pseudocode:
#     1. load array pointer to $t1
#     2. Calculate array offset given beginning index (offset = 4*(beginningIndex - 1)), store in $t5
#         a. $t5 = -1
#         b. $t5 = $t5 + $a1 (beginning index)
#         c. $t6 = 4
#         d. LO = $t6 * $t5
#         e. $t5 = LO
#     3. Add offset to array pointer ($t1 = $t1 + $t5)
#     4. if beginningIndex = endIndex, skip. else,
#         a. Get array element from current beginningIndex
#         b. Print the element to display
#         c. Print newline character
#         d. increment array pointer
#         e. increment first index
#     5. Finally
#         a. Get array element from current beginningIndex
#         b. Print the element to display
#         c. Print newline character
#     6. Return
#########################################################################################################################

printNumsNL:
    la      $t1,            arr                                 # load array pointer
    li      $t5,            -1                                  # initalize value to use to calculate memory offset required by beginning index
    add     $t5,            $t5,            $a1
    li      $t6,            4                                   # size of memory for integers
    mult    $t5,            $t6                                 # get amount of offset needed for array
    mflo    $t5                                                 # get product out of lo - this shouldn't exceed 80, so it won't go into hi
    addu    $t1,            $t1,            $t5                 # memory location + offset(which is 4*(firstIndex - 1))
printNLLoop:
    beq     $a1,            $a2,            lastIndexNL         # if they are equal, jump to last step.
    lw      $a0,            0($t1)                              # they are not equal, print nums until they are.
    li      $v0,            1
    syscall 
    la      $a0,            newline                             # printing newline
    li      $v0,            4
    syscall 
    addi    $t1,            $t1,            4                   # increment array pointer
    addi    $a1,            $a1,            1                   # increment first index
    j       printNLLoop                                         # loop
lastIndexNL:
    lw      $a0,            0($t1)                              # print last num followed by newline character
    li      $v0,            1
    syscall 
    la      $a0,            newline
    li      $v0,            4
    syscall 
    jr      $ra                                                 # return

#########################################################################################################################
# Function Name: printNums(int beginningIndex, int endIndex)
#########################################################################################################################
# Functional Description:
#     Prints the elements of the array starting from beginningIndex and ending at endIndex delimited by " "
#     Lastly prints a newline character to bring console to newline. 
#     (NOTE: index starts at 1)
#########################################################################################################################
# Register Usage in the Function:
#     $t1, $t5, $t6 - temporary values for function operation
#     LO - for multiplication when calculating offset for beginning array iteration
#     $a1, $a2 - input values for function (beginningIndex and endIndex)
#     $v0 - used with syscalls
#     $ra - return address
#########################################################################################################################
# Algoritmic Description in Pseudocode:
#     1. load array pointer to $t1
#     2. Calculate array offset given beginning index (offset = 4*(beginningIndex - 1)), store in $t5
#         a. $t5 = -1
#         b. $t5 = $t5 + $a1 (beginning index)
#         c. $t6 = 4
#         d. LO = $t6 * $t5
#         e. $t5 = LO
#     3. Add offset to array pointer ($t1 = $t1 + $t5)
#     4. if beginningIndex = endIndex, skip. else,
#         a. Get array element from current beginningIndex
#         b. Print the element to display
#         c. Print space character
#         d. increment array pointer
#         e. increment first index
#     5. Finally
#         a. Get array element from current beginningIndex
#         b. Print the element to display
#         c. Print newline character
#     6. Return
#########################################################################################################################

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

#########################################################################################################################
# Function Name: printSubsetN()
#########################################################################################################################
# Functional Description:
#     Prompts the user to enter an integer n. Then, it will print out all the sequential subarrays of length n
#     by calling the printNums function.
#########################################################################################################################
# Register Usage in the Function:
#     $a0 - used in syscalls
#     $v0 - used in syscalls
#     $t2, $t3, $t4 - temporary values for calculations for n
#     $ra - return address
#########################################################################################################################
# Algoritmic Description in Pseudocode:
#     1. Print prompt 3 to user
#     2. Get n from user, and then store it into $t3
#        a. if n <= 0, repeat the prompt until the user enters a valid number
#     3. Initialize beginning index as 1 into $t2
#     4. Initialize max index 20 into $t4
#     5. If beginning index is greater than max index, then jump to the end.
#     6. Loop:
#         a. put beginning index into $a0 and put n into $a1
#         b. call printNums
#         c. increment beginning index
#         d. increment end index
#         e. if n <= max index, then continue looping. else, break.
#     7. Return
#########################################################################################################################

printSubsetN:
    la      $a0,            prompt3                             # ask user to put in n
    li      $v0,            4
    syscall 
    li      $v0,            5                                   # get n from user
    syscall 
    blez    $v0,            printSubsetN                        # if number entered by user is <= 0, repeat the prompt.
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


















