%{
  open Ast
  open Ast.Syntax
%}

%token <int> Lint
%token <bool> Ltrue
%token <bool> Lfalse
%token <string> Lident
%token Ladd Lsub Lmul Ldiv Lopar Lcpar
%token Lsc Lend Leq Lreturn Ltypeint Ltypebool

%start prog

(* %type <Ast.Syntax.expr> prog *)
%type <Ast.Syntax.block> prog

%%

prog:
	| i = instr ; Lsc ; b = prog { i @ b }
	| i = instr ; Lsc ; Lend { i }
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
  /* | a = expr; Ladd; b = expr 
  { [Call { func = "%add"
          ; args = [a ; b]
          ; pos = $startpos($2)
          }]
  } */
;

expr:
| v = Lident { Var  { name = v ; pos = $startpos(v)} } 
| v = value { Value {value = v ; pos = $startpos(v)}}
;

value : 
| n = Lint {
  Int { value = n ; pos = $startpos(n) }
}
| b = Ltrue  { Bool { value = b ; pos = $startpos(b)} }
| b = Lfalse { Bool { value = b ; pos = $startpos(b)} }
;