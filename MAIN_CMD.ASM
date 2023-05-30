;----------------------------------------------------------------------------
; Wieczny Kalendarz ** Alg. Zellera (uproszczony)
; WK v1.0c ** MOD0523 ** wersja linii polecen ** 'marikaz'
;----------------------------------------------------------------------------

code SEGMENT PARA 'code'
     ASSUME cs:code
     ORG 100h
.386
start:          jmp begin

usage    DB 0dh,0ah,' Uzycie: wk <YYYY-MM-DD>',0dh,0ah,0dh,0ah
         DB ' YYYY = Rok     (4 cyfry)',0dh,0ah
         DB '   MM = Miesiac (2 cyfry)',0dh,0ah
         DB '   DD = Dzien   (2 cyfry)',0dh,0ah,0dh,0ah
         DB ' Zakres od 1583-01-01 do 9999-12-31',13,10,'$'

output   DB 0dh,0ah,20h,20h,20h
dow      DB 12 DUP (20h),13,10,'$'

dowName  DB 'SOBOTA      '
         DB 'NIEDZIELA   '
         DB 'PONIEDZIALEK'
         DB 'WTOREK      '
         DB 'SRODA       '
         DB 'CZWARTEK    '
         DB 'PIATEK      '

 h       DW 0 ;dzien tyg (0=sob)
 q       DW 0 ;dzien m-ca
 m       DW 0 ;m-c
 Y       DW 0 ;rok

begin:
                mov si,80h
                cmp byte ptr [si],0
                je  prnUsage
                inc si
                xor dx,dx
                xor ax,ax
       skipBS:
                lodsb
                cmp al,20h
                je skipBS
                cmp  al,9
                je skipBS
                ;ROK
                cmp al,31h      ;rok od 1
                jb  prnUsage
                cmp al,39h
                ja prnUsage
                sub al,30h
                mov bx,1000
                mul bx
                add Y,ax

                xor ax,ax
                lodsb
                cmp al,30h
                jb  prnUsage
                cmp al,39h
                ja prnUsage
                sub al,30h
                mov bx,100
                mul bx
                add Y,ax

                xor ax,ax
                lodsb
                cmp al,30h
                jb  prnUsage
                cmp al,39h
                ja prnUsage
                sub al,30h
                mov bx,10
                mul bx
                add Y,ax

                lodsb
                cmp al,30h
                jb  prnUsage
                cmp al,39h
                ja prnUsage
                sub al,30h
                add Y,ax

                cmp Y,1583
                jb  prnUsage

                lodsb
                cmp al,'-'
                jne prnUsage

                ;NIESIAC
                lodsb
                cmp al,30h
                jb  prnUsage
                cmp al,39h
                ja prnUsage
                sub al,30h
                mov bx,10
                mul bx
                add m,ax

                lodsb
                cmp al,30h
                jb  prnUsage
                cmp al,39h
                ja prnUsage
                sub al,30h
                add m,ax

                cmp m,1
                jb prnUsage
                cmp m,12
                ja prnUsage

                lodsb
                cmp al,'-'
                jne prnUsage
                ;DZIEN
                lodsb
                cmp al,30h
                jb  prnUsage
                cmp al,39h
                ja prnUsage
                sub al,30h
                mov bx,10
                mul bx
                add q,ax

                lodsb
                cmp al,30h
                jb  prnUsage
                cmp al,39h
                ja prnUsage
                sub al,30h
                add q,ax

                cmp q,1
                jb prnUsage
                cmp q,31
                ja prnUsage
skipBS2:
                lodsb
                cmp si,0ffh
                je prnUsage
                cmp al,20h
                je skipBS2
                cmp al,9
                je skipBS2
                cmp al,0dh
                jne prnUsage

                call Zeller

                xor dx,dx
                mov ax,h
                mov bx,12
                mul bx
                mov bx,ax
                lea si,[dowName+bx]
                lea di,dow
                mov cx,12
                rep movsb

                lea dx,output
                mov ah,9
                int 21h
                mov al,0
exit:
                mov ah,4ch
                int 21h
prnUsage:
                lea dx,usage
                mov ah,9
                int 21h
                mov al,1
                jmp exit

                INCLUDE zeller.inc

code  ENDS
      END start