# #######################################################################
# Program: chuck (Chuck-A-Luck)				Programmer: Kyung Ho Min
# Due Date: Nov. 24th, 2022							Course: CS2640
# #######################################################################
# Overall Program Functional Description:
# The program plays the Chuck-A-Luck game.  The player starts with
# a purse of $500.  For each round, the player selects a wager, then
# picks a number from 1 to 6.  The program then rolls three dice.
# If none of the dice match the chosen number, the player loses the
# wager.  For each dice that matches the chosen number, the player
# earns the wager (so, for example, if two dice show the chosen number,
# the player earns twice the wager).  The program ends when the
# player enters a wager of 0.

# #######################################################################
# Register usage in Main:
# $v0, $a0, $a1 - registers used for subroutine calling and linkage
# $t3 - temporary register used to store address of balance
# $s0, $s1 - callee saved registers for storing temp values

# #######################################################################
# Pseudocode Description:
# 1. Print a welcome message
# 2. Get a value from the user, use it to seed the random number generator
# 3. Seed the player's holdings with 500.
# 4. Loop:
# a. Print their holdings, receive the wager.  If 0, break the loop.
# b. Get the chosen number for this round.
# c. call diceRoutine
# d. If the holdings get to 0, print a 'bye' message.
# 5. Clean up, print a 'bye' message, and leave.

# #######################################################################
.data
welcome: .asciiz "Welcome to Chuck-A-Luck!\n"
seedPrompt: .asciiz "Enter seed: "
goodbyeMSG: .asciiz "Goodbye!\n"
goodbyeOOMMSG: .asciiz "You have no money left. Goodbye!\n"
newLine: .asciiz "\n"
space: .asciiz " "
.align 2
balance: .word 500
.globl main
.text
main:
    li      $v0,            4                               # print welcome
    la      $a0,            welcome
    syscall 
    la      $a0,            seedPrompt                      # print seed prompt
    syscall 
    li      $v0,            5                               # get seed from user
    syscall 
    move    $a0,            $v0                             # prepare to call seeding function
    jal     seedrand

    li      $v0,            4                               # print newline
    la      $a0,            newLine
    syscall 

loop:
    la      $t3,            balance
    lw      $a0,            0($t3)                          # load balance into a0 for calling getwager
    beqz    $a0,            exitOOM                         # branch to exit if player has no money left.
    jal     getwager                                        # call getWager
    move    $s0,            $v0                             # store wager in s0
    beqz    $s0,            exit                            # if wager is 0, quit the program.
    jal     getguess                                        # call getguess
    move    $s1,            $v0                             # store guess in s1
    move    $a0,            $s0                             # prepare to call dice routine
    move    $a1,            $s1
    jal     diceRoutine
    j       loop
exit:
    li      $v0,            4                               # print goodbye
    la      $a0,            goodbyeMSG
    syscall 
    li      $v0,            10                              # exit program
    syscall 
exitOOM:
    li      $v0,            4                               # print goodbye (OOM)
    la      $a0,            goodbyeOOMMSG
    syscall 
    li      $v0,            10                              # exit program
    syscall 

# #######################################################################
# Function Name: void diceRoutine(int wager, int guess)
# #######################################################################
# Functional Description:
# read dice values and print them to the user.
# count matches, and update the user balance accordingly.
# 0 matches means you lose the wager.
# 1 match means you get 1x the wager.
# 2 matches means you get 2x the wager.
# 3 matches means you get 3x the wager.

# #######################################################################
# Register Usage in the Function:
# $a0 - the wager size
# $a1 - the guess
# $sp - stack pointer for storing values
# $t0, $t1, $t2, $t3, $t4, $t5 - temporary values for calculations

# #######################################################################
# Algorithmic Description in Pseudocode:
# 1. Make space for 4 items on the stack
# 2. Store ra, wagerSize, and guess to the stack, and initialize counter to 0.
# 3. Do the following 3 times:
#     a. push counter to stack
#     b. call rand()
#     c. retrieve counter from stack 
#     d. print the return from rand()
#     e. retrieve guess from stack
#     f. if guess matches the output of rand(), increment counter.
# 4. print the appropriate message for the number of matches
# 5. retrieve wager from stack and update balance accordingly to the number of matches.
#     a. 0 matches: decrease balance by wager
#     b. 1 match: increase balance by wager
#     c. 2 matches: increase balance by wager*2
#     d. 3 matches: increase balance by wager*3
# 6. retrieve $ra from stack, free up stack space
# 7. return.

# #######################################################################
.data
rollMsg: .asciiz "I roll: "
noMatchesMSG: .asciiz "You didn't match any!\n"
oneMatchMSG: .asciiz "You matched once.\n"
twoMatchesMSG: .asciiz "You matched twice!\n"
threeMatchesMSG: .asciiz "You matched thrice! Lucky you!\n"
.align 2
.text

diceRoutine:
    addiu   $sp,            $sp,                -16         # make stack space (rand does not use a0 and a1, so we don't have to save it)
    sw      $ra,            0($sp)                          # store return address to stack for subroutine calls
    sw      $a0,            4($sp)                          # store wager size to stack
    sw      $a1,            8($sp)                          # store dice guess to stack
    li      $t0,            0                               # initialize match counter

    li      $v0,            4                               # print I roll to user
    la      $a0,            rollMsg
    syscall 

    sw      $t0,            12($sp)                         # push counter to stack
    jal     rand                                            # get random value 1
    lw      $t0,            12($sp)                         # get counter from stack
    move    $t3,            $v0                             # store random value to t3 for calculations
    move    $a0,            $t3                             # get ready to print int to user
    li      $v0,            1                               # print int
    syscall 
    la      $a0,            space                           # print space
    li      $v0,            4
    syscall 
    lw      $t2,            8($sp)                          # restore dice guess from stack
    bne     $t3,            $t2,                skip1       # skip if equal
    addi    $t0,            $t0,                1           # increment counter because match
skip1:
    sw      $t0,            12($sp)                         # push counter to stack
    jal     rand                                            # get random value 2
    lw      $t0,            12($sp)                         # get counter from stack
    move    $t3,            $v0                             # store random value to t3 for calculations
    move    $a0,            $t3                             # get ready to print int to user
    li      $v0,            1                               # print int
    syscall 
    la      $a0,            space                           # print space
    li      $v0,            4
    syscall 
    lw      $t2,            8($sp)                          # restore dice guess from stack
    bne     $t3,            $t2,                skip2       # skip if equal
    addi    $t0,            $t0,                1           # increment counter because match
skip2:
    sw      $t0,            12($sp)                         # push counter to stack
    jal     rand                                            # get random value 1
    lw      $t0,            12($sp)                         # get counter from stack
    move    $t3,            $v0                             # store random value to t3 for calculations
    move    $a0,            $t3                             # get ready to print int to user
    li      $v0,            1                               # print int
    syscall 
    la      $a0,            newLine                         # print newline
    li      $v0,            4
    syscall 
    lw      $t2,            8($sp)                          # restore dice guess from stack
    bne     $t3,            $t2,                skip3       # skip if equal
    addi    $t0,            $t0,                1           # increment counter because match
skip3:
    lw      $t1,            4($sp)                          # restore wager size from stack
    beqz    $t0,            noMatch                         # go to no matches if there were no matches
    li      $t5,            1                               # initialize t5 to be a counter
    beq     $t0,            $t5,                oneMatch    # find how many matches there were to print appropriate message.
    addi    $t5,            $t5,                1           # increment t5
    beq     $t0,            $t5,                twoMatch
    addi    $t5,            $t5,                1           # increment t5
    beq     $t0,            $t5,                threeMatch
oneMatch:
    li      $v0,            4                               # print one match mesage
    la      $a0,            oneMatchMSG
    syscall 
    j       then
twoMatch:
    li      $v0,            4                               # print two matches message
    la      $a0,            twoMatchesMSG
    syscall 
    j       then
threeMatch:
    li      $v0,            4                               # print 3 match mesage
    la      $a0,            threeMatchesMSG
    syscall 
    j       then
then:
    mult    $t0,            $t1                             # multiply num matches by wager size
    mflo    $t3                                             # store product in t3
    la      $t0,            balance                         # get balance and then add winnings to it, store it again.
    lw      $t4,            0($t0)
    add     $t4,            $t4,                $t3
    sw      $t4,            0($t0)
    j       diceRoutRet                                     # jump to return
noMatch:
    li      $v0,            4                               # print no matches message to user
    la      $a0,            noMatchesMSG
    syscall 
    la      $t0,            balance                         # get balance and then subtract winnings from it, store it again.
    lw      $t4,            0($t0)
    sub     $t4,            $t4,                $t1
    sw      $t4,            0($t0)
    j       diceRoutRet                                     # jump to return
diceRoutRet:
    lw      $ra,            0($sp)                          # restore return address
    addiu   $sp,            $sp,                16          # free stack space
    jr      $ra                                             # return

# #######################################################################
# Function Name: int getwager(holdings)
# #######################################################################
# Functional Description:
# This routine is passed the player's current holdings, and will return
# the player's wager, or the value 0 if the player wants to quit the
# program.  It displays the holdings, then prompts for the wager.
# It then checks to see if the wager is in the proper range.  If so,
# it returns the wager.  Otherwise, it prints an error message, then
# tries again.

# #######################################################################
# Register Usage in the Function:
# $v0, #a0 -- for subroutine linkage and general calculations
# $t8 -- a temporary register used to store the holdings

# #######################################################################
# Algorithmic Description in Pseudocode:
# 1. Display the current holdings to the player
# 1. Print the prompt, asking for the wager
# 2. Read in the number
# 3. If the number is between 0 and holdings, return with that number
# 4. Otherwise print an error message and loop back to try again.

# #######################################################################
.data
holdmsg:	.asciiz "\nYou currently have $"
wagermsg:	.asciiz "\nHow much would you like to wager? "
big:	.asciiz "\nThat bet is too big."
negtv:	.asciiz "\nYou can't bet a negative amount."
.text
getwager:
    move    $t8,            $a0                             # Save their holdings in $t8
again:
    li      $v0,            4                               # Call the Print String I/O Service to print
    la      $a0,            holdmsg                         # message about their holdings
    syscall 
    move    $a0,            $t8                             # Call the Print Integer I/O Service to
    li      $v0,            1                               # print the value
    syscall 
    li      $v0,            4                               # Call the Print String I/O Service to
    la      $a0,            wagermsg                        # ask for the wager
    syscall 
    li      $v0,            5                               # Call the Read Integer I/O Service to
    syscall                                                 # fetch the wager
    bgt     $v0,            $t8,                toobig      # If wager > holdings, go to error line
    bltz    $v0,            toosmall                        # If wager < 0, go to error line
    jr      $ra                                             # Return with the wager in $v0
toobig:
    li      $v0,            4                               # Call the Print String I/O Service to print
    la      $a0,            big                             # that the wager was too big
    syscall 
    j       again                                           # Jump back to try again
toosmall:
    li      $v0,            4                               # Call the Print String I/O Service to print
    la      $a0,            negtv                           # that the wager was too small
    syscall 
    j       again                                           # Jump back to try again

# #######################################################################
# Function Name: int getguess()
# #######################################################################
# Functional Description:
# This routine asks the player to enter the chosen number, which
# should be between 1 and 6.  If the value is out-of-range, the
# routine will print a message and ask again, repeating until we
# get a valid number.

# #######################################################################
# Register Usage in the Function:
# $v0, #a0 -- for subroutine linkage and general calculations
# $t0 -- a temporary register used in the calculations

# #######################################################################
# Algorithmic Description in Pseudocode:
# 1. Print the prompt, asking for the chosen number
# 2. Read in the number
# 3. If the number is between 1 and 6, return with that number
# 4. Otherwise print an error message and loop back to try again.

# #######################################################################
.data
dice:	.asciiz "\nWhat number do you want to bet on? "
limit:	.asciiz "\nThe number has to be between 1 and 6."
.text
getguess:
    li      $v0,            4                               # Call the Print String I/O Service to print
    la      $a0,            dice                            # request for their chosen number
    syscall 
    li      $v0,            5                               # Call the Read Integer I/O Service to get
    syscall                                                 # the number from the player
    blez    $v0,            bad                             # If the number is negative, it is bad
    li      $a0,            6                               # If the number is greater than 6, it is bad
    bgt     $v0,            $a0,                bad
    jr      $ra                                             # Return with the valid number in $v0
bad:
    li      $v0,            4                               # Call the Print String I/O Service to print
    la      $a0,            limit                           # that the number is out-of-bounds
    syscall 
    j       getguess                                        # Loop back to try again

# #######################################################################
# Function Name: int rand()
# #######################################################################
# Functional Description:
# This routine generates a pseudorandom number using the xorsum
# algorithm.  It depends on a non-zero value being in the 'seed'
# location, which can be set by a prior call to seedrand.  This
# version of the routine always returns a value between 1 and 6.

# #######################################################################
# Register Usage in the Function:
# $t0 -- a temporary register used in the calculations
# $v0 -- the register used to hold the return value

# #######################################################################
# Algorithmic Description in Pseudocode:
# 1. Fetch the current seed value into $v0
# 2. Perform these calculations:
# $v0 ^= $v0 << 13
# $v0 ^= $v0 >> 17
# $v0 ^= $v0 << 5
# 3. Save the resulting value back into the seed.
# 4. Mask the number, then get the modulus (remainder) dividing by 6.
# 5. Add 1, so the value ranges from 1 to 6

# #######################################################################
.data
.align 2
seed:	.word 31415                                           # An initial value, in case seedrand wasn't called
.text
rand:
    lw      $v0,            seed                            # Fetch the seed value
    sll     $t0,            $v0,                13          # Compute $v0 ^= $v0 << 13
    xor     $v0,            $v0,                $t0
    srl     $t0,            $v0,                17          # Compute $v0 ^= $v0 >> 17
    xor     $v0,            $v0,                $t0
    sll     $t0,            $v0,                5           # Compute $v0 ^= $v0 << 5
    xor     $v0,            $v0,                $t0
    sw      $v0,            seed                            # Save result as next seed
    andi    $v0,            $v0,                0xFFFF      # Mask the number (so we know its positive)
    li      $t0,            6                               # Get result mod 6, plus 1.  We get a 6 into
    div     $v0,            $t0                             # $t0, then do a divide.  The reminder will be
    mfhi    $v0                                             # in the special register, HI.  Move to $v0.
    add     $v0,            $v0,                1           # Increment the value, so it goes from 1 to 6.
    jr      $ra                                             # Return the number in $v0

# #######################################################################
# Function Name: seedrand(int)
# #######################################################################
# Functional Description:
# This routine sets the seed for the random number generator.  The
# seed is the number passed into the routine.

# #######################################################################
# Register Usage in the Function:
# $a0 -- the seed value being passed to the routine

# #######################################################################
seedrand:
    sw      $a0,            seed
    jr      $ra
