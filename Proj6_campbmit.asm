TITLE Program Template     (template.asm)

; Author:					Mitch Campbell
; Last Modified:			08-Dec-2020
; OSU email address:		campbmit@oregonstate.edu
; Course number/section:	CS271 / Section 400
; Project Number: 6			Due Date: 06-Dec-2020
; Description:				Collects 10 integers from user, then prints them to the console, along with the sum and average

INCLUDE Irvine32.inc

; (insert macro definitions here)
mGetString MACRO prompt, string, length, byteCount
; ------------------------------
; Gets a string from the user of maximum legnth bytes
; 
; Preconditions:	N/A
; Postconditions:	N/A
; Receives:			* prompt: address/OFFSET of prompt to print to console
;					* string: address/OFFSET of storage location for user string
;					* length: number of bytes/chars ro read from user input
;					* byteCount: address/OFFSET of variable in which to store number of bytes read
; Returns:			N/A
; ------------------------------

	pushad

	; Write prompt to terminal
	mov		EDX, OFFSET prompt
	call	WriteString 

	; Read user's input
	mov		EDX, OFFSET string
	mov		ECX, length
	call	ReadString

	; Store length of user input
	mov		byteCount, EAX

	popad

ENDM

mWriteString MACRO stringLoc
; ------------------------------
; Provided the address/OFFSET of a string, prints the string to the console
; 
; Preconditions:	string address to be printed in EDX
; Postconditions:	N/A
; Receives:			OFFSET of string to be printed
; Returns:			N/A
; ------------------------------
	pushad

	mov		EDX, stringLoc
	call	WriteString

	popad

ENDM

; Constants
ARRAYSIZE = 10

.data

; Prompts and descriptive text for user

	; Strings used in the program Introduction
	progName		BYTE	"Program owner:		Mitch Campbell", 10, 13, 0
	progTitle		BYTE	"Program title:		Project 6 - String Primitives and Macros", 10, 13, 0
	progDesc		BYTE	"Program description:	Accepts 10 numbers from user. Then prints numbers, sum and average to console.", 10, 13, 0
	exCred1			BYTE	"EC1: N/A", 10, 13, 0
	exCred2			BYTE	"EC2: N/A", 10, 13, 0

	; Strings used in collection of integers
	intPrompt		BYTE	"Please enter a signed integer: ", 0
	errorMsg		BYTE	"Error: your entry was either too long, or not a valid signed integer.", 10, 13, 0

	; Strings used in display of integers and calculations
	intStr			BYTE	"The numbers you entered: ", 10, 13, 0
	sumStr			BYTE	"Sum of provided integers: ", 0
	avgStr			BYTE	"Avg of provided integers: ", 0

	; Farwell string
	aFineHowDoYouDo	BYTE	"'Keep the change, ya filthy animal!'", 10, 13, " - Johnny (Angels with Filthy Souls)", 10, 13, " - Kevin McAllister", 10, 13, " - Michael Scott", 10, 13, 0


; Variables to store integer calculations
intSum			DWORD	0
intAvg			DWORD	0

; Variables used to store and validate integers
userStr			BYTE	13 DUP(0)			; Store user string
emptyStr		BYTE	12 DUP(0)			; Used to display numbers
intArray		DWORD	ARRAYSIZE DUP(0)	; Stores user inputs as ints
max_len			DWORD	12		
num_len			DWORD	10		
bytesRead		DWORD	?					; Number of bytes entered by user

decodedInt		DWORD	0					; Integer version of user input
sign			DWORD	0					; Info about sign of user's input. 0 = "+" sign (or nothing) entered, 1 = "-" sign entered

.code

main PROC
; ------------------------------
; Print's the program owner's name, program' title and description, 
; and strings describing Extra Credit work attempted to the terminal window.
; 
; Preconditions:	N/A
; Postconditions:	N/A
; Receives:			N/A
; Returns:			Collects 10 integers from user, then prints the integers to the console, along with the sum and average
; ------------------------------

	; Introduce the program to the user, and detail any extra credit attempted
	
		push	OFFSET progName
		push	OFFSET progTitle
		push	OFFSET progDesc
		push	OFFSET exCred1
		push	OFFSET exCred2
		call	introduction
	
		call	CrLf


	; Get 10 integers from the user
	
		; Set counter and indexing register
		mov		ECX, 10
		mov		EBX, OFFSET intArray

		_get_vals:

			mov		decodedInt, 0
		
			push	OFFSET userStr
			call	ReadVal
			mov		EAX, decodedInt


			; Store integer value in intArray
			mov		[EBX], EAX
			add		EBX, 4

			loop	_get_vals

	call	CrLf

	; Display integers to user

		mov		EDX, OFFSET intStr
		call	WriteString

		; Set counter and indexing register
		mov		ECX, 10
		mov		EBX, OFFSET intArray

		; Loop through intArray, converting ints to strings and printing to console
		_display_vals:
		
			push	offset emptyStr
			push	[EBX]				; Address of int to print
			call	WriteVal
			call	CrLf

			; Increment array index
			add		EBX, 4

			loop	_display_vals

		call	CrLf

	; Display sum to user

		; Calculate sum
		mov		ECX, 10					; Set counter
		mov		EBX, OFFSET intArray
		mov		EAX, 0					; Set accumulator to 0

		_sum_loop:
			add		EAX, [EBX]		; Add int to accumulating total
			add		EBX, 4			; Increment pointer

			loop	_sum_loop

		; Print message in sumStr to console
		mov		EDX, OFFSET sumStr
		call	WriteString
		
		; Print sum to console
		push	OFFSET emptyStr
		push	EAX
		call	WriteVal

		call	CrLf
		call	CrLf

	; Display average to user

		; Print message in avgStr to console
		mov		EDX, OFFSET avgStr
		call	WriteString

		; Calculate average
		mov		EBX, 10
		cdq
		idiv	EBX

		; Print average to console
		push	OFFSET emptyStr
		push	EAX
		call	WriteVal
	
		call	CrLf
		call	CrLf

	; Wish the user fairwell in the style of Kevin McAllister in Home Alone

		push	OFFSET aFineHowDoYouDo
		call	farewell
	
		call	CrLf

		Invoke	ExitProcess, 0	; exit to operating system

main ENDP

introduction PROC
; ------------------------------
; Print's the program owner's name, program' title and description, 
; and strings describing Extra Credit work attempted to the terminal window.
; 
; Preconditions:	N/A
; Postconditions:	N/A
; Receives:			OFFSET of 5 strings (DWORD * 5)
; Returns:			N/A
; ------------------------------

	; Preserve register values
	push	EBP
	mov		EBP, ESP
	push	EDX

	; Print introductory strings
	mov		EDX, [EBP+24]
	call	WriteString
	mov		EDX, [EBP+20]
	call	WriteString	
	mov		EDX, [EBP+16]
	call	WriteString	

	call	CrLf
	
	; No extra credit attempted

	; Print extra credit strings
	;mov		EDX, [EBP+12]
	;call	WriteString
	;mov		EDX, [EBP+8]
	;call	WriteString	

	; Restore register values and return
	pop		EDX
	pop		EBP
	ret		20

introduction ENDP

ReadVal PROC
; ------------------------------
; Print's the program owner's name, program' title and description, 
; and strings describing Extra Credit work attempted to the terminal window.
; 
; Preconditions:	N/A
; Postconditions:	EAX holds integer value ext
; Receives:			* address/OFFSET of userStr
; Returns:			decodedInt holds integer value that was read from user input
; ------------------------------

	push	EBP
	mov		EBP, ESP
	pushad

	_start_RV:
		; Get integer from user (as string)
		mGetString	intPrompt, userStr, max_len, bytesRead

		; Validate user's input while summing

		mov		sign, 0

		mov		ECX, 10
			
			; Move OFFSET of userStr into ESI
			mov		ESI, [EBP + 8]

			; Check for leading '-'
				
				mov		AL, [ESI]
				cmp		AL, 45
				
				; If no leading '-', check for leading '+'
				jne		_checkpos_RV

				; If leading '-' present, set sign tracker and increment string pointer
				dec		sign
				inc		ESI
				dec		bytesRead
				jmp		_add_digits_RV

			; Check for leading '+'

				_checkpos_RV:
				cmp		AL, 43

				; If no leading '+', proceed to checking digits
				jne		_add_digits_RV

				; If leading '+' present increment string pointer
				inc		ESI
				dec		bytesRead

			; Check if each remaining character is a digit
			_add_digits_RV:

				; Load next char into AL and adjust from ASCII to numberic
				cld
				lodsb
				
				movzx	EAX, AL
				sub		AL, 48

				; If < 0, invalid char
				jl		_invalid_RV

				; If > 9, invalid char
				cmp		AL, 10
				jge		_invalid_RV

				; Adjust number to expected decimal value
				push	bytesRead
				call	tensAdjust
				dec		bytesRead

				cmp		sign, -1
				jne		_unsigned_TA
				mul		sign

				_unsigned_TA:
				; Add number to decodedInt
				add		decodedInt, EAX
				jo		_invalid_RV

				cmp		bytesRead, 0
				jz		_end_RV

				loop	_add_digits_RV

			jmp		_end_RV

	_invalid_RV:
		
		; Print error message to console
		mov		EDX, OFFSET errorMsg
		call	WriteString

		; Zero out userStr
		mov		ECX, (SIZEOF userStr)
		mov		EDI, [EBP + 8]
		mov		AL, 0
		cld
		_zero_RV:
			stosb
			loop	_zero_RV

		; Prompt user to enter another number
		jmp		_start_RV

	_end_RV:

	; Restore registers and return
		popad
		pop		EBP

		ret		4

ReadVal ENDP

WriteVal PROC
; ------------------------------
; Print's the program owner's name, program' title and description, 
; and strings describing Extra Credit work attempted to the terminal window.
; 
; Preconditions:	N/A
; Postconditions:	N/A
; Receives:			* address/OFFSET of emptyStr
;					* integer to print (SDWORD)
; Returns:			Prints integer to console
; ------------------------------

	; Preserve registers and stack frame
	push	EBP
	mov		EBP, ESP
	pushad

	; Store provided int as string

		; Set counter register
		mov		ECX, 11

		; If in is negative, change to positive for printing purposes
		
			; Dereference integer
			mov		EAX, [EBP + 8]

			; If sign flag is on, change to positive
			cmp		EAX, 0
			jns		_noneg1_WV

			mov		EBX, -1
			mul		EBX

		_noneg1_WV:

		; Set direction flag and dereference emptyStr address
		STD
		mov		EDI, [EBP + 12]
		add		EDI, 10

		;  Continually divide integer by 10, storing remainder in current byte of emptyStr
		mov		EBX, 10
		_divloop_WV:
			xor		EDX, EDX
			div		EBX

			; Preserve int value
			push	EAX

			; Adjust value to ASCII and store in emptyStr byte
			mov		AL, DL
			add		AL, 48
			STOSB

			; Restore int value
			pop		EAX

			loop	_divloop_WV

	; Print string that now holds integer

		mov		EDI, [EBP + 12]

		; Skip leading zeros
		mov		ECX, 11
		CLD
		mov		AL, 48
		_skip_leading_zero_WV:
			
			; Check if ASII 0
			scasb
		
			; If current byte is not an ASCII 0, stop skipping zeros
			jne		_write_WV

			loop	_skip_leading_zero_WV

		_write_WV:

		; Dereference integer
		mov		EAX, [EBP + 8]
	
		; If negative, add a '-' to start of string
			cmp		EAX, 0
			jns		_noneg_WV

			mov		EBX, 45
			dec		EDI
			dec		EDI
			mov		[EDI], BL
			inc		EDI

		_noneg_WV:

		; Write string to console
		mov		EDX, EDI
		dec		EDX
		call	WriteString

	; Restore registers and return
	popad
	pop		EBP

	ret		8

WriteVal ENDP

tensAdjust PROC
; ------------------------------
; Passed a tens-place as stack parameter, multiplies 
;
; Preconditions:	Number to be adjusted in EAX
; Postcondition:	Number in EAX will be adjusted to desired tens-place
; Receives:			* Desired tens-place
; Returns:			N/A
; ------------------------------

	push	EBP
	mov		EBP, ESP
	push	ECX
	push	EBX

	mov		ECX, [EBP + 8]

	dec		ECX

	cmp		ECX, 0
	jz		_end_TA

	; Multiplies to correct tens place
	mov		EBX, 10
	_mul_TA:
		mul		EBX
		loop	_mul_TA

	_end_TA:
		pop		EBX
		pop		ECX
		pop		EBP

		ret		4

tensAdjust ENDP

farewell PROC
; ------------------------------
; Prints a farewell message to the user
;
; Preconditions:	N/A
; Postcondition:	N/A
; Receives:			* OFFSET of string to print (DWORD)
; Returns:			N/A
; ------------------------------

	; Preserve register values
	push	EBP
	mov		EBP, ESP
	push	EDX

	; Print farewell message
	mov		EDX, [EBP + 8]
	call	WriteString

	; Restore register values
	pop		EDX
	pop		EBX
	ret		4

farewell ENDP

END main
