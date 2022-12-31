open Ast
open Mips

module Env = Map.Make(String)

let _types_ = (* Env.empty *)
  Env.of_seq
    (List.to_seq
       [ "_add", (Func_t (Int_t,  [ [Int_t]  ; [Int_t]    ]), true)
       ; "_sub", (Func_t (Int_t,  [ [Int_t]  ; [Int_t]    ]), true)
       ; "_mul", (Func_t (Int_t,  [ [Int_t]  ; [Int_t]    ]), true)
       ; "_div", (Func_t (Int_t,  [ [Int_t]  ; [Int_t]    ]), true)
       ; "_equal",(Func_t(Bool_t, [ [Bool_t; Int_t] ; [Bool_t; Int_t] ]), true)
       ; "_nequal", (Func_t (Bool_t, [ [Bool_t; Int_t] ; [Bool_t; Int_t]   ]), true)
       ; "_gt",  (Func_t (Bool_t, [ [Int_t] ; [Int_t]   ]), true)
       ; "_gte", (Func_t (Bool_t, [ [Int_t] ; [Int_t]   ]), true)
       ; "_lt",  (Func_t (Bool_t, [ [Int_t] ; [Int_t]   ]), true)
       ; "_lte", (Func_t (Bool_t, [ [Int_t] ; [Int_t]   ]), true)
       ; "_or",  (Func_t (Bool_t, [ [Bool_t] ; [Bool_t] ]), true)
       ; "_and", (Func_t (Bool_t, [ [Bool_t] ; [Bool_t] ]), true)
       ; "puti", (Func_t (Void_t, [[Int_t] ]), true)
       ; "geti", (Func_t (Int_t, []), true)
    ])

let builtins = [ 
  (* Opérateurs *)
  Label "_add"
  ; Lw (T0, Mem (SP, 0))
  ; Lw (T1, Mem (SP, 4))
  ; Add (V0, T0, T1)
  ; Jr RA
  
  ; Label "_sub"
  ; Lw (T0, Mem (SP, 0))
  ; Lw (T1, Mem (SP, 4))
  ; Sub (V0, T1, T0)
  ; Jr RA

  ; Label "_mul"
  ; Lw (T0, Mem (SP, 0))
  ; Lw (T1, Mem (SP, 4))
  ; Mul (V0, T0, T1)
  ; Jr RA

  ; Label "_div"
  ; Lw (T0, Mem (SP, 0))
  ; Lw (T1, Mem (SP, 4))
  ; Div (V0, T1, T0)
  ; Jr RA

  ; Label "_equal"
  ; Lw (T0, Mem (SP, 0))
  ; Lw (T1, Mem (SP, 4))
  ; Seq (V0, T1, T0)
  ; Jr RA

  ; Label "_nequal"
  ; Lw (T0, Mem (SP, 0))
  ; Lw (T1, Mem (SP, 4))
  ; Sne (V0, T1, T0)
  ; Jr RA

  ; Label "_gt"
  ; Lw (T0, Mem (SP, 0))
  ; Lw (T1, Mem (SP, 4))
  ; Sgt (V0, T1, T0)
  ; Jr RA

  ; Label "_gte"
  ; Lw (T0, Mem (SP, 0))
  ; Lw (T1, Mem (SP, 4))
  ; Sge (V0, T1, T0)
  ; Jr RA

  ; Label "_lt"
  ; Lw (T0, Mem (SP, 0))
  ; Lw (T1, Mem (SP, 4))
  ; Slt (V0, T1, T0)
  ; Jr RA

  ; Label "_lte"
  ; Lw (T0, Mem (SP, 0))
  ; Lw (T1, Mem (SP, 4))
  ; Sle (V0, T1, T0)
  ; Jr RA

  ; Label "_or"
  ; Lw (T0, Mem (SP, 0))
  ; Lw (T1, Mem (SP, 4))
  ; Or (V0, T1, T0)
  ; Jr RA

  ; Label "_and"
  ; Lw (T0, Mem (SP, 0))
  ; Lw (T1, Mem (SP, 4))
  ; And (V0, T1, T0)
  ; Jr RA

  (* In/Out *)
  ; Label "puti"
  ; Lw (A0, Mem (SP, 0))
  ; Li (V0, Syscall.print_int)
  ; Syscall
  ; Jr RA

  ; Label "geti"
  ; Lw (A0, Mem (SP, 0))
  ; Li (V0, Syscall.read_int)
  ; Syscall
  ; Jr RA

  ; Label "puts"
  ; Lw (A0, Mem (SP, 0))
  ; Li (V0, Syscall.print_str)
  ; Syscall
  ; Jr RA

  ; Label "gets"
  ; Lw (A0, Mem (SP, 0))
  ; Li (V0, Syscall.read_str)
  ; Syscall
  ; Jr RA

  (*  ; Label "alloc"
  ; Lw (A0, Mem (SP, 0))
  ; Li (V0, Syscall.sbrk)
  ; Syscall
  ; Jr RA

  ; Label "_deref"
  ; La (V0, Mem (SP, 0))
  ; Jr RA *)
  ]
