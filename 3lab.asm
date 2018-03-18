.model	small
.stack	100h
.data
            
MaxArrayLength              equ 30            
            
ArrayLength                 dw  ?
InputArrayLengthMsgStr      db  'Input array length: $'
                                
ErrorInputMsgStr            db  0Ah,0Dh,'Incorrect value!',0Ah,0Dh, '$' 
ErrorInputArrayLengthMsgStr db  0Ah,0Dh,'Array length should be not less than 0 and not bigger than 30!', '$'
                                
InputMsgStr                 db 0Ah, 0Dh,'Input '    
CurrentEl                   db  2 dup(0)
InputMsgStr_2               db  ' element (-32 768..32 767) : $'

Answer                      db  2 dup(0)
ResultMsgStr                db  0Dh, 'Result: $'
                                
NumBuffer                   dw 0

NumLength                   db 7
EnterredNum                 db 9 dup('$')              
       
ten                         dw 10
two                         dw 2	
precision                   db  5             
minus                       db  0  
Max                         dw  0
Array                       dw  MaxArrayLength dup (0)
Temp                        dd 0
OutputArray                 dd MaxArrayLength dup(0) 
                                
                              
.code      

start:                            ;
mov	ax,@data                      ;
mov	ds,ax                         ;
                                  ;
xor	ax,ax                         ;
                                  ;
call inputMas                     ;
call FindMax                      ;
call MakeNormal
                                  ;
inputMas proc                       
    call inputArrayLength         ;
    call inputArray               ;                      
    ret                           ;
endp     

inputArrayLength proc near
    mov cx, 1           
    inputArrayLengthLoop:
       call ShowInputArrayLengthMsg
       push cx                    ;
       call inputElementBuff
       pop cx
       mov ArrayLength,ax
       cmp ArrayLength,0
       jle lengthError
       cmp ArrayLength,30
       jg  lengthError
                            
    loop inputArrayLengthLoop     
    ret      
endp

lengthError:
    call ErrorInput
    jmp  inputArrayLengthLoop
    
inputArray proc
    xor di,di                     
                                               
    mov cx,ArrayLength            
    inputArrayLoop:
       call ShowInputMsg
       push cx                    ;
       call inputElementBuff
       pop cx      
       
       mov Array[di], ax 

       add di,2                     
    loop inputArrayLoop           
    ret      
endp  



resetNumBuffer proc
    mov NumBuffer, 0    
    ret
endp    

inputElementBuff proc                                     
    
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
    
    xor ax,ax 
    xor bx,bx
    xor dx,dx
    mov dx,10        
    NextSym:
         xor ax,ax
         lodsb
         cmp bl,0
         je checkMinus
    
    checkSym:
         
         cmp al,'0'
         jl badNum
         cmp al,'9'
         jg badNum
         
         sub ax,'0'
         mov bx,ax
         xor ax,ax
         mov ax,NumBuffer
         
         mul dx
         jo badNum
         add ax, bx
         jo badNum
         mov NumBuffer,ax
         mov bx,1
         mov dx,10
         
    loop NextSym 
    
    mov ax,NumBuffer
    
    cmp minus,0
    je finish
    mov dx,-1
    mul dx
    mov minus,0
    
    finish: 
    call resetNumBuffer                        
    ret 
   
checkMinus:
    inc bl
    cmp al, '-'
    
    je SetMinus
    
    jmp checkSym
                  
SetMinus:
    mov minus,1
    dec cx
    cmp cx,0
    je badNum
    jmp NextSym
    
badNum:
    clc
    mov minus,0
    call ErrorInput
    call resetNumBuffer
    jmp inputElementBuff                            
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
    
    pop dx
    pop ax 
     
    ret
endp          
                                  ;
ShowInputMsg proc                     ;
    push ax
    push dx                      ;
                                  ;
    mov ah,09h                    ;output command
    lea dx, InputMsgStr           ;show input msg to user
    int 21h   
    
    pop dx
    pop ax                    
    ret                           
endp                        
                                  ;
FindMax proc near
    xor di,di
                          
    mov cx, ArrayLength
    mov ax,Array[di]
    add di,2
    dec cx
    cmp cx,0
    je endFind
    find:
        cmp cx,0
        je endFind
        mov dx,Array[di]
        cmp ax,dx
        jl saveMax
        add di,2
    loop find
    
    jmp endFind
    
    saveMax:
        mov ax,dx
        add di,2
        dec cx
        
        jmp find    
    endFind:
    mov Max,ax               
    ret                           ;
endp                              ;

MakeNormal proc near
    xor cx,cx
    mov cl,byte ptr [ArrayLength]
    xor di,di
    xor si,si
    xor ax,ax
    xor dx,dx
    
    make:
        cmp cl,0
        je goEnd
        xor dx,dx
        mov ax, Array[di]
        xor ch,ch
        mov Temp,0
    makeNum: 
        cmp ch,precision
        jg saveNum
        mov bx,ax
        
        idiv Max
        
        cmp ax,0
        
        je increase
        
        push dx
        mov bx,ax
        
        mov ax,Temp
        imul ten
        
       
        add ax,bx
        
        mov Temp,dx
        sal Temp,16
        add Temp,ax
        pop dx
        mov ax,dx
        imul ten
        inc ch
        jmp makeNum
        
        
    increase:
        inc ch
        
        mov ax,Temp
        imul ten
        mov Temp,ax 
        mov ax,bx

        imul ten
        
        
        jmp makeNum
        
    saveNum:
        
        
    goEnd:    
    ret    
endp     
                                      ;
output proc                       ;
                          ;
    ret                           ;
endp                              ;
                                  ;
end	start                         ;