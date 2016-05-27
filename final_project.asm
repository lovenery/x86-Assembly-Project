TITLE Assembly Language Final Project

INCLUDE Irvine32.inc

Print_Something PROTO, xyPos:COORD

;; data segment
.data
console_title BYTE "Demo Program",0
consoleHandle    DWORD ?

xyInit COORD <42,18> ; 起始座標
xyBound COORD <80,25> ; 一個頁面最大的邊界
xyPos COORD <0,0> ; 現在的游標位置
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; code segment
.code
main PROC

; Set the console window's title.
INVOKE SetConsoleTitle, ADDR console_title

; Get the Console standard output handle:
INVOKE GetStdHandle, STD_OUTPUT_HANDLE
mov consoleHandle,eax

INITIAL:
    mov ax,xyInit.x
    mov xyPos.x,ax
    mov ax,xyInit.y
    mov xyPos.y,ax

GameLoop:

    call ClrScr ; clear screen
    INVOKE Print_Something, xyPos
    call Controller ; control the snake

    jmp GameLoop

main ENDP


; print
Print_Something PROC, xyP:COORD
mov ax, xyP.x
mov dl, al
mov ax, xyP.y
mov dh, al
call gotoXY
mov al, 178
call writeChar
ret
Print_Something ENDP


Controller PROC
call ReadChar ; 讀取鍵盤的輸入
.IF ax == 1177h ;UP=W
   sub xyPos.y,1
.ENDIF

.IF ax == 1F73h ;DOWN=S
   add xyPos.y,1
.ENDIF

.IF ax == 1E61h ;LEFT=A
   sub xyPos.x,1
.ENDIF

.IF ax == 2064h ;RIGHT=D
   add xyPos.x,1
.ENDIF

.IF ax == 011Bh ;ESC
   call EndGame
.ENDIF

; 檢查作完上下左右後有沒有超過限制邊界

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


END main