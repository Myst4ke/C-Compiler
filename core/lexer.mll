{
  open Lexing
  open Parser

  exception Error of char
}

let num = ['0'-'9']
let alpha = ['a' - 'z' 'A' - 'Z']
let ident = alpha ( alpha | num | '_')*

rule token = parse
| eof             { Lend }
| '('             { Lopar }
| ')'             { Lcpar }
| '{'             { Lobracket }
| '}'             { Lcbracket }
| [ ' ' '\t' ]    { token lexbuf }
| '\n'            { Lexing.new_line lexbuf; token lexbuf }
| num+ as n       { Lint (int_of_string n) }
| ','             { Lcomma }
| "true"          { Ltrue (true)  }
| "false"         { Lfalse (false)}
| "int"           { Ltypeint }
| "bool"          { Ltypebool }
| "string"        { Ltypestr }
(* | "void"          { Ltypevoid } *)
| ';'             { Lsc }
| '='             { Leq }
| "=="            { Ldeq }
| "!="            { Lneq }
| ">"             { Lsupp }
| ">="            { Lsuppeq }
| "<"             { Linf }
| "<="            { Linfeq }
| '*'             { Lstar }
| '+'             { Ladd }
| '/'             { Ldiv }
| '-'             { Lsub }
| "||"            { Lor }  
| "&&"            { Land }  
| "if"            { Lif }
| "else"          { Lelse }
| "return"        { Lreturn }
| ident as id     { Lident (id)}
| _ as c          { raise (Error c) }