import CatalaRuntime

open CatalaRuntime



namespace Money_en


inductive Optional (TForall : Type) : Type where
  | Absent : Unit → Optional TForall
  | Present : TForall → Optional TForall
deriving Repr


/-- Round Money to the nearest whole unit (e.g., dollar/euro)
    Rounds to nearest 100 cents -/
@[simp, grind] def round (m : CatalaRuntime.Money) : CatalaRuntime.Money :=
  let cents := m.cents
  let remainder := cents % 100
  if remainder ≥ 50 then
    CatalaRuntime.Money.ofCents (cents - remainder + 100)
  else if remainder ≤ -50 then
    CatalaRuntime.Money.ofCents (cents - remainder - 100)
  else
    CatalaRuntime.Money.ofCents (cents - remainder)

/-- Compute 10^n for integer n -/
@[simp, grind] def pow10 (n : Int) : Int :=
  if n ≥ 0 then
    (10 : Int) ^ n.toNat
  else
    1

/-- Round Money to nth decimal place
    n=0: round to whole units (dollars/euros)
    n=1: round to tenths (10 cents)
    n=2: round to hundredths (cents) - no change
    Negative n rounds to larger units -/
@[simp, grind] def round_to_decimal (m : CatalaRuntime.Money) (nth_decimal : Int) : CatalaRuntime.Money :=
  -- cents are at decimal place 2, so we need to adjust
  let adjustment := 2 - nth_decimal
  if adjustment ≤ 0 then
    m  -- No rounding needed, already more precise
  else
    let divisor := pow10 adjustment
    let cents := m.cents
    let half := divisor / 2
    let rounded := if cents ≥ 0 then
      ((cents + half) / divisor) * divisor
    else
      ((cents - half) / divisor) * divisor
    CatalaRuntime.Money.ofCents rounded

@[simp, grind] def min := (fun (m1 : CatalaRuntime.Money) (m2 : CatalaRuntime.Money) => (if (m1 > m2) then m2 else m1))

@[simp, grind] def max := (fun (m1 : CatalaRuntime.Money) (m2 : CatalaRuntime.Money) => (if (m1 > m2) then m1 else m2))

@[simp, grind] def truncate := (fun (_variable : CatalaRuntime.Money) => (if (_variable = (CatalaRuntime.Money.ofCents 0)) then (CatalaRuntime.Money.ofCents 0) else (if (_variable > (CatalaRuntime.Money.ofCents 0)) then (round (_variable - (CatalaRuntime.Money.ofCents 50))) else (round (_variable + (CatalaRuntime.Money.ofCents 50))))))

@[simp, grind] def round_by_excess := (fun (_variable : CatalaRuntime.Money) => (if (_variable ≥ (CatalaRuntime.Money.ofCents 0)) then (round (_variable + (CatalaRuntime.Money.ofCents 49))) else (round (_variable + (CatalaRuntime.Money.ofCents 50)))))

@[simp, grind] def round_by_default := (fun (_variable : CatalaRuntime.Money) => (if (_variable > (CatalaRuntime.Money.ofCents 0)) then (round (_variable - (CatalaRuntime.Money.ofCents 50))) else (round (_variable - (CatalaRuntime.Money.ofCents 49)))))

@[simp, grind] def ceiling := (fun (_variable : CatalaRuntime.Money) (max_value : CatalaRuntime.Money) => (min _variable max_value))

@[simp, grind] def in_default := (fun (_variable : CatalaRuntime.Money) (reference : CatalaRuntime.Money) => (max (CatalaRuntime.Money.ofCents 0) (reference - _variable)))

@[simp, grind] def in_excess := (fun (_variable : CatalaRuntime.Money) (reference : CatalaRuntime.Money) => (max (CatalaRuntime.Money.ofCents 0) (_variable - reference)))

@[simp, grind] def floor := (fun (_variable : CatalaRuntime.Money) (min_value : CatalaRuntime.Money) => (max _variable min_value))

@[simp, grind] def positive := (fun (_variable : CatalaRuntime.Money) => (floor _variable (CatalaRuntime.Money.ofCents 0)))

end Money_en
