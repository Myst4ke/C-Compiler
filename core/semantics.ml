open Ast
open Ast.IR1
open Baselib

exception ErrorType of string
exception Error of string * Lexing.position
(* fonctions d'aide à la gestion des erreurs *)

let warn msg pos_lnum pos_cnum pos_bol=
  Printf.eprintf "Warning on line %d col %d: %s.\n"
    pos_lnum (pos_cnum - pos_bol) msg

let expr_pos expr =
  match expr with
  | Syntax.Value v -> v.pos
  | Syntax.Var v   -> v.pos
  | Syntax.Call c  -> c.pos

let rec type_list_to_string str list = 
  match list with
  | [] -> str ^ ")"
  (* Cas pour éviter la présence d'un espace si un seul type est attendu ex: (bool ) *)
  | h :: [] -> str ^ (string_of_type_t h) ^ ")"
  | h :: t -> str ^ (string_of_type_t h) ^ ", "

let errt expected given pos =
  raise (Error (Printf.sprintf "expected %s but given %s"
                  (type_list_to_string "(" expected)
                  (string_of_type_t given),
                pos))
let analyze_value value =
  match value with
  | Syntax.Bool   b -> V1.Bool b.value, Bool_t
  | Syntax.Int    n -> V1.Int n.value, Int_t
  | Syntax.String s -> V1.String s.value, String_t

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
  | Syntax.Call c -> begin
      match Env.find_opt c.func env with
      | None -> raise (Error ("undefined function: " ^ c.func, c.pos))
      | Some (Func_t (rt, args_t), _) ->
         if (List.length args_t) <> (List.length c.args) then
           raise (Error (Printf.sprintf "function %s expects %d arguments but was given %d"
                           c.func (List.length args_t) (List.length c.args), c.pos)) ;
         let args = verif_types args_t c.args env in
         Call (c.func, args), rt
      | _ -> raise (Error ("not a function: " ^ c.func, c.pos))
    end
and verif_types types args env = 
    List.map2
    (fun typ ar ->
      let aa, at = analyze_expr env ar in
      if not (List.mem at typ) then errt typ at (expr_pos ar) ;
      aa)
    types args

  let rec analyze_instr instr env =
    match instr with
    | Syntax.DeclVar d ->
     DeclVar d.name, Env.add d.name (d.type_t, false) env
    | Syntax.Assign a -> begin
      match Env.find_opt a.var env with
     | None -> raise (Error ("unbound variable: " ^ a.var, a.pos))
     | Some (vt, _) ->
        let ae, et = analyze_expr env a.expr in
        if vt <> et then errt [vt] et (expr_pos a.expr) ;
        Assign (a.var, ae), Env.add a.var (vt, true) env
    end
    | Syntax.Return r ->
     let (ex, _) = analyze_expr env r.expr in
     Return ex, env
    | Syntax.Expr e ->
     let (ex, _) = analyze_expr env e.expr in
     Expr ex, env
    | Syntax.Cond c -> begin
      match analyze_expr env c.expr with
      |ex, Bool_t -> Cond (ex, (analyze_block c.blockt env), (analyze_block c.blocke env)), env
      |_ -> raise (Error ("'if' statements expects boolean conditions", c.pos))
    end
    | Syntax.While w -> begin
      match analyze_expr env w.expr with
      |ex, Bool_t -> While (ex, (analyze_block w.block env)), env
      |_ -> raise (Error ("'if' statements expects boolean conditions", w.pos))
    end
and analyze_block block env =
  match block with
  | i :: b -> 
    let ai, new_env = analyze_instr i env in 
    ai :: (analyze_block b new_env)
  | [] -> []

let analyze parsed =
  analyze_block parsed Baselib._types_


