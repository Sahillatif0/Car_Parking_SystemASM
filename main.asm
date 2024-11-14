INCLUDE Irvine32.inc

.data
    prompt BYTE "Enter an integer: ", 0
    msgEqual BYTE "All integers are equal", 0
    msgNotEqual BYTE "Integers are not equal", 0
    num1 DWORD ?
    num2 DWORD ?
    num3 DWORD ?
    num4 DWORD ?

.code
main PROC
    mov edx, OFFSET prompt
    call WriteString
    call ReadInt
    mov num1, eax

    mov edx, OFFSET prompt
    call WriteString
    call ReadInt
    mov num2, eax

    mov edx, OFFSET prompt
    call WriteString
    call ReadInt
    mov num3, eax

    mov edx, OFFSET prompt
    call WriteString
    call ReadInt
    mov num4, eax

    mov eax, num1
    cmp eax, num2
    jne NotEqual
    cmp eax, num3
    jne NotEqual
    cmp eax, num4
    jne NotEqual

    mov edx, OFFSET msgEqual
    jmp DisplayMessage

NotEqual:
    mov edx, OFFSET msgNotEqual

DisplayMessage:
    call WriteString
    call CrLf
    exit
main ENDP
END main
