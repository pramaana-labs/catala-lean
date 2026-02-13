import CatalaRuntime

import Stdlib

open CatalaRuntime

inductive MonthYear_en.Date_en.Month : Type where
 | January : Unit -> MonthYear_en.Date_en.Month
 | February : Unit -> MonthYear_en.Date_en.Month
 | March : Unit -> MonthYear_en.Date_en.Month
 | April : Unit -> MonthYear_en.Date_en.Month
 | May : Unit -> MonthYear_en.Date_en.Month
 | June : Unit -> MonthYear_en.Date_en.Month
 | July : Unit -> MonthYear_en.Date_en.Month
 | August : Unit -> MonthYear_en.Date_en.Month
 | September : Unit -> MonthYear_en.Date_en.Month
 | October : Unit -> MonthYear_en.Date_en.Month
 | November : Unit -> MonthYear_en.Date_en.Month
 | December : Unit -> MonthYear_en.Date_en.Month
deriving DecidableEq, Inhabited

inductive Date_en.Day_of_week : Type where
 | Monday : Unit -> Date_en.Day_of_week
 | Tuesday : Unit -> Date_en.Day_of_week
 | Wednesday : Unit -> Date_en.Day_of_week
 | Thursday : Unit -> Date_en.Day_of_week
 | Friday : Unit -> Date_en.Day_of_week
 | Saturday : Unit -> Date_en.Day_of_week
 | Sunday : Unit -> Date_en.Day_of_week
deriving DecidableEq, Inhabited

inductive Sections.FilingStatus : Type where
 | JointReturn : Unit -> Sections.FilingStatus
 | SurvivingSpouse : Unit -> Sections.FilingStatus
 | HeadOfHousehold : Unit -> Sections.FilingStatus
 | Single : Unit -> Sections.FilingStatus
 | MarriedFilingSeparately : Unit -> Sections.FilingStatus
deriving DecidableEq, Inhabited

inductive Sections.ResidencyStatus : Type where
 | Resident : Unit -> Sections.ResidencyStatus
 | NonresidentAlien : Unit -> Sections.ResidencyStatus
deriving DecidableEq, Inhabited

inductive Sections.DecreeType : Type where
 | Divorce : Unit -> Sections.DecreeType
 | SeparateMaintenance : Unit -> Sections.DecreeType
deriving DecidableEq, Inhabited

inductive Sections.ParentType : Type where
 | Biological : Unit -> Sections.ParentType
 | Step : Unit -> Sections.ParentType
 | Adoptive : Unit -> Sections.ParentType
deriving DecidableEq, Inhabited

inductive Sections.FamilyRelationshipType : Type where
 | Child : Unit -> Sections.FamilyRelationshipType
 | DescendantOfChild : Unit -> Sections.FamilyRelationshipType
 | Brother : Unit -> Sections.FamilyRelationshipType
 | Sister : Unit -> Sections.FamilyRelationshipType
 | Stepbrother : Unit -> Sections.FamilyRelationshipType
 | Stepsister : Unit -> Sections.FamilyRelationshipType
 | DescendantOfSibling : Unit -> Sections.FamilyRelationshipType
 | Father : Unit -> Sections.FamilyRelationshipType
 | Mother : Unit -> Sections.FamilyRelationshipType
 | AncestorOfFatherOrMother : Unit -> Sections.FamilyRelationshipType
 | Stepfather : Unit -> Sections.FamilyRelationshipType
 | Stepmother : Unit -> Sections.FamilyRelationshipType
 | NieceOrNephew : Unit -> Sections.FamilyRelationshipType
 | UncleOrAunt : Unit -> Sections.FamilyRelationshipType
 | SonInLaw : Unit -> Sections.FamilyRelationshipType
 | DaughterInLaw : Unit -> Sections.FamilyRelationshipType
 | FatherInLaw : Unit -> Sections.FamilyRelationshipType
 | MotherInLaw : Unit -> Sections.FamilyRelationshipType
 | BrotherInLaw : Unit -> Sections.FamilyRelationshipType
 | SisterInLaw : Unit -> Sections.FamilyRelationshipType
deriving DecidableEq, Inhabited

inductive Sections.OrganizationType : Type where
 | Business : Unit -> Sections.OrganizationType
 | GovernmentFederal : Unit -> Sections.OrganizationType
 | GovernmentState : Unit -> Sections.OrganizationType
 | EducationalInstitution : Unit -> Sections.OrganizationType
 | Hospital : Unit -> Sections.OrganizationType
 | Club : Unit -> Sections.OrganizationType
 | FraternityOrSorority : Unit -> Sections.OrganizationType
 | ForeignGovernment : Unit -> Sections.OrganizationType
 | InternationalOrganization : Unit -> Sections.OrganizationType
 | PenalInstitution : Unit -> Sections.OrganizationType
deriving DecidableEq, Inhabited

inductive Sections.EmploymentCategory : Type where
 | General : Unit -> Sections.EmploymentCategory
 | AgriculturalLabor : Unit -> Sections.EmploymentCategory
 | DomesticService : Unit -> Sections.EmploymentCategory
 | FederalGovernment : Unit -> Sections.EmploymentCategory
 | StateGovernment : Unit -> Sections.EmploymentCategory
 | SchoolCollegeUniversity : Unit -> Sections.EmploymentCategory
 | Hospital : Unit -> Sections.EmploymentCategory
 | ForeignGovernment : Unit -> Sections.EmploymentCategory
 | InternationalOrganization : Unit -> Sections.EmploymentCategory
 | PenalInstitution : Unit -> Sections.EmploymentCategory
deriving DecidableEq, Inhabited

inductive Sections.ServiceLocation : Type where
 | WithinUnitedStates : Unit -> Sections.ServiceLocation
 | OutsideUnitedStates : Unit -> Sections.ServiceLocation
deriving DecidableEq, Inhabited

inductive Sections.PaymentMedium : Type where
 | Cash : Unit -> Sections.PaymentMedium
 | NonCash : Unit -> Sections.PaymentMedium
deriving DecidableEq, Inhabited

inductive Sections.PaymentReason : Type where
 | RegularCompensation : Unit -> Sections.PaymentReason
 | SicknessOrAccidentDisability : Unit -> Sections.PaymentReason
 | Death : Unit -> Sections.PaymentReason
 | TerminationAfterDeathOrDisabilityRetirement : Unit -> Sections.PaymentReason
 | AgriculturalLaborNonCash : Unit -> Sections.PaymentReason
 | DomesticServiceNonBusiness : Unit -> Sections.PaymentReason
deriving DecidableEq, Inhabited

inductive Sections.VisaCategory : Type where
 | H2A : Unit -> Sections.VisaCategory
 | Other : Unit -> Sections.VisaCategory
deriving DecidableEq, Inhabited

inductive Sections.TerminationReason : Type where
 | Death : Unit -> Sections.TerminationReason
 | DisabilityRetirement : Unit -> Sections.TerminationReason
 | Other : Unit -> Sections.TerminationReason
deriving DecidableEq, Inhabited

structure Sections.Individual where
  id : Int
  is_counterfactual : Bool
deriving DecidableEq, Inhabited

structure Sections.Household where
  id : Int
  is_counterfactual : Bool
deriving DecidableEq, Inhabited

structure MonthYear_en.MonthYear where
  year_number : Int
  month_name : MonthYear_en.Date_en.Month
deriving DecidableEq, Inhabited

structure Sections.Organization where
  id : Int
  organization_type : Sections.OrganizationType
  is_counterfactual : Bool
deriving DecidableEq, Inhabited

structure Sections.ImmigrationAdmissionEvent where
  id : Int
  individual : Sections.Individual
  visa_category : Sections.VisaCategory
  admission_date : CatalaRuntime.Date
  is_counterfactual : Bool
deriving DecidableEq, Inhabited

structure Sections.IndividualSection152QualifyingRelativeOutput where
  individual : Sections.Individual
  taxpayer : Sections.Individual
  is_qualifying_relative : Bool
  relationship_requirement_met_H : Bool
  relationship_requirement_met : Bool
  no_income_requirement_met : Bool
  not_qualifying_child_requirement_met : Bool
deriving DecidableEq, Inhabited

structure Sections.IndividualSection152QualifyingChildOutput where
  individual : Sections.Individual
  taxpayer : Sections.Individual
  is_qualifying_child : Bool
  relationship_requirement_met : Bool
  principal_place_of_abode_requirement_met : Bool
  age_requirement_met : Bool
  joint_return_exception_applies : Bool
deriving DecidableEq, Inhabited

structure Sections.IndividualSection151ExemptionOutput where
  individual : Sections.Individual
  exemption_amount_base : CatalaRuntime.Money
  exemption_amount_after_disallowance : CatalaRuntime.Money
  exemption_amount_after_phaseout : CatalaRuntime.Money
  number_of_personal_exemptions : Int
  personal_exemptions_deduction : CatalaRuntime.Money
  applicable_percentage : Rat
deriving DecidableEq, Inhabited

structure Sections.IndividualSection151ExemptionsListOutput where
  individual : Sections.Individual
  spouse_personal_exemption_allowed : Bool
  individuals_entitled_to_exemptions_under_151 : (List Sections.Individual)
deriving DecidableEq, Inhabited

structure Sections.TaxReturnEvent where
  id : Int
  individual : Sections.Individual
  tax_year : Int
  filed_joint_return : Bool
  is_only_for_refund_claim : Bool
  qualifying_children : (List Sections.Individual)
  dependents : (List Sections.Individual)
  is_counterfactual : Bool
deriving DecidableEq, Inhabited

structure Sections.IncomeEvent where
  id : Int
  individual : Sections.Individual
  tax_year : Int
  has_income : Bool
  earned_income : CatalaRuntime.Money
  is_counterfactual : Bool
deriving DecidableEq, Inhabited

structure Sections.FamilyRelationshipEvent where
  id : Int
  person : Sections.Individual
  relative : Sections.Individual
  start_date : CatalaRuntime.Date
  relationship_type : Sections.FamilyRelationshipType
  is_counterfactual : Bool
deriving DecidableEq, Inhabited

structure Sections.ParenthoodEvent where
  id : Int
  parent : Sections.Individual
  child : Sections.Individual
  start_date : CatalaRuntime.Date
  parent_type : Sections.ParentType
  is_counterfactual : Bool
deriving DecidableEq, Inhabited

structure Sections.DivorceOrLegalSeparationEvent where
  id : Int
  person1 : Sections.Individual
  person2 : Sections.Individual
  decree_date : CatalaRuntime.Date
  decree_type : Sections.DecreeType
  is_counterfactual : Bool
deriving DecidableEq, Inhabited

structure Sections.RemarriageEvent where
  id : Int
  individual : Sections.Individual
  remarriage_date : CatalaRuntime.Date
  is_counterfactual : Bool
deriving DecidableEq, Inhabited

structure Sections.MarriageEvent where
  id : Int
  spouse1 : Sections.Individual
  spouse2 : Sections.Individual
  marriage_date : CatalaRuntime.Date
  is_counterfactual : Bool
deriving DecidableEq, Inhabited

structure Sections.MarriedFilingSeparateVariant where
  taxpayer : Sections.Individual
  spouse : Sections.Individual
  itemization_election : Bool
  spouse_itemization_election : Bool
  is_estate_or_trust : Bool
  is_common_trust_fund : Bool
  is_partnership : Bool
deriving DecidableEq, Inhabited

structure Sections.SingleVariant where
  taxpayer : Sections.Individual
  itemization_election : Bool
  is_estate_or_trust : Bool
  is_common_trust_fund : Bool
  is_partnership : Bool
deriving DecidableEq, Inhabited

structure Sections.HeadOfHouseholdVariant where
  taxpayer : Sections.Individual
  qualifying_person : Sections.Individual
  itemization_election : Bool
  is_estate_or_trust : Bool
  is_common_trust_fund : Bool
  is_partnership : Bool
deriving DecidableEq, Inhabited

structure Sections.SurvivingSpouseVariant where
  taxpayer : Sections.Individual
  deceased_spouse : Sections.Individual
  qualifying_dependent : Sections.Individual
  itemization_election : Bool
  is_estate_or_trust : Bool
  is_common_trust_fund : Bool
  is_partnership : Bool
deriving DecidableEq, Inhabited

structure Sections.JointReturnVariant where
  taxpayer : Sections.Individual
  spouse : Sections.Individual
  itemization_election : Bool
  is_estate_or_trust : Bool
  is_common_trust_fund : Bool
  is_partnership : Bool
deriving DecidableEq, Inhabited

structure Sections.NonresidentAlienStatusPeriodEvent where
  id : Int
  individual : Sections.Individual
  start_date : CatalaRuntime.Date
  end_date : CatalaRuntime.Date
  residency_status : Sections.ResidencyStatus
  is_counterfactual : Bool
deriving DecidableEq, Inhabited

structure Sections.DeathEvent where
  id : Int
  decedent : Sections.Individual
  death_date : CatalaRuntime.Date
  is_counterfactual : Bool
deriving DecidableEq, Inhabited

structure Sections.BlindnessStatusEvent where
  id : Int
  individual : Sections.Individual
  status_date : CatalaRuntime.Date
  is_blind : Bool
  is_counterfactual : Bool
deriving DecidableEq, Inhabited

structure Sections.BirthEvent where
  id : Int
  individual : Sections.Individual
  birth_date : CatalaRuntime.Date
  is_counterfactual : Bool
deriving DecidableEq, Inhabited

structure Sections.IndividualSection7703MaritalStatusOutput where
  individual : Sections.Individual
  tax_year : Int
  determination_date : CatalaRuntime.Date
  is_married_at_determination_date : Bool
  is_legally_separated : Bool
  households_with_qualifying_child : (List Sections.Household)
  households_maintained_by_individual : (List Sections.Household)
  spouse_not_member_of_household_last_6_months : Bool
  subsection_b_exception_applies : Bool
  is_married_for_tax_purposes : Bool
deriving DecidableEq, Inhabited

structure Sections.HouseholdMaintenanceEvent where
  id : Int
  individual : Sections.Individual
  household : Sections.Household
  start_date : CatalaRuntime.Date
  end_date : CatalaRuntime.Date
  cost_furnished_percentage : Rat
  is_counterfactual : Bool
deriving DecidableEq, Inhabited

structure Sections.ResidencePeriodEvent where
  id : Int
  individual : Sections.Individual
  household : Sections.Household
  start_date : CatalaRuntime.Date
  end_date : CatalaRuntime.Date
  is_member_of_household : Bool
  is_principal_place_of_abode : Bool
  is_counterfactual : Bool
deriving DecidableEq, Inhabited

structure Sections.OrganizationSection3306EmployerStatusOutput where
  organization : Sections.Organization
  is_employer : Bool
  is_general_employer : Bool
  is_agricultural_employer : Bool
  is_domestic_service_employer : Bool
deriving DecidableEq, Inhabited

structure Sections.EmployerDomesticServiceVariant where
  employer : Sections.Organization
deriving DecidableEq, Inhabited

structure Sections.EmployerAgriculturalLaborVariant where
  employer : Sections.Organization
deriving DecidableEq, Inhabited

structure Sections.EmployerGeneralVariant where
  employer : Sections.Organization
deriving DecidableEq, Inhabited

structure Sections.EmploymentTerminationEvent where
  id : Int
  employer : Sections.Organization
  employee : Sections.Individual
  termination_date : CatalaRuntime.Date
  reason : Sections.TerminationReason
  is_counterfactual : Bool
deriving DecidableEq, Inhabited

structure Sections.HospitalPatientEvent where
  id : Int
  patient : Sections.Individual
  hospital : Sections.Organization
  start_date : CatalaRuntime.Date
  end_date : CatalaRuntime.Date
  is_counterfactual : Bool
deriving DecidableEq, Inhabited

structure Sections.StudentEnrollmentEvent where
  id : Int
  student : Sections.Individual
  institution : Sections.Organization
  start_date : CatalaRuntime.Date
  end_date : CatalaRuntime.Date
  is_regularly_attending : Bool
  is_counterfactual : Bool
deriving DecidableEq, Inhabited

structure Sections.WagePaymentEvent where
  id : Int
  employer : Sections.Organization
  employee : Sections.Individual
  payment_date : CatalaRuntime.Date
  amount : CatalaRuntime.Money
  payment_medium : Sections.PaymentMedium
  payment_reason : Sections.PaymentReason
  is_under_plan_or_system : Bool
  is_for_employee_generally : Bool
  is_for_class_of_employees : Bool
  is_for_dependents : Bool
  is_not_in_course_of_trade_or_business : Bool
  would_have_been_paid_without_termination : Bool
  is_paid_to_survivor_or_estate : Bool
  is_counterfactual : Bool
deriving DecidableEq, Inhabited

structure Sections.EmploymentRelationshipEvent where
  id : Int
  employer : Sections.Organization
  employee : Sections.Individual
  start_date : CatalaRuntime.Date
  end_date : CatalaRuntime.Date
  employment_category : Sections.EmploymentCategory
  service_location : Sections.ServiceLocation
  is_american_employer : Bool
  employee_is_us_citizen : Bool
  is_counterfactual : Bool
deriving DecidableEq, Inhabited

structure Sections.IndividualSection152DependentsOutput where
  taxpayer : Sections.Individual
  dependents_initial : (List Sections.Individual)
  dependents_after_152b1 : (List Sections.Individual)
  dependents_after_152b2 : (List Sections.Individual)
  qualifying_children : (List Sections.IndividualSection152QualifyingChildOutput)
  qualifying_relatives : (List Sections.IndividualSection152QualifyingRelativeOutput)
deriving DecidableEq, Inhabited

structure Sections.TaxpayerExemptionsListOutput where
  taxpayer_result : Sections.IndividualSection151ExemptionsListOutput
  spouse_result : (Optional Sections.IndividualSection151ExemptionsListOutput)
  individuals_entitled_to_exemptions_under_151 : (List Sections.Individual)
  spouse_personal_exemption_allowed : Bool
deriving DecidableEq, Inhabited

inductive Sections.FilingStatusVariant : Type where
 | JointReturn : Sections.JointReturnVariant -> Sections.FilingStatusVariant
 | SurvivingSpouse : Sections.SurvivingSpouseVariant -> Sections.FilingStatusVariant
 | HeadOfHousehold : Sections.HeadOfHouseholdVariant -> Sections.FilingStatusVariant
 | Single : Sections.SingleVariant -> Sections.FilingStatusVariant
 | MarriedFilingSeparate : Sections.MarriedFilingSeparateVariant -> Sections.FilingStatusVariant
deriving DecidableEq, Inhabited

inductive Sections.EmployerVariant : Type where
 | GeneralEmployer : Sections.EmployerGeneralVariant -> Sections.EmployerVariant
 | AgriculturalEmployer : Sections.EmployerAgriculturalLaborVariant -> Sections.EmployerVariant
 | DomesticServiceEmployer : Sections.EmployerDomesticServiceVariant -> Sections.EmployerVariant
deriving DecidableEq, Inhabited

structure Sections.WagePaymentEventSection3306WagesOutput where
  wage_payment_event : Sections.WagePaymentEvent
  is_excluded_by_sickness_disability_death : Bool
  is_excluded_by_nonbusiness_service : Bool
  is_excluded_by_termination_payment : Bool
  is_excluded_by_agricultural_noncash : Bool
  is_excluded_by_survivor_payment : Bool
  taxable_amount_before_7000_cap : CatalaRuntime.Money
deriving DecidableEq, Inhabited

structure Sections.EmploymentRelationshipEventSection3306EmploymentOutput where
  employment_relationship_event : Sections.EmploymentRelationshipEvent
  is_employment : Bool
  is_excluded_agricultural_labor : Bool
  is_excluded_domestic_service : Bool
  is_excluded_family_employment : Bool
  is_excluded_federal_government : Bool
  is_excluded_state_government : Bool
  is_excluded_student_service : Bool
  is_excluded_hospital_patient_service : Bool
  is_excluded_foreign_government : Bool
  is_excluded_student_nurse : Bool
  is_excluded_international_organization : Bool
  is_excluded_penal_institution : Bool
deriving DecidableEq, Inhabited

structure Sections.IndividualTaxReturn where
  id : Int
  tax_year : Int
  details : Sections.FilingStatusVariant
deriving DecidableEq, Inhabited

structure Sections.EmployerUnemploymentExciseTaxReturn where
  id : Int
  tax_year : Int
  details : Sections.EmployerVariant
deriving DecidableEq, Inhabited

structure Sections.TotalWages3306CalculationOutput where
  total_taxable_wages : CatalaRuntime.Money
  wage_results_with_cap : (List Sections.WagePaymentEventSection3306WagesOutput)
deriving DecidableEq, Inhabited

structure Sections.EmployerUnemploymentExciseTaxFilerSection3301TaxOutput where
  employer_unemployment_excise_tax_return : Sections.EmployerUnemploymentExciseTaxReturn
  total_taxable_wages : CatalaRuntime.Money
  excise_tax : CatalaRuntime.Money
  tax_rate : Rat
deriving DecidableEq, Inhabited

def Sections.is_tax_year_2018_through_2025 := (fun (tax_year_arg : Int) => ((decide (tax_year_arg ≥ (2018 : Int))) && (decide (tax_year_arg ≤ (2025 : Int)))))

def Sections.individual_is_blind_at_close := (fun (individual_arg : Sections.Individual) (blindness_status_events_arg : (List Sections.BlindnessStatusEvent)) (death_events_arg : (List Sections.DeathEvent)) (year_end_arg : CatalaRuntime.Date) => (List.foldl ((fun (acc : Bool) (blindness_event : Sections.BlindnessStatusEvent) => ((decide (acc)) || ((decide ((blindness_event).individual = individual_arg)) && ((decide ((blindness_event).status_date ≤ year_end_arg)) && ((decide ((blindness_event).is_blind)) && (!(decide ((List.foldl ((fun (acc : Bool) (death_event : Sections.DeathEvent) => ((decide (acc)) || ((decide ((death_event).decedent = individual_arg)) && ((decide ((death_event).death_date < (blindness_event).status_date)) && (decide ((death_event).death_date ≤ year_end_arg))))))) false death_events_arg)))))))))) false blindness_status_events_arg))

def Sections.get_taxpayer := (fun (individual_tax_return_arg : Sections.IndividualTaxReturn) => (match (individual_tax_return_arg).details with | Sections.FilingStatusVariant.JointReturn variant => (variant).taxpayer | Sections.FilingStatusVariant.SurvivingSpouse variant => (variant).taxpayer | Sections.FilingStatusVariant.HeadOfHousehold variant => (variant).taxpayer | Sections.FilingStatusVariant.Single variant => (variant).taxpayer | Sections.FilingStatusVariant.MarriedFilingSeparate variant => (variant).taxpayer))

def Sections.get_spouse := (fun (individual_tax_return_arg : Sections.IndividualTaxReturn) => (match (individual_tax_return_arg).details with | Sections.FilingStatusVariant.JointReturn variant => (Optional.Present (variant).spouse) | Sections.FilingStatusVariant.SurvivingSpouse variant => (Optional.Present (variant).deceased_spouse) | Sections.FilingStatusVariant.HeadOfHousehold variant => (Optional.Absent ()) | Sections.FilingStatusVariant.Single variant => (Optional.Absent ()) | Sections.FilingStatusVariant.MarriedFilingSeparate variant => (Optional.Present (variant).spouse)))

def Sections.extract_spouse_itemization_election := (fun (individual_tax_return_arg : Sections.IndividualTaxReturn) => (match (individual_tax_return_arg).details with | Sections.FilingStatusVariant.JointReturn variant => false | Sections.FilingStatusVariant.SurvivingSpouse variant => false | Sections.FilingStatusVariant.HeadOfHousehold variant => false | Sections.FilingStatusVariant.Single variant => false | Sections.FilingStatusVariant.MarriedFilingSeparate variant => (variant).spouse_itemization_election))

def Sections.individual_is_nonresident_alien_during_year := (fun (individual_arg : Sections.Individual) (nonresident_alien_status_period_events_arg : (List Sections.NonresidentAlienStatusPeriodEvent)) (tax_year_arg : Int) (year_end_arg : CatalaRuntime.Date) => (List.foldl ((fun (acc : Bool) (residency_event : Sections.NonresidentAlienStatusPeriodEvent) => ((decide (acc)) || ((decide ((residency_event).individual = individual_arg)) && ((decide ((residency_event).start_date ≤ year_end_arg)) && ((decide ((residency_event).end_date ≥ (Date_en.of_year_month_day tax_year_arg (1 : Int) (1 : Int)))) && (decide ((residency_event).residency_status = (ResidencyStatus.NonresidentAlien ()))))))))) false nonresident_alien_status_period_events_arg))

def Sections.get_year_end := (fun (tax_year_arg : Int) => (Date_en.of_year_month_day tax_year_arg (12 : Int) (31 : Int)))

def Sections.section_2_most_recent_spouse_death_date := (fun (spouse_death_events_in_window_arg : (List Sections.DeathEvent)) (tax_year_arg : Int) => (if (decide ((spouse_death_events_in_window_arg).length > (0 : Int))) then (match (List.map ((fun (death_event : Sections.DeathEvent) => (death_event).death_date)) spouse_death_events_in_window_arg) with | [] => (fun () => default /-unsupported expression-/) () | x0 :: xn => List.foldl (fun (max1 : CatalaRuntime.Date) (max2 : CatalaRuntime.Date) => (if (decide (max1 > max2)) then max1 else max2)) x0 xn) else (Date_en.of_year_month_day tax_year_arg (1 : Int) (1 : Int))))

def Sections.individual_attained_age_65 := (fun (individual_arg : Sections.Individual) (birth_events_arg : (List Sections.BirthEvent)) (year_end_arg : CatalaRuntime.Date) => (List.foldl ((fun (acc : Bool) (birth_event : Sections.BirthEvent) => ((decide (acc)) || ((decide ((birth_event).individual = individual_arg)) && (decide ((Date_en.is_old_enough_rounding_down (birth_event).birth_date (CatalaRuntime.Duration.create 65 0 0) year_end_arg))))))) false birth_events_arg))

def Sections.section_2_spouse_death_year := (fun (spouse_death_events_in_window_arg : (List Sections.DeathEvent)) => (if (decide ((spouse_death_events_in_window_arg).length > (0 : Int))) then (Optional.Present (match (List.map ((fun (death_event : Sections.DeathEvent) => (Date_en.get_year (death_event).death_date))) spouse_death_events_in_window_arg) with | [] => (fun () => default /-unsupported expression-/) () | x0 :: xn => List.foldl (fun (max1 : Int) (max2 : Int) => (if (decide (max1 > max2)) then max1 else max2)) x0 xn)) else (Optional.Absent ())))

def Sections.section_2_spouse_death_events_in_window := (fun (spouse_arg : (Optional Sections.Individual)) (death_events_arg : (List Sections.DeathEvent)) (tax_year_arg : Int) => (match spouse_arg with | Optional.Absent _ => (List.filter ((fun (death_event : Sections.DeathEvent) => false)) death_events_arg) | Optional.Present s => (List.filter ((fun (death_event : Sections.DeathEvent) => ((decide ((death_event).decedent = s)) && ((decide ((Date_en.get_year (death_event).death_date) ≥ (tax_year_arg - (2 : Int)))) && (decide ((Date_en.get_year (death_event).death_date) < tax_year_arg)))))) death_events_arg)))

structure Sections.IndividualSection152QualifyingChild_Input where
  tax_return_events : (List Sections.TaxReturnEvent)
  residence_period_events : (List Sections.ResidencePeriodEvent)
  birth_events : (List Sections.BirthEvent)
  family_relationship_events : (List Sections.FamilyRelationshipEvent)
  tax_year : Int
  taxpayer : Sections.Individual
  individual : Sections.Individual
  relationship_requirement_met : Bool := (List.foldl ((fun (acc : Bool) (rel_event : Sections.FamilyRelationshipEvent) => ((decide (acc)) || ((decide ((rel_event).person = taxpayer)) && ((decide ((rel_event).relative = individual)) && ((decide ((rel_event).start_date ≤ (Date_en.of_year_month_day tax_year (12 : Int) (31 : Int)))) && ((decide ((rel_event).relationship_type = (FamilyRelationshipType.Child ()))) || ((decide ((rel_event).relationship_type = (FamilyRelationshipType.DescendantOfChild ()))) || ((decide ((rel_event).relationship_type = (FamilyRelationshipType.Brother ()))) || ((decide ((rel_event).relationship_type = (FamilyRelationshipType.Sister ()))) || ((decide ((rel_event).relationship_type = (FamilyRelationshipType.Stepbrother ()))) || ((decide ((rel_event).relationship_type = (FamilyRelationshipType.Stepsister ()))) || (decide ((rel_event).relationship_type = (FamilyRelationshipType.DescendantOfSibling ()))))))))))))))) false family_relationship_events)
  age_requirement_met : Bool := ((fun (year_end : CatalaRuntime.Date) => ((fun (individual_birth_date : CatalaRuntime.Date) => ((fun (taxpayer_birth_date : CatalaRuntime.Date) => ((decide (individual_birth_date > taxpayer_birth_date)) && (decide ((Date_en.is_young_enough_rounding_down individual_birth_date (CatalaRuntime.Duration.create 25 0 0) year_end))))) (if (List.foldl ((fun (acc : Bool) (birth_event : Sections.BirthEvent) => ((decide (acc)) || (decide ((birth_event).individual = taxpayer))))) false birth_events) then (match (List.map ((fun (birth_event : Sections.BirthEvent) => (birth_event).birth_date)) (List.filter ((fun (birth_event : Sections.BirthEvent) => (decide ((birth_event).individual = taxpayer)))) birth_events)) with | [] => (fun () => default /-unsupported expression-/) () | x0 :: xn => List.foldl (fun (min1 : CatalaRuntime.Date) (min2 : CatalaRuntime.Date) => (if (decide (min1 < min2)) then min1 else min2)) x0 xn) else (Date_en.of_year_month_day (1900 : Int) (1 : Int) (1 : Int))))) (if (List.foldl ((fun (acc : Bool) (birth_event : Sections.BirthEvent) => ((decide (acc)) || (decide ((birth_event).individual = individual))))) false birth_events) then (match (List.map ((fun (birth_event : Sections.BirthEvent) => (birth_event).birth_date)) (List.filter ((fun (birth_event : Sections.BirthEvent) => (decide ((birth_event).individual = individual)))) birth_events)) with | [] => (fun () => default /-unsupported expression-/) () | x0 :: xn => List.foldl (fun (min1 : CatalaRuntime.Date) (min2 : CatalaRuntime.Date) => (if (decide (min1 < min2)) then min1 else min2)) x0 xn) else (Date_en.of_year_month_day (1900 : Int) (1 : Int) (1 : Int))))) (Date_en.of_year_month_day tax_year (12 : Int) (31 : Int)))
  principal_place_of_abode_requirement_met : Bool := ((fun (year_start : CatalaRuntime.Date) => ((fun (year_end : CatalaRuntime.Date) => ((fun (year_midpoint : CatalaRuntime.Date) => (List.foldl ((fun (acc : Bool) (taxpayer_residence : Sections.ResidencePeriodEvent) => ((decide (acc)) || ((decide ((taxpayer_residence).individual = taxpayer)) && ((decide ((taxpayer_residence).is_principal_place_of_abode)) && ((decide ((taxpayer_residence).start_date ≤ year_end)) && ((decide ((taxpayer_residence).end_date ≥ year_start)) && (decide ((List.foldl ((fun (acc : Bool) (individual_residence : Sections.ResidencePeriodEvent) => ((decide (acc)) || ((decide ((individual_residence).individual = individual)) && ((decide ((individual_residence).household = (taxpayer_residence).household)) && ((decide ((individual_residence).is_principal_place_of_abode)) && ((decide ((individual_residence).start_date ≤ year_midpoint)) && ((decide ((individual_residence).end_date ≥ (Date_en.of_year_month_day tax_year (7 : Int) (1 : Int)))) && ((decide ((individual_residence).start_date ≤ year_end)) && (decide ((individual_residence).end_date ≥ year_start))))))))))) false residence_period_events)))))))))) false residence_period_events)) (Date_en.of_year_month_day tax_year (6 : Int) (30 : Int)))) (Date_en.of_year_month_day tax_year (12 : Int) (31 : Int)))) (Date_en.of_year_month_day tax_year (1 : Int) (1 : Int)))
  joint_return_exception_applies : Bool := (List.foldl ((fun (acc : Bool) (event : Sections.TaxReturnEvent) => ((decide (acc)) || ((decide ((event).individual = individual)) && ((decide ((event).tax_year = tax_year)) && ((decide ((event).filed_joint_return)) && (!(decide ((event).is_only_for_refund_claim))))))))) false tax_return_events)
  is_qualifying_child : Bool := ((decide (relationship_requirement_met)) && ((decide (principal_place_of_abode_requirement_met)) && ((decide (age_requirement_met)) && (!(decide (joint_return_exception_applies))))))

def Sections.IndividualSection152QualifyingChild_main_output_leaf_0 (input : Sections.IndividualSection152QualifyingChild_Input) : Option Sections.IndividualSection152QualifyingChildOutput :=
  some (({ individual := input.individual, taxpayer := input.taxpayer, is_qualifying_child := input.is_qualifying_child, relationship_requirement_met := input.relationship_requirement_met, principal_place_of_abode_requirement_met := input.principal_place_of_abode_requirement_met, age_requirement_met := input.age_requirement_met, joint_return_exception_applies := input.joint_return_exception_applies } : IndividualSection152QualifyingChildOutput))

structure Sections.IndividualSection152QualifyingChild where
  main_output : Sections.IndividualSection152QualifyingChildOutput
deriving DecidableEq, Inhabited
def Sections.individualSection152QualifyingChild (input : Sections.IndividualSection152QualifyingChild_Input) : Sections.IndividualSection152QualifyingChild :=
  let main_output := match Sections.IndividualSection152QualifyingChild_main_output_leaf_0 input with | some val => val | _ => default 
  { main_output := main_output }

structure Sections.OrganizationSection3306EmployerStatus_Input where
  employment_relationship_events : (List Sections.EmploymentRelationshipEvent)
  wage_payment_events : (List Sections.WagePaymentEvent)
  calendar_year : Int
  organization : Sections.Organization
  section_3306_employment_overlaps_date : (Sections.EmploymentRelationshipEvent → CatalaRuntime.Date → Bool) := fun (emp_event_arg : Sections.EmploymentRelationshipEvent) (check_date_arg : CatalaRuntime.Date) => ((decide ((emp_event_arg).start_date ≤ check_date_arg)) && (decide ((emp_event_arg).end_date ≥ check_date_arg)))
  section_3306_count_unique_employees : ((List Sections.EmploymentRelationshipEvent) → Int) := fun (employment_events_arg : (List Sections.EmploymentRelationshipEvent)) => ((fun (unique_employee_events : (List Sections.EmploymentRelationshipEvent)) => (unique_employee_events).length) (List.filter ((fun (emp_event : Sections.EmploymentRelationshipEvent) => (!(decide ((List.foldl ((fun (acc : Bool) (prev_emp_event : Sections.EmploymentRelationshipEvent) => ((decide (acc)) || ((decide (((prev_emp_event).employee).id = ((emp_event).employee).id)) && (decide ((prev_emp_event).id < (emp_event).id)))))) false employment_events_arg)))))) employment_events_arg))
  section_3306_get_day_of_year : (CatalaRuntime.Date → Int) := fun (date_arg : CatalaRuntime.Date) => ((fun (year_local : Int) => ((fun (month_local : Int) => ((fun (day_local : Int) => ((fun (year_div_4 : Rat) => ((fun (year_mod_4 : Int) => ((fun (year_div_100 : Rat) => ((fun (year_mod_100 : Int) => ((fun (year_div_400 : Rat) => ((fun (year_mod_400 : Int) => ((fun (is_leap_year_local : Bool) => ((fun (days_before_month : Int) => (days_before_month + day_local)) (if (decide (month_local = (1 : Int))) then (0 : Int) else (if (decide (month_local = (2 : Int))) then (31 : Int) else (if (decide (month_local = (3 : Int))) then (if is_leap_year_local then (60 : Int) else (59 : Int)) else (if (decide (month_local = (4 : Int))) then (if is_leap_year_local then (91 : Int) else (90 : Int)) else (if (decide (month_local = (5 : Int))) then (if is_leap_year_local then (121 : Int) else (120 : Int)) else (if (decide (month_local = (6 : Int))) then (if is_leap_year_local then (152 : Int) else (151 : Int)) else (if (decide (month_local = (7 : Int))) then (if is_leap_year_local then (182 : Int) else (181 : Int)) else (if (decide (month_local = (8 : Int))) then (if is_leap_year_local then (213 : Int) else (212 : Int)) else (if (decide (month_local = (9 : Int))) then (if is_leap_year_local then (244 : Int) else (243 : Int)) else (if (decide (month_local = (10 : Int))) then (if is_leap_year_local then (274 : Int) else (273 : Int)) else (if (decide (month_local = (11 : Int))) then (if is_leap_year_local then (305 : Int) else (304 : Int)) else (if is_leap_year_local then (335 : Int) else (334 : Int))))))))))))))) (((decide (year_mod_4 = (0 : Int))) && (!(decide (year_mod_100 = (0 : Int))))) || (decide (year_mod_400 = (0 : Int)))))) (year_local - (CatalaRuntime.multiply (Rat.floor year_div_400) (400 : Int))))) (year_local / (400 : Int)))) (year_local - (CatalaRuntime.multiply (Rat.floor year_div_100) (100 : Int))))) (year_local / (100 : Int)))) (year_local - (CatalaRuntime.multiply (Rat.floor year_div_4) (4 : Int))))) (year_local / (4 : Int)))) (Date_en.get_day date_arg))) (Date_en.get_month date_arg))) (Date_en.get_year date_arg))
  is_domestic_service_employer : Bool := ((fun (relevant_wage_events : (List Sections.WagePaymentEvent)) => ((fun (total_domestic_service_wages : CatalaRuntime.Money) => (decide (total_domestic_service_wages ≥ (CatalaRuntime.Money.ofCents 100000)))) (match (List.map ((fun (wage_event : Sections.WagePaymentEvent) => (wage_event).amount)) relevant_wage_events) with | [] => (fun () => (CatalaRuntime.Money.ofCents 0)) () | x0 :: xn => List.foldl (fun (sum1 : CatalaRuntime.Money) (sum2 : CatalaRuntime.Money) => (sum1 + sum2)) x0 xn))) (List.filter ((fun (wage_event : Sections.WagePaymentEvent) => ((decide (((wage_event).employer).id = (organization).id)) && ((decide ((wage_event).payment_medium = (PaymentMedium.Cash ()))) && (((decide ((Date_en.get_year (wage_event).payment_date) = calendar_year)) || (decide ((Date_en.get_year (wage_event).payment_date) = (calendar_year - (1 : Int))))) && (decide ((List.foldl ((fun (acc : Bool) (emp_event : Sections.EmploymentRelationshipEvent) => ((decide (acc)) || ((decide (((emp_event).employer).id = (organization).id)) && ((decide (((emp_event).employee).id = ((wage_event).employee).id)) && (decide ((emp_event).employment_category = (EmploymentCategory.DomesticService ())))))))) false employment_relationship_events)))))))) wage_payment_events))
  section_3306_get_candidate_dates_in_year : ((List Sections.EmploymentRelationshipEvent) → Int → (List CatalaRuntime.Date)) := fun (employment_events_arg : (List Sections.EmploymentRelationshipEvent)) (target_year_arg : Int) => ((fun (year_start : CatalaRuntime.Date) => ((fun (year_end : CatalaRuntime.Date) => ((fun (all_year_days : (List CatalaRuntime.Date)) => (List.filter ((fun (check_date : CatalaRuntime.Date) => ((decide ((Date_en.get_year check_date) = target_year_arg)) && (decide ((List.foldl ((fun (acc : Bool) (emp_event : Sections.EmploymentRelationshipEvent) => ((decide (acc)) || (decide ((section_3306_employment_overlaps_date emp_event check_date)))))) false employment_events_arg)))))) all_year_days)) (List.map ((fun (day_num : Int) => (year_start + (CatalaRuntime.multiply (day_num - (1 : Int)) (CatalaRuntime.Duration.create 0 0 1))))) (List_en.sequence (1 : Int) (366 : Int))))) (Date_en.of_year_month_day target_year_arg (12 : Int) (31 : Int)))) (Date_en.of_year_month_day target_year_arg (1 : Int) (1 : Int)))
  section_3306_get_calendar_week_us : (CatalaRuntime.Date → (Int × Int)) := fun (date_arg : CatalaRuntime.Date) => ((fun (year_local : Int) => ((fun (day_of_year : Int) => ((fun (days_minus_one : Int) => ((fun (week_decimal : Rat) => ((fun (week_number : Int) => (year_local, week_number)) ((Rat.floor week_decimal) + (1 : Int)))) ((CatalaRuntime.toRat days_minus_one) / (Rat.mk 7 1)))) (day_of_year - (1 : Int)))) (section_3306_get_day_of_year date_arg))) (Date_en.get_year date_arg))
  section_3306_get_days_with_employment : ((List Sections.EmploymentRelationshipEvent) → Int → Int → (List CatalaRuntime.Date)) := fun (employment_events_arg : (List Sections.EmploymentRelationshipEvent)) (target_year_arg : Int) (min_individuals_arg : Int) => ((fun (candidate_dates : (List CatalaRuntime.Date)) => (List.filter ((fun (candidate_date : CatalaRuntime.Date) => ((fun (employment_events_on_day : (List Sections.EmploymentRelationshipEvent)) => ((fun (unique_employee_count : Int) => (decide (unique_employee_count ≥ min_individuals_arg))) (section_3306_count_unique_employees employment_events_on_day))) (List.filter ((fun (emp_event : Sections.EmploymentRelationshipEvent) => (section_3306_employment_overlaps_date emp_event candidate_date))) employment_events_arg)))) candidate_dates)) (section_3306_get_candidate_dates_in_year employment_events_arg target_year_arg))
  section_3306_get_week_identifier : (CatalaRuntime.Date → (Int × Int)) := fun (date_arg : CatalaRuntime.Date) => (section_3306_get_calendar_week_us date_arg)
  section_3306_count_unique_calendar_weeks : ((List CatalaRuntime.Date) → Int) := fun (dates_arg : (List CatalaRuntime.Date)) => ((fun (unique_dates : (List CatalaRuntime.Date)) => (unique_dates).length) (List.filter ((fun (date_item : CatalaRuntime.Date) => ((fun (current_week_id : (Int × Int)) => (!(decide ((List.foldl ((fun (acc : Bool) (prev_date : CatalaRuntime.Date) => ((decide (acc)) || ((decide (prev_date < date_item)) && (decide ((section_3306_get_week_identifier prev_date) = current_week_id)))))) false dates_arg))))) (section_3306_get_week_identifier date_item)))) dates_arg))
  section_3306_has_ten_days_in_different_weeks : ((List Sections.EmploymentRelationshipEvent) → Int → Int → Bool) := fun (employment_events_arg : (List Sections.EmploymentRelationshipEvent)) (target_year_arg : Int) (min_individuals_arg : Int) => ((fun (days_current_year : (List CatalaRuntime.Date)) => ((fun (preceding_year : Int) => ((fun (days_preceding_year : (List CatalaRuntime.Date)) => ((fun (all_days : (List CatalaRuntime.Date)) => ((fun (unique_week_count : Int) => (decide (unique_week_count ≥ (10 : Int)))) (section_3306_count_unique_calendar_weeks all_days))) (days_current_year ++ days_preceding_year))) (section_3306_get_days_with_employment employment_events_arg preceding_year min_individuals_arg))) (target_year_arg - (1 : Int)))) (section_3306_get_days_with_employment employment_events_arg target_year_arg min_individuals_arg))
  is_agricultural_employer : Bool := (match (match processExceptions [if ((fun (relevant_employment_events : (List Sections.EmploymentRelationshipEvent)) => (section_3306_has_ten_days_in_different_weeks relevant_employment_events calendar_year (5 : Int))) (List.filter ((fun (emp_event : Sections.EmploymentRelationshipEvent) => ((decide (((emp_event).employer).id = (organization).id)) && ((decide ((emp_event).employment_category = (EmploymentCategory.AgriculturalLabor ()))) && ((decide ((Date_en.get_year (emp_event).start_date) = calendar_year)) || ((decide ((Date_en.get_year (emp_event).start_date) = (calendar_year - (1 : Int)))) || ((decide ((Date_en.get_year (emp_event).end_date) = calendar_year)) || (decide ((Date_en.get_year (emp_event).end_date) = (calendar_year - (1 : Int))))))))))) employment_relationship_events)) then some (true) else none] with | none => some (((fun (relevant_wage_events : (List Sections.WagePaymentEvent)) => ((fun (total_agricultural_wages : CatalaRuntime.Money) => (decide (total_agricultural_wages ≥ (CatalaRuntime.Money.ofCents 2000000)))) (match (List.map ((fun (wage_event : Sections.WagePaymentEvent) => (wage_event).amount)) relevant_wage_events) with | [] => (fun () => (CatalaRuntime.Money.ofCents 0)) () | x0 :: xn => List.foldl (fun (sum1 : CatalaRuntime.Money) (sum2 : CatalaRuntime.Money) => (sum1 + sum2)) x0 xn))) (List.filter ((fun (wage_event : Sections.WagePaymentEvent) => ((decide (((wage_event).employer).id = (organization).id)) && (((decide ((Date_en.get_year (wage_event).payment_date) = calendar_year)) || (decide ((Date_en.get_year (wage_event).payment_date) = (calendar_year - (1 : Int))))) && (decide ((List.foldl ((fun (acc : Bool) (emp_event : Sections.EmploymentRelationshipEvent) => ((decide (acc)) || ((decide (((emp_event).employer).id = (organization).id)) && ((decide (((emp_event).employee).id = ((wage_event).employee).id)) && (decide ((emp_event).employment_category = (EmploymentCategory.AgriculturalLabor ())))))))) false employment_relationship_events))))))) wage_payment_events))) | some r => some r) with | some r => r | _ => default)
  is_general_employer : Bool := (match (match processExceptions [if ((fun (relevant_employment_events : (List Sections.EmploymentRelationshipEvent)) => (section_3306_has_ten_days_in_different_weeks relevant_employment_events calendar_year (1 : Int))) (List.filter ((fun (emp_event : Sections.EmploymentRelationshipEvent) => ((decide (((emp_event).employer).id = (organization).id)) && (((decide ((Date_en.get_year (emp_event).start_date) = calendar_year)) || ((decide ((Date_en.get_year (emp_event).start_date) = (calendar_year - (1 : Int)))) || ((decide ((Date_en.get_year (emp_event).end_date) = calendar_year)) || (decide ((Date_en.get_year (emp_event).end_date) = (calendar_year - (1 : Int))))))) && (!(decide ((emp_event).employment_category = (EmploymentCategory.DomesticService ())))))))) employment_relationship_events)) then some (true) else none] with | none => some (((fun (relevant_wage_events : (List Sections.WagePaymentEvent)) => ((fun (total_wages : CatalaRuntime.Money) => (decide (total_wages ≥ (CatalaRuntime.Money.ofCents 150000)))) (match (List.map ((fun (wage_event : Sections.WagePaymentEvent) => (wage_event).amount)) relevant_wage_events) with | [] => (fun () => (CatalaRuntime.Money.ofCents 0)) () | x0 :: xn => List.foldl (fun (sum1 : CatalaRuntime.Money) (sum2 : CatalaRuntime.Money) => (sum1 + sum2)) x0 xn))) (List.filter ((fun (wage_event : Sections.WagePaymentEvent) => ((decide (((wage_event).employer).id = (organization).id)) && (((decide ((Date_en.get_year (wage_event).payment_date) = calendar_year)) || (decide ((Date_en.get_year (wage_event).payment_date) = (calendar_year - (1 : Int))))) && (!(decide ((List.foldl ((fun (acc : Bool) (emp_event : Sections.EmploymentRelationshipEvent) => ((decide (acc)) || ((decide (((emp_event).employer).id = (organization).id)) && ((decide (((emp_event).employee).id = ((wage_event).employee).id)) && (decide ((emp_event).employment_category = (EmploymentCategory.DomesticService ())))))))) false employment_relationship_events)))))))) wage_payment_events))) | some r => some r) with | some r => r | _ => default)
  is_employer : Bool := ((decide (is_general_employer)) || ((decide (is_agricultural_employer)) || (decide (is_domestic_service_employer))))

def Sections.OrganizationSection3306EmployerStatus_main_output_leaf_0 (input : Sections.OrganizationSection3306EmployerStatus_Input) : Option Sections.OrganizationSection3306EmployerStatusOutput :=
  some (({ organization := input.organization, is_employer := input.is_employer, is_general_employer := input.is_general_employer, is_agricultural_employer := input.is_agricultural_employer, is_domestic_service_employer := input.is_domestic_service_employer } : OrganizationSection3306EmployerStatusOutput))

structure Sections.OrganizationSection3306EmployerStatus where
  main_output : Sections.OrganizationSection3306EmployerStatusOutput
deriving DecidableEq, Inhabited
def Sections.organizationSection3306EmployerStatus (input : Sections.OrganizationSection3306EmployerStatus_Input) : Sections.OrganizationSection3306EmployerStatus :=
  let main_output := match Sections.OrganizationSection3306EmployerStatus_main_output_leaf_0 input with | some val => val | _ => default 
  { main_output := main_output }

structure Sections.WagePaymentEventSection3306Wages_Input where
  death_events : (List Sections.DeathEvent)
  employment_termination_events : (List Sections.EmploymentTerminationEvent)
  wage_payment_event : Sections.WagePaymentEvent
  is_excluded_by_agricultural_noncash : Bool := ((decide ((wage_payment_event).payment_medium = (PaymentMedium.NonCash ()))) && (decide ((wage_payment_event).payment_reason = (PaymentReason.AgriculturalLaborNonCash ()))))
  is_excluded_by_nonbusiness_service : Bool := ((decide ((wage_payment_event).payment_medium = (PaymentMedium.NonCash ()))) && (decide ((wage_payment_event).is_not_in_course_of_trade_or_business)))
  is_excluded_by_sickness_disability_death : Bool := (((decide ((wage_payment_event).payment_reason = (PaymentReason.SicknessOrAccidentDisability ()))) || (decide ((wage_payment_event).payment_reason = (PaymentReason.Death ())))) && ((decide ((wage_payment_event).is_under_plan_or_system)) && ((decide ((wage_payment_event).is_for_employee_generally)) || (decide ((wage_payment_event).is_for_class_of_employees)))))
  is_excluded_by_termination_payment : Bool := ((fun (is_termination_payment : Bool) => ((fun (termination_condition_A_met : Bool) => ((fun (plan_condition_B_met : Bool) => (((decide (is_termination_payment)) && ((decide (termination_condition_A_met)) && (!(decide ((wage_payment_event).would_have_been_paid_without_termination))))) && (decide (plan_condition_B_met)))) ((decide ((wage_payment_event).is_under_plan_or_system)) && ((decide ((wage_payment_event).is_for_employee_generally)) || (decide ((wage_payment_event).is_for_class_of_employees)))))) (List.foldl ((fun (acc : Bool) (term_event : Sections.EmploymentTerminationEvent) => ((decide (acc)) || ((decide (((term_event).employer).id = ((wage_payment_event).employer).id)) && ((decide (((term_event).employee).id = ((wage_payment_event).employee).id)) && (((decide ((term_event).reason = (TerminationReason.Death ()))) || (decide ((term_event).reason = (TerminationReason.DisabilityRetirement ())))) && (decide ((term_event).termination_date ≤ (wage_payment_event).payment_date)))))))) false employment_termination_events))) (decide ((wage_payment_event).payment_reason = (PaymentReason.TerminationAfterDeathOrDisabilityRetirement ()))))
  is_excluded_by_survivor_payment : Bool := ((fun (is_paid_to_survivor_or_estate : Bool) => ((fun (payment_year : Int) => ((fun (employee_local : Sections.Individual) => ((fun (employee_died_in_previous_year : Bool) => ((decide (is_paid_to_survivor_or_estate)) && (decide (employee_died_in_previous_year)))) (List.foldl ((fun (acc : Bool) (death_event : Sections.DeathEvent) => ((decide (acc)) || ((decide (((death_event).decedent).id = (employee_local).id)) && (decide ((Date_en.get_year (death_event).death_date) < payment_year)))))) false death_events))) (wage_payment_event).employee)) (Date_en.get_year (wage_payment_event).payment_date))) (wage_payment_event).is_paid_to_survivor_or_estate)
  taxable_amount_before_7000_cap : CatalaRuntime.Money := (if ((decide (is_excluded_by_sickness_disability_death)) || ((decide (is_excluded_by_nonbusiness_service)) || ((decide (is_excluded_by_termination_payment)) || ((decide (is_excluded_by_agricultural_noncash)) || (decide (is_excluded_by_survivor_payment)))))) then (CatalaRuntime.Money.ofCents 0) else (wage_payment_event).amount)

def Sections.WagePaymentEventSection3306Wages_main_output_leaf_0 (input : Sections.WagePaymentEventSection3306Wages_Input) : Option Sections.WagePaymentEventSection3306WagesOutput :=
  some (({ wage_payment_event := input.wage_payment_event, is_excluded_by_sickness_disability_death := input.is_excluded_by_sickness_disability_death, is_excluded_by_nonbusiness_service := input.is_excluded_by_nonbusiness_service, is_excluded_by_termination_payment := input.is_excluded_by_termination_payment, is_excluded_by_agricultural_noncash := input.is_excluded_by_agricultural_noncash, is_excluded_by_survivor_payment := input.is_excluded_by_survivor_payment, taxable_amount_before_7000_cap := input.taxable_amount_before_7000_cap } : WagePaymentEventSection3306WagesOutput))

structure Sections.WagePaymentEventSection3306Wages where
  main_output : Sections.WagePaymentEventSection3306WagesOutput
deriving DecidableEq, Inhabited
def Sections.wagePaymentEventSection3306Wages (input : Sections.WagePaymentEventSection3306Wages_Input) : Sections.WagePaymentEventSection3306Wages :=
  let main_output := match Sections.WagePaymentEventSection3306Wages_main_output_leaf_0 input with | some val => val | _ => default 
  { main_output := main_output }

structure Sections.TotalWages3306Calculation_Input where
  wage_results : (List Sections.WagePaymentEventSection3306WagesOutput)
  total_taxable_wages : CatalaRuntime.Money := ((fun (total_before_cap : CatalaRuntime.Money) => (if (decide (total_before_cap > (CatalaRuntime.Money.ofCents 700000))) then (CatalaRuntime.Money.ofCents 700000) else total_before_cap)) (match (List.map ((fun (wage_result : Sections.WagePaymentEventSection3306WagesOutput) => (wage_result).taxable_amount_before_7000_cap)) wage_results) with | [] => (fun () => (CatalaRuntime.Money.ofCents 0)) () | x0 :: xn => List.foldl (fun (sum1 : CatalaRuntime.Money) (sum2 : CatalaRuntime.Money) => (sum1 + sum2)) x0 xn))

def Sections.TotalWages3306Calculation_main_output_leaf_0 (input : Sections.TotalWages3306Calculation_Input) : Option Sections.TotalWages3306CalculationOutput :=
  some (({ total_taxable_wages := input.total_taxable_wages, wage_results_with_cap := input.wage_results } : TotalWages3306CalculationOutput))

structure Sections.TotalWages3306Calculation where
  main_output : Sections.TotalWages3306CalculationOutput
deriving DecidableEq, Inhabited
def Sections.totalWages3306Calculation (input : Sections.TotalWages3306Calculation_Input) : Sections.TotalWages3306Calculation :=
  let main_output := match Sections.TotalWages3306Calculation_main_output_leaf_0 input with | some val => val | _ => default 
  { main_output := main_output }

structure Sections.EmploymentRelationshipEventSection3306Employment_Input where
  marriage_events : (List Sections.MarriageEvent)
  birth_events : (List Sections.BirthEvent)
  parenthood_events : (List Sections.ParenthoodEvent)
  immigration_admission_events : (List Sections.ImmigrationAdmissionEvent)
  hospital_patient_events : (List Sections.HospitalPatientEvent)
  student_enrollment_events : (List Sections.StudentEnrollmentEvent)
  employment_relationship_events : (List Sections.EmploymentRelationshipEvent)
  wage_payment_events : (List Sections.WagePaymentEvent)
  calendar_year : Int
  employment_relationship_event : Sections.EmploymentRelationshipEvent
  is_excluded_penal_institution : Bool := ((decide ((employment_relationship_event).employment_category = (EmploymentCategory.PenalInstitution ()))) || (decide (((employment_relationship_event).employer).organization_type = (OrganizationType.PenalInstitution ()))))
  is_excluded_international_organization : Bool := ((decide ((employment_relationship_event).employment_category = (EmploymentCategory.InternationalOrganization ()))) || (decide (((employment_relationship_event).employer).organization_type = (OrganizationType.InternationalOrganization ()))))
  is_excluded_foreign_government : Bool := ((decide ((employment_relationship_event).employment_category = (EmploymentCategory.ForeignGovernment ()))) || (decide (((employment_relationship_event).employer).organization_type = (OrganizationType.ForeignGovernment ()))))
  is_excluded_state_government : Bool := ((decide ((employment_relationship_event).employment_category = (EmploymentCategory.StateGovernment ()))) || (decide (((employment_relationship_event).employer).organization_type = (OrganizationType.GovernmentState ()))))
  is_excluded_federal_government : Bool := ((decide ((employment_relationship_event).employment_category = (EmploymentCategory.FederalGovernment ()))) || (decide (((employment_relationship_event).employer).organization_type = (OrganizationType.GovernmentFederal ()))))
  is_excluded_domestic_service : Bool := (if (decide ((employment_relationship_event).employment_category = (EmploymentCategory.DomesticService ()))) then ((fun (employer_local : Sections.Organization) => ((fun (employer_status : Sections.OrganizationSection3306EmployerStatusOutput) => ((fun (employer_is_domestic_service_employer : Bool) => (!(decide (employer_is_domestic_service_employer)))) (employer_status).is_domestic_service_employer)) ((organizationSection3306EmployerStatus ({ employment_relationship_events := employment_relationship_events, wage_payment_events := wage_payment_events, calendar_year := calendar_year, organization := employer_local } : OrganizationSection3306EmployerStatus_Input))).main_output)) (employment_relationship_event).employer) else false)
  is_excluded_student_nurse : Bool := (((decide ((employment_relationship_event).employment_category = (EmploymentCategory.Hospital ()))) || (decide ((employment_relationship_event).employment_category = (EmploymentCategory.SchoolCollegeUniversity ())))) && (decide ((List.foldl ((fun (acc : Bool) (se : Sections.StudentEnrollmentEvent) => ((decide (acc)) || ((decide (((se).student).id = ((employment_relationship_event).employee).id)) && ((decide ((se).is_regularly_attending)) && ((decide ((se).start_date ≤ (Date_en.of_year_month_day calendar_year (12 : Int) (31 : Int)))) && (decide ((se).end_date ≥ (Date_en.of_year_month_day calendar_year (1 : Int) (1 : Int)))))))))) false student_enrollment_events))))
  is_excluded_hospital_patient_service : Bool := ((decide ((employment_relationship_event).employment_category = (EmploymentCategory.Hospital ()))) && (decide ((List.foldl ((fun (acc : Bool) (hpe : Sections.HospitalPatientEvent) => ((decide (acc)) || ((decide (((hpe).patient).id = ((employment_relationship_event).employee).id)) && ((decide (((hpe).hospital).id = ((employment_relationship_event).employer).id)) && ((decide ((hpe).start_date ≤ (Date_en.of_year_month_day calendar_year (12 : Int) (31 : Int)))) && (decide ((hpe).end_date ≥ (Date_en.of_year_month_day calendar_year (1 : Int) (1 : Int)))))))))) false hospital_patient_events))))
  is_excluded_agricultural_labor : Bool := (if (decide ((employment_relationship_event).employment_category = (EmploymentCategory.AgriculturalLabor ()))) then ((fun (employer_local : Sections.Organization) => ((fun (employer_status : Sections.OrganizationSection3306EmployerStatusOutput) => ((fun (employer_is_agricultural_employer : Bool) => ((fun (is_h2a_alien : Bool) => ((!(decide (employer_is_agricultural_employer))) || (decide (is_h2a_alien)))) (List.foldl ((fun (acc : Bool) (iae : Sections.ImmigrationAdmissionEvent) => ((decide (acc)) || ((decide (((iae).individual).id = ((employment_relationship_event).employee).id)) && (decide ((iae).visa_category = (VisaCategory.H2A ()))))))) false immigration_admission_events))) (employer_status).is_agricultural_employer)) ((organizationSection3306EmployerStatus ({ employment_relationship_events := employment_relationship_events, wage_payment_events := wage_payment_events, calendar_year := calendar_year, organization := employer_local } : OrganizationSection3306EmployerStatus_Input))).main_output)) (employment_relationship_event).employer) else false)
  is_excluded_student_service : Bool := ((decide ((employment_relationship_event).employment_category = (EmploymentCategory.SchoolCollegeUniversity ()))) && ((decide ((List.foldl ((fun (acc : Bool) (se : Sections.StudentEnrollmentEvent) => ((decide (acc)) || ((decide (((se).student).id = ((employment_relationship_event).employee).id)) && ((decide (((se).institution).id = ((employment_relationship_event).employer).id)) && ((decide ((se).is_regularly_attending)) && ((decide ((se).start_date ≤ (Date_en.of_year_month_day calendar_year (12 : Int) (31 : Int)))) && (decide ((se).end_date ≥ (Date_en.of_year_month_day calendar_year (1 : Int) (1 : Int))))))))))) false student_enrollment_events))) || (decide ((List.foldl ((fun (acc : Bool) (se : Sections.StudentEnrollmentEvent) => ((decide (acc)) || ((decide (((se).institution).id = ((employment_relationship_event).employer).id)) && ((decide ((se).is_regularly_attending)) && ((decide ((se).start_date ≤ (Date_en.of_year_month_day calendar_year (12 : Int) (31 : Int)))) && ((decide ((se).end_date ≥ (Date_en.of_year_month_day calendar_year (1 : Int) (1 : Int)))) && (decide ((List.foldl ((fun (acc : Bool) (me : Sections.MarriageEvent) => ((decide (acc)) || ((((decide (((me).spouse1).id = ((se).student).id)) && (decide (((me).spouse2).id = ((employment_relationship_event).employee).id))) || ((decide (((me).spouse2).id = ((se).student).id)) && (decide (((me).spouse1).id = ((employment_relationship_event).employee).id)))) && (decide ((me).marriage_date ≤ (employment_relationship_event).end_date)))))) false marriage_events)))))))))) false student_enrollment_events)))))
  is_excluded_family_employment : Bool := ((fun (employee_local : Sections.Individual) => ((fun (employer_local : Sections.Organization) => ((fun (employee_is_parent_of_employer : Bool) => ((fun (employee_is_spouse_of_employer : Bool) => ((fun (is_son_daughter_or_spouse : Bool) => ((fun (is_child_under_21 : Bool) => ((decide (is_son_daughter_or_spouse)) || (decide (is_child_under_21)))) (List.foldl ((fun (acc : Bool) (pe : Sections.ParenthoodEvent) => ((decide (acc)) || ((decide (((pe).parent).id = (employer_local).id)) && ((decide (((pe).child).id = (employee_local).id)) && (((decide ((pe).parent_type = (ParentType.Biological ()))) || (decide ((pe).parent_type = (ParentType.Adoptive ())))) && (decide ((List.foldl ((fun (acc : Bool) (be : Sections.BirthEvent) => ((decide (acc)) || ((decide (((be).individual).id = (employee_local).id)) && (decide ((Date_en.is_young_enough_rounding_down (be).birth_date (CatalaRuntime.Duration.create 21 0 0) (Date_en.of_year_month_day calendar_year (12 : Int) (31 : Int))))))))) false birth_events))))))))) false parenthood_events))) ((decide (employee_is_parent_of_employer)) || (decide (employee_is_spouse_of_employer))))) (List.foldl ((fun (acc : Bool) (me : Sections.MarriageEvent) => ((decide (acc)) || ((((decide (((me).spouse1).id = (employee_local).id)) && (decide (((me).spouse2).id = (employer_local).id))) || ((decide (((me).spouse2).id = (employee_local).id)) && (decide (((me).spouse1).id = (employer_local).id)))) && (decide ((me).marriage_date ≤ (employment_relationship_event).end_date)))))) false marriage_events))) (List.foldl ((fun (acc : Bool) (pe : Sections.ParenthoodEvent) => ((decide (acc)) || ((decide (((pe).parent).id = (employee_local).id)) && ((decide (((pe).child).id = (employer_local).id)) && ((decide ((pe).parent_type = (ParentType.Biological ()))) || (decide ((pe).parent_type = (ParentType.Adoptive ()))))))))) false parenthood_events))) (employment_relationship_event).employer)) (employment_relationship_event).employee)
  is_employment : Bool := ((fun (is_within_us : Bool) => ((fun (is_outside_us_by_us_citizen : Bool) => (((decide (is_within_us)) || (decide (is_outside_us_by_us_citizen))) && ((!(decide (is_excluded_agricultural_labor))) && ((!(decide (is_excluded_domestic_service))) && ((!(decide (is_excluded_family_employment))) && ((!(decide (is_excluded_federal_government))) && ((!(decide (is_excluded_state_government))) && ((!(decide (is_excluded_student_service))) && ((!(decide (is_excluded_hospital_patient_service))) && ((!(decide (is_excluded_foreign_government))) && ((!(decide (is_excluded_student_nurse))) && ((!(decide (is_excluded_international_organization))) && (!(decide (is_excluded_penal_institution))))))))))))))) ((decide ((employment_relationship_event).service_location = (ServiceLocation.OutsideUnitedStates ()))) && ((decide ((employment_relationship_event).employee_is_us_citizen)) && (decide ((employment_relationship_event).is_american_employer)))))) (decide ((employment_relationship_event).service_location = (ServiceLocation.WithinUnitedStates ()))))

def Sections.EmploymentRelationshipEventSection3306Employment_main_output_leaf_0 (input : Sections.EmploymentRelationshipEventSection3306Employment_Input) : Option Sections.EmploymentRelationshipEventSection3306EmploymentOutput :=
  some (({ employment_relationship_event := input.employment_relationship_event, is_employment := input.is_employment, is_excluded_agricultural_labor := input.is_excluded_agricultural_labor, is_excluded_domestic_service := input.is_excluded_domestic_service, is_excluded_family_employment := input.is_excluded_family_employment, is_excluded_federal_government := input.is_excluded_federal_government, is_excluded_state_government := input.is_excluded_state_government, is_excluded_student_service := input.is_excluded_student_service, is_excluded_hospital_patient_service := input.is_excluded_hospital_patient_service, is_excluded_foreign_government := input.is_excluded_foreign_government, is_excluded_student_nurse := input.is_excluded_student_nurse, is_excluded_international_organization := input.is_excluded_international_organization, is_excluded_penal_institution := input.is_excluded_penal_institution } : EmploymentRelationshipEventSection3306EmploymentOutput))

structure Sections.EmploymentRelationshipEventSection3306Employment where
  main_output : Sections.EmploymentRelationshipEventSection3306EmploymentOutput
deriving DecidableEq, Inhabited
def Sections.employmentRelationshipEventSection3306Employment (input : Sections.EmploymentRelationshipEventSection3306Employment_Input) : Sections.EmploymentRelationshipEventSection3306Employment :=
  let main_output := match Sections.EmploymentRelationshipEventSection3306Employment_main_output_leaf_0 input with | some val => val | _ => default 
  { main_output := main_output }

structure Sections.IndividualSection151ExemptionsList_Input where
  is_joint_or_surviving_spouse : Bool
  dependents : (List Sections.Individual)
  income_events : (List Sections.IncomeEvent)
  tax_return_events : (List Sections.TaxReturnEvent)
  tax_year : Int
  spouse : (Optional Sections.Individual)
  individual : Sections.Individual
  spouse_personal_exemption_allowed : Bool := (if is_joint_or_surviving_spouse then false else (match spouse with | Optional.Absent _ => false | Optional.Present s => ((fun (spouse_has_no_income : Bool) => ((fun (spouse_is_not_dependent_of_another : Bool) => ((decide (spouse_has_no_income)) && (decide (spouse_is_not_dependent_of_another)))) (!(decide ((List.foldl ((fun (acc : Bool) (event : Sections.TaxReturnEvent) => ((decide (acc)) || ((!(decide ((event).individual = individual))) && ((decide ((event).tax_year = tax_year)) && (decide ((List.foldl ((fun (acc : Bool) (dependent : Sections.Individual) => ((decide (acc)) || (decide (dependent = s))))) false (event).dependents)))))))) false tax_return_events)))))) (!(decide ((List.foldl ((fun (acc : Bool) (income_event : Sections.IncomeEvent) => ((decide (acc)) || ((decide ((income_event).individual = s)) && ((decide ((income_event).tax_year = tax_year)) && (decide ((income_event).has_income))))))) false income_events)))))))
  individuals_entitled_to_exemptions_under_151 : (List Sections.Individual) := ((fun (individual_list : (List Sections.Individual)) => ((fun (spouse_list : (List Sections.Individual)) => ((individual_list ++ spouse_list) ++ dependents)) (match spouse with | Optional.Absent _ => [] | Optional.Present s => (if spouse_personal_exemption_allowed then [s] else [])))) [individual])

def Sections.IndividualSection151ExemptionsList_main_output_leaf_0 (input : Sections.IndividualSection151ExemptionsList_Input) : Option Sections.IndividualSection151ExemptionsListOutput :=
  some (({ individual := input.individual, spouse_personal_exemption_allowed := input.spouse_personal_exemption_allowed, individuals_entitled_to_exemptions_under_151 := input.individuals_entitled_to_exemptions_under_151 } : IndividualSection151ExemptionsListOutput))

structure Sections.IndividualSection151ExemptionsList where
  main_output : Sections.IndividualSection151ExemptionsListOutput
deriving DecidableEq, Inhabited
def Sections.individualSection151ExemptionsList (input : Sections.IndividualSection151ExemptionsList_Input) : Sections.IndividualSection151ExemptionsList :=
  let main_output := match Sections.IndividualSection151ExemptionsList_main_output_leaf_0 input with | some val => val | _ => default 
  { main_output := main_output }

structure Sections.IndividualSection152QualifyingRelative_Input where
  marriage_events : (List Sections.MarriageEvent)
  income_events : (List Sections.IncomeEvent)
  tax_return_events : (List Sections.TaxReturnEvent)
  qualifying_child_results : (List Sections.IndividualSection152QualifyingChildOutput)
  residence_period_events : (List Sections.ResidencePeriodEvent)
  family_relationship_events : (List Sections.FamilyRelationshipEvent)
  tax_year : Int
  taxpayer : Sections.Individual
  individual : Sections.Individual
  not_qualifying_child_requirement_met : Bool := ((fun (is_qualifying_child_of_current_taxpayer : Bool) => ((fun (is_qualifying_child_of_other_taxpayer : Bool) => (!((decide (is_qualifying_child_of_current_taxpayer)) || (decide (is_qualifying_child_of_other_taxpayer))))) (List.foldl ((fun (acc : Bool) (event : Sections.TaxReturnEvent) => ((decide (acc)) || ((decide ((event).tax_year = tax_year)) && ((!(decide ((event).individual = taxpayer))) && (decide ((List.foldl ((fun (acc : Bool) (qualifying_child : Sections.Individual) => ((decide (acc)) || (decide (qualifying_child = individual))))) false (event).qualifying_children)))))))) false tax_return_events))) (List.foldl ((fun (acc : Bool) (result : Sections.IndividualSection152QualifyingChildOutput) => ((decide (acc)) || ((decide ((result).individual = individual)) && ((decide ((result).taxpayer = taxpayer)) && (decide ((result).is_qualifying_child))))))) false qualifying_child_results))
  no_income_requirement_met : Bool := (!(decide ((List.foldl ((fun (acc : Bool) (income_event : Sections.IncomeEvent) => ((decide (acc)) || ((decide ((income_event).individual = individual)) && ((decide ((income_event).tax_year = tax_year)) && (decide ((income_event).has_income))))))) false income_events))))
  relationship_requirement_met_H : Bool := ((fun (year_start : CatalaRuntime.Date) => ((fun (year_end : CatalaRuntime.Date) => ((!(decide ((List.foldl ((fun (acc : Bool) (marriage_event : Sections.MarriageEvent) => ((decide (acc)) || ((((decide ((marriage_event).spouse1 = taxpayer)) && (decide ((marriage_event).spouse2 = individual))) || ((decide ((marriage_event).spouse1 = individual)) && (decide ((marriage_event).spouse2 = taxpayer)))) && (decide ((marriage_event).marriage_date ≤ year_end)))))) false marriage_events)))) && (decide ((List.foldl ((fun (acc : Bool) (taxpayer_residence : Sections.ResidencePeriodEvent) => ((decide (acc)) || ((decide ((taxpayer_residence).individual = taxpayer)) && ((decide ((taxpayer_residence).is_principal_place_of_abode)) && ((decide ((taxpayer_residence).start_date ≤ year_end)) && ((decide ((taxpayer_residence).end_date ≥ year_start)) && (decide ((List.foldl ((fun (acc : Bool) (individual_residence : Sections.ResidencePeriodEvent) => ((decide (acc)) || ((decide ((individual_residence).individual = individual)) && ((decide ((individual_residence).household = (taxpayer_residence).household)) && ((decide ((individual_residence).is_principal_place_of_abode)) && ((decide ((individual_residence).is_member_of_household)) && ((decide ((individual_residence).start_date ≤ year_end)) && (decide ((individual_residence).end_date ≥ year_start)))))))))) false residence_period_events)))))))))) false residence_period_events))))) (Date_en.of_year_month_day tax_year (12 : Int) (31 : Int)))) (Date_en.of_year_month_day tax_year (1 : Int) (1 : Int)))
  relationship_requirement_met : Bool := ((decide ((List.foldl ((fun (acc : Bool) (rel_event : Sections.FamilyRelationshipEvent) => ((decide (acc)) || ((decide ((rel_event).person = taxpayer)) && ((decide ((rel_event).relative = individual)) && ((decide ((rel_event).start_date ≤ (Date_en.of_year_month_day tax_year (12 : Int) (31 : Int)))) && ((decide ((rel_event).relationship_type = (FamilyRelationshipType.Child ()))) || ((decide ((rel_event).relationship_type = (FamilyRelationshipType.DescendantOfChild ()))) || ((decide ((rel_event).relationship_type = (FamilyRelationshipType.Brother ()))) || ((decide ((rel_event).relationship_type = (FamilyRelationshipType.Sister ()))) || ((decide ((rel_event).relationship_type = (FamilyRelationshipType.Stepbrother ()))) || ((decide ((rel_event).relationship_type = (FamilyRelationshipType.Stepsister ()))) || ((decide ((rel_event).relationship_type = (FamilyRelationshipType.Father ()))) || ((decide ((rel_event).relationship_type = (FamilyRelationshipType.Mother ()))) || ((decide ((rel_event).relationship_type = (FamilyRelationshipType.AncestorOfFatherOrMother ()))) || ((decide ((rel_event).relationship_type = (FamilyRelationshipType.Stepmother ()))) || ((decide ((rel_event).relationship_type = (FamilyRelationshipType.Stepfather ()))) || ((decide ((rel_event).relationship_type = (FamilyRelationshipType.NieceOrNephew ()))) || ((decide ((rel_event).relationship_type = (FamilyRelationshipType.UncleOrAunt ()))) || ((decide ((rel_event).relationship_type = (FamilyRelationshipType.SonInLaw ()))) || ((decide ((rel_event).relationship_type = (FamilyRelationshipType.DaughterInLaw ()))) || ((decide ((rel_event).relationship_type = (FamilyRelationshipType.FatherInLaw ()))) || ((decide ((rel_event).relationship_type = (FamilyRelationshipType.MotherInLaw ()))) || ((decide ((rel_event).relationship_type = (FamilyRelationshipType.BrotherInLaw ()))) || (decide ((rel_event).relationship_type = (FamilyRelationshipType.SisterInLaw ()))))))))))))))))))))))))))) false family_relationship_events))) || (decide (relationship_requirement_met_H)))
  is_qualifying_relative : Bool := ((decide (relationship_requirement_met)) && ((decide (no_income_requirement_met)) && (decide (not_qualifying_child_requirement_met))))

def Sections.IndividualSection152QualifyingRelative_main_output_leaf_0 (input : Sections.IndividualSection152QualifyingRelative_Input) : Option Sections.IndividualSection152QualifyingRelativeOutput :=
  some (({ individual := input.individual, taxpayer := input.taxpayer, is_qualifying_relative := input.is_qualifying_relative, relationship_requirement_met_H := input.relationship_requirement_met_H, relationship_requirement_met := input.relationship_requirement_met, no_income_requirement_met := input.no_income_requirement_met, not_qualifying_child_requirement_met := input.not_qualifying_child_requirement_met } : IndividualSection152QualifyingRelativeOutput))

structure Sections.IndividualSection152QualifyingRelative where
  main_output : Sections.IndividualSection152QualifyingRelativeOutput
deriving DecidableEq, Inhabited
def Sections.individualSection152QualifyingRelative (input : Sections.IndividualSection152QualifyingRelative_Input) : Sections.IndividualSection152QualifyingRelative :=
  let main_output := match Sections.IndividualSection152QualifyingRelative_main_output_leaf_0 input with | some val => val | _ => default 
  { main_output := main_output }

structure Sections.IndividualSection151Exemption_Input where
  individuals_entitled_to_exemptions_under_151 : (List Sections.Individual)
  applicable_amount : CatalaRuntime.Money
  adjusted_gross_income : CatalaRuntime.Money
  tax_return_events : (List Sections.TaxReturnEvent)
  tax_year : Int
  individual_tax_return : Sections.IndividualTaxReturn
  individual : Sections.Individual
  exemption_amount_base : CatalaRuntime.Money := (CatalaRuntime.Money.ofCents 200000)
  applicable_percentage : Rat := (if (decide (adjusted_gross_income > applicable_amount)) then ((fun (excess_agi : CatalaRuntime.Money) => ((fun (threshold : CatalaRuntime.Money) => ((fun (excess_decimal : Rat) => ((fun (threshold_decimal : Rat) => ((fun (fraction_count_decimal : Rat) => ((fun (fraction_count : Rat) => (Decimal_en.min (CatalaRuntime.multiply fraction_count (Rat.mk 1 50)) (Rat.mk 1 1))) (if (decide (fraction_count_decimal > (CatalaRuntime.toRat (Rat.floor fraction_count_decimal)))) then (CatalaRuntime.toRat ((Rat.floor fraction_count_decimal) + (1 : Int))) else (CatalaRuntime.toRat (Rat.floor fraction_count_decimal))))) (excess_decimal / threshold_decimal))) (CatalaRuntime.toRat threshold))) (CatalaRuntime.toRat excess_agi))) (match (individual_tax_return).details with | Sections.FilingStatusVariant.JointReturn _ => (CatalaRuntime.Money.ofCents 250000) | Sections.FilingStatusVariant.SurvivingSpouse _ => (CatalaRuntime.Money.ofCents 250000) | Sections.FilingStatusVariant.HeadOfHousehold _ => (CatalaRuntime.Money.ofCents 250000) | Sections.FilingStatusVariant.Single _ => (CatalaRuntime.Money.ofCents 250000) | Sections.FilingStatusVariant.MarriedFilingSeparate variant => (CatalaRuntime.Money.ofCents 125000)))) (adjusted_gross_income - applicable_amount)) else (Rat.mk 0 1))
  number_of_personal_exemptions : Int := (individuals_entitled_to_exemptions_under_151).length
  exemption_amount_after_disallowance : CatalaRuntime.Money := ((fun (taxpayer_is_dependent_of_another : Bool) => (if taxpayer_is_dependent_of_another then (CatalaRuntime.Money.ofCents 0) else exemption_amount_base)) (List.foldl ((fun (acc : Bool) (event : Sections.TaxReturnEvent) => ((decide (acc)) || ((!(decide ((event).individual = individual))) && ((decide ((event).tax_year = tax_year)) && (decide ((List.foldl ((fun (acc : Bool) (dependent : Sections.Individual) => ((decide (acc)) || (decide (dependent = individual))))) false (event).dependents)))))))) false tax_return_events))
  exemption_amount_after_phaseout : CatalaRuntime.Money := (match (match processExceptions [if (Sections.is_tax_year_2018_through_2025 tax_year) then some ((CatalaRuntime.Money.ofCents 0)) else none] with | none => some ((if (decide (adjusted_gross_income > applicable_amount)) then ((fun (reduction : CatalaRuntime.Money) => (exemption_amount_after_disallowance - reduction)) (CatalaRuntime.toMoney (CatalaRuntime.multiply (CatalaRuntime.toRat exemption_amount_after_disallowance) applicable_percentage))) else exemption_amount_after_disallowance)) | some r => some r) with | some r => r | _ => default)
  personal_exemptions_deduction : CatalaRuntime.Money := ((fun (n : Rat) => (CatalaRuntime.toMoney (CatalaRuntime.multiply n (CatalaRuntime.toRat exemption_amount_after_phaseout)))) (CatalaRuntime.toRat number_of_personal_exemptions))

def Sections.IndividualSection151Exemption_main_output_leaf_0 (input : Sections.IndividualSection151Exemption_Input) : Option Sections.IndividualSection151ExemptionOutput :=
  some (({ individual := input.individual, exemption_amount_base := input.exemption_amount_base, exemption_amount_after_disallowance := input.exemption_amount_after_disallowance, exemption_amount_after_phaseout := input.exemption_amount_after_phaseout, number_of_personal_exemptions := input.number_of_personal_exemptions, personal_exemptions_deduction := input.personal_exemptions_deduction, applicable_percentage := input.applicable_percentage } : IndividualSection151ExemptionOutput))

structure Sections.IndividualSection151Exemption where
  main_output : Sections.IndividualSection151ExemptionOutput
deriving DecidableEq, Inhabited
def Sections.individualSection151Exemption (input : Sections.IndividualSection151Exemption_Input) : Sections.IndividualSection151Exemption :=
  let main_output := match Sections.IndividualSection151Exemption_main_output_leaf_0 input with | some val => val | _ => default 
  { main_output := main_output }

structure Sections.TaxpayerExemptionsList_Input where
  dependents : (List Sections.Individual)
  income_events : (List Sections.IncomeEvent)
  tax_return_events : (List Sections.TaxReturnEvent)
  individual_tax_return : Sections.IndividualTaxReturn
  spouse_result : (Optional Sections.IndividualSection151ExemptionsListOutput) := (match (individual_tax_return).details with | Sections.FilingStatusVariant.JointReturn variant => ((fun (spouse_local : (Optional Sections.Individual)) => ((fun (spouse_result_inner : (Optional Sections.IndividualSection151ExemptionsListOutput)) => spouse_result_inner) (match spouse_local with | Optional.Absent _ => (Optional.Absent ()) | Optional.Present s => ((fun (taxpayer_local : Sections.Individual) => ((fun (spouse_result_scope : Sections.IndividualSection151ExemptionsList) => (Optional.Present (spouse_result_scope).main_output)) (individualSection151ExemptionsList ({ is_joint_or_surviving_spouse := true, dependents := dependents, income_events := income_events, tax_return_events := tax_return_events, tax_year := (individual_tax_return).tax_year, spouse := (Optional.Present taxpayer_local), individual := s } : IndividualSection151ExemptionsList_Input)))) (Sections.get_taxpayer individual_tax_return))))) (Sections.get_spouse individual_tax_return)) | Sections.FilingStatusVariant.SurvivingSpouse variant => (Optional.Absent ()) | Sections.FilingStatusVariant.HeadOfHousehold variant => (Optional.Absent ()) | Sections.FilingStatusVariant.Single variant => (Optional.Absent ()) | Sections.FilingStatusVariant.MarriedFilingSeparate variant => (Optional.Absent ()))
  taxpayer_exemptions : Sections.IndividualSection151ExemptionsList := Sections.individualSection151ExemptionsList { individual := (Sections.get_taxpayer individual_tax_return), spouse := (Sections.get_spouse individual_tax_return), tax_year := (individual_tax_return).tax_year, tax_return_events := tax_return_events, income_events := income_events, dependents := dependents, is_joint_or_surviving_spouse := (match (individual_tax_return).details with | Sections.FilingStatusVariant.JointReturn variant => true | Sections.FilingStatusVariant.SurvivingSpouse variant => true | Sections.FilingStatusVariant.HeadOfHousehold variant => false | Sections.FilingStatusVariant.Single variant => false | Sections.FilingStatusVariant.MarriedFilingSeparate variant => false) }
  spouse_personal_exemption_allowed : Bool := ((taxpayer_exemptions).main_output).spouse_personal_exemption_allowed
  individuals_entitled_to_exemptions_under_151 : (List Sections.Individual) := ((fun (taxpayer_list : (List Sections.Individual)) => ((fun (spouse_unique_list : (List Sections.Individual)) => (taxpayer_list ++ spouse_unique_list)) (match spouse_result with | Optional.Absent _ => [] | Optional.Present s_result => (List.filter ((fun (individual : Sections.Individual) => (!(decide ((List.foldl ((fun (acc : Bool) (taxpayer_individual : Sections.Individual) => ((decide (acc)) || (decide (taxpayer_individual = individual))))) false taxpayer_list)))))) (s_result).individuals_entitled_to_exemptions_under_151)))) ((taxpayer_exemptions).main_output).individuals_entitled_to_exemptions_under_151)

def Sections.TaxpayerExemptionsList_main_output_leaf_0 (input : Sections.TaxpayerExemptionsList_Input) (taxpayer_exemptions : Sections.IndividualSection151ExemptionsList) : Option Sections.TaxpayerExemptionsListOutput :=
  some (({ taxpayer_result := (taxpayer_exemptions).main_output, spouse_result := input.spouse_result, individuals_entitled_to_exemptions_under_151 := input.individuals_entitled_to_exemptions_under_151, spouse_personal_exemption_allowed := input.spouse_personal_exemption_allowed } : TaxpayerExemptionsListOutput))

structure Sections.TaxpayerExemptionsList where
  main_output : Sections.TaxpayerExemptionsListOutput
deriving DecidableEq, Inhabited
def Sections.taxpayerExemptionsList (input : Sections.TaxpayerExemptionsList_Input) : Sections.TaxpayerExemptionsList :=
  let taxpayer_exemptions := Sections.individualSection151ExemptionsList { individual := (Sections.get_taxpayer input.individual_tax_return), spouse := (Sections.get_spouse input.individual_tax_return), tax_year := (input.individual_tax_return).tax_year, tax_return_events := input.tax_return_events, income_events := input.income_events, dependents := input.dependents, is_joint_or_surviving_spouse := (match (input.individual_tax_return).details with | Sections.FilingStatusVariant.JointReturn variant => true | Sections.FilingStatusVariant.SurvivingSpouse variant => true | Sections.FilingStatusVariant.HeadOfHousehold variant => false | Sections.FilingStatusVariant.Single variant => false | Sections.FilingStatusVariant.MarriedFilingSeparate variant => false) }
  let main_output := match Sections.TaxpayerExemptionsList_main_output_leaf_0 input taxpayer_exemptions with | some val => val | _ => default 
  { main_output := main_output }

structure Sections.IndividualSection7703MaritalStatus_Input where
  individuals_entitled_to_exemptions_under_151 : (List Sections.Individual)
  qualifying_children : (List Sections.IndividualSection152QualifyingChildOutput)
  household_maintenance_events : (List Sections.HouseholdMaintenanceEvent)
  residence_period_events : (List Sections.ResidencePeriodEvent)
  individual_tax_return : Sections.IndividualTaxReturn
  death_events : (List Sections.DeathEvent)
  divorce_or_legal_separation_events : (List Sections.DivorceOrLegalSeparationEvent)
  marriage_events : (List Sections.MarriageEvent)
  tax_year : Int
  individual : Sections.Individual
  section_7703_find_spouse_from_marriage_events : (Sections.Individual → (List Sections.MarriageEvent) → CatalaRuntime.Date → (Optional Sections.Individual)) := fun (individual_arg : Sections.Individual) (marriage_events_arg : (List Sections.MarriageEvent)) (year_end_arg : CatalaRuntime.Date) => ((fun (valid_marriages : (List (Sections.Individual × CatalaRuntime.Date))) => (if (decide ((valid_marriages).length > (0 : Int))) then ((fun (most_recent_marriage : CatalaRuntime.Date) => (List_en.first_element (List.map ((fun (marriage_tuple : (Sections.Individual × CatalaRuntime.Date)) => (marriage_tuple).1)) (List.filter ((fun (marriage_tuple : (Sections.Individual × CatalaRuntime.Date)) => (decide ((marriage_tuple).2 = most_recent_marriage)))) valid_marriages)))) (match (List.map ((fun (marriage_tuple : (Sections.Individual × CatalaRuntime.Date)) => (marriage_tuple).2)) valid_marriages) with | [] => (fun () => default /-unsupported expression-/) () | x0 :: xn => List.foldl (fun (max1 : CatalaRuntime.Date) (max2 : CatalaRuntime.Date) => (if (decide (max1 > max2)) then max1 else max2)) x0 xn)) else (Optional.Absent ()))) (List.map ((fun (marriage_event : Sections.MarriageEvent) => ((if (decide ((marriage_event).spouse1 = individual_arg)) then (marriage_event).spouse2 else (marriage_event).spouse1), (marriage_event).marriage_date))) (List.filter ((fun (marriage_event : Sections.MarriageEvent) => (((decide ((marriage_event).spouse1 = individual_arg)) || (decide ((marriage_event).spouse2 = individual_arg))) && (decide ((marriage_event).marriage_date ≤ year_end_arg))))) marriage_events_arg)))
  section_7703_get_spouse_death_date_during_year : ((Optional Sections.Individual) → (List Sections.DeathEvent) → Int → (Optional CatalaRuntime.Date)) := fun (spouse_arg : (Optional Sections.Individual)) (death_events_arg : (List Sections.DeathEvent)) (tax_year_arg : Int) => (match spouse_arg with | Optional.Absent _ => (Optional.Absent ()) | Optional.Present s => ((fun (year_start : CatalaRuntime.Date) => ((fun (year_end : CatalaRuntime.Date) => ((fun (spouse_death_events_during_year : (List Sections.DeathEvent)) => (if (decide ((spouse_death_events_during_year).length > (0 : Int))) then (Optional.Present (match (List.map ((fun (death_event : Sections.DeathEvent) => (death_event).death_date)) spouse_death_events_during_year) with | [] => (fun () => default /-unsupported expression-/) () | x0 :: xn => List.foldl (fun (min1 : CatalaRuntime.Date) (min2 : CatalaRuntime.Date) => (if (decide (min1 < min2)) then min1 else min2)) x0 xn)) else (Optional.Absent ()))) (List.filter ((fun (death_event : Sections.DeathEvent) => ((decide ((death_event).decedent = s)) && ((decide ((death_event).death_date ≥ year_start)) && (decide ((death_event).death_date ≤ year_end)))))) death_events_arg))) (Date_en.of_year_month_day tax_year_arg (12 : Int) (31 : Int)))) (Date_en.of_year_month_day tax_year_arg (1 : Int) (1 : Int))))
  section_7703_spouse_died_before_date : ((Optional Sections.Individual) → (List Sections.DeathEvent) → CatalaRuntime.Date → Bool) := fun (spouse_arg : (Optional Sections.Individual)) (death_events_arg : (List Sections.DeathEvent)) (before_date_arg : CatalaRuntime.Date) => (match spouse_arg with | Optional.Absent _ => false | Optional.Present s => ((fun (spouse_death_events_before_date : (List Sections.DeathEvent)) => (decide ((spouse_death_events_before_date).length > (0 : Int)))) (List.filter ((fun (death_event : Sections.DeathEvent) => ((decide ((death_event).decedent = s)) && (decide ((death_event).death_date < before_date_arg))))) death_events_arg)))
  section_7703_get_spouse_from_tax_return : (Sections.Individual → Sections.IndividualTaxReturn → (Optional Sections.Individual)) := fun (individual_arg : Sections.Individual) (individual_tax_return_arg : Sections.IndividualTaxReturn) => (match (individual_tax_return_arg).details with | Sections.FilingStatusVariant.JointReturn variant => (if (decide ((variant).taxpayer = individual_arg)) then (Optional.Present (variant).spouse) else (Optional.Absent ())) | Sections.FilingStatusVariant.SurvivingSpouse variant => (if (decide ((variant).taxpayer = individual_arg)) then (Optional.Present (variant).deceased_spouse) else (Optional.Absent ())) | Sections.FilingStatusVariant.HeadOfHousehold variant => (Optional.Absent ()) | Sections.FilingStatusVariant.Single variant => (Optional.Absent ()) | Sections.FilingStatusVariant.MarriedFilingSeparate variant => (if (decide ((variant).taxpayer = individual_arg)) then (Optional.Present (variant).spouse) else (Optional.Absent ())))
  section_7703_files_separate_return : (Sections.Individual → Sections.IndividualTaxReturn → Bool) := fun (individual_arg : Sections.Individual) (individual_tax_return_arg : Sections.IndividualTaxReturn) => (match (individual_tax_return_arg).details with | Sections.FilingStatusVariant.JointReturn variant => false | Sections.FilingStatusVariant.SurvivingSpouse variant => false | Sections.FilingStatusVariant.HeadOfHousehold variant => false | Sections.FilingStatusVariant.Single variant => false | Sections.FilingStatusVariant.MarriedFilingSeparate variant => (decide ((variant).taxpayer = individual_arg)))
  section_7703_is_spouse_member_of_household_last_6_months : (Sections.Individual → Sections.Household → (List Sections.ResidencePeriodEvent) → CatalaRuntime.Date → CatalaRuntime.Date → Bool) := fun (spouse_arg : Sections.Individual) (household_arg : Sections.Household) (residence_period_events_arg : (List Sections.ResidencePeriodEvent)) (last_6_months_start_arg : CatalaRuntime.Date) (last_6_months_end_arg : CatalaRuntime.Date) => ((fun (spouse_membership_events : (List Sections.ResidencePeriodEvent)) => (if (decide ((spouse_membership_events).length > (0 : Int))) then (List.foldl ((fun (acc : Bool) (membership_event : Sections.ResidencePeriodEvent) => ((decide (acc)) || ((decide ((membership_event).start_date ≤ last_6_months_end_arg)) && (decide ((membership_event).end_date ≥ last_6_months_start_arg)))))) false spouse_membership_events) else false)) (List.filter ((fun (spouse_residence_event : Sections.ResidencePeriodEvent) => ((decide ((spouse_residence_event).individual = spouse_arg)) && ((decide ((spouse_residence_event).household = household_arg)) && (decide ((spouse_residence_event).is_member_of_household)))))) residence_period_events_arg))
  households_with_qualifying_child : (List Sections.Household) := ((fun (year_end : CatalaRuntime.Date) => ((fun (year_start : CatalaRuntime.Date) => (List.map ((fun (child_residence_event : Sections.ResidencePeriodEvent) => (child_residence_event).household)) (List.filter ((fun (child_residence_event : Sections.ResidencePeriodEvent) => ((decide ((child_residence_event).is_principal_place_of_abode)) && ((decide ((child_residence_event).start_date ≤ (Date_en.of_year_month_day tax_year (6 : Int) (30 : Int)))) && ((decide ((child_residence_event).end_date ≥ (Date_en.of_year_month_day tax_year (7 : Int) (1 : Int)))) && ((decide ((child_residence_event).start_date ≤ year_end)) && ((decide ((child_residence_event).end_date ≥ year_start)) && (decide ((List.foldl ((fun (acc : Bool) (qualifying_child_result : Sections.IndividualSection152QualifyingChildOutput) => ((decide (acc)) || ((decide ((qualifying_child_result).is_qualifying_child)) && ((decide ((qualifying_child_result).taxpayer = individual)) && ((decide ((qualifying_child_result).individual = (child_residence_event).individual)) && (decide ((List.foldl ((fun (acc : Bool) (entitled_individual : Sections.Individual) => ((decide (acc)) || ((decide (entitled_individual = (child_residence_event).individual)) && (decide ((List.foldl ((fun (acc : Bool) (individual_residence_event : Sections.ResidencePeriodEvent) => ((decide (acc)) || ((decide ((individual_residence_event).individual = individual)) && ((decide ((individual_residence_event).household = (child_residence_event).household)) && ((decide ((individual_residence_event).start_date ≤ (child_residence_event).end_date)) && ((decide ((individual_residence_event).end_date ≥ (child_residence_event).start_date)) && ((decide ((individual_residence_event).start_date ≤ year_end)) && (decide ((individual_residence_event).end_date ≥ year_start)))))))))) false residence_period_events))))))) false individuals_entitled_to_exemptions_under_151))))))))) false qualifying_children)))))))))) residence_period_events))) (Date_en.of_year_month_day tax_year (1 : Int) (1 : Int)))) (Date_en.of_year_month_day tax_year (12 : Int) (31 : Int)))
  determination_date : CatalaRuntime.Date := ((fun (year_end : CatalaRuntime.Date) => ((fun (spouse : (Optional Sections.Individual)) => ((fun (spouse_death_date_during_year : (Optional CatalaRuntime.Date)) => (match spouse_death_date_during_year with | Optional.Absent _ => year_end | Optional.Present death_date => death_date)) (section_7703_get_spouse_death_date_during_year spouse death_events tax_year))) (section_7703_find_spouse_from_marriage_events individual marriage_events year_end))) (Date_en.of_year_month_day tax_year (12 : Int) (31 : Int)))
  households_maintained_by_individual : (List Sections.Household) := ((fun (year_end : CatalaRuntime.Date) => ((fun (year_start : CatalaRuntime.Date) => (List.filter ((fun (household : Sections.Household) => (List.foldl ((fun (acc : Bool) (maintenance_event : Sections.HouseholdMaintenanceEvent) => ((decide (acc)) || ((decide ((maintenance_event).individual = individual)) && ((decide ((maintenance_event).household = household)) && ((decide ((maintenance_event).cost_furnished_percentage > (Rat.mk 1 2))) && ((decide ((maintenance_event).start_date ≤ year_end)) && ((decide ((maintenance_event).end_date ≥ year_start)) && (decide ((List.foldl ((fun (acc : Bool) (individual_residence_event : Sections.ResidencePeriodEvent) => ((decide (acc)) || ((decide ((individual_residence_event).individual = individual)) && ((decide ((individual_residence_event).household = household)) && ((decide ((individual_residence_event).start_date ≤ (maintenance_event).end_date)) && (decide ((individual_residence_event).end_date ≥ (maintenance_event).start_date)))))))) false residence_period_events))))))))))) false household_maintenance_events))) households_with_qualifying_child)) (Date_en.of_year_month_day tax_year (1 : Int) (1 : Int)))) (Date_en.of_year_month_day tax_year (12 : Int) (31 : Int)))
  is_legally_separated : Bool := ((fun (year_end : CatalaRuntime.Date) => ((fun (spouse : (Optional Sections.Individual)) => (match spouse with | Optional.Absent _ => false | Optional.Present s => (List.foldl ((fun (acc : Bool) (divorce_event : Sections.DivorceOrLegalSeparationEvent) => ((decide (acc)) || (((decide ((divorce_event).person1 = individual)) || (decide ((divorce_event).person2 = individual))) && (((decide ((divorce_event).person1 = s)) || (decide ((divorce_event).person2 = s))) && ((decide ((divorce_event).decree_date ≤ determination_date)) && ((decide ((divorce_event).decree_type = (DecreeType.Divorce ()))) || (decide ((divorce_event).decree_type = (DecreeType.SeparateMaintenance ())))))))))) false divorce_or_legal_separation_events))) (section_7703_find_spouse_from_marriage_events individual marriage_events year_end))) (Date_en.of_year_month_day tax_year (12 : Int) (31 : Int)))
  is_married_at_determination_date : Bool := ((fun (year_end : CatalaRuntime.Date) => ((fun (spouse : (Optional Sections.Individual)) => (match spouse with | Optional.Absent _ => false | Optional.Present s => (!(decide ((section_7703_spouse_died_before_date spouse death_events determination_date)))))) (section_7703_find_spouse_from_marriage_events individual marriage_events year_end))) (Date_en.of_year_month_day tax_year (12 : Int) (31 : Int)))
  spouse_not_member_of_household_last_6_months : Bool := ((fun (year_end : CatalaRuntime.Date) => ((fun (last_6_months_start : CatalaRuntime.Date) => ((fun (last_6_months_end : CatalaRuntime.Date) => ((fun (spouse_from_tax_return : (Optional Sections.Individual)) => (match spouse_from_tax_return with | Optional.Absent _ => (decide ((households_maintained_by_individual).length > (0 : Int))) | Optional.Present spouse => (List.foldl ((fun (acc : Bool) (household : Sections.Household) => ((decide (acc)) || (!(decide ((section_7703_is_spouse_member_of_household_last_6_months spouse household residence_period_events last_6_months_start last_6_months_end))))))) false households_maintained_by_individual))) (section_7703_get_spouse_from_tax_return individual individual_tax_return))) year_end)) (Date_en.of_year_month_day tax_year (7 : Int) (1 : Int)))) (Date_en.of_year_month_day tax_year (12 : Int) (31 : Int)))
  subsection_b_exception_applies : Bool := (match (match processExceptions [if ((decide (is_married_at_determination_date)) && ((!(decide (is_legally_separated))) && ((decide ((section_7703_files_separate_return individual individual_tax_return))) && (decide (spouse_not_member_of_household_last_6_months))))) then some (true) else none] with | none => some (false) | some r => some r) with | some r => r | _ => default)
  is_married_for_tax_purposes : Bool := (match (match processExceptions [(match processExceptions [if subsection_b_exception_applies then some (false) else none] with | none => if ((decide (is_married_at_determination_date)) && (!(decide (is_legally_separated)))) then some (true) else none | some r => some r)] with | none => some (false) | some r => some r) with | some r => r | _ => default)

def Sections.IndividualSection7703MaritalStatus_main_output_leaf_0 (input : Sections.IndividualSection7703MaritalStatus_Input) : Option Sections.IndividualSection7703MaritalStatusOutput :=
  some (({ individual := input.individual, tax_year := input.tax_year, determination_date := input.determination_date, is_married_at_determination_date := input.is_married_at_determination_date, is_legally_separated := input.is_legally_separated, households_with_qualifying_child := input.households_with_qualifying_child, households_maintained_by_individual := input.households_maintained_by_individual, spouse_not_member_of_household_last_6_months := input.spouse_not_member_of_household_last_6_months, subsection_b_exception_applies := input.subsection_b_exception_applies, is_married_for_tax_purposes := input.is_married_for_tax_purposes } : IndividualSection7703MaritalStatusOutput))

structure Sections.IndividualSection7703MaritalStatus where
  main_output : Sections.IndividualSection7703MaritalStatusOutput
deriving DecidableEq, Inhabited
def Sections.individualSection7703MaritalStatus (input : Sections.IndividualSection7703MaritalStatus_Input) : Sections.IndividualSection7703MaritalStatus :=
  let main_output := match Sections.IndividualSection7703MaritalStatus_main_output_leaf_0 input with | some val => val | _ => default 
  { main_output := main_output }

structure Sections.EmployerUnemploymentExciseTaxFilerSection3301Tax_Input where
  employment_relationship_employment_results : (List Sections.EmploymentRelationshipEventSection3306EmploymentOutput)
  organization_employer_statuses : (List Sections.OrganizationSection3306EmployerStatusOutput)
  wage_payment_wages_results : (List Sections.WagePaymentEventSection3306WagesOutput)
  employer_unemployment_excise_tax_return : Sections.EmployerUnemploymentExciseTaxReturn
  tax_rate : Rat := (Rat.mk 3 50)
  total_taxable_wages : CatalaRuntime.Money := (match (match processExceptions [if ((fun (employer_local : Sections.Organization) => (!(decide ((List.foldl ((fun (acc : Bool) (org_status : Sections.OrganizationSection3306EmployerStatusOutput) => ((decide (acc)) || ((decide (((org_status).organization).id = (employer_local).id)) && (decide ((org_status).is_employer)))))) false organization_employer_statuses))))) (match (employer_unemployment_excise_tax_return).details with | Sections.EmployerVariant.GeneralEmployer variant => (variant).employer | Sections.EmployerVariant.AgriculturalEmployer variant => (variant).employer | Sections.EmployerVariant.DomesticServiceEmployer variant => (variant).employer)) then some ((CatalaRuntime.Money.ofCents 0)) else none] with | none => some (((fun (employer_local : Sections.Organization) => ((fun (wages_for_employer : (List Sections.WagePaymentEventSection3306WagesOutput)) => ((fun (wages_for_employment : (List Sections.WagePaymentEventSection3306WagesOutput)) => ((fun (unique_employee_wage_results : (List Sections.WagePaymentEventSection3306WagesOutput)) => ((fun (unique_employee_ids : (List Int)) => (match (List.map ((fun (emp_id_local : Int) => ((fun (employee_wages : (List Sections.WagePaymentEventSection3306WagesOutput)) => (((totalWages3306Calculation ({ wage_results := employee_wages } : TotalWages3306Calculation_Input))).main_output).total_taxable_wages) (List.filter ((fun (wage_result : Sections.WagePaymentEventSection3306WagesOutput) => (decide ((((wage_result).wage_payment_event).employee).id = emp_id_local)))) wages_for_employment)))) unique_employee_ids) with | [] => (fun () => (CatalaRuntime.Money.ofCents 0)) () | x0 :: xn => List.foldl (fun (sum1 : CatalaRuntime.Money) (sum2 : CatalaRuntime.Money) => (sum1 + sum2)) x0 xn)) (List.map ((fun (wage_result : Sections.WagePaymentEventSection3306WagesOutput) => (((wage_result).wage_payment_event).employee).id)) unique_employee_wage_results))) (List.filter ((fun (wage_result : Sections.WagePaymentEventSection3306WagesOutput) => (!(decide ((List.foldl ((fun (acc : Bool) (prev_wage_result : Sections.WagePaymentEventSection3306WagesOutput) => ((decide (acc)) || ((decide ((((prev_wage_result).wage_payment_event).employee).id = (((wage_result).wage_payment_event).employee).id)) && (decide (((prev_wage_result).wage_payment_event).id < ((wage_result).wage_payment_event).id)))))) false wages_for_employment)))))) wages_for_employment))) (List.filter ((fun (wage_result : Sections.WagePaymentEventSection3306WagesOutput) => (List.foldl ((fun (acc : Bool) (emp_result : Sections.EmploymentRelationshipEventSection3306EmploymentOutput) => ((decide (acc)) || ((decide ((((emp_result).employment_relationship_event).employer).id = (((wage_result).wage_payment_event).employer).id)) && ((decide ((((emp_result).employment_relationship_event).employee).id = (((wage_result).wage_payment_event).employee).id)) && ((decide (((emp_result).employment_relationship_event).start_date ≤ ((wage_result).wage_payment_event).payment_date)) && (((decide ((Date_en.get_year ((emp_result).employment_relationship_event).start_date) = (employer_unemployment_excise_tax_return).tax_year)) || (decide ((Date_en.get_year ((emp_result).employment_relationship_event).end_date) = (employer_unemployment_excise_tax_return).tax_year))) && (decide ((emp_result).is_employment))))))))) false employment_relationship_employment_results))) wages_for_employer))) (List.filter ((fun (wage_result : Sections.WagePaymentEventSection3306WagesOutput) => ((decide ((((wage_result).wage_payment_event).employer).id = (employer_local).id)) && (decide ((Date_en.get_year ((wage_result).wage_payment_event).payment_date) = (employer_unemployment_excise_tax_return).tax_year))))) wage_payment_wages_results))) (match (employer_unemployment_excise_tax_return).details with | Sections.EmployerVariant.GeneralEmployer variant => (variant).employer | Sections.EmployerVariant.AgriculturalEmployer variant => (variant).employer | Sections.EmployerVariant.DomesticServiceEmployer variant => (variant).employer))) | some r => some r) with | some r => r | _ => default)
  excise_tax : CatalaRuntime.Money := (CatalaRuntime.multiply total_taxable_wages tax_rate)

def Sections.EmployerUnemploymentExciseTaxFilerSection3301Tax_main_output_leaf_0 (input : Sections.EmployerUnemploymentExciseTaxFilerSection3301Tax_Input) : Option Sections.EmployerUnemploymentExciseTaxFilerSection3301TaxOutput :=
  some (({ employer_unemployment_excise_tax_return := input.employer_unemployment_excise_tax_return, total_taxable_wages := input.total_taxable_wages, excise_tax := input.excise_tax, tax_rate := input.tax_rate } : EmployerUnemploymentExciseTaxFilerSection3301TaxOutput))

structure Sections.EmployerUnemploymentExciseTaxFilerSection3301Tax where
  tax_rate : Rat
  total_taxable_wages : CatalaRuntime.Money
  excise_tax : CatalaRuntime.Money
  main_output : Sections.EmployerUnemploymentExciseTaxFilerSection3301TaxOutput
deriving DecidableEq, Inhabited
def Sections.employerUnemploymentExciseTaxFilerSection3301Tax (input : Sections.EmployerUnemploymentExciseTaxFilerSection3301Tax_Input) : Sections.EmployerUnemploymentExciseTaxFilerSection3301Tax :=
  let main_output := match Sections.EmployerUnemploymentExciseTaxFilerSection3301Tax_main_output_leaf_0 input with | some val => val | _ => default 
  { tax_rate := input.tax_rate,
    total_taxable_wages := input.total_taxable_wages,
    excise_tax := input.excise_tax,
    main_output := main_output }

structure Sections.IndividualSection152Dependents_Input where
  marriage_events : (List Sections.MarriageEvent)
  income_events : (List Sections.IncomeEvent)
  tax_return_events : (List Sections.TaxReturnEvent)
  residence_period_events : (List Sections.ResidencePeriodEvent)
  birth_events : (List Sections.BirthEvent)
  family_relationship_events : (List Sections.FamilyRelationshipEvent)
  individuals : (List Sections.Individual)
  tax_year : Int
  taxpayer : Sections.Individual
  qualifying_children : (List Sections.IndividualSection152QualifyingChildOutput) := ((fun (potential_individuals : (List Sections.Individual)) => (List.map ((fun (individual : Sections.Individual) => ((individualSection152QualifyingChild ({ tax_return_events := tax_return_events, residence_period_events := residence_period_events, birth_events := birth_events, family_relationship_events := family_relationship_events, tax_year := tax_year, taxpayer := taxpayer, individual := individual } : IndividualSection152QualifyingChild_Input))).main_output)) potential_individuals)) (List.filter ((fun (individual : Sections.Individual) => (!(decide (individual = taxpayer))))) individuals))
  qualifying_relatives : (List Sections.IndividualSection152QualifyingRelativeOutput) := ((fun (potential_individuals : (List Sections.Individual)) => (List.map ((fun (individual : Sections.Individual) => ((individualSection152QualifyingRelative ({ marriage_events := marriage_events, income_events := income_events, tax_return_events := tax_return_events, qualifying_child_results := qualifying_children, residence_period_events := residence_period_events, family_relationship_events := family_relationship_events, tax_year := tax_year, taxpayer := taxpayer, individual := individual } : IndividualSection152QualifyingRelative_Input))).main_output)) potential_individuals)) (List.filter ((fun (individual : Sections.Individual) => (!(decide (individual = taxpayer))))) individuals))
  dependents_initial : (List Sections.Individual) := ((fun (qualifying_children_individuals : (List Sections.Individual)) => ((fun (qualifying_relatives_individuals : (List Sections.Individual)) => (qualifying_children_individuals ++ qualifying_relatives_individuals)) (List.map ((fun (result : Sections.IndividualSection152QualifyingRelativeOutput) => (result).individual)) (List.filter ((fun (result : Sections.IndividualSection152QualifyingRelativeOutput) => (result).is_qualifying_relative)) qualifying_relatives)))) (List.map ((fun (result : Sections.IndividualSection152QualifyingChildOutput) => (result).individual)) (List.filter ((fun (result : Sections.IndividualSection152QualifyingChildOutput) => (result).is_qualifying_child)) qualifying_children)))
  dependents_after_152b1 : (List Sections.Individual) := ((fun (initial_dependents : (List Sections.Individual)) => ((fun (is_dependent_of_another_taxpayer : Bool) => (if is_dependent_of_another_taxpayer then [] else initial_dependents)) (List.foldl ((fun (acc : Bool) (event : Sections.TaxReturnEvent) => ((decide (acc)) || ((!(decide ((event).individual = taxpayer))) && ((decide ((event).tax_year = tax_year)) && (decide ((List.foldl ((fun (acc : Bool) (dependent : Sections.Individual) => ((decide (acc)) || (decide (dependent = taxpayer))))) false (event).dependents)))))))) false tax_return_events))) ((fun (qualifying_children_individuals : (List Sections.Individual)) => ((fun (qualifying_relatives_individuals : (List Sections.Individual)) => (qualifying_children_individuals ++ qualifying_relatives_individuals)) (List.map ((fun (result : Sections.IndividualSection152QualifyingRelativeOutput) => (result).individual)) (List.filter ((fun (result : Sections.IndividualSection152QualifyingRelativeOutput) => (result).is_qualifying_relative)) qualifying_relatives)))) (List.map ((fun (result : Sections.IndividualSection152QualifyingChildOutput) => (result).individual)) (List.filter ((fun (result : Sections.IndividualSection152QualifyingChildOutput) => (result).is_qualifying_child)) qualifying_children))))
  dependents_after_152b2 : (List Sections.Individual) := ((fun (initial_dependents : (List Sections.Individual)) => ((fun (dependents_after_b1 : (List Sections.Individual)) => (List.filter ((fun (individual : Sections.Individual) => (!(decide ((List.foldl ((fun (acc : Bool) (event : Sections.TaxReturnEvent) => ((decide (acc)) || ((decide ((event).individual = individual)) && ((decide ((event).tax_year = tax_year)) && (decide ((event).filed_joint_return))))))) false tax_return_events)))))) dependents_after_b1)) ((fun (is_dependent_of_another_taxpayer : Bool) => (if is_dependent_of_another_taxpayer then [] else initial_dependents)) (List.foldl ((fun (acc : Bool) (event : Sections.TaxReturnEvent) => ((decide (acc)) || ((!(decide ((event).individual = taxpayer))) && ((decide ((event).tax_year = tax_year)) && (decide ((List.foldl ((fun (acc : Bool) (dependent : Sections.Individual) => ((decide (acc)) || (decide (dependent = taxpayer))))) false (event).dependents)))))))) false tax_return_events)))) ((fun (qualifying_children_individuals : (List Sections.Individual)) => ((fun (qualifying_relatives_individuals : (List Sections.Individual)) => (qualifying_children_individuals ++ qualifying_relatives_individuals)) (List.map ((fun (result : Sections.IndividualSection152QualifyingRelativeOutput) => (result).individual)) (List.filter ((fun (result : Sections.IndividualSection152QualifyingRelativeOutput) => (result).is_qualifying_relative)) qualifying_relatives)))) (List.map ((fun (result : Sections.IndividualSection152QualifyingChildOutput) => (result).individual)) (List.filter ((fun (result : Sections.IndividualSection152QualifyingChildOutput) => (result).is_qualifying_child)) qualifying_children))))

def Sections.IndividualSection152Dependents_main_output_leaf_0 (input : Sections.IndividualSection152Dependents_Input) : Option Sections.IndividualSection152DependentsOutput :=
  some (({ taxpayer := input.taxpayer, dependents_initial := input.dependents_initial, dependents_after_152b1 := input.dependents_after_152b1, dependents_after_152b2 := input.dependents_after_152b2, qualifying_children := input.qualifying_children, qualifying_relatives := input.qualifying_relatives } : IndividualSection152DependentsOutput))

structure Sections.IndividualSection152Dependents where
  main_output : Sections.IndividualSection152DependentsOutput
deriving DecidableEq, Inhabited
def Sections.individualSection152Dependents (input : Sections.IndividualSection152Dependents_Input) : Sections.IndividualSection152Dependents :=
  let main_output := match Sections.IndividualSection152Dependents_main_output_leaf_0 input with | some val => val | _ => default 
  { main_output := main_output }

structure Sections.IRCSimplified_Input where
  employer_unemployment_excise_tax_return : Sections.EmployerUnemploymentExciseTaxReturn
  employment_termination_events : (List Sections.EmploymentTerminationEvent)
  immigration_admission_events : (List Sections.ImmigrationAdmissionEvent)
  hospital_patient_events : (List Sections.HospitalPatientEvent)
  student_enrollment_events : (List Sections.StudentEnrollmentEvent)
  wage_payment_events : (List Sections.WagePaymentEvent)
  employment_relationship_events : (List Sections.EmploymentRelationshipEvent)
  income_events : (List Sections.IncomeEvent)
  tax_return_events : (List Sections.TaxReturnEvent)
  family_relationship_events : (List Sections.FamilyRelationshipEvent)
  parenthood_events : (List Sections.ParenthoodEvent)
  household_maintenance_events : (List Sections.HouseholdMaintenanceEvent)
  residence_period_events : (List Sections.ResidencePeriodEvent)
  divorce_or_legal_separation_events : (List Sections.DivorceOrLegalSeparationEvent)
  remarriage_events : (List Sections.RemarriageEvent)
  marriage_events : (List Sections.MarriageEvent)
  nonresident_alien_status_period_events : (List Sections.NonresidentAlienStatusPeriodEvent)
  death_events : (List Sections.DeathEvent)
  blindness_status_events : (List Sections.BlindnessStatusEvent)
  birth_events : (List Sections.BirthEvent)
  organizations : (List Sections.Organization)
  individuals : (List Sections.Individual)
  individual_tax_return : Sections.IndividualTaxReturn
  itemized_deductions : CatalaRuntime.Money := (CatalaRuntime.Money.ofCents 0)
  adjusted_gross_income : CatalaRuntime.Money
  section_2_a_1_A_spouse_died_in_preceding_two_years : Bool := ((fun (spouse_local : (Optional Sections.Individual)) => (match spouse_local with | Optional.Absent _ => false | Optional.Present s => (List.foldl ((fun (acc : Bool) (death_event : Sections.DeathEvent) => ((decide (acc)) || ((decide ((death_event).decedent = s)) && ((decide ((Date_en.get_year (death_event).death_date) ≥ ((individual_tax_return).tax_year - (2 : Int)))) && (decide ((Date_en.get_year (death_event).death_date) < (individual_tax_return).tax_year))))))) false death_events))) (Sections.get_spouse individual_tax_return))
  section_2_a_2_B_joint_return_could_have_been_made : Bool := ((fun (spouse_local : (Optional Sections.Individual)) => ((fun (taxpayer_local : Sections.Individual) => ((fun (spouse_death_events_in_window_local : (List Sections.DeathEvent)) => ((fun (spouse_death_year_local : (Optional Int)) => (match spouse_death_year_local with | Optional.Absent _ => false | Optional.Present death_year => ((!(decide ((List.foldl ((fun (acc : Bool) (residency_event_taxpayer : Sections.NonresidentAlienStatusPeriodEvent) => ((decide (acc)) || ((decide ((residency_event_taxpayer).individual = taxpayer_local)) && ((decide ((residency_event_taxpayer).residency_status = (ResidencyStatus.NonresidentAlien ()))) && ((decide ((residency_event_taxpayer).start_date ≤ (Date_en.of_year_month_day death_year (12 : Int) (31 : Int)))) && (decide ((residency_event_taxpayer).end_date ≥ (Date_en.of_year_month_day death_year (1 : Int) (1 : Int)))))))))) false nonresident_alien_status_period_events)))) && (!(match spouse_local with | Optional.Absent _ => false | Optional.Present s => (List.foldl ((fun (acc : Bool) (residency_event_spouse : Sections.NonresidentAlienStatusPeriodEvent) => ((decide (acc)) || ((decide ((residency_event_spouse).individual = s)) && ((decide ((residency_event_spouse).residency_status = (ResidencyStatus.NonresidentAlien ()))) && ((decide ((residency_event_spouse).start_date ≤ (Date_en.of_year_month_day death_year (12 : Int) (31 : Int)))) && (decide ((residency_event_spouse).end_date ≥ (Date_en.of_year_month_day death_year (1 : Int) (1 : Int)))))))))) false nonresident_alien_status_period_events)))))) (Sections.section_2_spouse_death_year spouse_death_events_in_window_local))) (Sections.section_2_spouse_death_events_in_window spouse_local death_events (individual_tax_return).tax_year))) (Sections.get_taxpayer individual_tax_return))) (Sections.get_spouse individual_tax_return))
  section_2_a_2_A_taxpayer_has_remarried : Bool := ((fun (spouse_local : (Optional Sections.Individual)) => ((fun (spouse_death_events_in_window_local : (List Sections.DeathEvent)) => ((fun (most_recent_spouse_death_date_local : CatalaRuntime.Date) => (List.foldl ((fun (acc : Bool) (remarriage_event : Sections.RemarriageEvent) => ((decide (acc)) || ((decide ((remarriage_event).individual = (Sections.get_taxpayer individual_tax_return))) && ((decide ((remarriage_event).remarriage_date > most_recent_spouse_death_date_local)) && (decide ((remarriage_event).remarriage_date ≤ (Sections.get_year_end (individual_tax_return).tax_year)))))))) false remarriage_events)) (Sections.section_2_most_recent_spouse_death_date spouse_death_events_in_window_local (individual_tax_return).tax_year))) (Sections.section_2_spouse_death_events_in_window spouse_local death_events (individual_tax_return).tax_year))) (Sections.get_spouse individual_tax_return))
  section_2_b_1_A_i_I_qualifying_child_is_married_at_close_of_year : Bool := ((fun (year_end_local : CatalaRuntime.Date) => (match (individual_tax_return).details with | Sections.FilingStatusVariant.JointReturn variant => false | Sections.FilingStatusVariant.SurvivingSpouse variant => false | Sections.FilingStatusVariant.HeadOfHousehold variant => (List.foldl ((fun (acc : Bool) (marriage_event : Sections.MarriageEvent) => ((decide (acc)) || (((decide ((marriage_event).spouse1 = (variant).qualifying_person)) || (decide ((marriage_event).spouse2 = (variant).qualifying_person))) && ((decide ((marriage_event).marriage_date ≤ year_end_local)) && (!(decide ((List.foldl ((fun (acc : Bool) (divorce_event : Sections.DivorceOrLegalSeparationEvent) => ((decide (acc)) || (((decide ((divorce_event).person1 = (variant).qualifying_person)) || (decide ((divorce_event).person2 = (variant).qualifying_person))) && ((decide ((divorce_event).decree_date > (marriage_event).marriage_date)) && (decide ((divorce_event).decree_date ≤ year_end_local))))))) false divorce_or_legal_separation_events))))))))) false marriage_events) | Sections.FilingStatusVariant.Single variant => false | Sections.FilingStatusVariant.MarriedFilingSeparate variant => false)) (Sections.get_year_end (individual_tax_return).tax_year))
  section_2_b_2_is_married_at_close_of_year : Bool := ((fun (spouse_local : (Optional Sections.Individual)) => ((fun (taxpayer_local : Sections.Individual) => ((fun (year_end_local : CatalaRuntime.Date) => (match spouse_local with | Optional.Absent _ => false | Optional.Present s => (if (List.foldl ((fun (acc : Bool) (divorce_event : Sections.DivorceOrLegalSeparationEvent) => ((decide (acc)) || (((decide ((divorce_event).person1 = taxpayer_local)) || (decide ((divorce_event).person2 = taxpayer_local))) && (((decide ((divorce_event).person1 = s)) || (decide ((divorce_event).person2 = s))) && (decide ((divorce_event).decree_date ≤ year_end_local))))))) false divorce_or_legal_separation_events) then false else (if (List.foldl ((fun (acc : Bool) (residency_event : Sections.NonresidentAlienStatusPeriodEvent) => ((decide (acc)) || ((decide ((residency_event).individual = s)) && ((decide ((residency_event).start_date ≤ year_end_local)) && ((decide ((residency_event).end_date ≥ (Date_en.of_year_month_day (individual_tax_return).tax_year (1 : Int) (1 : Int)))) && (decide ((residency_event).residency_status = (ResidencyStatus.NonresidentAlien ()))))))))) false nonresident_alien_status_period_events) then false else (if (List.foldl ((fun (acc : Bool) (death_event : Sections.DeathEvent) => ((decide (acc)) || ((decide ((death_event).decedent = s)) && ((decide ((Date_en.get_year (death_event).death_date) = (individual_tax_return).tax_year)) && (!(decide ((List.foldl ((fun (acc : Bool) (residency_event : Sections.NonresidentAlienStatusPeriodEvent) => ((decide (acc)) || ((decide ((residency_event).individual = s)) && ((decide ((residency_event).start_date ≤ (death_event).death_date)) && ((decide ((residency_event).end_date ≥ (Date_en.of_year_month_day (individual_tax_return).tax_year (1 : Int) (1 : Int)))) && (decide ((residency_event).residency_status = (ResidencyStatus.NonresidentAlien ()))))))))) false nonresident_alien_status_period_events))))))))) false death_events) then true else (List.foldl ((fun (acc : Bool) (marriage_event : Sections.MarriageEvent) => ((decide (acc)) || (((decide ((marriage_event).spouse1 = taxpayer_local)) || (decide ((marriage_event).spouse2 = taxpayer_local))) && (((decide ((marriage_event).spouse1 = s)) || (decide ((marriage_event).spouse2 = s))) && ((decide ((marriage_event).marriage_date ≤ year_end_local)) && (!(decide ((List.foldl ((fun (acc : Bool) (divorce_event : Sections.DivorceOrLegalSeparationEvent) => ((decide (acc)) || (((decide ((divorce_event).person1 = taxpayer_local)) || (decide ((divorce_event).person2 = taxpayer_local))) && (((decide ((divorce_event).person1 = s)) || (decide ((divorce_event).person2 = s))) && ((decide ((divorce_event).decree_date > (marriage_event).marriage_date)) && (decide ((divorce_event).decree_date ≤ year_end_local)))))))) false divorce_or_legal_separation_events)))))))))) false marriage_events)))))) (Sections.get_year_end (individual_tax_return).tax_year))) (Sections.get_taxpayer individual_tax_return))) (Sections.get_spouse individual_tax_return))
  taxpayer_dependents : Sections.IndividualSection152Dependents := Sections.individualSection152Dependents { taxpayer := (Sections.get_taxpayer individual_tax_return), tax_year := (individual_tax_return).tax_year, individuals := individuals, family_relationship_events := family_relationship_events, birth_events := birth_events, residence_period_events := residence_period_events, tax_return_events := tax_return_events, income_events := income_events, marriage_events := marriage_events }
  wage_payment_wages_results : (List Sections.WagePaymentEventSection3306WagesOutput) := (List.map ((fun (wage_event : Sections.WagePaymentEvent) => ((wagePaymentEventSection3306Wages ({ death_events := death_events, employment_termination_events := employment_termination_events, wage_payment_event := wage_event } : WagePaymentEventSection3306Wages_Input))).main_output)) wage_payment_events)
  employment_relationship_employment_results : (List Sections.EmploymentRelationshipEventSection3306EmploymentOutput) := (List.map ((fun (emp_event : Sections.EmploymentRelationshipEvent) => ((employmentRelationshipEventSection3306Employment ({ marriage_events := marriage_events, birth_events := birth_events, parenthood_events := parenthood_events, immigration_admission_events := immigration_admission_events, hospital_patient_events := hospital_patient_events, student_enrollment_events := student_enrollment_events, employment_relationship_events := employment_relationship_events, wage_payment_events := wage_payment_events, calendar_year := (employer_unemployment_excise_tax_return).tax_year, employment_relationship_event := emp_event } : EmploymentRelationshipEventSection3306Employment_Input))).main_output)) employment_relationship_events)
  organization_employer_statuses : (List Sections.OrganizationSection3306EmployerStatusOutput) := ((fun (organizations_with_events : (List Sections.Organization)) => (List.map ((fun (organization : Sections.Organization) => ((organizationSection3306EmployerStatus ({ employment_relationship_events := employment_relationship_events, wage_payment_events := wage_payment_events, calendar_year := (employer_unemployment_excise_tax_return).tax_year, organization := organization } : OrganizationSection3306EmployerStatus_Input))).main_output)) organizations_with_events)) (List.filter ((fun (org : Sections.Organization) => (List.foldl ((fun (acc : Bool) (wage_event : Sections.WagePaymentEvent) => ((decide (acc)) || ((decide (((wage_event).employer).id = (org).id)) || (decide ((List.foldl ((fun (acc : Bool) (emp_event : Sections.EmploymentRelationshipEvent) => ((decide (acc)) || (decide (((emp_event).employer).id = (org).id))))) false employment_relationship_events))))))) false wage_payment_events))) organizations))
  section_68_eighty_percent_reduction : CatalaRuntime.Money := (CatalaRuntime.multiply itemized_deductions (Rat.mk 4 5))
  taxpayer_dependents_result : Sections.IndividualSection152DependentsOutput := (taxpayer_dependents).main_output
  employer_unemployment_excise_tax : Sections.EmployerUnemploymentExciseTaxFilerSection3301Tax := Sections.employerUnemploymentExciseTaxFilerSection3301Tax { employer_unemployment_excise_tax_return := employer_unemployment_excise_tax_return, wage_payment_wages_results := wage_payment_wages_results, organization_employer_statuses := organization_employer_statuses, employment_relationship_employment_results := employment_relationship_employment_results }
  taxpayer_exemptions_list : Sections.TaxpayerExemptionsList := Sections.taxpayerExemptionsList { individual_tax_return := individual_tax_return, tax_return_events := tax_return_events, income_events := income_events, dependents := (taxpayer_dependents_result).dependents_after_152b2 }
  section_2_b_1_A_i_II_qualifying_person_not_dependent_by_152b2 : Bool := (match (individual_tax_return).details with | Sections.FilingStatusVariant.JointReturn variant => false | Sections.FilingStatusVariant.SurvivingSpouse variant => false | Sections.FilingStatusVariant.HeadOfHousehold variant => (List.foldl ((fun (acc : Bool) (dependent_individual : Sections.Individual) => ((decide (acc)) || ((decide (dependent_individual = (variant).qualifying_person)) && (!(decide ((List.foldl ((fun (acc : Bool) (dependent_individual_final : Sections.Individual) => ((decide (acc)) || (decide (dependent_individual_final = (variant).qualifying_person))))) false (taxpayer_dependents_result).dependents_after_152b2)))))))) false (taxpayer_dependents_result).dependents_after_152b1) | Sections.FilingStatusVariant.Single variant => false | Sections.FilingStatusVariant.MarriedFilingSeparate variant => false)
  employer_unemployment_excise_tax_result : Sections.EmployerUnemploymentExciseTaxFilerSection3301TaxOutput := (employer_unemployment_excise_tax).main_output
  taxpayer_exemptions_list_result : Sections.TaxpayerExemptionsListOutput := (taxpayer_exemptions_list).main_output
  section_2_b_1_A_i_satisfied : Bool := (match (individual_tax_return).details with | Sections.FilingStatusVariant.JointReturn variant => false | Sections.FilingStatusVariant.SurvivingSpouse variant => false | Sections.FilingStatusVariant.HeadOfHousehold variant => ((fun (qualifying_person_is_qualifying_child_local : Bool) => ((decide (qualifying_person_is_qualifying_child_local)) && (!((decide (section_2_b_1_A_i_I_qualifying_child_is_married_at_close_of_year)) && (decide (section_2_b_1_A_i_II_qualifying_person_not_dependent_by_152b2)))))) ((fun (result : Sections.IndividualSection152QualifyingChild) => ((result).main_output).is_qualifying_child) (individualSection152QualifyingChild ({ tax_return_events := tax_return_events, residence_period_events := residence_period_events, birth_events := birth_events, family_relationship_events := family_relationship_events, tax_year := (individual_tax_return).tax_year, taxpayer := (Sections.get_taxpayer individual_tax_return), individual := (variant).qualifying_person } : IndividualSection152QualifyingChild_Input)))) | Sections.FilingStatusVariant.Single variant => false | Sections.FilingStatusVariant.MarriedFilingSeparate variant => false)
  taxpayer_marital_status : Sections.IndividualSection7703MaritalStatus := Sections.individualSection7703MaritalStatus { individual := (match (individual_tax_return).details with | Sections.FilingStatusVariant.JointReturn variant => (variant).taxpayer | Sections.FilingStatusVariant.SurvivingSpouse variant => (variant).taxpayer | Sections.FilingStatusVariant.HeadOfHousehold variant => (variant).taxpayer | Sections.FilingStatusVariant.Single variant => (variant).taxpayer | Sections.FilingStatusVariant.MarriedFilingSeparate variant => (variant).taxpayer), tax_year := (individual_tax_return).tax_year, marriage_events := marriage_events, divorce_or_legal_separation_events := divorce_or_legal_separation_events, death_events := death_events, individual_tax_return := individual_tax_return, residence_period_events := residence_period_events, household_maintenance_events := household_maintenance_events, qualifying_children := (taxpayer_dependents_result).qualifying_children, individuals_entitled_to_exemptions_under_151 := (taxpayer_exemptions_list_result).individuals_entitled_to_exemptions_under_151 }
  additional_amount_spouse_blind : CatalaRuntime.Money := (match (match processExceptions [if ((fun (spouse_local : (Optional Sections.Individual)) => ((fun (year_end_local : CatalaRuntime.Date) => ((fun (spouse_death_events_local : (List Sections.DeathEvent)) => ((fun (spouse_death_date_local : CatalaRuntime.Date) => ((fun (spouse_is_blind_at_close_local : Bool) => ((decide (spouse_is_blind_at_close_local)) && ((decide ((taxpayer_exemptions_list_result).spouse_personal_exemption_allowed)) && (match (individual_tax_return).details with | Sections.FilingStatusVariant.JointReturn variant => true | Sections.FilingStatusVariant.SurvivingSpouse variant => true | Sections.FilingStatusVariant.HeadOfHousehold variant => false | Sections.FilingStatusVariant.Single variant => false | Sections.FilingStatusVariant.MarriedFilingSeparate variant => true)))) (match spouse_local with | Optional.Absent _ => false | Optional.Present s => (Sections.individual_is_blind_at_close s blindness_status_events death_events spouse_death_date_local)))) (if (decide ((spouse_death_events_local).length > (0 : Int))) then (match (List.map ((fun (death_event : Sections.DeathEvent) => (death_event).death_date)) spouse_death_events_local) with | [] => (fun () => default /-unsupported expression-/) () | x0 :: xn => List.foldl (fun (min1 : CatalaRuntime.Date) (min2 : CatalaRuntime.Date) => (if (decide (min1 < min2)) then min1 else min2)) x0 xn) else year_end_local))) (match spouse_local with | Optional.Absent _ => (List.filter ((fun (death_event : Sections.DeathEvent) => false)) death_events) | Optional.Present s => (List.filter ((fun (death_event : Sections.DeathEvent) => ((decide ((death_event).decedent = s)) && (decide ((Date_en.get_year (death_event).death_date) = (individual_tax_return).tax_year))))) death_events)))) (Sections.get_year_end (individual_tax_return).tax_year))) (Sections.get_spouse individual_tax_return)) then some ((CatalaRuntime.Money.ofCents 60000)) else none] with | none => some ((CatalaRuntime.Money.ofCents 0)) | some r => some r) with | some r => r | _ => default)
  additional_amount_spouse_aged : CatalaRuntime.Money := (match (match processExceptions [if ((fun (spouse_local : (Optional Sections.Individual)) => ((fun (year_end_local : CatalaRuntime.Date) => ((fun (spouse_attained_age_65_local : Bool) => ((decide (spouse_attained_age_65_local)) && ((decide ((taxpayer_exemptions_list_result).spouse_personal_exemption_allowed)) && (match (individual_tax_return).details with | Sections.FilingStatusVariant.JointReturn variant => true | Sections.FilingStatusVariant.SurvivingSpouse variant => true | Sections.FilingStatusVariant.HeadOfHousehold variant => false | Sections.FilingStatusVariant.Single variant => false | Sections.FilingStatusVariant.MarriedFilingSeparate variant => true)))) (match spouse_local with | Optional.Absent _ => false | Optional.Present s => (Sections.individual_attained_age_65 s birth_events year_end_local)))) (Sections.get_year_end (individual_tax_return).tax_year))) (Sections.get_spouse individual_tax_return)) then some ((CatalaRuntime.Money.ofCents 60000)) else none] with | none => some ((CatalaRuntime.Money.ofCents 0)) | some r => some r) with | some r => r | _ => default)
  section_2_b_1_B_satisfied : Bool := ((fun (taxpayer_local : Sections.Individual) => ((fun (year_end_local : CatalaRuntime.Date) => (match (individual_tax_return).details with | Sections.FilingStatusVariant.JointReturn variant => false | Sections.FilingStatusVariant.SurvivingSpouse variant => false | Sections.FilingStatusVariant.HeadOfHousehold variant => ((fun (qualifying_person_is_father_or_mother_local : Bool) => ((fun (father_or_mother_has_principal_place_of_abode_local : Bool) => ((fun (taxpayer_entitled_to_section151_for_father_or_mother_local : Bool) => ((decide (father_or_mother_has_principal_place_of_abode_local)) && (decide (taxpayer_entitled_to_section151_for_father_or_mother_local)))) (List.foldl ((fun (acc : Bool) (entitled_individual : Sections.Individual) => ((decide (acc)) || (decide (entitled_individual = (variant).qualifying_person))))) false (taxpayer_exemptions_list_result).individuals_entitled_to_exemptions_under_151))) (List.foldl ((fun (acc : Bool) (maintenance_event : Sections.HouseholdMaintenanceEvent) => ((decide (acc)) || ((decide ((maintenance_event).individual = taxpayer_local)) && ((decide ((maintenance_event).start_date ≤ year_end_local)) && ((decide ((maintenance_event).end_date ≥ (Date_en.of_year_month_day (individual_tax_return).tax_year (1 : Int) (1 : Int)))) && ((decide ((maintenance_event).cost_furnished_percentage > (Rat.mk 1 2))) && (decide ((List.foldl ((fun (acc : Bool) (residence_event : Sections.ResidencePeriodEvent) => ((decide (acc)) || ((decide ((residence_event).individual = (variant).qualifying_person)) && ((decide ((residence_event).household = (maintenance_event).household)) && ((decide ((residence_event).is_principal_place_of_abode)) && ((decide ((residence_event).start_date ≤ year_end_local)) && ((decide ((residence_event).end_date ≥ (Date_en.of_year_month_day (individual_tax_return).tax_year (1 : Int) (1 : Int)))) && (decide (qualifying_person_is_father_or_mother_local)))))))))) false residence_period_events)))))))))) false household_maintenance_events))) (List.foldl ((fun (acc : Bool) (parenthood_event : Sections.ParenthoodEvent) => ((decide (acc)) || ((decide ((parenthood_event).parent = (variant).qualifying_person)) && ((decide ((parenthood_event).child = taxpayer_local)) && ((decide ((parenthood_event).start_date ≤ year_end_local)) && ((decide ((parenthood_event).parent_type = (ParentType.Biological ()))) || (decide ((parenthood_event).parent_type = (ParentType.Adoptive ())))))))))) false parenthood_events)) | Sections.FilingStatusVariant.Single variant => false | Sections.FilingStatusVariant.MarriedFilingSeparate variant => false)) (Sections.get_year_end (individual_tax_return).tax_year))) (Sections.get_taxpayer individual_tax_return))
  section_2_b_1_A_ii_satisfied : Bool := (match (individual_tax_return).details with | Sections.FilingStatusVariant.JointReturn variant => false | Sections.FilingStatusVariant.SurvivingSpouse variant => false | Sections.FilingStatusVariant.HeadOfHousehold variant => ((decide ((List.foldl ((fun (acc : Bool) (dependent_individual : Sections.Individual) => ((decide (acc)) || (decide (dependent_individual = (variant).qualifying_person))))) false (taxpayer_dependents_result).dependents_after_152b2))) && (decide ((List.foldl ((fun (acc : Bool) (entitled_individual : Sections.Individual) => ((decide (acc)) || (decide (entitled_individual = (variant).qualifying_person))))) false (taxpayer_exemptions_list_result).individuals_entitled_to_exemptions_under_151)))) | Sections.FilingStatusVariant.Single variant => false | Sections.FilingStatusVariant.MarriedFilingSeparate variant => false)
  section_2_a_1_B_satisfied : Bool := ((fun (taxpayer_local : Sections.Individual) => ((fun (year_end_local : CatalaRuntime.Date) => (match (individual_tax_return).details with | Sections.FilingStatusVariant.JointReturn variant => false | Sections.FilingStatusVariant.SurvivingSpouse variant => ((fun (dependent_is_son_stepson_daughter_stepdaughter_local : Bool) => ((fun (dependent_has_principal_place_of_abode_in_taxpayer_household_local : Bool) => ((fun (taxpayer_entitled_to_section151_deduction_for_dependent_local : Bool) => ((decide (dependent_is_son_stepson_daughter_stepdaughter_local)) && ((decide (dependent_has_principal_place_of_abode_in_taxpayer_household_local)) && (decide (taxpayer_entitled_to_section151_deduction_for_dependent_local))))) (List.foldl ((fun (acc : Bool) (entitled_individual : Sections.Individual) => ((decide (acc)) || (decide (entitled_individual = (variant).qualifying_dependent))))) false (taxpayer_exemptions_list_result).individuals_entitled_to_exemptions_under_151))) (List.foldl ((fun (acc : Bool) (maintenance_event : Sections.HouseholdMaintenanceEvent) => ((decide (acc)) || ((decide ((maintenance_event).individual = taxpayer_local)) && ((decide ((maintenance_event).start_date ≤ year_end_local)) && ((decide ((maintenance_event).end_date ≥ (Date_en.of_year_month_day (individual_tax_return).tax_year (1 : Int) (1 : Int)))) && ((decide ((maintenance_event).cost_furnished_percentage > (Rat.mk 1 2))) && (decide ((List.foldl ((fun (acc : Bool) (residence_event : Sections.ResidencePeriodEvent) => ((decide (acc)) || ((decide ((residence_event).individual = (variant).qualifying_dependent)) && ((decide ((residence_event).household = (maintenance_event).household)) && ((decide ((residence_event).is_member_of_household)) && ((decide ((residence_event).is_principal_place_of_abode)) && ((decide ((residence_event).start_date ≤ year_end_local)) && (decide ((residence_event).end_date ≥ (Date_en.of_year_month_day (individual_tax_return).tax_year (1 : Int) (1 : Int)))))))))))) false residence_period_events)))))))))) false household_maintenance_events))) (List.foldl ((fun (acc : Bool) (parenthood_event : Sections.ParenthoodEvent) => ((decide (acc)) || ((decide ((parenthood_event).parent = taxpayer_local)) && ((decide ((parenthood_event).child = (variant).qualifying_dependent)) && ((decide ((parenthood_event).start_date ≤ year_end_local)) && ((decide ((parenthood_event).parent_type = (ParentType.Biological ()))) || (decide ((parenthood_event).parent_type = (ParentType.Step ())))))))))) false parenthood_events)) | Sections.FilingStatusVariant.HeadOfHousehold variant => false | Sections.FilingStatusVariant.Single variant => false | Sections.FilingStatusVariant.MarriedFilingSeparate variant => false)) (Sections.get_year_end (individual_tax_return).tax_year))) (Sections.get_taxpayer individual_tax_return))
  individual_marital_statuses : (List Sections.IndividualSection7703MaritalStatusOutput) := [(taxpayer_marital_status).main_output]
  standard_deduction_eligible : Bool := (match (match processExceptions [processExceptions [if ((match (individual_tax_return).details with | Sections.FilingStatusVariant.JointReturn variant => (variant).is_estate_or_trust | Sections.FilingStatusVariant.SurvivingSpouse variant => (variant).is_estate_or_trust | Sections.FilingStatusVariant.HeadOfHousehold variant => (variant).is_estate_or_trust | Sections.FilingStatusVariant.Single variant => (variant).is_estate_or_trust | Sections.FilingStatusVariant.MarriedFilingSeparate variant => (variant).is_estate_or_trust) || ((match (individual_tax_return).details with | Sections.FilingStatusVariant.JointReturn variant => (variant).is_common_trust_fund | Sections.FilingStatusVariant.SurvivingSpouse variant => (variant).is_common_trust_fund | Sections.FilingStatusVariant.HeadOfHousehold variant => (variant).is_common_trust_fund | Sections.FilingStatusVariant.Single variant => (variant).is_common_trust_fund | Sections.FilingStatusVariant.MarriedFilingSeparate variant => (variant).is_common_trust_fund) || (match (individual_tax_return).details with | Sections.FilingStatusVariant.JointReturn variant => (variant).is_partnership | Sections.FilingStatusVariant.SurvivingSpouse variant => (variant).is_partnership | Sections.FilingStatusVariant.HeadOfHousehold variant => (variant).is_partnership | Sections.FilingStatusVariant.Single variant => (variant).is_partnership | Sections.FilingStatusVariant.MarriedFilingSeparate variant => (variant).is_partnership))) then some (false) else none, if ((fun (taxpayer_local : Sections.Individual) => ((fun (year_end_local : CatalaRuntime.Date) => (Sections.individual_is_nonresident_alien_during_year taxpayer_local nonresident_alien_status_period_events (individual_tax_return).tax_year year_end_local)) (Sections.get_year_end (individual_tax_return).tax_year))) (Sections.get_taxpayer individual_tax_return)) then some (false) else none, if ((decide (((taxpayer_marital_status).main_output).is_married_for_tax_purposes)) && ((match (individual_tax_return).details with | Sections.FilingStatusVariant.JointReturn variant => false | Sections.FilingStatusVariant.SurvivingSpouse variant => false | Sections.FilingStatusVariant.HeadOfHousehold variant => false | Sections.FilingStatusVariant.Single variant => false | Sections.FilingStatusVariant.MarriedFilingSeparate variant => true) && ((match (individual_tax_return).details with | Sections.FilingStatusVariant.JointReturn variant => (variant).itemization_election | Sections.FilingStatusVariant.SurvivingSpouse variant => (variant).itemization_election | Sections.FilingStatusVariant.HeadOfHousehold variant => (variant).itemization_election | Sections.FilingStatusVariant.Single variant => (variant).itemization_election | Sections.FilingStatusVariant.MarriedFilingSeparate variant => (variant).itemization_election) || (decide ((Sections.extract_spouse_itemization_election individual_tax_return)))))) then some (false) else none]] with | none => some (true) | some r => some r) with | some r => r | _ => default)
  section_2_b_1_A_satisfied : Bool := ((fun (taxpayer_local : Sections.Individual) => ((fun (year_end_local : CatalaRuntime.Date) => ((fun (qualifying_person_has_principal_place_of_abode_more_than_half_year_local : Bool) => ((decide (qualifying_person_has_principal_place_of_abode_more_than_half_year_local)) && ((decide (section_2_b_1_A_i_satisfied)) || (decide (section_2_b_1_A_ii_satisfied))))) (match (individual_tax_return).details with | Sections.FilingStatusVariant.JointReturn variant => false | Sections.FilingStatusVariant.SurvivingSpouse variant => false | Sections.FilingStatusVariant.HeadOfHousehold variant => (List.foldl ((fun (acc : Bool) (maintenance_event : Sections.HouseholdMaintenanceEvent) => ((decide (acc)) || ((decide ((maintenance_event).individual = taxpayer_local)) && ((decide ((maintenance_event).start_date ≤ year_end_local)) && ((decide ((maintenance_event).end_date ≥ (Date_en.of_year_month_day (individual_tax_return).tax_year (1 : Int) (1 : Int)))) && ((decide ((maintenance_event).cost_furnished_percentage > (Rat.mk 1 2))) && (decide ((List.foldl ((fun (acc : Bool) (residence_event : Sections.ResidencePeriodEvent) => ((decide (acc)) || ((decide ((residence_event).individual = (variant).qualifying_person)) && ((decide ((residence_event).household = (maintenance_event).household)) && ((decide ((residence_event).is_member_of_household)) && ((decide ((residence_event).is_principal_place_of_abode)) && ((decide ((residence_event).start_date ≤ (Date_en.of_year_month_day (individual_tax_return).tax_year (6 : Int) (30 : Int)))) && (decide ((residence_event).end_date ≥ (Date_en.of_year_month_day (individual_tax_return).tax_year (7 : Int) (1 : Int)))))))))))) false residence_period_events)))))))))) false household_maintenance_events) | Sections.FilingStatusVariant.Single variant => false | Sections.FilingStatusVariant.MarriedFilingSeparate variant => false))) (Sections.get_year_end (individual_tax_return).tax_year))) (Sections.get_taxpayer individual_tax_return))
  is_surviving_spouse : Bool := (match (match processExceptions [processExceptions [if section_2_a_2_A_taxpayer_has_remarried then some (false) else none, if (!(decide (section_2_a_2_B_joint_return_could_have_been_made))) then some (false) else none]] with | none => some (((decide (section_2_a_1_A_spouse_died_in_preceding_two_years)) && (decide (section_2_a_1_B_satisfied)))) | some r => some r) with | some r => r | _ => default)
  is_head_of_household : Bool := (match (match processExceptions [if (match (individual_tax_return).details with | Sections.FilingStatusVariant.JointReturn variant => false | Sections.FilingStatusVariant.SurvivingSpouse variant => false | Sections.FilingStatusVariant.HeadOfHousehold variant => (List.foldl ((fun (acc : Bool) (result : Sections.IndividualSection152QualifyingRelativeOutput) => ((decide (acc)) || ((decide ((result).individual = (variant).qualifying_person)) && ((decide ((result).taxpayer = (Sections.get_taxpayer individual_tax_return))) && ((decide ((result).is_qualifying_relative)) && ((!(decide ((result).relationship_requirement_met))) && (decide ((result).relationship_requirement_met_H))))))))) false (taxpayer_dependents_result).qualifying_relatives) | Sections.FilingStatusVariant.Single variant => false | Sections.FilingStatusVariant.MarriedFilingSeparate variant => false) then some (false) else none, if ((fun (taxpayer_local : Sections.Individual) => ((fun (year_end_local : CatalaRuntime.Date) => (List.foldl ((fun (acc : Bool) (residency_event : Sections.NonresidentAlienStatusPeriodEvent) => ((decide (acc)) || ((decide ((residency_event).individual = taxpayer_local)) && ((decide ((residency_event).start_date ≤ year_end_local)) && ((decide ((residency_event).end_date ≥ (Date_en.of_year_month_day (individual_tax_return).tax_year (1 : Int) (1 : Int)))) && (decide ((residency_event).residency_status = (ResidencyStatus.NonresidentAlien ()))))))))) false nonresident_alien_status_period_events)) (Sections.get_year_end (individual_tax_return).tax_year))) (Sections.get_taxpayer individual_tax_return)) then some (false) else none] with | none => some (((!(decide (section_2_b_2_is_married_at_close_of_year))) && ((!(decide (is_surviving_spouse))) && ((decide (section_2_b_1_A_satisfied)) || (decide (section_2_b_1_B_satisfied)))))) | some r => some r) with | some r => r | _ => default)
  additional_amount_taxpayer_blind : CatalaRuntime.Money := (match (match processExceptions [if ((fun (taxpayer_local : Sections.Individual) => ((fun (year_end_local : CatalaRuntime.Date) => ((decide ((Sections.individual_is_blind_at_close taxpayer_local blindness_status_events death_events year_end_local))) && ((!(decide (((taxpayer_marital_status).main_output).is_married_for_tax_purposes))) && (!(decide (is_surviving_spouse)))))) (Sections.get_year_end (individual_tax_return).tax_year))) (Sections.get_taxpayer individual_tax_return)) then some ((CatalaRuntime.Money.ofCents 75000)) else none] with | none => some ((if (Sections.individual_is_blind_at_close (Sections.get_taxpayer individual_tax_return) blindness_status_events death_events (Sections.get_year_end (individual_tax_return).tax_year)) then (CatalaRuntime.Money.ofCents 60000) else (CatalaRuntime.Money.ofCents 0))) | some r => some r) with | some r => r | _ => default)
  additional_amount_taxpayer_aged : CatalaRuntime.Money := (match (match processExceptions [if ((fun (taxpayer_local : Sections.Individual) => ((fun (year_end_local : CatalaRuntime.Date) => ((decide ((Sections.individual_attained_age_65 taxpayer_local birth_events year_end_local))) && ((!(decide (((taxpayer_marital_status).main_output).is_married_for_tax_purposes))) && (!(decide (is_surviving_spouse)))))) (Sections.get_year_end (individual_tax_return).tax_year))) (Sections.get_taxpayer individual_tax_return)) then some ((CatalaRuntime.Money.ofCents 75000)) else none] with | none => some ((if (Sections.individual_attained_age_65 (Sections.get_taxpayer individual_tax_return) birth_events (Sections.get_year_end (individual_tax_return).tax_year)) then (CatalaRuntime.Money.ofCents 60000) else (CatalaRuntime.Money.ofCents 0))) | some r => some r) with | some r => r | _ => default)
  applicable_amount : CatalaRuntime.Money := (match (match processExceptions [(match processExceptions [(match processExceptions [if ((decide (((taxpayer_marital_status).main_output).is_married_for_tax_purposes)) && (match (individual_tax_return).details with | Sections.FilingStatusVariant.JointReturn variant => false | Sections.FilingStatusVariant.SurvivingSpouse variant => false | Sections.FilingStatusVariant.HeadOfHousehold variant => false | Sections.FilingStatusVariant.Single variant => false | Sections.FilingStatusVariant.MarriedFilingSeparate variant => true)) then some ((CatalaRuntime.Money.ofCents 15000000)) else none] with | none => if ((!(decide (((taxpayer_marital_status).main_output).is_married_for_tax_purposes))) && ((!(decide (is_surviving_spouse))) && (!(decide (is_head_of_household))))) then some ((CatalaRuntime.Money.ofCents 25000000)) else none | some r => some r)] with | none => if is_head_of_household then some ((CatalaRuntime.Money.ofCents 27500000)) else none | some r => some r)] with | none => some ((if (((decide (((taxpayer_marital_status).main_output).is_married_for_tax_purposes)) && (match (individual_tax_return).details with | Sections.FilingStatusVariant.JointReturn variant => true | Sections.FilingStatusVariant.SurvivingSpouse variant => false | Sections.FilingStatusVariant.HeadOfHousehold variant => false | Sections.FilingStatusVariant.Single variant => false | Sections.FilingStatusVariant.MarriedFilingSeparate variant => false)) || (decide (is_surviving_spouse))) then (CatalaRuntime.Money.ofCents 30000000) else (CatalaRuntime.Money.ofCents 0))) | some r => some r) with | some r => r | _ => default)
  basic_standard_deduction : CatalaRuntime.Money := (match (match processExceptions [if ((fun (taxpayer_local : Sections.Individual) => ((fun (deduction_allowable_to_another_taxpayer : Bool) => deduction_allowable_to_another_taxpayer) (List.foldl ((fun (acc : Bool) (event : Sections.TaxReturnEvent) => ((decide (acc)) || ((!(decide ((event).individual = taxpayer_local))) && ((decide ((event).tax_year = (individual_tax_return).tax_year)) && (decide ((List.foldl ((fun (acc : Bool) (dependent : Sections.Individual) => ((decide (acc)) || (decide (dependent = taxpayer_local))))) false (event).dependents)))))))) false tax_return_events))) (Sections.get_taxpayer individual_tax_return)) then some (((fun (taxpayer_local : Sections.Individual) => ((fun (earned_income_local : CatalaRuntime.Money) => ((Money_en.min (CatalaRuntime.Money.ofCents 50000) (CatalaRuntime.Money.ofCents 25000)) + earned_income_local)) ((fun (income_event_local : (List Sections.IncomeEvent)) => (if (decide ((income_event_local).length > (0 : Int))) then (match (List.map ((fun (event : Sections.IncomeEvent) => (event).earned_income)) income_event_local) with | [] => (fun () => (CatalaRuntime.Money.ofCents 0)) () | x0 :: xn => List.foldl (fun (sum1 : CatalaRuntime.Money) (sum2 : CatalaRuntime.Money) => (sum1 + sum2)) x0 xn) else (CatalaRuntime.Money.ofCents 0))) (List.filter ((fun (income_event : Sections.IncomeEvent) => ((decide ((income_event).individual = taxpayer_local)) && ((decide ((income_event).tax_year = (individual_tax_return).tax_year)) && (!(decide ((income_event).is_counterfactual))))))) income_events)))) (Sections.get_taxpayer individual_tax_return))) else none, (match processExceptions [(match processExceptions [if ((decide ((Sections.is_tax_year_2018_through_2025 (individual_tax_return).tax_year))) && (((decide (((taxpayer_marital_status).main_output).is_married_for_tax_purposes)) && (match (individual_tax_return).details with | Sections.FilingStatusVariant.JointReturn variant => true | Sections.FilingStatusVariant.SurvivingSpouse variant => false | Sections.FilingStatusVariant.HeadOfHousehold variant => false | Sections.FilingStatusVariant.Single variant => false | Sections.FilingStatusVariant.MarriedFilingSeparate variant => false)) || (decide (is_surviving_spouse)))) then some ((CatalaRuntime.Money.ofCents 2400000)) else none] with | none => if ((decide ((Sections.is_tax_year_2018_through_2025 (individual_tax_return).tax_year))) && (decide (is_head_of_household))) then some ((CatalaRuntime.Money.ofCents 1800000)) else none | some r => some r)] with | none => if (Sections.is_tax_year_2018_through_2025 (individual_tax_return).tax_year) then some ((CatalaRuntime.Money.ofCents 1200000)) else none | some r => some r), (match processExceptions [if ((!(decide ((Sections.is_tax_year_2018_through_2025 (individual_tax_return).tax_year)))) && (((decide (((taxpayer_marital_status).main_output).is_married_for_tax_purposes)) && (match (individual_tax_return).details with | Sections.FilingStatusVariant.JointReturn variant => true | Sections.FilingStatusVariant.SurvivingSpouse variant => false | Sections.FilingStatusVariant.HeadOfHousehold variant => false | Sections.FilingStatusVariant.Single variant => false | Sections.FilingStatusVariant.MarriedFilingSeparate variant => false)) || (decide (is_surviving_spouse)))) then some ((CatalaRuntime.Money.ofCents 600000)) else none] with | none => if ((!(decide ((Sections.is_tax_year_2018_through_2025 (individual_tax_return).tax_year)))) && (decide (is_head_of_household))) then some ((CatalaRuntime.Money.ofCents 440000)) else none | some r => some r)] with | none => some ((CatalaRuntime.Money.ofCents 300000)) | some r => some r) with | some r => r | _ => default)
  additional_standard_deduction : CatalaRuntime.Money := (((additional_amount_taxpayer_aged + additional_amount_spouse_aged) + additional_amount_taxpayer_blind) + additional_amount_spouse_blind)
  taxpayer_exemption : Sections.IndividualSection151Exemption := Sections.individualSection151Exemption { individual := (Sections.get_taxpayer individual_tax_return), individual_tax_return := individual_tax_return, tax_year := (individual_tax_return).tax_year, tax_return_events := tax_return_events, adjusted_gross_income := adjusted_gross_income, applicable_amount := applicable_amount, individuals_entitled_to_exemptions_under_151 := (taxpayer_exemptions_list_result).individuals_entitled_to_exemptions_under_151 }
  section_68_three_percent_reduction : CatalaRuntime.Money := ((fun (excess_agi : CatalaRuntime.Money) => (if (decide (excess_agi > (CatalaRuntime.Money.ofCents 0))) then (CatalaRuntime.multiply excess_agi (Rat.mk 3 100)) else (CatalaRuntime.Money.ofCents 0))) (adjusted_gross_income - applicable_amount))
  standard_deduction : CatalaRuntime.Money := (match (match processExceptions [if (!(decide (standard_deduction_eligible))) then some ((CatalaRuntime.Money.ofCents 0)) else none] with | none => some ((basic_standard_deduction + additional_standard_deduction)) | some r => some r) with | some r => r | _ => default)
  taxpayer_exemption_result : Sections.IndividualSection151ExemptionOutput := (taxpayer_exemption).main_output
  section_68_reduction_amount : CatalaRuntime.Money := (if (decide (adjusted_gross_income > applicable_amount)) then (Money_en.min section_68_three_percent_reduction section_68_eighty_percent_reduction) else (CatalaRuntime.Money.ofCents 0))
  itemized_deductions_after_68 : CatalaRuntime.Money := (match (match processExceptions [if (Sections.is_tax_year_2018_through_2025 (individual_tax_return).tax_year) then some (itemized_deductions) else none] with | none => some ((itemized_deductions - section_68_reduction_amount)) | some r => some r) with | some r => r | _ => default)
  taxable_income : CatalaRuntime.Money := (match (match processExceptions [if ((fun (itemizes_deductions : Bool) => itemizes_deductions) (match (individual_tax_return).details with | Sections.FilingStatusVariant.JointReturn variant => (variant).itemization_election | Sections.FilingStatusVariant.SurvivingSpouse variant => (variant).itemization_election | Sections.FilingStatusVariant.HeadOfHousehold variant => (variant).itemization_election | Sections.FilingStatusVariant.Single variant => (variant).itemization_election | Sections.FilingStatusVariant.MarriedFilingSeparate variant => (variant).itemization_election)) then some (((fun (computed_taxable_income : CatalaRuntime.Money) => (if (decide (computed_taxable_income < (CatalaRuntime.Money.ofCents 0))) then (CatalaRuntime.Money.ofCents 0) else computed_taxable_income)) ((adjusted_gross_income - itemized_deductions_after_68) - (taxpayer_exemption_result).personal_exemptions_deduction))) else none] with | none => some (((fun (computed_taxable_income : CatalaRuntime.Money) => (if (decide (computed_taxable_income < (CatalaRuntime.Money.ofCents 0))) then (CatalaRuntime.Money.ofCents 0) else computed_taxable_income)) ((adjusted_gross_income - standard_deduction) - (taxpayer_exemption_result).personal_exemptions_deduction))) | some r => some r) with | some r => r | _ => default)
  tax : CatalaRuntime.Money := (match (match processExceptions [(match processExceptions [(match processExceptions [(match processExceptions [if is_head_of_household then some ((if (decide (taxable_income ≤ (CatalaRuntime.Money.ofCents 2960000))) then (CatalaRuntime.multiply taxable_income (Rat.mk 3 20)) else (if (decide (taxable_income ≤ (CatalaRuntime.Money.ofCents 7640000))) then ((CatalaRuntime.Money.ofCents 444000) + (CatalaRuntime.multiply (taxable_income - (CatalaRuntime.Money.ofCents 2960000)) (Rat.mk 7 25))) else (if (decide (taxable_income ≤ (CatalaRuntime.Money.ofCents 12750000))) then ((CatalaRuntime.Money.ofCents 1754400) + (CatalaRuntime.multiply (taxable_income - (CatalaRuntime.Money.ofCents 7640000)) (Rat.mk 31 100))) else (if (decide (taxable_income ≤ (CatalaRuntime.Money.ofCents 25000000))) then ((CatalaRuntime.Money.ofCents 3338500) + (CatalaRuntime.multiply (taxable_income - (CatalaRuntime.Money.ofCents 12750000)) (Rat.mk 9 25))) else ((CatalaRuntime.Money.ofCents 7748500) + (CatalaRuntime.multiply (taxable_income - (CatalaRuntime.Money.ofCents 25000000)) (Rat.mk 99 250)))))))) else none] with | none => if is_surviving_spouse then some ((if (decide (taxable_income ≤ (CatalaRuntime.Money.ofCents 3690000))) then (CatalaRuntime.multiply taxable_income (Rat.mk 3 20)) else (if (decide (taxable_income ≤ (CatalaRuntime.Money.ofCents 8915000))) then ((CatalaRuntime.Money.ofCents 553500) + (CatalaRuntime.multiply (taxable_income - (CatalaRuntime.Money.ofCents 3690000)) (Rat.mk 7 25))) else (if (decide (taxable_income ≤ (CatalaRuntime.Money.ofCents 14000000))) then ((CatalaRuntime.Money.ofCents 2016500) + (CatalaRuntime.multiply (taxable_income - (CatalaRuntime.Money.ofCents 8915000)) (Rat.mk 31 100))) else (if (decide (taxable_income ≤ (CatalaRuntime.Money.ofCents 25000000))) then ((CatalaRuntime.Money.ofCents 3592850) + (CatalaRuntime.multiply (taxable_income - (CatalaRuntime.Money.ofCents 14000000)) (Rat.mk 9 25))) else ((CatalaRuntime.Money.ofCents 7552850) + (CatalaRuntime.multiply (taxable_income - (CatalaRuntime.Money.ofCents 25000000)) (Rat.mk 99 250)))))))) else none | some r => some r)] with | none => if ((decide (((taxpayer_marital_status).main_output).is_married_for_tax_purposes)) && (match (individual_tax_return).details with | Sections.FilingStatusVariant.JointReturn variant => true | Sections.FilingStatusVariant.SurvivingSpouse variant => false | Sections.FilingStatusVariant.HeadOfHousehold variant => false | Sections.FilingStatusVariant.Single variant => false | Sections.FilingStatusVariant.MarriedFilingSeparate variant => false)) then some ((if (decide (taxable_income ≤ (CatalaRuntime.Money.ofCents 3690000))) then (CatalaRuntime.multiply taxable_income (Rat.mk 3 20)) else (if (decide (taxable_income ≤ (CatalaRuntime.Money.ofCents 8915000))) then ((CatalaRuntime.Money.ofCents 553500) + (CatalaRuntime.multiply (taxable_income - (CatalaRuntime.Money.ofCents 3690000)) (Rat.mk 7 25))) else (if (decide (taxable_income ≤ (CatalaRuntime.Money.ofCents 14000000))) then ((CatalaRuntime.Money.ofCents 2016500) + (CatalaRuntime.multiply (taxable_income - (CatalaRuntime.Money.ofCents 8915000)) (Rat.mk 31 100))) else (if (decide (taxable_income ≤ (CatalaRuntime.Money.ofCents 25000000))) then ((CatalaRuntime.Money.ofCents 3592850) + (CatalaRuntime.multiply (taxable_income - (CatalaRuntime.Money.ofCents 14000000)) (Rat.mk 9 25))) else ((CatalaRuntime.Money.ofCents 7552850) + (CatalaRuntime.multiply (taxable_income - (CatalaRuntime.Money.ofCents 25000000)) (Rat.mk 99 250)))))))) else none | some r => some r)] with | none => if ((decide (((taxpayer_marital_status).main_output).is_married_for_tax_purposes)) && (match (individual_tax_return).details with | Sections.FilingStatusVariant.JointReturn variant => false | Sections.FilingStatusVariant.SurvivingSpouse variant => false | Sections.FilingStatusVariant.HeadOfHousehold variant => false | Sections.FilingStatusVariant.Single variant => false | Sections.FilingStatusVariant.MarriedFilingSeparate variant => true)) then some ((if (decide (taxable_income ≤ (CatalaRuntime.Money.ofCents 1845000))) then (CatalaRuntime.multiply taxable_income (Rat.mk 3 20)) else (if (decide (taxable_income ≤ (CatalaRuntime.Money.ofCents 4457500))) then ((CatalaRuntime.Money.ofCents 276750) + (CatalaRuntime.multiply (taxable_income - (CatalaRuntime.Money.ofCents 1845000)) (Rat.mk 7 25))) else (if (decide (taxable_income ≤ (CatalaRuntime.Money.ofCents 7000000))) then ((CatalaRuntime.Money.ofCents 1008250) + (CatalaRuntime.multiply (taxable_income - (CatalaRuntime.Money.ofCents 4457500)) (Rat.mk 31 100))) else (if (decide (taxable_income ≤ (CatalaRuntime.Money.ofCents 12500000))) then ((CatalaRuntime.Money.ofCents 1796425) + (CatalaRuntime.multiply (taxable_income - (CatalaRuntime.Money.ofCents 7000000)) (Rat.mk 9 25))) else ((CatalaRuntime.Money.ofCents 3776425) + (CatalaRuntime.multiply (taxable_income - (CatalaRuntime.Money.ofCents 12500000)) (Rat.mk 99 250)))))))) else none | some r => some r)] with | none => some ((if (decide (taxable_income ≤ (CatalaRuntime.Money.ofCents 2210000))) then (CatalaRuntime.multiply taxable_income (Rat.mk 3 20)) else (if (decide (taxable_income ≤ (CatalaRuntime.Money.ofCents 5350000))) then ((CatalaRuntime.Money.ofCents 331500) + (CatalaRuntime.multiply (taxable_income - (CatalaRuntime.Money.ofCents 2210000)) (Rat.mk 7 25))) else (if (decide (taxable_income ≤ (CatalaRuntime.Money.ofCents 11500000))) then ((CatalaRuntime.Money.ofCents 1210700) + (CatalaRuntime.multiply (taxable_income - (CatalaRuntime.Money.ofCents 5350000)) (Rat.mk 31 100))) else (if (decide (taxable_income ≤ (CatalaRuntime.Money.ofCents 25000000))) then ((CatalaRuntime.Money.ofCents 3117200) + (CatalaRuntime.multiply (taxable_income - (CatalaRuntime.Money.ofCents 11500000)) (Rat.mk 9 25))) else ((CatalaRuntime.Money.ofCents 7977200) + (CatalaRuntime.multiply (taxable_income - (CatalaRuntime.Money.ofCents 25000000)) (Rat.mk 99 250)))))))) | some r => some r) with | some r => r | _ => default)

def Sections.IRCSimplified_adjusted_gross_income (input : Sections.IRCSimplified_Input) : Option CatalaRuntime.Money :=
  some input.adjusted_gross_income

structure Sections.IRCSimplified where
  itemized_deductions : CatalaRuntime.Money
  adjusted_gross_income : CatalaRuntime.Money
  section_2_a_1_A_spouse_died_in_preceding_two_years : Bool
  section_2_a_2_B_joint_return_could_have_been_made : Bool
  section_2_a_2_A_taxpayer_has_remarried : Bool
  section_2_b_1_A_i_I_qualifying_child_is_married_at_close_of_year : Bool
  section_2_b_2_is_married_at_close_of_year : Bool
  wage_payment_wages_results : (List Sections.WagePaymentEventSection3306WagesOutput)
  employment_relationship_employment_results : (List Sections.EmploymentRelationshipEventSection3306EmploymentOutput)
  organization_employer_statuses : (List Sections.OrganizationSection3306EmployerStatusOutput)
  section_68_eighty_percent_reduction : CatalaRuntime.Money
  taxpayer_dependents_result : Sections.IndividualSection152DependentsOutput
  section_2_b_1_A_i_II_qualifying_person_not_dependent_by_152b2 : Bool
  employer_unemployment_excise_tax_result : Sections.EmployerUnemploymentExciseTaxFilerSection3301TaxOutput
  taxpayer_exemptions_list_result : Sections.TaxpayerExemptionsListOutput
  section_2_b_1_A_i_satisfied : Bool
  additional_amount_spouse_blind : CatalaRuntime.Money
  additional_amount_spouse_aged : CatalaRuntime.Money
  section_2_b_1_B_satisfied : Bool
  section_2_b_1_A_ii_satisfied : Bool
  section_2_a_1_B_satisfied : Bool
  individual_marital_statuses : (List Sections.IndividualSection7703MaritalStatusOutput)
  standard_deduction_eligible : Bool
  section_2_b_1_A_satisfied : Bool
  is_surviving_spouse : Bool
  is_head_of_household : Bool
  additional_amount_taxpayer_blind : CatalaRuntime.Money
  additional_amount_taxpayer_aged : CatalaRuntime.Money
  applicable_amount : CatalaRuntime.Money
  basic_standard_deduction : CatalaRuntime.Money
  additional_standard_deduction : CatalaRuntime.Money
  section_68_three_percent_reduction : CatalaRuntime.Money
  standard_deduction : CatalaRuntime.Money
  taxpayer_exemption_result : Sections.IndividualSection151ExemptionOutput
  section_68_reduction_amount : CatalaRuntime.Money
  itemized_deductions_after_68 : CatalaRuntime.Money
  taxable_income : CatalaRuntime.Money
  tax : CatalaRuntime.Money
deriving DecidableEq, Inhabited
def Sections.iRCSimplified (input : Sections.IRCSimplified_Input) : Sections.IRCSimplified :=
  let taxpayer_dependents := Sections.individualSection152Dependents { taxpayer := (Sections.get_taxpayer input.individual_tax_return), tax_year := (input.individual_tax_return).tax_year, individuals := input.individuals, family_relationship_events := input.family_relationship_events, birth_events := input.birth_events, residence_period_events := input.residence_period_events, tax_return_events := input.tax_return_events, income_events := input.income_events, marriage_events := input.marriage_events }
  let employer_unemployment_excise_tax := Sections.employerUnemploymentExciseTaxFilerSection3301Tax { employer_unemployment_excise_tax_return := input.employer_unemployment_excise_tax_return, wage_payment_wages_results := input.wage_payment_wages_results, organization_employer_statuses := input.organization_employer_statuses, employment_relationship_employment_results := input.employment_relationship_employment_results }
  let taxpayer_exemptions_list := Sections.taxpayerExemptionsList { individual_tax_return := input.individual_tax_return, tax_return_events := input.tax_return_events, income_events := input.income_events, dependents := (input.taxpayer_dependents_result).dependents_after_152b2 }
  let taxpayer_marital_status := Sections.individualSection7703MaritalStatus { individual := (match (input.individual_tax_return).details with | Sections.FilingStatusVariant.JointReturn variant => (variant).taxpayer | Sections.FilingStatusVariant.SurvivingSpouse variant => (variant).taxpayer | Sections.FilingStatusVariant.HeadOfHousehold variant => (variant).taxpayer | Sections.FilingStatusVariant.Single variant => (variant).taxpayer | Sections.FilingStatusVariant.MarriedFilingSeparate variant => (variant).taxpayer), tax_year := (input.individual_tax_return).tax_year, marriage_events := input.marriage_events, divorce_or_legal_separation_events := input.divorce_or_legal_separation_events, death_events := input.death_events, individual_tax_return := input.individual_tax_return, residence_period_events := input.residence_period_events, household_maintenance_events := input.household_maintenance_events, qualifying_children := (input.taxpayer_dependents_result).qualifying_children, individuals_entitled_to_exemptions_under_151 := (input.taxpayer_exemptions_list_result).individuals_entitled_to_exemptions_under_151 }
  let taxpayer_exemption := Sections.individualSection151Exemption { individual := (Sections.get_taxpayer input.individual_tax_return), individual_tax_return := input.individual_tax_return, tax_year := (input.individual_tax_return).tax_year, tax_return_events := input.tax_return_events, adjusted_gross_income := input.adjusted_gross_income, applicable_amount := input.applicable_amount, individuals_entitled_to_exemptions_under_151 := (input.taxpayer_exemptions_list_result).individuals_entitled_to_exemptions_under_151 }
  { itemized_deductions := input.itemized_deductions,
    adjusted_gross_income := input.adjusted_gross_income,
    section_2_a_1_A_spouse_died_in_preceding_two_years := input.section_2_a_1_A_spouse_died_in_preceding_two_years,
    section_2_a_2_B_joint_return_could_have_been_made := input.section_2_a_2_B_joint_return_could_have_been_made,
    section_2_a_2_A_taxpayer_has_remarried := input.section_2_a_2_A_taxpayer_has_remarried,
    section_2_b_1_A_i_I_qualifying_child_is_married_at_close_of_year := input.section_2_b_1_A_i_I_qualifying_child_is_married_at_close_of_year,
    section_2_b_2_is_married_at_close_of_year := input.section_2_b_2_is_married_at_close_of_year,
    wage_payment_wages_results := input.wage_payment_wages_results,
    employment_relationship_employment_results := input.employment_relationship_employment_results,
    organization_employer_statuses := input.organization_employer_statuses,
    section_68_eighty_percent_reduction := input.section_68_eighty_percent_reduction,
    taxpayer_dependents_result := input.taxpayer_dependents_result,
    section_2_b_1_A_i_II_qualifying_person_not_dependent_by_152b2 := input.section_2_b_1_A_i_II_qualifying_person_not_dependent_by_152b2,
    employer_unemployment_excise_tax_result := input.employer_unemployment_excise_tax_result,
    taxpayer_exemptions_list_result := input.taxpayer_exemptions_list_result,
    section_2_b_1_A_i_satisfied := input.section_2_b_1_A_i_satisfied,
    additional_amount_spouse_blind := input.additional_amount_spouse_blind,
    additional_amount_spouse_aged := input.additional_amount_spouse_aged,
    section_2_b_1_B_satisfied := input.section_2_b_1_B_satisfied,
    section_2_b_1_A_ii_satisfied := input.section_2_b_1_A_ii_satisfied,
    section_2_a_1_B_satisfied := input.section_2_a_1_B_satisfied,
    individual_marital_statuses := input.individual_marital_statuses,
    standard_deduction_eligible := input.standard_deduction_eligible,
    section_2_b_1_A_satisfied := input.section_2_b_1_A_satisfied,
    is_surviving_spouse := input.is_surviving_spouse,
    is_head_of_household := input.is_head_of_household,
    additional_amount_taxpayer_blind := input.additional_amount_taxpayer_blind,
    additional_amount_taxpayer_aged := input.additional_amount_taxpayer_aged,
    applicable_amount := input.applicable_amount,
    basic_standard_deduction := input.basic_standard_deduction,
    additional_standard_deduction := input.additional_standard_deduction,
    section_68_three_percent_reduction := input.section_68_three_percent_reduction,
    standard_deduction := input.standard_deduction,
    taxpayer_exemption_result := input.taxpayer_exemption_result,
    section_68_reduction_amount := input.section_68_reduction_amount,
    itemized_deductions_after_68 := input.itemized_deductions_after_68,
    taxable_income := input.taxable_income,
    tax := input.tax }

structure TestTaxCase2_Input where


def TestTaxCase2_computation_leaf_0  : Option Sections.IRCSimplified :=
  some (((fun (alice : Sections.Individual) => ((fun (bob : Sections.Individual) => ((fun (charlie : Sections.Individual) => ((fun (charlie_birth : Sections.BirthEvent) => ((fun (marriage : Sections.MarriageEvent) => ((fun (alice_death : Sections.DeathEvent) => ((fun (alice_parenthood : Sections.ParenthoodEvent) => ((fun (bob_parenthood : Sections.ParenthoodEvent) => ((fun (household : Sections.Household) => ((fun (bob_household_maintenance : Sections.HouseholdMaintenanceEvent) => ((fun (bob_residence : Sections.ResidencePeriodEvent) => ((fun (charlie_residence : Sections.ResidencePeriodEvent) => ((fun (alice_family_relationship : Sections.FamilyRelationshipEvent) => ((fun (bob_family_relationship : Sections.FamilyRelationshipEvent) => ((fun (charlie_family_relationship_alice : Sections.FamilyRelationshipEvent) => ((fun (charlie_family_relationship_bob : Sections.FamilyRelationshipEvent) => ((fun (alice_income : Sections.IncomeEvent) => ((fun (bob_income : Sections.IncomeEvent) => ((fun (tax_return_event : Sections.TaxReturnEvent) => ((fun (joint_return_variant : Sections.JointReturnVariant) => ((fun (individual_tax_return : Sections.IndividualTaxReturn) => ((fun (dummy_org : Sections.Organization) => ((fun (employer_general_variant : Sections.EmployerGeneralVariant) => ((fun (employer_tax_return : Sections.EmployerUnemploymentExciseTaxReturn) => ((fun (income_events_list : (List Sections.IncomeEvent)) => ((fun (adjusted_gross_income : CatalaRuntime.Money) => (Sections.iRCSimplified ({ adjusted_gross_income := adjusted_gross_income, employer_unemployment_excise_tax_return := employer_tax_return, employment_termination_events := [], immigration_admission_events := [], hospital_patient_events := [], student_enrollment_events := [], wage_payment_events := [], employment_relationship_events := [], income_events := income_events_list, tax_return_events := [tax_return_event], family_relationship_events := ((([alice_family_relationship] ++ [bob_family_relationship]) ++ [charlie_family_relationship_alice]) ++ [charlie_family_relationship_bob]), parenthood_events := ([alice_parenthood] ++ [bob_parenthood]), household_maintenance_events := [bob_household_maintenance], residence_period_events := ([bob_residence] ++ [charlie_residence]), divorce_or_legal_separation_events := [], remarriage_events := [], marriage_events := [marriage], nonresident_alien_status_period_events := [], death_events := [alice_death], blindness_status_events := [], birth_events := [charlie_birth], organizations := [dummy_org], individuals := (([alice] ++ [bob]) ++ [charlie]), individual_tax_return := individual_tax_return } : Sections.IRCSimplified_Input))) (CatalaRuntime.Money.ofCents 12180000))) ([alice_income] ++ [bob_income]))) ({ id := (0 : Int), tax_year := (2013 : Int), details := (Sections.EmployerVariant.GeneralEmployer employer_general_variant) } : Sections.EmployerUnemploymentExciseTaxReturn))) ({ employer := dummy_org } : Sections.EmployerGeneralVariant))) ({ id := (0 : Int), organization_type := (Sections.OrganizationType.Business ()), is_counterfactual := false } : Sections.Organization))) ({ id := (1 : Int), tax_year := (2013 : Int), details := (Sections.FilingStatusVariant.JointReturn joint_return_variant) } : Sections.IndividualTaxReturn))) ({ taxpayer := alice, spouse := bob, itemization_election := false, is_estate_or_trust := false, is_common_trust_fund := false, is_partnership := false } : Sections.JointReturnVariant))) ({ id := (1 : Int), individual := alice, tax_year := (2013 : Int), filed_joint_return := true, is_only_for_refund_claim := false, qualifying_children := [charlie], dependents := [], is_counterfactual := false } : Sections.TaxReturnEvent))) ({ id := (2 : Int), individual := bob, tax_year := (2013 : Int), has_income := true, earned_income := (CatalaRuntime.Money.ofCents 5640000), is_counterfactual := false } : Sections.IncomeEvent))) ({ id := (1 : Int), individual := alice, tax_year := (2013 : Int), has_income := true, earned_income := (CatalaRuntime.Money.ofCents 6540000), is_counterfactual := false } : Sections.IncomeEvent))) ({ id := (4 : Int), person := charlie, relative := bob, start_date := (Date_en.of_year_month_day (2000 : Int) (10 : Int) (9 : Int)), relationship_type := (Sections.FamilyRelationshipType.Father ()), is_counterfactual := false } : Sections.FamilyRelationshipEvent))) ({ id := (3 : Int), person := charlie, relative := alice, start_date := (Date_en.of_year_month_day (2000 : Int) (10 : Int) (9 : Int)), relationship_type := (Sections.FamilyRelationshipType.Mother ()), is_counterfactual := false } : Sections.FamilyRelationshipEvent))) ({ id := (2 : Int), person := bob, relative := charlie, start_date := (Date_en.of_year_month_day (2000 : Int) (10 : Int) (9 : Int)), relationship_type := (Sections.FamilyRelationshipType.Child ()), is_counterfactual := false } : Sections.FamilyRelationshipEvent))) ({ id := (1 : Int), person := alice, relative := charlie, start_date := (Date_en.of_year_month_day (2000 : Int) (10 : Int) (9 : Int)), relationship_type := (Sections.FamilyRelationshipType.Child ()), is_counterfactual := false } : Sections.FamilyRelationshipEvent))) ({ id := (2 : Int), individual := charlie, household := household, start_date := (Date_en.of_year_month_day (2013 : Int) (1 : Int) (1 : Int)), end_date := (Date_en.of_year_month_day (2013 : Int) (12 : Int) (31 : Int)), is_member_of_household := true, is_principal_place_of_abode := true, is_counterfactual := false } : Sections.ResidencePeriodEvent))) ({ id := (1 : Int), individual := bob, household := household, start_date := (Date_en.of_year_month_day (2013 : Int) (1 : Int) (1 : Int)), end_date := (Date_en.of_year_month_day (2013 : Int) (12 : Int) (31 : Int)), is_member_of_household := true, is_principal_place_of_abode := true, is_counterfactual := false } : Sections.ResidencePeriodEvent))) ({ id := (1 : Int), individual := bob, household := household, start_date := (Date_en.of_year_month_day (2013 : Int) (1 : Int) (1 : Int)), end_date := (Date_en.of_year_month_day (2013 : Int) (12 : Int) (31 : Int)), cost_furnished_percentage := (Rat.mk 2 5), is_counterfactual := false } : Sections.HouseholdMaintenanceEvent))) ({ id := (1 : Int), is_counterfactual := false } : Sections.Household))) ({ id := (2 : Int), parent := bob, child := charlie, start_date := (Date_en.of_year_month_day (2000 : Int) (10 : Int) (9 : Int)), parent_type := (Sections.ParentType.Biological ()), is_counterfactual := false } : Sections.ParenthoodEvent))) ({ id := (1 : Int), parent := alice, child := charlie, start_date := (Date_en.of_year_month_day (2000 : Int) (10 : Int) (9 : Int)), parent_type := (Sections.ParentType.Biological ()), is_counterfactual := false } : Sections.ParenthoodEvent))) ({ id := (1 : Int), decedent := alice, death_date := (Date_en.of_year_month_day (2014 : Int) (7 : Int) (9 : Int)), is_counterfactual := false } : Sections.DeathEvent))) ({ id := (1 : Int), spouse1 := alice, spouse2 := bob, marriage_date := (Date_en.of_year_month_day (1992 : Int) (2 : Int) (3 : Int)), is_counterfactual := false } : Sections.MarriageEvent))) ({ id := (3 : Int), individual := charlie, birth_date := (Date_en.of_year_month_day (2000 : Int) (10 : Int) (9 : Int)), is_counterfactual := false } : Sections.BirthEvent))) ({ id := (3 : Int), is_counterfactual := false } : Sections.Individual))) ({ id := (2 : Int), is_counterfactual := false } : Sections.Individual))) ({ id := (1 : Int), is_counterfactual := false } : Sections.Individual)))

structure TestTaxCase2 where
  computation : Sections.IRCSimplified
deriving DecidableEq, Inhabited
def testTaxCase2 (input : TestTaxCase2_Input) : TestTaxCase2 :=
  let computation := match TestTaxCase2_computation_leaf_0  with | some val => val | _ => default 
  { computation := computation }
