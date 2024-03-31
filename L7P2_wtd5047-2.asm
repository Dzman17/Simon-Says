#Simon Says part 2 (colored blocks)
#William Deasy
#WTD5047
#3/23/24

.data

#stack
stack_beg:
        	.word   	0 : 40
stack_end:

#game prompts
startPrompt:	.asciiz		"SIMON SAYS"
EASY:		.asciiz		"1: EASY"
MEDIUM:		.asciiz		"2: MEDIUM"
HARD:		.asciiz		"3: HARD"
enterPrompt:	.asciiz		"\nEnter 1 for blue, 2 for green, 3 for red and 4 for cyan and then press enter\n"
continuePrompt:	.asciiz		"Correct enter next in sequence\n"
winPrompt:	.asciiz		"\nWinner"
losePrompt:	.asciiz		"\nLoser"
error:		.asciiz		"\nError"
one:		.asciiz		"1"
two:		.asciiz		"2"
three:		.asciiz		"3"
four:		.asciiz		"4"
GameOver:	.asciiz		"GAME OVER"
YouWin:		.asciiz		"YOU WIN"

#colors
blue:		.asciiz		"\nBlue (1)"
red:		.asciiz		"\nRed (2)"
yellow:		.asciiz		"\nYellow (3)"
green:		.asciiz		"\nGreen (4)"

#sequence
sequence:	.word		0,0,0,0,0,0,0,0,0,0,0

#random generator
max:		.word		0
genID:		.word		0
seed:		.word		0
randomNum:	.word		0

#color Table
ColorTable:
		.word		0x000000	#black
		.word		0x0000ff	#blue
		.word		0x00ff00	#green
		.word		0xff0000	#red
		.word		0x00ffff	#blue + green
		.word		0xff00ff	#blue + red
		.word		0xffff00	#green + red
		.word		0xffffff	#white

BoxSimp:
		.word		128,64,1,124,58,one,60,100,36		#blue circle
		.word		192,128,2,188,122,two,62,164,100	#green circle
		.word		64,128,3,60,122,three,64,36,100		#red circle
		.word		128,192,4,124,,186,four,66,100,164	#blue + green circle
		
CircleValues:	.word		11,17,23,27,31,33,35,37,39,41,43,45,47,47,49,49,51,51,51,53,53,53,55,55,55,55,55,55,55,55,55,55,55,53,53,53,51,51,51,49,49,47,47,45,43,41,39,37,35,33,31,27,23,17,11		

.text
main:
#load stack end
	la	$sp, stack_end
	jal	ClearDisplay
	#PRINT TITLE
	li	$a0,80				#load x value for text display
	li	$a1,88				#load y value for text display
	la	$a2,startPrompt			#specify string to print
	jal	OutText				#jump and link to text display procedure
	#PRINT EASY
	li	$a0,84				#load x value for text display
	li	$a1,112				#load y value for text display
	la	$a2,EASY			#specify string to print
	jal	OutText				#jump and link to text display procedure
	#PRINT MEDIUM
	li	$a0,84				#load x value for text display
	li	$a1,130				#load y value for text display
	la	$a2,MEDIUM			#specify string to print
	jal	OutText				#jump and link to text display procedure
	#PRINT HARD
	li	$a0,84				#load x value for text display
	li	$a1,148				#load y value for text display
	la	$a2,HARD			#specify string to print
	jal	OutText				#jump and link to text display procedure
	
#Print start prompt
	la	$a0,startPrompt			#load address of startPrompt
	li	$v0,4				#specify print string service
	syscall					#print the starting prompt
#User selection
	jal	GetChar	
	
#load arguments
	la	$a0,sequence			#load address of sequence into $a0
	la	$a1,max				#load address of max into $a1
#clear values
	addi	$sp,$sp,-4
	sw	$v0,0($sp)
	jal	initialize			#jump and link to initialize
	lw	$v0,0($sp)
	addi	$sp,$sp,4

#difficulty check
	beq	$v0,48,quit			#jump to quit tag if user entered 0
	beq	$v0,49,easy			#jump to easy tag if user entered 1
	beq	$v0,50,medium			#jump to medium tag if user entered 2
	beq	$v0,51,hard			#jump to hard tag if user entered 3
	j	userError			#jump to userError if user input doesn't match correct choices
	
#difficulty set
easy:	li	$t0,5				#load max value of 5 into $t0
	sw	$t0,max				#store value from $t0 into max
	j	L0				#jump to L0 tag to continue
	
medium:	li	$t0,8				#load max value of 8 into $t0
	sw	$t0,max				#store value from $t0 into max
	j	L0				#jump to L0 tag to continue
	
hard:	li	$t0,11				#load max value of 11 into $t0
	sw	$t0,max				#store value from $t0 into max
	j	L0				#jump to L0 tag to continue
	
L0:	li	$t6,0				#store value 0 into $t6 as a counter
	lw	$t5,max				#load value from max into $t5

#main loop 	
mainLoop:
	la	$a0,genID			#load address of genID into $a0
	la	$a1,seed			#load address of seed into $a1
#get random	
	jal	randomGen			#jump and link to randomGen
	sw	$v0,randomNum			#save the random number from $v0 into randomNum
	
	la	$a0,sequence			#load address of sequence into $a0
	la	$a1,randomNum			#load address of randomNum into $a1
	
	move	$t7,$t6				#copy counter value from $t6 into $t7
	sll	$t7,$t7,2			#multiply counter value by 4
	add	$a0,$a0,$t7			#move address in $a0 by counter value * 4
	addi	$t6,$t6,1			#increment counter by 1
#build the sequence	
	jal	buildSequence			#jump and link to build sequence
	bne	$t6,$t5,mainLoop		#if counter value is less than max, jump to mainLoop
	
#Gameplay
	li	$t6,1				#set counter to 1
	lw	$t5,max				#load value from max into $t5
uCheck:
	li	$a0,500
	li	$v0,32
	syscall
	la	$a0,sequence			#load address of sequence into $a0
	move	$a1,$t6				#load address of max into $a1
	addi	$sp,$sp,-8			#make room on the stack
	sw	$t6,4($sp)			#store $t6 on the stack
	sw	$t5,0($sp)			#store $t5 on the stack
#displays sequence on screen with circles
	jal	showSeq				#Shows the current sequence on the screen
	lw	$t6,4($sp)			#resores $t6 from the stack
	lw	$t5,0($sp)			#restores $t5 from the stack
	la	$a0,sequence			#load address of sequence into $a0
	move	$a1,$t6				#load address of max into $a1
#allows user to enter the sequence and checks if it is correct one at a time.
	jal	checkinput			#jump and link to checkinput
	lw	$t6,4($sp)			#resores $t6 from the stack
	lw	$t5,0($sp)			#restores $t5 from the stack
	addi	$t6,$t6,1			#increment counter by 1
	beq	$v0,1,loser
	ble	$t6,$t5,uCheck			#if counter value is less than max, jump to mainLoop
	addi	$sp,$sp,8			#returns stack to previous position
#check if winner or loser	
	beq	$v0,1,loser			#if value in $v0 is 1, jump to loser tag
	beq	$v1,0,winner			#if value in $v0 is 0, jump to winner tag

#print loser prompt	
loser:	la	$a0,losePrompt			#load loserPrompt string into $a0
	li	$v0,4				#specify print string service
	syscall					#print the loseprompt
	li	$t1,0				#set counter to 0
LosL:	li	$v0,31				#specify Midi Output procedure
	li	$a0,44				#specify the pitch
	li	$a1,500				#specify length of tone
	li	$a2,88				#specify the instrument of tone
	li	$a3,127				#specify volume of tone
	syscall					#perform Midi Tone syscall
	li	$v0,32
	li	$a0,500
	syscall
	addi	$t1,$t1,1
	bne	$t1,5,LosL
	
	jal	ClearDisplay
	
	li	$a0,75			#load x value for text display
	li	$a1,122			#load y value for text display
	la	$a2,GameOver
	jal	OutText				#jump and link to text display procedure
	j	main				#return back to main
#print winner prompt
winner:	la	$a0,winPrompt			#load winPrompt string into #a0
	li	$v0,4				#specify print string service
	syscall					#print the winPrompt
	j	main				#return back to main
#exit program	
quit:
	li   	$v0, 10          		#specify exit system call
      syscall   				#exit

#IsCharThere
#checking to see if a character is present
#returns $v0 = 0 (no Data) or 1 (Character in the buffer)
IsCharThere:
	lui	$t0,0xffff			#reg @oxffff0000
	lw	$t1,0($t0)			#get control
	and	$v0,$t1,1			#look at least significant bit
	jr 	$ra
	      
#GetChar
#poll the keypad, wait for an input character
#returns with $v0 = Ascii Character
GetChar:
	addi	$sp,$sp,-4
	sw	$ra,0($sp)
	j	check
CLoop:	
	li	$a0,50
	li	$v0,32
	syscall	
check:	jal	IsCharThere			
	beq	$v0,$0,CLoop			#if no data try later
	lui	$t0,0xffff			 
	lw	$v0,4($t0)			#get char in oxffff0004
	
	lw	$ra,0($sp)
	addi	$sp,$sp,4
	jr	$ra           
                        
#print error prompt and restart program            
userError:
	la	$a0,error			#load error string into $a0
	li	$v0,4				#specify print string service
	syscall					#print error string
	j	main				#return back to main
	
#initialize	
#clear everything to start a new game
#$a0 - pointer to sequence
#$a1 - pointer to max
initialize:
	li	$t0,11				#load max number of sequence parts into $t0
	li	$t1,0				#load counter value 0 into $t1
L1:	
	sw	$0,0($a0)			#save value 0 into sequence
	addi	$t1,$t1,1			#increment counter by 1
	addi	$a0,$a0,4			#move address in $a0 by 4
	bne	$t1,12,L1			#break to L1 tag once counter reaches 12
	
	sw	$t1,0($a1)			#reset value of max to 0
	addi	$sp,$sp,-4
	sw	$ra,0($sp)
	jal	ClearDisplay
	lw	$ra,0($sp)
	addi	$sp,$sp,4
	jr	$ra				#return from function
	

#randomGen
#returns a random number for the sequence
#$a0 - pointer to genID
#$a1 - pointer to seed
#$v0 - random number (1-4)
randomGen:
	
	
	sw	$0,0($a0)			#set generator to zero
	
	move	$t0,$a0				#move value from $a0 into $t0
	move	$t1,$a1				#move address of seed value to $t1
	
	#Random Number (initial seed)
	li	$v0,30				#specify system time service
	syscall					#places 32 bit system time in $a0
	sw	$a0,0($t1)			#moves system time data into address stored in $t1 (seed)
	
	lw	$a0, 0($t0)			#load the genID value of zero into $a0
	lw	$a1, 0($t1)			#load the seed value in $a1
	li	$v0,40				#specify set seed service
	syscall					#sets the seed
	sw	$a1,0($t1)			#stores the value in $a1 to $t1
	
	li	$a0,16				#setss $a0 to 10
	li	$v0,32				#specify sleep service, ensures a more random result
	syscall					#sleep
	
	li	$a1,4				#upper bound will return 0-3
	li	$v0,42				#specify random integer range, returns result in $a0
	syscall					#create random number from 0-3
	addi	$a0,$a0,1			#add 1 to make it 1-4
	move	$v0,$a0				#move result to $v0
	
	jr	$ra
	
#buildSequence
#adds the random number to the sequence
#$a0 - pointer to sequence
#$a1 - pointer to randomNum
buildSequence:
	lw	$t0,0($a1)			#load random number from $a1
	sw	$t0,0($a0)			#save random number at current position of sequence stored in $a0
	jr	$ra				#return from function
	
	
#showSeq
#displays sequence to player
#$a0 - pointer to sequence
#$a1 - pointer to max
showSeq:
	li	$s1,0				#counter
	move	$s2,$a1				#copy address of max into $s2
	move	$s3,$a0				#address of sequence stored in $s3

	addi	$sp,$sp,-36			#make room on the stack for 6 words
	sw	$s3,32($sp)
	sw	$ra,28($sp)
	sw	$s2,24($sp)
	sw	$s1,20($sp)

	jal	DrawX
L2:	
	lw	$a0,0($s3)

	jal 	CircleSwitch
	
	
cont:	lw	$s3,32($sp)
	lw	$ra,28($sp)
	lw	$s2,24($sp)
	lw	$s1,20($sp)

#increment	
	addi	$s3,$s3,4			#increment sequence by 1 word
	addi	$s1,$s1,1			#increment counter by 1
	sw	$s1,20($sp)
	sw	$s3,32($sp)

#sleep	
	li	$a0,1000			#set sleep value to 1000
	li	$v0,32				#specify sleep service
	syscall					#sleep
#restore important values	
	lw	$ra,28($sp)
	lw	$s2,24($sp)
	lw	$s1,20($sp)

	bne	$s1,$s2,L2			#return to L2 until counter reaches max value
	
	addi	$sp,$sp,36			#restores stack position
	
	
	jr	$ra				#return from function
	
#CircleSwitch
#a0 = circle number 1-4
CircleSwitch:
	move	$t3,$a0				#load number from sequence			
	la	$t0,BoxSimp			#load address of BoxSimp Table
	addi	$t3,$t3,-1			#box number -1
	li	$s5,36				#value to multiple box number by
	multu 	$t3,$s5				#multiply box number by 36
	mflo	$t3				#move value from mult to $t3
	add	$t3,$t0,$t3			#add BoxSimp Address from value in $t3 and set to $t6
	addi	$sp,$sp,-8
	sw	$ra,4($sp)
	sw	$t3,0($sp)
	lw 	$a0,0($t3)			#load x value from jump table into $a0
	lw	$a1,4($t3)			#load y value from jump table into $a1
	lw	$a2,8($t3)			#load color value from jump table into $a2
	jal	DrawCircle			#jump and link to DrawBox function
	lw	$t3,0($sp)
	lw	$a0,12($t3)			#load x value for text display
	lw	$a1,16($t3)			#load y value for text display
	lw	$a2,20($t3)
	jal	OutText				#jump and link to text display procedure
	lw	$t3,0($sp)
	li	$v0,31				#specify Midi Output procedure
	lw	$a0,24($t3)			#specify the pitch
	li	$a1,1500			#specify length of tone
	li	$a2,88				#specify the instrument of tone
	li	$a3,127				#specify volume of tone
	syscall					#perform Midi Tone syscall
	li	$a0,1000			#specify length of pause
	li	$v0,32				#specify pause service
	syscall					#perform pause service
	lw	$a0,28($t3)			#x position for box
	lw	$a1,32($t3)			#y position for box
	li	$a2,0				#box color is black
	li	$a3,56				#box width is 56
	jal	DrawBox
	lw	$ra,4($sp)
	addi	$sp,$sp,8
	
	jr $ra
	

#Checkinput
#checks user input verse sequence
#$a0 - pointer to sequence
#$a1 - pointer to max
#$v0 - returns 0 if pass and 1 if fail
checkinput:
	li	$t0,0				#set counter value to zero
	move	$t1,$a1				#load max value from $a1
	move	$t2,$a0				#copy sequence into $t2
	
	la	$a0,enterPrompt			#load enterPrompt string into $a0
	li	$v0,4				#specify print string service
	syscall					#print string
	
Uloop:
	
	addi	$sp,$sp,-20
	sw	$v0,16($sp)
	sw	$t0,12($sp)
	sw	$t1,8($sp)
	sw	$t2,4($sp)
	sw	$ra,0($sp)
	
	jal	GetChar
	addi	$v0,$v0,-48
	
	sw	$v0,16($sp)
	
	lw	$ra,0($sp)
	lw	$t2,4($sp)
	lw	$t1,8($sp)
	lw	$t0,12($sp)
	
	
	move	$a0,$v0
	jal	CircleSwitch
	
	lw	$ra,0($sp)
	lw	$t2,4($sp)
	lw	$t1,8($sp)
	lw	$t0,12($sp)
	lw	$v0,16($sp)
	addi	$sp,$sp,20
	
	lw	$t3,0($t2)
	bne	$v0,$t3,fail			#if user input does not match the number from sequence, jump to fail, otherwise proceed
	
	addi	$t2,$t2,4			#increment adress in $t2 by 4
	addi	$t0,$t0,1			#increment counter by 1
	
	la	$a0,continuePrompt		#load continuePrompt string into $a0
	li	$v0,4				#specify print string service
	syscall					#print string
	
	bne	$t0,$t1,Uloop			#if counter is not equal to max, loop back to Uloop tag
	
	li	$v0,0				#load value 0 into $v0 specifying a "win"
	jr	$ra				#return from function
	
fail:	li	$v0,1				#load value 1 into $v0 specifying a "loss"
	jr	$ra				#return from function

#CalcAddr:
#converts x/y coordinate to a memory address
#returns memory address in $v0
#$a0 = x coordinate (0-256)
#$a1 = y coordinate (0-256)
#$v0 = Memory address

CalcAddr:
#v0 = base + ($a0 * 4) + ($a1 *4 *256)

	add	$t0,$zero,$a0			#load $a0 to $t0
	add	$t1,$zero,$a1			#load $a1 to $t1
	sll	$t0,$t0,2			#multiple $t0 by 4
	sll	$t1,$t1,8			#multiple $t1 by 256
	sll	$t1,$t1,2			#multiple $t1 by 4
	add	$v0,$t0,$t1			#add $t0 and $t1 and store in $v0
	addi	$v0,$v0,0x10040000		#add base address to $v0
	jr	$ra				#return from function

#GetColor
#returns a color from a table
#returns colors 32 bit value in $v1
#$a2 = color number (0-7)
#$v1 = 32 bit color value

GetColor:
#v1 = colortable address + ($a2 * 4)

	la	$t0,ColorTable			#load base address of ColorTable
	add	$t1,$zero,$a2			#load color number in $t1
	sll	$t1,$t1,2			#multiply color number by 4
	add	$t1,$t1,$t0			#add ColorTable address plus color number
	lw	$v1,0($t1)			#load value from this memory address
	jr	$ra				#return from function
	
#DrawDot
#Draw a dot of the specified color
#a0 = x coordinate (0-255)
#a1 = y coordinate (0-255)
#a2 = color number (0-7)

DrawDot:

	addi	$sp,$sp,-8			#make room on stack for 2 words
	sw	$ra,4($sp)			#stores #ra on the stack
	sw	$a2,0($sp)			#stores #a2 (the color) on the stack
	
	jal	CalcAddr			#returns address for pixel in #v0
	lw	$a2,0($sp)			#restores $a2 from the stack
	sw	$v0,0($sp)			#saves #v0 to the stack
	
	jal	GetColor			#color value returned in #v1
	lw	$v0,0($sp)			#restores #v0 from the stack
	
	sw	$v1,0($v0)			#make dot
	lw	$ra,4($sp)			#restores $ra from the stack
	addi	$sp,$sp,8			#adjust $sp
	
	jr	$ra				#return from function
	

#HorzLine
#draws a horizontal line
#$a0 = x coordinate (0-255)
#$a1 = y coordinate (0-255)
#$a2 = color number (0-7)
#$a3 = length of the line (1-256)

HorzLine:
	addi	$sp,$sp,-20			#make room on the stack for 5 words
	sw	$ra,16($sp)			#stores #ra on the stack
	sw	$a1,12($sp)			#stores #a1 on the stack
	sw	$a2,8($sp)			#stores #a2 on the stack
HorzLoop:
	sw	$a0,4($sp)			#stores $a0 on the stack
	sw	$a3,0($sp)			#stores $a3 on the stack
	jal	DrawDot				#jump and link to DrawDot
	lw	$a0,4($sp)			#restores $a0 from the stack
	lw	$a3,0($sp)			#restores $a3 from the stack
	addi	$a0,$a0,1			#increment x coordinate ($a0)
	subi	$a3,$a3,1			#decrement space left to draw ($a3)
	bne	$a3,$0,HorzLoop			#if $a3 != 0 branch to HorzLoop
	
	lw	$ra,16($sp)			#restores $ra from the stack
	lw	$a1,12($sp)			#restores $a1 from the stack
	lw	$a2,8($sp)			#restores $a2 from the stack
	addi	$sp,$sp,20			#restores stack position
	
	jr	$ra				#return from function

#VertLine
#draws a Verticle line
#$a0 = x coordinate (0-255)
#$a1 = y coordinate (0-255)
#$a2 = color number (0-7)
#$a3 = length of the line (1-256)

VertLine:
	addi	$sp,$sp,-20			#make room on the stack for 5 words
	sw	$ra,16($sp)			#stores #ra on the stack
	sw	$a0,12($sp)			#stores #a0 on the stack
	sw	$a2,8($sp)			#stores #a2 on the stack
VertLoop:
	sw	$a1,4($sp)			#stores $a1 on the stack
	sw	$a3,0($sp)			#stores $a3 on the stack
	jal	DrawDot				#jump and link to DrawDot
	lw	$a1,4($sp)			#restores $a1 from the stack
	lw	$a3,0($sp)			#restores $a3 from the stack
	addi	$a1,$a1,1			#increment x coordinate ($a0)
	subi	$a3,$a3,1			#decrement space left to draw ($a3)
	bne	$a3,$0,VertLoop			#if $a3 != 0 branch to VertLoop
	
	lw	$ra,16($sp)			#restores $ra from the stack
	lw	$a0,12($sp)			#restores $a0 from the stack
	lw	$a2,8($sp)			#restores $a2 from the stack
	addi	$sp,$sp,20			#restores stack position
	
	jr	$ra				#return from function

#DrawBox
#draws a filled box
#$a0 = x coordinate (0-255)
#$a1 = y coordinate (0-255)
#$a2 = color number (0-7)
#$a3 = size of box (1-256)

DrawBox:
	addi	$sp,$sp,-24			#make room on the stack for 6 words
	sw	$ra,20($sp)			#stores $ra on the stack
	sw	$s0,0($sp)			#stores $s0 on the stack
	add	$s0,$a3,$zero			#copy $a3 to $s0
BoxLoop:
	sw	$a0,16($sp)			#stores $a0 on the stack
	sw	$a1,12($sp)			#stores $a1 on the stack
	sw	$a2,8($sp)			#stores $a2 on the stack
	sw	$a3,4($sp)			#stores $a3 on the stack
	
	jal	HorzLine
	
	lw	$a0,16($sp)			#restores $a0 from the stack
	lw	$a1,12($sp)			#restores $a1 from the stack
	lw	$a2,8($sp)			#restores $a2 from the stack
	lw	$a3,4($sp)			#restores $a3 from the stack
	
	addi	$a1,$a1,1			#increment y coordinate
	addiu	$s0,$s0,-1			#decrement counter
	bne	$s0,$0,BoxLoop			#if $t0 != 0 branch to BoxLoop
	
	lw	$ra,20($sp)			#restores $ra from the stack
	lw	$s0,0($sp)			#restores $s0 from the stack
	addi	$sp,$sp,24			#restores stack position
	
	jr	$ra				#return from function

#ClearDisplay
#Draw a large "black" box over the entire display

ClearDisplay:
	addi	$sp,$sp,-4			#make room on the stack for 1 word
	sw	$ra,0($sp)			#stores $ra on the stack
	
	li	$a0,0				#set x coordinate to zero
	li	$a1,0				#set y coordinate to zero
	li	$a2,0				#set color to black
	li	$a3,255				#set size to full size of screen
	
	jal	DrawBox
	
	lw	$ra,0($sp)			#restores $ra from the stack
	addi	$sp,$sp,4			#restores stack position
	
	jr	$ra				#return from function
	
#DrawCircle
#Draws a circle on the screen at a specific x,y point in a given color
#$a0 = x coordinate (16-240)
#$a1 = y coordinate (16-240)
#$a2 = color number (0-7)

DrawCircle:
	addi	$sp,$sp,-32
	sw	$a0,28($sp)
	sw	$a1,24($sp)
	sw	$a2,20($sp)
	sw	$ra,4($sp)
#set counter to -27
	li	$t0,-27				#counter value set to -27
	la	$t1,CircleValues		#load address of CircleValues table
Cloop:						#circle loop tag
#move to top position (y + counter)
	add	$a1,$a1,$t0			#(y value + counter)
#calculate starting position top position - ((CircleValue -1) /2)
	#la	$t1,CircleValues		#load address of CircleValues table
	lw	$t2,0($t1)			#load value from CircleValues table
	lw	$a3,0($t1)
	addi	$t2,$t2,-1			#subtract 1 from circle value
	srl	$t2,$t2,1			#divide circle value by 2
	sub	$a0,$a0,$t2			#set x coordinate to original x value - ((circlevalue -1 )/ 2)
	
	sw	$t0,16($sp)
	sw	$t1,12($sp)
	sw	$t2,8($sp)
#Draw Horzline (starting postion is x,y coordinate and circle value is length)	
	jal	HorzLine
	
	lw	$t0,16($sp)
	lw	$t1,12($sp)
	lw	$t2,8($sp)
	
	lw	$a1,24($sp)
	lw	$a0,28($sp)
	
#increment counter	
	addi	$t0,$t0,1
	addi	$t1,$t1,4
#loop until counter = 27
	bne	$t0,28,Cloop	

	lw	$a0,16($sp)
	lw	$a1,12($sp)
	lw	$a2,8($sp)
	lw	$ra,4($sp)
	addi	$sp,$sp,32
	jr	$ra
	
#DrawX
#Draws an X on the screen
#contained, no input or output
DrawX:
	li	$a0,10
	li	$a1,10
	li	$a2,7
	li	$a3,4
Xloop:	
	addi	$sp,$sp,-20
	sw	$a3,16($sp)
	sw	$a0,12($sp)
	sw	$a1,8($sp)
	sw	$a2,4($sp)
	sw	$ra,0($sp)
	
	jal	HorzLine
	
	lw	$a3,16($sp)
	lw	$a0,12($sp)
	lw	$a1,8($sp)
	lw	$a2,4($sp)
	lw	$ra,0($sp)
	addi	$sp,$sp,20
	
	addi	$a0,$a0,1
	addi	$a1,$a1,1
	
	ble	$a0,245,Xloop
	
	li	$a0,241
	li	$a1,10
	li	$a2,7
	li	$a3,4
Xloop2:	
	addi	$sp,$sp,-20
	sw	$a3,16($sp)
	sw	$a0,12($sp)
	sw	$a1,8($sp)
	sw	$a2,4($sp)
	sw	$ra,0($sp)
	
	jal	HorzLine
	
	lw	$a3,16($sp)
	lw	$a0,12($sp)
	lw	$a1,8($sp)
	lw	$a2,4($sp)
	lw	$ra,0($sp)
	addi	$sp,$sp,20
	
	addi	$a0,$a0,-1
	addi	$a1,$a1,1
	
	bge	$a0,6,Xloop2	
	
	jr 	$ra
	
#*****************************************added file*******************************************	
        .data
        .word   0 : 40
Stack:

Colors: .word   0x000000        # background color (black)
        .word   0xffffff        # foreground color (white)

DigitTable:
        .byte   ' ', 0,0,0,0,0,0,0,0,0,0,0,0
        .byte   '0', 0x7e,0xff,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xff,0x7e
        .byte   '1', 0x38,0x78,0xf8,0x18,0x18,0x18,0x18,0x18,0x18,0x18,0x18,0x18
        .byte   '2', 0x7e,0xff,0x83,0x06,0x0c,0x18,0x30,0x60,0xc0,0xc1,0xff,0x7e
        .byte   '3', 0x7e,0xff,0x83,0x03,0x03,0x1e,0x1e,0x03,0x03,0x83,0xff,0x7e
        .byte   '4', 0xc3,0xc3,0xc3,0xc3,0xc3,0xff,0x7f,0x03,0x03,0x03,0x03,0x03
        .byte   '5', 0xff,0xff,0xc0,0xc0,0xc0,0xfe,0x7f,0x03,0x03,0x83,0xff,0x7f
        .byte   '6', 0xc0,0xc0,0xc0,0xc0,0xc0,0xfe,0xfe,0xc3,0xc3,0xc3,0xff,0x7e
        .byte   '7', 0x7e,0xff,0x03,0x06,0x06,0x0c,0x0c,0x18,0x18,0x30,0x30,0x60
        .byte   '8', 0x7e,0xff,0xc3,0xc3,0xc3,0x7e,0x7e,0xc3,0xc3,0xc3,0xff,0x7e
        .byte   '9', 0x7e,0xff,0xc3,0xc3,0xc3,0x7f,0x7f,0x03,0x03,0x03,0x03,0x03
        .byte   '+', 0x00,0x00,0x00,0x18,0x18,0x7e,0x7e,0x18,0x18,0x00,0x00,0x00
        .byte   '-', 0x00,0x00,0x00,0x00,0x00,0x7e,0x7e,0x00,0x00,0x00,0x00,0x00
        .byte   '*', 0x00,0x00,0x00,0x66,0x3c,0x18,0x18,0x3c,0x66,0x00,0x00,0x00
        .byte   '/', 0x00,0x00,0x18,0x18,0x00,0x7e,0x7e,0x00,0x18,0x18,0x00,0x00
        .byte   '=', 0x00,0x00,0x00,0x00,0x7e,0x00,0x7e,0x00,0x00,0x00,0x00,0x00
        .byte   'A', 0x18,0x3c,0x66,0xc3,0xc3,0xc3,0xff,0xff,0xc3,0xc3,0xc3,0xc3
        .byte   'B', 0xfc,0xfe,0xc3,0xc3,0xc3,0xfe,0xfe,0xc3,0xc3,0xc3,0xfe,0xfc
        .byte   'C', 0x7e,0xff,0xc1,0xc0,0xc0,0xc0,0xc0,0xc0,0xc0,0xc1,0xff,0x7e
        .byte   'D', 0xfc,0xfe,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xfe,0xfc
        .byte   'E', 0xff,0xff,0xc0,0xc0,0xc0,0xfe,0xfe,0xc0,0xc0,0xc0,0xff,0xff
        .byte   'F', 0xff,0xff,0xc0,0xc0,0xc0,0xfe,0xfe,0xc0,0xc0,0xc0,0xc0,0xc0
        .byte   'G', 0x7e,0xff,0xc3,0xc0,0xc0,0xcf,0xcf,0xc3,0xc3,0xc3,0xff,0x7e
        .byte   'H', 0xc3,0xc3,0xc3,0xc3,0xc3,0xff,0xff,0xc3,0xc3,0xc3,0xc3,0xc3
        .byte   'I', 0xff,0xff,0x18,0x18,0x18,0x18,0x18,0x18,0x18,0x18,0xff,0xff
        .byte   'J', 0x7f,0x7f,0x03,0x03,0x03,0x03,0x03,0x03,0xc3,0xc3,0xff,0x7e
        .byte   'K', 0xc3,0xc3,0xc3,0xc6,0xcc,0xf8,0xf8,0xcc,0xc6,0xc3,0xc3,0xc3
        .byte   'L', 0xc0,0xc0,0xc0,0xc0,0xc0,0xc0,0xc0,0xc0,0xc0,0xc0,0xff,0xff
        .byte   'M', 0xc3,0xc3,0xe7,0xff,0xff,0xdb,0xdb,0xc3,0xc3,0xc3,0xc3,0xc3
        .byte   'N', 0xc3,0xc3,0xe3,0xe3,0xf3,0xfb,0xdb,0xcf,0xcf,0xc7,0xc7,0xc3
        .byte   'O', 0x7e,0xff,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xff,0x7e
        .byte   'P', 0xfe,0xff,0xc3,0xc3,0xc3,0xc3,0xfe,0xfe,0xc0,0xc0,0xc0,0xc0
        .byte   'Q', 0x7e,0xff,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xdb,0xcf,0xff,0x7e
        .byte   'R', 0xfc,0xfe,0xc3,0xc3,0xc3,0xc3,0xfe,0xfc,0xcc,0xc6,0xc3,0xc3
        .byte   'S', 0x7e,0xff,0xc3,0xc0,0xc0,0xff,0x7f,0x03,0x03,0xc3,0xff,0x7e
        .byte   'T', 0xff,0xff,0x18,0x18,0x18,0x18,0x18,0x18,0x18,0x18,0x18,0x18
        .byte   'U', 0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xff,0x7e
        .byte   'V', 0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0x66,0x3c,0x18,0x18
        .byte   'W', 0xc3,0xc3,0xc3,0xc3,0xc3,0xc3,0xdb,0xdb,0xff,0xe7,0xc3,0xc3
        .byte   'X', 0xc3,0xc3,0x66,0x3c,0x3c,0x18,0x18,0x3c,0x3c,0x66,0xc3,0xc3
        .byte   'Y', 0xc3,0xc3,0x66,0x66,0x3c,0x3c,0x18,0x18,0x18,0x18,0x18,0x18
        .byte   'Z', 0xff,0xff,0x03,0x06,0x0c,0x18,0x30,0x60,0xc0,0xc0,0xff,0xff
# add additional characters here....
# first byte is the ascii character
# next 12 bytes are the pixels that are "on" for each of the 12 lines
        .byte    0, 0,0,0,0,0,0,0,0,0,0,0,0




#  0x80----  ----0x08
#  0x40--- || ---0x04
#  0x20-- |||| --0x02
#  0x10- |||||| -0x01
#       ||||||||
#       84218421

#   1   ...xx...      0x18
#   2   ..xxxx..      0x3c
#   3   .xx..xx.      0x66
#   4   xx....xx      0xc3
#   5   xx....xx      0xc3
#   6   xx....xx      0xc3
#   7   xxxxxxxx      0xff
#   8   xxxxxxxx      0xff
#   9   xx....xx      0xc3
#  10   xx....xx      0xc3
#  11   xx....xx      0xc3
#  12   xx....xx      0xc3



Test1:  .asciiz "0123456789"
Test2:  .asciiz "+ - * / ="
Test3:  .asciiz "ABCDEF"

        .text
        la      $sp, Stack

        li      $a0, 1          # some test cases
        li      $a1, 2
        la      $a2, Test1
        jal     OutText

        li      $a0, 1
        li      $a1, 18
        la      $a2, Test2
        jal     OutText

        li      $a0, 1
        li      $a1, 34
        la      $a2, Test3
        jal     OutText

        li      $v0, 10         # program exit
        syscall


# OutText: display ascii characters on the bit mapped display
# $a0 = horizontal pixel co-ordinate (0-255)
# $a1 = vertical pixel co-ordinate (0-255)
# $a2 = pointer to asciiz text (to be displayed)
OutText:
        addiu   $sp, $sp, -24
        sw      $ra, 20($sp)

        li      $t8, 1          # line number in the digit array (1-12)
_text1:
        la      $t9, 0x10040000 # get the memory start address
        sll     $t0, $a0, 2     # assumes mars was configured as 256 x 256
        addu    $t9, $t9, $t0   # and 1 pixel width, 1 pixel height
        sll     $t0, $a1, 10    # (a0 * 4) + (a1 * 4 * 256)
        addu    $t9, $t9, $t0   # t9 = memory address for this pixel

        move    $t2, $a2        # t2 = pointer to the text string
_text2:
        lb      $t0, 0($t2)     # character to be displayed
        addiu   $t2, $t2, 1     # last character is a null
        beq     $t0, $zero, _text9

        la      $t3, DigitTable # find the character in the table
_text3:
        lb      $t4, 0($t3)     # get an entry from the table
        beq     $t4, $t0, _text4
        beq     $t4, $zero, _text4
        addiu   $t3, $t3, 13    # go to the next entry in the table
        j       _text3
_text4:
        addu    $t3, $t3, $t8   # t8 is the line number
        lb      $t4, 0($t3)     # bit map to be displayed

        sw      $zero, 0($t9)   # first pixel is black
        addiu   $t9, $t9, 4

        li      $t5, 8          # 8 bits to go out
_text5:
        la      $t7, Colors
        lw      $t7, 0($t7)     # assume black
        andi    $t6, $t4, 0x80  # mask out the bit (0=black, 1=white)
        beq     $t6, $zero, _text6
        la      $t7, Colors     # else it is white
        lw      $t7, 4($t7)
_text6:
        sw      $t7, 0($t9)     # write the pixel color
        addiu   $t9, $t9, 4     # go to the next memory position
        sll     $t4, $t4, 1     # and line number
        addiu   $t5, $t5, -1    # and decrement down (8,7,...0)
        bne     $t5, $zero, _text5

        sw      $zero, 0($t9)   # last pixel is black
        addiu   $t9, $t9, 4
        j       _text2          # go get another character

_text9:
        addiu   $a1, $a1, 1     # advance to the next line
        addiu   $t8, $t8, 1     # increment the digit array offset (1-12)
        bne     $t8, 13, _text1

        lw      $ra, 20($sp)
        addiu   $sp, $sp, 24
        jr      $ra


