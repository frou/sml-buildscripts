
SML build scripts
==================

A set of scripts to compile and run Standard ML programs defined in
`.mlb` files.

All of these are Bash scripts for Unix-like systems, apart from one
PowerShell script for Windows.


Motivation and the polybuild script
-----------------------------------

The `.mlb` file format (http://mlton.org/MLBasis) is, at its most
basic, a list of the input files that constitute a program. This
format is associated with the MLton compiler, and a `.mlb` file can be
compiled using MLton without any additional scripting:

```
 $ mlton file.mlb
```

But MLton is rather slow to run, for development use, and it's a good
idea to test code with more than one compiler.

The script `polybuild` therefore takes a `.mlb` file and builds an
executable from it using the Poly/ML compiler:

```
 $ polybuild file.mlb
 $ ./file
```

which compiles much faster and still produces a reasonably quick
native executable.


Build-and-run and build-and-REPL scripts
----------------------------------------

The script `polyrun` takes a `.mlb` file and runs it directly in the
Poly/ML environment (rather than dumping out an executable as
polybuild does).

The script `polyrepl` takes a `.mlb` file and loads it into the
Poly/ML interactive environment or REPL, leaving you at the REPL
prompt with your program's contents present in the current
environment.

The script `smlrun` takes a `.mlb` file and runs it directly using the
SML/NJ environment.

The PowerShell script `smlrun.ps1`, for Windows, takes a `.mlb` file
and runs it directly using the SML/NJ environment.


Code coverage
-------------

The script `mlb-coverage` uses MLton's profile tool to print out line
coverage reports for the files making up a program. Run

```
 $ ./mlb-coverage file.mlb
```

to compile and print an overall coverage summary for the program
defined in `file.mlb`, or

```
 $ ./mlb-coverage file.mlb sourcefile.sml
```

to compile `file.mlb` and print detailed coverage for the single
source file `sourcefile.sml`.


Makefile dependency generation
------------------------------

The script `mlb-dependencies` reads a `.mlb` file and prints to stdout
a list of file dependencies in a format suitable to include in a
Makefile.


MLB environments
----------------

If a `.mlb` file refers to other `.mlb` files, these scripts simply
interpolate their contents into the parent. This is not the way `.mlb`
files are supposed to work: each new `.mlb` is supposed to be
elaborated into a new empty environment, which is then brought into
the parent environment.

This difference can cause incompatibilities in both directions:
programs that build with MLton but not with `polybuild`, and also vice
versa. I haven't yet met an incompatibility that couldn't be worked
around though. (I think it is possible to define programs that build
both ways but work differently, although I don't think this is likely
by accident.) Treat your MLton build as definitive.


Main function and top-level code
--------------------------------

Different compilers have different conventions for the main entry
points they generate in a stand-alone executable. MLton produces an
executable that, when run, invokes any code that was found at the top
level during compilation. The entry point of the executable is
therefore the start of the top-level code.

Compilers such as Poly/ML, that start from an interactive environment,
usually evaluate top-level code "at compile time" instead. Therefore
Poly/ML expects to find a separate function called "main" that it will
make into the entry point for the executable.

The convention used by these scripts is that your program will have a
`main.sml` file listed at the bottom of your main `.mlb` file, and
that `main.sml` will simply call out (at the top level) to a main
function that presumably has already been defined in an earlier file
of code. Thus `main.sml` provides the entry point for MLton.

Then the polybuild script will *remove* any file called `main.sml`
when it compiles for Poly/ML, leaving the main function that this file
would have called as the entry point.

That is, if you create a file called `main.sml`, containing a line of
code like

```
val () = main ()
```

and list that file as the last item in your `.mlb` file, then MLton
will treat this line of code as the entry point for the executable,
and so call `main ()` when the executable is run; while the
`polybuild` script will remove this line, leaving Poly/ML simply
calling `main` function as its entry point as usual. So both will have
the same effect in the end.

You will still run into differences if you have other top-level code
with side-effects: best to avoid that if you can.


Author, copyright, and licence
------------------------------

Written by Chris Cannam, copyright 2015-2018.

These scripts are provided under the MIT licence:

    Permission is hereby granted, free of charge, to any person
    obtaining a copy of this software and associated documentation
    files (the "Software"), to deal in the Software without
    restriction, including without limitation the rights to use, copy,
    modify, merge, publish, distribute, sublicense, and/or sell copies
    of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be
    included in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
    NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
    CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
    WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


