; Algorytm (uproszczony) Zellera do identyfikacji dnia tygodnia.
; https://en.wikipedia.org/wiki/Zeller%27s_congruence
;
; h - dzien tygodnia (0=sobota ...)
; q - dzien miesiaca
; m - miesiac  (styczen, luty: m+=12)
; Y - rok      (styczen, luty: Y-=1)
;                                                 impl. 'marikaz'
;----------------------------------------------------------------

Zeller            PROC
                  cmp m,2
                  ja do
                  add m,12
                  sub Y,1
do:
                  xor dx,dx
                  mov h,0
                  mov ax,q
                  add h,ax

                  mov ax,m
                  inc ax
                  mov bx,13
                  mul bx
                  mov bx,5
                  div bx
                  add h,ax

                  mov ax,Y
                  add h,ax

                  xor dx,dx
                  mov bx,4
                  div bx
                  add h,ax

                  xor dx,dx
                  mov ax,Y
                  mov bx,100
                  div bx
                  sub h,ax

                  xor dx,dx
                  mov ax,y
                  mov bx,400
                  div bx
                  add h,ax

                  xor dx,dx
                  mov ax,h
                  mov bx,7
                  div bx

                  mov h,dx

                  ret
Zeller            ENDP