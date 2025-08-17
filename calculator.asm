

section .data
    menu        db "=== REGGIN SA KCUF ===", 10
                db "1. Add", 10
                db "2. Subtract", 10
                db "3. Multiply", 10
                db "4. Divide", 10
                db "5. Exit", 10
                db "Choose (1-5): ", 0
    menu_len    equ $ - menu

    prompt1     db "Enter first number: ", 0
    prompt1_len equ $ - prompt1

    prompt2     db "Enter second number: ", 0
    prompt2_len equ $ - prompt2

    result_msg  db "Result: ", 0
    result_len  equ $ - result_msg

    newline     db 10, 0

section .bss
    choice  resb 2
    num1    resb 12
    num2    resb 12
    result  resb 20

section .text
    global _start

; ------------------------------------------------------------
; Entry Point
; ------------------------------------------------------------
_start:
main_loop:
    ; Display menu
    mov eax, 4              ; sys_write
    mov ebx, 1
    mov ecx, menu
    mov edx, menu_len
    int 0x80

    ; Read user choice
    mov eax, 3              ; sys_read
    mov ebx, 0
    mov ecx, choice
    mov edx, 2
    int 0x80
    mov byte [choice+1], 0   ; Null-terminate

    mov al, [choice]
    sub al, '0'

    cmp al, 1
    je do_add
    cmp al, 2
    je do_sub
    cmp al, 3
    je do_mul
    cmp al, 4
    je do_div
    cmp al, 5
    je exit_program

    jmp main_loop            ; invalid input → back to menu

; ------------------------------------------------------------
; Get two integers from user
;   → returns eax=num1, ebx=num2
; ------------------------------------------------------------
get_numbers:
    ; Prompt for first number
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt1
    mov edx, prompt1_len
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, num1
    mov edx, 12
    int 0x80
    mov byte [num1+eax-1], 0
    mov esi, num1
    call str2int
    push eax                 ; save first number

    ; Prompt for second number
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt2
    mov edx, prompt2_len
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, num2
    mov edx, 12
    int 0x80
    mov byte [num2+eax-1], 0
    mov esi, num2
    call str2int
    mov ebx, eax             ; ebx = second number

    pop eax                  ; eax = first number
    ret

; ------------------------------------------------------------
; Operations
; ------------------------------------------------------------
do_add:
    call get_numbers
    add eax, ebx
    call print_result
    jmp main_loop

do_sub:
    call get_numbers
    sub eax, ebx
    call print_result
    jmp main_loop

do_mul:
    call get_numbers
    imul eax, ebx
    call print_result
    jmp main_loop

do_div:
    call get_numbers
    cmp ebx, 0
    je main_loop             ; avoid divide by zero
    xor edx, edx
    div ebx
    call print_result
    jmp main_loop

; ------------------------------------------------------------
; Convert string → integer (EAX result)
; Input: ESI points to string
; ------------------------------------------------------------
str2int:
    xor eax, eax             ; result = 0
    xor ecx, ecx
.next:
    mov bl, [esi+ecx]
    cmp bl, 0
    je .done
    cmp bl, '0'
    jl .done
    cmp bl, '9'
    jg .done
    sub bl, '0'
    imul eax, eax, 10
    add eax, ebx
    inc ecx
    jmp .next
.done:
    ret

; ------------------------------------------------------------
; Print integer result
; Input: eax = number
; ------------------------------------------------------------
print_result:
    mov edi, result
    add edi, 19
    mov byte [edi], 0        ; null-terminate

    test eax, eax
    jnz .convert
    dec edi
    mov byte [edi], '0'
    jmp .show

.convert:
    mov ecx, 0               ; sign flag
    cmp eax, 0
    jge .digits
    neg eax
    mov ecx, 1               ; negative

.digits:
    dec edi
    xor edx, edx
    mov ebx, 10
    div ebx
    add dl, '0'
    mov [edi], dl
    test eax, eax
    jnz .digits

    cmp ecx, 0
    je .show
    dec edi
    mov byte [edi], '-'

.show:
    ; Print "Result: "
    mov eax, 4
    mov ebx, 1
    mov ecx, result_msg
    mov edx, result_len
    int 0x80

    ; Print number
    mov eax, 4
    mov ebx, 1
    mov ecx, edi
    mov edx, result+20
    sub edx, ecx
    int 0x80

    ; Print newline
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 2
    int 0x80
    ret

; ------------------------------------------------------------
; Exit Program
; ------------------------------------------------------------
exit_program:
    mov eax, 1
    xor ebx, ebx
    int 0x80
