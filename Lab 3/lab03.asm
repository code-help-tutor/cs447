WeChat: cstutorcs
QQ: 749389476
Email: tutorcs@163.com
.data
	enterMsg: .asciiz "Please enter a positive integer: "
	negMsg: .asciiz "A negative integer is not allowed.\n"
	posMsg: .asciiz "\nPlease enter another positive integer: "
	multi: .asciiz " * "
	equal: .asciiz " = "
	powersymbol: .asciiz "^"

.text
	#$s0 - holds first integer
	#$s1 - holds second integer
	#$s3 - holds result
	#$s4 - copy of $s0 value
	#$s5 - copy of $s1 value

	addi $v0, $zero, 4	# Syscall 4: Print string
	la $a0, enterMsg	# $a0 = address of the character in enterMsg
	syscall
	
	j firstval
	
firstval:
	addi $v0, $zero, 5	# Syscall 5: Read integer
	syscall
	move $s0, $v0		# Put read integer into $s0
	
	slt $s7, $s0, $zero
	beq $s7, 1, checkNegFirst
	
	move $s4, $s0		# Create a copy
	
	j secondval
	
secondval:
	addi $v0, $zero, 4	# Syscall 4: Print string
	la $a0, posMsg		# $a0 = address of the character in enterMsg
	syscall
	
	addi $v0, $zero, 5	# Syscall 5: Read integer
	syscall
	move $s1, $v0		# Put read integer into $s1
	
	slt $s7, $s1, $zero
	beq $s7, 1, checkNegSecond
	
	move $s5, $s1
	
	j multiply
	
checkNegFirst:	
	addi $v0, $zero, 4
	la $a0, negMsg
	syscall
	
	addi $v0, $zero, 4
	la $a0, posMsg
	syscall

	j firstval
	
checkNegSecond:
	addi $v0, $zero, 4
	la $a0, negMsg
	syscall
	
	j secondval

multiply:
	ori $t0, $zero, 1
	move $s3, $zero
	move $t1, $zero
	
loop:
	beq $s1, $zero, done
	and $t1, $t0, $s1
	beq $t1, 1, addition
	beq $t1, 0, next
	
addition:
	addu $s3, $s3, $s0
	
next:
	sll $s0, $s0, 1    #shift multiplicand left
      	srl $s1, $s1, 1    #shift multiplier right

      	j loop
	
done:
	addi $v0, $zero, 1
	move $a0, $s4
	syscall
	
	addi $v0, $zero, 4	# Syscall 4: Print string
	la $a0, multi 		# $a0 = address of the character in enterMsg
	syscall
	
	addi $v0, $zero, 1
	move $a0, $s5
	syscall
	
	addi $v0, $zero, 4	# Syscall 4: Print string
	la $a0, equal		# $a0 = address of the character in enterMsg
	syscall
	
	addi $v0, $zero, 1
	move $a0, $s3
	syscall
	
exit:	
	addi $v0, $zero, 10	# Terminate the program
	syscall			# Exit
