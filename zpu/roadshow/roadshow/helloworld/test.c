/* zpu-elf-gcc -g -Wl,--relax test.c -phi -o hello.elf */
int main(int argc, char **argv)
{
	for (;;)
	{
		int c;
		printf("Hello world!\n");
		printf("Press any key!\n");
		c=inbyte();
		printf("You pressed (%02x) '%c'\n", c, c);
	}
}
