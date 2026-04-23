import CatalaRuntime
import Stdlib.Date_en

open CatalaRuntime


namespace MonthYear_en

@[grind] structure MonthYear where
  year_number : Int
  month_name : Date_en.Month
deriving Repr, DecidableEq

/-- Extracts the named month and year from a date ignoring the day. -/
@[simp, grind] def from_date (d : CatalaRuntime.Date) : MonthYear :=
  { year_number := Date_en.get_year d,
    month_name := Date_en.integer_to_month (Date_en.get_month d) }

/-- Gets the first day of the month as a date. -/
@[simp, grind] def first_day_of_month (m : MonthYear) : CatalaRuntime.Date :=
  Date_en.of_year_month_day m.year_number (Date_en.month_to_integer m.month_name) 1

/-- Gets the last day of the month as a date. -/
@[simp, grind] def last_day_of_month (m : MonthYear) : CatalaRuntime.Date :=
  Date_en.last_day_of_month
    (Date_en.of_year_month_day m.year_number (Date_en.month_to_integer m.month_name) 1)

/-- Checks if the date occurs strictly before the given month. -/
@[simp, grind] def is_before_the_month (m : MonthYear) (d : CatalaRuntime.Date) : Bool :=
  decide (d < first_day_of_month m)

/-- Checks if the date occurs strictly after the given month. -/
@[simp, grind] def is_after_the_month (m : MonthYear) (d : CatalaRuntime.Date) : Bool :=
  decide (d > last_day_of_month m)

/-- Checks if the date occurs before the first day of the next month. -/
@[simp, grind] def is_before_or_during_month (m : MonthYear) (d : CatalaRuntime.Date) : Bool :=
  decide (d ≤ last_day_of_month m)

/-- Checks if the date occurs after the last day of the previous month. -/
@[simp, grind] def is_during_or_after_month (m : MonthYear) (d : CatalaRuntime.Date) : Bool :=
  decide (d ≥ first_day_of_month m)

/-- Checks if the date is in the given month. -/
@[simp, grind] def is_in_the_month (m : MonthYear) (d : CatalaRuntime.Date) : Bool :=
  is_before_or_during_month m d && is_during_or_after_month m d

end MonthYear_en
