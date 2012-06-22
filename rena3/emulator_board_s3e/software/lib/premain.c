/*
extern char _data_start;
extern char _data_end;
extern char _data_start_rom;
*/


_realloc_r() {}
_calloc_r() {}
_malloc_r() {}
_free_r() {}

void _premain( void)
{
/*
    int count;
    char *dst = (char *) &_data_start;
    char *src = (char *) &_data_start_rom;

    if ( (&_data_start) != (&_data_start_rom) )
    {
        count = &_data_end - &_data_start; 
        while (count--) 
        {
            *dst++ = *src++;
        }
    }
*/

    main();
}
