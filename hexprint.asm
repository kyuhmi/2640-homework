# passed 32 bit number, will print it in hex
# assume acccept value in $v0 before call?

pseudocode: 
	print "0x"
	(we need first 4 bits and then convert them into hex)
	(loop needs to print 4 bit chunks of the number.)
	
	loop i = 28 (each loop decrement by 4)
		temp = shift right logical 28, 24, 20... (i) bits
		# but we want to chop off upper bits too!
		temp = temp % 16 (will give remainder of the last 4 bits)
		
			or we can and it with 00000000000000000000000000001111 too! (15)
			
			Masking data in assembly code: use AND operation!
		
			andi $t2, $t1, 15
		