import CatalaRuntime
import Stdlib.Optional

open CatalaRuntime

namespace Date_internal


@[simp, grind] def of_ymd (dyear: Int) (dmonth : Int) (dday : Int) : CatalaRuntime.Date :=
CatalaRuntime.Date.mk dyear dmonth dday

@[simp, grind] def to_ymd (date: CatalaRuntime.Date) : Int × Int × Int :=
(date.year, date.month, date.day)


@[simp, grind] def is_leap_year (year : Int) : Bool :=
  (year % 400 = 0) || (year % 4 = 0 && year % 100 != 0)

@[simp, grind] def days_in_month (month : Int) (is_leap_year : Bool) : Int :=
  match month with
  | 1 | 3 | 5 | 7 | 8 | 10 | 12 => 31
  | 4 | 6 | 9 | 11 => 30
  | 2 => if is_leap_year then 29 else 28
  | _ => default


@[simp, grind] def last_day_of_month (d: CatalaRuntime.Date) : CatalaRuntime.Date :=
let days_month := days_in_month (d.month) (is_leap_year d.year)
CatalaRuntime.Date.mk (d.year) (d.month) (days_month)

/-- Add duration to date, rounding down if the resulting day is invalid (e.g., Feb 31 → Feb 28) -/
@[simp, grind] def add_rounded_down (d : CatalaRuntime.Date) (dur : CatalaRuntime.Duration) : CatalaRuntime.Date :=
  let new_year := d.year + dur.years
  let total_months := d.month + dur.months
  let year_adjustment := (total_months - 1) / 12
  let new_month := ((total_months - 1) % 12) + 1
  let adjusted_year := new_year + year_adjustment
  let max_day := days_in_month new_month (is_leap_year adjusted_year)
  let new_day := min d.day max_day + dur.days
  CatalaRuntime.Date.mk adjusted_year new_month new_day

/-- Add duration to date, rounding up if the resulting day is invalid (e.g., Feb 31 → Mar 1) -/
@[simp, grind] def add_rounded_up (d : CatalaRuntime.Date) (dur : CatalaRuntime.Duration) : CatalaRuntime.Date :=
  let new_year := d.year + dur.years
  let total_months := d.month + dur.months
  let year_adjustment := (total_months - 1) / 12
  let new_month := ((total_months - 1) % 12) + 1
  let adjusted_year := new_year + year_adjustment
  let max_day := days_in_month new_month (is_leap_year adjusted_year)
  if d.day > max_day then
    -- Round up to next month
    let next_month := if new_month = 12 then 1 else new_month + 1
    let next_year := if new_month = 12 then adjusted_year + 1 else adjusted_year
    CatalaRuntime.Date.mk next_year next_month (1 + dur.days)
  else
    CatalaRuntime.Date.mk adjusted_year new_month (d.day + dur.days)

end Date_internal
