
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>
#include <syslog.h>

int main (int argc, char *argv[] )
{
	if (argc == 3)
	{
		char *writefile = argv[1];
		char *writestr = argv[2];
		//printf("File path : %s\n",writefile);
		//printf("Write string : %s\n",writestr);
		openlog (NULL,0,LOG_USER);
		syslog(LOG_DEBUG,"Writing %s to %s", writestr, writefile);
		
		//Crea el fichero
		int fd;
		fd = creat(writefile, 0644);
		if (fd == -1)
			//perror("creat");
			syslog(LOG_ERR,"ERROR: could not create file\n");
			
		//Escribe el contenido en el fichero
		size_t count;
		ssize_t nr;
		
		count = strlen(writestr);
		nr = write (fd, writestr, count);
		if (nr == -1)
			//printf("ERROR: could not write file");
			syslog(LOG_ERR,"ERROR: could not write file\n");
		else if( nr != count)
			syslog(LOG_ERR,"ERROR: could not write file\n");
			
		//Cierra el fichero
		if (close (fd) == -1)
			perror ("close");
	}
	else
	{
		syslog(LOG_ERR,"ERROR: invalid number of arguments\n");
		//printf("ERROR: invalid number of arguments\n");
		//printf("Total number of arguments should be 2\n");
		return 1;
	}
}
