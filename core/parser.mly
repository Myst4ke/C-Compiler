%{
  open Ast
  open Ast.Syntax
%}

%token <int> Lint
%token <bool> Ltrue
%token <bool> Lfalse
%token <string> Lident
%token Lopar Lcpar Lobracket Lcbracket
%token Ladd Lsub Lstar Ldiv 
%token Lif Lelse
%token Lreturn Ltypeint Ltypebool Ltypestr Ltypevoid
%token Lcomma Lsc Lend
%token Lneq Leq Ldeq Lsupp Lsuppeq Linf Linfeq
%token Land Lor


%left Ladd Lsub
%left Lstar Ldiv

%start prog

(* %type <Ast.Syntax.expr> prog *)
%type <Ast.Syntax.block> prog

%%

prog:
	| i = instr ; Lsc ; b = prog { i @ b }
	| i = instr ; Lsc ; Lend { i }
;

block:
	| i = instr ; Lsc ; b = block { i @ b }
	| i = instr ; Lsc {i}
;

instr:
  /* Gestion des bool */
  |Ltypebool; id = Lident
  {
   [ DeclVar { name = id ; type_t = Bool_t ;  pos = $startpos(id)}]
  }
  |Ltypebool; id = Lident; Leq; e = expr
  {
   [ DeclVar { name = id ; type_t = Bool_t ; pos = $startpos(id)}
      ; Assign { var = id ; expr = e ; pos = $startpos($3) }
    ]
  }
  /* Gestion des int */
  |Ltypeint ; id = Lident
  {
   [ DeclVar { name = id ; type_t = Int_t ;  pos = $startpos(id)}]
  }
   |Ltypeint ; id = Lident; Leq; e = expr
  {
   [ DeclVar { name = id ; type_t = Int_t ; pos = $startpos(id)}
      ; Assign { var = id ; expr = e ; pos = $startpos($3) }
    ]
  }
  /* Gestion des string */
  |Ltypestr ; id = Lident
  {
   [ DeclVar { name = id ; type_t = String_t ;  pos = $startpos(id)}]
  }
   |Ltypestr ; id = Lident; Leq; e = expr
  {
   [ DeclVar { name = id ; type_t = String_t ; pos = $startpos(id)}
      ; Assign { var = id ; expr = e ; pos = $startpos($3) }
    ]
  }
  
  /* Autres instructions */
  | id = Lident; Leq; e = expr
  {
	[ Assign { var = id
     		 ; expr = e 
    		 ; pos = $startpos($2) 
    		 }
    ]
  }
  |Lreturn; e = expr
  {
    [Return { expr = e; pos = $startpos(e)}]
  }
  |e = expr 
  {
    [Expr { expr = e; pos = $startpos(e)}]
  }

  /* Condition */
  |Lif; Lopar; e = expr; Lcpar; Lobracket; bthen = block; Lcbracket;
  {
    [Cond {expr = e; blockt = bthen; blocke = []; pos = $startpos($1)}]
  }
  |Lif; Lopar; e = expr; Lcpar; Lobracket; bthen = block; Lcbracket;
  Lelse; Lobracket; belse = block; Lcbracket;
  {
    [Cond {expr = e; blockt = bthen; blocke = belse; pos = $startpos($1)}]
  }
  
;

expr:
/* Values */
| v = value { Value {value = v ; pos = $startpos(v)}}
/* Call Baselib*/
| a = expr; Ladd; b = expr 
  { Call { func = "_add"
          ; args = [a ; b]
          ; pos = $startpos($2)
          }
  }
| a = expr; Lsub; b = expr 
  { Call { func = "_sub"
          ; args = [a ; b]
          ; pos = $startpos($2)
          }
  }
| a = expr; Lstar; b = expr 
  { Call { func = "_mul"
          ; args = [a ; b]
          ; pos = $startpos($2)
          }
  }
| a = expr; Ldiv; b = expr 
  { Call { func = "_div"
          ; args = [a ; b]
          ; pos = $startpos($2)
          }
  }
| a = expr; Ldeq; b = expr 
  { Call { func = "_equal"
          ; args = [a ; b]
          ; pos = $startpos($2)
          }
  }
| a = expr; Lneq; b = expr 
  { Call { func = "_nequal"
          ; args = [a ; b]
          ; pos = $startpos($2)
          }
  }
| a = expr; Lsupp; b = expr 
  { Call { func = "_gt"
          ; args = [a ; b]
          ; pos = $startpos($2)
          }
  }
| a = expr; Lsuppeq; b = expr 
  { Call { func = "_gte"
          ; args = [a ; b]
          ; pos = $startpos($2)
          }
  }
| a = expr; Linf; b = expr 
  { Call { func = "_lt"
          ; args = [a ; b]
          ; pos = $startpos($2)
          }
  }
| a = expr; Linfeq; b = expr 
  { Call { func = "_lte"
          ; args = [a ; b]
          ; pos = $startpos($2)
          }
  }
/* | a = expr; Leq; Lor; b = expr 
  { Call { func = "_or"
          ; args = [a ; b]
          ; pos = $startpos($2)
          }
  }
| a = expr; Leq; Land; b = expr 
  { Call { func = "_and"
          ; args = [a ; b]
          ; pos = $startpos($2)
          }
  } */

/* Call */
|name = Lident; Lopar; args = separated_list(Lcomma, expr) ; Lcpar 
  { Call { func = name
          ; args = args
          ; pos = $startpos(name)
        }
  }
/* Variables */
| v = Lident { Var  { name = v ; pos = $startpos(v)} } 
;



value : 
| n = Lint {
  Int { value = n ; pos = $startpos(n) }
}
| b = Ltrue  { Bool { value = b ; pos = $startpos(b)} }
| b = Lfalse { Bool { value = b ; pos = $startpos(b)} }
;