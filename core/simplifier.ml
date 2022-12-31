open Ast
module Env = Map.Make(String)
let re = ref Env.empty 

let collect_constant_strings code =
  let counter = ref 0 in
  let ccs_value = function
    | V1.Bool b -> V2.Bool b
    | V1.Int n  -> V2.Int n
    | V1.String s -> 
      match Env.mem s !re with
      | true -> V2.Data (Env.find s !re)
      | false -> 
      let label = "str" ^ (string_of_int !counter) in 
      re := Env.add s label !re;
      incr counter;
      V2.Data label
      
  in
  let rec ccs_expr = function
    | IR1.Value v ->
       IR2.Value (ccs_value v)
    | IR1.Var v ->
       IR2.Var v
    | IR1.Call (f, args) ->
       let args2 = List.map ccs_expr args in
       IR2.Call (f, args2)
  in
  let rec ccs_instr = function
    | IR1.DeclVar v ->
       IR2.DeclVar v
    | IR1.Return e ->
       IR2.Return (ccs_expr e)
    | IR1.Expr e ->
       IR2.Expr (ccs_expr e)
    | IR1.Assign (lv, e) ->
       IR2.Assign (lv, ccs_expr e)
    | IR1.Cond (t, y, n) ->
       IR2.Cond (ccs_expr t, ccs_block y, ccs_block n)
    | IR1.While (e, b)-> 
      IR2.While (ccs_expr e, ccs_block b)

  and ccs_block = function
    | [] -> []
    | i :: r ->
       ccs_instr i :: ccs_block r
  in ccs_block code

let simplify code =
   Env.iter( fun str lbl -> print_endline str; print_endline lbl) !re;
   
   let def = collect_constant_strings code in
   def, Env.fold (fun label s acc -> (s, label) :: acc ) !re []
  
