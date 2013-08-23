open Rt

exception Conflict of Rt.ty * Rt.ty

val unify       : ty -> ty -> (tvar * ty) list
val unify_list  : ty list  -> (tvar * ty) list
val subst       : (tvar * ty) list -> ty -> ty

val print_env   : (tvar * ty) list -> unit
