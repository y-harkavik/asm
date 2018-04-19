.model small

.stack 100h

.data    

startDX               dw  0
tempDX                dw  0
flagTemp              dw  0
flagStart             dw  0

maxCMDSize equ 127
cmd_size              db  ?
cmd_text              db  maxCMDSize + 2 dup(0)
sourcePath            db  128 dup (0) 

path                  db "kol.txt",0
destinationPath       db  "output.txt",0
extension             db "txt"       
point2                db '.'
buf                   db  0                      
sourceID              dw  0
destinationID         dw  0                                              
                            
newLineSymbol         equ 0Dh
returnSymbol          equ 0Ah                           
endl                  equ 0

enteredString         db 200 dup("$")
enteredStringSize     dw 0

startProcessing       db "Processing started",'$'                      
startText             db  "Program is started",                                               '$'
badCMDArgsMessage     db  "Bad command-line arguments.",                                      '$'
badSourceText         db  "Open error", "$"    
fileNotFoundText      db  "File not found",                                                   '$'
endText               db  0Dh,0Ah,"Program is ended",                                     '$'
errorReadSourceText   db  "Error reading from source file",                                   '$'

.code

scanf MACRO string
    push ax
    push dx
    
    lea dx, string
    mov ah, 0Ah
    int 21h
    
    pop dx
    pop ax
endm

println MACRO info          ;
	push ax                 ;
	push dx                 ;
                            ;
	mov ah, 09h             ; Команда вывода 
	lea dx, info            ; Загрузка в dx смещения выводимого сообщения
	int 21h                 ; Вызов прервывания для выполнения вывода
                            ;
	mov dl, 0Ah             ; Символ перехода на новую строку
	mov ah, 02h             ; Команда вывода символа
	int 21h                 ; Вызов прерывания
                            ;
	mov dl, 0Dh             ; Символ перехода в начало строки   
	mov ah, 02h             ;
	int 21h                 ;            ==//==
                            ;
	pop dx                  ;
	pop ax                  ;
ENDM

strcpy MACRO destination, source, count
    push cx
    push di
    push si
    
    xor cx, cx
    
    mov cl, count
    lea si, source
    lea di, destination
    
    rep movsb
    
    pop si
    pop di
    pop cx
ENDM   
;11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
incrementTempPos MACRO num
    add tempDX, num
    jo overflowTempPos
    jmp endIncrementTempPos
     
overflowTempPos:
    inc flagTemp
    add tempDX, 32769
    jmp endIncrementTempPos
    
endIncrementTempPos:
            
endm 
;22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
incrementStartPos proc
    push ax
    
    mov ax, tempDX
    add startDX, ax
    jo overflow
    jmp endIncrement
     
overflow:
    inc flagStart
    add startDX, 32769
    
endIncrement:
    mov ax, flagTemp
    add flagStart, ax
     
    pop ax
    ret    
endp    
;----------------------------------------------------------------------------------------------------  
fseekCurrent MACRO settingPos
    push ax                     ;                     ;
	push cx                     ;
	push dx
	
	mov ah, 42h                 ; Записываем в ah код 42h - ф-ция DOS уставноки указателя файла
	mov al, 1
	mov cx, 0                   ; Обнуляем cx, 
	mov dx, settingPos	        ; Обнуляем dx, т.е премещаем указатель на 0 символов от начала файла (cx*2^16)+dx 
	int 21h                     ; Вызываем прерывания DOS для исполнения команды   
                                ;
	pop dx                      ; Восстанавливаем значения регистров и выходим из процедуры
	pop cx                      ;                     ;
	pop ax               
ENDM
;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
fseek MACRO fseekPos
    push ax                     ;                     ;
	push cx                     ;
	push dx
	
	mov ah, 42h                 ; Записываем в ah код 42h - ф-ция DOS уставноки указателя файла
	mov al, 0 			        ; Обнуляем al, т.к. al=0 - код перемещения указателя в начало файла 
	mov cx, 0                   ; Обнуляем cx, 
	mov dx, fseekPos            ; Обнуляем dx, т.е премещаем указатель на 0 символов от начала файла (cx*2^16)+dx 
	int 21h                     ; Вызываем прерывания DOS для исполнения команды   
                                ;
	pop dx                      ; Восстанавливаем значения регистров и выходим из процедуры
	pop cx                      ;                     ;
	pop ax    
           
ENDM
;""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
setPointer proc
    push cx
    push bx
    
    mov bx, sourceID
    fseek startDX
    
    cmp flagStart, 0
    je endSetPos
    xor cx, cx    
    mov cx, flagStart
    
setPos1:
    mov bx, sourceID
    fseekCurrent 32767
    loop setPos1 
    
endSetPos:
   
   pop bx
   pop cx
   ret 
endp 
;/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
main:
	mov ax, @data           ; Загружаем данные
	mov es, ax              ;
                            ;
	xor ch, ch              ; Обнуляем ch
	mov cl, ds:[80h]		; Смещеие для дальнейшей работы с командой строкой
	mov bl, cl
	mov cmd_size, cl 		; В cmd_size загружаем длину командной строки
	mov si, 81h             ;
	lea di, cmd_text        ; Загружаем в di смещение текста переданного через командную строку
	rep movsb               ; Записать в ячейку адресом ES:DI байт из ячейки DS:SI
                            ;
	mov ds, ax              ; Загружаем в ds данные  
	mov cmd_size, bl
                            ;
	println startText       ; Вывод строки о начале работы программы
                            ;
	call parseCMD           ; Вызов процедуры парсинга командной строки
	cmp ax, 0               ;
	jne endMain				; Если ax != 0, т.е. при выполении процедуры произошла ошибка - переходим к конце программы, т.е. прыгаем в endMain
                            ;
	call openFiles          ; Вызываем процедуру, которая открывает оба файла для чтения/записи
	cmp ax, 0               ;
	jne endMain				;
    
    scanf enteredString
    xor ax,ax
    mov al, [enteredString+1]
    mov enteredStringSize, ax
    
    cmp enteredStringSize, 0
    je endMain
    println startProcessing                        ;
	call checkStr       
                            
endMain:                    ;
	println endText         ; Выводим сообщение о завершении работы программы
                            ;
	mov ah, 4Ch             ; Загружаем в ah код команды завершения работы
	int 21h                 ; Вызов прерывания DOS для ее исполнения  
	         
parseCMD proc
    xor ax, ax
    xor cx, cx
    
    cmp cmd_size, 0
    je notFound
    
    mov cl, cmd_size
    
    lea di, cmd_text
    mov al, cmd_size
    add di, ax
    dec di
    
findPoint: 
    mov al, '.'
    mov bl, [di]
    cmp al, bl
    je pointFound
    dec di
    loop findPoint
    
notFound:
    println badCMDArgsMessage
    mov ax, 1
    ret
    
pointFound:
    mov al, cmd_size
    sub ax, cx
    cmp ax, 3
     
    jne notFound
    
    
    xor ax, ax
    lea di, cmd_text
    lea si, extension
    add di, cx
    
    mov cx, 3
    
    repe cmpsb
    jne notFound
    
    strcpy sourcePath, cmd_text, cmd_size
    mov ax, 0
    ret         
endp

openFiles PROC                  ;
	push bx                     ;
	push dx                     ;           
	push si                                     
                                 ;
	mov ah, 3Dh			        ; Функция 3Dh - открыть существующий файл
	mov al, 02h			        ; Режим открытия файла - чтение
	lea dx, path          ; Загружаем в dx название исходного файла 
	int 21h                     ;
                                ;
	jb badOpenSource	        ; Если файл не открылся, то прыгаем в badOpenSource
                                ;
	mov sourceID, ax	        ; Загружаем в sourceId значение из ax, полученное при открытии файла
     
    mov ah, 3Ch
    xor cx, cx
    lea dx, destinationPath
    int 21h 
    
    jb badOpenSource
    
    mov ah, 3Dh
    mov al, 02h
    lea dx, destinationPath
    int 21h
    
    jb badOpenSource
    
    mov destinationID, ax
                                ;
	mov ax, 0			        ; Загружаем в ax 0, т.е. ошибок во время выполнения процедуры не произшло    
	jmp endOpenProc		        ; Прыгаем в endOpenProc и корректно выходим из процедуры
                                ;
badOpenSource:                  ;
	println badSourceText       ; Выводим соответсвующее сообщение
	
	cmp ax, 02h                 ; Сравниваем ax с 03h
	jne errorFound              ; Если ax != 02h file error, прыгаем в errorFound
                                ;
	println fileNotFoundText    ; Выводим сообщение о том, что файл не найден  
                                ;
	jmp errorFound              ; Прыгаем в errorFound
                               
errorFound:                     ;
	mov ax, 1
	                   
endOpenProc:
    pop si                      ;
	pop dx                      ;                                   
	pop bx                      ;
	ret                         ;
ENDP

checkStr proc
    
for1:
    mov tempDX, 0
    mov flagTemp, 0
    
    mov bx, sourceID
    call setPointer
        
    lea si, enteredString
    add si, 2
    
for2:    
    call readSymbolFromFile
    
    incrementTempPos 1
    
    cmp ax, 0
    je endFileGG
    cmp [buf], 0
    je endFileGG
    
    cmp [buf], returnSymbol
    je  endString
    cmp [buf], newLineSymbol
    je  endString
    cmp [buf], endl
    je  endString
          
    xor ax, ax
    xor bx, bx
          
    mov al, buf
    mov bl, [si]
     
    cmp al, bl
    je doSomething
    
    jmp for2
    
endString:
    call incrementStartPos  
    jmp for1
    
    
doSomething:        
    inc si
    
    xor bx, bx      
    mov bl, [si]
    
    cmp bl, newLineSymbol
    je stringUdov
    cmp bl, returnSymbol
    je stringUdov
    cmp bl, endl
    je stringUdov
    
    mov tempDX, 0
    mov flagTemp, 0
    
    mov bx, sourceID 
    call setPointer
    
    jmp for2
    
stringUdov:
    call writeStr   
    jmp for1
    
endFileGG:
    
    ret
endp
;&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
writeStr proc
    mov bx, sourceID 
    call setPointer
    
    mov bx, destinationID
     
    mov tempDX, 1
    mov flagTemp, 0
    
while1:
    call readSymbolFromFile
    call incrementStartPos
    
    cmp ax, 0
    je endAll
    
    cmp [buf], returnSymbol
    je  endWrite
    cmp [buf], endl
    je  endAll
    
    mov ah, 40h
    mov cx, 1
    lea dx, buf
    int 21h
    
    jmp while1
    
endWrite: 
    mov ah, 40h
    mov cx, 1
    lea dx, buf
    int 21h
    
endAll:
        
    ret
endp    
;**********************************************************************************************************************    
readSymbolFromFile proc
    push bx
    push dx
    
    mov ah, 3Fh                     ; Загружаем в ah код 3Fh - код ф-ции чтения из файла
	mov bx, sourceID                ; В bx загружаем ID файла, из которого собираемся считывать
	mov cx, 1                       ; В cx загружаем максимальный размер слова, т.е. считываем максимальное кол-во символов (maxWordSize символов)
	lea dx, buf                     ; В dx загружаем смещения буффера, в который будет считывать данные из файла
	int 21h                         ; Вызываем прерывание для выполнения ф-ции
	
	jnb successfullyRead            ; Если ошибок во время счтения не произошло - прыгаем в goodRead
	
	println errorReadSourceText     ; Иначе выводим сообщение об ошибке чтения из файла
	mov ax, 0                       ;
	    
successfullyRead:

	pop dx                          ;
	pop bx
	                                
	ret    	   
endp

end main                                                                                                               