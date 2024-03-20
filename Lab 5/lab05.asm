WeChat: cstutorcs
QQ: 749389476
Email: tutorcs@163.com
.data
	sumTitle:	.asciiz	"Summation: sum(n)\n"
	integer_n:	.asciiz	"Please enter an integer (greater than or equal to 0): "
	sumResult:	.asciiz	"sum("
	powTitle:	.asciiz	"Power: pow(x,y)\n"
	integer_x:	.asciiz	"Please enter an integer for x (greater than or equal to 0): "
	integer_y:	.asciiz	"Please enter an integer for y (greater than or equal to 0): "
	powResult:	.asciiz "pow("
	comma:		.asciiz	","
	fTitle:		.asciiz	"Fibonacci: F(n)\n"
	fResult:	.asciiz	"F("
	isMsg:		.asciiz	") is "
	period:		.asciiz ".\n"
.text
	# Sum
	addi $v0, $zero, 4		# Syscall 4: Print string
	la   $a0, sumTitle		# Set $a0 to sumTitle
	syscall				# Print "Summation..."
	la   $a0, integer_n		# Set $a0 to integer_n
	syscall				# Print "Please..."
	addi $v0, $zero, 5		# Syscall 5: Read integer
	syscall				# Read an integer
	add  $s0, $zero, $v0		# $s0 is n
	add  $a0, $zero, $s0		# Set argument for _sum
	jal  _sum			# Call the _sum function
	add  $s1, $zero, $v0		# $s1 = sum(n)
	# Print result (sum)
	addi $v0, $zero, 4		# Syscall 4: Print string
	la   $a0, sumResult		# Set $a0 to sumResult
	syscall				# Print "sum("
	addi $v0, $zero, 1		# Syscall 1: Print integer
	add  $a0, $zero, $s0		# Set $a0 to n
	syscall				# Print n
	addi $v0, $zero, 4		# Syscall 4: Print string
	la   $a0, isMsg			# Set $a0 to isMsg
	syscall				# Print ") is "
	addi $v0, $zero, 1		# Syscall 1: Print integer
	add  $a0, $zero, $s1		# Set $a0 to result of sum
	syscall				# Print result
	addi $v0, $zero, 4		# Syscall 4: Print string
	la   $a0, period		# Set $a0 to period
	syscall				# Print ".\n"

	# Power
	addi $v0, $zero, 4		# Syscall 4: Print string
	la   $a0, powTitle		# Set $a0 to powTitle
	syscall				# Print "Summation..."
	la   $a0, integer_x		# Set $a0 to integer_x
	syscall				# Print "Please..."
	addi $v0, $zero, 5		# Syscall 5: Read integer
	syscall				# Read an integer
	add  $s0, $zero, $v0		# $s0 is x
	addi $v0, $zero, 4		# Syscall 4: Print string	
	la   $a0, integer_y		# Set $a0 to integer_y
	syscall				# Print "Please..."
	addi $v0, $zero, 5		# Syscall 5: Read integer
	syscall				# Read an integer
	add  $s1, $zero, $v0		# $s1 is y
	add  $a0, $zero, $s0		# Set argument x for _pow
	add  $a1, $zero, $s1		# Set argument y for _pow
	jal  _pow			# Call the _pow function
	add  $s2, $zero, $v0		# $s2 = pow(x,y)
	# Print result (pow)
	addi $v0, $zero, 4		# Syscall 4: Print string
	la   $a0, powResult		# Set $a0 to powResult
	syscall				# Print "pow("
	addi $v0, $zero, 1		# Syscall 1: Print integer
	add  $a0, $zero, $s0		# Set $a0 to x
	syscall				# Print x
	addi $v0, $zero, 4		# Syscal 4: Print string
	la   $a0, comma			# Set $a0 to comma
	syscall				# Print ","
	addi $v0, $zero, 1		# Syscall 1: Print integer
	add  $a0, $zero, $s1		# Set $a0 to y
	syscall				# Print y
	addi $v0, $zero, 4		# Syscall 4: Print string
	la   $a0, isMsg			# Set $a0 to isMsg
	syscall				# Print ") is "
	addi $v0, $zero, 1		# Syscall 1: Print integer
	add  $a0, $zero, $s2		# Set $a0 to result of pow
	syscall				# Print result
	addi $v0, $zero, 4		# Syscall 4: Print string
	la   $a0, period		# Set $a0 to period
	syscall				# Print ".\n"

	# Fibonacci
	addi $v0, $zero, 4		# Syscall 4: Print string
	la   $a0, fTitle		# Set $a0 to fTitle
	syscall				# Print "Fibonacci..."
	la   $a0, integer_n		# Set $a0 to integer_n
	syscall				# Print "Please..."
	addi $v0, $zero, 5		# Syscall 5: Read integer
	syscall				# Read an integer
	add  $s0, $zero, $v0		# $s0 is n
	add  $a0, $zero, $s0		# Set argument for _fibonacci
	jal  _fibonacci			# Call the _fabonacci function
	add  $s1, $zero, $v0		# $s1 = fibonacci(n)
	# Print result (fibonacci)
	addi $v0, $zero, 4		# Syscall 4: Print string
	la   $a0, fResult		# Set $a0 to sumResult
	syscall				# Print "F("
	addi $v0, $zero, 1		# Syscall 1: Print integer
	add  $a0, $zero, $s0		# Set $a0 to n
	syscall				# Print n
	addi $v0, $zero, 4		# Syscall 4: Print string
	la   $a0, isMsg			# Set $a0 to isMsg
	syscall				# Print ") is "
	addi $v0, $zero, 1		# Syscall 1: Print integer
	add  $a0, $zero, $s1		# Set $a0 to result of fibonacci
	syscall				# Print result
	addi $v0, $zero, 4		# Syscall 4: Print string
	la   $a0, period		# Set $a0 to period
	syscall				# Print ".\n"
	# Terminate Program
	addi $v0, $zero, 10		# Syscall 10: Terminate program
	syscall				# Terminate Program

# _sum
#
# Recursively calculate summation of a given number
#   sum(n) = n + sum(n - 1)
# where n >= 0 and sum(0) = 0.
#
# Argument:
#   $a0 - n
# Return Value:
#   $v0 = sum(n)
_sum:
	addi $sp, $sp, -8	# Allocate space on the stack
	sw $ra, 0($sp)		# Store the return address
	sw $a0, 4($sp)		# Store the argument
	
	slti $s0, $a0, 1	# $s0 = n; check to make sure it's negative
	beq $s0, $zero, _sumRecurse	
	add $v0, $zero, $zero	# Return start value to 0
	addi $sp, $sp, 8	# Pop two items
	jr   $ra
	
	_sumRecurse:
		addi $a0, $a0, -1
		jal _sum
		
		lw $ra, 0($sp)
		lw $a0, 4($sp)
		addi $sp, $sp, 8
		
		add $v0, $a0, $v0
		jr $ra

# _pow
#
# Recursively calculate x^y
#   x^y = x * (x^(y - 1))
# where x >= 0 and y >= 0
#
# Arguments:
#   - $a0 - x
#   - $a1 - y
# Return Value
#   - $v0 = x^y
_pow:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	bne $a1, $zero, continue
	addi $v0, $zero, 1
	addi $sp, $sp, 4
	jr   $ra
	
	continue:
		bne $a1, 1, next
		add $v0, $zero, $a0
		addi $sp, $sp, 4
		jr $ra
	next: 
		andi $t0, $t1,1        
        	bne $t0, $zero, next2   
        	srl $a1, $a1, 1       
        	jal _pow      
        	mul $v0, $v0, $v0       
        	lw $ra, 0($sp)
        	addi $sp, $sp, 4
        	jr $ra
   	next2:
   	    	addi $a1, $a1, -1        
        	jal _pow
        	lw $ra, 0($sp)
                addi $sp, $sp, 4
        	mul $v0, $v0, $a0
        	jr $ra

# _fibonacci
#
# Calculate a Fibonacci number (F) where
#   F(0) = 0
#   F(1) = 1
#   F(n) = F(n - 1) + F(n - 2)
# Argument:
#   $a0 = n
# Return Value:
#   $v0 = F(n)
_fibonacci:
	addiu $sp, $sp, -8
    	sw $a0, 0($sp)
   	sw $ra, 4($sp)

    	sltiu $t0, $a0, 2
    	beq $t0, $zero, one

    	move $v0, $a0
    	j two

	one:
    		addiu $a0, $a0, -1
    		jal _fibonacci
    		addiu $sp, $sp, -4
    		sw $v0,0($sp)
	
    		addiu $a0, $a0, -1
   		jal _fibonacci

    		lw $t0,0($sp)
    		addiu $sp, $sp, 4
    		addu $v0, $v0, $t0

	two:
    		lw $ra, 4($sp)
   		lw $a0, 0($sp)
    		addiu $sp, $sp, 8
    		jr $ra