extern time
extern random
extern srand
extern exit
extern printf

section .data

	;   NOTE: The max number may be changed to any 64-bit number, provided
	;   that DIGIT_COUNT is the number of digits + 1. Changing the minimum
	;   value has no effect on the program logic.
	MIN dq 1
	MAX dq 10000
	DIGIT_COUNT dq 6; Inclusive of newline character.

	welcome_msg              db  "Guess a number from %d-%d.", 10, 0
	loop_msg                 db  "> ", 0
	loop_msg_len             equ $ - loop_msg
	too_low_msg              db  "Too low!", 10, 0
	too_low_msg_len          equ $ - too_low_msg
	too_high_msg             db  "Too high!", 10, 0
	too_high_msg_len         equ $ - too_high_msg
	correct_number_debug_msg db  "The randomly generated number is: %d", 10, 0
	invalid_msg              db  "Please enter a number from %d to %d.", 10, 0
	win_msg                  db  "You win! The corrrect number was: %d.", 10, "It took you %d guess(es) to get it right.", 10, "Would you like to try again? (y/n)", 10, "> ", 0

section .bss
	buf     resb 4; Same as DIGIT_COUNT

section .text
global  main

atoui:
	; INFO: ASCII to unsigned Integer (modified)
	; Accepts a null-terminated string of indeterminate length to be
	; converted into an unsigned integer within the 64-bit integer limit.
	; Signature is:
	; unsigned int (char *digits)

	xor r9, r9; Counter.
	xor rax, rax; Return register
	mov rcx, 10; Multiplier

.loop:
	movzx r8, byte [rdi + r9]; Ensure the rest of `r8` is 0'd with `movzx`.
	cmp   r8, 0; If it's a null pointer, return.
	je    .exit
	;     WARN: The part modified for this game: If it's a newline, return.
	;     Why? Let's say we input `30` into stdin, that actually puts
	;     `30\n` into `buf`. So instead of manually clearing out `\n`s from
	;     user input before calling atoui, (time consuming), just add a
	;     newline check.
	cmp   r8, 10
	je    .exit

	;   Check if a character is invalid (`x - '0'` => `(x < 0 || x > 10)`)
	sub r8, "0"
	cmp r8, 9
	jg  .invalid
	cmp r8, 0
	jl  .invalid

	;   total * 10 + digit
	mul rcx
	add rax, r8
	inc r9; Increment counter
	jmp .loop

.invalid:
	mov rax, -1; Return -1 as an error.

.exit:
	ret

clear_stdin:
	; INFO: void clear_stdin()
	; Drains stdin byte-by-byte until it hits a newline.

	; INFO: This `clear_stdin` exists due to how the `read` syscall works.
	; While `rdx` is the maximum number of bytes read, it's NOT the maximum
	; number of bytes that'll actually go into stdin, and it's NOT "how
	; many bytes will definitely be read". Also, we set rdx to 4 bytes
	; even though the max number is 100 (3 digits) because of this reason:
	; Anything you input into stdin does NOT end with a null terminator; it
	; ends with a newline.
	; ---
	; Without this section, the following happens:
	; Take a look at the following list of inputs vs what the program gets
	; and prints back with in response (assume random number is `50`):
	; 1. These inputs get handled just fine (under 4 bytes given):
	; - 1 -> "1\n" (2 Bytes) -> "Too low!"
	; - 49 -> "49\n" (3 B) -> "Too low!"
	; - 001 -> "100\n" (4 B) -> "Too low!"
	; - 51 -> "51\n" (3 B) -> "Too high!"
	; - 100 -> "100\n" (4 B) -> "Too high!"
	; - 999 -> "999\n" (4 B) -> "Please enter a number from 1 to 100."
	; - 0 -> "0\n" (2 B) -> "Please enter a number from 1 to 100."
	; 2. These inputs "carry over" into the next read syscall (bad behavior):
	; - "1000\n" (5 B) -> "Too high!\nPlease enter a number from 1 to 100."
	; - "00010001\n" (9 B) -> "Too low!\nToo low!\nPlease enter a number from 1 to 100."
	; - "abcdefghijklmnopqrstuvwxyz\n" (27 B) -> "Please enter a number from 1 to 100.\n" (6 times)
	; ---
	; INFO: How do we resolve this?
	; Keep calling `read` syscall for one byte until you get a newline
	; (`10`), in which case, it's the end of the user's input, so you can
	; go back to wherever it is you were before.
	; (Note that this approach may be inefficient, and there may be better
	; ways for real programs.)
	; NOTE:
	; Notice how we use `buf`, the same buffer used for storing our
	; numbers. Normally, writing garbage data into the same buffer we use
	; to store important information is a bad idea, but in this program,
	; triggering this function means that you've gone over the maximum
	; guessable number (and so your guess is invalid anyway), so this is
	; fine.

	;   read(fd=0, buf=buf, count=1)
	xor rdi, rdi
	mov rsi, buf
	mov rdx, 1
	xor rax, rax
	syscall
	cmp byte [buf], 10
	jne clear_stdin
	ret

main:
	; INFO: Storage
	; r12 = number
	; r13 = guess count

	mov  rdi, welcome_msg
	mov  rsi, [MIN]
	mov  rdx, [MAX]
	xor  rax, rax
	call printf

	; INFO: The random number generator: `srand(time(0)); random()`
	; Note that this actually doesn't qualify as a PRNG because of modulo
	; bias.

	;    NOTE: time() expects a nullable value OR a pointer to store the
	;    result in. Thus, we set `rdi` to zero or else it segfaults because
	;    rdi has garbage in it.
	xor  rdi, rdi
	call time
	mov  rdi, rax
	call srand
	call random
	mov  rcx, [MAX]
	cqo
	div  rcx
	;    NOTE: The random number is now in `r12` (range 0-MAX)
	;    Modulo Bias: some numbers might appear more than others.
	;    Probably not noticable for this game. And, the program only
	;    generates a random number once every second due to how time()
	;    only updates once a second, which is a detail that won't matter
	;    for the purposes of this game.
	mov  r12, rdx
	inc  r12; Now the random number is in the inclusive range [1, MAX]

	mov r13, 1

	; NOTE: Uncomment to show the correct number.
	; mov  rdi, correct_number_debug_msg
	; mov  rsi, r12
	; xor  rax, rax
	; call printf

.game_loop:
	mov dword [buf], 0

	;   write(fd=stdout, buf=loop_msg, count=loop_msg_len)
	mov rdi, 1
	mov rsi, loop_msg
	mov rdx, loop_msg_len
	mov rax, 1
	syscall

	;   read(fd=0, buf=buf, count=[DIGIT_COUNT])
	xor rdi, rdi
	mov rsi, buf
	mov rdx, [DIGIT_COUNT]
	xor rax, rax
	syscall

	;    Validate input
	cmp  rax, [DIGIT_COUNT]
	jl   .game_loop_post_clear_stdin
	;    If the number of bytes read was DIGIT_COUNT - 1, but the last byte
	;    is a newline then there's no need to clear stdin.
	dec rax; Get DIGIT_COUNT - 1
	cmp  byte [buf + rax], 10
	je   .game_loop_post_clear_stdin
	call clear_stdin

.game_loop_post_clear_stdin:
	mov  rdi, buf
	call atoui
	cmp  rax, [MIN]
	jl   .invalid
	cmp  rax, [MAX]
	jg   .invalid

	cmp rax, r12
	je  win

	mov rdi, 1
	jl  .too_low

	;   .too_high:
	mov rsi, too_high_msg
	mov rdx, too_high_msg_len
	mov rax, 1
	syscall
	;   Increment guess count only if input was valid AND innacurate.
	;   Since `inc` affects flags, we need this in both branches.
	inc r13
	jmp .game_loop

.too_low:
	;   write(fd=stdout, buf=too_high_msg, count=too_low_msg_len)
	mov rsi, too_low_msg
	mov rdx, too_low_msg_len
	mov rax, 1
	syscall
	inc r13
	jmp .game_loop

.invalid:
	mov  rdi, invalid_msg
	mov  rsi, [MIN]
	mov  rdx, [MAX]
	xor  rax, rax
	call printf
	jmp  .game_loop

win:
	mov  rdi, win_msg
	mov  rsi, r12
	mov  rdx, r13
	xor  rax, rax
	call printf; Also contains the "Would you like to play again?" text.

confirm_replay:
	mov dword [buf], 0
	;   read(fd=0, buf=buf, count=1)
	xor rdi, rdi
	mov rsi, buf
	mov rdx, 1
	xor rax, rax
	syscall
	cmp byte [buf], 'y'
	je  main
	cmp byte [buf], 'n'
	jne confirm_replay

end:
	;    exit(error_code=0)
	xor  rdi, rdi
	call exit
