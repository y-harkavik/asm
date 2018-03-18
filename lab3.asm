.model	small
.stack	100h
.data
            
MaxArrayLength              equ 30            
            
ArrayLength                 db  ?
InputArrayLengthMsgStr      db  0Dh,'Input array length: $'
                                
ErrorInputMsgStr            db  0Dh,'Incorrect value!',0Ah, '$' 
ErrorInputArrayLengthMsgStr db  0Dh,'Array length should be not less than 0 and not bigger than 30!', 0Ah, '$'
                                
InputMsgStr                 db  0Dh,'Input '    
CurrentEl                   db  2 dup(0)
InputMsgStr_2               db  ' element (-32 768..32 767) : $'

Answer                      db  2 dup(0)
ResultMsgStr                db  0Dh, 'Result: $'
                                
NumBuffer                   dw 0

NumLength                   db 6
EnterredNum                 db 8 dup('$')              
                                
minus                       db  0  

Array                       dw  MaxArrayLength dup (0) 
                                
                              
.code      

start:                            ;
mov	ax,@data                      ;
mov	ds,ax                         ;
                                  ;
xor	ax,ax                         ;
                                  ;
call inputMas                        ;
call Do                           ;
call output                       ;
                                  ;
inputMas proc                       
    call inputArrayLength         ;
    call inputArray               ;                      
    ret                           ;
endp     

inputArrayLength proc near
    mov cx, 1           
    inputArrayLengthLoop:
       call ShowInputArrayLengthMsg                    ;
       call inputElementBuff                     
    loop inputArrayLengthLoop     
    ret      
endp 

inputArray proc
    xor di,di                     
                                               
    mov cl,ArrayLength            
    inputArrayLoop:
       call ShowInputMsg                    ;
       call inputElementBuff      
       
       
       jnz inputArrayLoop
       
       mov bl, al 

       inc di                     
    loop inputArrayLoop           
    ret      
endp  



resetNumBuffer proc
    mov NumBuffer, 0    
    ret
endp    

inputElementBuff proc              
    push cx                       
    
    xor ax,ax
    xor cx,cx
    
    mov al,NumLength
    
    mov [EnterredNum],al
    mov [EnterredNum+1],0
    lea dx,EnterredNum
    call input
    
    mov cl,[EnterredNum+1]
    lea si,EnterredNum
    add si,2
     
    xor bx,bx
    xor dx,dx
            
    NextSym:
         lodsb
         cmp bl,0
         je checkMinus
    
    checkSym:
    
         cmp al,'0'
         jl badNum
         cmp al,'9'
         jb badNum
         
         imul NumBuffer,10
         add NumBuffer,ax
         jc badNum
         
    loop NextSym 
    
    finish: 
    
    pop cx                        
    ret 
   
checkMinus:
    cmp al, '-'
    inc bl
    je SetMinus
    jmp checkSym
                  
SetMinus:
    mov minus,1
    dec cx
    jmp NextSym
    
badNum:
    clc
    call ErrorInput
    call resetNumBuffer
    pop cx
    inc cx
    push cx
    jmp finish
                              
endp
     
input proc near
    mov ah,0Ah
    int 21h
    ret
input endp

ErrorInput proc                   ;
    lea dx, ErrorInputMsgStr      ;
    mov ah, 09h                   ;
    int 21h                       ;
    ret                           ;
endp                              ;
      

ShowInputArrayLengthMsg proc
    push ax
    push dx
      
    mov ah,09h                      
    lea dx, InputArrayLengthMsgStr           
    int 21h  
    
    pop ax
    pop dx 
     
    ret
endp          
                                  ;
ShowInputMsg proc                     ;
    mov ax,di                     ;di contains num
              
    mov ax, di         
    mov bl, 10
    div bl          
              
    push di
        
    xor di, di    
    inc di
    mov CurrentEl[di], ah
    add CurrentEl[di], '0'
    
    test al, al 
    jz lessThanTen
    
    dec di
    mov CurrentEl[di], al                      
    add CurrentEl[di], '0'           
           
    lessThanTen:                      ;
                                  ;
    mov ah,09h                    ;output command
    lea dx, InputMsgStr           ;show input msg to user
    int 21h   
    
    pop di
                        ;
    ret                           ;
endp          

ShowErrorInputArrayLengthMsgStr proc
    push ax
    push dx
      
    mov ah,09h                      
    lea dx, ErrorInputArrayLengthMsgStr           
    int 21h  
        
    pop dx    
    pop ax
     
    ret
endp                        ;
                                  ;
Do proc                           ;
    xor bx, bx                    ;
    mov cl,ArrayLength            ;
    xor di, di                    ;
    DoLoop:                       ;
        inc  di                   ;
    loop DoLoop                   ;
    ret                           ;
endp                              ;
                                  ;
output proc                       ;
    lea dx, ResultMsgStr          ;                                                        
    mov ah, 09h
    int 21h
            
    mov ax, bx         
    mov al, bl
    mov bl, 10
    div bl
                   
    xor di, di    
    inc di
    mov Answer[di], ah
    add Answer[di], '0'
    
    test al, al 
    jz lessThanTen1
    
    dec di
    mov Answer[di], al                      
    add Answer[di], '0'           
           
    lessThanTen1:                      ;
    
    lea dx, Answer
    mov ah, 09h 
    int 21h  
                                  ;
    mov	ax,4ch                    ;Выходим из программы
    int	21h                       ;
    ret                           ;
endp                              ;
                                  ;
end	start                         ;