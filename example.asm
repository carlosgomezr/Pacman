imprime macro cadena
  mov ax,@data
  mov ds,ax
  mov ah,09
  mov dx,offset cadena
  int 21h
endm



view macro cadena
		MOV   AX,SEG cadena ;muevo a ax la cadena q deseo imprimir
		MOV   DS,AX        
		MOV   AH,09        ;asigno a ah = 09 para mostrar en consola
		LEA   DX,cadena    ;paso a dx la cadena
		INT   21H  		   ;interrupcion int 21h muestra en consola
endm    

clear macro     
            ;----------Con todo esto limpiamos la pantalla y la cerramos----------    
	mov ah, 0
	mov al, 3h
	int 10h
    mov ah, 6h          ;funcion 6h=scroll up, 7h=scroll down
    mov al, 0h          ;lineas a escrolear 0=borrar toda la pantalla
    mov bh, 00000111b  ;atributo, 4 bits primeros= background, 4ultimos = font color
    mov ch, 0           ;fila inicial de relleno
    mov cl, 0           ;columna inicial de relleno
    mov dh, 24          ;fila final de relleno
    mov dl, 79          ;columna final de relleno
    int 10h             ;interrupcion con funcion ah=6h
endm      

counter macro
	lea si, scorefile	;macro counter contiene score
	mov cx, 20
macr:	
	mov al, 30h
	mov [si], al
	inc si	
	loop macr
endm


.model small
.stack
.data
		cadena db 'Cadena a Escribir en el archivo','$'
		head db "Universidad de San Carlos de Guatemala",0Dh,0Ah,24h   
        menu db "Seleccione una opcion",0Dh,0Ah,24h; 0Dh,0Ah,24h --> equivale a '\n' en C++,
        op1 db "0. Laberinto",0Dh,0Ah,24h
        op2 db "1. Login",0Dh,0Ah,24h
        op3 db "2. Registrarse",0Dh,0Ah,24h
        op4 db "3. Salir",0Dh,0Ah,24h
		opjuego1 db "1.Iniciar ",24h
		opjuego2 db "2.Volver ",24h
		opjuego3 db "3.Limpiar ",24h
		opjuego4 db "4.Logout",0Dh,0Ah,24h
        apellido db "xD$" 
        msgtime db "time$"
        msgscore db "score$"  
        msgname db "name$"
		msgmaxscore db "MxS$"
	    msgnumero db 'Numero al azar: $' 
		;File file
		us db "Ingrese usuario", 0Dh,0Ah,"$"
		pass db "Ingrese password", 0Dh,0Ah,"$"
		vpass db "confirme password", 0Dh,0Ah,"$"
		msgcreateuser db "user creado (~owo)~", 0Dh,0Ah,"$"
		msgadd db "se aniadio", 0Dh,0Ah,"$"
		slash db " ", 0Dh,0Ah,"$"
		path db 'Usuarios.txt',0 ;nombre del archivo que deseo crear se almacena en masm611\binr
		separar db " ","$"

		scorefile db 3 dup(' '),'$'
		user_name db 20 dup(' '),'$'
		pasword db 5 dup(' '),'$'

		user_read db 20 dup(' '),'$'
		pass_read db 5 dup(' '),'$'

		confirmarpass db 5 dup(' '),'$'

		handle dw ?

		msgerror1 db "ERROR ARCHIVO Usuarios.txt",0Dh,0Ah,21h
		msgcoinciden db 'password incorreccta verifique$'

        ;variables
        ;variable laberinto
            i dw 0
            j dw 0
            x dw 0
            y dw 0
            xr dw 0
            yr dw 0
            sizec dw 16   
        
        ;variable puntos
            k dw 0
            l dw 0
            posx dw 0
            posy dw 0
            posxr dw 0
            posyr dw 0
            tam dw 8    
            
        ;variable pacman
            pk dw 0
            pl dw 0
            px dw 1
            py dw 2
            pxr dw 0
            pyr dw 0
            ptam dw 16
		;variable boca pacman
			bocax dw 3
			bocay dw 4
        ;variable contador
            cen db 0
            dece db 0
            uni db 0,0Dh,0Ah,24h  
            score db 0    
        ;variable timer
            centena db 0
            decena db 0
            unidad db 0
            time db 1
        ;variable maxscore
			centena1 db 0
			decena1 db 0
			unidad1 db 0
			scoreh db 0
        ;variable color pixcel
            color db 100
            colorpac db 01
        ;variables temporales
            tempx dw 0
            tempy dw 0   
        ;variables ciclo x y
            ciclox dw 0
            cicloy dw 0   
            condx dw 0  
            condy dw 0      
        ;variables ciclo punto x y
            puntox dw 0
            puntoy dw 0
            condpx dw 0
            condpy dw 0
            mp dw 2
		;variable randomize
			random dw 0
			numero dw 0
			sumar1 dw 2
			restar1 dw 6
			por dw 2
			
.code
inicio:
printmenu:
	imprime head;en dx se le asigna la cadena de entrada
    imprime menu
    imprime op1
    imprime op2
    imprime op3
    imprime op4
    jmp readop
printmenujuego:
	imprime opjuego1
	imprime opjuego2
	imprime opjuego3
	imprime opjuego4
	jmp readopjuego
    ;read_op opcion ingresada
readop:
    mov ah,8h  ;lee un caracter sin imprimirlo
    int 21h
    cmp al,30h
    je option1  ;saltar si es igual a uno
    cmp al,31h
    ;je option2  ;saltar si es igual a dos
    je login
	cmp al,32h
    ;je option3  ;saltar si es igual a tres
    je registrarse
	cmp al,33h
    je salir ;saltar si es igual a cuatro
    
    ;borrar pantalla
    mov ah,6h   ;funcion 6h=scroll up, 7h=scroll down
    mov al,0h   ;lineas a scrolear 0=borrar toda la pantalla
    mov bh,00000111b
    mov ch,0
    mov cl,0
    mov dh,24
    mov dl,79
    int 10h 
    ret         


readopjuego:
    mov ah,8h  ;lee un caracter sin imprimirlo
    int 21h
    cmp al,31h
    je option1  ;saltar si es igual a uno
    cmp al,32h
    je volverjuego  ;saltar si es igual a dos
    cmp al,33h
    je option1  ;saltar si es igual a tres
    cmp al,34h
	je logout
	cmp al,35h
    jne readopjuego ;saltar si es igual a cuatro
    
    ;borrar pantalla
    mov ah,6h   ;funcion 6h=scroll up, 7h=scroll down
    mov al,0h   ;lineas a scrolear 0=borrar toda la pantalla
    mov bh,00000111b
    mov ch,0
    mov cl,0
    mov dh,24
    mov dl,79
    int 10h 
    ret         	

volverjuego:
	call laberinto
	call rutscore
    ;call timer           
    call nameus
	call maxscore
	mov ah,02h
	mov dl,2
	mov dl,0
	int 10h
    jmp readesc	

logout:
	jmp printmenu
	
    ;leer la tecla scape
	
readesc2:
	mov ah,8h
    int 21h
    cmp al,70h  ;hexa de la tecla p
    je printmenu
	cmp al,6dh	;saltar si es igual a m la tecla presionada
	je printmenujuego
    cmp al,77h     ;saltar si es igual a w la tecla presionada
    je optionw   
    cmp al,73h     ;saltar si es igual a s la tecla presionada
    je options
    cmp al,61h     ;saltar si es igual a a la tecla presionada
    je optiona
    cmp al,64h     ;saltar si es igual a d la tecla presionada
    jmp readesc2   
	
readesc:
	
    mov al,time ; asigno un valor de 3 digitos en decimal al registro AL
    aam ;ajusta el valor en AL por: AH=23 Y AL=4 
    mov unidad,al ; Respaldo 4 en unidades
    mov al,ah ;muevo lo que tengo en AH a AL para poder volver a separar los números 
    aam ; separa lo qe hay en AL por: AH=2 Y AL=3
    mov centena,ah ;respaldo las centenas en cen en este caso 2
    mov decena,al ;respaldo las decenas en dec, en este caso 3
    ;Imprimos los tres valores empezando por centenas, decenas y unidades.
    
    mov ah,02h
    mov dh,00
    mov dl,10
    int 10h
           
    mov dx,offset msgtime
    mov ah,9h
    int 21h   
    
    mov ah,02h
	mov dh,00
	mov dl,15
	int 10h
	         
	mov ah,02h         
	mov dl,centena
    add dl,30h ; se suma 30h a dl para imprimir el numero real.
    int 21h
    
    mov ah,02h
    mov dl,decena
    add dl,30h
    int 21h
              
    mov ah,02h          
    mov dl,unidad
    add dl,30h
    int 21h   
    
	mov ah,02h
	mov dh,01
	mov dl,00
	int 10h
	
     ;interrupcion 1 seg
    mov cx, 0fh
    mov dx, 4240h
    mov ah, 86h
    int 15h            
    ;interrupcion 1 seg
	mov color,0
	mov dx,bocax
	mov cx,bocay
	mov posx,dx
    mov posy,cx
    call multi
    call pixel
    inc time
	
	
	;mov ah,8h
    mov ah,06h
	mov dl,00ffh
	int 21h
	
	
	jz readesc
	cmp al,70h  ;hexa de la tecla p
    je printmenu
	cmp al,6dh	;saltar si es igual a m la tecla presionada
	je printmenujuego
    cmp al,77h     ;saltar si es igual a w la tecla presionada
    je optionw   
    cmp al,73h     ;saltar si es igual a s la tecla presionada
    je options
    cmp al,61h     ;saltar si es igual a a la tecla presionada
    je optiona
    cmp al,64h     ;saltar si es igual a d la tecla presionada
    je optiond	
	jnz readesc	
	
    ;jmp readesc         

randomize:
	MOV AH, 00h  ; interrupts to get system time
	INT 1AH      ; CX:DX now hold number of clock ticks since midnight

	mov  ax, dx
	xor  dx, dx
	mov  cx, 10
	div  cx       ; here dx contains the remainder of the division - from 0 to 9

	add  dl, '0'  ; to ascii from '0' to '9'
	;mov ah, 2h   ; call interrupt to display a value in DL
	;int 21h
	mov random,dx
	mov ax,random
	mul por
	mov random,ax
RET

    
	
cicloc1:
    mov dx,ciclox
    mov x,dx
    call multiply
    call square
    inc ciclox
    mov ax,condx
    cmp ciclox,ax
    jb cicloc1
    ret 

cicloc2:
    mov dx,cicloy
    mov y,dx
    call multiply
    call square
    inc cicloy
    mov ax,condy
    cmp cicloy,ax
    jb cicloc2
    ret          
    
ciclop1:     
    mov dx,puntox
    mov posx,dx
    mov ax,posx
    mul mp
    mov posx,ax   
    call multi
    call pixel
    inc puntox
    mov ax,condpx
    cmp puntox,ax
    jb ciclop1
    ret
        
optionscore:
    call rutscore
    ;call timer 
    call nameus
	call maxscore
    jmp readesc            
          
option1:
    mov ah,0    ;cambiar modo de video
    mov al,13h  ;modo de video vga standard 
    int 10h
	mov bocax,3
	mov bocay,4
	mov px,1
	mov py,2
	mov cen,0
	mov dece,0
	mov uni,0
	mov score,0
	mov centena,0
	mov decena,0
	mov unidad,0
	mov time,0
    call laberinto
    call point
	call frutas
    call dibujarpacman
	;call timer
    jmp readesc   
       
laberinto:        

        ;COLUMNA SUPERIOR
    mov condx,20
    mov ciclox,0
    mov y,0      
    call cicloc1
	
	mov condx,20
	mov ciclox,0
	mov y,1
	call cicloc1
	
    
        ;COLUMNA INFERIOR
    mov condx,20
    mov ciclox,0
    mov y,11
    call cicloc1    
    

    ;COLUMNA 1
    mov condx,9
    mov ciclox,2
    mov y,3
    call cicloc1
    
    mov condx,18
    mov ciclox,10
    mov y,3
    call cicloc1           
               
    ;COLUMNA 4
    mov condx,9
    mov ciclox,2
    mov y,9     
    call cicloc1
        
    mov condx,18
    mov ciclox,10
    mov y,9
    call cicloc1
    ;COLUMNA 2
               
    mov condx,9
    mov ciclox,2
    mov y,5     
    call cicloc1
    
    mov condx,18
    mov ciclox,10
    mov y,5
    call cicloc1      
    
    ;COLUMNA 3
    
    mov condx,9
    mov ciclox,2
    mov y,7
    call cicloc1
    
    mov condx,18
    mov ciclox,10
    mov y,7
    call cicloc1    
    
               
    ;FILA IZQUIERDA
    
    mov condy,6
    mov cicloy,0
    mov x,0
    call cicloc2
    
	mov condy,11
	mov cicloy,7
	mov x,0
	call cicloc2
	
    ;FILA DERECHA
    mov condy,6
	mov cicloy,0
	mov x,19
	call cicloc2
	
    mov condy,11
    mov cicloy,7
    mov x,19
    call cicloc2
    
    
    ;FILA 1
    
    mov condy,5
    mov cicloy,3
    mov x,2
    call cicloc2
    
    mov condy,9
    mov cicloy,7
    mov x,2
    call cicloc2
        
    
    ;FILA 2
        
    mov condy,5
    mov cicloy,3
    mov x,8
    call cicloc2
    
    mov condy,9
    mov cicloy,7
    mov x,8
    call cicloc2
    
    ;FILA 3
    
    mov condy,5
    mov cicloy,3
    mov x,10
    call cicloc2
    
    mov condy,9
    mov cicloy,7
    mov x,10
    call cicloc2   
            
    ;FILA 4
    mov condy,5
    mov cicloy,3
    mov x,17
    call cicloc2
    
    mov condy,9
    mov cicloy,7
    mov x,17
    call cicloc2            
    ret
    
point:
	;PUNTOS COLUMNA ARRIBA 
    mov color,10
    mov posx,4
    mov posy,4
    call multi
    call pixel
    mov posx,6
    mov posy,4
    call multi
    call pixel
    mov posx,8
    mov posy,4
    call multi
    call pixel
    mov posx,10
    mov posy,4
    call multi
    call pixel
    mov posx,12
    mov posy,4
    call multi
    call pixel 
    mov posx,14
    mov posy,4
    call multi
    call pixel
    mov posx,16
    mov posy,4
    call multi
    call pixel
    mov posx,18
    mov posy,4
    call multi
    call pixel 
    mov posx,20
    mov posy,4
    call multi
    call pixel 
    mov posx,22
    mov posy,4
    call multi
    call pixel
    mov posx,24
    mov posy,4
    call multi
    call pixel
    mov posx,26
    mov posy,4
    call multi
    call pixel
    mov posx,28
    mov posy,4
    call multi
    call pixel 
    mov posx,30
    mov posy,4
    call multi
    call pixel 
    mov posx,32
    mov posy,4
    call multi
    call pixel
    mov posx,34
    mov posy,4
    call multi
    call pixel 
   
    ;PUNTOS FILA IZQ
    mov posx,2
    mov posy,4
    call multi
    call pixel
    mov posx,2
    mov posy,6
    call multi
    call pixel
    mov posx,2
    mov posy,8
    call multi
    call pixel
    mov posx,2
    mov posy,10
    call multi
    call pixel
    mov posx,2
    mov posy,12
    call multi
    call pixel 
    mov posx,2
    mov posy,14
    call multi
    call pixel
    mov posx,2
    mov posy,16
    call multi
    call pixel
    mov posx,2
    mov posy,18
    call multi
    call pixel 
    mov posx,2
    mov posy,20
    call multi
    call pixel 
            

    ;PUNTOS FILA MEDIO
    mov posx,18
    mov posy,4
    call multi
    call pixel
    mov posx,18
    mov posy,6
    call multi
    call pixel
    mov posx,18
    mov posy,8
    call multi
    call pixel
    mov posx,18
    mov posy,10
    call multi
    call pixel
    mov posx,18
    mov posy,12
    call multi
    call pixel 
    mov posx,18
    mov posy,14
    call multi
    call pixel
    mov posx,18
    mov posy,16
    call multi
    call pixel
    mov posx,18
    mov posy,18
    call multi
    call pixel 
    mov posx,18
    mov posy,20
    call multi
    call pixel 

    ;PUNTOS FILA DER
    mov posx,36
    mov posy,4
    call multi
    call pixel
    mov posx,36
    mov posy,6
    call multi
    call pixel
    mov posx,36
    mov posy,8
    call multi
    call pixel
    mov posx,36
    mov posy,10
    call multi
    call pixel
    mov posx,36
    mov posy,12
    call multi
    call pixel 
    mov posx,36
    mov posy,14
    call multi
    call pixel
    mov posx,36
    mov posy,16
    call multi
    call pixel
    mov posx,36
    mov posy,18
    call multi
    call pixel 
    mov posx,36
    mov posy,20
    call multi
    call pixel 

     ;PUNTOS COLUMNA MEDIO
    mov posx,4
    mov posy,12
    call multi
    call pixel
    mov posx,6
    mov posy,12
    call multi
    call pixel
    mov posx,8
    mov posy,12
    call multi
    call pixel
    mov posx,10
    mov posy,12
    call multi
    call pixel
    mov posx,12
    mov posy,12
    call multi
    call pixel 
    mov posx,14
    mov posy,12
    call multi
    call pixel
    mov posx,16
    mov posy,12
    call multi
    call pixel
    mov posx,18
    mov posy,12
    call multi
    call pixel 
    mov posx,20
    mov posy,12
    call multi
    call pixel 
    mov posx,22
    mov posy,12
    call multi
    call pixel
    mov posx,24
    mov posy,12
    call multi
    call pixel
    mov posx,26
    mov posy,12
    call multi
    call pixel
    mov posx,28
    mov posy,12
    call multi
    call pixel 
    mov posx,30
    mov posy,12
    call multi
    call pixel 
    mov posx,32
    mov posy,12
    call multi
    call pixel
    mov posx,34
    mov posy,12
    call multi
    call pixel         
              
    ;PUNTOS COLUMNA ABAJO
    mov posx,4
    mov posy,20
    call multi
    call pixel
    mov posx,6
    mov posy,20
    call multi
    call pixel
    mov posx,8
    mov posy,20
    call multi
    call pixel
    mov posx,10
    mov posy,20
    call multi
    call pixel
    mov posx,12
    mov posy,20
    call multi
    call pixel 
    mov posx,14
    mov posy,20
    call multi
    call pixel
    mov posx,16
    mov posy,20
    call multi
    call pixel
    mov posx,18
    mov posy,20
    call multi
    call pixel 
    mov posx,20
    mov posy,20
    call multi
    call pixel 
    mov posx,22
    mov posy,20
    call multi
    call pixel
    mov posx,24
    mov posy,20
    call multi
    call pixel
    mov posx,26
    mov posy,20
    call multi
    call pixel
    mov posx,28
    mov posy,20
    call multi
    call pixel 
    mov posx,30
    mov posy,20
    call multi
    call pixel 
    mov posx,32
    mov posy,20
    call multi
    call pixel
    mov posx,34
    mov posy,20
    call multi
    call pixel
	ret
	
rutscore:
    
    mov al,score ; asigno un valor de 3 digitos en decimal al registro AL
    aam ;ajusta el valor en AL por: AH=23 Y AL=4
    
    mov uni,al ; Respaldo 4 en unidades
    mov al,ah ;muevo lo que tengo en AH a AL para poder volver a separar los números
    
    aam ; separa lo qe hay en AL por: AH=2 Y AL=3
    mov cen,ah ;respaldo las centenas en cen en este caso 2
    
    mov dece,al ;respaldo las decenas en dec, en este caso 3
    
    
    ;Imprimos los tres valores empezando por centenas, decenas y unidades.
    mov ah,02h
    mov dh,00 ; posicion de la fila donde pongo el cursor
    mov dl,00 ; posicion de la columna donde pongo el cursor
    int 10h
           
    mov dx,offset msgscore ;imprimo la variable db que se llama msgscore 
    mov ah,9h
    int 21h   
     
     
    mov ah,02h
    mov dh,00 ; posicion de la fila donde pongo el cursor
	mov dl,06 ;muevo el cursor a la columna 6
	int 10h   
	
	mov ah,02h      
    mov dl,cen ; imprimo numero db centena
    add dl,30h ; se suma 30h a dl para imprimir el numero real.
    int 21h
           
    mov ah,02h       
    mov dl,dece; imprimo numero db decena
    add dl,30h
    int 21h
              
    mov ah,02h          
    mov dl,uni; imprimo numero db unidad
    add dl,30h
    int 21h  
	
    ;Termina impresion numero score   
    ret
dibujarboca:
	mov dx,bocax
	mov cx,bocay
	mov posx,dx
    mov posy,cx
    call multi
    call pixel
	
dibujarpacman:   
    call rutscore
    ;call timer           
    call nameus
	call maxscore
    ;PACMAN      
    mov colorpac,14
    mov si,py
    ;mov px,10
    ;mov si,10
    
    mov dx,px
    ;mov dx,10
    call multipac
    call pacpixel
    ;/PACMAN
    ret 
         
frutas:    
	
    ;FRESA
	call randomize
    mov color,12
	mov dx,random
    mov posx,dx
	mov posy,4    
    call multi
    call pixel
    ;CEREZA
	call randomize
    mov color,13
	mov dx,random
	sub dx,restar1
    mov posx,dx
    mov posy,20
    call multi
    call pixel
    ;NARANJA
	call randomize
    mov color,14
	mov dx,random
	add dx,sumar1
    mov posx,dx
    mov posy,12
    call multi
    call pixel
            
    
nameus:
    mov ah,02h
    mov dh,00
    mov dl,20
    int 10h
    
    mov dx,offset msgname
    mov ah,9h
    int 21h
    ret

maxscore:
    ;mov ah,02h
    ;mov dh,00
    ;mov dl,33
    ;int 10h
    
    ;mov dx,offset msgmaxscore
    ;mov ah,9h
    ;int 21h
    ;ret
	
	mov al,scoreh ; asigno un valor de 3 digitos en decimal al registro AL
    aam ;ajusta el valor en AL por: AH=23 Y AL=4 
    mov unidad1,al ; Respaldo 4 en unidades
    mov al,ah ;muevo lo que tengo en AH a AL para poder volver a separar los números 
    aam ; separa lo qe hay en AL por: AH=2 Y AL=3
    mov centena1,ah ;respaldo las centenas en cen en este caso 2
    mov decena1,al ;respaldo las decenas en dec, en este caso 3
    ;Imprimos los tres valores empezando por centenas, decenas y unidades.
    
    mov ah,02h
    mov dh,00
    mov dl,33
    int 10h
           
    mov dx,offset msgmaxscore
    mov ah,9h
    int 21h   
    
    mov ah,02h
	mov dh,00
	mov dl,37
	int 10h
	         
	mov ah,02h         
	mov dl,centena1
    add dl,30h ; se suma 30h a dl para imprimir el numero real.
    int 21h
    
    mov ah,02h
    mov dl,decena1
    add dl,30h
    int 21h
              
    mov ah,02h          
    mov dl,unidad1
    add dl,30h
    int 21h       
    ret
    
timer:
    mov al,time ; asigno un valor de 3 digitos en decimal al registro AL
    aam ;ajusta el valor en AL por: AH=23 Y AL=4 
    mov unidad,al ; Respaldo 4 en unidades
    mov al,ah ;muevo lo que tengo en AH a AL para poder volver a separar los números 
    aam ; separa lo qe hay en AL por: AH=2 Y AL=3
    mov centena,ah ;respaldo las centenas en cen en este caso 2
    mov decena,al ;respaldo las decenas en dec, en este caso 3
    ;Imprimos los tres valores empezando por centenas, decenas y unidades.
    
    mov ah,02h
    mov dh,00
    mov dl,10
    int 10h
           
    mov dx,offset msgtime
    mov ah,9h
    int 21h   
    
    mov ah,02h
	mov dh,00
	mov dl,15
	int 10h
	         
	mov ah,02h         
	mov dl,centena
    add dl,30h ; se suma 30h a dl para imprimir el numero real.
    int 21h
    
    mov ah,02h
    mov dl,decena
    add dl,30h
    int 21h
              
    mov ah,02h          
    mov dl,unidad
    add dl,30h
    int 21h   
    
     ;interrupcion 1 seg
    mov cx, 0fh
    mov dx, 4240h
    mov ah, 86h
    int 15h            
    ;interrupcion 1 seg
    inc time  
    
    ret
    multipac:
        mov ax,px
        mul ptam
        mov pxr,ax
        mov ax,py
        mul ptam
        mov pyr,ax
        mov pl,0
    pacpixel:
        mov pk,0
        mov si,ptam
        cmp pl,si
        jb pacpixel2
        ret
    pacpixel2:
        mov ah,0ch
        mov al,colorpac
        mov bh,0 
        mov si,pk
        add pxr,si
        mov si,pl
        add pyr,si
        mov cx,pxr
        mov dx,pyr
        mov si,pk
        sub pxr,si
        mov si,pl
        sub pyr,si
        int 10h
        inc pk   
        mov si,ptam
        cmp pk,si
        jb pacpixel2
        inc pl
        jmp pacpixel
   
    ;PIXELES PUNTOS
    multi:
        mov ax,posx
        mul tam
        mov posxr,ax
        mov ax,posy
        mul tam
        mov posyr,ax
        mov l,0
                
    pixel:
        mov k,0
        mov si,tam
        cmp l,si    
        jb pixel2
        ret           
    
    pixel2:
        mov ah,0ch
        mov al,color
        mov bh,0
        mov si,k
        add posxr,si    
        mov si,l    
        add posyr,si
        mov cx,posxr
        mov dx,posyr 
        mov si,k
        sub posxr,si
        mov si,l
        sub posyr,si
        int 10h
        inc k
        mov si,tam
        cmp k,si
        jb pixel2
        inc l
        jmp pixel
    
    
    
    multiply:
        mov ax,x
        mul sizec
        mov xr,ax
        mov ax,y
        mul sizec
        mov yr,ax
        mov j,0
        ret  
    ;imprimir un cuadro de tamanio sizec
    square:
        mov i,0
        mov si,sizec
        cmp j,si
        jb square2
        ret   
    square2:
        mov ah,0ch
        mov al,01
        mov bh,0
        mov si,i
        add xr,si 
        mov si,j
        add yr,si
        mov cx,xr
        mov dx,yr
        mov si,i
        sub xr,si
        mov si,j
        sub yr,si
        int 10h;interrupcion
        inc i
        mov si,sizec
        cmp i,si            
        jb square2
        inc j
        jmp square
    
        
    printcarnet:
        mov ah,09h;impirmir un caracter en el puntero actaul
        mov al,'2';caracter a imprimir con atributos
        mov bh,0;numero de pagina
        mov bl,00000010b
        mov cx,1
        int 10h
        
        mov ah,2 ;cambiar posicion del cursor
        mov dh,0 ;posicion x
        mov dl,1 ;posicion y
        int 10h     
                       
        mov ah,09h
        mov al,'0'
        mov bh,0
        mov bl,00000010b
        mov cx,1
        int 10h    
        
        mov ah,2
        mov ah,0
        mov dl,2
        
        mov ah,09h
        mov al,'1'
        mov bh,0
        mov bl,00000010b
        mov cx,1
        
        jmp readesc  
        
    incrementscore1:
        inc score
        call pintarnegro
        dec py                                   
        dec bocay
		dec bocay
		call dibujarpacman
        jmp readesc
                    
    incrementscore2:
        inc score
        call pintarnegro
        inc py   
		inc bocay
		inc bocay		
        call dibujarpacman
        jmp readesc
    
    incrementscore3:
        inc score
        call pintarnegro
        dec px   
		dec bocax
		dec bocax
        call dibujarpacman
        jmp readesc   
        
    incrementscore4:
        inc score
        call pintarnegro
        inc px   
		inc bocax
		inc bocax
        call dibujarpacman
        jmp readesc
    
    incrementfresa1:
        add score,15
        call pintarnegro
        dec py   
		dec bocay
		dec bocay
        call dibujarpacman
        jmp readesc
                    
    incrementfresa2:
        add score,15
        call pintarnegro
        inc py   
		inc bocay
		inc bocay
        call dibujarpacman
        jmp readesc
    
    incrementfresa3:
        add score,15
        call pintarnegro
        dec px   
		dec bocax
		dec bocax
        call dibujarpacman
        jmp readesc   
        
    incrementfresa4:
        add score,15
        call pintarnegro
        inc px   
		inc bocax
		inc bocax
        call dibujarpacman
        jmp readesc
                           
                           
    incrementbanano1:
        add score,25
        call pintarnegro
        dec py   
		dec bocay
		dec bocay
        call dibujarpacman
        jmp readesc
                    
    incrementbanano2:
        add score,25
        call pintarnegro
        inc py   
		inc bocay
		inc bocay
        call dibujarpacman
        jmp readesc
    
    incrementbanano3:
        add score,25
        call pintarnegro
        dec px   
		dec bocax
		dec bocax
        call dibujarpacman
        jmp readesc   
        
    incrementbanano4:
        add score,25
        call pintarnegro
        inc px   
		inc bocax
		inc bocax
        call dibujarpacman
        jmp readesc 
        
    incrementnaranja1:
        add score,5
        call pintarnegro
        dec py   
		dec bocay
		dec bocay
        call dibujarpacman
        jmp readesc
                    
    incrementnaranja2:
        add score,5
        call pintarnegro
        inc py   
		inc bocay
		inc bocay
        call dibujarpacman
        jmp readesc
    
    incrementnaranja3:
        add score,5
        call pintarnegro
        dec px   
		dec bocax
		dec bocax
        call dibujarpacman
        jmp readesc   
        
    incrementnaranja4:
        add score,5
        call pintarnegro
        inc px   
		inc bocax
		inc bocax
        call dibujarpacman
        jmp readesc                          
                                
    pintarnegro:
        mov colorpac,00
        mov si,py
        mov dx,px
        call multipac
        call pacpixel
        ret
         
    pressw:
        mov ax,py
        mul ptam
        mov tempy,ax
        sub tempy,9
        mov ax,px
        mul ptam
        mov tempx,ax
        add tempx,6   
        mov ah, 0dh ;AH = 0DH
	    mov bh,0	;BH = Página de vídeo.
	    mov cx,tempx	;CX = Columna del pixel que nos interesa (coordenada gráfica x).
	    mov dx,tempy	;DX = Fila del pixel que nos interesa (coordenada gráfica y).
	    int 10h
	    cmp al,01
	    je readesc
	    cmp al,10
	    je incrementscore1
        cmp al,12
        je incrementfresa1
        cmp al,13
        je incrementnaranja1
        cmp al,14
        je incrementbanano1
        call pintarnegro
        dec py    
		dec bocay
		dec bocay
        ;inc score
        call dibujarpacman
        jmp readesc  
    presss:          
        mov ax,py
        mul ptam
        mov tempy,ax
        add tempy,22
        mov ax,px
        mul ptam
        mov tempx,ax
        add tempx,6   
        mov ah, 0dh ;AH = 0DH
	    mov bh,0	;BH = Página de vídeo.
	    mov cx,tempx	;CX = Columna del pixel que nos interesa (coordenada gráfica x).
	    mov dx,tempy	;DX = Fila del pixel que nos interesa (coordenada gráfica y).
	    int 10h
	    cmp al,01
	    je readesc
	    cmp al,10
	    je incrementscore2
        cmp al,12
        je incrementfresa2 
        cmp al,13
        je incrementnaranja2
        cmp al,14
        je incrementbanano2            
        call pintarnegro
        inc py   
		inc bocay
		inc bocay
        ;inc score
        call dibujarpacman
        jmp readesc
    pressa:
        mov ax,py
        mul ptam
        mov tempy,ax
        add tempy,6
        mov ax,px
        mul ptam
        mov tempx,ax
        sub tempx,10   
        mov ah, 0dh ;AH = 0DH
	    mov bh,0	;BH = Página de vídeo.
	    mov cx,tempx	;CX = Columna del pixel que nos interesa (coordenada gráfica x).
	    mov dx,tempy	;DX = Fila del pixel que nos interesa (coordenada gráfica y).
	    int 10h
		cmp al,01
	    je readesc              
        cmp al,10
	    je incrementscore3   
	    cmp al,12
        je incrementfresa3 
        cmp al,13
        je incrementnaranja3
        cmp al,14
        je incrementbanano3
        call pintarnegro
        dec px
		dec bocax
		dec bocax
		cmp px,1
		jb xpaso1
        ;inc score
        call dibujarpacman     
        jmp readesc
	xpaso1:
		call pintarnegro
        mov px,18
		mov bocax,37
        call dibujarpacman
        jmp readesc
    pressd:        
        mov ax,py
        mul ptam
        mov tempy,ax
        add tempy,6
        mov ax,px
        mul ptam
        mov tempx,ax
        add tempx,22   
        mov ah, 0dh ;AH = 0DH
	    mov bh,0	;BH = Página de vídeo.
	    mov cx,tempx	;CX = Columna del pixel que nos interesa (coordenada gráfica x).
	    mov dx,tempy	;DX = Fila del pixel que nos interesa (coordenada gráfica y).
	    int 10h
	    cmp al,01
	    je readesc      
        cmp al,10
	    je incrementscore4   
	    cmp al,12
        je incrementfresa4 
        cmp al,13
        je incrementnaranja4
        cmp al,14
        je incrementbanano4
        call pintarnegro
        inc px   
		inc bocax
		inc bocax
        ;inc score
		cmp px,18
		ja xpaso2
        call dibujarpacman
        jmp readesc       
    
	xpaso2:
		call pintarnegro
        mov px,1 
		mov bocax,1
        call dibujarpacman
        jmp readesc
		
    option2:
        mov ah,0
        mov al,3h
        int 10h
        
        ;imprimir
        
        mov ah,6h
        mov al,0h
        mov bh,00011110b
        mov ch,0
        mov cl,0
        mov dh,24
        mov dl,79
        int 10h
        
        ;imprimir apellido
        
        mov dx,offset apellido
        mov ah,9h
        int 21h
        
        ;readkey
        jmp readesc
        
    optionw:
        jmp pressw
    
    options:
        jmp presss
        
    optiona:
        jmp pressa
    
    optiond:
        jmp pressd            
        
    option3:
        mov ah,0
        mov al,13h
        int 10h
        jmp printcarnet
	
	;file code
	       
registrarse:
	clear
	view us
	jmp readuser
			
readuser:	
	lea SI, user_name	
	mov cx,20	
	 
savevec:
    mov ah,07h
    int 21h
    cmp al, 0Dh
    je ingresopass1
    mov [SI],al
    inc SI
    mov dl,al
    mov ah,02h
    int 21h
    loop savevec
	
ingresopass1:	
	view slash
	view pass
	lea SI,pasword
	mov cx,5
		
savepassword:
	mov ah,07h
    int 21h
    cmp al,0Dh
    je ingresopass2
    mov [SI],al
    inc SI
    mov dl,al
    mov ah,02h
    int 21h
    loop savepassword
	
ingresopass2:
	view slash
	view vpass
	lea SI,confirmarpass
	mov cx,5
 
savevec2:
    mov ah,07h
    int 21h
    cmp al, 0Dh
    je compare
    mov [SI],al
    inc SI
    mov dl,al
    mov ah,02h
    int 21h
    loop savevec2

compare:
	mov cx,5
	mov ax,ds
	mov es,ax
	lea si,pasword  
	lea di,confirmarpass 
	repe cmpsb  ;compara la password ingresada con la que cargue del archivo user
	Jne dif  ;passwords diferentes 
	je igual ;passwords iguales
	
clear_leidos:
	lea si,user_read
	mov cx,20
	
removeuserread:
	mov al,separar
	mov [si],al
	inc si 
	loop removeuserread
rpassread:
	lea si,pass_read
	mov cx,5
clearpassr:
	mov al,separar
	mov [si],al
	inc si 
	loop clearpassr
	ret
	
clear_vector:
	lea si,user_name
	mov cx,20
cleanus:
	mov al,separar
	mov [si],al
	inc si 
	loop cleanus	
cleanpass:
	lea si,Pasword
	mov cx,5
clpass:
	mov al,separar
	mov [si],al
	inc si 
	loop clpass	
cleanconfirmacion:
	lea si,confirmarpass
	mov cx,5
cleanconfirpass:
	mov al,separar
	mov [si],al
	inc si 
	loop cleanconfirpass
cleanscore:
	lea si,scorefile
	mov cx,3
clean_marc:
	mov al,separar
	mov [si],al
	inc si 
	loop clean_marc
	ret
			  
modificar:
	mov ah, 3dh
	mov al, 2
	mov dx, offset path
	int 21h
	jc salir

	mov [handle], ax
	mov bx, ax
	mov ah, 42h  
	mov al, 2    
	mov cx, 0    
	mov dx, 0    
	int 21h
	jc salir
	;escribo en el archivo xD
	mov bx, [handle]
	mov dx, offset user_name
	mov cx, 20
	mov ah, 40h
	int 21h 
	mov bx, [handle]
	mov dx, offset pasword
	mov cx, 5
	mov ah, 40h
	int 21h 
	counter
	mov bx, [handle]
	mov dx, offset scorefile
	mov cx, 3
	mov ah, 40h
	int 21h 
	view msgadd
	;cierro archivo xD
	mov bx, [handle]
	mov ah, 3eh
	int 21h 
	call clear_vector
	jmp printmenu
			
dif:
	view slash
	view msgcoinciden
	call clear_vector
	jmp printmenu
	
igual:	
	jmp modificar	
	
crear:
	mov ax,@data  
	mov ds,ax
	mov ah,3ch ;aqui es donde creo el archivo 
	mov cx,0 
	mov dx,offset path 
	int 21h
	jc ERR 
	view msgcreateuser
	mov bx,ax
	mov ah,3eh ;cierra el archivo
	int 21h
	jmp printmenu
	
ERR:
	view msgerror1
	jmp printmenu
	
salir:
	mov ax, 4C00H
	int 21h
	
login:
	call clear_leidos
	call clear_vector
	clear
	view us
	jmp saveus
	
saveus:
	lea SI, user_name	
	mov cx,20	
	 
nextsave:
    mov ah,07h
    int 21h
    cmp al, 0Dh
    je givemepass
    mov [SI],al
    inc SI
    mov dl,al
    mov ah,02h
    int 21h
    loop nextsave
	
givemepass:
	view slash
	view pass
	lea SI,pasword
	mov cx,5

savepass:
	mov ah,07h
    int 21h
    cmp al,0Dh
    je read
    mov [SI],al
    inc SI
    mov dl,al
    mov ah,02h
    int 21h
    loop savepass

read:
	mov     ah, 3dh        ;abro el archivo y lo leo
	mov     al, 0           
	lea     dx, path    
	int     21h             
	jc      salir
	mov     handle, ax       ;guardo handle 
	
firstview:        
	call clear_leidos
	mov     ah,3fh          
	lea     dx, user_read  
	mov     cx, 20          
	mov     bx, handle      
	int     21h
	jc      salir
	cmp     ax, cx          
	jne     finall
	
	mov cx,20   ;Determinamos la cantidad de datos a leer/comparar
	mov AX,DS  ;mueve el segmento datos a AX
	mov ES,AX  ;Mueve los datos al segmento extra

	lea si,user_read  ;cargamos en si la cadena que contiene vec	
	lea di,user_name ;cargamos en di la cadena que contiene vec2		
	repe cmpsb  ;compara las dos cadenas	
	je continuar ;si no fueron igual
	
	;mover 5 espacios el puntero
	mov     ah,3fh          ;Read data from the file
	lea     dx, pass_read  ;Address of data buffer
	mov     cx, 5          ;Read one byte
	mov     bx, handle      ;Get file handle value
	int     21h
	jc      salir
	cmp     ax, cx          ;final leido?
	jne     finall	
	
	;mueve el puntero los 3 espacios del marcador
	mov     ah,3fh          ;Read data from the file
	lea     dx, pass_read  ;Address of data buffer
	mov     cx, 3          ;Read one byte
	mov     bx, handle      ;Get file handle value
	int     21h
	cmp     ax, cx          ;final leido?
	jne     finall		
	jmp firstview  ;Read next byte
		
continuar:
	view slash
	view user_read
	view user_name
	mov     ah,3fh          ;Read data from the file
	lea     dx, pass_read  ;Address of data buffer
	mov     cx, 5          ;Read one byte
	mov     bx, handle      ;Get file handle value
	int     21h
	jc      salir
	cmp     ax, cx          ;final leido?
	jne     finall
		
	mov cx,5   ;Determinamos la cantidad de datos a leer/comparar
	mov AX,DS  ;mueve el segmento datos a AX
	mov ES,AX  ;Mueve los datos al segmento extra

	lea si,pasword  ;cargamos en si la cadena que contiene vec
	lea di,pass_read ;cargamos en di la cadena que contiene vec2
	view slash
	view pasword
	view pass_read
	repe cmpsb  ;compara las dos cadenas
	Je search ;si fueron igual	
	
	;mueve el puntero los 3 espacios del marcador
	mov     ah,3fh          ;Read data from the file
	lea     dx, pass_read  ;Address of data buffer
	mov     cx, 3          ;Read one byte
	mov     bx, handle      ;Get file handle value
	int     21h
	cmp     ax, cx          ;final leido?
	jne     finall	
	jmp firstview
		
search:
    mov     bx, handle
    mov     ah, 3eh         ;Close file
    int     21h
	jmp printmenu

finall:
	mov     bx, handle
	mov     ah, 3eh         ;Close file
	int     21h
   
	call clear_vector
	call clear_leidos
	view slash
	view user_read
	jmp printmenu


end 
