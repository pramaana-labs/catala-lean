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
-- Error Handling
-- ============================================================================

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

end CatalaRuntime

-- Export Rat.mk as an alias
-- Note: Returns Int for now, not Rat (simplified)
@[inline] def Rat.mk := CatalaRuntime.mkRational
