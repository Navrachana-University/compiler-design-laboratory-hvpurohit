
==============================
MatrixDSL - Matrix Expression Compiler
==============================

Author:
Name: Hitanshu Purohit  
Roll Number: 22000386  

 Description:
MatrixDSL is a domain-specific language designed to simplify matrix operations. 
It allows users to write high-level matrix expressions (such as addition, multiplication, scalar ops)
in a natural and readable syntax. The compiler translates these expressions into intermediate code
and evaluates the result.

Supported Features:
- Matrix definition using curly braces
- Matrix addition, subtraction, multiplication
- Scalar multiplication
- Print statement for output
- Static matrix size check (at compile-time)

 Example Input:

matrix A = { {1, 2}, {3, 4} };
matrix B = { {5, 6}, {7, 8} };
matrix C = A + B;
print C;

 How to Run:

1. Make sure you have `flex`, `bison`, and `gcc` installed.

2. Run the following commands in terminal:

bison -d matrix_dsl.y
flex matrix_dsl.l
gcc matrix_dsl.tab.c lex.yy.c -o matrix\_dsl -lfl


3. Run the compiler with an input file:

	./matrix\_dsl < input.msdl



Files:
- `matrix_dsl.l`: Flex lexer
- `matrix_dsl.y`: Bison parser
- `main.c` (if applicable): Driver code
- `input.txt`: Sample DSL code to run

 Notes:
- Matrices must be well-formed and of matching dimensions where required.
- Scalar multiplication only allowed with defined constant values.


