# Architecture
StarShip source code gets processed in three steps to produce the expected result.

## Overview
Source code → Lexer → Parser → Execution → Result

*Each step is self-contained and can be used independently. This can be useful for testing and makes the code very reusable.*

## Lexer
Once the source code is loaded from the input file, the lexer starts breaking up the source code into tokens. It starts at the beginning of the input string by looking for keywords like "let". If the string doesn't start with any particular keyword, the lexer checks if a string or comment is about to begin. If not, it assumes a name is about to start. Once it has recognized any of these elements it generates a token and trims the input string. This repeats until the input string is empty.

## Parser
The parser receives an array of tokens. Like the lexer, the parser starts at the beginning of the array. It looks for familiar patterns, like variable or function definitions and print statements. Once the parser recognized a pattern, it generates an instruction for the interpreter to execute. Instructions for function definitions include tokens for the code they contain. The tokens get parsed when the function is called. Like the lexer, the parser looks for patterns, until the input array is empty.

*Since this programming language doesn't have if-statements or for-loops, we don't need to pay attention to hierarchy. For a different kind of syntax, a more complex parser would be needed.*

## Interpreter
The main interpreter (called "Execution" in this project), executes the instructions from the parser. It has access to a variable stack to store values. In this project, it's also responsible for most errors. Ideally, most errors would be identified before running the program. When a function definition calls a function, a new execution unit gets started. The parser parses the function body and then sends the instructions to the new execution unit. This process of executing and removing instructions gets repeated until there are no instructions left to execute. Then, the interpreter is done and the program has been executed.

## Building a similar architecture
If you want to build your own interpreter, you could use the same architecture. For better results, adding an intermediate byte code format would be a good idea. In case you don't want to have a simple syntax like the one used in this project, you might also need a more complex parser.
