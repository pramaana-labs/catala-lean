import CatalaRuntime
import Stdlib.Optional

open CatalaRuntime

namespace Date_internal


def of_ymd (dyear: Int) (dmonth : Int) (dday : Int) : CatalaRuntime.Date :=
CatalaRuntime.Date.mk dyear dmonth dday

def to_ymd (date: CatalaRuntime.Date) : Int × Int × Int :=
(date.year, date.month, date.day)


def is_leap_year (year : Int) : Bool :=
  (year % 400 = 0) || (year % 4 = 0 && year % 100 != 0)

def days_in_month (month : Int) (is_leap_year : Bool) : Int :=
  match month with
  | 1 | 3 | 5 | 7 | 8 | 10 | 12 => 31
  | 4 | 6 | 9 | 11 => 30
  | 2 => if is_leap_year then 29 else 28
  | _ => sorry


def last_day_of_month (d: CatalaRuntime.Date) : CatalaRuntime.Date :=
let days_month := days_in_month (d.month) (is_leap_year d.year)
CatalaRuntime.Date.mk (d.year) (d.month) (days_month)

end Date_internal
