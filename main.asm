.model small
.stack 100h

.data
    title_str    db '  8086 CALCULATOR  $'
    b_add        db ' 1. Addition    (+) $'
    b_sub        db ' 2. Subtraction (-) $'
    b_mul        db ' 3. Multiplication  $'
    b_div        db ' 4. Division    (/) $'
    b_ext        db '      5. Exit       $'
    prompt       db 'Choose (1-5) or click a button: $'

    msg1         db 10,13, 'Enter First Number : $'
    msg2         db 10,13, 'Enter Second Number: $'
    msg3         db 10,13, 'Result: $'
    msg_neg      db '-$'
    msg_rem      db '  Remainder: $'
    msg_div_zero db 10,13, 'Error: Division by zero!$'
    msg_cont     db 10,13, 10,13, 'Press any key to continue...$'

    num1 dw 0
    num2 dw 0
    choice db 0

.code

DrawBox MACRO r1, c1, r2, c2, attr
    mov ax, 0600h
    mov bh, attr
    mov ch, r1
    mov cl, c1
    mov dh, r2
    mov dl, c2
    int 10h
ENDM

GotoXY MACRO row, col
    mov ah, 02h
    xor bh, bh
    mov dh, row
    mov dl, col
    int 10h
ENDM

Print MACRO straddr
    lea dx, straddr
    mov ah, 09h
    int 21h
ENDM

main proc
    mov ax, @data
    mov ds, ax

    mov ax, 0
    int 33h

MenuLoop:
    mov ax, 2
    int 33h

    DrawBox 0, 0, 24, 79, 08h

    DrawBox 1, 14, 3, 65, 70h
    GotoXY 2, 30
    Print  title_str

    DrawBox 5, 10, 7, 35, 1Fh
    GotoXY 6, 11
    Print  b_add

    DrawBox 5, 44, 7, 69, 4Fh
    GotoXY 6, 45
    Print  b_sub

    DrawBox 10, 10, 12, 35, 2Fh
    GotoXY 11, 11
    Print  b_mul

    DrawBox 10, 44, 12, 69, 5Fh
    GotoXY 11, 45
    Print  b_div

    DrawBox 15, 30, 17, 49, 0Eh
    GotoXY 16, 31
    Print  b_ext

    DrawBox 22, 0, 23, 79, 07h
    GotoXY 22, 24
    Print  prompt

    mov ax, 1
    int 33h

WaitInput:
    mov ah, 01h
    int 16h
    jz  CheckMouse
    mov ah, 00h
    int 16h
    mov choice, al
    jmp ProcessChoice

CheckMouse:
    mov ax, 3
    int 33h
    test bx, 1
    jz  WaitInput

WaitRelease:
    mov ax, 3
    int 33h
    test bx, 1
    jnz WaitRelease

    shr cx, 3
    shr dx, 3

    cmp dx, 5
    jl  CheckB3area
    cmp dx, 7
    jg  CheckB3area
    cmp cx, 10
    jl  WaitInput
    cmp cx, 35
    jle ClickAdd
    cmp cx, 44
    jl  WaitInput
    cmp cx, 69
    jle ClickSub
    jmp WaitInput

CheckB3area:
    cmp dx, 10
    jl  CheckExitArea
    cmp dx, 12
    jg  CheckExitArea
    cmp cx, 10
    jl  WaitInput
    cmp cx, 35
    jle ClickMul
    cmp cx, 44
    jl  WaitInput
    cmp cx, 69
    jle ClickDiv
    jmp WaitInput

CheckExitArea:
    cmp dx, 15
    jl  WaitInput
    cmp dx, 17
    jg  WaitInput
    cmp cx, 30
    jl  WaitInput
    cmp cx, 49
    jle ClickExit
    jmp WaitInput

ClickAdd:  mov choice, '1'
           jmp ProcessChoice
ClickSub:  mov choice, '2'
           jmp ProcessChoice
ClickMul:  mov choice, '3'
           jmp ProcessChoice
ClickDiv:  mov choice, '4'
           jmp ProcessChoice
ClickExit: mov choice, '5'
           jmp ProcessChoice

ProcessChoice:
    mov ax, 2
    int 33h

    cmp choice, '5'
    je  ExitProg
    cmp choice, '1'
    jb  MenuLoop
    cmp choice, '4'
    ja  MenuLoop

    DrawBox 0, 0, 24, 79, 07h
    GotoXY 0, 0

ReadNumbers:
    Print msg1
    call ReadNumber
    mov num1, bx

    Print msg2
    call ReadNumber
    mov num2, bx

    Print msg3

    mov ah, 03h
    xor bh, bh
    int 10h
    mov ah, 02h
    xor bh, bh
    mov dl, 8
    int 10h

    cmp choice, '1'
    je  DoAdd
    cmp choice, '2'
    je  DoSub
    cmp choice, '3'
    je  DoMul
    cmp choice, '4'
    je  DoDiv

DoAdd:
    mov ax, num1
    add ax, num2
    jmp PrintResult

DoSub:
    mov ax, num1
    sub ax, num2
    jns PrintResult
    push ax
    Print msg_neg
    pop ax
    neg ax
    jmp PrintResult

DoMul:
    mov ax, num1
    mov bx, num2
    mul bx
    jmp PrintResult

DoDiv:
    mov ax, num1
    mov bx, num2
    test bx, bx
    jz  DivZeroError
    xor dx, dx
    div bx
    push dx
    call PrintNumber
    Print msg_rem
    pop ax
    call PrintNumber
    jmp WaitKey

DivZeroError:
    Print msg_div_zero
    jmp WaitKey

PrintResult:
    call PrintNumber

WaitKey:
    Print msg_cont
    mov ah, 07h
    int 21h
    jmp MenuLoop

ExitProg:
    DrawBox 0, 0, 24, 79, 07h
    GotoXY 0, 0
    mov ah, 4Ch
    int 21h
main endp

ReadNumber proc
    xor bx, bx
ReadLoop:
    mov ah, 01h
    int 21h
    cmp al, 13
    je  EndRead
    sub al, 30h
    xor ah, ah
    mov cx, ax
    mov ax, bx
    mov dx, 10
    mul dx
    add ax, cx
    mov bx, ax
    jmp ReadLoop
EndRead:
    ret
ReadNumber endp

PrintNumber proc
    xor cx, cx
    mov bx, 10
    test ax, ax
    jnz DivideLoop
    push ax
    inc cx
    jmp PrintLoop
DivideLoop:
    xor dx, dx
    div bx
    push dx
    inc cx
    test ax, ax
    jnz DivideLoop
PrintLoop:
    pop dx
    add dl, 30h
    mov ah, 02h
    int 21h
    loop PrintLoop
    ret
PrintNumber endp

end main
