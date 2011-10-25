/*
 * Small test program to check GPIOs 
 * 
 * LED chaser until keypress
 *
 */

// addresses refer to Phi memory layout
#define GPIO_DATA   *((volatile unsigned int *) 0x080a0004)
#define GPIO_DIR    *((volatile unsigned int *) 0x080a0008)


#define BUTTON_EAST  (3)
#define BUTTON_NORTH (2)
#define BUTTON_SOUTH (1)
#define BUTTON_WEST  (0)


#define bit_is_set(var, bit)              ((var) & (1 << (bit)))
#define bit_is_clear(var, bit)            ((!(var)) & (1 << (bit)))
#define loop_until_bit_is_set(var, bit)   do { } while (bit_is_clear(var, bit))
#define loop_until_bit_is_clear(var, bit) do { } while (bit_is_set(var, bit))


void led_test( void)
{
    unsigned char runs;
    unsigned char leds;

    runs = 1;
    leds = 0x01;

    while( runs)
    {
        // output
        GPIO_DATA = leds;

        // read button status
        if bit_is_set(GPIO_DATA, BUTTON_NORTH) 
        {
            runs = 0;
        }

        // LED chaser
        leds = leds << 1;
        if (leds == 0)
        { 
            leds = 0x01;
        }
    }
}


void header_test( void)
{
    // this test is special for the SP601 header connector
    // check the output in simulation
    GPIO_DATA = 0x00550000;
    GPIO_DIR  = 0xff00ffff;
    GPIO_DATA = 0x00aa0000;
    GPIO_DIR  = 0xffffffff;
}


int main(int argc, char **argv)
{

    led_test();
    header_test();

    abort();
}
