open Unicode.Std
open Big_int
open Rt

exception Undefined_primitive of string

(* Debug primitive implementations. *)

let debug args =
  match args with
  | [arg] ->
    print_endline (Unicode.assert_utf8s
      (Sexplib.Sexp.to_string_hum (sexp_of_value arg)));
    Rt.Nil
  | _ -> assert false

(* Integer primitive implementations. *)

let int_binop op =
  (fun args ->
    match args with
    | [Unsigned(wl,lhs); Unsigned(wr,rhs)] when wl = wr
    -> (let prec = shift_left_big_int unit_big_int wl in
        Unsigned(wl, mod_big_int (op lhs rhs) prec))
    | [Integer(lhs); Integer(rhs)]
    -> Integer(op lhs rhs)
    | _ -> assert false)

let int_cmpop op =
  (fun args ->
    match args with
    | [Unsigned(wl,lhs); Unsigned(wr,rhs)]
    | [  Signed(wl,lhs);   Signed(wr,rhs)]
      when wl = wr
    -> if op lhs rhs then Rt.Truth else Rt.Lies
    | [Integer(lhs); Integer(rhs)]
    -> if op lhs rhs then Rt.Truth else Rt.Lies
    | _ -> assert false)

let int_shl = int_binop (fun lhs rhs -> shift_left_big_int  lhs (int_of_big_int rhs))
let int_shr = int_binop (fun lhs rhs -> shift_right_big_int lhs (int_of_big_int rhs))

let int_divmod args =
  match args with
  | [Unsigned(wl,lhs); Unsigned(wr,rhs)] when wl = wr
  -> (let quo, rem = quomod_big_int lhs rhs in
        Tuple [Unsigned(wl, quo); Unsigned(wl, rem)])
  | [Integer(lhs); Integer(rhs)]
  -> (let quo, rem = quomod_big_int lhs rhs in
        Tuple [Integer(quo); Integer(rem)])
  | _
  -> assert false

let int_to_str args =
  match args with
  | [Integer(value)] | [Signed(_, value)] | [Unsigned(_, value)]
  -> String (string_of_big_int value)
  | _
  -> assert false

(* Symbol primitive implementations. *)

let sym_to_str args =
  match args with
  | [Symbol str] -> String str
  | _ -> assert false

(* Object primitive implementations. *)

let obj_alloc args =
  match args with
  | [Class (cls)]
  -> (Instance({
        i_hash  = Hash_seed.make ();
        i_class = cls;
        i_slots = Table.create []
      }))
  | _
  -> assert false

let obj_equal args =
  match args with
  | [a; b] -> if equal a b then Rt.Truth else Rt.Lies
  | _ -> assert false

(* Class primitive implementations. *)

let cls_defm args =
  match args with
  | [Rt.Class (klass, _); Rt.Symbol name; Rt.Lambda body]
  -> (let meth = {
        im_hash    = Hash_seed.make ();
        im_body    = body;
        im_dynamic = false; } in
      klass.k_methods <- Assoc.append klass.k_methods name meth;
      Rt.Nil)
  | _
  -> assert false

let prim = Table.create [
  (* name       side-eff?  impl *)
  (* -- debug ------------------------------------------ *)
  "debug",      (true,     debug);
  "external",   (true,     fun _ -> assert false);
  "externalva", (true,     fun _ -> assert false);
  (* -- booleans --------------------------------------- *)
  "bool_neg",   (false,    fun _ -> assert false);
  (* -- machine int and big int ------------------------ *)
  "int_add",    (false,    int_binop add_big_int);
  "int_sub",    (false,    int_binop sub_big_int);
  "int_mul",    (false,    int_binop mult_big_int);
  "int_sdiv",   (false,    int_divmod);
  "int_udiv",   (false,    int_divmod);
  "int_and",    (false,    int_binop and_big_int);
  "int_or",     (false,    int_binop or_big_int);
  "int_xor",    (false,    int_binop xor_big_int);
  "int_shl",    (false,    int_shl);
  "int_lshr",   (false,    int_shr);
  "int_ashr",   (false,    int_shr);
  "int_exp",    (false,    int_binop power_big_int_positive_big_int);
  "int_cmp",    (false,    int_binop (fun lhs rhs -> big_int_of_int (compare_big_int lhs rhs)));
  "int_eq",     (false,    int_cmpop eq_big_int);
  "int_ne",     (false,    int_cmpop (fun lhs rhs -> not (eq_big_int lhs rhs)));
  "int_ule",    (false,    int_cmpop le_big_int);
  "int_sle",    (false,    int_cmpop le_big_int);
  "int_ult",    (false,    int_cmpop lt_big_int);
  "int_slt",    (false,    int_cmpop lt_big_int);
  "int_uge",    (false,    int_cmpop ge_big_int);
  "int_sge",    (false,    int_cmpop ge_big_int);
  "int_ugt",    (false,    int_cmpop gt_big_int);
  "int_sgt",    (false,    int_cmpop gt_big_int);
  "int_to_str", (false,    int_to_str);
  (* -- tuples ----------------------------------------- *)
  "tup_length", (false,    fun _ -> assert false);
  "tup_lookup", (false,    fun _ -> assert false);
  "tup_slice",  (false,    fun _ -> assert false);
  "tup_enum",   (true,     fun _ -> assert false);
  (* -- records ---------------------------------------- *)
  "rec_lookup", (false,    fun _ -> assert false);
  "rec_enum",   (true,     fun _ -> assert false);
  (* -- symbols ---------------------------------------- *)
  "sym_to_str", (false,    sym_to_str);
  (* -- closures --------------------------------------- *)
  "lam_call",   (true,     fun _ -> assert false);
  (* -- objects ---------------------------------------- *)
  "obj_alloc",  (false,    obj_alloc);
  "obj_equal",  (false,    obj_equal);
  "obj_send",   (false,    fun _ -> assert false);
  (* -- classes ---------------------------------------- *)
  "cls_alloc",  (false,    fun _ -> assert false);
  "cls_defm",   (true,     cls_defm);
  "cls_defv",   (false,    fun _ -> assert false);
  (* -- hardware access -------------------------------- *)
  "mem_load",   (false,    fun _ -> assert false);
  "mem_store",  (true,     fun _ -> assert false);
  "mem_loadv",  (true,     fun _ -> assert false);
  "mem_storev", (true,     fun _ -> assert false);
]

let find name =
  try
    Table.get_exn prim name
  with Not_found ->
    raise (Undefined_primitive name)

let exists = Table.exists prim

let has_side_effects name =
  fst (find name)

let invoke name args =
  (snd (find name)) args
