WeChat: cstutorcs
QQ: 749389476
Email: tutorcs@163.com
.data
	buffer: .space	102
	bmpHeader: .space	15
	.align	2
	dibHeader: .space	4
	enterMsg: .asciiz "Please enter a filename: "
	fileSize: .asciiz "The size of the BMP file (bytes): "
	firstTwoChar: .asciiz "The first two characters: "
	startAdd: .asciiz "The starting address of image data: "
	imgWidth: .asciiz "Image imgWidth (pixels): "
	imgHeight: .asciiz "Image imgHeight (pixels): "
	colorPanes: .asciiz "The number of color colorPanes: "
	bitsPer: .asciiz "The number of bits per pixel: "
	compMethod:	.asciiz "The compression method: "
	rawData:	.asciiz "The size of raw bitmap data (bytes): "
	horRes: .asciiz "The horizontal resolution (pixels/meter): "
	vertRes:	.asciiz "The vertical resolution (pixels/meter): "
	numColors: .asciiz "The number of colors in the color palette: "
	numImpColors: .asciiz "The number of important colors used: "
	indexZero: .asciiz "The color at index 0 (B G R): "
	indexOne: .asciiz "The color at index 1 (B G R): "	
	newLine: .asciiz "\n"
	space: .asciiz " "
	
.text
	addi $v0, $zero, 4		# Syscall 4: _print string
	la   $a0, enterMsg		# _print out the enter message
	syscall			
	
	addi $v0, $zero, 8		# Syscall 8: Read string
	la   $a0, buffer			# Set the buffer in $a0
	addi $a1, $zero, 100		# Set the maximum input size to 100
	syscall
	
	la $t0, buffer       	# Load buffer address into $t0 (will need to incremenet to read chars)
   add $t1, $zero, $zero   # $t1 is reset
	
_removeNewLine:
	lbu $t1, 0($t0)		# Load next character (1 byte) from buffer into $t1

	beq $t1, 10, endLoop	# Test for lf, if no lf, then end of string
	addi, $t0, $t0, 1	# Increase counter by 1 (1 char is 1 byte)
	j _removeNewLine

endLoop:
	sb $zero, 0($t0)		# Replace lf char with null 
	
_openFile:
	addi $v0, $zero, 13	# Syscall 13: Open file
	la   $a0, buffer		# $a0 has address of the buffer
	add  $a1, $zero, $zero	# Set $a1 = 0
	add  $a2, $zero, $zero	# Set $a2 = 0
	syscall			
	add  $s0, $zero, $v0	# Copy the file descriptor into $s0
	
_readFile:
	addi $v0, $zero, 14	# Syscall 14: Read file
	add  $a0, $zero, $s0	# $a0 is the file descriptor
	la   $a1, bmpHeader	# $a1 is the address of a buffer
	addi $a2, $zero, 14	# $s2 is the number of bytes to read
	syscall			
	
_readFirstTwo:
	la   $a0, firstTwoChar
	add  $v0, $zero, 4		# Syscall 4: _print string
	syscall				
	
	la   $s1, bmpHeader	# Set $s1 to the address of the header
	
	addi $v0, $zero, 11	# Syscall 11: _print character
	lb   $a0, 0($s1)	# $a0 is the first byte of header
	syscall			
	lb   $a0, 1($s1)	# $a0 is the second byte of header
	syscall			
	jal _insertNewLine		# Will put in a new line
	
__printFileSize:
	la   $a0, fileSize
	add  $v0, $zero, 4		# Syscall 4: _print string
	syscall			
	
	addi $v0, $zero, 1		# Syscall 1: _print integer
	lw   $a0, 2($s1)		# $a0 is the first 4-byte integer
	syscall			
	jal _insertNewLine			# Will put in a new line
	
__printStartAddress:
	la   $a0, startAdd
	add  $v0, $zero, 4		# Syscall 4: _print string
	syscall			
	
	addi $v0, $zero, 1		# Syscall 1: _print integer
	lw   $a0, 10($s1)			# $a0 = data offset by 10
	add $s2, $zero, $a0		# Copy data offset into $s2
	syscall			
	jal _insertNewLine				# Will put in a new line
	
_readDIBbmpHeader:
	addi $v0, $zero, 14		# Syscall 14: Read file
	add  $a0, $zero, $s0		# $a0 is the file descriptor
	la   $a1, dibHeader		# $a1 is the address of a buffer
	addi $a2, $zero, 4		# $a2 is the number of bytes to read
	syscall		
		
_allocateMemory:
	addi $v0, $zero, 9		# Syscall 9: Allocate heap memory
	lw  $a0, dibHeader		
	addi $a0, $a0, -4			# Subtract DIB - 4 bytes
	syscall				
	add  $s3, $zero, $v0		# Store address of DIB into $s3
	
_readDIBFile:
	addi $v0, $zero, 14		# Syscall 14: Read file
	add  $a0, $zero, $s0		# $a0 is the file descriptor
	add  $a1, $zero, $s3		# $a1 is the address of a buffer ($s3 = DIB)
	lw $a2, dibHeader			# $a2 is the number of bytes to read (DIB bmpHeader - 4)
	addi $a2, $a2, -4
	syscall			
	
__printImgimgWidth:
	add  $v0, $zero, 4		# Syscall 4: _print string
	la   $a0, imgWidth
	syscall			
	
	addi $v0, $zero, 1		# Syscall 1: _print integer
	lw   $a0, 0($s3)			# Offset by 0
	syscall			
	jal _insertNewLine				# Will put in a new line

__printImgimgHeight:
	add  $v0, $zero, 4		# Syscall 4: _print string
	la   $a0, imgHeight
	syscall			
	
	addi $v0, $zero, 1		# Syscall 1: _print integer
	lw   $a0, 4($s3)			# Offset by 4
	syscall		
	jal _insertNewLine				# Will put in a new line

__printColorPanes:
	add  $v0, $zero, 4		# Syscall 4: _print string
	la   $a0, colorPanes
	syscall		
	
	addi $v0, $zero, 1		# Syscall 1: _print integer
	lh   $a0, 8($s3)			# Offset by 8
	syscall		
	jal _insertNewLine				# Will put in a new line

__printBitNum:
	add  $v0, $zero, 4		# Syscall 4: _print string
	la   $a0, bitsPer			
	syscall			
	
	addi $v0, $zero, 1		# Syscall 1: _print integer
	lh   $a0, 10($s3)			# Offset by 10
	syscall			
	jal _insertNewLine				# Will put in a new line

__printCompression:
	add  $v0, $zero, 4		# Syscall 4: _print string
	la   $a0, compMethod
	syscall		
	
	addi $v0, $zero, 1		# Syscall 1: _print integer
	lw   $a0, 12($s3)			# Offset by 12
	syscall		
	jal _insertNewLine				# Will put in a new line

__printRawData:
	add  $v0, $zero, 4		# Syscall 4: _print string
	la   $a0, rawData
	syscall			
	
	addi $v0, $zero, 1		# Syscall 1: _print integer
	lw   $a0, 16($s3)			# Offset by 16
	syscall 
	jal _insertNewLine				# Will put in a new line

__printHorRes:
	add  $v0, $zero, 4		# Syscall 4: _print string
	la   $a0, horRes
	syscall			
	
	addi $v0, $zero, 1		# Syscall 1: _print integer
	lw   $a0, 20($s3)			# Offset by 20
	syscall																								
	jal _insertNewLine				# Will put in a new line

__printVertRes:
	add  $v0, $zero, 4		# Syscall 4: _print string
	la   $a0, vertRes
	syscall			
	
	addi $v0, $zero, 1		# Syscall 1: _print integer
	lw   $a0, 24($s3)			# Offset by 24
	syscall			
	jal _insertNewLine				# Will put in a new line

__printNumColors:
	add  $v0, $zero, 4		# Syscall 4: _print string
	la   $a0, numColors
	syscall				
	
	addi $v0, $zero, 1		# Syscall 1: _print integer
	lw   $a0, 28($s3)			# Offset by 28
	syscall			
	jal _insertNewLine				# _print a new line
  
 __printnumImpColors:
	add  $v0, $zero, 4		# Syscall 4: _print string
	la   $a0, numImpColors
	syscall			
	
	addi $v0, $zero, 1		# Syscall 1: _print integer
	lw   $a0, 32($s3)			# Offset by 32
	syscall			

	add $t0, $zero, $a0		# Copy number of important colors into $t0
	jal _insertNewLine				# Insert a new line

__printColors:
	addi $v0, $zero, 9		# Syscall 9: Allocate heap memory
	sll $a0, $t0, 2			# $a0 = Accomodate 4 bytes for each color
	syscall			
	add  $s4, $zero, $v0		# Store address of colors in $s4
	
_readColors:
	addi $v0, $zero, 14	# Syscall 14: Read file
	add $a2, $zero, $a0	# $a2 is the number of bytes to read (still stored in $a0)
	add  $a0, $zero, $s0	# $a0 is the file descriptor
	add  $a1, $zero, $s4	# $a1 is the address of a buffer ($s4 = colors)
	syscall			# Read file
	
__printIndexZero:
	add  $v0, $zero, 4		# Syscall 4: _print string
	la   $a0, indexZero
	syscall			
	
	addi $v0, $zero, 1			# Syscall 1: _print integer
	lbu   $a0, 0($s4)			# Load blue color
	syscall			
	
	jal _insertSpace					# Inserts a space character
	
	addi $v0, $zero, 1			# Syscall 1: _print integer
	lbu   $a0, 1($s4)			# Inserts green color
	syscall			
	
	jal _insertSpace					# Inserts a space

	addi $v0, $zero, 1			# Syscall 1: _print integer
	lbu   $a0, 2($s4)			# Inserts a red color
	syscall			
	jal _insertNewLine				# Insert a new line

__printIndexOne:
	add  $v0, $zero, 4		# Syscall 4: _print string
	la   $a0, indexOne
	syscall			
	
	addi $v0, $zero, 1		# Syscall 1: _print integer
	lbu   $a0, 4($s4)			# Insert blue
	syscall			
	jal _insertSpace					# Insert a space	
	addi $v0, $zero, 1		# Syscall 1: _print integer
	lbu   $a0, 5($s4)		# Insert green
	syscall			
	jal _insertSpace				# Insert a space
	addi $v0, $zero, 1		# Syscall 1: _print integer
	lbu   $a0, 6($s4)		# Insert red
	add $t7, $zero, $a0
	syscall			

	sll $t7, $t7, 24
	sra $s7, $t7, 24
		
__printOutImage:
	# Allocate memory to store image data
	addi $v0, $0, 9		# Syscall 9: Allocate heap memory
	lw   $a0, 16($s3)	# $a0 = raw size of image ($s3 is address of DIB header)	
	syscall			# Allocate memeory
	add  $s5, $0, $v0	# Store address of image data in $s5
	
_readImageData:
	addi $v0, $0, 14	# Syscall 14: Read file
	add $a2, $0, $a0	# $a2 is the number of bytes to read 
	add  $a0, $0, $s0	# $a0 = file descriptor ($s0)
	add  $a1, $0, $s5	# $a1 is the address of a buffer
	syscall			

	lw   $s0, 0($s3)	# Get horizontal size
	
	lw   $s1, 4($s3)	# Get vertical size
	lw   $s2, 16($s3)	# Get raw data size
	
	div $s2, $s1		
	mflo $s3		

	add $s5, $s5, $s2 	
	sub $s5, $s5, $s3	
	sw $s5, buffer		
	
	addi $t7, $0, 8
	mult $t7, $s3
	mflo $t7
	sw $t7, buffer+4	
	
	add $s6, $0, $0		# Will keep track of current index of byte in the current row
	addi $t4, $0, 1		# Counter for number of times the memory pointer was moved down 8 rows
__printLoop: 
	blez $s1, _donePrinting	
	add $s4, $0, $0		# Reset $s4
	add $s6, $0, $0		# Reset $s6
	
	_getNumBytes:	
		bge $s4, $s0 _deadSpace	
		
		addi $s6, $s6, 1	# Incrase counter by 1
		add $t0, $0, $0	# Resets $t0 to 0
		add $t1, $0, $0	# Resets $t1 to 0
		add $t2, $0, $0	# Resets $t2 to 0
		add $t3, $0, $0	# Resets $t3 to 0
		add $t6, $0 $0		# Resets $t6 to 0
		
	_mainLoop:
		addi $t7, $s1, -1	# Check if there's another row to get data from
		add $t3, $0, $0		# Resets $t3 to 0
		add $t5, $0, $0		# Resets $t5 to 0
		
		_upperHalf:
			beq $t3, 4, _lowHalf	# Loop runs 4 times
			sll $t1, $t1, 8		# Shift left 8 bits to make room for next byte
			ble $t3, $t7, _nextUpper	
			j continue1
			
			_nextUpper:	lbu $t0, 0($s5)		
					sub $s5, $s5, $s3
					or $t1, $t1, $t0	
					addi $t5, $t5, 1	
			continue1:	addi $t3, $t3, 1	# Increase $t3 by 1
			
		j _upperHalf
		
		_lowHalf:
			beq $t3, 8, _movePointer	# Loop runs 4 times 
			sll $t2, $t2, 8		# Shift left 8 bits to make room for next byte
			ble $t3, $t7, _nextLower	
			j _keepGoing
			
			_nextLower:	
				lbu $t0, 0($s5)		
				sub $s5, $s5, $s3	
				or $t2, $t2, $t0	
				addi $t5, $t5, 1	# Move 1 row down
			_keepGoing:	addi $t3, $t3, 1	# Increase counter by 1
		j _lowHalf
		
		_movePointer:
			addi $t7, $s4, 1	# Check to make sure there's one more pixel in the row
			bgt  $t7,  $s0, _deadSpace # If no pixels remain in the row, move down 8 rows
			add $t3, $0, $0		# Reset $t3 to 0
		_column:
			beq $t3, $t5, _moveMemPointer	# Run loop 8 times total
 				add $s5, $s5, $s3	
				addi $t3, $t3, 1	# Increase $t3 by 1
		j _column
	
		_moveMemPointer: # Move memory pointer 1 byte to the right to get next 8 bits
			addi $s5, $s5, 1	
			j _loadPrintStart
		
		_moveDown: 
			lw $s5, buffer		# Restore last beginning of line from buffer
			lw $t7, buffer + 4	
			sub $s5, $s5, $t7	# Subtract 8 lines from last starting position
			sw $s5, buffer		# Save updated position to the buffer
			beq $s4, $s0, _deadSpace

	_loadPrintStart:
		add $t8, $0, $0			
		beq $t1, 0xffffffff, _checkColor # Check for whether it is white or black
		beqz  $t1, _checkColor	 
			j continue
			
	_checkColor:	beq  $t2, $t1 __printLine8
		beqz $t1, _numberFour
		
	continue:
		add $t7, $0, 0x80000000	# This is to get the 8th bit
		
		and $t3, $t1, $t7	
		srl $t3, $t3, 24	
		or $t8, $t8, $t3	
		srl $t7, $t7, 8	
		
		and $t3, $t1, $t7	
		srl $t3, $t3, 17	
		or $t8, $t8, $t3	
		srl $t7, $t7, 8	

		and $t3, $t1, $t7	
		srl $t3, $t3, 10	
		or $t8, $t8, $t3	
		srl $t7, $t7, 8	
					
		and $t3, $t1, $t7	
		srl $t3, $t3, 3	
		or $t8, $t8, $t3	
			
	_numberFour:	
		add $t7, $0, 0x80000000
		and $t3, $t2, $t7	# This will grab the 8th bit
		srl $t3, $t3, 28	
		or $t8, $t8, $t3	
		srl $t7, $t7, 8

		and $t3, $t2, $t7	 # 4th bit
		srl $t3, $t3, 21
		or $t8, $t8, $t3	
		srl $t7, $t7, 8		

		and $t3, $t2, $t7	# 2nd bit
		srl $t3, $t3, 14	
		or $t8, $t8, $t3	
		srl $t7, $t7, 8		
		
		and $t3, $t2, $t7	# 1st bit
		srl $t3, $t3, 7	
		or $t8, $t8, $t3	
		
		sll $t1, $t1, 1	# Shift higher bits 1 bit to the left
		sll $t2, $t2, 1	# Shift lower bits 1 bit to the left 
				
_loadPrintHead:
		xor $t8, $t8, $s7
		
		_print:
			addi $t9, $0, 1		# Set $t9 to 1 
		_wait: 	bne  $t9, $0, _wait	# Must until $t9 is 0
		
		addi $s4, $s4, 1	# Add 1 to total column of numbers printed
		beq $s4, $s0, _deadSpace

		addi $t6, $t6, 1		# Increment counter to check if there is data left in $t1/$t2 to _print
		blt $t6, 8, _loadPrintStart	# Check if there are any columns left to _print in $t1/$t2
		
		j _getNumBytes

__printLine8:
	add $t7, $0, $0
	xor $t8, $s7, $t1
	_print8:
		beq $t7, 8, _getNumBytes

		addi $t7, $t7, 1	# Increment $t7
		addi $t9, $0, 1	# Set $t9 to 1
		
	_keepWaiting: 	bne  $t9, $0, _keepWaiting	# Must wait until $t9 is 0

		addi $s4, $s4, 1	
		beq $s4, $s0, _deadSpace
		
		addi $t6, $t6, 1	# Increement $t6
		blt $t6, 8, _print8 # Must check if there are any other columns

	j _getNumBytes
	
_deadSpace:	
	addi $t8, $0,0		# Set printing head to 0 for white
	add $t7, $0, $s0	
	
	__printDeadSpace:
		bge  $t7, 480, _endOfLine
		addi $t7, $t7, 1	# Increment $t7
		addi $t9, $0, 1	# Set $t9 to 1 for printing
		
	__continueWait: 	bne  $t9, $0, __continueWait	# Must wait until $t9 is 0

		j __printDeadSpace	# Print all the dead space
	
_endOfLine: 
	lw $s5, buffer
	lw $t7, buffer + 4	# Add 4 to buffer
	sub $s5, $s5, $t7
	sw $s5, buffer
	addi $s1, $s1, -8	 # Subtract 8 rows
	j __printLoop
	
_donePrinting:
	_closeFile:
	add  $v0, $0, 16	# Syscall 16: Close file
	add  $a0, $0, $s0	
	syscall			
	
_finish:
	addi $v0, $0, 10	# Syscall 10: Terminate program
	syscall			

_insertNewLine: la   $a0, newLine
	j __printString

_insertSpace: la   $a0, space

__printString:
	add  $v0, $0, 4		# Syscall 4: _print string
	syscall			
	jr $ra
