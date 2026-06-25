/-
  Catala Runtime Library for Lean4

  Minimal runtime support for Catala programs compiled to Lean4.
-/

-- Nat.gcd and Nat.div are defined by well-founded recursion and marked
-- @[irreducible] in Lean 4.9+.  Unsealing them lets the kernel reduce
-- Rat.mk, Rat.mul, etc. so that `rfl` proofs over Rat/Money arithmetic
-- go through.
unseal Nat.gcd Nat.div

namespace CatalaRuntime

-- ============================================================================
-- Basic Types
-- ============================================================================

/-- Money type represented as integer cents -/
 structure Money where
  cents : Int
  deriving Repr, BEq, DecidableEq, Inhabited

instance : ToString Money where
  toString m :=
    let absCents := m.cents.natAbs
    let whole := absCents / 100
    let cents := absCents % 100
    let centsText := if cents < 10 then s!"0{cents}" else s!"{cents}"
    let sign := if m.cents < 0 then "-" else ""
    s!"{sign}${whole}.{centsText}"

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

/-- Helper method to convert Duration to days (integer division) -/
@[inline, simp, grind]
instance : HDiv Duration Duration Int where
  hDiv a b :=
    let aDays := a.years * 365 + a.months * 30 + a.days
    let bDays := b.years * 365 + b.months * 30 + b.days
    aDays / bDays

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
@[inline,simp, grind]  def ofCents (c : Int) : Money := ⟨c⟩

/-- Create Money from integer (dollars/euros) -/
@[inline,simp, grind]  def ofInt (n : Int) : Money := ⟨n * 100⟩

/-- Convert Money to Int (dollars/euros, truncated) -/
@[inline,simp, grind]  def toInt (m : Money) : Int := m.cents / 100

@[inline,simp, grind]  def toIntRound (m: Money) : Int :=
  let absCents := m.cents.natAbs
  let whole := absCents / 100
  let cents := absCents % 100
  let rounded := if cents >= 50 then whole + 1 else whole
  if m.cents < 0 then -(Int.ofNat rounded) else Int.ofNat rounded

/-- Addition -/
@[inline, simp, grind]
instance : Add Money where
  add a b := ⟨a.cents + b.cents⟩

/-- Subtraction -/
@[inline, simp, grind]
instance : Sub Money where
  sub a b := ⟨a.cents - b.cents⟩

/-- Negation -/
@[inline, simp, grind]
instance : Neg Money where
  neg a := ⟨-a.cents⟩

/-- Multiplication by Int -/
@[inline,simp, grind]  def mulInt (m : Money) (n : Int) : Money := ⟨m.cents * n⟩

/-- Comparison -/
@[inline, simp, grind]
instance : LE Money where
  le a b := a.cents ≤ b.cents

@[inline, simp, grind]
instance : LT Money where
  lt a b := a.cents < b.cents

@[inline, simp, grind]
instance : DecidableRel (α := Money) (· ≤ ·) :=
  fun a b => inferInstanceAs (Decidable (a.cents ≤ b.cents))

@[inline, simp, grind]
instance : DecidableRel (α := Money) (· < ·) :=
  fun a b => inferInstanceAs (Decidable (a.cents < b.cents))


end Money

-- Multiplication operators for Money
@[inline, simp, grind]
instance : HMul Money Int Money where
  hMul := Money.mulInt

@[inline, simp, grind]
instance : HMul Int Money Money where
  hMul i m := Money.mulInt m i

-- ============================================================================
-- Date Operations
-- ============================================================================

namespace Date

/-- Create a Date -/
@[inline,simp, grind]  def create (y m d : Int) : Date := ⟨y, m, d⟩

@[inline] def isLeapYear (year : Int) : Bool :=
  (year % 400 = 0) || (year % 4 = 0 && year % 100 != 0)

@[inline] def daysInMonth (year month : Int) : Int :=
  match month with
  | 1 | 3 | 5 | 7 | 8 | 10 | 12 => 31
  | 4 | 6 | 9 | 11 => 30
  | 2 => if isLeapYear year then 29 else 28
  | _ => 31

@[inline] def daysFromCivil (year month day : Int) : Int :=
  let y := year - if month <= 2 then 1 else 0
  let era := (if y >= 0 then y else y - 399) / 400
  let yoe := y - era * 400
  let mp := month + if month > 2 then -3 else 9
  let doy := (153 * mp + 2) / 5 + day - 1
  let doe := yoe * 365 + yoe / 4 - yoe / 100 + doy
  era * 146097 + doe

@[inline] def civilFromDays (days : Int) : Date :=
  let era := (if days >= 0 then days else days - 146096) / 146097
  let doe := days - era * 146097
  let yoe := (doe - doe / 1460 + doe / 36524 - doe / 146096) / 365
  let y := yoe + era * 400
  let doy := doe - (365 * yoe + yoe / 4 - yoe / 100)
  let mp := (5 * doy + 2) / 153
  let day := doy - (153 * mp + 2) / 5 + 1
  let month := mp + if mp < 10 then 3 else -9
  let year := y + if month <= 2 then 1 else 0
  ⟨year, month, day⟩

@[inline] def normalizeYearMonth (year month : Int) : Int × Int :=
  let totalMonths := year * 12 + (month - 1)
  let normalizedYear := totalMonths / 12
  let normalizedMonth := totalMonths % 12 + 1
  (normalizedYear, normalizedMonth)

/-- Add duration to date. Month/year components are applied first, then days. -/
@[inline,simp, grind]  def addDuration (d : Date) (dur : Duration) : Date :=
  let (year, month) := normalizeYearMonth (d.year + dur.years) (d.month + dur.months)
  let day := min d.day (daysInMonth year month)
  civilFromDays (daysFromCivil year month day + dur.days)

/-- Subtract duration from date -/
@[inline,simp, grind]  def subDuration (d : Date) (dur : Duration) : Date :=
  let (year, month) := normalizeYearMonth (d.year - dur.years) (d.month - dur.months)
  let day := min d.day (daysInMonth year month)
  civilFromDays (daysFromCivil year month day - dur.days)

/-- Subtract two dates to get a day-count duration. -/
@[inline,simp, grind]  def difference (d1 d2 : Date) : Duration :=
  ⟨0, 0, daysFromCivil d1.year d1.month d1.day - daysFromCivil d2.year d2.month d2.day⟩

end Date

-- Subtraction operator for Date
@[inline, simp, grind]
instance : HSub Date Date Duration where
  hSub := Date.difference

@[inline, simp, grind]
instance : HSub Date Duration Date where
  hSub := Date.subDuration

-- adding a duration to a date
@[inline, simp, grind]
instance : HAdd Duration Date Date where
  hAdd dur dat := Date.addDuration dat dur

@[inline, simp, grind]
instance : HAdd Date Duration Date where
  hAdd dat dur := Date.addDuration dat dur
-- ============================================================================
-- Duration Operations
-- ============================================================================

namespace Duration

/-- Create a Duration -/
@[inline,simp, grind]  def create (y m d : Int) : Duration := ⟨y, m, d⟩

/-- Addition -/
@[inline, simp, grind]
instance : Add Duration where
  add a b := ⟨a.years + b.years, a.months + b.months, a.days + b.days⟩

/-- Subtraction -/
@[inline, simp, grind]
instance : Sub Duration where
  sub a b := ⟨a.years - b.years, a.months - b.months, a.days - b.days⟩

/-- Negation -/
@[inline, simp, grind]
instance : Neg Duration where
  neg a := ⟨-a.years, -a.months, -a.days⟩

/-- Multiplication by Int -/
@[inline,simp, grind]  def mulInt (d : Duration) (n : Int) : Duration :=
  ⟨d.years * n, d.months * n, d.days * n⟩

end Duration

set_option autoImplicit false

-- Multiplication operators for Duration
@[inline, simp, grind]
instance : HMul Duration Int Duration where
  hMul := Duration.mulInt

@[inline, simp, grind]
instance : HMul Int Duration Duration where
  hMul i d := Duration.mulInt d i

-- ============================================================================
-- Rational Number Helpers
-- ============================================================================

/-- Create rational from numerator and denominator. -/
@[simp, grind] def mkRational (num den : Int) : Rat :=
  if den = 0 then
    default
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

def processExceptions0 {α : Type} [DecidableEq α] (exceptions : List (D α)) : D α :=
  exceptions.foldl
    (fun acc ex =>
      match acc with
      | .error e => .error e  -- propagate errors
      | .ok none =>
          -- No value yet, use this exception if it has one
          ex
      | .ok (some v1) =>
          -- We already have a value, check for conflicts
          match ex with
          | .ok (some v2) => if v1 = v2 then acc else .error .conflict  -- conflict!
          | .ok none => acc  -- keep existing value
          | .error e => .error e)  -- propagate error
    (.ok none)


@[inline, simp, grind]
def processExceptions {α : Type} (exceptions : List (Option α)) : Option α :=
  exceptions.foldl (fun acc ex => match acc with
  | none => ex
  | some _ => acc
  ) none

/-- Handle exceptions by selecting the first non-none value -/
@[simp, grind] def handleExceptions {α : Type} (options : List (Option (α × SourcePosition))) :
    Option (α × SourcePosition) :=
  options.find? (·.isSome) |>.join

/-- Division with error position tracking for Money -/
@[simp, grind] def divWithErr (_pos : SourcePosition) (a b : Money) : Money :=
  if b.cents = 0 then
    default
  else
    ⟨(a.cents * 100) / b.cents⟩

-- ============================================================================
-- Money Operations (Extended)
-- ============================================================================

namespace Money

/-- Multiply Money by Float (for percentages, decimal operations) -/
@[inline,simp, grind]  def mulFloat (m : Money) (f : Float) : Money :=
  ⟨(Float.toInt64 (Float.round (Float.ofInt m.cents * f))).toInt⟩

/-- Multiply Money by Rat (rational number), rounded half-away-from-zero.
    Stays in Int arithmetic (no natAbs/Float) so omega can close concrete goals. -/
@[inline,simp, grind] def mulRat (m : Money) (r : Rat) : Money :=
  let num := m.cents * r.num
  let den : Int := ↑r.den
  if num ≥ 0 then
    ⟨(2 * num + den) / (2 * den)⟩
  else
    ⟨-((- 2 * num + den) / (2 * den))⟩

@[inline,simp, grind]  def divMoney (m1: Money) (m2: Money) : Rat :=
  (m1.cents : Rat) / (m2.cents : Rat)

/-- Greater than or equal -/
@[inline,simp, grind]  def ge (a b : Money) : Bool := a.cents ≥ b.cents

/-- Greater than -/
@[inline,simp, grind]  def gt (a b : Money) : Bool := a.cents > b.cents

/-- Less than or equal -/
@[inline,simp, grind]  def le (a b : Money) : Bool := a.cents ≤ b.cents

/-- Less than -/
@[inline,simp, grind]  def lt (a b : Money) : Bool := a.cents < b.cents

/-- Equality -/
@[inline,simp, grind]  def eq (a b : Money) : Bool := a.cents = b.cents

end Money

-- Multiplication operators for Money (extended)
@[inline, simp, grind]
instance : HMul Money Rat Money where
  hMul := Money.mulRat

@[inline, simp, grind]
instance : HMul Rat Money Money where
  hMul r m := Money.mulRat m r

@[inline, simp, grind]
instance : HMul Money Float Money where
  hMul := Money.mulFloat

@[inline, simp, grind]
instance : HMul Float Money Money where
  hMul f m := Money.mulFloat m f

-- Int * Rat and Rat * Int
@[inline, simp, grind]
instance : HMul Int Rat Rat where
  hMul i r := ↑(i:Int) * r

@[inline, simp, grind]
instance : HMul Rat Int Rat where
  hMul r i := ↑(i:Int) * r

-- Division of Money by Money to give a Rational number
@[inline, simp, grind]
instance: HDiv Money Money Rat where
  hDiv m1 m2 := Money.divMoney m1 m2

-- Division of Money by rationals and integers to give Money
@[inline, simp, grind]
instance: HDiv Money Rat Money where
  hDiv m q := Money.mulRat m (1/q)

@[inline, simp, grind]
instance: HDiv Money Int Money where
  hDiv m i := {cents := m.cents / i}
-- ============================================================================
-- Generic Multiplication Function
-- ============================================================================
/- Convert to Money -/

class CatalatoMoney (α: Type) (γ: outParam Type) where
  toMoney : α → γ

@[inline, simp, grind]
instance: CatalatoMoney Int Money where
  toMoney := Money.ofInt

@[inline, simp, grind]
instance: CatalatoMoney Rat Money where
  toMoney r :=
    let cents := r * 100
    let n := cents.num.natAbs
    let d := cents.den
    let absRound := (2 * n + d) / (2 * d)
    ⟨if cents.num ≥ 0 then Int.ofNat absRound else -(Int.ofNat absRound)⟩

@[inline, simp, grind]
def toMoney {α γ: Type} [CatalatoMoney α γ] (a: α) : γ :=
  CatalatoMoney.toMoney a

/- Convert to Rationals -/
class CatalatoRat (α: Type) (γ: outParam Type) where
  toRat : α → γ

@[inline, simp, grind]
instance : CatalatoRat Money Rat where
  toRat m := (m.cents : Rat) / 100

@[inline, simp, grind]
instance : CatalatoRat Int Rat where
  toRat m := Rat.ofInt m

@[inline, simp, grind]
def toRat {α γ : Type} [CatalatoRat α γ] (a : α) : γ :=
  CatalatoRat.toRat a

/-- Typeclass for Catala rounding. Covers Round_rat (Rat → Rat) and
    Round_mon (Money → Money), both emitted as `round` by the translator. -/
class CatalaRound (α : Type) (β : outParam Type) where
  round : α → β

/-- Round a rational to the nearest integer.
    Uses round-half-away-from-zero semantics: round(q) = sgn(q) * floor(|q| + 0.5),
    matching Catala's OCaml runtime. -/
@[inline, simp, grind]
instance : CatalaRound Rat Rat where
  round q :=
    let n := q.num.natAbs
    let d := q.den
    let absRound := (2 * n + d) / (2 * d)
    if q.num ≥ 0 then Rat.ofInt (Int.ofNat absRound)
    else Rat.ofInt (-(Int.ofNat absRound))

/-- Round Money to the nearest whole monetary unit (100 cents).
    Uses round-half-away-from-zero semantics, matching Catala's OCaml runtime. -/
@[inline, simp, grind]
instance : CatalaRound Money Money where
  round m :=
    let n := m.cents.natAbs
    let frac := n % 100
    let whole := n / 100
    let roundedWhole := if frac ≥ 50 then whole + 1 else whole
    ⟨if m.cents ≥ 0 then Int.ofNat (roundedWhole * 100)
     else -(Int.ofNat (roundedWhole * 100))⟩

/-- Generic round dispatching via CatalaRound typeclass. -/
@[inline, simp, grind]
def round {α β : Type} [CatalaRound α β] (x : α) : β := CatalaRound.round x

/-- Type class for Catala multiplication — DEPRECATED: use HMul (* operator) instead.
    All type combinations are now covered by HMul instances above. -/
class CatalaMul (α : Type) (β : Type) (γ : outParam Type) where
  multiply : α → β → γ

@[inline, simp, grind]
instance : CatalaMul Money Rat Money where
  multiply := Money.mulRat

@[inline, simp, grind]
instance : CatalaMul Rat Money Money where
  multiply r m := Money.mulRat m r

@[inline, simp, grind]
instance : CatalaMul Money Int Money where
  multiply := Money.mulInt

@[inline, simp, grind]
instance : CatalaMul Int Money Money where
  multiply i m := Money.mulInt m i

@[inline, simp, grind]
instance : CatalaMul Money Float Money where
  multiply := Money.mulFloat

@[inline, simp, grind]
instance : CatalaMul Float Money Money where
  multiply f m := Money.mulFloat m f

@[inline, simp, grind]
instance : CatalaMul Duration Int Duration where
  multiply := Duration.mulInt

@[inline, simp, grind]
instance : CatalaMul Int Duration Duration where
  multiply i d := Duration.mulInt d i

@[inline, simp, grind]
instance : CatalaMul Int Int Int where
  multiply i1 i2 := i1 * i2

@[inline, simp, grind]
instance : CatalaMul Int Rat Rat where
  multiply i r := ↑(i:Int) * r

@[inline, simp, grind]
instance: CatalaMul Rat Int Rat where
  multiply r i := ↑(i:Int) * r

@[inline, simp, grind]
instance : CatalaMul Rat Rat Rat where
  multiply := (· * ·)

@[inline, simp, grind]
instance : CatalaMul Float Float Float where
  multiply := (· * ·)

/-- DEPRECATED: use the * operator (HMul) instead. -/
@[inline, simp, grind, deprecated "Use the * operator (HMul) instead of CatalaRuntime.multiply" (since := "2026-06-25")]
def multiply {α β γ : Type} [CatalaMul α β γ] (a : α) (b : β) : γ :=
  CatalaMul.multiply a b

-- ============================================================================
-- Date Operations (Extended)
-- ============================================================================

namespace Date

/-- Compare dates: less than -/
@[simp, grind] def lt (d1 d2 : Date) : Bool :=
  if d1.year < d2.year then true
  else if d1.year > d2.year then false
  else if d1.month < d2.month then true
  else if d1.month > d2.month then false
  else d1.day < d2.day

/-- Compare dates: less than or equal -/
@[simp, grind] def le (d1 d2 : Date) : Bool :=
  lt d1 d2 || (d1.year = d2.year && d1.month = d2.month && d1.day = d2.day)

/-- Compare dates: greater than -/
@[simp, grind] def gt (d1 d2 : Date) : Bool := lt d2 d1

/-- Compare dates: greater than or equal -/
@[simp, grind] def ge (d1 d2 : Date) : Bool := le d2 d1

/-- Compare dates: equal -/
@[simp, grind] def eq (d1 d2 : Date) : Bool :=
  d1.year = d2.year && d1.month = d2.month && d1.day = d2.day

@[inline, simp, grind]
instance : LT Duration where
  lt a b := (a.years < b.years) ∨ (a.years = b.years ∧ a.months < b.months) ∨
    (a.years = b.years ∧ a.months = b.months ∧ a.days < b.days)

@[inline, simp, grind]
instance : LE Duration where
  le a b := (a.years < b.years) ∨ (a.years = b.years ∧ a.months < b.months) ∨
    (a.years = b.years ∧ a.months = b.months ∧ a.days ≤ b.days)

@[inline, simp, grind]
instance : LT Date where
  lt a b := (a.year < b.year) ∨ (a.year = b.year ∧ a.month < b.month) ∨
    (a.year = b.year ∧ a.month = b.month ∧ a.day < b.day)

@[inline, simp, grind]
instance : LE Date where
  le a b := (a.year < b.year) ∨ (a.year = b.year ∧ a.month < b.month) ∨
    (a.year = b.year ∧ a.month = b.month ∧ a.day ≤ b.day)

-- instance : DecidableRel (α := Money) (· ≤ ·) :=
--   fun a b => inferInstanceAs (Decidable (a.cents ≤ b.cents))

@[inline, simp, grind]
instance : DecidableRel (α := Date) (· < ·) :=
  fun a b => inferInstanceAs (Decidable ((a.year < b.year) ∨ (a.year = b.year ∧ a.month < b.month) ∨
    (a.year = b.year ∧ a.month = b.month ∧ a.day < b.day)))

@[inline, simp, grind]
instance : DecidableRel (α := Date) (· ≤ ·) :=
  fun a b => inferInstanceAs (Decidable ((a.year < b.year) ∨ (a.year = b.year ∧ a.month < b.month) ∨
    (a.year = b.year ∧ a.month = b.month ∧ a.day ≤ b.day)))

@[inline, simp, grind]
instance : DecidableRel (α := Duration) (· < ·) :=
  fun a b => inferInstanceAs (Decidable ((a.years < b.years) ∨ (a.years = b.years ∧ a.months < b.months) ∨
    (a.years = b.years ∧ a.months = b.months ∧ a.days < b.days)))

@[inline, simp, grind]
instance : DecidableRel (α := Duration)  (· ≤ ·) :=
  fun a b => inferInstanceAs (Decidable ((a.years < b.years) ∨ (a.years = b.years ∧ a.months < b.months) ∨
    (a.years = b.years ∧ a.months = b.months ∧ a.days ≤ b.days)))

end Date

-- ============================================================================
-- D Monad Operations (Arithmetic and Comparison through D)
-- ============================================================================

namespace D

/-- Add two D Money values -/
@[simp, grind] def addMoney (m1 m2 : D Money) : D Money :=
  match m1, m2 with
  | .ok (some a), .ok (some b) => .ok (some (a + b))
  | .ok none, _ => .ok none
  | _, .ok none => .ok none
  | .error e, _ => .error e
  | _, .error e => .error e

/-- Subtract two D Money values -/
@[simp, grind] def subMoney (m1 m2 : D Money) : D Money :=
  match m1, m2 with
  | .ok (some a), .ok (some b) => .ok (some (a - b))
  | .ok none, _ => .ok none
  | _, .ok none => .ok none
  | .error e, _ => .error e
  | _, .error e => .error e

/-- Multiply D Money by Float -/
@[simp, grind] def mulMoneyFloat (m : D Money) (f : Float) : D Money :=
  match m with
  | .ok (some a) => .ok (some (a * f))
  | .ok none => .ok none
  | .error e => .error e

/-- Compare D Money: less than -/
@[simp, grind] def ltMoney (m1 m2 : D Money) : D Bool :=
  match m1, m2 with
  | .ok (some a), .ok (some b) => .ok (some (Money.lt a b))
  | .ok none, _ => .ok none
  | _, .ok none => .ok none
  | .error e, _ => .error e
  | _, .error e => .error e

/-- Compare D Money: greater than or equal -/
@[simp, grind] def geMoney (m1 m2 : D Money) : D Bool :=
  match m1, m2 with
  | .ok (some a), .ok (some b) => .ok (some (Money.ge a b))
  | .ok none, _ => .ok none
  | _, .ok none => .ok none
  | .error e, _ => .error e
  | _, .error e => .error e

/-- Maximum of two D Money values (return larger, or first on tie) -/
@[simp, grind] def maxMoney (m1 m2 : D Money) : D Money :=
  match m1, m2 with
  | .ok (some a), .ok (some b) => .ok (some (if Money.ge a b then a else b))
  | .ok (some a), .ok none => .ok (some a)
  | .ok none, .ok (some b) => .ok (some b)
  | .ok none, .ok none => .ok none
  | .error e, _ => .error e
  | _, .error e => .error e

end D

-- Operator instances for D Money
@[inline, simp, grind]
instance : HAdd (D Money) (D Money) (D Money) where
  hAdd := D.addMoney

@[inline, simp, grind]
instance : HSub (D Money) (D Money) (D Money) where
  hSub := D.subMoney

end CatalaRuntime

-- Export Rat.mk as an alias
@[inline,simp, grind]  def Rat.mk := CatalaRuntime.mkRational
