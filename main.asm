INCLUDE Irvine32.inc

.386

.stack 4096

.data
;---------------- For Color -----------------------
fore DWORD 9   ; Blue color (Foreground)
back DWORD 0   ; Black (Background)

;---------------- Car Fleet Data -----------------------
MAX_CARS = 10
carIds DWORD MAX_CARS DUP(0)        
carPrices DWORD MAX_CARS DUP(0)     
carStatus BYTE MAX_CARS DUP(0)      ; 0=available, 1=booked
carMileage DWORD MAX_CARS DUP(0)    ; Track car mileage
currentCars DWORD 0                 

;---------------- System Variables -----------------------
tempIndex DWORD 0
carIndex DWORD 0
bookingIndex DWORD 0
inputValid BYTE 0    ; For input validation
buffer BYTE 21 DUP(0)  ; General input buffer

;---------------- Menu Strings -----------------------
mainMenu BYTE "========== CAR BOOKING SYSTEM ==========",0ah,0ah
        BYTE "1. Car Owner Interface",0ah
        BYTE "2. Customer Interface",0ah
        BYTE "3. View System Statistics",0ah
        BYTE "4. Exit",0ah,0ah
        BYTE "Enter Choice: ",0

ownerMenu BYTE "---------- Car Owner Interface ----------",0ah,0ah
        BYTE "1. Add New Car",0ah
        BYTE "2. View Fleet Status",0ah
        BYTE "3. Return to Main Menu",0ah,0ah
        BYTE "Enter Choice: ",0

customerMenu BYTE "---------- Customer Interface ----------",0ah,0ah
            BYTE "1. View Available Cars",0ah
            BYTE "2. Book a Car",0ah
            BYTE "3. Return Car",0ah
            BYTE "4. Search by Price Range",0ah
            BYTE "5. Return to Main Menu",0ah,0ah
            BYTE "Enter Choice: ",0

;---------------- Messages -----------------------
msgCarId BYTE "Enter Car ID (1000-9999): ",0
msgPrice BYTE "Enter Price per Day ($10-$1000): $",0
msgMileage BYTE "Enter Car Mileage: ",0
msgSuccess BYTE 0ah,"Operation Successful!",0ah,0
msgError BYTE 0ah,"Error: Invalid Input!",0ah,0
msgFull BYTE 0ah,"Error: System is Full!",0ah,0
msgNotFound BYTE 0ah,"Error: Car ID Not Found!",0ah,0
msgCarBooked BYTE 0ah,"Error: Car is Already Booked!",0ah,0
msgCarNotBooked BYTE 0ah,"Error: Car is Not Booked!",0ah,0
msgMinPrice BYTE "Enter Minimum Price: $",0
msgMaxPrice BYTE "Enter Maximum Price: $",0
msgReturnMileage BYTE "Enter Return Mileage: ",0
msgInvalidId BYTE 0ah,"Error: ID must be between 1000 and 9999!",0ah,0
msgInvalidPrice BYTE 0ah,"Error: Price must be between $10 and $1000!",0ah,0
msgInvalidMileage BYTE 0ah,"Error: New mileage must be greater than current mileage!",0ah,0
msgRemoveConfirm BYTE "Are you sure you want to remove this car? (1=Yes, 0=No): ",0
msgStatHeader BYTE "---------- System Statistics ----------",0ah,0
msgTotalCars BYTE "Total Cars in System: ",0
msgAvailCars BYTE "Available Cars: ",0
msgBookedCars BYTE "Booked Cars: ",0
totalCarsMsg BYTE "Total Cars: ", 0
availableCarsMsg BYTE "Available Cars: ", 0
noCarsToDisplayMsg BYTE "No Car available to display",0ah, 0
emptyArrayMsg BYTE "Empty error: Access to uninitialized memory space", 0
msgFleetHeader BYTE "Car ID  |  Price/Day  |  Mileage  |  Status",0ah
               BYTE "----------------------------------------",0ah,0
msgPressKey BYTE 0ah,"Press any key to continue...",0ah,0
str1 BYTE " Available",0ah,0
str2 BYTE " Booked",0ah,0
; Car Booking Office Exterior Design
officeArtLine1  BYTE "     _____________________________________________________", 0
officeArtLine2  BYTE "    |  _________________________________________________  |", 0
officeArtLine3  BYTE "    | |                                                 | |", 0
officeArtLine4  BYTE "    | |       CAR BOOKING OFFICE                        | |", 0
officeArtLine5  BYTE "    | |                                                 | |", 0
officeArtLine6  BYTE "    | |   Welcome to Smooth Rides Car Rentals           | |", 0
officeArtLine7  BYTE " ___| |_________________________________________________| |___", 0
officeArtLine8  BYTE "|                                                         |", 0
officeArtLine9  BYTE "|  [ENTRANCE]     __________     [PARKING]                |", 0
officeArtLine10 BYTE "|               |  __  __  |                              |", 0
officeArtLine11 BYTE "|    _____       | |  ||  | |       _____                 |", 0
officeArtLine12 BYTE "|   /     \      | |__||__| |      /     \                |", 0
officeArtLine13 BYTE "|  | INFO  |     |  __  __  |     | CARS  |               |", 0
officeArtLine14 BYTE "|   \_____/      | |__||__| |      \_____/                |", 0
officeArtLine15 BYTE "|               |__________|                              |", 0
officeArtLine16 BYTE "|_______________________________________________________|", 0



;Horizontal Design
horizontalCarsLine1   db "        _______     _______     _______     _______    ", 0
horizontalCarsLine2   db "       /|_||_  |   /|_||_  |   /|_||_  |   /|_||_  |   ", 0
horizontalCarsLine3   db "      (   *    *| (   *    *| (   *    *| (   *    *|  ", 0
horizontalCarsLine4   db "       (_)  (_)    (_)  (_)    (_)  (_)    (_)  (_)    ", 0
horizontalCarsLine5   db " ___________________   ___________________  ___________________  ___________________                              ", 0
horizontalCarsLine6   db " /|_  |  ___    ___ | /|_  |  ___    ___ | /|_  |  ___    ___ | /|_  |  ___    ___ |", 0
horizontalCarsLine7   db "(   _| |   |   |   ||    _| |   |   |   ||    _| |   |   |   ||    _| |   |   |   ||", 0
horizontalCarsLine8   db " `--(_)--(_)--(_)--'  `--(_)--(_)--(_)--'  `--(_)--(_)--(_)--'  `--(_)--(_)--(_)--' ", 0
horizontalCarsLine9   db "    ____|_|____      ____|_|____      ____|_|____      ____|_|____     ", 0
horizontalCarsLine10  db "   /    | |    \     /    | |    \     /    | |    \     /    | |    \    ", 0
horizontalCarsLine11  db "  (     | |     )   (     | |     )   (     | |     )   (     | |     )   ", 0
horizontalCarsLine12  db "   `-(_)--(_)--'     `-(_)--(_)--'     `-(_)--(_)--'     `-(_)--(_)--'    ", 0
horizontalCarsLine13  db "    _____|_____       _____|_____       _____|_____       _____|_____    ", 0
horizontalCarsLine14  db "   /     |     \     /     |     \     /     |     \     /     |     \   ", 0
horizontalCarsLine15  db "  (______|______|   (______|______|   (______|______|   (______|______|  ", 0
horizontalCarsLine16  db "   |     |     |     |     |     |     |     |     |     |     |     |   ", 0
horizontalCarsLine17  db "   `-(_)--(_)--'     `-(_)--(_)--'     `-(_)--(_)--'     `-(_)--(_)--'   ", 0
.code
main PROC
    
    call displayCarArt
    call setColor
    call mainInterface
    exit
main ENDP
displayCarArt PROC

    mov edx, OFFSET officeArtLine1
    call WriteString
    call Crlf

    mov edx, OFFSET officeArtLine2
    call WriteString
    call Crlf

    mov edx, OFFSET officeArtLine3
    call WriteString
    call Crlf

    mov edx, OFFSET officeArtLine4
    call WriteString
    call Crlf

    

    mov edx, OFFSET officeArtLine5
    call WriteString
    call Crlf

    mov edx, OFFSET officeArtLine6
    call WriteString
    call Crlf


    mov edx, OFFSET officeArtLine7
    call WriteString
    call Crlf


    mov edx, OFFSET officeArtLine8
    call WriteString
    call Crlf

    mov edx, OFFSET officeArtLine9
    call WriteString
    call Crlf

    mov edx, OFFSET officeArtLine10
    call WriteString
    call Crlf


    mov edx, OFFSET officeArtLine11
    call WriteString
    call Crlf

    mov edx, OFFSET officeArtLine12
    call WriteString
    call Crlf

    mov edx, OFFSET officeArtLine13
    call WriteString
    call Crlf


    mov edx, OFFSET officeArtLine14
    call WriteString
    call Crlf

    mov edx, OFFSET officeArtLine15
    call WriteString
    call Crlf

    mov edx, OFFSET officeArtLine16
    call WriteString
    call Crlf

    mov edx, OFFSET horizontalCarsLine1
    call WriteString
    call Crlf

    mov edx, OFFSET horizontalCarsLine2
    call WriteString
    call Crlf

    mov edx, OFFSET horizontalCarsLine3
    call WriteString
    call Crlf

    mov edx, OFFSET horizontalCarsLine4
    call WriteString
    call Crlf

    mov edx, OFFSET horizontalCarsLine5
    call WriteString
    call Crlf

    mov edx, OFFSET horizontalCarsLine6
    call WriteString
    call Crlf

    mov edx, OFFSET horizontalCarsLine7
    call WriteString
    call Crlf

    mov edx, OFFSET horizontalCarsLine8
    call WriteString
    call Crlf

    mov edx, OFFSET horizontalCarsLine9
    call WriteString
    call Crlf

    mov edx, OFFSET horizontalCarsLine10
    call WriteString
    call Crlf

    mov edx, OFFSET horizontalCarsLine11
    call WriteString
    call Crlf


    mov edx, OFFSET horizontalCarsLine12
    call WriteString
    call Crlf


    mov edx, OFFSET horizontalCarsLine13
    call WriteString
    call Crlf


    mov edx, OFFSET horizontalCarsLine14
    call WriteString
    call Crlf


    mov edx, OFFSET horizontalCarsLine15
    call WriteString
    call Crlf



    mov edx, OFFSET horizontalCarsLine16
    call WriteString
    call Crlf

    mov edx, OFFSET horizontalCarsLine17
    call WriteString
    call Crlf


   
    ret

displayCarArt ENDP
;---------------- Interface Procedures -----------------------
setColor PROC
    mov eax, back
    mov ebx, 16
    mul ebx
    add eax, fore
    call SetTextColor
    ret
setColor ENDP

displayCarDetails PROC
    ; Input: ESI = index of car to display
    push eax        ; Save registers we'll use
    push ebx
    push ecx
    
    ; Display Car ID (already displayed by caller)
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
    
    ; Display Mileage
    mov eax, carMileage[esi]
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
    
    mov edx, OFFSET str2    ; Show "Booked"
    call WriteString
    jmp end_display
    
show_available:
    mov edx, OFFSET str1    ; Show "Available"
    call WriteString
    
end_display:
    pop ecx         ; Restore registers
    pop ebx
    pop eax
    ret
displayCarDetails ENDP

; Here's the corrected searchByPrice procedure that uses displayCarDetails
searchByPrice PROC
    LOCAL minPrice:DWORD, maxPrice:DWORD
    mov ecx, currentCars
    cmp ecx, 0
    je no_car_avail
    mov edx, OFFSET msgMinPrice
    call WriteString
    call ReadInt
    mov minPrice, eax
    
    mov edx, OFFSET msgMaxPrice
    call WriteString
    call ReadInt
    mov maxPrice, eax
    mov edx, OFFSET msgFleetHeader
    call WriteString
    
    mov esi, 0
    
searchLoop:
    push ecx
    
    ; Check price range
    mov ecx, carPrices[esi]
    cmp ecx, minPrice
    jl skipCar
    cmp ecx, maxPrice
    jg skipCar
    
    ; Display car details if in range
    mov eax, carIds[esi]
    call WriteDec    ; Display ID first
    call displayCarDetails  ; Then display rest of details
    
skipCar:
    add esi, 4
    pop ecx
    loop searchLoop
    jmp exit_func
no_car_avail:
    mov edx, OFFSET noCarsToDisplayMsg
    call WriteString
exit_func:
    ret
searchByPrice ENDP
mainInterface PROC
L1: 
    mov edx, OFFSET mainMenu
    call WriteString
    call ReadInt
    
    cmp eax, 1
    je ownerInt
    cmp eax, 2
    je customerInt
    cmp eax, 3
    je statsInt
    cmp eax, 4
    je exitProg
    
    mov edx, OFFSET msgError
    call WriteString
    call WaitMsg
    jmp L1
    
ownerInt:
    call ownerInterface
    jmp L1
customerInt:
    call customerInterface
    jmp L1
statsInt:
    call displaySystemStats
    jmp L1
exitProg:
    ret
mainInterface ENDP

displaySystemStats PROC
    ; Check if the array is empty
    cmp currentCars, 0
    je empty_stats

    ; Display total cars
    mov edx, OFFSET totalCarsMsg ; Message: "Total Cars: "
    call WriteString
    mov eax, currentCars
    call WriteDec
    call Crlf

    ; Count available cars
    xor esi, esi        ; Initialize index
    xor ebx, ebx        ; Initialize available cars counter

countLoop:
    cmp esi, currentCars
    jae finishCount     ; Jump if done counting

    movzx eax, carStatus[esi]
    cmp al, 0
    jne skipCount       ; Skip if not available
    inc ebx             ; Increment available cars counter

skipCount:
    inc esi             ; Move to next status
    jmp countLoop       ; Continue counting

finishCount:
    mov edx, OFFSET availableCarsMsg ; Message: "Available Cars: "
    call WriteString
    mov eax, ebx        ; Move count to eax for display
    call WriteDec
    call Crlf

    call WaitMsg
    ret

empty_stats:
    mov edx, OFFSET emptyArrayMsg    ; Message: "No cars available."
    call WriteString
    call Crlf
    ret
displaySystemStats ENDP


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

    call Clrscr
    ret
    
    mov edx, OFFSET msgError
    call WriteString
    call WaitMsg
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
    je returnCar
    cmp eax, 4
    je searchPrice
    cmp eax, 5
    ret
    
    mov edx, OFFSET msgError
    call WriteString
    call WaitMsg
    jmp L1
    
viewCars:
    call displayAvailableCars
    call WaitMsg
    jmp L1
bookCar:
    call createBooking
    call WaitMsg
    jmp L1
returnCar:
    call processReturn
    call WaitMsg
    jmp L1
searchPrice:
    call searchByPrice
    call WaitMsg
    jmp L1
customerInterface ENDP

;---------------- Validation Procedures -----------------------

validateCarId PROC
    cmp eax, 1000
    jl invalid_id
    cmp eax, 9999
    jg invalid_id
    mov inputValid, 1
    ret
invalid_id:
    mov edx, OFFSET msgInvalidId
    call WriteString
    mov inputValid, 0
    ret
validateCarId ENDP

validatePrice PROC
    cmp eax, 10
    jl invalid_price
    cmp eax, 1000
    jg invalid_price
    mov inputValid, 1
    ret
invalid_price:
    mov edx, OFFSET msgInvalidPrice
    call WriteString
    mov inputValid, 0
    ret
validatePrice ENDP

validateMileage PROC
    ; EAX = new mileage, EBX = current mileage
    cmp eax, ebx
    jle invalid_mileage
    mov inputValid, 1
    ret
invalid_mileage:
    mov edx, OFFSET msgInvalidMileage
    call WriteString
    mov inputValid, 0
    ret
validateMileage ENDP

;---------------- Car Management Procedures -----------------------

addNewCar PROC
    mov eax, currentCars
    cmp eax, MAX_CARS
    jae full
    
get_id:
    mov edx, OFFSET msgCarId
    call WriteString
    call ReadInt
    call validateCarId
    cmp inputValid, 0
    je get_id
    
    ; Store car ID
    mov ebx, currentCars
    mov tempIndex, ebx
    mov esi, ebx
    shl esi, 2      ; multiply by 4 for DWORD array
    mov carIds[esi], eax
    
get_price:
    mov edx, OFFSET msgPrice
    call WriteString
    call ReadInt
    call validatePrice
    cmp inputValid, 0
    je get_price
    
    mov carPrices[esi], eax
    
    ; Get initial mileage
    mov edx, OFFSET msgMileage
    call WriteString
    call ReadInt
    mov carMileage[esi], eax
    
    ; Set as available
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
    LOCAL count:DWORD, carLength:DWORD
    xor esi, esi
    mov carLength, LENGTHOF carIds
    mov count, 0
displayLoop1:
    mov ebx, carLength
    cmp count, ebx
    jae empty_fleet     

    ; Display Car ID
    mov eax, carIds[esi]
    cmp eax, 0
	je empty_fleet
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

    ; Display Mileage
    mov eax, carMileage[esi]
    call WriteDec
    mov al, ' '
    call WriteChar
    mov al, '|'
    call WriteChar
    mov al, ' '
    call WriteChar

    ; Display Status
    mov ebx, esi
    shr ebx, 2          ; Divide by 4 to get status index
    movzx eax, carStatus[ebx]
    cmp al, 0
    je show_available

    mov edx, OFFSET str2    ; Display "Not Available"
    call WriteString
    jmp next_car

show_available:
    mov edx, OFFSET str1    ; Display "Available"
    call WriteString

next_car:
    inc count
    add esi, 4          ; Move to next car (4 bytes per entry)
    jmp displayLoop1    ; Continue loop

empty_fleet:
    ret
displayFleet ENDP

displayAvailableCars PROC
    mov edx, OFFSET msgFleetHeader
    call WriteString
    
    mov ecx, currentCars
    cmp ecx, 0
    je no_car_to_display
    mov esi, 0
    
displayLoop:
    push ecx
    
    ; Check if available
    mov ebx, esi
    shr ebx, 2
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
    mov al, ' '
    call WriteChar
    mov al, '|'
    call WriteChar
    mov al, ' '
    call WriteChar
    
    ; Display Mileage
    mov eax, carMileage[esi]
    call WriteDec
    call Crlf
    
skip_car:
    add esi, 4
    pop ecx
    loop displayLoop
    jmp exit_func
no_car_to_display:
    mov edx, offset noCarsToDisplayMsg
    call writeString
exit_func:
    ret
displayAvailableCars ENDP

createBooking PROC
    call displayAvailableCars
    mov ecx, currentCars
    cmp ecx, 0
    je exit_func
    mov edx, OFFSET msgCarId
    call WriteString
    call ReadInt
    
    mov carIndex, eax
    
    ; Find car
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
    shr ebx, 2
    movzx eax, carStatus[ebx]
    cmp al, 1
    je alreadyBooked
    
    mov carStatus[ebx], 1
    
    mov edx, OFFSET msgSuccess
    call WriteString
    ret
    
alreadyBooked:
    mov edx, OFFSET msgCarBooked
    call WriteString
exit_func:
    ret
createBooking ENDP

processReturn PROC
    mov ecx, currentCars
    cmp ecx, 0
    je no_car_avail
    mov edx, OFFSET msgCarId
    call WriteString
    call ReadInt
    
    mov carIndex, eax
    
    ; Find car
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
    shr ebx, 2
    movzx eax, carStatus[ebx]
    cmp al, 0
    je notBooked
    
    ; Get return mileage
get_mileage:
    mov edx, OFFSET msgReturnMileage
    call WriteString
    call ReadInt
    
    ; Validate mileage
    push eax            ; Save new mileage
    mov ebx, carMileage[esi]  ; Get current mileage
    pop eax             ; Restore new mileage
    call validateMileage
    cmp inputValid, 0
    je get_mileage
    
    mov carMileage[esi], eax
    mov carStatus[esi], 0
    
    mov edx, OFFSET msgSuccess
    call WriteString
    exit_func:
    ret
    
notBooked:
    mov edx, OFFSET msgCarNotBooked
    call WriteString
    jmp exit_func2
no_car_avail:
    mov edx, OFFSET noCarsToDisplayMsg
    call WriteString
exit_func2:
    ret
processReturn ENDP



END main