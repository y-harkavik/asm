sseg segment stack
    db 256 DUP (?)
sseg ends    

data segment 
; add your data here! 
intro db "Enter string...", 0Dh,0Ah,"$"
first_substr db 0Dh,0Ah, "Enter first substr: ",0Dh,0Ah,"$"
second_substr db 0Dh,0Ah, "Enter second substr: ",0Dh,0Ah,"$" 
string db 202 dup("$")
find_str db 202 dup("$")
change_str db 202 dup("$") 
length db 200 
data ends 


code segment 
start: 
; set segment registers: 
mov ax, data 
mov ds, ax  

lea dx, intro 
call output 
  
  
mov al, length ;load max string length in al register for subsequent loading in string buffer 
mov [string], al ;load max string length to first byte in string buffer 
mov [string + 1], 0 ;null the second string buffer byte (fact length) 
lea dx, string ;load string buffer to dx 
call input

lea dx, first_substr 
call output 
  
  
mov [find_str], al ;load max string length to first byte in string buffer 
mov [find_str + 1], 0 ;null the second string buffer byte (fact length) 
lea dx, find_str ;load string buffer to dx 
call input

lea dx, second_substr 
call output 
    

mov [change_str], al ;load max string length to first byte in string buffer 
mov [change_str + 1], 0 ;null the second string buffer byte (fact length) 
lea dx, change_str ;load string buffer to dx 
call input

lea bx,find_str
lea si,string

mov al, [string + 1] ;saving fact string length into al 
mov length, al 

add bx,2 ;moving bx ptr to fisrt string character
add si,2
cld

xor dx,dx
xor ax,ax
xor cx,cx
mov dh,[find_str+1] ;saving fact length of find_str

;add ch,2

find_equal:
    cmp length, cl   ;check abroad
    jbe finish       ;
    lodsb            ;get sym from si in al and inc  si
    cmp byte ptr[bx], al
    je l_equal
    jmp not_equal

l_equal:
    inc cl    ;inc iterator
    inc bx
    inc ah ;num of equal sym
    cmp dh,ah
    je add_str
    jmp find_equal

not_equal:
    inc cl ;i++
    
    xor ah,ah  ;ah=0
    lea bx,find_str  ;bx pointing on first sym
    add bx,2
    jmp find_equal   ;
add_str:
      std
      lea bx,string
      mov al,length
      add al,1
      add bx,al
      dec length
      jmp pushInStack
      
pushInStack:
    cmp ch,length
    jbe addItem
    jmp pasteStr
    
addItem:
    lodsb
    push al
    dec length
    jmp pushInStack     

pasteStr:
    
                    
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

end start