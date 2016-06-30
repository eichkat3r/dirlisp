# dirlisp
## a directory structure based programming language

### Intro
dirlisp is a Lisp dialect which compiles to a directory structure that can later
be evaluated. The compiler and the evaluator are entirely written in plain bash
script.
This is actually a proof of concept implementation not intended to be used
for functional applications.

### Usage
Call

```bash
$ ./convert.sh "<program>"
```

to create a directory structure for <program>.
An example program would be:

```lisp
(+ 1 2 (* 3 (/ 4 (- 6 5))))
```

The program will be stored in a directory called a.out in the working
directory.
To specify a different output dir (which will be overwritten!), the
-o option can be used. For example:

```bash
$ ./convert.sh "(+ 1 2 (* 3 (/ 4 (- 6 5))))" -o testprog
```

The compiled program can be evaluated with the eval script:

```bash
$ ./eval.sh testprog
```

which will print the result on the command line.

