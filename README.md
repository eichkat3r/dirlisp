# DirRacket
## a directory structure based programming language

### Intro
DirRacket is a Lisp dialect which compiles to a directory structure that can later
be evaluated. The "compiler" and the evaluator are entirely written in plain bash
script.

### Usage
Call

```
./convert.sh "<program>"
```

to create a directory structure for <program>.
An example program would be:

```
(+ 1 2 (* 3 (/ 4 (- 6 5))))
```

The program will be stored in a directory called a.out in the working
directory.
To specify a different output dir (which will be overwritten!), the
-o option can be used. For example:

```
./convert.sh "(+ 1 2 (* 3 (/ 4 (- 6 5))))" -o testprog
```

The compiled program can be evaluated with the eval script:

```
./eval.sh testprog
```

which will print the result on the command line.


### TODO
* more commands
  * file/dir operations!!!
  * more maths stuff (sqrt, modulo, logarithms,...)
  * string ops (concatenation,...)
* exception handling, syntax checking
* lambda functions, functional programming stuff (map, fold, filter)
* macros, includes
