;Nome: Gabriel Santa Clara Ucelli
;Materia: Sistemas Embarcados 1
;Curso: Engenharia de Computação
;Matricula: 2013101033

segment code
..start:
	mov 		ax,data
	mov 		ds,ax
	mov 		ax,stack
	mov 		ss,ax
	mov 		sp,stacktop

; salvar modo corrente de video(vendo como esta o modo de video da maquina)

	mov  		ah,0Fh
	int  		10h
	mov  		[modo_anterior],al   

; alterar modo de video para grafico 640x480 16 cores

	mov     	al,12h
	mov     	ah,0
	int     	10h
	
;inicializando_mouse:

	mov ax, 01h
	int 33h
		
;DESENHAR A INTERFACE
;desenhar retas

	mov		byte[cor],branco_intenso	;linha do meio
	mov		ax, 250
	push		ax
	mov		ax,0
	push		ax
	mov		ax, 250
	push		ax
	mov		ax,480
	push		ax
	call		line
	
	mov		byte[cor],branco_intenso	;linha entre histogramas
	mov		ax, 250
	push		ax
	mov		ax,250
	push		ax
	mov		ax, 640
	push		ax
	mov		ax,250
	push		ax
	call		line
	
	mov		byte[cor],branco_intenso	;linha baixa
	mov		ax, 0
	push		ax
	mov		ax,115
	push		ax
	mov		ax, 250
	push		ax
	mov		ax,115
	push		ax
	call		line
	
	mov		byte[cor],branco_intenso	;linha alta
	mov		ax, 0
	push		ax
	mov		ax,365
	push		ax
	mov		ax, 250
	push		ax
	mov		ax,365
	push		ax
	call		line
	
	mov		byte[cor],branco_intenso	;1 linha menu
	mov		ax, 70
	push		ax
	mov		ax, 480
	push		ax
	mov		ax, 70
	push		ax
	mov		ax, 365
	push		ax
	call		line
	
	mov		byte[cor],branco_intenso	;2 linha menu
	mov		ax, 130
	push		ax
	mov		ax, 480
	push		ax
	mov		ax, 130
	push		ax
	mov		ax, 365
	push		ax
	call		line
	
	mov		byte[cor],branco_intenso	;3 linha menu
	mov		ax, 190
	push		ax
	mov		ax, 480
	push		ax
	mov		ax, 190
	push		ax
	mov		ax, 365
	push		ax
	call		line

;escrever title histograma

	mov     	cx,10			;numero de caracteres
	mov     	bx,0
	mov     	dh,1			;linha 0-29
	mov     	dl,35			;coluna 0-79
	mov		byte[cor],branco
	
l4__:
	call	cursor
	mov     al,[bx+title_histograma]
	call	caracter
	inc     bx			;proximo caracter
	inc		dl			;avanca a coluna
	;inc		byte [cor]		;mudar a cor para a seguinte
	loop    l4__
	
;escrever title histograma equalizado

	mov     	cx,21			;numero de caracteres
	mov     	bx,0
	mov     	dh,15			;linha 0-29
	mov     	dl,35			;coluna 0-79
	mov		byte[cor],branco
	
l3__:
	call	cursor
	mov     al,[bx+title_histograma_eq]
	call	caracter
	inc     bx			;proximo caracter
	inc		dl			;avanca a coluna
	;inc		byte [cor]		;mudar a cor para a seguinte
	loop    l3__
	
	
;escrever nome

	mov     	cx,14			;numero de caracteres
	mov     	bx,0
	mov     	dh,25			;linha 0-29
	mov     	dl,3			;coluna 0-79
	mov		byte[cor],azul
	
l4:
	call	cursor
	mov     al,[bx+nome]
	call	caracter
	inc     bx			;proximo caracter
	inc		dl			;avanca a coluna
	;inc		byte [cor]		;mudar a cor para a seguinte
	loop    l4
	
;escreve curso

	mov     	cx,21			;n?mero de caracteres
	mov     	bx,0
	mov     	dh,26			;linha 0-29
	mov     	dl,3			;coluna 0-79
	mov		byte[cor],azul
	
l5:
	call	cursor
	mov     al,[bx+curso]
	call	caracter
	inc     bx			;proximo caracter
	inc		dl			;avanca a coluna
	;inc		byte [cor]		;mudar a cor para a seguinte
	loop    l5
	
;escreve o periodo

	mov     	cx,6			;n?mero de caracteres
	mov     	bx,0
	mov     	dh,27			;linha 0-29
	mov     	dl,3			;coluna 0-79
	mov		byte[cor],azul
	
l6:
	call	cursor
	mov     al,[bx+periodo]
	call	caracter
	inc     bx			;proximo caracter
	inc		dl			;avanca a coluna
	;inc		byte [cor]		;mudar a cor para a seguinte
	loop    l6
	
call l_menu ; escreve menu

	
l_mouse:

	mov ax, 5h
	mov bx, 0
	int 33h
	
	cmp bx, 1 ;não clicou
	jl	l_mouse
	
	mov	ax,480
	sub ax, dx
	
	cmp ax, 365 ;não está em uma area clicavel
	jl l_mouse
	
	mov	ax,cx

l_abrir:

	cmp ax, 70
	jg l_fechar
	
	call l_menu
	call abrir_amarelo
	
	call limpar_histograma
	call limpar_histograma_eq
	
	jmp verifica_arquivo

l_fechar:		
	cmp ax, 130
	jg l_hist
	
	call l_menu
	call sair_amarelo
	
	jmp exit

l_hist:	
	cmp ax, 200
	jg l_histeq
	
	call l_menu
	call hist_amarelo
	
	cmp word[handle],0
	je l_mouse
	
	jmp l_setup_max
	
l_histeq:
	cmp ax, 250
	jg l_mouse
	
	call l_menu
	call histeq_amarelo
	
	cmp word[handle],0
	je l_mouse
	
	jmp f_densidade_acumulada
	
jmp l_mouse
	
	
verifica_arquivo:
	
	cmp word[handle],0
	je abrir_arquivo ;não abriu ainda

fechar_arquivo:
	
	;fechar o arquivo
	mov bx, handle
	mov ah, 3Eh
	int 21h		
	
abrir_arquivo:

	mov dx, filename ; coloca o endereço do nome do arquivo em dx
	mov al, 2 ; modo leitura e escrita
	mov ah, 3Dh ;abre arquivo
	int 21h
	
	mov [handle], ax
	
	mov word[i],0
	mov word[j], 365
	
	xor si, si
	
zerar_histograma:
	
	cmp si, 512
	je le_um_numero
	
	mov word[histograma+si], 0
	
	inc si
	inc si
	
	jmp zerar_histograma

le_um_numero:

	mov byte[sum], 0
	
le_byte: ;le um byte	

	mov ah, 3Fh 
	mov bx, [handle] ;manipulador
	mov cx, 1 ;quantidade de bytes a serem lidos
	mov dx, buffer ;segment offset de um buffer
	int 21h
	
	mov dl, byte[buffer]
	cmp dl, ' '
	je printar_ponto
	
	sub dl, 30h
	
	mov al, 10 ;
	mov bl, byte[sum]
	mul bl
	
	mov byte[sum], al
		
	add byte[sum], dl
	
	jmp le_byte
	
printar_ponto:		

	;add byte[sum], 10h ;em binario - 10h é pq o espaco é 20h
	xor ax, ax
	mov al, byte[sum]
	
	;mov si, ax
	mov bl, 2
	mul bl
	mov si, ax
	
	inc word[histograma+si]
	
	mov al, byte[sum]
	mov dl, 16
	div dl
	mov byte[cor], al
	
	mov dx, word[i]
	push dx
	
	mov dx, word[j]
	push dx
	
	call plot_xy
	
	cmp word[i], 249
	je nova_linha
	inc word[i]
	jmp le_um_numero
	
nova_linha:
	cmp word[j], 116
	jne continua ; acabou de ler o arquivo e printar na tela
	jmp l_mouse
	
continua:
	mov word[i], 0
	dec word[j]
	jmp le_um_numero
	

l_setup_max:
	xor si, si
	xor ax, ax
	
l_histograma:
	mov ax, word[histograma+si]
	mov word[max_histograma], ax
	inc si
	inc si
	
l_max_histograma:

	cmp si, 512
	je l_setup_histograma
	
	mov ax, word[histograma+si]
	cmp word[max_histograma], ax
	jl l_histograma
	
	inc si
	inc si
	jmp l_max_histograma
	

l_setup_histograma:
	mov word[i], 0
	
l_desenhar_histograma:

	mov		byte[cor],branco_intenso	;linha entre histogramas
	
	mov		ax, 260 ;x0
	add		ax, word[i]
	push		ax
	
	mov		ax, 260 ;y0
	push		ax
	
	mov		ax, 260 ;xf
	add 	ax, word[i]
	push		ax
	
	;mov si,	word[i]
	mov ax, word[i]
	mov bx, 2
	mul bx
	mov si, ax
	
	mov ax, word[histograma+si]   ; AL = 0C8h
	mov bx, 170
	mul bx       ; AX = 0320h (800)
	
	mov bx, word[max_histograma]
	div bx
	
	add ax, 260
	push		ax
	
	cmp word[i], 256
	jne continua2
	jmp l_mouse

continua2:

	call line
	
	inc word[i]
	;inc word[i]
	
	jmp l_desenhar_histograma
	
	
f_densidade_acumulada:
	
	xor si, si
		
zerar_histo_eq:
		
	cmp si, 512
	je begin_histo_eq
	
	mov word[histograma2+si],0
	mov word[histo_eq+si], 0
	
	inc si
	inc si
	
	jmp zerar_histo_eq

begin_histo_eq:
		
	mov ax, word[histograma]
	mov word[histo_eq], ax
	xor si, si
	inc si
	inc si
		
for_histo_eq:
		
	cmp si, 512
	je setup_h
	
	mov ax, word[histo_eq+si]
	add ax, word[histograma+si]
	add ax, word[histo_eq-2+si]
	
	mov word[histo_eq+si], ax
	
	inc si
	inc si
	jmp for_histo_eq
		
setup_h:

	mov ax, word[histo_eq]
	mov word[min_histo_eq], ax
	
	mov ax, word[histo_eq+510]
	mov word[max_histo_eq], ax
	
	mov ax, word[max_histo_eq]
	sub ax, word[min_histo_eq]
	
	;mov bx, 255
	;mul bx
	
	mov word[den_h], ax
	
	xor si, si		
		
begin_h:

	cmp si, 512
	je	setup_feq
	
	mov ax, word[histo_eq + si]
	sub ax, word[min_histo_eq]
	
	mov bx, 255
	mul bx
	
	mov bx, word[den_h]
	div bx
	
	mov word[h+si], ax
	
	inc si
	inc si
	
	jmp begin_h
		
setup_feq:

	mov ah, 0x42
	mov bx, [handle]
	mov cx, 0
	mov dx, 0
	mov al, 0
	int 21h
	
	xor si, si
	
	mov word[i], 0
	mov word[j], 365
		
le_um_numero_feq:

	mov byte[sum], 0
		
le_feq:
	
	mov ah, 3Fh 
	mov bx, [handle]
	mov cx, 1 ;quantidade de bytes a serem lidos
	mov dx, buffer ;segment offset de um buffer
	int 21h
	
	mov dl, byte[buffer]
	cmp dl, ' '
	je printar_ponto_feq
	
	sub dl, 30h
	
	mov al, 10 ;
	mov bl, byte[sum]
	mul bl
	
	mov byte[sum], al
		
	add byte[sum], dl
	
	jmp le_feq
		
		
		
printar_ponto_feq:

	xor ax, ax
	mov al, byte[sum]
	mov bx, 2
	mul bx
	mov si, ax ;posicao
	mov ax, word[h+si]
	
	mov bx, 2
	mul bx
	
	mov si, ax
	
	inc word[histograma2+si]
	
	
	xor ax, ax
	mov al, byte[sum]
	mov bx, 2
	mul bx
	mov si, ax ;posicao
	mov ax, word[h+si]
	
	mov bx, 16
	div bx
	
	mov byte[cor], al
	
	mov dx, word[i]
	push dx
	
	mov dx, word[j]
	push dx
	
	call plot_xy
	
	cmp word[i], 249
	je nova_linha_feq
	inc word[i]
	jmp le_um_numero_feq
		
nova_linha_feq:

	cmp word[j], 116
	je l_setup_max_2
	mov word[i], 0
	dec word[j]
	jmp le_um_numero_feq

		
l_setup_max_2:

	xor si, si
	xor ax, ax
		
l_histograma2

	mov ax, word[histograma2+si]
	mov word[max_histograma2], ax
	inc si
	inc si
		
l_max_histograma2:

	cmp si, 512
	je histograma_eq
	
	mov ax, word[histograma2+si]
	cmp word[max_histograma2], ax
	jl l_histograma2
	
	inc si
	inc si
	jmp l_max_histograma2		
		
histograma_eq:

	mov word[i], 0
	xor ax, ax
		
	printa_histo_eq:

	mov		byte[cor], branco_intenso	;linha entre histogramas
	
	mov		ax, 260 ;x0
	add		ax, word[i]
	push	ax
	
	mov		ax, 10 ;y0
	push	ax
	
	mov		ax, 260 ;xf
	add 	ax, word[i]
	push	ax
	
	mov ax, word[i]
	mov bx, 2
	mul bx
	mov si, ax
	
	mov ax, word[histograma2+si]
	
	mov bx, 170
	mul bx
	
	mov bx, word[max_histograma2]
	div bx
	
	add ax, 10
	;mov ax, 30
	push	ax
	
	cmp word[i], 256
	jne continua3
	jmp l_mouse
		
	continua3:
	
	call	line
	
	inc word[i]
	
	jmp printa_histo_eq	
		
exit:		

		;mov    ah,08h
		;int     21h
	    mov  	ah,0   			; set video mode
	    mov  	al,[modo_anterior]   	; modo anterior
	    int  	10h
		mov     ax,4c00h
		int     21h
		
		
		
;***************************************************************************
;
;   fun??o cursor
;
; dh = linha (0-29) e  dl=coluna  (0-79)
cursor:
		pushf
		push 		ax
		push 		bx
		push		cx
		push		dx
		push		si
		push		di
		push		bp
		mov     	ah,2
		mov     	bh,0
		int     	10h
		pop		bp
		pop		di
		pop		si
		pop		dx
		pop		cx
		pop		bx
		pop		ax
		popf
		ret
;_____________________________________________________________________________
;
;   fun??o caracter escrito na posi??o do cursor
;
; al= caracter a ser escrito
; cor definida na variavel cor
caracter:
		pushf
		push 		ax
		push 		bx
		push		cx
		push		dx
		push		si
		push		di
		push		bp
    		mov     	ah,9
    		mov     	bh,0
    		mov     	cx,1
   		mov     	bl,[cor]
    		int     	10h
		pop		bp
		pop		di
		pop		si
		pop		dx
		pop		cx
		pop		bx
		pop		ax
		popf
		ret
;_____________________________________________________________________________
;
;   fun??o plot_xy
;
; push x; push y; call plot_xy;  (x<639, y<479)
; cor definida na variavel cor
plot_xy:
		push		bp
		mov		bp,sp
		pushf
		push 		ax
		push 		bx
		push		cx
		push		dx
		push		si
		push		di
	    mov     	ah,0ch
	    mov     	al,[cor]
	    mov     	bh,0
	    mov     	dx,479
		sub		dx,[bp+4]
	    mov     	cx,[bp+6]
	    int     	10h
		pop		di
		pop		si
		pop		dx
		pop		cx
		pop		bx
		pop		ax
		popf
		pop		bp
		ret		4
		
;-----------------------------------------------------------------------------
;
;   fun??o line
;
; push x1; push y1; push x2; push y2; call line;  (x<639, y<479)
line:
		push		bp
		mov		bp,sp
		pushf                        ;coloca os flags na pilha
		push 		ax
		push 		bx
		push		cx
		push		dx
		push		si
		push		di
		mov		ax,[bp+10]   ; resgata os valores das coordenadas
		mov		bx,[bp+8]    ; resgata os valores das coordenadas
		mov		cx,[bp+6]    ; resgata os valores das coordenadas
		mov		dx,[bp+4]    ; resgata os valores das coordenadas
		cmp		ax,cx
		je		line2
		jb		line1
		xchg		ax,cx
		xchg		bx,dx
		jmp		line1
line2:		; deltax=0
		cmp		bx,dx  ;subtrai dx de bx
		jb		line3
		xchg		bx,dx        ;troca os valores de bx e dx entre eles
line3:	; dx > bx
		push		ax
		push		bx
		call 		plot_xy
		cmp		bx,dx
		jne		line31
		jmp		fim_line
line31:		inc		bx
		jmp		line3
;deltax <>0
line1:
; comparar m?dulos de deltax e deltay sabendo que cx>ax
	; cx > ax
		push		cx
		sub		cx,ax
		mov		[deltax],cx
		pop		cx
		push		dx
		sub		dx,bx
		ja		line32
		neg		dx
line32:		
		mov		[deltay],dx
		pop		dx

		push		ax
		mov		ax,[deltax]
		cmp		ax,[deltay]
		pop		ax
		jb		line5

	; cx > ax e deltax>deltay
		push		cx
		sub		cx,ax
		mov		[deltax],cx
		pop		cx
		push		dx
		sub		dx,bx
		mov		[deltay],dx
		pop		dx

		mov		si,ax
line4:
		push		ax
		push		dx
		push		si
		sub		si,ax	;(x-x1)
		mov		ax,[deltay]
		imul		si
		mov		si,[deltax]		;arredondar
		shr		si,1
; se numerador (DX)>0 soma se <0 subtrai
		cmp		dx,0
		jl		ar1
		add		ax,si
		adc		dx,0
		jmp		arc1
ar1:		sub		ax,si
		sbb		dx,0
arc1:
		idiv		word [deltax]
		add		ax,bx
		pop		si
		push		si
		push		ax
		call		plot_xy
		pop		dx
		pop		ax
		cmp		si,cx
		je		fim_line
		inc		si
		jmp		line4

line5:		cmp		bx,dx
		jb 		line7
		xchg		ax,cx
		xchg		bx,dx
line7:
		push		cx
		sub		cx,ax
		mov		[deltax],cx
		pop		cx
		push		dx
		sub		dx,bx
		mov		[deltay],dx
		pop		dx



		mov		si,bx
line6:
		push		dx
		push		si
		push		ax
		sub		si,bx	;(y-y1)
		mov		ax,[deltax]
		imul		si
		mov		si,[deltay]		;arredondar
		shr		si,1
; se numerador (DX)>0 soma se <0 subtrai
		cmp		dx,0
		jl		ar2
		add		ax,si
		adc		dx,0
		jmp		arc2
ar2:		sub		ax,si
		sbb		dx,0
arc2:
		idiv		word [deltay]
		mov		di,ax
		pop		ax
		add		di,ax
		pop		si
		push		di
		push		si
		call		plot_xy
		pop		dx
		cmp		si,dx
		je		fim_line
		inc		si
		jmp		line6

fim_line:
		pop		di
		pop		si
		pop		dx
		pop		cx
		pop		bx
		pop		ax
		popf
		pop		bp
		ret		8
		

;ESCREVER MENU	
;escreve abrir
l_menu:

	mov     	cx,5			;n?mero de caracteres
	mov     	bx,0
	mov     	dh,3			;linha 0-29
	mov     	dl,2			;coluna 0-79
	mov		byte[cor],branco_intenso
	
	l7:
		call	cursor
		mov     al,[bx+abrir]
		call	caracter
		inc     bx			;proximo caracter
		inc		dl			;avanca a coluna
		;inc		byte [cor]		;mudar a cor para a seguinte
		loop    l7		

;escreve sair

	mov     	cx,4			;n?mero de caracteres
	mov     	bx,0
	mov     	dh,3			;linha 0-29
	mov     	dl,10			;coluna 0-79
	mov		byte[cor],branco_intenso
	
	l8:
		call	cursor
		mov     al,[bx+sair]
		call	caracter
		inc     bx			;proximo caracter
		inc		dl			;avanca a coluna
		;inc		byte [cor]		;mudar a cor para a seguinte
		loop    l8	

;escreve hist

	mov     	cx,4			;n?mero de caracteres
	mov     	bx,0
	mov     	dh,3			;linha 0-29
	mov     	dl,18			;coluna 0-79
	mov		byte[cor],branco_intenso
	
	l9:
		call	cursor
		mov     al,[bx+hist]
		call	caracter
		inc     bx			;proximo caracter
		inc		dl			;avanca a coluna
		;inc		byte [cor]		;mudar a cor para a seguinte
		loop    l9	
	
;escreve histeq

	mov     	cx,6			;n?mero de caracteres
	mov     	bx,0
	mov     	dh,3			;linha 0-29
	mov     	dl,25			;coluna 0-79
	mov		byte[cor],branco_intenso
	
	l10:
		call	cursor
		mov     al,[bx+histeq]
		call	caracter
		inc     bx			;proximo caracter
		inc		dl			;avanca a coluna
		;inc		byte [cor]		;mudar a cor para a seguinte
		loop    l10
	
	ret

;ESCREVER MENU EM AMARELO	
;escreve abrir
abrir_amarelo:

	mov     	cx,5			;n?mero de caracteres
	mov     	bx,0
	mov     	dh,3			;linha 0-29
	mov     	dl,2			;coluna 0-79
	mov		byte[cor],amarelo
	
	l7_:
		call	cursor
		mov     al,[bx+abrir]
		call	caracter
		inc     bx			;proximo caracter
		inc		dl			;avanca a coluna
		;inc		byte [cor]		;mudar a cor para a seguinte
		loop    l7_		

	ret

;************************************************
;escreve sair
sair_amarelo:

	mov     	cx,4			;n?mero de caracteres
	mov     	bx,0
	mov     	dh,3			;linha 0-29
	mov     	dl,10			;coluna 0-79
	mov		byte[cor],amarelo
	
	l8_:
		call	cursor
		mov     al,[bx+sair]
		call	caracter
		inc     bx			;proximo caracter
		inc		dl			;avanca a coluna
		;inc		byte [cor]		;mudar a cor para a seguinte
		loop    l8_

	ret

;escreve hist
hist_amarelo:

	mov     	cx,4			;n?mero de caracteres
	mov     	bx,0
	mov     	dh,3			;linha 0-29
	mov     	dl,18			;coluna 0-79
	mov		byte[cor],amarelo
	
	l9_:
		call	cursor
		mov     al,[bx+hist]
		call	caracter
		inc     bx			;proximo caracter
		inc		dl			;avanca a coluna
		;inc		byte [cor]		;mudar a cor para a seguinte
		loop    l9_	
	
	ret
		
;escreve histeq
histeq_amarelo:

	mov     	cx,6			;n?mero de caracteres
	mov     	bx,0
	mov     	dh,3			;linha 0-29
	mov     	dl,25			;coluna 0-79
	mov		byte[cor],amarelo
	
	l10_:
		call	cursor
		mov     al,[bx+histeq]
		call	caracter
		inc     bx			;proximo caracter
		inc		dl			;avanca a coluna
		;inc		byte [cor]		;mudar a cor para a seguinte
		loop    l10_
		
	ret
	
limpar_histograma:
	
	mov word[i],255
	mov word[j],260
	
l_limpar:

	mov byte[cor], preto
	
	mov dx, word[i]
	push dx
	
	mov dx, word[j]
	push dx
	
	call plot_xy
	
	cmp word[i], 630
	je nova_linha_limpar_histograma
	
	inc word[i]
	jmp l_limpar
	
nova_linha_limpar_histograma:

	cmp word[j], 445
	je acabou_limpar; acabou de ler o arquivo e printar na tela
	mov word[i], 255
	inc word[j]
	jmp l_limpar

acabou_limpar:
	ret
	

limpar_histograma_eq:
	
	mov word[i],255
	mov word[j],5
	
l_limpar_eq:

	mov byte[cor], preto
	
	mov dx, word[i]
	push dx
	
	mov dx, word[j]
	push dx
	
	call plot_xy
	
	cmp word[i], 630
	je nova_linha_limpar_histograma_eq
	
	inc word[i]
	jmp l_limpar_eq
	
nova_linha_limpar_histograma_eq:

	cmp word[j], 190
	je acabou_limpar_eq; acabou de ler o arquivo e printar na tela
	mov word[i], 255
	inc word[j]
	jmp l_limpar_eq

acabou_limpar_eq:
	ret
	
;*******************************************************************
segment data

cor		db		branco_intenso

;	I R G B COR
;	0 0 0 0 preto
;	0 0 0 1 azul
;	0 0 1 0 verde
;	0 0 1 1 cyan
;	0 1 0 0 vermelho
;	0 1 0 1 magenta
;	0 1 1 0 marrom
;	0 1 1 1 branco
;	1 0 0 0 cinza
;	1 0 0 1 azul claro
;	1 0 1 0 verde claro
;	1 0 1 1 cyan claro
;	1 1 0 0 rosa
;	1 1 0 1 magenta claro
;	1 1 1 0 amarelo
;	1 1 1 1 branco intenso

preto		equ		0
azul		equ		1
verde		equ		2
cyan		equ		3
vermelho	equ		4
magenta		equ		5
marrom		equ		6
branco		equ		7
cinza		equ		8
azul_claro	equ		9
verde_claro	equ		10
cyan_claro	equ		11
rosa		equ		12
magenta_claro	equ		13
amarelo		equ		14
branco_intenso	equ		15

modo_anterior	db		0
linha   	dw  		0
coluna  	dw  		0
deltax		dw		0
deltay		dw		0
title_histograma	db	'Histograma'
title_histograma_eq	db	'Histograma equalizado'	
nome    	db  	'Gabriel Ucelli'
curso		db		'Sistemas Embarcados I'
periodo		db		'2016/1'
abrir		db 		'Abrir'
sair		db		'Sair'
hist		db		'Hist'
histeq		db		'Histeq'
filename 	db		'imagem.txt',0
buffer		db		'R', '$'
handle		dw		0
input		db		'R'
sum			db		'0', '$'
i			dw		0
j			dw		365
max_histograma 	dw	0
max_histograma2	dw	0
max_histo_eq	dw	0
min_histo_eq	dw	62501
den_h			dw	0
histograma:	resw	256
histograma2: resw	256
histo_eq:	resw	256
h:			resw	256
;*************************************************************************
segment stack stack
    		resb 		1024
stacktop:


