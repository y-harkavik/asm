sseg segment stack
    db 256 DUP (?)
sseg ends    

data segment 
; add your data here! 
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
; set segment registers: 
mov ax, data 
mov ds, ax
mov es,ax  

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
      add byte ptr[bx],al
      dec length
      jmp pushInStack
      
pushInStack:
    cmp length,cl
    jge addItem
    jmp pasteStr
    
addItem:
    lodsb
    xor ah,ah
    push ax
    dec length
    jmp pushInStack     

pasteStr:
    lea si,change_str
    add si,2
    
    
    add cl,2
    xor ch,ch
    ;mov ax,[change_str+1]
    mov al,[string+1]
    add al,[change_str+1]
    lea di,string
    mov [string+1],al
    add di, cx
    
    
    
    xor cx,cx
    mov cl,[change_str+1]
    
    rep movsb 
    
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
      lea dx,answer
      call output
      lea dx,string
      add dx,2
      call output
      mov ax,4c00h
      int 21h
end start