.model small
.stack 100h
.data

KUpSpeed    equ 48h	         ; Up key
KDownSpeed  equ 50h	         ; Down key
KMoveUp     equ 11h	         ; W key
KMoveDown   equ 1Fh	         ; S key
KMoveLeft   equ 1Eh	         ; A key
KMoveRight  equ 20h	         ; D key
KExit       equ 01h          ; ESC key
                             
xSize       equ 80           ; Ширина консоли
ySize       equ 25           ; Высота консоли
xField      equ 50           ; Ширина поля
yField      equ 21           ; Высота поля
videoBufferCellSize equ 2    ; Размер одной "клетки" консоли
scoreSize equ 4              ; Длина блока счета
                             
videoStart   dw 0B800h       ; Смещение видеобуффера
dataStart    dw 0000h        
timeStart    dw 0040h        
timePosition dw 006Ch        
                             
space equ 0020h              ; Пустой блок с черным фоном  
spaceBlue equ 3020h	         ; Пустой блок с синим фоном
snakeBodySymbol    equ 0A01h ; Символ тела змейки
appleSymbol        equ 0B15h ; Символ яблока
VWallSymbol        equ 30BAh ; Символ вертикальной стены
HWallSymbol        equ 30CDh ; Символ горизонтальной стены  
BWallSymbol        equ 4023h ; Символ препятствия, от яблока
 
LeftTopWallSpecialSymbol equ 30C9h ; Верхний левый угол 
LeftBottomWallSpecialSymbol equ 30C8h ; Нижний левый угол
RightTopWallSpecialSymbol equ 30BBh ; Верхний правый угол 
RightBottomWallSpecialSymbol equ 30BCh ; Нижний правый угол 

fieldSpacingBad equ spaceBlue, VWallSymbol, xField dup(space)
fieldSpacing equ fieldSpacingBad, VWallSymbol

screen	dw xSize dup(spaceBlue)   
        dw spaceBlue, LeftTopWallSpecialSymbol, xField dup(HWallSymbol), RightTopWallSpecialSymbol, 27 dup (spaceBlue)
        dw fieldSpacing, spaceBlue, 3053h, 3063h, 306Fh, 3072h, 3065h, 303Ah, spaceBlue
score	dw scoreSize dup(3030h), xSize - xField - scoreSize - 11 dup(spaceBlue)
        dw fieldSpacing, spaceBlue, 3053h, 3070h, 2 dup(3065h), 3064h, 303Ah, spaceBlue
speed	dw 3031h, 18 dup(spaceBlue) ;3031h - адрес, где будет отображаться скорость
		dw fieldSpacing, xSize - xField - 3 dup(spaceBlue) 
		dw fieldSpacing, spaceBlue, 3043h, 306Fh, 306Eh, 3074h, 3072h, 306Fh, 306Ch, 3073h, 303Ah, 17 dup(spaceBlue)
		dw fieldSpacing, spaceBlue, 3057h, spaceBlue, 30C4h, spaceBlue, 3055h, 3070h, 3018h, 19 dup(spaceBlue)
		dw fieldSpacing, spaceBlue, 3053h, spaceBlue, 30C4h, spaceBlue, 3044h, 306Fh, 3077h, 306Eh, 3019h, 17 dup(spaceBlue)
		dw fieldSpacing, spaceBlue, 3041h, spaceBlue, 30C4h, spaceBlue, 304Ch, 3065h, 3066h, 3074h, 301Bh, 17 dup(spaceBlue)
		dw fieldSpacing, spaceBlue, 3044h, spaceBlue, 30C4h, spaceBlue, 3052h, 3069h, 3067h, 3068h, 3074h, 301Ah, 16 dup(spaceBlue)
		dw fieldSpacing, spaceBlue, 3045h, 3073h, 3063h, spaceBlue, 30C4h, spaceBlue, 3045h, 3078h, 3069h, 3074h, 3021h, xSize - xField - 15 dup(spaceBlue)
		dw fieldSpacing, spaceBlue, 3018h, spaceBlue, 30C4h, spaceBlue, 3053h, 3070h, 3065h, 3065h, 3064h, spaceBlue, 3075h, 3070h, spaceBlue, 13 dup(spaceBlue)
		dw fieldSpacing, spaceBlue, 3019h, spaceBlue, 30C4h, spaceBlue, 3053h, 3070h, 3065h, 3065h, 3064h, spaceBlue, 3064h, 306Fh, 3077h, 306Eh, 12 dup(spaceBlue) 
		dw fieldSpacing, xSize - xField - 3 dup(spaceBlue)
		dw fieldSpacing, xSize - xField - 3 dup(spaceBlue)
		dw fieldSpacing, xSize - xField - 3 dup(spaceBlue)
		dw fieldSpacing, xSize - xField - 3 dup(spaceBlue)
		dw fieldSpacing, xSize - xField - 3 dup(spaceBlue)
		dw fieldSpacing, xSize - xField - 3 dup(spaceBlue)
		dw fieldSpacing, xSize - xField - 3 dup(spaceBlue)   
		dw fieldSpacing, xSize - xField - 3 dup(spaceBlue)
		dw fieldSpacing, xSize - xField - 3 dup(spaceBlue)
		dw fieldSpacing, xSize - xField - 3 dup(spaceBlue)
		dw spaceBlue, LeftBottomWallSpecialSymbol, xField dup(HWallSymbol), RightBottomWallSpecialSymbol, 27 dup(spaceBlue)
        dw xSize dup(spaceBlue) 
		
;===============================================END SCREEN===================================================================
                         
widthOfEndScreen   equ 20     ; 
allWidth        equ 80     ; 
black           equ 0020h  ;
white           equ 4020h  ; 
black           equ 0020h  ;

blackVWallSymbol     equ 00FBAh
blackHWallSymbol     equ 00FCDh

theEnd      dw LeftTopWallSpecialSymbol, widthOfEndScreen-2 dup(HWallSymbol), RightTopWallSpecialSymbol 
			dw VWallSymbol, 18 dup(black), VWallSymbol
			dw VWallSymbol, 5 dup(black) ,0F47h,0F61h,0F6Dh,0F65h,space, 0F6Fh,0F76h,0F65h,0F72h, 4 dup(black), VWallSymbol
			dw VWallSymbol, 18 dup(black), VWallSymbol
			dw LeftBottomWallSpecialSymbol, widthOfEndScreen-2 dup(HWallSymbol), RightBottomWallSpecialSymbol
			
snakeMaxSize equ 30
snakeSize db 3
PointSize equ 2

snakeBody dw 1D0Dh, 1C0Dh, 1B0Dh, snakeMaxSize-2 dup(0000h)   
             ;1D - столбец 0D - строка                                               
brickWallSize equ 5                                                           

brickWall1 dw 0202h,  0201h, 0200h,  01FFh, 01FEh  ; справа вертикальная
brickWall2 dw 0202h,  0102h, 0002h, 0FF02h, 0FE02h  ; внизу горизонтальная        
brickWall3 dw 01FEh,  00FEh, 0FFFEh, 0FEFEh, 0FDFEh  ; вверху горизонтальная
brickWall4 dw 0FE02h,  0FE01h, 0FE00h, 0FDFFh, 0FDFEh ; слева вертикальная                                                                                 
            
brickWallTemplate dw brickWallSize dup(0)

brickWallTrue dw brickWallSize dup(0)

stopVal     equ 00h
forwardVal  equ 01h
backwardVal equ -1

Bmoveright db 01h         ; если 1 - двигаемся вправо, -1 - двигаемся влево, 0 - ни туда ни сюда
Bmovedown db 00h          ; eсли 1 - двигаемся вправо, -1 - двигаемся влево, 0 - ни туда ни сюда

minWaitTime equ 1
maxWaitTime equ 9
waitTime    dw maxWaitTime
deltaTime   equ 1

.code
;=============================================CODE==============================================================    
clearScreen MACRO          ;
	push ax                ; Сохраняем значение ax
	mov ax, 0003h          ; 00 - установить видеорежим, очистить экран. 03h - режим 80x25
	int 10h                ; Вызов прерывания для исполнения команды
	pop ax                 ; Восстанавливаем значение регистра ax
ENDM                       ;
;end macro help

main:
	mov ax, @data	        ;
	mov ds, ax              ;
	mov dataStart, ax       ; Загружаем начальные данные
	mov ax, videoStart      ; Загружаем в ax код начала вывода в видеобуффер
	mov es, ax              ; Загружаем ax в es
	xor ax, ax              ; Обнуляем ax
                            ;
	clearScreen             ; Очищаем консоль  
	call HideCursor
                            ;
	call initAllScreen      ; Инициализируем экран
                            ;
	call mainGame           ; Переходим в основной цикл игры
                            ;
to_close:                   ;
	call printEndScreen     ;
	mov ah,7h               ; 7h - консольный ввод без эха (ожидаем нажатия клавиши для выхода из приложения)
    int 21h                 
    
esc_exit:    
    
	clearScreen             ;
                            ;
	mov ah, 4ch             ; Выход
	int 21h                 ;

GetTimerValue MACRO         
	push ax                 ; Сохраняем значения регистра ax
                            ;
	mov ax, 00h             ; Получаем значение времени
	int 1Ah                 ;
                            ;
	pop ax                  ; Восстанавливаем значение регистра ax
ENDM                        
                              
                            
printEndScreen PROC                      
	push es                           ;
	push 0B800h                       ;
                                     
	pop es                            ; ES=0B800h
                                      ;
	mov di, 20*80 + 50    
	mov si, offset theEnd             ;
	mov cx, 5                         ;
	cld                               ; 
loopPrintEndScreen:                   ;
                                      ;
	push cx                           ; 
                                      ;
	mov cx, widthOfEndScreen          ; 
	rep movsw                         ; 
                                      ;
	add di, 2*(allWidth - widthOfEndScreen);
                                      ;
	pop cx                            ; 
	loop loopPrintEndScreen           ;
    std                               ;
	pop es                            ;
	ret                               ;         	
ENDP      
  
;========================================HIDE CURSOR=============================================
HideCursor proc      
    push ax
    push bx
    push cx
        mov ah,3
        mov bh,0
        int 10h
        mov ch,20h
        mov ah,1
        int 10h  
        pop cx
        pop bx
        pop ax
        ret
endp   

drawBrickWall PROC 
 push cx
 push bx
 mov cx, brickWallSize
             
 mov si, offset brickWallTrue            
 loopBrickWall:              
	mov bx, [si]            ; Загружаем в si очередной символ 
	add si, PointSize        	
	                       
	call CalcOffsetByPoint  ; Получаем смещение выводимого символа в видеобуффере
                            ;
	mov di, bx              ; загружаем в di позицию
                            ;
	mov ax, BWallSymbol     ; Загружаем в ax выводимый символ
	stosw                   ; Выводим
	loop loopBrickWall    
 pop bx	
 pop cx
 ret
ENDP  

destroyWall PROC
    push cx
    mov cx, brickWallSize
             
    mov si, offset brickWallTrue            
loopDestroyWall:           
	mov bx, [si]            ; Загружаем в si очередной символ
	add si, PointSize        	
	call CalcOffsetByPoint  ; Получаем смещение выводимого символа в видеобуффере                            ;
	mov di, bx              ; загружаем в di позицию                            
	mov ax, space           ; Загружаем в ax пробел + чёрный фон
	stosw                   ; Записываем
	loop loopDestroyWall    	
    pop cx
    ret   
ENDP    
                            
initAllScreen PROC          
	mov si, offset screen   ; В si загружаем смещение на первый символ массива, окна, которое мы прописали
	xor di, di             
	mov cx, xSize*ySize     ; Загружаем в cx кол-во символов в консоли, т.е. 80x25                                    
	rep movsw               ; Переписываем последовательно все cx символов из ds:si в консоль es:di 
                            
	xor ch, ch              ; Обнуляем ch
	mov cl, snakeSize       ; Загружаем в cl размер змейки
	mov si, offset snakeBody; В si загружаем смещения начала тела змейки
                            ;
loopInitSnake:              ; Цикл, в котором мы выводим тело змейки
	mov bx, [si]            ; Загружаем в si очередной символ тела змейки
	add si, PointSize       ; Добавляем к si PointSize, т.е. 2, т.к. каждая точка занимает 2 байта (цвет + символ)
	
	call CalcOffsetByPoint  ; Получаем смещение выводимого символа в видеобуффере
                            ;
	mov di, bx              ; загружаем в di позицию
                            ;
	mov ax, snakeBodySymbol ; Загружаем в ax выводимый символ
	stosw                   ; Выводим Store AX at address DI

	loop loopInitSnake      
                            
	call GenerateRandomApple; Генерируем яблоко в случайных координатах  
                            
	ret                     
ENDP                        
                            
CalcOffsetByPoint PROC      ;(номер_строки * 80 + номер_столбца * 25) * 2
                            ;input: Координаты (номер_строки,номер_столбца) в bx
                            ;output: Смещение в bx    
	push ax                 
	push dx                 
	                        
	xor ah, ah             
	mov al, bl              ; Загружаем в al bl - номер строки, на которой находимся
	mov dl, xSize           ; В dl загружаем xSize - размер строки
	mul dl                  ; Умножаем al на dl
	mov dl, bh              ; Загружаем в dl bh - номер столбца
	xor dh, dh              ; Обнуляем dh
	add ax, dx              ; Добавляем к ax dx - получаем позицию в видеобуфере
	mov dx, videoBufferCellSize	; Загружаем в dx 2, т.к. символ и цвет
	mul dx                  ; Умножаем на 2
	mov bx, ax              ; Загружаем ax в bx
                            
	pop dx                  
	pop ax                  
	ret                     
ENDP                        

;Сдвигаем тело змейки в массиве
;Удаляем старый последний элемент
;Закрашиваем последний элемент
MoveSnake PROC              
	push ax                 ; Сохраняем значения регистров
	push bx                 
	push cx                 
	push si                 
	push di                 
	push es                 
    
    xor ax, ax                     
	mov al, snakeSize       ; В al загружаем длину змейки
	mov cx, ax              ; Запоминаем размер в cx
	mov bx, PointSize       ; Загружаем в bx размер точки в видеобуфере
	mul bx			        ; Теперь в ax реальная позиция в памяти относительно начала массива
	mov di, offset snakeBody; Загружаем в di смещение головы змейки, становимся на первый элемент
	add di, ax 		        ; di - адрес следующего после последнего элемента массива (с 0 нумерация)
	mov si, di              ; Загружаем di в si
	sub si, PointSize 	    ; Т.к. стоим сразу после последнего эл-та, надо -2, чтобы стать на последний
                            
	push di                 ; Сохраняем значение di
	                        ; Удаляем конец змейки с экрана
	mov es, videoStart      ; Загружаем в es смещение видеобуффера
	mov bx, ds:[si]         ; Загружаем в bx последний элемент змейки
	call CalcOffsetByPoint  ; Вычисляем ее позицию в видеобуфере
	mov di, bx			    ; Заносим смещения буфера, в которое будем очищать в di
	mov ax, space           ; Загружаем в ax пустую клетку
	stosw                   ; Пересылаем содерджимое ax в es:di
                            
	pop di                  ; Восстанавливаем di
                            
	mov es, dataStart	    ; Для работы с данными (до этого es указывал на видеобуффер)
	std				        ; Идем от конца к началу
	rep movsw               ; Переписываем символы из ds:si в es:di (si - предпоследний элемент змейки, di - последний элемент)
	                        ; Сдвигаем массив змейки вправо на 1 шаг, первый элемент остаётся под вопросом
                            
	mov bx, snakeBody 	    ; Загружаем в bx старую позицию головы змейки
                            
	add bh, Bmoveright      ; Обновляем координаты головы, т.е. если вправо, +1 к столбцу будет, если влево, то -1
	add bl, Bmovedown	    ; Также и с низом
	mov snakeBody, bx	    ; Сохраняем новую позицию головы, куда хотим поставить голову
	                        ; Теперь все тело в памяти сдвинуто, как будто съели яблоко
	                                                   
	pop es                  ; Восстанавливаем значения регистров
	pop di                  
	pop si                  
	pop cx                  
	pop bx                  
	pop ax                  
	ret                     
ENDP                     

mainGame PROC
	push ax                      ; Сохраняем значения регистров 
	push bx                      
	push cx                      
	push dx                      
	push ds                      
	push es                      
                                 
checkAndMoveLoop:                           
	mov ah, 01h                  ; Проверка наличия символа в буфере, ZF = 1 - Буффер пуст   
	int 16h                   
	jnz checkEnteredSymbol       ; Если да - проверяем что за символ ввели
	jmp noSymbolInBuff           ; Иначе noSymbolInBuff
                                 
checkEnteredSymbol:             
    mov ah, 00h                  ; Чтение символа из буффера AH = scan-code   
	int 16h
	cmp ah, KExit		         ; Если была нажата кнопка выхода
	jne skipJmp                  ; Иначе skipJmp
                                 
	jmp esc_exit                 ; Заканчиваем игру, прыгая в esc_exit
                                 
skipJmp:                         
	cmp ah, KMoveLeft	         ; Если была нажата кнопка "влево"
	je setMoveLeft               
                               
	cmp ah, KMoveRight	         ; Если была нажата кнопка "вправо"
	je setMoveRight             
                             
	cmp ah, KMoveUp		         ; Если была нажата кнопка "вверх"
	je setMoveUp                 
                              
	cmp ah, KMoveDown	         ; Если была нажата кнопка "вниз"
	je setMoveDown               
                              
	cmp ah, KUpSpeed		     ; Если была нажата кнопка увеличения скорости
	je setSpeedUp                
                              
	cmp ah, KDownSpeed	         ; Если была нажата кнопка уменьшения скорости
	je setSpeedDown              
                              
	jmp noSymbolInBuff           
                              
setMoveLeft:                       
    mov al, Bmoveright           ; Проверка на попытку изменения направления на противоположное
    cmp al, forwardVal           ; Смотрим, если Bmoveright == 1, т.е. двигались вправо
    jne setMoveLeft_ok           ; Bmoveright != forwardVal
    jmp noSymbolInBuff           
                                 
    setMoveLeft_ok:              
                                 
	mov Bmoveright, backwardVal  ; Направление вправо - отрицательное
	mov Bmovedown,  stopVal      ; Направление вниз - нулевое
	jmp noSymbolInBuff           
                                 
setMoveRight:                      
    mov al, Bmoveright           ; Проверка на попытку изменения направления на противоположное
    cmp al, backwardVal          ; Смотрим, если Bmoveright == -1, т.е. двигались влево
    jne setMoveRight_ok          
    jmp noSymbolInBuff           
                                 
    setMoveRight_ok:             
                                 
	mov Bmoveright, forwardVal   ; Направление вправо - положительное
	mov Bmovedown, stopVal       ; Направление вправо - нулевое
	jmp noSymbolInBuff           
                              
setMoveUp:                     
    mov al, Bmovedown            ; Проверка на попытку изменения направления на противоположное
    cmp al, forwardVal           ; Смотрим, если Bmovedown == 1, т.е. двигались вниз
    jne setMoveUp_ok             
    jmp noSymbolInBuff           
                                 
    setMoveUp_ok:                
                                 
	mov Bmoveright, stopVal      ; Направление вправо - нулевое
	mov Bmovedown, backwardVal   ; Направление вниз - отрицательное
	jmp noSymbolInBuff           
                              
setMoveDown:                   
    mov al, Bmovedown            ; Проверка на попытку изменения направления на противоположное
    cmp al, backwardVal          ; Смотрим, если Bmovedown == +1, т.е. двигались вверх
    jne setMoveDown_ok           
    jmp noSymbolInBuff           
                                 
    setMoveDown_ok:              
                                 
	mov Bmoveright, stopVal      ; Направление вправо - нулевое
	mov Bmovedown, forwardVal    ; Направление вниз - положительное
	jmp noSymbolInBuff           
                              
setSpeedUp:                      
	mov ax, waitTime             ; Загружаем в ax значение задержки
	cmp ax, minWaitTime          ; Сравниваем его с минимальным
	je noSymbolInBuff			 ; Если равно минимальному - пропускаем, не можем меньше минимального 
	                             
	sub ax, deltaTime            ; Уменьшаем время задержки, скорость увеличивается
	mov waitTime, ax 			 ; Обновляем значение задержки
                                 
	mov es, videoStart           
	mov di, offset speed - offset screen	
	mov ax, es:[di]              ; Берём из буфера значение скорости и увеличиваем его на 1
	inc ax                       
	mov es:[di], ax              ; Записываем новое значение скорости
                                 
	jmp noSymbolInBuff           
                                 
setSpeedDown:                    ; Инверсия для увеличения скорости
	mov ax, waitTime             
	cmp ax, maxWaitTime          
	je noSymbolInBuff			 
	                        
	add ax, deltaTime            
	mov waitTime, ax 			 
                                 
	mov es, videoStart           
	mov di, offset speed - offset screen
	mov ax, es:[di]              
	dec ax                       
	mov es:[di], ax                       
                              
noSymbolInBuff:                  
	call MoveSnake               ; Передвигаем змейку на экране
                                 
	mov bx, snakeBody 		     ; В помещаем в bx голову змеи(относительные координаты)
	
checkSymbolAgain:                
	call CalcOffsetByPoint	     ; В bx теперь адрес в видеобуфере
                                 
	mov es, videoStart           ; Загружаем в es смещение видеобуффера
	mov ax, es:[bx]		         ; Загружаем в ax символ куда должна стать змейка
                                 
	cmp ax, appleSymbol          ; Если этот символ - яблоко
	je AppleIsNext               
                                 
	cmp ax, snakeBodySymbol      ; Если этот символ - тело змейки
	je SnakeIsNext               
                                 
	cmp ax, HWallSymbol          ; Если этот символ - горизонтальная стена
	je PortalUpDown              
                                  
	cmp ax, VWallSymbol          ; Если этот символ - верникальная стена
	je PortalLeftRight            
	                             
	cmp ax, BWallSymbol          ; Если этот символ - препятсвие(стена) от яблока
	je SnakeIsNext                             
                                 
	jmp GoNextIteration          
                                 
AppleIsNext:                       
    call destroyWall             ; Убираемся стену, что рисовали(пробелами)
	call incSnake                ; Увеличиваем длину змейки
	call GenerateRandomApple     ; Генерируем новое яблоко 
	call incScore                ; Увеличиваем счет
	jmp GoNextIteration          ; Переходим к следующей итерации
SnakeIsNext:                     ;
	jmp endLoop                  ; Заканчиваем игру
PortalUpDown:                    ;
	mov bx, snakeBody            ; Загружаем в bx голову змейки
	sub bl, yField               ; Отнимаем от y координаты(строки) высоту поля 
	cmp bl, 0		             ; Определяем верхняя если <0 или нижняя == 21 граница
	jg writeNewHeadPos           ; Перерисовываем голову змейки                               
	                             ; Если это была верхняя стена, т.е. от 0 отняли 21, стало -21
	add bl, yField*2             ; Корректируем координаты, -21+42=21,т.е. на нижнию границу 
                                 
writeNewHeadPos:                 
	mov snakeBody, bx	         ; Записываем новое значение головы, мы уже сместились, когда от bl отняли yField или корректировали коорд.
	jmp checkSymbolAgain	     ; Отправляем его заново на сравнение
                                 ; Проверяем что на той стороное стены
PortalLeftRight:                 
	mov bx, snakeBody            
	sub bh, xField               
	cmp bh, 0		             ; 
	jg writeNewHeadPos           ;  Аналогично обрабатываем случай с вертикальной стеной
                                 
	add bh, xField*2             
	jmp writeNewHeadPos          
                                 
GoNextIteration:                 
	mov bx, snakeBody		     ; Загружаем в bx новое начало змейки
	call CalcOffsetByPoint       ; Вычисляем ее позицию
	mov di, bx                   ; Теперь в di смещение в видеобуфере, где должна быть голова
	mov ax, snakeBodySymbol      ; Записываем в ax символ змейки 
	stosw                        ; Наконец-то записываем в видеобуфер символ головы
                                 
	call Sleep                   ; Задержка
                                 
	jmp checkAndMoveLoop         
                                 
endLoop:                         ; Восстанавливаем значения регистров
	pop es                       
	pop ds                       
	pop dx                       
	pop cx                       
	pop bx                       
	pop ax                       
	ret                          
ENDP                               
                                 
Sleep PROC                       
	push ax                      
	push bx                      ; Сохраняем регистры
	push cx                      ;
	push dx                      ;
                                 ;
	GetTimerValue                ; Получаем текущее значение времени
                                 ;
	add dx, waitTime             ; Добавляем к dx значение задержки
	mov bx, dx                   ; Загружаем его в bx
                                 ;
checkTimeLoop:                   ;
	GetTimerValue                ; Получаем текузее значение времени
	cmp dx, bx			         ; ax - current value, bx - needed value
	jl checkTimeLoop             ; Если еще рано - уходим на следующую итерацию 
                                 ;
	pop dx                       ;
	pop cx                       ;
	pop bx                       ; Восстанавливаем значения регистров
	pop ax                       ;
	ret                          ;
ENDP                             ;

GenerateRandomApple PROC  
	push ax               
	push bx               
	push cx                
	push dx               
	push es               
	                      
	mov ah, 2Ch           ; Считываем текущее время
	int 21h               ; ch - час, cl - минуты, dh - секунды, dl - сотые доли секунды
	
	mov al, dl                     
    mul dh                ; секунды * сотые доли секунды
	             
	xor dx, dx             
	             
	mov cx, 04h           ; делим на 4, т.к. 4 вида стен
	div cx                ; ах - целая часть, dx - остаток
	mov bh, dl            ; запоминаем остаток от деления
	                      ; выбираем стену для рисования
	cmp bh, 0
	jne rnd1  
	mov si, offset brickWall1                      
	jmp writeToTemplate
	
	rnd1:
	
	cmp bh, 1
	jne rnd2  
	mov si, offset brickWall2                      
	jmp writeToTemplate
	
	rnd2:
	
	cmp bh, 2
	jne rnd3  
	mov si, offset brickWall3                      
	jmp writeToTemplate
	
	rnd3:                    
	
	mov si, offset brickWall4                      
	jmp writeToTemplate  
	            
	writeToTemplate:
	mov di, offset brickWallTemplate
	mov cx, brickWallSize
	
	push ax
	movswToTemplate:	  
	    mov ax, [si]
	    mov [di],ax	  
	    add di, 2
	    add si, 2
	loop movswToTemplate                    
	pop ax
	                      
generateRandomApplePosition: ; Генерирцем позицию для яблока
	mov ah, 2Ch           ; Считываем текущее время
	int 21h               ; ch - час, cl - минуты, dh - секунды, dl - мсек
                          ;
	mov al, dl            ; Получаем случайное число
	mul dh 				  
                          
	xor dx, dx			  
	mov cx, xField        ; В cx загружаем ширину поля 50
	div cx				  ; Получаем номер строки яблока
	add dx, 2			  ; Добавляем смещение от начала оси
	mov bh, dl 		      ; Сохраняем координату x
                          
	xor dx, dx            
	mov cx, yField        
	div cx                ; Аналогично получаем y координату
	add dx, 2			  
	mov bl, dl 			  ; Теперь в bx находится координата яблока
                                         
    push bx               ; Сохраняем в стек координату яблока       
	call CalcOffsetByPoint
	mov es, videoStart
	mov ax, es:[bx]       ; В ax загружаем символ, который расположен по координатам, в которых мы хотим расположить яблоко
    pop bx                ; Возвращаем координату яблока
                          
	cmp ax, space                   ; Сравниваем их с пробелом(т.е. пустой чёрной клеткой). 
	jne generateRandomApplePosition	; Если в клетке что-то есть - генерируем новые координаты яблока   
	                                      
    mov cx, brickWallSize             
    mov si, offset brickWallTemplate            
    
    checkWallPlace:             ; делаем проверку, можем ли мы впихнуть стену в выбранную позицию
        push bx                 ; сохраняем координату яблока
	    add bx, [si]            ; добавляем к яблоку относительную координату стенки
        
        push bx                 ; сохраняем координату стену     
	    call CalcOffsetByPoint  ; Расситываем смещение
	    mov es, videoStart      ; Загружаем в es начало видеобуффера
	    mov ax, es:[bx]         ; В ax загружаем символ, который расположен по координатам, в которых мы хотим расположить яблоко
        pop bx 
        
        pop bx                  ; возвращаем координату яблока
	    
	    cmp ax, space  

	    jne generateRandomApplePosition
	              
	    add si, PointSize       ; Добавляем к si PointSize, т.е. 2, т.к. каждая точка занимает 2 байта (цвет + символ)
	loop checkWallPlace
	
    mov cx, brickWallSize            
    mov si, offset brickWallTemplate
    mov di, offset brickWallTrue
	
	push ax 
	copyTrueCoordinateOfWall:            
	    mov ax, [si]             
	    add ax, bx 
	    mov [di], ax                      
	    
	    add si, PointSize
	    add di, PointSize
	loop copyTrueCoordinateOfWall    
	pop ax
	
	call drawBrickWall                                    
	                
	push bx                      
	call CalcOffsetByPoint; Расситываем смещение
	mov es, videoStart    ; Загружаем в es начало видеобуффера
	mov ax, appleSymbol; 
	mov es:[bx], ax       ; Выводим символ яблока
    pop bx                 
                          ;
	pop es                ;
	pop dx                ;
	pop cx                ; Восстанавливаем регистры
	pop bx                ;
	pop ax                ;
	ret                   ;
ENDP                     ;

incSnake PROC             
	push ax               
	push bx               ; Сохраняем значения регистров
	push di               
	push es               
                       
	mov al, snakeSize     ; Загружаем в ax текущий размер змейки
	cmp al, snakeMaxSize  ; Сравниваем его с максимальным размером змейки
	je return             ; Если достигли максимума - выходим                          
	inc al                ; Увеличиваем длину змейки в массиве
	mov snakeSize, al     ; Обновляем размер змейки
	dec al 				  ; Уменьшаем al на 1(старый размер).
                          ; После MoveSnake, мы сдвигали массив на 1 эл. влево, но не удаляли посл. эл.!	                      
	mov bl, PointSize     ; 
	mul bl 				  ;   
                          
	mov di, offset snakeBody ; Становимся на первый элемент массива
	add di, ax 			     ; Становимся на тот самый элемент, который последний
                          
	mov es, dataStart     ; Загружаем в es данные
	mov bx, es:[di]       ; Загружаем в bx восстанавливаемый элемент
	                      ; Т.к. мы хвост удаляли в видеобуфере в методе MoveSnake, надо его вернуть
	call CalcOffsetByPoint; Получаем ее координаты
	mov es, videoStart           ; Загружаем в es смещение видеобуффера
	mov es:[bx], snakeBodySymbol ; Записываем в точку символ тела змейки
	                      
return:                   
	pop es                
	pop di                ; Восстанавливаем значения регистров
	pop bx                
	pop ax                
	ret                   
ENDP                   
                       
incScore PROC             
	push ax              
	push es               
	push si               
	push di               
	mov es, videoStart    
	mov cx, scoreSize 	  ;max pos value
	mov di, offset score + (scoreSize - 1) * videoBufferCellSize - offset screen
                          
loop_score:	              
	mov ax, es:[di]       
	cmp al, '9'			  
	jne nineNotNow       
	                      
	sub al, 9			  
	mov es:[di], ax       
                          
	sub di, videoBufferCellSize  ;return to symbol back
                          
	loop loop_score       
	jmp return_incScore   
                          
nineNotNow:               
	inc ax                
	mov es:[di], ax       
return_incScore:       
	pop di                
	pop si                
	pop es                
	pop ax                
	ret                   
ENDP                   
end main               
