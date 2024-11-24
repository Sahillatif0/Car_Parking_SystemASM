INCLUDE Irvine32.inc

.386
.model flat,stdcall
.stack 4096

.data

;---------------- For Color -----------------------
fore DWORD 9   ; Blue color (Foreground)
back DWORD 0    ; Black (Background)

;---------------- Car Fleet Data -----------------------
MAX_CARS = 10
carIds DWORD MAX_CARS DUP(0)        
carPrices DWORD MAX_CARS DUP(0)     
carStatus BYTE MAX_CARS DUP(0)      ; 0=available, 1=booked
currentCars DWORD 0                 

;---------------- System Variables -----------------------
tempIndex DWORD 0
carIndex DWORD 0
bookingIndex DWORD 0

;---------------- Menu Strings -----------------------
mainMenu BYTE "*********** CAR BOOKING SYSTEM ***********",0ah,0ah
        BYTE "1. Car Owner Interface",0ah
        BYTE "2. Customer Interface",0ah
        BYTE "3. Exit",0ah,0ah
        BYTE "Enter Choice: ",0

ownerMenu BYTE "--- Car Owner Interface ---",0ah,0ah
        BYTE "1. Add New Car",0ah
        BYTE "2. View Fleet Status",0ah
        BYTE "3. Return to Main Menu",0ah,0ah
        BYTE "Enter Choice: ",0

customerMenu BYTE "--- Customer Interface ---",0ah,0ah
            BYTE "1. View Available Cars",0ah
            BYTE "2. Book a Car",0ah
            BYTE "3. Return to Main Menu",0ah,0ah
            BYTE "Enter Choice: ",0

;---------------- Messages -----------------------
msgCarId BYTE "Enter Car ID: ",0
msgPrice BYTE "Enter Price per Day: ",0
msgSuccess BYTE "Operation Successful!",0ah,0
msgError BYTE "Error: Invalid Input",0ah,0
msgFull BYTE "System is Full",0ah,0
msgNotFound BYTE "ID Not Found",0ah,0
msgCarBooked BYTE "Car is Already Booked",0ah,0
msgFleetHeader BYTE "Car ID  |  Price/Day  |  Status",0ah
               BYTE "--------------------------------",0ah,0
str1 BYTE " Available",0ah,0
str2 BYTE " Booked",0ah,0

.code

main PROC
    call setColor
    call mainInterface
    exit
main ENDP

;---------------- Interface Procedures -----------------------

mainInterface PROC
    call Clrscr
    
L1: mov edx, OFFSET mainMenu
    call WriteString
    call ReadInt
    
    cmp eax, 1
    je ownerInt
    cmp eax, 2
    je customerInt
    cmp eax, 3
    je exitProg
    
    mov edx, OFFSET msgError
    call WriteString
    jmp L1
    
ownerInt:
    call ownerInterface
    jmp L1
    
customerInt:
    call customerInterface
    jmp L1
    
exitProg:
    ret
mainInterface ENDP

ownerInterface PROC
L1: call Clrscr
    mov edx, OFFSET ownerMenu
    call WriteString
    call ReadInt
    
    cmp eax, 1
    je addCar
    cmp eax, 2
    je viewFleet
    cmp eax, 3
    ret
    
    mov edx, OFFSET msgError
    call WriteString
    jmp L1
    
addCar:
    call addNewCar
    jmp L1
viewFleet:
    call displayFleet
    call WaitMsg
    jmp L1
ownerInterface ENDP

customerInterface PROC
L1: call Clrscr
    mov edx, OFFSET customerMenu
    call WriteString
    call ReadInt
    
    cmp eax, 1
    je viewCars
    cmp eax, 2
    je bookCar
    cmp eax, 3
    ret
    
    mov edx, OFFSET msgError
    call WriteString
    jmp L1
    
viewCars:
    call displayAvailableCars
    call WaitMsg
    jmp L1
bookCar:
    call createBooking
    call WaitMsg
    jmp L1
customerInterface ENDP

;---------------- Car Management Procedures -----------------------

addNewCar PROC
    mov eax, currentCars
    cmp eax, MAX_CARS
    jae full
    
    ; Get Car ID
    mov edx, OFFSET msgCarId
    call WriteString
    call ReadInt
    
    mov ebx, currentCars
    mov tempIndex, ebx
    mov esi, ebx
    shl esi, 2      ; multiply by 4 for DWORD array
    mov carIds[esi], eax
    
    ; Get Price
    mov edx, OFFSET msgPrice
    call WriteString
    call ReadInt
    mov carPrices[esi], eax
    
    ; Set status as available
    mov ebx, tempIndex
    mov carStatus[ebx], 0    
    
    inc currentCars
    mov edx, OFFSET msgSuccess
    call WriteString
    call WaitMsg
    ret
    
full:
    mov edx, OFFSET msgFull
    call WriteString
    call WaitMsg
    ret
addNewCar ENDP

displayFleet PROC
    mov edx, OFFSET msgFleetHeader
    call WriteString
    
    mov ecx, currentCars
    mov esi, 0
    cmp ecx, 0
    je empty_fleet
    
displayLoop:
    push ecx    ; Save counter
    
    ; Display Car ID
    mov eax, carIds[esi]
    call WriteDec
    mov al, ' '
    call WriteChar
    mov al, '|'
    call WriteChar
    mov al, ' '
    call WriteChar
    
    ; Display Price
    mov eax, carPrices[esi]
    call WriteDec
    mov al, ' '
    call WriteChar
    mov al, '|'
    call WriteChar
    mov al, ' '
    call WriteChar
    
    ; Display Status
    mov ebx, esi
    shr ebx, 2      ; Convert to index for carStatus
    movzx eax, carStatus[ebx]
    cmp al, 0
    je show_available
    
    ; Show booked status
    mov edx, OFFSET str2
    call WriteString
    jmp next_car
    
show_available:
    mov edx, OFFSET str1
    call WriteString
    
next_car:
    add esi, 4      ; Move to next DWORD
    pop ecx         ; Restore counter
    loop displayLoop
    
empty_fleet:
    ret
displayFleet ENDP

displayAvailableCars PROC
    mov edx, OFFSET msgFleetHeader
    call WriteString
    
    mov ecx, currentCars
    mov esi, 0
    
displayLoop:
    push ecx    ; Save counter
    
    ; Check if car is available
    mov ebx, esi
    shr ebx, 2      ; Convert to index for carStatus
    movzx eax, carStatus[ebx]
    cmp al, 0
    jne skip_car
    
    ; Display Car ID
    mov eax, carIds[esi]
    call WriteDec
    mov al, ' '
    call WriteChar
    mov al, '|'
    call WriteChar
    mov al, ' '
    call WriteChar
    
    ; Display Price
    mov eax, carPrices[esi]
    call WriteDec
    call Crlf
    
skip_car:
    add esi, 4      ; Move to next DWORD
    pop ecx         ; Restore counter
    loop displayLoop
    
    ret
displayAvailableCars ENDP

createBooking PROC
    call displayAvailableCars
    
    mov edx, OFFSET msgCarId
    call WriteString
    call ReadInt
    
    ; Store car ID temporarily
    mov carIndex, eax
    
    ; Find the car and mark it as booked
    mov ecx, currentCars
    mov esi, 0
    
findCar:
    mov eax, carIds[esi]
    cmp eax, carIndex
    je carFound
    add esi, 4
    loop findCar
    
    mov edx, OFFSET msgNotFound
    call WriteString
    ret
    
carFound:
    mov ebx, esi
    shr ebx, 2      ; Convert to index for carStatus
    movzx eax, carStatus[ebx]
    cmp al, 1
    je alreadyBooked
    
    ; Mark car as booked
    mov carStatus[ebx], 1
    
    mov edx, OFFSET msgSuccess
    call WriteString
    ret
    
alreadyBooked:
    mov edx, OFFSET msgCarBooked
    call WriteString
    ret
createBooking ENDP

setColor PROC
    mov eax, back
    mov ebx, 16
    mul ebx
    add eax, fore
    call SetTextColor
    ret
setColor ENDP

END main