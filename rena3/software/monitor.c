/*
 * $HeadURL: https://svn.fzd.de/repo/concast/FWF_Projects/FWKE/beam_position_monitor/software/test/monitor.c $
 * $Date: 2011-09-06 14:27:41 +0200 (Di, 06. Sep 2011) $
 * $Author: lange $
 * $Revision: 1242 $
 */

#include "monitor.h"

////////////////////////////////////////////////////////////
//  monitor functions

static char          command_list[MAX_COMMANDS][MAX_COMMAND_LENGTH];
static char          help_list   [MAX_COMMANDS][MAX_HELP_LENGTH];
static command_ptr_t command_ptr_list[MAX_COMMANDS];

uint8_t       buffer[BUFFER_LENGTH];
uint8_t       command_number;
uint8_t       buffer_position;
command_ptr_t exec_function;



/*
    reset some values for monitor
*/
void monitor_init( void)
{
    buffer_position = 0;
    command_number  = 0;
    exec_function   = 0;
}


/*
    add an command to the monitor list
*/
void monitor_add_command(char* new_command, char* new_help, command_ptr_t new_command_ptr) 
{
    if (command_number < MAX_COMMANDS)
    {
        strcpy( command_list[ command_number], new_command);
        strcpy( help_list[    command_number], new_help);
        command_ptr_list[ command_number] = new_command_ptr;
        command_number++;
    }
    else
    {
        putstr("ERROR: too much commands.\n");
    }
}


/*
    print out a nice promt
*/
void monitor_prompt( void) { 
    putstr("> ");
}


/*
    check the line buffer content and search command
*/
void process_buffer( void) {
    uint8_t command_index;
    uint8_t i;

    i = 0;

    while ( !((buffer[i] == ' ') || (buffer[i] == 0)) ) i++;
    
    if (!i) {
        monitor_prompt();
        return;
    }

    for ( command_index = 0; command_index < command_number; command_index++) {
        if ( !strncmp( command_list[ command_index], buffer, i) ) {
            exec_function = command_ptr_list[ command_index];
            return;
        }
    }
    putstr("command not found.\n");
    monitor_prompt();
}


uint8_t monitor_run;


/*
    execute the command
*/
void monitor_mainloop( void) 
{
    uint32_t return_value;

    // execute selected function 
    if (exec_function) {
        return_value = exec_function();
        exec_function = 0;
        
        // print return value (as hex)
        if (return_value > 0)
        {
            putstr("0x");
            if (return_value > 0xffff)
                puthex(32, return_value);
            else
                if (return_value > 0xff)
                    puthex(16, return_value);
                else
                    puthex(8, return_value);
            putchar('\n');
        }
        
        monitor_prompt();
    }
}


/*
    add an character to the monitor line buffer
*/
void monitor_input(uint8_t c) {
   
    // carrige return
    if (c == CR) {
        putchar( LF);
        buffer[ buffer_position++] = 0;
        process_buffer();
        buffer_position = 0;

    // backspace or delete
    } else if ( (c == BS) || (c == DEL)) {
        if (buffer_position > 0) {
            putchar( BS);
            putchar( ' ');
            putchar( BS);
            buffer_position--;
        }
    } else {
        // add to buffer
        if ((c >= 0x20) && (buffer_position < (BUFFER_LENGTH-1))) {
            putchar( c);
            buffer[ buffer_position++] = c;
        }
    }
}


/*
    parse the argument as string
*/
char* monitor_get_argument_string(uint8_t num)
{
    uint8_t index;
    uint8_t arg;

    // example line:
    // "   command   arg1   arg2 arg3 "

    index = 0;

    // search for first char (non space)
    while (( buffer[ index] != 0) && (buffer[ index] == ' ')) index++;

    for ( arg = 0; arg < num; arg++)
    {
        // next space 
        while (( buffer[ index] != 0) && (buffer[ index] != ' ')) index++;
        // next non space
        while (( buffer[ index] != 0) && (buffer[ index] == ' ')) index++;
    }
    return &buffer[ index];
}


/*
    parse the argument as integer
*/
int monitor_get_argument_int(uint8_t num)
{
    char *endptr;
    return strtol( monitor_get_argument_string(num), &endptr, 0);
}


/*
    parse the argument as hex number
*/
uint32_t monitor_get_argument_hex(uint8_t num)
{
    char *endptr;
    return strtoul( monitor_get_argument_string(num), &endptr, 16);
}



/*
    print all avalible functions as help screen
*/
uint32_t help_function( void)
{
    uint8_t command_index;
    uint8_t i;

    putchar( LF);
    putstr("supported commands:\n\n");
    for ( command_index = 0; command_index < command_number; command_index++) {
        putstr( command_list[ command_index]); 
        if (strlen( help_list[ command_index]) > 0 )
        {
            for (i = strlen( command_list[ command_index]); i < MAX_COMMAND_LENGTH; i++) putchar(' ');
            putstr( " - ");
            putstr( help_list[ command_index]); 
        }
        putchar('\n');
    }
    putchar( LF);
    return command_number;
}


