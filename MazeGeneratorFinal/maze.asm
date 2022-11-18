.data
wid:     .word 10    # Length of one row, must be 4n - 1
hgt:     .word 10    # Number of rows
cx:     .word 0
cy:     .word 0
numLeft:      .word 0
board:     .space 1764    # we need the space to store a 42 x 42 bytes at max
seedPrompt: .asciiz "Enter a seed: "
.align 2
.text

main:
    li		$v0, 4		# print seed prompt
    la		$a0, seedPrompt	
    syscall
    li		$v0, 5		# read user int
    syscall
    move 	$a0, $v0		# put user int into a0 for seeding fxn
    jal		seedrand				# call seeding fxn

    jal		getSize				# call getSize
    jal     initBoard           # initialize board
    jal     pickExit            # place exit
    jal		pickEntrance		# place entrance

    la		$t0, wid		    # get pointer to width
    lw		$t0, 0($t0)		    # dereference width
    la		$t1, hgt		    # get pointer to height
    lw      $t1, 0($t1)         # dereference height
    mult	$t0, $t1			# calucalte num squares, store into t0
    mflo	$t0					
    addi	$t0, $t0, -1		# decrement num squares since 1 was consumed by placing entrance
    
    jal		printBoard			# print board
    
    #jal     printRawBoard       # TEMP:
    
    li		$v0, 10		# exit
    syscall
    
    
# TEMP: function to print all the data in the board space...
printRawBoard:
    la		$t0, board	    # board pointer
    li      $t1, 0          # loop couunter
    li      $t2, 49       # upper bound for loop
    li      $v0, 1          # initialize for printing
printLoop:
    lb		$a0, 0($t0)		# load bit
    syscall
    addiu	$t0, $t0, 1			# increment to next bit
    addi    $t1, $t1, 1        # increment counter 
    beq		$t1, $t2, printLoopExit
    j       printLoop
printLoopExit:
    jr		$ra					# jump to $ra


########################################################################
# Function Name: getSize
########################################################################
# Functional Description:
#    Ask the user for the size of the maze.  If they ask for a dimension
#    less than 5, we will just use 5.  If they ask for a dimension greater
#    than 40, we will just use 40.  This routine will store the size into
#    the globals wid and hgt.
#
########################################################################
# Register Usage in the Function:
#    $t0 -- Pointer into the board
#    $t1, $t2 -- wid - 1 and hgt - 1, the values for the right edge and
#     bottom row.
#    $t3, $t4 -- loop counters
#    $t6 -- the value to store
#
########################################################################
# Algorithmic Description in Pseudocode:
#    1. Prompt for the two values
#    2. Fetch each of the two values
#    3. Limit the values to the range 5 <= n <= 40
#    4. Store into wid and hgt
#
########################################################################
.data
prompt1: .asciiz "Enter the width of the maze: "
prompt2: .asciiz "Enter the height of the maze: "
intOutOfRange: .asciiz "Integer n must be 5 <= n <= 40. Try again.\n"
.align 2
.text

getSize:
    li		$t7, 5		# store lower bound for branching
    li      $t8, 40     # store upper bound for branching
    p1Loop:
    li		$v0, 4		# printing prompt 1
    la		$a0, prompt1		
    syscall
    li		$v0, 5		# setting up reading integer from user
    syscall
    move 	$t1, $v0		# store width into t1
    blt		$t1, $t7, p1LoopOOB	# if n < 5, go to OOB
    bgt		$t1, $t8, p1LoopOOB	# if n > 40, go to OOB
    j		p1LoopExit				# passes the check, 5 <= n <= 40.
    p1LoopOOB:
    li		$v0, 4		# print out of range prompt !(5 <= n <= 40)
    la		$a0, intOutOfRange		
    syscall
    j		p1Loop				# ask user for input again
    p1LoopExit:
    p2Loop:
    li		$v0, 4		# printing prompt 2
    la		$a0, prompt2		
    syscall
    li		$v0, 5		# setting up reading integer from user
    syscall
    move 	$t2, $v0		# store width into t2
    blt		$t2, $t7, p2LoopOOB	# if n < 5, go to OOB
    bgt		$t2, $t8, p2LoopOOB	# if n > 40, go to OOB
    j		p2LoopExit				# passes the check, 5 <= n <= 40.
    p2LoopOOB:
    li		$v0, 4		# print out of range prompt !(5 <= n <= 40)
    la		$a0, intOutOfRange		
    syscall
    j		p2Loop				# ask user for input again
    p2LoopExit:
    la		$t0, wid		# get pointer to width
    sw		$t1, 0($t0)		# store width into global wid
    la		$t0, hgt		# get pointer to height
    sw		$t2, 0($t0)		# store height into global hgt

    jr		$ra					# return. 
    

########################################################################
# Function Name: initBoard
########################################################################
# Functional Description:
#    Initialize the board array.  All of the cells in the middle of the
#    board will be set to 0 (empty), and all the cells on the edges of
#    the board will be set to 5 (border).
#
########################################################################
# Register Usage in the Function:
#    $t0 -- Pointer into the board
#    $t1, $t2 -- wid - 1 and hgt - 1, the values for the right edge and
#     bottom row.
#    $t3, $t4 -- loop counters
#    $t6 -- the value to store
#
########################################################################
# Algorithmic Description in Pseudocode:
#    1. Set $t0 to point to the board
#    2. Build nested loops for each row and column
#     2a. If we are in the first or last iteration of either loop,
#     place a 5 in the board.
#     2b. Otherwise, place a 0 in the board
#     2c. Increment $t0 after each placement, to go to the next cell.
#
########################################################################

.text

initBoard:
    # POTENTIAL ISSUE: can you access something with the address and store it back into the same register?
    la		$t0, board		# t0 points to the board.
    la		$t1, wid		# load address of width into t1
    lw		$t1, 0($t1)		# load width into t1
    addi	$t1, $t1, 2			# add implicit 2 
    la		$t2, hgt		# load address of height into t2
    lw		$t2, 0($t2)		# load height into t2
    addi	$t2, $t2, 2			# add implicit 2
    li		$t3, 0		# initialize loop counter i

    li		$t8, 0		# t8 = 0 for storage later
    li		$t9, 5		# t9 = 5 for storage later
    
    move $t5, $t1 # store width - 1
    addi	$t5, $t5, -1			
    move $t6, $t2 # store height - 1
    addi $t6, $t6, -1
    
    

    iLoop:
    li		$t4, 0		# initialize loop counter j for each instance of the i loop
    #do i loop stuff
    jLoop:
    # j loop body
    multu	$t3, $t1			# caluclating offset: i * width
    mflo	$t7				
    addu		$t7, $t7, $t4		# store offset i * width + col into t7
    addu	$t7, $t7, $t0 # t7 now has address of the element in array.
    beqz $t3, store5 # if i == 0, we store a 5
    beq		$t3, $t5, store5	# if i == width - 1, we store a 5
    beqz $t4, store5 # if j == 0, we store a 5
    beq $t4, $t6, store5 # if j == height - 1, we store a 5
    j store0 # else, we are storing a 0.
    

    store5:
    sb		$t9, 0($t7)		# store a 5 in the spot of the array
    j storeExit
    store0:
    sb		$t8, 0($t7)		# store a 0 in the spot of the array
    j storeExit
    storeExit:
    
    # j loop body
    addi	$t4, $t4, 1			# increment j loop counter
    ble		$t4, $t2, jLoop	# if j <= height - 1, continue j loop. Else, escape loop.
    addi	$t3, $t3, 1			# out of j loop, increment i loop counter
    ble		$t3, $t1, iLoop	# if i <= width - 1, continue i loop. Else, exit loop.
    #loop exit
    
    jr		$ra					# return
    
    

########################################################################
# Function Name: placeInSquare
########################################################################
# Functional Description:
#    A value is passed in $a0, the number to be placed in one square of
#    the board.  The global variables cx and cy indicate which square. (indexed starting with 1,1 for internal values)
#
########################################################################
# Register Usage in the Function:
#    $a0 -- The value to be placed
#    $t0, $t1, $t2, $t3 -- general computations
#
########################################################################
# Algorithmic Description in Pseudocode:
#    1. compute the effective address, board + cy * wid + cx
#    2. Store the byte in $a0 at this address.
#
########################################################################

.text

placeInSquare:
    la		$t0, board		# load pointer to board
    la		$t3, cx		# load pointer to cx
    lw		$t1, 0($t3)		# get value of cx and store it
    la		$t3, cy		# load pointer to cy
    lw		$t2, 0($t3)		# load value of cy into register
    la		$t3, wid		# load pointer to width
    lw		$t3, 0($t3)		# get value of width
    addiu   $t3, $t3, 2          # add 2 to width to account for empty spaces.
    mult	$t2, $t3			# compute cy * width
    mflo	$t2
    addu	$t2, $t1, $t2			# store cy * wid + cx into t2
    addu    $t0, $t0, $t2   # compute board + cy * wid + cx, t0 now has address of element.
    sb		$a0, 0($t0)		# store user byte into address. 
    jr		$ra					# return

########################################################################
# Function Name: pickEntrace
########################################################################
# Functional Description:
#    This picks the entrance for the maze.  It goes to one of the
#    cells on the north edge of the map (inside the border), then changes
#   it's value from 0 (empty) to 1 (came from north).
#    This routine will exit with cx, cy set to the cell, so we are ready
#    to find a path here through the maze.
#
########################################################################
# Register Usage in the Function:
#    $a0, $v0 -- used for syscall linkage, and calculations
#    $t0 - for general computation
#    We save $ra on stack, because we call the rand and placeInSquare
#   functions
#
########################################################################
# Algorithmic Description in Pseudocode:
#    1. Save $ra on the stack
#    2. Pick a random column, from 1 to wid - 1
#    3. Place '1' in the chosen border cell
#    4. Restore the $ra value
#
########################################################################

.text

pickEntrance:
    addiu $sp, $sp, -4 # make space on stack
    sw		$ra, 0($sp)		# store ra on stack
    la		$t0, wid		# get pointer to width
    lw		$a0, 0($t0)		# load width into a0
    jal		rand				# call rand fxn passing in width
    la		$t0, cy		# get pointer to cy
    li		$t1, 1		# store 1 to store into cy
    sw		$t1, 0($t0)		# set cy to 1
    la		$t0, cx		# get pointer to cx 
    sw      $v0, 0($t0) # store output of rand into cx
    li		$a0, 1		# set a0 to 1 (came from north) to call placeInSquare
    jal		placeInSquare				# call placeInSquare
    lw		$ra, 0($sp)		# restore return address
    addiu	$sp, $sp, 4			# free up stack space
    jr		$ra					# return
    

########################################################################
# Function Name: pickExit
########################################################################
# Functional Description:
#    This picks the exit for the maze.  It goes to one of the border
#    cells on the south edge of the map, then changes it's value from
#    5 (border) to 1 (came from north).
#
########################################################################
# Register Usage in the Function:
#    $a0, $v0 -- used for syscall linkage, and calculations
#    $t0, $t1 - for general computation
#    We save $ra on stack, because we call the rand and placeInSquare
#   functions
#
########################################################################
# Algorithmic Description in Pseudocode:
#    1. Save $ra on the stack
#    2. Pick a random column, from 1 to wid - 1
#    3. Place '1' in the chosen border cell
#    4. Restore the $ra value
#
########################################################################

.text

pickExit:
    addiu $sp, $sp, -4 # make space on stack
    sw		$ra, 0($sp)		# store ra on stack
    la		$t0, wid		# get pointer to width
    lw		$a0, 0($t0)		# load width into a0
    jal		rand				# call rand fxn passing in width
    la		$t0, hgt		# get pointer to height
    lw		$t1, 0($t0)		# get height
    addi    $t1, $t1, 1     # increment height by 1 to move it into the boarder.
    la		$t0, cy		# get pointer to cy
    sw		$t1, 0($t0)		# set cy to height
    la		$t0, cx		# get pointer to cx 
    sw      $v0, 0($t0) # store output of rand into cx
    li		$a0, 1		# set a0 to 1 (came from north) to call placeInSquare
    jal		placeInSquare				# call placeInSquare
    lw		$ra, 0($sp)		# restore return address
    addiu	$sp, $sp, 4			# free up stack space
    jr		$ra					# return
    

########################################################################
# Function Name: printBoard
########################################################################
# Functional Description:
#    This prints the final maze to the console
#
########################################################################
# Register Usage in the Function:
#    $a0, $v0 -- used for syscall linkage
#    $t8 -- pointer to first cell in current row
#    $t9 -- loop counter for rows
#    $t7, $t6 -- pointers to neighboring cells as we scan rows
#    $t5 -- loop counter for columns
#    $t0, $t1 -- general computations
#
########################################################################
# Algorithmic Description in Pseudocode:
#    1. Loop for each row on the board.  $t8 will point to the first cell
#     in the row, and $t9 is the loop counter.
#     1a.    Loop for each column, printing the north wall/door.  $t7 will
#     point to the north cell, $t6 to the south cell, and $t5 is
#     loop counter.
#     1a1. If board[$t7] came from south or board[$t6] came from
#     north, print open door.  Otherwise print wall.
#     1b. At end of row, print closing char and newline.
#     1c. If we are in the last row of the board, don't print the 'cells'
#     at the bottom edge, they are the border of the map.  Skip
#     steps 1d and 1e.
#     1d.    Loop for each column, printing the west wall/door.  $t7 will
#     point to the west cell, $t6 to the east cell, and $t5 is
#     loop counter.
#     1d1. If board[$t7] came from east or board[$t6] came from
#     west, print open door.  Otherwise print wall.
#     1e. At end of row, print closing char and newline.
#
########################################################################
.data
wallHorizClosed: .asciiz "+--"
wallHorizOpen: .asciiz "+  "
wallHorizEnd: .asciiz "+\n"
wallVertOpen: .asciiz "   "
wallVertClosed: .asciiz "|  "
wallVertEnd: .asciiz "|\n"
.align 2
.text

printBoard:
    la		$t0, board		# get pointer to board, store in t0
    la		$t1, wid        # get pointer to width
    lw      $t1, 0($t1)     # dereference width
    move    $t6, $t1        # copy normal width for limit in colLoops
    addi	$t1, $t1, 2		# increment width by 2 to account for empty space
    la		$t2, hgt        # get pointer to height
    lw		$t2, 0($t2)		# dereference height

    move    $t3, $t0        # t3 now points to the first element of the board
    addu    $t3, $t3, $t1   # t3 now points to first element of second row
    addiu   $t3, $t3, 1     # t3 now poitns to second element of second row, the first real value.

    li		$t4, 0		    # initialize rowLoopCounter
    
    li      $v0, 4          # preparing to print strings
    

    forEachRow:
    #row loop body
    # printing N walls
    li      $t5, 0          # initialize / reset colLoopCounter
    move    $t7, $t3        # make a copy of the pointer to element in board
    forEachColN:
    #col loop body
    lb		$t8, 0($t7)		        # load the value of the bit into t8
    li		$t9, 1		            # comparison value for current place coming from north
    beq		$t8, $t9, printNoNWall	# if curr bit = 1, then it came from the north so no wall should be printed.
    negu    $t9, $t1                # store -(width+2) into t9
    addu    $t9, $t9, $t7           # compute currElementAddress - (width + 2), t9 should now point to the element in the previous row, same column.
    lb		$t8, 0($t9)		        # get the bit stored there
    li		$t9, 2		            # comparison value for place coming from south
    beq		$t8, $t9, printNoNWall	# above element came from the south element, that means that we shouldn't print the north wall.
    la		$a0, wallHorizClosed	# else, we print the north wall closed.
    syscall 
    j       printNWallExit          # to skip printing no wall
    printNoNWall:
    la		$a0, wallHorizOpen		# print an open north wall
    syscall
    printNWallExit:
    #col loop body
    addiu   $t7, $t7, 1             # increment pointer to next bit of data
    addi    $t5, $t5, 1             # increment colLoopCounter
    blt		$t5, $t6, forEachColN    # if colLoopCounter < width, continue looping, else, keep going.
    la		$a0, wallHorizEnd		# we are done printing north walls, so move onto next line.
    syscall

    beq		$t4, $t2, printingExit	# if rowLoopCounter == height, then we should skip printing vertical walls.
    
    # printing side walls
    li      $t5, 0          # reset colLoopCounter
    move    $t7, $t3        # make a copy of the pointer to element in board
    forEachColS:
    #col loop body
    lb		$t8, 0($t7)		            # load current value of current place
    li		$t9, 4		                # value that represents "came from west" for comparison
    beq		$t9, $t8, printOpenSideWall	# if the current element came from the west, we shouldn't print a wall.
    lb		$t8, -1($t7)		        # load value of previous element
    li		$t9, 3		                # value that represents "came from east" for comparison
    beq		$t9, $t8, printOpenSideWall	# if the previous element came from the east, then there shouldn't be a wall.
    la		$a0, wallVertClosed		    # otherwise, there should be a wall printed.
    syscall
    j       printSideWallExit           # to skip printing open side wall at this point.
    printOpenSideWall:
    la		$a0, wallVertOpen		# printing open side wall
    syscall
    printSideWallExit:
    #col loop body
    addiu   $t7, $t7, 1             # increment pointer to next bit of data
    addi    $t5, $t5, 1             # increment colLoopCounter
    blt		$t5, $t6, forEachColS    # if colLoopCounter < width, continue looping, else, keep going.
    
    la		$a0, wallVertEnd		# done printing vertical walls, so move to next line.
    syscall

    #row loop body
    addu    $t3, $t3, $t1           # move pointer to second element of next row
    addi    $t4, $t4, 1             # increment rowLoopCounter
    ble		$t4, $t2, forEachRow	# if rowLoopCounter <= height (should include last OOB row), continue looping, else, keep going.
    
    printingExit:
    jr		$ra					# done, so we return.
    

    
    
    
    
    
    




########################################################################
# Function Name: int rand()
########################################################################
# Functional Description:
#    This routine generates a pseudorandom number using the xorsum
#    algorithm.  It depends on a non-zero value being in the 'seed'
#    location, which can be set by a prior call to seedrand.  For this
#    version, pass in a number N in $a0.  The return value will be a
#    number between 0 and N-1.
#
########################################################################
# Register Usage in the Function:
#    $t0 -- a temporary register used in the calculations
#    $v0 -- the register used to hold the return value
#    $a0 -- the input value, N
#
########################################################################
# Algorithmic Description in Pseudocode:
#    1. Fetch the current seed value into $v0
#    2. Perform these calculations:
#     $v0 ^= $v0 << 13
#     $v0 ^= $v0 >> 17
#     $v0 ^= $v0 << 5
#    3. Save the resulting value back into the seed.
#    4. Mask the number, then get the modulus (remainder) dividing by $a0.
#
########################################################################
     .data
seed:    .word 31415     # An initial value, in case seedrand wasn't called
     .text
rand:
    lw     $v0, seed     # Fetch the seed value
    sll     $t0, $v0, 13    # Compute $v0 ^= $v0 << 13
    xor     $v0, $v0, $t0
    srl     $t0, $v0, 17    # Compute $v0 ^= $v0 >> 17
    xor     $v0, $v0, $t0
    sll     $t0, $v0, 5     # Compute $v0 ^= $v0 << 5
    xor     $v0, $v0, $t0
    sw     $v0, seed     # Save result as next seed
    andi    $v0, $v0, 0xFFFF    # Mask the number (so we know its positive)
    div     $v0, $a0     # divide by N.  The reminder will be
    mfhi    $v0     # in the special register, HI.  Move to $v0.
    jr     $ra     # Return the number in $v0

########################################################################
# Function Name: seedrand(int)
########################################################################
# Functional Description:
#    This routine sets the seed for the random number generator.  The
#    seed is the number passed into the routine.
#
########################################################################
# Register Usage in the Function:
#    $a0 -- the seed value being passed to the routine
#
########################################################################
seedrand:
    sw $a0, seed
    jr $ra

########################################################################
# Function Name: takeMove
########################################################################
# Functional Description:
#    This adds one more cell to the maze.  It starts with the cell cx, cy.
#    It then counts how many of the neighboring cells are currently
#    empty.
#    *    If there is only one, then it adds that square to the maze,
#     having that square point to this one, and moving cx, cy to that
#     square.
#    *    If there are two or three, it randomly picks one, then does the
#     same as the only one case.
#    *    If there are none, the routine clears the numLeft value, signifying
#     that we are done with the maze (TBD change this in part 3).
#
########################################################################
# Register Usage in the Function:
#    $a0, $v0 -- used for syscall linkage, and calculations
#    We save $ra on stack, as well as $s0-$s5
#    $t0, $t1 -- general use
#    $s0 -- pointer to the square at cx, cy
#    $s1 -- pointer to a neighboring cell
#    $s2 -- how many neighbors are empty?
#    $s3-$s5 -- possible neighbors to move to
#
########################################################################
# Algorithmic Description in Pseudocode:
#    1. Save $ra and $s registers on the stack
#    2. Set $s0 to point to the current cell
#    3. Count the number of neighbors that have a 0 value.  The count
#     will be in $s2, and $s3-$s5 will be the possible moves to
#     neighbors:  1 = move north, 2 = move south, 3 = move east,
#     4 = move west.
#     3a. If we have one choice, move to that square and have it point back
#     to this square.
#     3b. If we have two or three choices, pick one at random.
#     3c. If we have no choices, stop the generator
#    4. Restore the $ra and $s register values
#
########################################################################