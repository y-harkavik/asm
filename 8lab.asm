.model tiny
.code
.386
org 80h
cmd_size                                db  ?
org 82h
cmd_text                                db  ?
org 100h

start:
    jmp main

old_handler dd 0

fseekBack MACRO numOfSymbols
    push ax                  
	push cx                     
	push dx
	push bx

    
    mov bx, sourceID
	
	mov ah, 42h                               ; Записываем в AH код 42h - ф-ция DOS уставноки указателя файла
	mov al, 1                                 ; 1 - перемещение указателя от текущей позиции
	mov cx, -1                                ; Заносим в CX -1, для движения в обратную сторону т.к. смотрится пара CX:DX !!!
	mov dx, numOfSymbols                      ; Заносим в DX, кол-во символов на которое перемещаемся  
	int 21h                                   ; Вызываем прерывания DOS для исполнения команды   
 
    pop bx                            
	pop dx                      
	pop cx                      
	pop ax
ENDM                   

fseekStart MACRO setPos
    push ax                  
	push cx                     
	push dx
	push bx

    
    mov bx, sourceID
	
	mov ah, 42h                               ; Записываем в AH код 42h - ф-ция DOS уставноки указателя файла
	mov al, 0                                 ; 0 - перемещение указателя от начала файла
	mov cx, 0                                 ; Обнуляем CX 
	mov dx, setPos	                          ; Заносим в DX, кол-во символов на которое перемещаемся
	int 21h                                   ; Вызываем прерывания DOS для исполнения команды   
 
    pop bx                            
	pop dx                      
	pop cx                      
	pop ax               
ENDM

fseekCurrent MACRO settingPos
    push ax                  
	push cx                     
	push dx
	push bx

    
    mov bx, sourceID
	
	mov ah, 42h                               ; Записываем в AH код 42h - ф-ция DOS уставноки указателя файла
	mov al, 1                                 ; 1 - перемещение указателя от текущей позиции
	mov cx, 0                                 ; Обнуляем CX 
	mov dx, settingPos	                      ; Заносим в DX, кол-во символов на которое перемещаемся 
	int 21h                                   ; Вызываем прерывания DOS для исполнения команды   
 
    pop bx                            
	pop dx                      
	pop cx                      
	pop ax               
ENDM

checkNextSymbolOnCRET MACRO
    mov bl, buf                               ; Запоминаем 80-ый символ
    
    call readSymbolFromFile                   ; Считываем 81-ый символ
    cmp [buf], returnSymbol                   ; Если CRET => строка закончилась 
    jne endCheckCRET                          ; Если не CRET => следующий 81-ый символ это еще строка, но т.к. она не влазит в консоль надо перейти на новую строку в видеобуфере
    
    mov es:[di], bl                           ; Записываем символ в видеобуфер
    inc numOfPrintedSymbols                   
    add di, 2                                 ; Переходим на ячейку след. символа (в данном случае новая строка в консоли)

    jmp endOfString                           ; Прыгаем в endOfString
    
endCheckCRET:
    fseekBack -2                              ; Смещаемся на -2, т.е. на 80-ый символ, т.к. в endOfString мы сместимся на 81-ый 
    mov es:[di], bl                           ; Записываем символ в видеобуфер
    inc numOfPrintedSymbols
    add di, 2                                 ; Переходим на ячейку след. символа (в данном случае новая строка в консоли)
    
    jmp endOfString                           ; Прыгаем в endOfString
    
ENDM

strcpy MACRO destination, source, count       ;Макрос, предназначенный для копирования из source в destination заданное количество символов
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

println MACRO info      
	push ax                
	push dx                
                        
	mov ah, 09h                          ; Команда вывода 
	mov dx, offset info                  ; Загрузка в dx смещения выводимого сообщения
	int 21h                              ; Вызов прервывания для выполнения вывода

	pop dx                 
	pop ax                 
ENDM  

new_handler proc far
    
    pushf                                ; Сохраняем регистры флагов
    call cs:old_handler                  ; Вызываем старый обработчик
        
    pusha                                ; Сохраняем регистры    
    push ds                              
    push es
    push cs
    pop ds

    cmp openFileFlag, 0                  ; Проверяем, открывали ли мы файл
    jne checkTypedButton                 ; Если да, то прыгаем в checkTypedButton, иначе открываем файл и устанавливаем соотвутствующий флаг 
    mov openFileFlag, 1                  ; Устанавливаем флаг открытия файла
    call openFile                        ; Открываем файл
    
checkTypedButton:        
    xor ah, ah                           
    int 16h                              ; Считываем буфер клавиатуры
    
    cmp ah, 49h                          ; Проверяем нажатую клавишу, 49h - скан-код PageUP
    jne notPageUP                        ; Если не была нажата PageUp, то прыгаем в notPageUP 
    mov endFileFlag, 0                   ; Устанавливаем флаг конца файла в 0
    fseekStart 0                         ; Переходим в начало файла
    call printFilePage                   ; Выводим страницу документа
    jmp notNeedKey                       ; После вывода страницы прыгаем в notNeedKey
    
notPageUP:    
   cmp ah, 51h                           ; Проверяем, не была ли нажата клавиша PageDown - скан-код 51h
   jne notNeedKey                        ; Если нет, завершаем процедуру обработчика
   cmp endFileFlag, 0                    ; Проверяем, не был ли достигнут конец файла
   jne notNeedKey                        ; Если достигнут конец, то прыгаем в notNeedKey
   call printFilePage                    ; Выводим следующую страницу
    
notNeedKey:                              ; Восстанавливаем значения регистров
    pop es
    pop ds
    popa    
    iret
    
new_handler endp

main:
    call parseCMD                        ; Парсим параметры командной строки
    cmp ax, 0
	jne endMain
	
	call openFile                        ; Вызываем процедуру, которая открывает файл, переданный через командную строку	
	cmp ax, 0               
	jne endMain
	
	jmp install_handler                  ; Устанавливаем обработчик
	
endMain:                    
	                            
	mov ah, 4Ch                          ; Загружаем в AH код команды завершения работы
	int 21h  
    ret

openFile PROC               
	push bx                     
	push dx                                
	push si                                     
                                 
	mov ah, 3Dh			                 ; Функция 3Dh - открыть существующий файл
	mov al, 02h			                 ; Режим открытия файла - чтение
	lea dx, sourcePath                   ; Загружаем в dx название исходного файла 
	int 21h                     
                         
	jb badOpenSource	                 ; Если файл не открылся, то прыгаем в badOpenSource
              
	mov sourceID, ax	                 ; Загружаем в sourceId значение из ax, полученное при открытии файла
                                
	mov ax, 0			                 ; Загружаем в AX 0, т.е. ошибок во время выполнения процедуры не произшло    
	jmp endOpenProc		                 ; Прыгаем в endOpenProc и корректно выходим из процедуры
                                
badOpenSource:                  
	println badSourceText                ; Выводим соответсвующее сообщение
	
	cmp ax, 02h                          ; Сравниваем AX с 02h
	jne errorFound                       ; Если AX != 02h file error, прыгаем в errorFound
                                
	println fileNotFoundText             ; Выводим сообщение о том, что файл не найден  
                                
	jmp errorFound                       ; Прыгаем в errorFound
                               
errorFound:                     
	mov ax, 1
	                   
endOpenProc:
    pop si               
	pop dx                                                     
	pop bx                  
	ret                     
ENDP

parseCMD proc
    xor ax, ax
    xor cx, cx
    
    dec cmd_size

    cmp cmd_size, 0                      ; Если параметр не был передан, то переходим в notFound 
    je notFound
    
    mov cl, cmd_size
    
    xor ah, ah
    lea di, cmd_text
    mov al, cmd_size
    add di, ax
    dec di
    
findPoint:                               ; Ищем точку начиная с конца файла
    mov al, '.'
    mov bl, [di]
    cmp al, bl
    je pointFound
    dec di
    loop findPoint
    
notFound:                                ; Если точка не найдена выводим badCMDArgsMessage и завершаем программу
    println badCMDArgsMessage    
    mov ah, 0
    int 16h

    mov ax, 1
    ret
    
pointFound:                              ; Количество символов должно быть равно 3, т.к. "txt", если отлично от этого => файл не подходит        
    mov al, cmd_size
    sub ax, cx
    cmp ax, 3                            ; Если после точки 3 символа => продолжаем проверку
    jne notFound
    
    xor ax, ax
    mov di, offset cmd_text
    mov si, offset extension             
    ;add si, 2                           ; В эмуляторе почему-то перед строкой два элемента NULL и при lea она указывает на первый NULL
    add di, cx
    
    mov cx, 3
    
    repe cmpsb                           ; Сравниваем со строкой Extension расширение файла, если всё совпало - копируем адрес файла в sourcePath 
    jne notFound
    
    strcpy sourcePath, cmd_text, cmd_size
    
    mov ax, 0
    ret         
endp

printFilePage proc
    mov ax, 3                            ; Настраиваем консоль 
    int 10h

    mov ax, 1003h
    mov bx, 0
    int 10h
    
    call clearWindow                     ; Очищаем консоль
    
    mov tempSentences, 0                 ; Обнуляем tempSentences 
    
    push es                              ; Сохраняем значение ES
    mov ax, 0b800h                       ; Устанавливаем ES на начало видеобуфера 
    mov es, ax
    
    xor di, di
	cld
	
nextSentence:
	xor ax, ax
	mov numOfPrintedSymbols, 0           ; Обнуляем numOfReadSymbolsOfSentence и numOfPrintedSymbols
    mov numOfReadSymbolsOfSentence, 0     

getAndCheckSymbol:    
    call readSymbolFromFile              ; Считываем символ с файла

    inc numOfReadSymbolsOfSentence 
    
    
    cmp ax, 0                            ; Если ничего не считали => конец файла
    je endOfFile
    cmp [buf], 0                         ; Если считали NULL => конец файла
    je endOfFile
    
    
    cmp [buf], returnSymbol              ; Проверяем не конец строки: CRET
    je  endOfString                      ; Если конец прыгаем в endOfString
    cmp numOfReadSymbolsOfSentence, 80   ; Проверяем, не считали ли мы 80-ый символ строки 
    jne printSymbol                      ; Если не 80-ый => всё хорошо и прыгаем в printSymbol
    
    checkNextSymbolOnCRET                ; Проверяем 81-ый символ, т.к. это может быть CRET 
    
printSymbol:    
    mov al, buf                          ; Заносим символ в AL
    xor ah, ah
    
    mov es:[di], al                      ; Записываем символ в видеобуфер
    add di, 2                            ; Пернходим на ячейку следующего символа
    inc numOfPrintedSymbols              
    jmp getAndCheckSymbol                ; Переходим к следующему символу
    
endOfString:
    inc tempSentences                    ; Увеличиваем кол-во напечатанных строк
 
    fseekCurrent 1                       ; Перескакиваем символ перехода на новую строку
    
    cmp tempSentences, dosHeigth         ; Если заполнили консоль по высоте, то прыгаем в endPage
    je endPage  
    
    mov ax, dosWidth                     ; Заносим ширину консоли в AX
    sub al, numOfPrintedSymbols          ; Вычитаем из AX количество напечатанных символов 
    cmp ax, 0                            ; Сравниваем с 0. Если равно 0 => заполнили всю строку консоли (80 символов)                                          
    je nextSentence                      ; Переходим на следующее предложение, если заполнили всю строку консоли,
                                         ; иначе - надо переместится на следующую строку в консоли
    mul two                              ; Умножаем на два т.к. необходимо перемещаться на 2 байта
    add di, ax                           ; Переходим на следующую строку в видеобуфере
        
    jmp nextSentence                     ; Переходим на следующее предложение    

endPage:     
    pop es    
    ret 
    
endOfFile:
	mov endFileFlag, 1                   ; Устанавливаем флаг конца файла
    pop es                               
    ret   
endp

readSymbolFromFile proc
    push bx
    push dx
    
    mov ah, 3Fh                          ; Загружаем в ah код 3Fh - код ф-ции чтения из файла
	mov bx, sourceID                     ; В bx загружаем ID файла, из которого собираемся считывать
	mov cx, 1                            ; В cx загружаем количество считываемых символов
	lea dx, buf                          ; В dx загружаем смещения буффера, в который будет считывать данные из файла
	int 21h                              ; Вызываем прерывание для выполнения ф-ции
	
	jnb successfullyRead                 ; Если ошибок во время чтения не произошло - прыгаем в successfullyRead
	
	println errorReadSourceText          ; Иначе выводим сообщение об ошибке чтения из файла                       
	    
successfullyRead:                              
	pop dx                               
	pop bx
	                                
	ret    	   
endp                                     

clearWindow proc
    push ax                              ; Сохраняем значения регистров
    push es
    push di
    
    cld                                  ; Настраиваем консоль
    mov ax, 3h
    int 10h
    
    xor di, di
    mov ax, 0b800h
    mov es, ax                           ; Указываем на видеобуфер
    
    mov cx, numOfDosWindowSymbols        ; numOfDosWindowSymbols = 2000 - кол-во символов, которое возможно вывести на консоль 
     
fillSymbol:
    mov byte ptr es:[di], ' '            ; Заполянем консоль пробелами и устанавливаем атрибуты
    inc di
    mov byte ptr es:[di], textColor
    inc di
    loop fillSymbol 
                                         ; Возвращаем сохранённые значения в регистры
    pop di
    pop es
    pop ax
    ret
endp
;============================================================DATA==================================================================    
numOfReadSymbolsOfSentence              dw 0
tempSentences                           db 0
numOfPrintedSymbols                     db 0

dosWidth                                equ 80
dosHeigth                               equ 25
numOfDosWindowSymbols                   equ 2000

textColor                               equ 01110000b   ; black(0000) on white backround(0111)

two                                     db 2

maxCMDSize                              equ 127
sourcePath                              db  129 dup (0) 

extension             db "txt"       

buf                   db  0                      
sourceID              dw  0                                             
                            
newLineSymbol         equ 0Ah
returnSymbol          equ 0Dh                           
                     
badCMDArgsMessage     db  "Bad command-line arguments.",                                      0Dh,0Ah,'$'
badSourceText         db  "Open error",                                                       0Dh,0Ah,'$'    
fileNotFoundText      db  "File not found",                                                   0Dh,0Ah,'$'         
errorReadSourceText   db  "Error reading from source file",                                   0Dh,0Ah,'$'

pageUpFlag            db 0
endFileFlag           db 0
openFileFlag          db 0
;==================================================================================================================================
install_handler:
    
    cli
    mov ah, 35h                       ; Функция получения адреса обработчика прерывания
	mov al, 09h                       ; прерывание, обработчик которого необходимо получить (09 - прерывание от клавиатуры)
	int 21h
	
	                                 ; Сохраняем старый обработчик
	mov word ptr old_handler, bx     ; смещение
	mov word ptr old_handler + 2, es ; сегмент
	
	push ds
	pop es
	
	mov ah, 25h                       ; Функция замены обработчика прерывания
	mov al, 09h                       ; Прерывание, обработчк которого будет заменен
	mov dx, offset new_handler        ; Загружаем в dx смещение нового обработчика прерывания, который будет установлен на место старого обработчика 
	int 21h
    sti
    
    mov ah, 31h                       ; Делаем программу резидентной
    mov al, 0
    mov dx, (install_handler - start + 100h) / 16 + 1
    int 21h
    
    ret
end start