import CatalaRuntime

open CatalaRuntime


namespace Duration_en

@[simp, grind] def positive (d : CatalaRuntime.Duration) : CatalaRuntime.Duration :=
  if d > CatalaRuntime.Duration.create 0 0 0 then d else CatalaRuntime.Duration.create 0 0 0

@[simp, grind] def sum (l : List CatalaRuntime.Duration) : CatalaRuntime.Duration :=
  List.foldl (fun acc x => acc + x) (CatalaRuntime.Duration.create 0 0 0) l

end Duration_en
