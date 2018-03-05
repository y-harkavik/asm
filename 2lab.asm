dseg segment
                                    
                                    
dseg ends
 
 
sseg segment stack
                                    
            db  60  dup (?)
    top     db  ?
                                    
sseg ends
 
 
cseg segment
 
assume  cs: cseg,   ds: dseg,   ss: sseg
 
main:
    
                                    
    mov ax, dseg                ; ????????? ???????? ??????
    mov ds, ax
    
    xor ah, ah
    mov al, str_max
    mov [buffer], al  
    mov byte ptr[buffer+1],0       
                         
    mov ah, 0ah             ; ?????? ??????
    lea dx, buffer
    int 21h     


 
cseg ends
end  main