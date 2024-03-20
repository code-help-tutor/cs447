WeChat: cstutorcs
QQ: 749389476
Email: tutorcs@163.com
.data
	enterMsg: .asciiz "\nEnter a number between 0 and 9: "
	lowMsg: .asciiz "Your guess is too low."
	highMsg: .asciiz "Your guess is too high."
	loseMsg: .asciiz "\nYou lose. The number was "
	period: .asciiz "."
	winMsg: .asciiz "Congratulations! You win!"

.text
	addi $v0, $zero, 42	# Syscall 42: Random int range
	add $a0, $zero, $zero	# Set RNG ID to 0
	addi $a1, $zero, 10	# Set upper bound to 9
	syscall
	add $s1, $zero, $a0	#  Copy the random number to $s1
	
	addi $s0, $zero, 3	# Set counter to 3 (for 3 chance)
	
	j loop
	
loop:
	beq $s0, $zero, ifIncorrect	# Check to see if count has reached zero
	addi $v0, $zero, 4	# Syscall 4: Print string
	la $a0, enterMsg	# $a0 = address of the character in enterMsg
	syscall
	
	addi $v0, $zero, 5	# Syscall 5: Read integer
	syscall
	add $s2, $zero, $v0	# Put read integer into $s0
	
	beq $s1, $s2, ifCorrect	# If value is the same as the randomly generated number, go to isCorrect

	slt $s7, $s2, $s1	# Compare the value that the user entered and the randomly generated number
	beq $s7, 1, ifLower	# If not equal (designated by 1), go to ifLower

ifHigher:
	addi $v0, $zero, 4	# Syscall 4: Print string
	la $a0, highMsg		# Prints message if number is too high
	syscall
	
	addi $s0, $s0, -1	# Decreases count by 1
	j loop 			# Go back to the loop
	
ifLower:
	addi $v0, $zero, 4	# Syscall 4: Print string
	la $a0, lowMsg		# Prints message if number is too low
	syscall
	
	addi $s0, $s0, -1 	# Decreases count by 1
	j loop			# Go back to the loop

ifCorrect:
	addi $v0, $zero, 4	# Print message if number is correct
	la $a0, winMsg
	syscall
	
	j done
	
ifIncorrect:
	addi $v0, $zero, 4	# Print out message if you lost the game
	la $a0, loseMsg
	syscall
	
	addi $v0, $zero, 1	# Syscall 1: Prints integer
	add $a0, $zero, $s1
	syscall
	
	addi $v0, $zero, 4	# Put a period at the end
	la $a0, period
	syscall
	
	j done
	
done:
	addi $v0, $zero, 10	# Terminate the program
	syscall			# Exit
