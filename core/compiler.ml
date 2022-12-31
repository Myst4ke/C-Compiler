open Ast.IR
open Mips

module Env = Map.Make(String)

type cinfo = { asm: Mips.instr list
             ; env: Mips.loc Env.t
             ; fpo: int
             ; counter: int
             ; return: string 
             }
let compile_value v env = 
  match v with
  | Int  n -> [Li (V0, n)]
  | Bool b -> [Li (V0, if b then 1 else 0)] 
  | String l -> [ La (V0, Lbl l) ]

let rec compile_expr e env =
  match e with
  | Value v -> compile_value v env
  | Var  v -> [Lw (V0,Env.find v env)] 
  | Call (f, args) ->
     let ca = List.map (fun a ->
                  compile_expr a env
                  @ [ Addi (SP, SP, -4)
                    ; Sw (V0, Mem (SP, 0)) ])
                args in
     List.flatten ca
     @ [ Jal f
       ; Addi (SP, SP, 4 * (List.length args)) ]

let rec compile_instr instr info = 
  match instr with 
  | DeclVar v -> 
    {
      info with 
      fpo = info.fpo +4
      ; env = Env.add v (Mem (FP, info.fpo)) info.env
    }
  | Assign (v,e) -> 
    { info with 
    asm = info.asm 
     @ compile_expr e info.env
     @ [ Sw (V0, Env.find v info.env)]
    }
  | Return e ->
     { info with
       asm = info.asm
              @ compile_expr e info.env
     }
  | Expr e ->
    { info with
          asm = info.asm
              @ compile_expr e info.env
     }
  | Cond (c, t, e) ->
     let uniq = string_of_int info.counter in
     let ct = compile_block t { info with asm = []
                                        ; counter = info.counter + 1 } in
     let ce = compile_block e { info with asm = []
                                        ; counter = ct.counter } in
     { info with
       asm = info.asm
              @ compile_expr c info.env
              @ [ Beqz (V0, "else" ^ uniq) ]
              @ ct.asm
              @ [ B ("endif" ^ uniq)
                ; Label ("else" ^ uniq) ]
              @ ce.asm
              @ [ Label ("endif" ^ uniq) ]
     ; counter = ce.counter }
  | While (e, b) ->
    let uniq = string_of_int info.counter in
     let ct = compile_block b { info with asm = []
                                        ; counter = info.counter + 1 } in
     { info with
       asm = info.asm
              @ [Label ("while" ^ uniq)]
              @ compile_expr e info.env
              @ [ Beqz (V0, "endwhile" ^ uniq) ]
              @ ct.asm
              @ [B ("while" ^ uniq)]
              @ [ Label ("endwhile" ^ uniq) ]
     ; counter = ct.counter }

and compile_block block info = 
  match block with
  | i :: b -> 
    let new_info = compile_instr i info in compile_block b new_info
  | [] -> info


let compile ir =
  let counter = 0 in
  let info = compile_block ir 
      {
        asm = []
      ; env = Env.empty
      ; fpo = 8
      ; counter = counter + 1
      ; return = "ret" ^ (string_of_int counter)
      }
  in
  { text = 
    Baselib.builtins @ 
    [ 
      Label "main"
      ; Addi (SP, SP, -info.fpo)
      ; Sw (RA, Mem (SP, info.fpo - 4))
      ; Sw (FP, Mem (SP, info.fpo - 8))
      ; Addi (FP, SP, info.fpo - 4) 
    ]
    @ info.asm @ 
    [
      Addi (SP, SP, info.fpo)
     ; Lw (RA, Mem (FP, 0))
     ; Lw (FP, Mem (FP, -4))
     ; Jr (RA)
    ]
      
  ; data = [] }


 (*  let compile (code, data) =
  { text = Baselib.builtins @ compile_prog code 0
  ; data = List.map (fun (l, s) -> (l, Asciiz s)) data } *)