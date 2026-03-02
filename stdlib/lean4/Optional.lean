
inductive Optional (TForall : Type) : Type where
  | Absent : Optional TForall
  | Present : TForall → Optional TForall
deriving Repr, DecidableEq, Inhabited
