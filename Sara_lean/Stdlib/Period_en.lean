import CatalaRuntime
import Stdlib.Date_en
import Stdlib.Optional

open CatalaRuntime


namespace Period_en

@[grind] structure Period where
  begin : CatalaRuntime.Date
  _end : CatalaRuntime.Date
deriving Repr, BEq


@[simp, grind] def valid := (fun (p : Period) => (if ((p)._end < (p).begin) then false else true))

@[simp, grind] def duration := (fun (p : Period) => (((CatalaRuntime.Duration.create 0 0 1) + (p)._end) - (p).begin))

@[simp, grind] def are_adjacent := (fun (p1 : Period) (p2 : Period) => ((p1)._end = ((p2).begin - (CatalaRuntime.Duration.create 0 0 1))))

@[simp, grind] def join := (fun (p1 : Period) (p2 : Period) => ({ begin := (Date_en.min (p1).begin (p2).begin), _end := (Date_en.max (p1)._end (p2)._end) } : Period))

@[simp, grind] def contained := (fun (p : Period) (d : CatalaRuntime.Date) => (decide ((p).begin ≤ d) && decide (d ≤ (p)._end)))

@[simp, grind] def to_tuple := (fun (p : Period) => ((p).begin, (p)._end))

@[simp, grind] def of_tuple := (fun (tpl : CatalaRuntime.Date × CatalaRuntime.Date) => ({ begin := tpl.1, _end := tpl.2 } : Period))

@[simp, grind] def of_tuple2 := (fun (begin_date : CatalaRuntime.Date) (_end : CatalaRuntime.Date) => ({ begin := begin_date, _end := _end } : Period))

@[simp, grind] def intersection := (fun (p1 : Period) (p2 : Period) => ((fun (intersection : Period) => (if (valid intersection) then (Optional.Present intersection) else (Optional.Absent ()))) ({ begin := (Date_en.max (p1).begin (p2).begin), _end := (Date_en.min (p1)._end (p2)._end) } : Period)))

@[simp, grind] def find_period := (fun (l : (List Period)) (d : CatalaRuntime.Date) => (List.foldl ((fun (found : (Optional Period)) (p : Period) => (match found with
  | Optional.Absent _ => (if (contained p d) then (Optional.Present p) else (Optional.Absent ()))
  | Optional.Present _ => found))) (Optional.Absent ()) l))

@[simp, grind] def to_tuple_list := (fun (l : (List Period)) => (List.map ((fun (p : Period) => (to_tuple p))) l))

@[simp, grind] def to_tuple_associated_list {t1 : Type} (l : List (Period × t1)) : List ((CatalaRuntime.Date × CatalaRuntime.Date) × t1) :=
  List.map (fun (p : Period × t1) => ((to_tuple p.1), p.2)) l

@[simp, grind] def of_tuple_list := (fun (l : (List (CatalaRuntime.Date × CatalaRuntime.Date))) => (List.map (fun (tpl : (CatalaRuntime.Date × CatalaRuntime.Date)) => (of_tuple tpl)) l))

@[simp, grind] def of_tuple_associated_list {t1 : Type} (l : List ((CatalaRuntime.Date × CatalaRuntime.Date) × t1)) : List (Period × t1) :=
  List.map (fun (tpl : ((CatalaRuntime.Date × CatalaRuntime.Date) × t1)) => ((of_tuple tpl.1), tpl.2)) l

/-- Helper: get next month's first day -/
private  def next_month_start (d : CatalaRuntime.Date) : CatalaRuntime.Date :=
  let ymd := Date_en.to_year_month_day d
  let year := ymd.1
  let month := ymd.2.1
  if month = 12 then
    Date_en.of_year_month_day (year + 1) 1 1
  else
    Date_en.of_year_month_day year (month + 1) 1

/-- Helper: get first day of current month -/
private  def month_start (d : CatalaRuntime.Date) : CatalaRuntime.Date :=
  let ymd := Date_en.to_year_month_day d
  Date_en.of_year_month_day ymd.1 ymd.2.1 1

/-- Split a period into monthly sub-periods, each paired with the original period.
    Returns List (Period × Period) where first is original, second is the monthly slice.
    starting_month parameter reserved for fiscal year support -/
partial  def split_by_year (_starting_month : Date_en.Month) (p : Period) : List (Period × Period) :=
  let rec loop (current : CatalaRuntime.Date) (acc : List (Period × Period)) : List (Period × Period) :=
    if decide (current > p._end) then acc.reverse
    else
      let month_end_date := Date_en.last_day_of_month current
      let slice_end := Date_en.min month_end_date p._end
      let slice : Period := { begin := current, _end := slice_end }
      let next := next_month_start current
      loop next ((p, slice) :: acc)
  loop p.begin []

/-- Split a period into monthly sub-periods.
    Returns List Period of monthly slices -/
partial  def split_by_month (p : Period) : List Period :=
  let rec loop (current : CatalaRuntime.Date) (acc : List Period) : List Period :=
    if decide (current > p._end) then acc.reverse
    else
      let month_end_date := Date_en.last_day_of_month current
      let slice_end := Date_en.min month_end_date p._end
      let slice : Period := { begin := current, _end := slice_end }
      let next := next_month_start current
      loop next (slice :: acc)
  loop p.begin []

/-- Compare two periods by their begin date -/
private  def period_lt (p1 p2 : Period) : Bool :=
  decide (p1.begin < p2.begin)

/-- Sort a list of (Period × t) by the period's begin date -/
@[simp, grind] def sort_by_date {t : Type} (l : List (Period × t)) : List (Period × t) :=
  l.toArray.qsort (fun a b => decide (a.1.begin < b.1.begin)) |>.toList

end Period_en
