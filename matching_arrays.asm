section .data
    new_line db ' ', 0x0a
    var1 dd 0
    var2 db 48
    k equ 9
    n equ 6
    m equ 5
    C TIMES m db 48 ;same as length as B array, because C can olny have m elemnts max
    A TIMES n db 0
    B TIMES m db 0
    

section .text
    global _start

_start:

    ; Filling the A array with random numbers
    mov ecx, n   ; loop iterations
    mov ebp, A   ; assign Array A adress to register ebp
l1:
    push ecx
    rdtsc  ; instruction that retrieves basically system time in edx:eax, eax - low order part, in short it's time(null) like in C
           ; eax now holds our random number
    
    mov ecx, k   ; our upper bound - [x : 9] ///  our K is inclusive

    ; now we will set range: (random % upper_bound) + lower_bound

    xor edx, edx ; clear edx value for the MOD instructon
    div ecx      ; this means edx:eax / ecx, which will result in edx being our remainder, this is simply how it works :) (random % upper_bound)
    mov eax, edx ; replace our random number with random number in range
    add eax, 1   ; our lower bound, inclusive
    add eax, 48  ; this is to print our numbers, because ASCII number starts after 48
    mov [ebp], eax

    add ebp, 1   ; increment this adress by 1

    pop ecx
    loop l1      ; Fill A with random numbers

    push n       ; give array size as a parameter
    push A       ; give array as a parameter
    call print_array    ;print our A array



    ; Filling the B array with random numbers that do not repeat
    mov ecx, m   ; loop iterations
    mov ebp, B   ; assign Array A adress to register ebp
l3:
    ; generate a random number
    push ecx  ;preserve loop counter
GEN:
    rdtsc  
    mov ecx, n  
    xor edx, edx 
    div ecx      
    mov eax, edx 
    add eax, 1   
    add eax, 48  


    ; our if loop starts here
    push ebp    ;preserve B array pointer

    mov ebp, B ; set ebp to the start of array B
    mov ecx, m ; set itterations for the whole loop
    mov [var1], eax
    mov al, byte [var1]  ; to avoid trash we only take the first byte

l4:
    mov ah, byte [ebp]   ; to avoid trash we only take the first byte of the curent element 
    cmp al, ah
    je REPEAT   ; what to do if they're equal
    add ebp, 1  ; increase aray B pointer
    loop l4

    
    ; our if loops ends here
    pop ebp

    mov [ebp], eax  ; add random number to the array
    add ebp, 1   ; increment this adress by 1

    pop ecx
    loop l3      ; Fill B with random numbers


    push m       ; give array size as a parameter
    push B       ; give array as a parameter
    call print_array    ;print B array
    
    
    ;Now, we will pass values from A that match index as a number with B values to C array
    mov ebp, B  ;track B array
    mov ecx, m  ; set itterations
    mov edx, A  ;track A array
    mov ebx, C  ;track C array
l5:
    push ecx    ;preserve itteration count
    
    
    mov ah, byte [ebp]  ;avoid the trash and move the number byte to ah registry
    mov al, [var2]      ;set ah registry as 0, which will be our index
    
    
    cmp ah, al          ;check whether index is equal to the corresponding B value
    je TRANSFER
CONTINUE:
    add ebp, 1          ;increase all the counters by 1
    add edx, 1
    add ebx, 1
    mov eax, 1
    add [var2], eax
    pop ecx
    loop l5
    
    push m       ; give array size as a parameter
    push C       ; give array as a parameter
    call print_array    ;print C array
   



    mov eax, 1
    mov ebx, 0
    int 0x80 ;exit


    
print_array:

    mov ebp, [esp + 4] ;retrieving the array
    mov ecx, [esp + 8] ;retrieving the array size

    l2:
    push ecx
    mov eax, 4
    mov ebx, 1
    mov ecx, ebp
    mov edx, 1
    int 0x80
    add ebp, 1
    pop ecx

    loop l2
    mov eax, 4
    mov ebx, 1
    mov ecx, new_line
    mov edx, 1
    int 0x80
    ret

REPEAT:
    pop ebp ;retrieve the old B array pointer
    jmp GEN ; jump to the GEN step
    
TRANSFER:
    mov al, byte [edx] ;move the number byte from the A array
    mov [ebx], al      ;move it to the C array
    jmp CONTINUE
    



