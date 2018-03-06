sseg segment stack
    db 256 DUP (?)
sseg ends    

data segment 
 
    intro db "Enter string...", 0Dh,0Ah,"$"
    first_substr db 0Dh,0Ah, "Enter first substr: ",0Dh,0Ah,"$"
    second_substr db 0Dh,0Ah, "Enter second substr: ",0Dh,0Ah,"$" 
    answer db 0Dh,0Ah, "Answer:  ",0Dh,0Ah,"$"
    string db 202 dup("$")
    find_str db 202 dup("$")
    change_str db 202 dup("$") 
    length db 200
 
data ends 


code segment 
start: 
                 
mov ax, data    ;set data segment for string
mov ds, ax
mov es,ax  

lea dx, intro 
call output 
  
  
mov al, length          ;load max string length
mov [string], al        ;load max string length 
mov [string + 1], 0     ;null fact length 
lea dx, string          ;load string to dx 
call input

lea dx, first_substr 
call output 
  
  
mov [find_str], al      ;load max string length
mov [find_str + 1], 0   ;load max string length
lea dx, find_str        ;load string to dx 
call input

lea dx, second_substr 
call output 
    

mov [change_str], al    ;load max string length
mov [change_str + 1], 0 ;load max string length
lea dx, change_str      ;load string to dx 
call input
   
go:
lea bx,find_str         ; set find_str in bx
lea si,string           ; set string in si

mov al, [string + 1]    ;saving fact string length into al 
mov length, al          ;saving fact length

add bx,2                ;moving bx ptr to fisrt string character
add si,2                ;moving si ptr to fisrt string character
cld

xor dx,dx               ;null dx,ax,cx
xor ax,ax
xor cx,cx
mov dh,[find_str+1]     ;saving fact length of find_str

find_equal:
    cmp length, cl          ;check abroad
    jbe finish              ;if went to the abroad not found finish
    lodsb                   ;get sym from si in al and inc  si
    cmp byte ptr[bx], al    ;compare sym
    je l_equal              ;if equal go l_equal
    jmp not_equal           ;else not_equal

l_equal:
    inc cl          ;inc iterator
    inc bx          ;go to the next sym in find_str
    inc ah          ;num of equal sym
    cmp dh,ah       ;if we find substring
    je add_str      ;go change substr
    jmp find_equal  ;if not found all substr continue finding

not_equal:
    inc cl              ;inc iterator
    mov ch,cl           ;remember start of changable str
    xor ah,ah           ;ah=0 num of equal sym
    lea bx,find_str     ;reset bx pointer
    add bx,2            ;point on first sym
    jmp find_equal
add_str:
      std               ;set flag of direction
      lea bx,string     ;set string
      mov al,length     ;save string length
      add al,1          ;add 1 because string start of second byte and length more by one then we need
      xor ah,ah         ;null ah
      add bx,ax         ;move pointer on last sym in string
                        
      mov si,bx         ;move string in si
      mov dh, length    ;remember string length in dh
      sub dh,cl         ;num of elem in stack
      dec length        ;dec length, because numeration start from zero. example "qwerty" length=6, but 'y' has 5 address
      jmp pushInStack   ;push excess sym after substr in stack
      
pushInStack:
    cmp length,cl       ;while(cl<=length) cl - point on first substr sym 
    jge addItem         ;
    jmp pasteStr        ;if add all sym in stack
    
addItem:

    std                 ;add in stack and movsb
    lodsb               ;get sym from string and string++
    xor ah,ah
    push ax
    dec length
    jmp pushInStack     

pasteStr:
    cld
    lea si,change_str
    add si,2
    
    
    xor ax,ax
    mov al,ch           ;start point when we will put syms
    
    lea di,string
    add di,2
    add di, ax
    
    add al,[change_str+1]  ;num of sym before substr + num of sym change_str
    add al,dh              ;and +num sym in stack

    mov [string+1],al   ;change fact length in str
    
    xor cx,cx
    mov cl,[change_str+1]
     
    rep movsb           ;move sym from si to di
    
    mov cl,dh           ;return num of elem in stack
     
getFromStack:
    cmp cl,0            ;if stack empty
    je finish
    cld
    xor ax,ax
    pop ax
    stosb               ;put sym from al to di and di++
    loop getFromStack
    jmp go        
    jmp finish
                    
input proc near
    mov ah,0Ah
    int 21h
    ret
input endp

output proc near
    mov ah,9
    int 21h
    ret
output endp

finish:
      xor ax,ax         
      mov ax,'$'
      stosb           ;put terminator in the end of string
      lea dx,answer
      call output
      lea dx,string
      add dx,2
      call output
      mov ax,4c00h
      int 21h
end start