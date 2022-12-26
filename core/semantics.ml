open Ast
open Ast.IR
open Baselib

exception Error of string * Lexing.position
(* fonctions d'aide à la gestion des erreurs *)

let warn msg pos_lnum pos_cnum pos_bol=
  Printf.eprintf "Warning on line %d col %d: %s.\n"
    pos_lnum (pos_cnum - pos_bol) msg

let expr_pos expr =
  match expr with
  | Syntax.Value v -> v.pos
  | Syntax.Var v   -> v.pos
  (* | Syntax.Call c  -> c.pos *)

let errt expected given pos =
  raise (Error (Printf.sprintf "expected %s but given %s"
                  (string_of_type_t expected)
                  (string_of_type_t given),
                pos))

let analyze_value value =
  match value with
  | Syntax.Bool b -> Bool b.value, Bool_t
  | Syntax.Int n  -> Int n.value, Int_t

let rec analyze_expr env expr =
  match expr with
  | Syntax.Value v ->
     let av, vt = analyze_value v.value in
     Value av, vt
  | Syntax.Var v -> begin
     match Env.find_opt v.name env with
     | None -> raise (Error ("unbound variable: " ^ v.name, v.pos))
     | Some (t, init) ->
       (*Pour une raison que j'ignore warn ne reconnaissait v.pos comme un a' et non comme une position *)
        if not init then warn ("unassigned variable: " ^ v.name) v.pos.pos_lnum v.pos.pos_cnum v.pos.pos_bol ;
        Var v.name, t
    end

  let rec analyze_instr instr env =
    match instr with
    | Syntax.DeclVar d ->
     DeclVar d.name, Env.add d.name (d.type_t, false) env
    | Syntax.Assign a -> begin
      match Env.find_opt a.var env with
     | None -> raise (Error ("unbound variable: " ^ a.var, a.pos))
     | Some (vt, _) ->
        let ae, et = analyze_expr env a.expr in
        if vt <> et then errt vt et (expr_pos a.expr) ;
        Assign (a.var, ae), Env.add a.var (vt, true) env
    end
    | Syntax.Return r ->
     let (ex, _) = analyze_expr env r.expr in
     Return ex, env
     


let rec analyze_block block env =
  match block with
  | i :: b -> 
    let ai, new_env = analyze_instr i env in 
    ai :: (analyze_block b new_env)
  | [] -> []

let analyze parsed =
  analyze_block parsed Baselib._types_


