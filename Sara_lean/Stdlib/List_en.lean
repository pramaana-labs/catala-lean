import CatalaRuntime
import Stdlib.Optional

open CatalaRuntime



-- en list operations using 1-based indexing
namespace List_en


/-- Get nth element from list (1-based index) -/
def nth_element {t : Type} (lst : List t) (index : Int) : Optional t :=
  let idx := index.toNat - 1  -- Convert to 0-based
  match lst[idx]? with
  | some v => Optional.Present v
  | none => Optional.Absent ()

/-- Remove nth element from list (1-based index) -/
def remove_nth_element {t : Type} (lst : List t) (index : Int) : List t :=
  let idx := index.toNat - 1  -- Convert to 0-based
  lst.eraseIdx idx



/-- Create a list of integers from begin_val to end_val (inclusive) -/
def sequence (begin_val : Int) (end_val : Int) : List Int :=
  if begin_val > end_val then []
  else
    let length := (end_val - begin_val + 1).toNat
    (List.range length).map (fun i => begin_val + (Int.ofNat i))

def remove_first_element := (fun {t : Type} (lst : (List t)) => (remove_nth_element lst (1 : Int)))

def remove_last_element := (fun {t : Type} (lst : (List t)) => (remove_nth_element lst (lst.length : Int)))

def last_element := (fun {t : Type} (lst : (List t)) => (nth_element lst (lst.length : Int)))

def first_element := (fun {t : Type} (lst : (List t)) => (nth_element lst (1 : Int)))

end List_en
