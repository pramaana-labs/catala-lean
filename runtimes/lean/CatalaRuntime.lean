/-
  Catala Runtime Library for Lean4

  Minimal runtime support for Catala programs compiled to Lean4.
-/

namespace CatalaRuntime

-- ============================================================================
-- Basic Types
-- ============================================================================

/-- Money type represented as integer cents -/
structure Money where
  cents : Int
  deriving Repr, BEq, DecidableEq, Inhabited

instance : ToString Money where
  toString m := s!"${m.cents / 100}.{(m.cents % 100).natAbs}"

/-- Date type -/
structure Date where
  year : Int
  month : Int
  day : Int
  deriving Repr, BEq, DecidableEq, Inhabited

instance : ToString Date where
  toString d := s!"{d.year}-{d.month}-{d.day}"

/-- Duration type -/
structure Duration where
  years : Int
  months : Int
  days : Int
  deriving Repr, BEq, DecidableEq, Inhabited

instance : ToString Duration where
  toString d := s!"{d.years}y {d.months}m {d.days}d"

/-- Source position for error reporting -/
structure SourcePosition where
  filename : String
  start_line : Int
  start_column : Int
  end_line : Int
  end_column : Int
  deriving Repr, BEq, Inhabited

instance : ToString SourcePosition where
  toString p := s!"{p.filename}:{p.start_line}:{p.start_column}"

-- ============================================================================
-- Money Operations
-- ============================================================================

namespace Money

/-- Create Money from cents -/
@[inline] def ofCents (c : Int) : Money := ⟨c⟩

/-- Create Money from integer (dollars/euros) -/
@[inline] def ofInt (n : Int) : Money := ⟨n * 100⟩

/-- Convert Money to Int (dollars/euros, truncated) -/
@[inline] def toInt (m : Money) : Int := m.cents / 100

/-- Addition -/
instance : Add Money where
  add a b := ⟨a.cents + b.cents⟩

/-- Subtraction -/
instance : Sub Money where
  sub a b := ⟨a.cents - b.cents⟩

/-- Negation -/
instance : Neg Money where
  neg a := ⟨-a.cents⟩

/-- Multiplication by Int -/
@[inline] def mulInt (m : Money) (n : Int) : Money := ⟨m.cents * n⟩

/-- Comparison -/
instance : LE Money where
  le a b := a.cents ≤ b.cents

instance : LT Money where
  lt a b := a.cents < b.cents

instance : DecidableRel (α := Money) (· ≤ ·) :=
  fun a b => inferInstanceAs (Decidable (a.cents ≤ b.cents))

instance : DecidableRel (α := Money) (· < ·) :=
  fun a b => inferInstanceAs (Decidable (a.cents < b.cents))

end Money

-- Multiplication operator for Money
instance : HMul Money Int Money where
  hMul := Money.mulInt

-- ============================================================================
-- Date Operations
-- ============================================================================

namespace Date

/-- Create a Date -/
@[inline] def create (y m d : Int) : Date := ⟨y, m, d⟩

/-- Add duration to date (simplified) -/
@[inline] def addDuration (d : Date) (dur : Duration) : Date :=
  ⟨d.year + dur.years, d.month + dur.months, d.day + dur.days⟩

/-- Subtract duration from date -/
@[inline] def subDuration (d : Date) (dur : Duration) : Date :=
  ⟨d.year - dur.years, d.month - dur.months, d.day - dur.days⟩

/-- Subtract two dates to get duration (simplified) -/
@[inline] def difference (d1 d2 : Date) : Duration :=
  ⟨d1.year - d2.year, d1.month - d2.month, d1.day - d2.day⟩

end Date

-- Subtraction operator for Date
instance : HSub Date Date Duration where
  hSub := Date.difference

-- ============================================================================
-- Duration Operations
-- ============================================================================

namespace Duration

/-- Create a Duration -/
@[inline] def create (y m d : Int) : Duration := ⟨y, m, d⟩

/-- Addition -/
instance : Add Duration where
  add a b := ⟨a.years + b.years, a.months + b.months, a.days + b.days⟩

/-- Subtraction -/
instance : Sub Duration where
  sub a b := ⟨a.years - b.years, a.months - b.months, a.days - b.days⟩

/-- Negation -/
instance : Neg Duration where
  neg a := ⟨-a.years, -a.months, -a.days⟩

/-- Multiplication by Int -/
@[inline] def mulInt (d : Duration) (n : Int) : Duration :=
  ⟨d.years * n, d.months * n, d.days * n⟩

end Duration

-- Multiplication operator for Duration
instance : HMul Duration Int Duration where
  hMul := Duration.mulInt

-- ============================================================================
-- Rational Number Helpers
-- ============================================================================

/-- Create rational from numerator and denominator -/
-- Note: Simplified implementation - just does integer division for now
def mkRational (num den : Int) : Int :=
  if den = 0 then
    panic! "Rational denominator cannot be zero"
  else
    num / den

-- ============================================================================
-- Error Handling and Default Calculus Monad
-- ============================================================================

/-- Errors from the default calculus -/
inductive Err where
  | conflict : Err
  | empty : Err
  deriving Repr, DecidableEq

/-- Default calculus monad: D α = Except Err (Option α)
    - .error .conflict: multiple conflicting definitions
    - .error .empty: no definition and no default
    - .ok none: no definition (but has default handling)
    - .ok (some v): successful definition
-/
abbrev D (α : Type) := Except Err (Option α)

/-- Process a list of exceptions, checking for conflicts.
    Returns the first successful definition, or conflict if multiple succeed.
-/
def processExceptions {α : Type} (exceptions : List (D α)) : D α :=
  exceptions.foldl
    (fun acc ex =>
      match acc with
      | .error e => .error e  -- propagate errors
      | .ok none =>
          -- No value yet, use this exception if it has one
          ex
      | .ok (some _) =>
          -- We already have a value, check for conflicts
          match ex with
          | .ok (some _) => .error .conflict  -- conflict!
          | .ok none => acc  -- keep existing value
          | .error e => .error e)  -- propagate error
    (.ok none)

/-- Handle exceptions by selecting the first non-none value -/
def handleExceptions {α : Type} (options : List (Option (α × SourcePosition))) :
    Option (α × SourcePosition) :=
  options.find? (·.isSome) |>.join

/-- Division with error position tracking for Money -/
def divWithErr (pos : SourcePosition) (a b : Money) : Money :=
  if b.cents = 0 then
    panic! s!"Division by zero at {pos}"
  else
    -- Simplified: return integer division for now
    ⟨a.cents / b.cents⟩

-- ============================================================================
-- Money Operations (Extended)
-- ============================================================================

namespace Money

/-- Multiply Money by Float (for percentages, decimal operations) -/
@[inline] def mulFloat (m : Money) (f : Float) : Money :=
  ⟨(Float.toInt64 (Float.round (Float.ofInt m.cents * f))).toInt⟩

/-- Greater than or equal -/
@[inline] def ge (a b : Money) : Bool := a.cents ≥ b.cents

/-- Greater than -/
@[inline] def gt (a b : Money) : Bool := a.cents > b.cents

/-- Less than or equal -/
@[inline] def le (a b : Money) : Bool := a.cents ≤ b.cents

/-- Less than -/
@[inline] def lt (a b : Money) : Bool := a.cents < b.cents

/-- Equality -/
@[inline] def eq (a b : Money) : Bool := a.cents = b.cents

end Money

-- Float multiplication for Money
instance : HMul Money Float Money where
  hMul := Money.mulFloat

-- ============================================================================
-- Date Operations (Extended)
-- ============================================================================

namespace Date

/-- Compare dates: less than -/
def lt (d1 d2 : Date) : Bool :=
  if d1.year < d2.year then true
  else if d1.year > d2.year then false
  else if d1.month < d2.month then true
  else if d1.month > d2.month then false
  else d1.day < d2.day

/-- Compare dates: less than or equal -/
def le (d1 d2 : Date) : Bool :=
  lt d1 d2 || (d1.year = d2.year && d1.month = d2.month && d1.day = d2.day)

/-- Compare dates: greater than -/
def gt (d1 d2 : Date) : Bool := lt d2 d1

/-- Compare dates: greater than or equal -/
def ge (d1 d2 : Date) : Bool := le d2 d1

/-- Compare dates: equal -/
def eq (d1 d2 : Date) : Bool :=
  d1.year = d2.year && d1.month = d2.month && d1.day = d2.day

end Date

-- ============================================================================
-- D Monad Operations (Arithmetic and Comparison through D)
-- ============================================================================

namespace D

/-- Add two D Money values -/
def addMoney (m1 m2 : D Money) : D Money :=
  match m1, m2 with
  | .ok (some a), .ok (some b) => .ok (some (a + b))
  | .ok none, _ => .ok none
  | _, .ok none => .ok none
  | .error e, _ => .error e
  | _, .error e => .error e

/-- Subtract two D Money values -/
def subMoney (m1 m2 : D Money) : D Money :=
  match m1, m2 with
  | .ok (some a), .ok (some b) => .ok (some (a - b))
  | .ok none, _ => .ok none
  | _, .ok none => .ok none
  | .error e, _ => .error e
  | _, .error e => .error e

/-- Multiply D Money by Float -/
def mulMoneyFloat (m : D Money) (f : Float) : D Money :=
  match m with
  | .ok (some a) => .ok (some (a * f))
  | .ok none => .ok none
  | .error e => .error e

/-- Compare D Money: less than -/
def ltMoney (m1 m2 : D Money) : D Bool :=
  match m1, m2 with
  | .ok (some a), .ok (some b) => .ok (some (Money.lt a b))
  | .ok none, _ => .ok none
  | _, .ok none => .ok none
  | .error e, _ => .error e
  | _, .error e => .error e

/-- Compare D Money: greater than or equal -/
def geMoney (m1 m2 : D Money) : D Bool :=
  match m1, m2 with
  | .ok (some a), .ok (some b) => .ok (some (Money.ge a b))
  | .ok none, _ => .ok none
  | _, .ok none => .ok none
  | .error e, _ => .error e
  | _, .error e => .error e

/-- Maximum of two D Money values (return larger, or first on tie) -/
def maxMoney (m1 m2 : D Money) : D Money :=
  match m1, m2 with
  | .ok (some a), .ok (some b) => .ok (some (if Money.ge a b then a else b))
  | .ok (some a), .ok none => .ok (some a)
  | .ok none, .ok (some b) => .ok (some b)
  | .ok none, .ok none => .ok none
  | .error e, _ => .error e
  | _, .error e => .error e

end D

-- Operator instances for D Money
instance : HAdd (D Money) (D Money) (D Money) where
  hAdd := D.addMoney

instance : HSub (D Money) (D Money) (D Money) where
  hSub := D.subMoney

end CatalaRuntime

-- Export Rat.mk as an alias
-- Note: Returns Int for now, not Rat (simplified)
@[inline] def Rat.mk := CatalaRuntime.mkRational
