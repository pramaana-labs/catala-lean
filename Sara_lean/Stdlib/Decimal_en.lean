import CaseStudies.Pramaana.CatalaRuntime
import CaseStudies.Pramaana.Stdlib.Optional


open CatalaRuntime


namespace Decimal_en



/-- Round a rational number to the nearest integer (half rounds away from zero) -/
@[simp, grind, smt_translate] def round (x : Rat) : Rat :=
  let floorVal : Int := Rat.floor x
  let frac := x - floorVal
  if x ≥ 0 then
    if frac ≥ (1 : Rat) / 2 then ↑(floorVal + 1) else ↑floorVal
  else
    if frac > (1 : Rat) / 2 then ↑(floorVal + 1) else ↑floorVal

/-- Compute 10^n for integer n (handles both positive and negative exponents) -/
@[simp, grind, smt_translate] def pow10 (n : Int) : Rat :=
  if n ≥ 0 then
    ↑((10 : Nat) ^ n.toNat)
  else
    1 / ↑((10 : Nat) ^ ((-n).toNat))

/-- Round a rational number to the nth decimal place
    Positive n: round to n decimal places (e.g., n=2 rounds to hundredths)
    Negative n: round to 10^(-n) place (e.g., n=-1 rounds to tens) -/
@[simp, grind, smt_translate] def round_to_decimal (x : Rat) (nth_decimal : Int) : Rat :=
  let multiplier := pow10 nth_decimal
  (round (x * multiplier)) / multiplier

@[simp, grind, smt_translate] def min := (fun (m1 : Rat) (m2 : Rat) => (if (m1 > m2) then m2 else m1))

@[simp, grind, smt_translate] def max := (fun (m1 : Rat) (m2 : Rat) => (if (m1 > m2) then m1 else m2))

@[simp, grind, smt_translate] def truncate := (fun (_variable : Rat) => (if (_variable = (Rat.mk 0 1)) then (Rat.mk 0 1) else (if (_variable > (Rat.mk 0 1)) then (round (_variable - (Rat.mk 1 2))) else (round (_variable + (Rat.mk 1 2))))))

@[simp, grind, smt_translate] def ceiling := (fun (_variable : Rat) (max_value : Rat) => (min _variable max_value))

@[simp, grind, smt_translate] def floor := (fun (_variable : Rat) (min_value : Rat) => (max _variable min_value))

@[simp, grind, smt_translate] def round_by_default := (fun (_variable : Rat) => (if (_variable > (Rat.mk 0 1)) then (truncate _variable) else (if ((truncate _variable) = _variable) then _variable else (truncate (_variable - (Rat.mk 1 1))))))

@[simp, grind, smt_translate] def round_by_excess := (fun (_variable : Rat) => (if (_variable ≥ (Rat.mk 0 1)) then (if ((truncate _variable) = _variable) then _variable else (truncate (_variable + (Rat.mk 1 1)))) else (round (_variable + (Rat.mk 1 2)))))

@[simp, grind, smt_translate] def positive := (fun (_variable : Rat) => (floor _variable (Rat.mk 0 1)))

end Decimal_en
