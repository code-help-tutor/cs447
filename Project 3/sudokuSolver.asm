WeChat: cstutorcs
QQ: 749389476
Email: tutorcs@163.com
.data
	newLine:	.asciiz "\n"	# Adds in a newline
	
.text
printPuzzle:
	_beginPrinting:
		addi $t2, $t2, 1		# Add value of 1 to $t2
		beq $t2, 10, _reset	
	
	_printRow:					
		addi $t1, $zero, 0	# Print out all of the rows of sudoku numbers
		lb $a0, 0xffff8000($t3)   	
		addi $v0, $zero, 1  		
		syscall        
	  		
	_keepPrinting:
		addi $t1, $t1, 1	
		addi $t3, $t3, 1
		lb $a0, 0xffff8000($t3)
		syscall
		beq $t1, 8, _completedLoop
		j	_keepPrinting
	
	_completedLoop:
		jal _newLine
		add $t1, $zero, $zero
		subi $t3, $t3, -1
		j _beginPrinting
	
	_newLine: 
		la   $a0, newLine
		j _printString
	
	_printString:
		add  $v0, $zero, 4		
		syscall				
		jr $ra

	_reset:
		jal _resetRegisters		# Resets all of the registers being used

		add $s0, $zero, $zero   # Set the initial position of s0 to zero
		add $s1, $zero, $zero 	# Set the initial position of s1 to zero
		add $a0, $s0, $zero		# $a0 will hold the row
		add $a1, $s1, $zero		# $a1 will hold the column
	
######################################################################
main:
	jal _solveSudoku
	j	_endProgram

	_solveSudoku:
		addi $sp, $sp, -4
  		sw $ra, 0($sp)
		add $s3, $zero, $zero
	_compareRow:
		beq $a0, 8, _compareColumn	# If row equals 8, compare columns
		j	_next
	_compareColumn:	
		beq $a1, 9, _setTrue			# If column equals 9, set the value of $s3 to true
		j	_next
	_next:
		beq $a1, 9, _increment		# If column equals 9, increment the value of $s0 by 1
		j	_continue
	_increment:
		add $s0, $s0, 1
		add $s1, $zero, $zero
		
	_continue:
		addi $t6, $zero, 9		# Put the value of 9 into $t6
		mult $a0, $t6				# Multiply $t6 (9) by the row		
		mflo $t6 					# Put the lowest bits into register $t6
		add $t6, $t6, $a1 		# Add the column value to register $t6
		lb $t6, 0xffff8000($t6) # This is the data that is dependent on the row and column
		sgt $s4, $t6, 0			# If the value of the number inside the box is greater than zero we set $s4 to 1
		beq $s4, 1, _keepGoing  # If $s4 is 1, then the value is not zero and can continue
		j	_checkValue				# Otherwise, jump to check the value that is in the box
		
	_keepGoing:
		add $a1, $a1, 1			# Increment column by 1
		add $s1, $s1, 1			# $s1 holds a copy of the data in column

		jal _solveSudoku
		j	_endSolving
		
_checkValue:
	addi $t5, $zero, 1 	# $t5 holds the value that we are checking. It also acts as our incrementor
	
_checkValueLoop:
	beq $t5, 10, _endLoop	# If $t5 is equal to 10, end the loop. We can only check values between 0-9.
	add $a2, $zero, $t5 		# $a2 now holds the value in $t5, which is the number we are currently checking
	jal	_makeChecks
	beq $v0, 1, _numberExists
	j	_canContinue
	
_numberExists:
	addi $t5, $t5, 1		# If the number already exists, increment the value of $t5 by 1
	j	_checkValueLoop	
	
_canContinue:
	addi $t6, $zero, 9	# Put 9 into register $t6
	mult $s0, $t6 			# Multiply contents of $t6 with contents in $s0
	mflo $t6			 		# Put lower contents into $t6
	add $t6, $t6, $a1 	# Add column to value in $t6
	sb  $t5, 0xffff8000($t6) 	
	
	addi $sp, $sp, -20	# Store and load the corresponding values needed
	sw   $s0, 0($sp)
	sw   $s1, 4($sp)
	sw   $a0, 8($sp) 
	sw   $t5, 12($sp)
	sw   $a1, 16($sp)
	addi $a1, $a1, 1
	addi $s1, $s1, 1
	jal	_solveSudoku
	lw   $s0, 0($sp)
	lw   $s1, 4($sp)
	lw   $a0, 8($sp) 
	lw   $t5, 12($sp)
	lw   $a1, 16($sp)
	addi $sp, $sp, 20
	beq $s3, 1, _endSolving	# If $s3 is equal to 1, end your sudoku solving
	j	_checkValueLoop
	
_endLoop:				
	addi $t6, $zero, 9	# Resets registers again
	mult $s0, $t6 
	mflo $t6 			
	add $t6, $t6, $s1
	sb  $zero, 0xffff8000($t6) 	
	add $s3, $zero, $zero
	j	_endSolving
	
_setTrue:					
	add $s3, $zero, 1		# If $s3 is set to 1, you can quit the program.
	
_endSolving:
	lw $ra, 0($sp)			# Load/restore stack pointer
  	addi $sp, $sp, 4
  	jr $ra 					# Jump to restore address
	
_makeChecks:
	addi $sp, $sp, -4
  	sw $ra, 0($sp)
  
  	add $a0, $zero, $s0 	
  	add $a1, $zero, $a2 	
  	jal	_checkRow
  	beq $v0, 1, _checkingComplete
  	
  	jal	_resetRegisters
  	
  	add $a0, $zero, $s1 	
  	jal	_checkColumn 	
  	beq $v0, 1, _checkingComplete
  	
  	jal	_resetRegisters
  	
  	add $a0, $zero, $s0 	
  	add $a2, $zero, $a1 
  	add $a1, $zero, $s1 	
  	jal	_checkSubGrid
  	
  	jal	_resetRegisters
  
_checkingComplete:
  	lw $ra, 0($sp)
  	addi $sp, $sp, 4
  	jr $ra

_checkRow:
	add $v0, $zero, $zero # Reset values in register $v0
 	addi $t0, $zero, 9 	 # Put the value of 9 into $t0
 	mult $a0, $t0      	 # Multiply contents in $a0 with contents in $t0
 	mflo $t1	   			 # Move lower bits into register $t1
 	addi $t3, $zero, 0 	 # $t3 holds the counter for checks
 	
 	_loopRow:
 		beq $t3, 9, _finishedRow # If all the rows have been check, then the loop jumps to _finishedRow
 		lb $t2, 0xffff8000($t1) 
 		beq $a1, $t2, _rowReset  # Compares the value in current box to the number we are trying to check
 		addi $t1, $t1, 1 			 # Increment $t1 to move boxes
 		addi $t3, $t3, 1 			 # Increment $t3, which is a counter
 		j	_loopRow
 		
 	_rowReset:
 		addi $v0, $zero, 1	# If $v0 is set to 1, it has already been used
 		
 	_finishedRow:
 		jr $ra

	
_checkColumn:
 	add $v0, $zero, $zero # Resets $v0 back to zero
 	add $t0, $a0, $zero   # $t0 holds the column value
 	addi $t2, $zero, 0    #$t2 holds the counter for checks
	
	_loopColumn:
		beq $t2, 9, _finishedColumn # If all the rows have been check, then the loop jumps to _finishedColumn
 		lb $t1, 0xffff8000($t0)
 		beq $t1, $a1, _columnReset  # Compares the value in current box to the number we are trying to check
 		addi $t0, $t0, 9				 # Increment $t1 to move boxes
 		addi $t2, $t2, 1 	          # Increment $t3, which is a counter
 		j _loopColumn
 		
 	_columnReset:
 		addi $v0, $zero, 1 #sets v0 to 1 if number we are trying is already in column 	
 		
 	_finishedColumn:
 		jr $ra

_checkSubGrid:
	add $t0, $a0, $zero	# Resets all of the temporary registers back to zero
	add $t1, $a1, $zero
	add $t2, $a2, $zero 
	add $t3, $zero, $zero
	add $t4, $zero, $zero 
	add $v0, $zero, $zero 
	blt $t1, 3, zeroThreeSix
	blt $t1, 6, oneFourSeven
	j	twoFiveEight 
	
zeroThreeSix:
	blt $t0, 3, _topLeft
	blt $t0, 6, _middleLeft
	j	_bottomLeft
oneFourSeven:
	blt $t0, 3, _topMiddle
	blt $t0, 6, _middleGrid
	j	_middleBottom
twoFiveEight:
	blt $t0, 3, _topRight
	blt $t0, 6, _middleRight
	j	_bottomRight

top:	# Recursively checks the top row of subgrids
	_topLeft: 
		lb $t3, 0xffff8000($t4)
		beq $t3, $t2, _hasSameValue
		addi $t4, $t4, 1
		lb $t3, 0xffff8000($t4)
		beq $t3, $t2, _hasSameValue
		addi $t4, $t4, 1
		lb $t3, 0xffff8000($t4)
		beq $t3, $t2, _hasSameValue
		addi $t4, $t4, 7
		lb $t3, 0xffff8000($t4)
		beq $t3, $t2, _hasSameValue
		addi $t4, $t4, 1
		lb $t3, 0xffff8000($t4)
		beq $t3, $t2, _hasSameValue
		addi $t4, $t4, 1
		lb $t3, 0xffff8000($t4)
		beq $t3, $t2, _hasSameValue
		addi $t4, $t4, 7
		lb $t3, 0xffff8000($t4)
		beq $t3, $t2, _hasSameValue
		addi $t4, $t4, 1
		lb $t3, 0xffff8000($t4)
		beq $t3, $t2, _hasSameValue
		addi $t4, $t4, 1
		lb $t3, 0xffff8000($t4)
		beq $t3, $t2, _hasSameValue
		j	_completelyFinished
	
	_topMiddle:
		lb $t3, 0xffff8003($t4)
		beq $t3, $t2, _hasSameValue
		addi $t4, $t4, 1
		lb $t3, 0xffff8003($t4)
		beq $t3, $t2, _hasSameValue
		addi $t4, $t4, 1
		lb $t3, 0xffff8003($t4)
		beq $t3, $t2, _hasSameValue
		addi $t4, $t4, 7
		lb $t3, 0xffff8003($t4)
		beq $t3, $t2, _hasSameValue
		addi $t4, $t4, 1
		lb $t3, 0xffff8003($t4)
		beq $t3, $t2, _hasSameValue
		addi $t4, $t4, 1
		lb $t3, 0xffff8003($t4)
		beq $t3, $t2, _hasSameValue
		addi $t4, $t4, 7
		lb $t3, 0xffff8003($t4)
		beq $t3, $t2, _hasSameValue
		addi $t4, $t4, 1
		lb $t3, 0xffff8003($t4)
		beq $t3, $t2, _hasSameValue
		addi $t4, $t4, 1
		lb $t3, 0xffff8003($t4)
		beq $t3, $t2, _hasSameValue
		j	_completelyFinished
	
	_topRight:
		lb $t3, 0xffff8006($t4)
		beq $t3, $t2, _hasSameValue
		addi $t4, $t4, 1
		lb $t3, 0xffff8006($t4)
		beq $t3, $t2, _hasSameValue
		addi $t4, $t4, 1
		lb $t3, 0xffff8006($t4)
		beq $t3, $t2, _hasSameValue
		addi $t4, $t4, 7
		lb $t3, 0xffff8006($t4)
		beq $t3, $t2, _hasSameValue
		addi $t4, $t4, 1
		lb $t3, 0xffff8006($t4)
		beq $t3, $t2, _hasSameValue
		addi $t4, $t4, 1
		lb $t3, 0xffff8006($t4)
		beq $t3, $t2, _hasSameValue
		addi $t4, $t4, 7
		lb $t3, 0xffff8006($t4)
		beq $t3, $t2, _hasSameValue
		addi $t4, $t4, 1
		lb $t3, 0xffff8006($t4)
		beq $t3, $t2, _hasSameValue
		addi $t4, $t4, 1
		lb $t3, 0xffff8006($t4)
		beq $t3, $t2, _hasSameValue
		j	_completelyFinished

middle:	# Recursively checks the middle row of subgrids
	_middleLeft:
		lb $t3, 0xffff801b($t4)
		beq $t3, $t2, _hasSameValue
		addi $t4, $t4, 1
		lb $t3, 0xffff801b($t4)
		beq $t3, $t2, _hasSameValue
		addi $t4, $t4, 1
		lb $t3, 0xffff801b($t4)
		beq $t3, $t2, _hasSameValue
		addi $t4, $t4, 7
		lb $t3, 0xffff801b($t4)
		beq $t3, $t2, _hasSameValue
		addi $t4, $t4, 1
		lb $t3, 0xffff801b($t4)
		beq $t3, $t2, _hasSameValue
		addi $t4, $t4, 1
		lb $t3, 0xffff801b($t4)
		beq $t3, $t2, _hasSameValue
		addi $t4, $t4, 7
		lb $t3, 0xffff801b($t4)
		beq $t3, $t2, _hasSameValue
		addi $t4, $t4, 1
		lb $t3, 0xffff801b($t4)
		beq $t3, $t2, _hasSameValue
		addi $t4, $t4, 1
		lb $t3, 0xffff801b($t4)
		beq $t3, $t2, _hasSameValue
		j	_completelyFinished
	
	_middleGrid:
		lb $t3, 0xffff801e($t4)
		beq $t3, $t2, _hasSameValue
		addi $t4, $t4, 1
		lb $t3, 0xffff801e($t4)
		beq $t3, $t2, _hasSameValue
		addi $t4, $t4, 1
		lb $t3, 0xffff801e($t4)
		beq $t3, $t2, _hasSameValue
		addi $t4, $t4, 7
		lb $t3, 0xffff801e($t4)
		beq $t3, $t2, _hasSameValue
		addi $t4, $t4, 1
		lb $t3, 0xffff801e($t4)
		beq $t3, $t2, _hasSameValue
		addi $t4, $t4, 1
		lb $t3, 0xffff801e($t4)
		beq $t3, $t2, _hasSameValue
		addi $t4, $t4, 7
		lb $t3, 0xffff801e($t4)
		beq $t3, $t2, _hasSameValue
		addi $t4, $t4, 1
		lb $t3, 0xffff801e($t4)
		beq $t3, $t2, _hasSameValue
		addi $t4, $t4, 1
		lb $t3, 0xffff801e($t4)
		beq $t3, $t2, _hasSameValue
		j	_completelyFinished
	
	_middleRight:
		lb $t3, 0xffff8021($t4)
		beq $t3, $t2, _hasSameValue
		addi $t4, $t4, 1
		lb $t3, 0xffff8021($t4)
		beq $t3, $t2, _hasSameValue
		addi $t4, $t4, 1
		lb $t3, 0xffff8021($t4)
		beq $t3, $t2, _hasSameValue
		addi $t4, $t4, 7
		lb $t3, 0xffff8021($t4)
		beq $t3, $t2, _hasSameValue
		addi $t4, $t4, 1
		lb $t3, 0xffff8021($t4)
		beq $t3, $t2, _hasSameValue
		addi $t4, $t4, 1
		lb $t3, 0xffff8021($t4)
		beq $t3, $t2, _hasSameValue
		addi $t4, $t4, 7
		lb $t3, 0xffff8021($t4)
		beq $t3, $t2, _hasSameValue
		addi $t4, $t4, 1
		lb $t3, 0xffff8021($t4)
		beq $t3, $t2, _hasSameValue
		addi $t4, $t4, 1
		lb $t3, 0xffff8021($t4)
		beq $t3, $t2, _hasSameValue
		j	_completelyFinished
	
bottom: # Recursively checks the bottom row of subgrids
	_bottomLeft:
		lb $t3, 0xffff8036($t4)
		beq $t3, $t2, _hasSameValue
		addi $t4, $t4, 1
		lb $t3, 0xffff8036($t4)
		beq $t3, $t2, _hasSameValue
		addi $t4, $t4, 1
		lb $t3, 0xffff8036($t4)
		beq $t3, $t2, _hasSameValue
		addi $t4, $t4, 7
		lb $t3, 0xffff8036($t4)
		beq $t3, $t2, _hasSameValue
		addi $t4, $t4, 1
		lb $t3, 0xffff8036($t4)
		beq $t3, $t2, _hasSameValue
		addi $t4, $t4, 1
		lb $t3, 0xffff8036($t4)
		beq $t3, $t2, _hasSameValue
		addi $t4, $t4, 7
		lb $t3, 0xffff8036($t4)
		beq $t3, $t2, _hasSameValue
		addi $t4, $t4, 1
		lb $t3, 0xffff8036($t4)
		beq $t3, $t2, _hasSameValue
		addi $t4, $t4, 1
		lb $t3, 0xffff8036($t4)
		beq $t3, $t2, _hasSameValue
		j	_completelyFinished
	
	_middleBottom:
		lb $t3, 0xffff8039($t4)
		beq $t3, $t2, _hasSameValue
		addi $t4, $t4, 1
		lb $t3, 0xffff8039($t4)
		beq $t3, $t2, _hasSameValue
		addi $t4, $t4, 1
		beq $t3, $t2, _hasSameValue
		addi $t4, $t4, 7
		lb $t3, 0xffff8039($t4)
		beq $t3, $t2, _hasSameValue
		addi $t4, $t4, 1
		lb $t3, 0xffff8039($t4)
		beq $t3, $t2, _hasSameValue
		addi $t4, $t4, 1
		lb $t3, 0xffff8039($t4)
		beq $t3, $t2, _hasSameValue
		addi $t4, $t4, 7
		lb $t3, 0xffff8039($t4)
		beq $t3, $t2, _hasSameValue
		addi $t4, $t4, 1
		lb $t3, 0xffff8039($t4)
		beq $t3, $t2, _hasSameValue
		addi $t4, $t4, 1
		lb $t3, 0xffff8039($t4)
		beq $t3, $t2, _hasSameValue
		j	_completelyFinished
	
	_bottomRight:
		lb $t3, 0xffff803c($t4)
		beq $t3, $t2, _hasSameValue
		addi $t4, $t4, 1
		lb $t3, 0xffff803c($t4)
		beq $t3, $t2, _hasSameValue
		addi $t4, $t4, 1
		lb $t3, 0xffff803c($t4)
		beq $t3, $t2, _hasSameValue
		addi $t4, $t4, 7
		lb $t3, 0xffff803c($t4)
		beq $t3, $t2, _hasSameValue
		addi $t4, $t4, 1
		lb $t3, 0xffff803c($t4)
		beq $t3, $t2, _hasSameValue
		addi $t4, $t4, 1
		lb $t3, 0xffff803c($t4)
		beq $t3, $t2, _hasSameValue
		addi $t4, $t4, 7
		lb $t3, 0xffff803c($t4)
		beq $t3, $t2, _hasSameValue
		addi $t4, $t4, 1
		lb $t3, 0xffff803c($t4)
		beq $t3, $t2, _hasSameValue
		addi $t4, $t4, 1
		lb $t3, 0xffff803c($t4)
		beq $t3, $t2, _hasSameValue
		j	_completelyFinished
	
_hasSameValue:
	addi $v0, $zero, 1 	# If the values are the same, put 1 into $v0
	
_completelyFinished:		# Jump if completely finished
	jr $ra

_resetRegisters: 
	add $t0, $zero, $zero	# Resets all used registers back to 0
	add $t1, $zero, $zero
	add $t2, $zero, $zero
	add $t3, $zero, $zero
	add $t4, $zero, $zero
	jr $ra
	
_endProgram:
	addi $v0, $zero, 10		# Terminate the program
	syscall
