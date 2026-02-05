import CatalaRuntime
import Stdlib.Date_internal
import Stdlib.Optional

open CatalaRuntime



namespace Date_en

inductive Month : Type where
 | January : Unit -> Month
 | February : Unit -> Month
 | March : Unit -> Month
 | April : Unit -> Month
 | May : Unit -> Month
 | June : Unit -> Month
 | July : Unit -> Month
 | August : Unit -> Month
 | September : Unit -> Month
 | October : Unit -> Month
 | November : Unit -> Month
 | December : Unit -> Month
deriving Repr, DecidableEq


structure MonthOfYear where
  year_number : Int
  month_name : Month
deriving Repr, DecidableEq


def min := (fun (x : CatalaRuntime.Date) (y : CatalaRuntime.Date) => (if (x ≤ y) then x else y))

def max := (fun (x : CatalaRuntime.Date) (y : CatalaRuntime.Date) => (if (x ≥ y) then x else y))

def of_year_month_day := (fun (dyear : Int) (dmonth : Int) (dday : Int) => (Date_internal.of_ymd dyear dmonth dday))

def to_year_month_day := (fun (d : CatalaRuntime.Date) => (Date_internal.to_ymd d))

def last_day_of_month := (fun (d : CatalaRuntime.Date) => (Date_internal.last_day_of_month d))

def month_to_int := (fun (m : Month) => (match m with
  | Month.January _ => (1 : Int)
  | Month.February _ => (2 : Int)
  | Month.March _ => (3 : Int)
  | Month.April _ => (4 : Int)
  | Month.May _ => (5 : Int)
  | Month.June _ => (6 : Int)
  | Month.July _ => (7 : Int)
  | Month.August _ => (8 : Int)
  | Month.September _ => (9 : Int)
  | Month.October _ => (10 : Int)
  | Month.November _ => (11 : Int)
  | Month.December _ => (12 : Int)))

def month_of_int := (fun (i : Int) => (if (i = (1 : Int)) then (Month.January ()) else (if (i = (2 : Int)) then (Month.February ()) else (if (i = (3 : Int)) then (Month.March ()) else (if (i = (4 : Int)) then (Month.April ()) else (if (i = (5 : Int)) then (Month.May ()) else (if (i = (6 : Int)) then (Month.June ()) else (if (i = (7 : Int)) then (Month.July ()) else (if (i = (8 : Int)) then (Month.August ()) else (if (i = (9 : Int)) then (Month.September ()) else (if (i = (10 : Int)) then (Month.October ()) else (if (i = (11 : Int)) then (Month.November ()) else (if (i = (12 : Int)) then (Month.December ()) else sorry /-unsupported expression-/)))))))))))))

def is_after_date_plus_delay := (fun (compared_date : CatalaRuntime.Date) (reference_date : CatalaRuntime.Date) (delay : CatalaRuntime.Duration) => (compared_date ≥ (reference_date + delay)))

def is_old_enough_rounding_down := (fun (birth_date : CatalaRuntime.Date) (target_age : CatalaRuntime.Duration) (current_date : CatalaRuntime.Date) => decide (current_date ≥ (birth_date + target_age)))

def is_before_date_plus_delay := (fun (compared_date : CatalaRuntime.Date) (reference_date : CatalaRuntime.Date) (delay : CatalaRuntime.Duration) => decide (compared_date ≤ (reference_date + delay)))

def is_young_enough := (fun (currrent_date : CatalaRuntime.Date) (birth_date : CatalaRuntime.Date) (target_age : CatalaRuntime.Duration) => decide (currrent_date ≤ (birth_date + target_age)))

def is_young_enough_rounding_down := (fun (birth_date : CatalaRuntime.Date) (target_age : CatalaRuntime.Duration) (current_date : CatalaRuntime.Date) => decide (current_date ≤ (birth_date + target_age)))

def last_day_of_year := (fun (d : CatalaRuntime.Date) => ((fun (ymd : (Int × Int × Int)) => (of_year_month_day (ymd).1 (12 : Int) (31 : Int))) (to_year_month_day d)))

def first_day_of_year := (fun (d : CatalaRuntime.Date) => ((fun (ymd : (Int × Int × Int)) => (of_year_month_day (ymd).1 (1 : Int) (1 : Int))) (to_year_month_day d)))

def first_day_of_month := (fun (d : CatalaRuntime.Date) => ((fun (ymd : (Int × Int × Int)) => (of_year_month_day (ymd).1, (ymd).2, (1 : Int))) (to_year_month_day d)))

def get_day := (fun (d : CatalaRuntime.Date) => ((to_year_month_day d)).2.2)

def get_month := (fun (d : CatalaRuntime.Date) => ((to_year_month_day d)).2.1)

def get_year := (fun (d : CatalaRuntime.Date) => ((to_year_month_day d)).1)

def month_of_year_to_first_day_of_month := (fun (m : MonthOfYear) => (of_year_month_day (m).year_number (month_to_int (m).month_name) (1 : Int)))

def to_month_of_year := (fun (d : CatalaRuntime.Date) => ({ year_number := (get_year d), month_name := (month_of_int (get_month d)) } : MonthOfYear))

end Date_en
