import CatalaRuntime

open CatalaRuntime


namespace Integer_en

@[simp, grind] def min (n1 : Int) (n2 : Int) : Int :=
  if n1 ≤ n2 then n1 else n2

@[simp, grind] def max (n1 : Int) (n2 : Int) : Int :=
  if n1 ≥ n2 then n1 else n2

@[simp, grind] def ceiling (n : Int) (max_value : Int) : Int :=
  min n max_value

@[simp, grind] def floor (n : Int) (min_value : Int) : Int :=
  max n min_value

@[simp, grind] def positive (n : Int) : Int :=
  floor n 0

@[simp, grind] def sum (l : List Int) : Int :=
  List.foldl (fun acc x => acc + x) 0 l

end Integer_en
