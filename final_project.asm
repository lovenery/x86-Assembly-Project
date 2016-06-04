TITLE Assembly Language Final Project

INCLUDE Irvine32.inc

INITIAL PROTO

Controller PROTO

Print_Something PROTO, xy:COORD


;; data segment
.data
console_title BYTE "Demo Program",0
consoleHandle    DWORD ?

;物體資訊
xyInit COORD <42,18> ; 起始座標
xyBound COORD <80,25> ; 一個頁面最大的邊界
xyPos COORD <0,0> ; 現在的游標位置
currentDirection BYTE RIGHT ; 面向位置
UP = 1
DOWN = 2
LEFT = 3
RIGHT = 4
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; code segment
.code
main PROC

; Set the console window's title.
INVOKE SetConsoleTitle, ADDR console_title

; Get the Console standard output handle:
INVOKE GetStdHandle, STD_OUTPUT_HANDLE
mov consoleHandle,eax

;call splashScreen

; 設定起始座標
INVOKE INITIAL

; 遊戲迴圈
GameLoop:
    
    call ClrScr ; clear screen
    INVOKE Controller ; 控制物體
    INVOKE Print_Something, xyPos ; 繪製物體

    ; 物體移動的速度
    INVOKE Sleep,100
    ;mov eax,45    
    ;call delay
    ;call ReadChar

    jmp GameLoop

main ENDP


INITIAL PROC
    mov ax,xyInit.x
    mov xyPos.x,ax
    mov ax,xyInit.y
    mov xyPos.y,ax
    ret
INITIAL ENDP

; print
Print_Something PROC, Position:COORD
mov ax, Position.x
mov dl, al
mov ax, Position.y
mov dh, al
call gotoXY
mov al, 219
call writeChar
ret
Print_Something ENDP


Controller PROC
call ReadKey;ReadChar ; 讀取鍵盤的輸入

; 設定面對的方向 , 不能把自己吃掉
.IF ax == 1177h && currentDirection!=DOWN;UP=W
   ;sub xyPos.y,1
   mov currentDirection, UP
.ENDIF

.IF ax == 1F73h && currentDirection!=UP;DOWN=S
   ;add xyPos.y,1
   mov currentDirection, DOWN
.ENDIF

.IF ax == 1E61h && currentDirection!=RIGHT;LEFT=A
   ;sub xyPos.x,1
   mov currentDirection, LEFT
.ENDIF

.IF ax == 2064h && currentDirection!=LEFT;RIGHT=D
   ;add xyPos.x,1
   mov currentDirection, RIGHT
.ENDIF

.IF ax == 011Bh ;ESC
   call EndGame
.ENDIF

; 以面對的方向更新座標
.IF currentDirection == UP
   sub xyPos.y,1
   jmp exitUpdate
.ELSEIF currentDirection == DOWN
   add xyPos.y,1
   jmp exitUpdate
.ELSEIF currentDirection == LEFT
   sub xyPos.x,1
   jmp exitUpdate
.ELSEIF currentDirection == RIGHT
   add xyPos.x,1
   jmp exitUpdate
exitUpdate:
.ENDIF


; 檢查移動後,有沒有超過限制邊界
.IF xyPos.x == 0h ;x lowerbound
add xyPos.x,1
   ;jmp INITIAL ; 跳去設定初始
.ENDIF

mov ax,xyBound.x ; 註：比較不能用雙定址，故將其中一個轉成 register

.IF xyPos.x == ax ;x upperbound
sub xyPos.x,1   
;jmp INITIAL ;
.ENDIF

.IF xyPos.y == 0h ;y lowerbound
add xyPos.y,1
   ;jmp INITIAL ;
.ENDIF

mov ax,xyBound.y

.IF xyPos.y == ax ;y upperbound
   sub xyPos.y,1
   ;jmp INITIAL ;
.ENDIF

ret
Controller ENDP 


EndGame PROC
    exit
    ret
EndGame ENDP


.data

splash BYTE"     #######                          /",13,10    
BYTE "       /       ###                      #/",13,10
BYTE "      /         ##                      ##",13,10
BYTE "      ##        #                       ##",13,10
BYTE "       ###                              ##",13,10
BYTE "      ## ###      ###  /###     /###    ##  /##      /##",13,10
BYTE "       ### ###     ###/ #### / / ###  / ## / ###    / ###",13,10
BYTE "         ### ###    ##   ###/ /   ###/  ##/   /    /   ###",13,10
BYTE "           ### /##  ##    ## ##    ##   ##   /    ##    ###",13,10
BYTE "             #/ /## ##    ## ##    ##   ##  /     ########",13,10
BYTE "              #/ ## ##    ## ##    ##   ## ##     #######",13,10
BYTE "               # /  ##    ## ##    ##   ######    ##",13,10
BYTE "     /##        /   ##    ## ##    /#   ##  ###   ####    /",13,10
BYTE "    /  ########/    ###   ### ####/ ##  ##   ### / ######/",13,10
BYTE "   /     #####       ###   ### ###   ##  ##   ##/   #####",13,10
BYTE "   |",13,10                                                       
BYTE "    \)",0

ourNames BYTE "-Hamza Masud & Sohaib Ahmad",0
start BYTE "Start Game", 0


.code
splashScreen PROC
  call clrscr
  mov dh,0
  mov dl,10
  call gotoXY

  mov eax, green+(black*16)
  call setTextColor
  mov edx, OFFSET splash
  call writeString

  mov dh, 15
  mov dl, 35
  call gotoXY
  mov edx, OFFSET ourNames
  call writeString

  mov dh, 19
  mov dl, 34
  call gotoXY
  mov eax, white+(cyan*16)
  call setTextColor
  mov edx, OFFSET start
  call writeString

  mov eax, white+(black*16)
  call setTextColor
  
  mov dh, 19
  mov dl,32
  call gotoXY
  mov al, '>'
  call writeChar
again:
  call readChar 
  cmp al, 0Dh
  jne again

  call clrscr
  
ret
splashScreen ENDP







END main