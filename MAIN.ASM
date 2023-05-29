;----------------------------------------------------------------------------
; 'Wieczny Kalendarz' * WKAL v1.0 * MOD0523 * MAIN rev. 1 * (c)1994 'marikaz'
;----------------------------------------------------------------------------
; Program podaje dzien tygodna na podstawie wprowadzonej daty. TU z zakresu
; od 1583/01/01 do 9999/12/31, ale uzytkownik powinien zadbac o sensownosc
; tej daty. Np. date 2020/04/31 program uzna za prawidlowa i poda dzien
; tygodnia ale oczywiscie dla 1/05.
;----------------------------------------------------------------------------

GETCURSORPOS    MACRO
                mov ah,3
                mov bx,0
                int 10h
                ENDM

PRINTSTRING     MACRO addr
                lea dx,addr
                mov ah,9
                int 21h
                ENDM

GETDATAFROMCON  MACRO data
                lea dx,data
                mov ah,0ah
                int 21h
                ENDM

code SEGMENT PARA 'code'
     ASSUME cs:code
     ORG 100h
.386

start:
                jmp main

info     DB 13,10
         DB "  WKAL v1.0 ** (c)1994 'marikaz'",13,10
         DB '  ---------------------------------------',13,10
         DB '  [Enter] - nastepna data : [Esc] - wyjdz',13,10
         DB 13,10,'$'

errtxt   DB '        E',13,10,'$'

clear    DB 30 DUP (20h),'$'

output   DB 20h,20h
date     DB '0000/00/00 to '
dow      DB 12 DUP (20h),13,10,'$'

txt1     DB '      rok: $'
txt2     DB '  miesiac: $'
txt3     DB '    dzien: $'

dowName  DB 'SOBOTA      '
         DB 'NIEDZIELA   '
         DB 'PONIEDZIALEK'
         DB 'WTOREK      '
         DB 'SRODA       '
         DB 'CZWARTEK    '
         DB 'PIATEK      '

year     DB 5,?,5 DUP (0)
month    DB 3,?,0,0,0
day      DB 3,?,0,0,0

 h       DW ? ;dzien tyg (0=sob)
 q       DW ? ;dzien m-ca
 m       DW ? ;m-c
 Y       DW ? ;rok

cRow     DB ?

main:
                PRINTSTRING info
                GETCURSORPOS
                mov cRow,dh
again:
                call ClearBuffers
                call StartPos
                PRINTSTRING clear
                call StartPos
                PRINTSTRING txt1
                GETDATAFROMCON year

                xor dx,dx
                mov bx,5 ;offset ostatniej cyfry
                ;pobierz rok
                mov ax,0
                mov al,[year+bx]
                cmp ax,30h
                jb  err0
                cmp ax,39h
                ja  err0
                sub ax,30h
                mov Y,ax

                dec bx
                mov cx,10
                mov al,[year+bx]
                cmp ax,30h
                jb  err0
                cmp ax,39h
                ja  err0
                sub ax,30h
                mul cx
                add Y,ax

                dec bx
                mov cx,100
                mov al,[year+bx]
                cmp ax,30h
                jb  err0
                cmp ax,39h
                ja  err0
                sub ax,30h
                mul cx
                add Y,ax

                dec bx
                mov cx,1000
                mov ax,0
                mov al,[year+bx]
                cmp ax,30h
                jb  err0
                cmp ax,39h
                ja  err0
                sub ax,30h
                mul cx
                add Y,ax

                cmp Y,1583
                jb  err0
                cmp Y,9999
                ja  err0

                ;miesiac
                call StartPos
                PRINTSTRING clear
                call StartPos
                PRINTSTRING txt2
                GETDATAFROMCON month
                mov ax,0
                cmp [month+3],0dh
                jne twoDigits
                mov al,[month+2]
                cmp ax,31h    ;dla jednej cyfry musi byc 1
                jb  err0
                cmp ax,39h
                ja  err0
                sub ax,30h
                mov m,ax
                jmp getDay
     twoDigits:
                mov al,[month+3]
                cmp ax,30h
                jb err0
                cmp ax,39h
                ja err0
                sub ax,30h
                mov m,ax

                mov cx,10
                mov al,[month+2]
                cmp ax,30h
                jb err0
                cmp ax,39h
                ja err0
                sub ax,30h
                mul cx
                add m,ax

                cmp m,1
                jb  err0
                cmp m,12
                ja  err0

       getDay:  ;dzien
                call StartPos
                PRINTSTRING clear
                call StartPos
                PRINTSTRING txt3
                GETDATAFROMCON day
                mov ax,0
                cmp [day+3],0dh
                jne twoDigits2
                mov al,[day+2]
                cmp ax,31h    ;dla jednej cyfry musi byc 1
                jb  err0
                cmp ax,39h
                ja  err0
                sub ax,30h
                mov q,ax
                jmp next
    twoDigits2:
                mov al,[day+3]
                cmp ax,30h
                jb err0
                cmp ax,39h
                ja err0
                sub ax,30h
                mov q,ax

                mov cx,10
                mov al,[day+2]
                cmp ax,30h
                jb err0
                cmp ax,39h
                ja err0
                sub ax,30h
                mul cx
                add q,ax

                cmp q,1
                jb  err0
                cmp q,31
                ja  err0
         next:
                call  Zeller

                lea si,[year+2]
                lea di,[date]
                mov cx,4
                rep movsb

                inc di
                cmp [month+1],1
                ja  move2dig
                mov al,'0'
                stosb
                mov al,[month+2]
                stosb
                jmp moveD
      move2dig:
                mov al,[month+2]
                stosb
                mov al,[month+3]
                stosb
         moveD:
                inc di
                cmp [day+1],1
                ja  move2dig2
                mov al,'0'
                stosb
                mov al,[day+2]
                stosb
                jmp getDOW
     move2dig2:
                mov al,[day+2]
                stosb
                mov al,[day+3]
                stosb
getDOW:
                xor dx,dx
                mov ax,h
                mov bx,12
                mul bx
                mov bx,ax
                lea si,[dowName+bx]
                lea di,dow
                mov cx,12
                rep movsb

                call StartPos
                PRINTSTRING clear
                call StartPos
                PRINTSTRING output
                GETCURSORPOS
                mov cRow,dh
    waitKey:
                mov ah,0ah
                mov al,'?'
                mov bh,0
                mov cx,1
                int 10h
                mov ah,0
                int 16h
                cmp al,1bh
                je exit
                cmp al,0dh
                je again
                jmp waitKey
exit:
                mov ah,4ch
                int 21h
err0:
                PRINTSTRING errTxt
                GETCURSORPOS
                mov cRow,dh
                jmp waitKey

;----------------------------------------------------------------------------
StartPos        PROC
                mov ah,2
                mov bx,0
                mov dh,cRow
                mov dl,0
                int 10h
                ret
StartPos        ENDP

ClearBuffers    PROC
                mov al,0
                lea di,[year+1]
                mov cx,6
                rep stosb
                inc di
                mov cx,4
                rep stosb
                inc di
                mov cx,4
                rep stosb
                ret
ClearBuffers    ENDP

                INCLUDE zeller.inc

code     ENDS
         END start