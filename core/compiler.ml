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

let rec compile_expr e env =
  match e with
  | Value v -> compile_value v env
  | Var  v -> [Lw (V0,Env.find v env)] 

let compile_instr instr info = 
  match instr with 
  | DeclVar v -> 
    {
      info with 
      fpo = info.fpo -4
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


let rec compile_block block info = 
  match block with
  | i :: b -> 
 (* let new_info = compile_instr i info in new_info :: (compile_block b new_info)*)
    let new_info = compile_instr i info in compile_block b new_info
  | [] -> info


let compile ir =
  let counter = 0 in
  let info = compile_block ir 
      {
        asm = Baselib.builtins
      ; env = Env.empty
      ; fpo = 0
      ; counter = counter + 1
      ; return = "ret" ^ (string_of_int counter)
      }
  in
  { text =[ 
        Move (FP, SP) 
      ;Addi (SP, SP, info.fpo )] 
      @ info.asm
  ; data = [] }