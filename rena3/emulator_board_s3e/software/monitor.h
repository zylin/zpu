/*
 * $Date$
 * $Author$
 * $Revision$
 */

#ifndef MONITOR_H
#define MONITOR_H

#include <types.h>

////////////////////////////////////////////////////////////
//  monitor definitions

#define MAX_COMMANDS       (20)
#define MAX_COMMAND_LENGTH (10)
#define MAX_HELP_LENGTH    (40)
#define BUFFER_LENGTH      (60)

#define CR                 '\r'
#define LF                 '\n'
#define BS                 '\b'
#define DEL                (0x7f)

#define SOH                (0x01)
#define EOT                (0x04)
#define ACK                (0x06)
#define NAK                (0x15)
#define CAN                (0x18)
#define EOF                (0x1a)


////////////////////////////////////////////////////////////
//  monitor variables

typedef uint32_t (*command_ptr_t) (void);

extern char          command_list[MAX_COMMANDS][MAX_COMMAND_LENGTH];
extern char          help_list   [MAX_COMMANDS][MAX_HELP_LENGTH];
extern command_ptr_t command_ptr_list[MAX_COMMANDS];

extern uint8_t       buffer[BUFFER_LENGTH];
extern uint8_t       command_number;
extern uint8_t       buffer_position;
extern command_ptr_t exec_function;


////////////////////////////////////////////////////////////
//  monitor functions

void monitor_init( void);
void monitor_add_command(char* new_command, char* new_help, command_ptr_t new_command_ptr, int8_t new_command_nbr);
void monitor_prompt( void); 
void process_buffer( void);
extern uint8_t monitor_run;

void monitor_mainloop( void);
void monitor_input(uint8_t c);
char* monitor_get_argument_string(uint8_t num);
int      monitor_get_argument_int(uint8_t num);
uint32_t monitor_get_argument_hex(uint8_t num);

uint32_t help_function( void);

#endif // MONITOR_H
