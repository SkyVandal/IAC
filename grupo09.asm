; ******************************************************************************************
; *
; * IST-UL
; *
; ******************************************************************************************

; ******************************************************************************************
; *
; * Projeto Interm�dio: Calculadora
; *   Grupo 9 :
; *     Bruno Codinha   90707
; *		Tiago Neves     90778
; *     Tom�s Costa     90783
; *
; ******************************************************************************************

; ******************************************************************************************
; * Constantes
; ******************************************************************************************
DISPLAYS   EQU 0A000H             ; endere�o dos displays de 7 segmentos (perif�rico POUT-1)
TEC_LIN    EQU 0C000H             ; endere�o das linhas do teclado (perif�rico POUT-2)
TEC_COL    EQU 0E000H             ; endere�o das colunas do teclado (perif�rico PIN)
LINHA      EQU 8                  ; posi��o do bit correspondente � linha a testar (4)
PIXSCREEN  EQU 8000H
TECLA_C    EQU 0CH
TECLA_D    EQU 0DH
TECLA_F    EQU 0FH
TECLA_E    EQU 0EH
UP         EQU 1
DOWN       EQU 2
LEFT       EQU 3
; ******************************************************************************************
; * C�digo
; ******************************************************************************************
PLACE      1000H
pilha : TABLE 200H
fim_pilha:
objeto_atual:
	WORD ninja_string
etiquetas_teclas:
	WORD funcao_0
	WORD funcao_1
	WORD funcao_2
	WORD funcao_3
	WORD funcao_4
	WORD funcao_5
	WORD funcao_6
	WORD funcao_7
	WORD funcao_8
	WORD funcao_9
	WORD funcao_A
	WORD funcao_B
	WORD funcao_C
	WORD funcao_D
	WORD funcao_E
	WORD funcao_F
tabela_interrupcoes:
		WORD gravidade_int
		WORD prendas_kunais_int
mascra_pix:
	string 80H
	string 40H
	string 20H
	string 10H
	string 08H
	string 04H
	string 02H
	string 01H
	string 55H  ;8



posicao_objeto:
;*********************************************************;
;                                                         ;
;strings que guardam o valor das posicoes dos ninjas,     ;
;das prendas e das armas atraves de duas coordenas (x,y). ;
;                                                         ;
;*********************************************************;
  string 10,10,10,10  ;ninjas
	string 28,12        ;prenda
	string 28,20        ;arma

ninja_string:
	string 4,3      ;comprimento e largura do ninja
	string 0,1,0
	string 1,1,1
	string 0,1,0
	string 1,0,1
kunai_objeto:
	string 3,3		;comprimento e largura da arma
	string 1,0,1
	string 0,1,0
	string 1,0,1

prenda_objeto:
	string 3,3      ;comprimento e largura da prenda
	string 0,1,0
	string 1,1,1
	string 0,1,0

pinta_limpa:
	string 1        ; flag 1-pinta um certo ponto 0-limpa um certo ponto

ultima_tecla:
	string 00FFH

flag_drop:
	string 0 ; flag gravidade

flag_extra:
	string 0 ; flag prendas e armas


PLACE 0H
	MOV SP, fim_pilha
	MOV BTE, tabela_interrupecoes
	EI0
	EI1
	EI
	MOV R7, 0                  ; coordenada geral x
	MOV R1, 10                 ; coordenada geral y
	CALL limpa_screen
	CALL inicializa_ecra

main:

	CALL ler_teclado
	CALL processamento
  CALL interrupcoes

JMP main

gravidade_int:
;poe a flag flag_drop a 1 em vez de zero e o que faz com que o a interrupcao execute o codigo que faz com os 4 ninjas des�am
PUSH R2
PUSH R3
MOV R2, flag_drop
MOV R3, 1
MOVB [R2], R3
POP R3
POP R2
RFE

prendas_kunais_int:
; mesma coisa mas para o as prendas e as armas
PUSH R2
PUSH R3
MOV R2, flag_extra
MOV R3, 1
MOVB [R2], R3
POP R3
POP R2
RFE

interrupcoes:
PUSH R8
PUSH R9
PUSH R10
DI
MOV R8, flag_drop  ; passa o endere�o da string flag_drop para R8
MOVB R9, [R8]      ; passa o valor da flag_drop para R9, 0 ou 1
MOV R10, 0         ;
MOVB [R8], R10     ; poe ativa a
CMP R9, 0
JZ ler_proximo

CALL gravidade
ler_proximo:
MOV R8, flag_extra
MOVB R9, [R8]
MOVB[R8], R10
CMP R9, 0
JZ fim_interrupcoes
CALL move_extras
fim_interrupcoes:
EI
POP R10
POP R9
POP R8
RET



gravidade:
; **********************************************************************************
; * Gravidade
; * Descricao - Rotina que movimenta para baixo os 4 ninjas, para tal chama as rotinas: gerador_ninjas, mover, atualizador_ninjas e ninja
; *
; **********************************************************************************
PUSH R2
PUSH R9
PUSH R3
PUSH R1
PUSH R8
PUSH R0
  MOV R3, 1                 ;contador
  MOV R9, 5				   ;5 para fazer 4 ciclos pois ha 4 ninjas
  MOV R8, 70H               ;31-4=70H    4, porque e a altura de um ninja
gravidade_aux:
  CALL gerador_ninjas      ; seleciona um certo ninja dependendo do r3
  MOV R2, DOWN

  CALL mover                 ; baixa o ninja selecionado
  CALL atualizador_ninjas    ; atualiza a nova posi�ao do ninja

  CMP R1, R8                  ; ve se o ninja ja chegou ao chao
  JGT mata_ninjas_gravidade  ;se ja tiver chegado salta para mata ninjas gravidade
gravidade_aux2:
  ADD R3, 1                   ; adiciona 1 ao R3 porque o gerador selecionar o ninja seguinte
  CMP R3, R9                  ; compara com cinco para ver se ja movimentou para baixo todos os ninjas
  JZ fim_gravidade           ; se sim salta para o fim
  JMP gravidade_aux          ; se nao repete
mata_ninjas_gravidade:

		MOV R0, pinta_limpa        ; esta parte do jogo acabar quando eles caem nao funciona
		MOV R8, 0				   ;
		MOVB [R0], R8
		CALL ninja
        JMP gravidade_aux2
fim_gravidade:
POP R0
POP R8
POP R1
POP R3
POP R9
POP R2
		RET


move_extras:
PUSH R6
PUSH R5
PUSH R0

	MOV R0, posicao_objeto   ; passa o endereco da string posicao_objeto para R0
	ADD R0, 4                ; adiciona 4 para R0 ficar com o endere�o da string que contem a coordenada x do presente
	MOVB R7, [R0]            ; guarda essa coordenada em R7
	ADD R0, 1                ; adiciona 1 para R0 ficar com o endere�o da string que contem a coordenada y do presente
	MOVB R1, [R0]            ; guarda essa coordenada em R1

	MOV R5, objeto_atual     ; passa o endereco da word que contem o argumento da funcao pinta_objeto para R5
	MOV R6, prenda_objeto    ; passa o endereco da string prenda_objeto para R6
	MOV [R5], R6             ;

	MOV R2, LEFT             ; move a prenda para a esquerda
	CALL mover               ;

	MOVB [R0], R1            ; este bloco de codigo atualiza as coordenadas da prenda
	SUB R0, 1                ;
	MOVB [R0], R7            ;

	ADD R0, 2                ; este bloco de codigo vai buscar as coordenadas da arma
	MOVB R7, [R0]            ; R7-->x
	ADD R0, 1                ; R1-->y
	MOVB R1, [R0]            ;

	MOV R6, kunai_objeto     ; muda o argumento da fun�ao pinta_objeto para a string da arma
	MOV [R5], R6             ;

	CALL mover               ; move a arma para a esquerda

	MOVB [R0], R1            ; este bloco de codigo atualiza as coordenadas da prenda
	SUB R0, 1                ;
	MOVB [R0], R7            ;

	MOV R6, ninja_string     ; repoe o argumento do pinta_objeto para ninja
	MOV [R5], R6             ;

POP R0
POP R5
POP R6
RET

mover:
PUSH R0
PUSH R2
PUSH R4
	MOV R0, pinta_limpa        ;
	MOV R8, 0				   ;
	MOVB [R0], R8               ;
	CALL ninja                 ;

	CMP R2, UP
	JZ move_up
	CMP R2, DOWN
	JZ move_down
	CMP R2, LEFT
	JZ move_left
	JMP fim_mover
		move_up:
		CMP R1, 0
		JZ fim_mover
		SUB R1, 1

		JMP fim_mover
		move_down:
		ADD R1, 1
		JMP fim_mover
		move_left:
		SUB R7, 1

	fim_mover:

	MOVB [R4], R1
	MOV R0, pinta_limpa        ;
	MOV R2, 1				   ;
	MOVB [R0], R2
	CALL ninja
POP R4
POP R2
POP R0
	RET

gerador_ninjas:
PUSH R3
PUSH R4
PUSH R5

	MOV R4,posicao_objeto
	CMP R3, 1
	JZ gerador_1ponteiro
	CMP R3, 2
	JZ gerador_2ponteiro
	CMP R3, 3
	JZ gerador_3ponteiro
	CMP R3, 4
	JZ gerador_4ponteiro
    JMP fim_gerador
		gerador_1ponteiro:
			MOV R7, 0
			MOVB R5,[R4]
			MOV R1, R5
			JMP fim_gerador

		gerador_2ponteiro:
			MOV R7, 4
			ADD R4, 1
			MOVB R5, [R4]
			MOV R1, R5
			JMP fim_gerador

		gerador_3ponteiro:
			MOV R7, 8
			ADD R4, 2
			MOVB R5,[R4]
			MOV R1, R5
			JMP fim_gerador

		gerador_4ponteiro:
			MOV R7, 12
			ADD R4, 3
			MOVB R5, [R4]
			MOV R1, R5

    fim_gerador:
POP R5
POP R4
POP R3
		RET

atualizador_ninjas:

PUSH R3
PUSH R4
PUSH R5

	MOV R4,posicao_objeto
	CMP R3, 1
	JZ atualizador_ninjas1
	CMP R3, 2
	JZ atualizador_ninjas2
	CMP R3, 3
	JZ atualizador_ninjas3
	CMP R3, 4
	JZ atualizador_ninjas4
    JMP fim_atualizador
		atualizador_ninjas1:
			MOV R7, 0
			MOVB [R4], R1
			;MOV R1, R5
			JMP fim_atualizador

		atualizador_ninjas2:
			MOV R7, 4
			ADD R4, 1
			MOVB [R4], R1
			;MOV R1, R5
			JMP fim_atualizador

		atualizador_ninjas3:
			MOV R7, 8
			ADD R4, 2
			MOVB [R4], R1
			;MOV R1, R5
			JMP fim_atualizador

		atualizador_ninjas4:
			MOV R7, 12
			ADD R4, 3
			MOVB [R4], R1
			;MOV R1, R5

    fim_atualizador:
POP R5
POP R4
POP R3
		RET

ninja:
        PUSH R0
		PUSH R1
		PUSH R2
		PUSH R3
		PUSH R4
		PUSH R5
		PUSH R6
		PUSH R7
		PUSH R9
	MOV R8, objeto_atual
	MOV R0, [R8]
	MOVB R2, [R0]
	ADD R0, 1
	MOVB R3, [R0]
	MOV R6, 0
	MOV R4, 0
	MOV R9, R7

    objeto_linha:
		CMP R4, R2
		JZ fim_objeto
		JMP objeto_coluna
		linha_aux:
			ADD R4, 1
			ADD R1, 1
		    JMP objeto_linha

	objeto_coluna:
			ADD R0, 1
			MOVB R5, [R0]
			CMP R5, 0
			JZ coluna_aux
			CALL pinta_um_ponto

		coluna_aux:
			ADD R6, 1
			ADD R7, 1
			CMP R6, R3
			JNZ objeto_coluna
			MOV R6, 0
			MOV R7, R9
	        JMP linha_aux
	    fim_objeto:
		POP R9
		POP R7
		POP R6
		POP R5
		POP R4
		POP R3
		POP R2
		POP R1
		POP R0
		RET

; *********************************************************************
; * Funcao Picasso
; * Descricao - pinta um ponto no screen recebendo as coordenadas (x,y)
; *
; *********************************************************************


pinta_um_ponto:
    PUSH R0
		PUSH R1
		PUSH R2
		PUSH R3
		PUSH R4
		PUSH R7
		PUSH R8
		PUSH R9
		PUSH R10
			MOV R10, R1                 ; Valor de y
			MOV R9, R7                  ; Valor de x
			MOV R8, R9                  ;
			MOV R0, 4                   ;
			MUL R10, R0                 ; Multiplica o valor de y por 4
			MOV R0, 8                   ;
			DIV R9, R0                  ; Divide o valor de x por 8
			MOV R2, PIXSCREEN          ; Endereco do pixel screen
			ADD R2, R10                 ;
			ADD R2, R9                  ;

			MOD R8,R0
			MOV R0, mascra_pix
			ADD R0, R8
			MOVB R8, [R0]
			MOVB R3, [R2]
			MOV R4, pinta_limpa
			MOVB R0, [R4]
			CMP R0, 1
			JNZ limpa
			OR R8, R3
			JMP fim_pinta_limpa
			limpa:
			NOT R8
			AND R8, R3
			fim_pinta_limpa:
			MOVB [R2],R8
		POP R10
		POP R9
		POP R8
		POP R7
		POP R4
		POP R3
		POP R2
		POP R1
		POP R0

			RET
inicializa_ecra:
        PUSH R0
		PUSH R1
		PUSH R2
		PUSH R3
		PUSH R4
		PUSH R5
		PUSH R7
		PUSH R8
		PUSH R9
		PUSH R10
			MOV R0, PIXSCREEN
			MOV R2, mascra_pix
			MOV R8, 8
			ADD R2, R8
			MOVB R3,[R2]
			MOV R4, 1
		pinta_ecra:
			MOVB [R0], R3
			MOV R5, 807FH
			CMP R0, R5
			JZ  fim_incializa�ao

			ADD R0, 1
			MOV R9, 4
			MOV R7, R0
			MOD R7, R9
			JZ rotate
			JMP pinta_ecra

		rotate:
			ADD R4, 1
			MOV R10, 2
			MOD R4, R10
			JZ  ROTL
			JMP ROTR
		ROTL:
			MOV R9, R3
			ROL R9, 1
			MOV R3, R9
			JMP pinta_ecra

		ROTR:
			MOV R9, R3
			ROR R9, 1
			MOV R3, R9
			JMP pinta_ecra
		fim_incializa�ao:
		POP R10
		POP R9
		POP R8
		POP R7
		POP R5
		POP R4
		POP R3
		POP R2
		POP R1
		POP R0
		RET
limpa_screen:
	PUSH R0
    PUSH R1
	PUSH R2
		MOV R0, PIXSCREEN
		MOV R1, 8080H
		MOV R2, 0H
	limpa_screen1:
		MOVB [R0], R2
		ADD R0, 1
		CMP R0, R1
		JNZ limpa_screen1
	POP R2
	POP R1
	POP R0

		RET




; ******************************************************************************************
; * Leitura Do Teclado
; ******************************************************************************************
ler_teclado:
		PUSH R0
		PUSH R1
		PUSH R2

		PUSH R4
		PUSH R5
		PUSH R6
		PUSH R8
		PUSH R9
		PUSH R10


; ******************************************************************************************
; *  Teclado
; *
; * Descricao - ciclo que verifica se alguma tecla foi clicada
; *
; ******************************************************************************************
    MOV  R2, TEC_LIN              ; endere�o do perif�rico das linhas
    MOV  R3, TEC_COL              ; endere�o do perif�rico das colunas
    MOV  R4, DISPLAYS             ; endere�o do perif�rico dos displays
    MOV  R9, 0                    ; acumulador display
	MOV  R10,0		              ; registo auxiliar



    MOV  R1, 0H
    MOVB [R4], R1                 ; escreve linha a coluna a zero nos displays
ciclo:
	MOV  R1, LINHA                ; testar a linha 4

espera_tecla:
    MOVB [R2], R1                 ; escrever no perif�rico de sa�da (linhas)
    MOVB R0, [R3]                 ; ler do perif�rico de entrada (colunas)
    MOV R5, 0FH
	AND R0, R5
	CMP  R0, 0                    ; h� tecla premida?
    JZ   outras_linhas            ; se nenhuma tecla premida, repete
    JNZ  contador_linhas


ha_tecla:
	MOVB [R2], R1                 ; escrever no perif�rico de sa�da (linhas)
    MOVB R0, [R3]      	          ; ler do perif�rico de entrada (colunas)
    CMP R0, 0                     ; h� tecla premida?
    JNZ ha_tecla                  ; se ainda houver uma tecla premida, espera at� n�o haver
	JMP ciclo                     ; repete ciclo

outras_linhas:
	SHR R1, 1                     ; passa para linha seguinte
	JNZ espera_tecla
	JMP fim_teclado               ; processamento ir

contador_linhas:
	MOV R5, R1                    ; troca de registos linha
	MOV R6, R0                    ; troca de registos coluna
	MOV R3, 0
ciclo_linhas:
	ADD R3, 4                     ; converte a linha seguinte com o numero em hexa
	SHR R5, 1                     ; conta zeros linhas
	JNZ ciclo_linhas              ; se nao for zero repete
	SUB R3, 4
ciclo_colunas:
    ADD R3, 1                     ; converte a coluna seguinte com o numero em hexa
	SHR R6, 1	                  ; conta zeros coluna
	JNZ ciclo_colunas             ; se nao for zero repete
	SUB R3, 1
	JMP return_teclado
fim_teclado:
		MOV R3, 00FFH
return_teclado:

		POP R10
		POP R9
		POP R8
		POP R6
		POP R5
		POP R4

		POP R2
		POP R1
		POP R0

	RET
; ********************************************************************************************
; * Processamento Das Teclas
; *
; * Descri��o - Seleciona qual das funcoes das teclas ir� ser executada.
; *			  - Chama as funcoes que aplicam movimentos aos ninjas, iniciam e terminam o programa.
; *
; *
; * Recebe - R3: Com o valor da tecla clicada
; ********************************************************************************************

processamento:
	PUSH R5
	PUSH R6
	PUSH R3
	PUSH R8

	MOV R5, ultima_tecla
	MOVB R6, [R5]                ;
	CMP R6, R3
	JZ processamento_return
	MOVB [R5], R3

	MOV R5,00FFH
	CMP R3,R5
	JZ  processamento_return

	MOV R8, etiquetas_teclas
	SHL R3, 1
	ADD R8, R3

	MOV R6, [R8]
	CALL R6
	processamento_return:

	POP R8
	POP R3
	POP R6
	POP R5
		RET

limitador_soma:
	MOV R9,63H                    ; poe o acumulador do display a 63H

; *********************************************************************************************
; * Display
; *********************************************************************************************

imp_display:

	conversao_hexadecimal:
		MOV R7, 10
		MOV R5, 10H
		MOV R8, -1

		MOV R0, R9                ; passa o valor do acumulador do display para um novo registo
		DIV R0, R7                ; faz a  conversao do display das dezenas para decimal
		MUL R0, R5                ; faz a conversao do display das dezenas para decimal

		MOV R6, R9                ; passa o valor do acumulador do display para um novo registo
		DIV R6, R7                ; faz a conversao do display das unidades para decimal
		MUL R6, R7                ; faz a conversao do display das unidades para decimal
		MUL R6, R8                ; faz a conversao do display das unidades para decimal
		ADD R6, R9                ; faz a conversao do display das unidades para decimal

		ADD R0, R6                ; junta o valor convertido das dezenas ao das unidades

 	MOVB [R4],R0                  ; passa o valor convertido para o display
	JMP ha_tecla                  ; recome�a o ciclo; ***************************************************************************************



RET

funcao_0:
PUSH R2
PUSH R3
PUSH R9
	MOV R3, 1                     ; aponta para o ninja que ira mover (neste caso o primeiro)
	CALL gerador_ninjas           ; chama a funcao que aponta para os ninjas
    MOV R2, UP                    ; seleciona o movimento para cima
	MOV R9, 0                     ;
	CMP R1, R9                    ; verifica se ja chegou ao limite
	JZ fim_0                      ; se chegou sai da funcao
	CALL mover                    ; chama a funcao que aplica o movimento
	CALL atualizador_ninjas
	fim_0:
POP R9
POP R3
POP R2
	RET

funcao_1:
PUSH R2
PUSH R3
PUSH R9
	MOV R3, 2                     ; aponta para o ninja que ira mover (neste caso o segundo)
	CALL gerador_ninjas           ; chama a funcao que aponta para o ninja a mover
    MOV R2, UP                    ; seleciona o movimento para cima
	MOV R9, 0                     ;
	CMP R1, R9                    ; verifica se ja chegou ao limite
	JZ fim_1                      ; se chegou sai da funcao
	CALL mover                    ; chama a funcao que aplica o movimento
	CALL atualizador_ninjas
	fim_1:
POP R9
POP R3
POP R2
	RET

funcao_2:
PUSH R2
PUSH R3
PUSH R9
	MOV R3, 3                     ; aponta para o ninja que ira mover (neste caso o terceiro)
	CALL gerador_ninjas           ; chama a funcao que aponta para o ninja a mover
    MOV R2, UP                    ; seleciona o movimento para cima
	MOV R9, 0                     ;
	CMP R1, R9                    ; verifica se ja chegou ao limite
	JZ fim_2                      ; se chegou sai da funcao sem aplicar movimento
	CALL mover                    ; nao chegou, chama a funcao que aplica o movimento
		CALL atualizador_ninjas
	fim_2:
POP R9
POP R3
POP R2
	RET

funcao_3:
PUSH R2
PUSH R3
PUSH R9
	MOV R3, 4                     ; aponta para o ninja que ira mover (neste caso o quarto)
	CALL gerador_ninjas           ; chama a funcao que aponta para o ninja a mover
    MOV R2, UP                    ; seleciona o movimento ara cima
	MOV R9, 0                     ;
	CMP R1,R9                	  ; verifica se ja chegou ao limite
	JZ fim_3                      ; se chegou sai da funcao sem aplicar o movimento
	CALL mover                    ; se nao chegou chama a funcao que aplica o movimento
	CALL atualizador_ninjas
fim_3:
POP R9
POP R3
POP R2
	RET
                                  ; as funcoes abaixo seguem a logica das primeiras, com a excepcao de que o movimento e para baixo
funcao_4:
PUSH R2
PUSH R3
PUSH R9
	MOV R3, 1
	CALL gerador_ninjas
	MOV R2,DOWN
	MOV R9, 27
	CMP R1, R9
	JZ fun_4_aux
		CALL mover
	    CALL atualizador_ninjas
	JMP fim_4
	fun_4_aux:
		MOV R0, pinta_limpa        ;
		MOV R8, 0				   ;
		MOVB [R0], R8
		CALL ninja

fim_4:
POP R9
POP R3
POP R2
	RET

funcao_5:
PUSH R2
PUSH R3
PUSH R9
	MOV R3, 2
	CALL gerador_ninjas
	MOV R2, DOWN
	MOV R9, 27
	CMP R1, R9
	JZ fun_5_aux
		CALL mover
		CALL atualizador_ninjas
	JMP fim_5
	fun_5_aux:
		MOV R0, pinta_limpa        ;
		MOV R8, 0 				   ;
		MOVB [R0], R8
		CALL ninja
fim_5:
POP R9
POP R3
POP R2
	RET


funcao_6:
PUSH R2
PUSH R3
PUSH R9
	MOV R3, 3
	CALL gerador_ninjas
	MOV R2, DOWN
	MOV R9, 27
	CMP R1, R9
	JZ fun_6_aux
		CALL mover
		CALL atualizador_ninjas
	JMP fim_6
	fun_6_aux:
		MOV R0, pinta_limpa        ;
		MOV R8, 0				   ;
		MOVB [R0], R8
		CALL ninja
fim_6:
POP R9
POP R3
POP R2
	RET

funcao_7:
PUSH R2
PUSH R3
PUSH R9
	MOV R3, 4
	CALL gerador_ninjas
	MOV R2, DOWN
	MOV R9, 27
	CMP R1, R9
	JZ fun_7_aux
		CALL mover
		CALL atualizador_ninjas
	JMP fim_7
	fun_7_aux:
		MOV R0, pinta_limpa        ;
		MOV R8, 0				   ;
		MOVB [R0], R8
		CALL ninja
fim_7:
POP R9
POP R3
POP R2
	RET


funcao_8:
	RET

funcao_9:
	RET

funcao_A:
	RET

funcao_B:
	RET

funcao_C:
	PUSH R3
	PUSH R6
	PUSH R4
	PUSH R0
	PUSH R8
	PUSH R5

	MOV R4, posicao_objeto
	MOV R6, 3
	reposicao_ninjas_C:
	MOV R5, 10
	MOVB [R4], R5
	ADD R4, 1
	CMP R6, 0
	JZ funcao_C_aux2
	SUB R6, 1
	JMP reposicao_ninjas_C

	funcao_C_aux2:
	MOV R3, 0
	CALL limpa_screen
	MOV R0, pinta_limpa        ;
	MOV R8, 1				   ;
	MOVB [R0], R8
	 funcao_C_aux:
		ADD R3, 1
		CALL gerador_ninjas
		CALL ninja
		CMP R3, 4
		JNZ funcao_C_aux

	POP R5
	POP R8
	POP R0
	POP R4
	POP R6
	POP R3
	RET
funcao_D:


	RET

funcao_E:
 CALL limpa_screen
 CALL inicializa_ecra
	RET

funcao_F:
	RET
