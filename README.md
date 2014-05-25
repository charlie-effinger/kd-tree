Overview and Use:

The Fortran program 'kdtree' allows a user to create a k-d tree from scratch and
probe it for its contents. The user must provide a node count that is greater 
than 0. Then, the user must give 'node count' 3-dimensional points, although
a different dimension can be selected by editing the global constant DIMENSIONS 
in kdtree.pas. (EXTRA CREDIT) The points can be separated by spaces, newlines, 
or tabs. Every three consecutive points will be counted.

For example, the input:
	
	2
	1 2 3
	2
	3	4

will create 2 nodes, (1,2,3) and (2,3,4).

Once the user has entered 'node count' points, the program will construct the 
tree. Once this is complete, the user must input a 'probe count' integer which 
must be greater than 0. The user will then be able to enter 'probe count' 3-d 
points. The program will then determine which leaf each point would exist in if
it were in the k-d tree. The program will print out each probe and the bucket of
probes at the leaf it would exist in. The program will then exit. 



Compilation and Running Instructions:

The kdtree program must be compiled in a Unix environment. There is a Makefile
in the same directory as this README file. One simply has to issue the following
command: 

	make

The compiler should produce a linker warning that states:

	/usr/bin/ld: warning: link.res contains output sections

This warning is benign and should be ignored. Further information can be found
at: http://www.freepascal.org/faq.var#unix-ld219. 

Once the program has been compiled, it can be run. To run with user input via 
the terminal, a user can issue the following command.

	./kdtree

Input redirection can be achieved in multiple ways. If the user's input file is
named 'test.txt', the following command be used to redirect the input:

	make test

Otherwise, any other file name can be redirected using the following command:

	./kdtree < filename

Output will be printed to the user's terminal unless otherwise specified. In 
order to redirect the output of the program, the user can use the following 
commands.

	./kdtree > output.txt
		OR
	make test > output.txt

To delete the executable file, the user can use the following command:

	make clean
