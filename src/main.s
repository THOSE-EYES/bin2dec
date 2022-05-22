#    Licensed to the Apache Software Foundation (ASF) under one
#    or more contributor license agreements.  See the NOTICE file
#    distributed with this work for additional information
#    regarding copyright ownership.  The ASF licenses this file
#    to you under the Apache License, Version 2.0 (the
#    "License")# you may not use this file except in compliance
#    with the License.  You may obtain a copy of the License at
#    
#     http://www.apache.org/licenses/LICENSE-2.0
#    
#    Unless required by applicable law or agreed to in writing,
#    software distributed under the License is distributed on an
#    "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
#    KIND, either express or implied.  See the License for the
#    specific language governing permissions and limitations
#    under the License.


.section .data
test:
    .byte 16,12

.section .bss
    .lcomm buffer 12 * 8
    .lcomm output 29 * 8

.section .text

    .global _start

_start:

loop:
    # Clear the result register
    xor %rax, %rax
    
    # Clear the buffer
    movabs $buffer, %rsi
    mov $12, %rdi
    call clear

    # Read data from STDIN
    movabs $buffer, %rsi
    mov $0xc,%rdi
    call read

    # Look for the terminating character
    cmp $0x0,%rax
    jl end
    je end

    # Reverse the order of bytes
    movabs $buffer, %rsi 
    mov $0xc,%edi
    call reverse

    # Iterating from the end of the output buffer
    mov $29, %rcx

dec_loop:
    # Get the last integer from the input
    movabs $buffer, %rsi
    mov $12, %edi
    mov $10, %edx
    call divide

    # Store the ASCII code of the result into the output buffer
    add $48, %al
    movb %al, output - 1(%rcx)

    # Decrement the counter
    dec %rcx

    # If there are symbols, continue
    cmp $0, %rcx
    jne dec_loop

# End of the dec_loop
    # Print the output buffer to STDOUT
    movabs $output, %rsi
    mov $29, %rdi
    call print

    # Print the ending '\n' character
    movb $10, output
    movabs $output, %rsi
    mov $1, %rdi
    call print

    # Get to the start of the loop
    jmp loop 

# End of the loop

end:
    # Exit the process (Linux 64-bit version)
    mov $60, %rax
    xor %rdi, %rdi
    syscall

#
# @brief : Divide a large integer and get the reminder
#
# @param rsi the buffer where to put the result
# @param rdi the size of the buffer
# @param rdx the divisor (one byte max)
# @return rax the reminder of the division
#
divide:
    # Prolog of the function
    push %rbp
    mov %rsp, %rbp

    # Save the registers
    push %rcx
    push %rbx

    # Prepare the divisor
    and $0xFF, %rdx
    mov %rdx, %rbx

    # Prepare the high bits for division
    xor %rax, %rax

    # Prepare the low bits for division
    movb (%rsi), %al

    # The first byte should be cleared
    mov $0, %rcx

divide_loop:
    # Execute the division
    div %bl

    # Store the result back in the buffer
    mov %al, (%rsi, %rcx, 1)
    inc %rcx

    # Prepare the dividend for the next iteration
    mov (%rsi, %rcx, 1), %al

    # If the counter is less than size, get to the start of the loop
    cmp %rdi,%rcx
    jl divide_loop

# End of divide_loop
    # Save the remainder to return it
    mov %ah,%al
    xor %ah,%ah

    # Restore the registers
    pop %rbx
    pop %rcx

    # Epilog of the function
    mov %rbp, %rsp
    pop %rbp

    ret 

#
# @brief : Read data from STDIN
#
# @param rsi the buffer where to put the result
# @param rdi amount of bytes to read
#
read:
    # Prolog of the function
    push %rbp
    mov %rsp, %rbp

    # Call the system function to print the data
    mov %rdi, %rdx
    xor %rdi, %rdi
    xor %rax, %rax
    syscall

    # Epilog of the function
    mov %rbp, %rsp
    pop %rbp

    ret

#
# @brief : Write data to STDOUT
#
# @param rsi the buffer where the data lies
# @param rdi amount of bytes to write
#
print:
    # Prolog of the function
    push %rbp
    mov %rsp, %rbp

    # Call the system function to write the data to STDOUT
    mov %rdi, %rdx
    mov $1, %rax
    mov $1, %rdi
    syscall

    # Epilog of the function
    mov %rbp, %rsp
    pop %rbp

    ret

#
# @brief : Clear the buffer
#
# @param rsi the buffer to clear
# @param rdi the size of the buffer
#
clear:
    # Prolog of the function
    push %rbp
    mov %rsp, %rbp

    # Save the registers
    push %rcx

    # Prepare the counter
    xor %rcx, %rcx

clear_loop:
    # Clear the bit in the buffer
    movb $0x0, (%rsi, %rcx, 1)
    inc %rcx

    # If it is not the end of the buffer, loop
    cmp %rdi, %rcx
    jl clear_loop

    # Restore the registers
    pop %rcx

    # Epilog of the function
    mov %rbp, %rsp
    pop %rbp

    ret

#
# @brief : Reverse the byte order
#
# @param rsi the buffer to reverse
# @param rdi the size of the buffer
#
reverse:
    # Prolog of the function
    push %rbp
    mov %rsp, %rbp

    # Save the registers
    push %rax
    push %rcx
	push %rdx

    # Prepare the counter
    xor %rcx, %rcx

reverse_loop:
    # Store the values of elements
    mov    (%rsi,%rcx,1),%al
    mov    %rdi,%rdx
    sub    %rcx,%rdx
    mov    -1(%rsi,%rdx,1),%ah

    # Move the elements to the new places
    mov    %ah,(%rsi,%rcx,1)
    mov    %al,-1(%rsi,%rdx,1)
    inc    %rcx

    # If it is not the end of the buffer, loop
    mov %rdi,%rax
    shr %rax
    cmp %rax,%rcx
    jl reverse_loop

    # Restore the registers
	pop %rdx
    pop %rcx
    pop %rax

    # Epilog of the function
    mov %rbp, %rsp
    pop %rbp

    ret
