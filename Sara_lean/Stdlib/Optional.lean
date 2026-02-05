
inductive Optional (TForall : Type) : Type where
  | Absent : Unit → Optional TForall
  | Present : TForall → Optional TForall
deriving Repr, DecidableEq, Inhabited
