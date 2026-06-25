import CatalaRuntime

import Stdlib

open CatalaRuntime

inductive Date_en.Day_of_week : Type where
 | Monday : Unit -> Date_en.Day_of_week
 | Tuesday : Unit -> Date_en.Day_of_week
 | Wednesday : Unit -> Date_en.Day_of_week
 | Thursday : Unit -> Date_en.Day_of_week
 | Friday : Unit -> Date_en.Day_of_week
 | Saturday : Unit -> Date_en.Day_of_week
 | Sunday : Unit -> Date_en.Day_of_week
deriving Repr, DecidableEq, Inhabited

inductive FilingStatus : Type where
 | JointReturn : Unit -> FilingStatus
 | SurvivingSpouse : Unit -> FilingStatus
 | HeadOfHousehold : Unit -> FilingStatus
 | Single : Unit -> FilingStatus
 | MarriedFilingSeparately : Unit -> FilingStatus
deriving Repr, DecidableEq, Inhabited

inductive ResidencyStatus : Type where
 | Resident : Unit -> ResidencyStatus
 | NonresidentAlien : Unit -> ResidencyStatus
deriving Repr, DecidableEq, Inhabited

inductive DecreeType : Type where
 | Divorce : Unit -> DecreeType
 | SeparateMaintenance : Unit -> DecreeType
deriving Repr, DecidableEq, Inhabited

inductive ParentType : Type where
 | Biological : Unit -> ParentType
 | Step : Unit -> ParentType
 | Adoptive : Unit -> ParentType
deriving Repr, DecidableEq, Inhabited

inductive FamilyRelationshipType : Type where
 | Child : Unit -> FamilyRelationshipType
 | DescendantOfChild : Unit -> FamilyRelationshipType
 | Brother : Unit -> FamilyRelationshipType
 | Sister : Unit -> FamilyRelationshipType
 | Stepbrother : Unit -> FamilyRelationshipType
 | Stepsister : Unit -> FamilyRelationshipType
 | DescendantOfSibling : Unit -> FamilyRelationshipType
 | Father : Unit -> FamilyRelationshipType
 | Mother : Unit -> FamilyRelationshipType
 | AncestorOfFatherOrMother : Unit -> FamilyRelationshipType
 | Stepfather : Unit -> FamilyRelationshipType
 | Stepmother : Unit -> FamilyRelationshipType
 | NieceOrNephew : Unit -> FamilyRelationshipType
 | UncleOrAunt : Unit -> FamilyRelationshipType
 | SonInLaw : Unit -> FamilyRelationshipType
 | DaughterInLaw : Unit -> FamilyRelationshipType
 | FatherInLaw : Unit -> FamilyRelationshipType
 | MotherInLaw : Unit -> FamilyRelationshipType
 | BrotherInLaw : Unit -> FamilyRelationshipType
 | SisterInLaw : Unit -> FamilyRelationshipType
deriving Repr, DecidableEq, Inhabited

inductive OrganizationType : Type where
 | Business : Unit -> OrganizationType
 | GovernmentFederal : Unit -> OrganizationType
 | GovernmentState : Unit -> OrganizationType
 | EducationalInstitution : Unit -> OrganizationType
 | Hospital : Unit -> OrganizationType
 | Club : Unit -> OrganizationType
 | FraternityOrSorority : Unit -> OrganizationType
 | ForeignGovernment : Unit -> OrganizationType
 | InternationalOrganization : Unit -> OrganizationType
 | PenalInstitution : Unit -> OrganizationType
deriving Repr, DecidableEq, Inhabited

inductive EmploymentCategory : Type where
 | General : Unit -> EmploymentCategory
 | AgriculturalLabor : Unit -> EmploymentCategory
 | DomesticService : Unit -> EmploymentCategory
 | FederalGovernment : Unit -> EmploymentCategory
 | StateGovernment : Unit -> EmploymentCategory
 | SchoolCollegeUniversity : Unit -> EmploymentCategory
 | Hospital : Unit -> EmploymentCategory
 | ForeignGovernment : Unit -> EmploymentCategory
 | InternationalOrganization : Unit -> EmploymentCategory
 | PenalInstitution : Unit -> EmploymentCategory
deriving Repr, DecidableEq, Inhabited

inductive ServiceLocation : Type where
 | WithinUnitedStates : Unit -> ServiceLocation
 | OutsideUnitedStates : Unit -> ServiceLocation
deriving Repr, DecidableEq, Inhabited

inductive PaymentMedium : Type where
 | Cash : Unit -> PaymentMedium
 | NonCash : Unit -> PaymentMedium
deriving Repr, DecidableEq, Inhabited

inductive PaymentReason : Type where
 | RegularCompensation : Unit -> PaymentReason
 | SicknessOrAccidentDisability : Unit -> PaymentReason
 | Death : Unit -> PaymentReason
 | TerminationAfterDeathOrDisabilityRetirement : Unit -> PaymentReason
 | AgriculturalLaborNonCash : Unit -> PaymentReason
 | DomesticServiceNonBusiness : Unit -> PaymentReason
deriving Repr, DecidableEq, Inhabited

inductive VisaCategory : Type where
 | H2A : Unit -> VisaCategory
 | Other : Unit -> VisaCategory
deriving Repr, DecidableEq, Inhabited

inductive TerminationReason : Type where
 | Death : Unit -> TerminationReason
 | DisabilityRetirement : Unit -> TerminationReason
 | Other : Unit -> TerminationReason
deriving Repr, DecidableEq, Inhabited

structure Individual where
  id : Int
  is_counterfactual : Bool
deriving Repr, DecidableEq, Inhabited

structure Household where
  id : Int
  is_counterfactual : Bool
deriving Repr, DecidableEq, Inhabited

structure Organization where
  id : Int
  organization_type : OrganizationType
  is_counterfactual : Bool
deriving Repr, DecidableEq, Inhabited

structure ImmigrationAdmissionEvent where
  id : Int
  individual : Individual
  visa_category : VisaCategory
  admission_date : CatalaRuntime.Date
  is_counterfactual : Bool
deriving Repr, DecidableEq, Inhabited

structure IndividualSection152QualifyingRelativeOutput where
  individual : Individual
  taxpayer : Individual
  is_qualifying_relative : Bool
  relationship_requirement_met_H : Bool
  relationship_requirement_met : Bool
  no_income_requirement_met : Bool
  not_qualifying_child_requirement_met : Bool
deriving Repr, DecidableEq, Inhabited

structure IndividualSection152QualifyingChildOutput where
  individual : Individual
  taxpayer : Individual
  is_qualifying_child : Bool
  relationship_requirement_met : Bool
  principal_place_of_abode_requirement_met : Bool
  age_requirement_met : Bool
  joint_return_exception_applies : Bool
deriving Repr, DecidableEq, Inhabited

structure IndividualSection151ExemptionOutput where
  individual : Individual
  exemption_amount_base : CatalaRuntime.Money
  exemption_amount_after_disallowance : CatalaRuntime.Money
  exemption_amount_after_phaseout : CatalaRuntime.Money
  number_of_personal_exemptions : Int
  personal_exemptions_deduction : CatalaRuntime.Money
  applicable_percentage : Rat
deriving Repr, DecidableEq, Inhabited

structure IndividualSection151ExemptionsListOutput where
  individual : Individual
  spouse_personal_exemption_allowed : Bool
  individuals_entitled_to_exemptions_under_151 : (List Individual)
deriving Repr, DecidableEq, Inhabited

structure TaxReturnEvent where
  id : Int
  individual : Individual
  tax_year : Int
  filed_joint_return : Bool
  is_only_for_refund_claim : Bool
  qualifying_children : (List Individual)
  dependents : (List Individual)
  is_counterfactual : Bool
deriving Repr, DecidableEq, Inhabited

structure IncomeEvent where
  id : Int
  individual : Individual
  tax_year : Int
  has_income : Bool
  earned_income : CatalaRuntime.Money
  is_counterfactual : Bool
deriving Repr, DecidableEq, Inhabited

structure FamilyRelationshipEvent where
  id : Int
  person : Individual
  relative : Individual
  start_date : CatalaRuntime.Date
  relationship_type : FamilyRelationshipType
  is_counterfactual : Bool
deriving Repr, DecidableEq, Inhabited

structure ParenthoodEvent where
  id : Int
  parent : Individual
  child : Individual
  start_date : CatalaRuntime.Date
  parent_type : ParentType
  is_counterfactual : Bool
deriving Repr, DecidableEq, Inhabited

structure DivorceOrLegalSeparationEvent where
  id : Int
  person1 : Individual
  person2 : Individual
  decree_date : CatalaRuntime.Date
  decree_type : DecreeType
  is_counterfactual : Bool
deriving Repr, DecidableEq, Inhabited

structure RemarriageEvent where
  id : Int
  individual : Individual
  remarriage_date : CatalaRuntime.Date
  is_counterfactual : Bool
deriving Repr, DecidableEq, Inhabited

structure MarriageEvent where
  id : Int
  spouse1 : Individual
  spouse2 : Individual
  marriage_date : CatalaRuntime.Date
  is_counterfactual : Bool
deriving Repr, DecidableEq, Inhabited

structure MarriedFilingSeparateVariant where
  taxpayer : Individual
  spouse : Individual
  itemization_election : Bool
  spouse_itemization_election : Bool
  is_estate_or_trust : Bool
  is_common_trust_fund : Bool
  is_partnership : Bool
deriving Repr, DecidableEq, Inhabited

structure SingleVariant where
  taxpayer : Individual
  itemization_election : Bool
  is_estate_or_trust : Bool
  is_common_trust_fund : Bool
  is_partnership : Bool
deriving Repr, DecidableEq, Inhabited

structure HeadOfHouseholdVariant where
  taxpayer : Individual
  qualifying_person : Individual
  itemization_election : Bool
  is_estate_or_trust : Bool
  is_common_trust_fund : Bool
  is_partnership : Bool
deriving Repr, DecidableEq, Inhabited

structure SurvivingSpouseVariant where
  taxpayer : Individual
  deceased_spouse : Individual
  qualifying_dependent : Individual
  itemization_election : Bool
  is_estate_or_trust : Bool
  is_common_trust_fund : Bool
  is_partnership : Bool
deriving Repr, DecidableEq, Inhabited

structure JointReturnVariant where
  taxpayer : Individual
  spouse : Individual
  itemization_election : Bool
  is_estate_or_trust : Bool
  is_common_trust_fund : Bool
  is_partnership : Bool
deriving Repr, DecidableEq, Inhabited

structure NonresidentAlienStatusPeriodEvent where
  id : Int
  individual : Individual
  start_date : CatalaRuntime.Date
  end_date : CatalaRuntime.Date
  residency_status : ResidencyStatus
  is_counterfactual : Bool
deriving Repr, DecidableEq, Inhabited

structure DeathEvent where
  id : Int
  decedent : Individual
  death_date : CatalaRuntime.Date
  is_counterfactual : Bool
deriving Repr, DecidableEq, Inhabited

structure BlindnessStatusEvent where
  id : Int
  individual : Individual
  status_date : CatalaRuntime.Date
  is_blind : Bool
  is_counterfactual : Bool
deriving Repr, DecidableEq, Inhabited

structure BirthEvent where
  id : Int
  individual : Individual
  birth_date : CatalaRuntime.Date
  is_counterfactual : Bool
deriving Repr, DecidableEq, Inhabited

structure IndividualSection7703MaritalStatusOutput where
  individual : Individual
  tax_year : Int
  determination_date : CatalaRuntime.Date
  is_married_at_determination_date : Bool
  is_legally_separated : Bool
  households_with_qualifying_child : (List Household)
  households_maintained_by_individual : (List Household)
  spouse_not_member_of_household_last_6_months : Bool
  subsection_b_exception_applies : Bool
  is_married_for_tax_purposes : Bool
deriving Repr, DecidableEq, Inhabited

structure HouseholdMaintenanceEvent where
  id : Int
  individual : Individual
  household : Household
  start_date : CatalaRuntime.Date
  end_date : CatalaRuntime.Date
  cost_furnished_percentage : Rat
  is_counterfactual : Bool
deriving Repr, DecidableEq, Inhabited

structure ResidencePeriodEvent where
  id : Int
  individual : Individual
  household : Household
  start_date : CatalaRuntime.Date
  end_date : CatalaRuntime.Date
  is_member_of_household : Bool
  is_principal_place_of_abode : Bool
  is_counterfactual : Bool
deriving Repr, DecidableEq, Inhabited

structure OrganizationSection3306EmployerStatusOutput where
  organization : Organization
  is_employer : Bool
  is_general_employer : Bool
  is_agricultural_employer : Bool
  is_domestic_service_employer : Bool
deriving Repr, DecidableEq, Inhabited

structure EmployerDomesticServiceVariant where
  employer : Organization
deriving Repr, DecidableEq, Inhabited

structure EmployerAgriculturalLaborVariant where
  employer : Organization
deriving Repr, DecidableEq, Inhabited

structure EmployerGeneralVariant where
  employer : Organization
deriving Repr, DecidableEq, Inhabited

structure EmploymentTerminationEvent where
  id : Int
  employer : Organization
  employee : Individual
  termination_date : CatalaRuntime.Date
  reason : TerminationReason
  is_counterfactual : Bool
deriving Repr, DecidableEq, Inhabited

structure HospitalPatientEvent where
  id : Int
  patient : Individual
  hospital : Organization
  start_date : CatalaRuntime.Date
  end_date : CatalaRuntime.Date
  is_counterfactual : Bool
deriving Repr, DecidableEq, Inhabited

structure StudentEnrollmentEvent where
  id : Int
  student : Individual
  institution : Organization
  start_date : CatalaRuntime.Date
  end_date : CatalaRuntime.Date
  is_regularly_attending : Bool
  is_counterfactual : Bool
deriving Repr, DecidableEq, Inhabited

structure WagePaymentEvent where
  id : Int
  employer : Organization
  employee : Individual
  payment_date : CatalaRuntime.Date
  amount : CatalaRuntime.Money
  payment_medium : PaymentMedium
  payment_reason : PaymentReason
  is_under_plan_or_system : Bool
  is_for_employee_generally : Bool
  is_for_class_of_employees : Bool
  is_for_dependents : Bool
  is_not_in_course_of_trade_or_business : Bool
  would_have_been_paid_without_termination : Bool
  is_paid_to_survivor_or_estate : Bool
  is_counterfactual : Bool
deriving Repr, DecidableEq, Inhabited

structure EmploymentRelationshipEvent where
  id : Int
  employer : Organization
  employee : Individual
  start_date : CatalaRuntime.Date
  end_date : CatalaRuntime.Date
  employment_category : EmploymentCategory
  service_location : ServiceLocation
  is_american_employer : Bool
  employee_is_us_citizen : Bool
  is_counterfactual : Bool
deriving Repr, DecidableEq, Inhabited

structure IndividualSection152DependentsOutput where
  taxpayer : Individual
  dependents_initial : (List Individual)
  dependents_after_152b1 : (List Individual)
  dependents_after_152b2 : (List Individual)
  qualifying_children : (List IndividualSection152QualifyingChildOutput)
  qualifying_relatives : (List IndividualSection152QualifyingRelativeOutput)
deriving Repr, DecidableEq, Inhabited

structure TaxpayerExemptionsListOutput where
  taxpayer_result : IndividualSection151ExemptionsListOutput
  spouse_result : (Optional IndividualSection151ExemptionsListOutput)
  individuals_entitled_to_exemptions_under_151 : (List Individual)
  spouse_personal_exemption_allowed : Bool
deriving Repr, DecidableEq, Inhabited

inductive FilingStatusVariant : Type where
 | JointReturn : JointReturnVariant -> FilingStatusVariant
 | SurvivingSpouse : SurvivingSpouseVariant -> FilingStatusVariant
 | HeadOfHousehold : HeadOfHouseholdVariant -> FilingStatusVariant
 | Single : SingleVariant -> FilingStatusVariant
 | MarriedFilingSeparate : MarriedFilingSeparateVariant -> FilingStatusVariant
deriving Repr, DecidableEq, Inhabited

inductive EmployerVariant : Type where
 | GeneralEmployer : EmployerGeneralVariant -> EmployerVariant
 | AgriculturalEmployer : EmployerAgriculturalLaborVariant -> EmployerVariant
 | DomesticServiceEmployer : EmployerDomesticServiceVariant -> EmployerVariant
deriving Repr, DecidableEq, Inhabited

structure WagePaymentEventSection3306WagesOutput where
  wage_payment_event : WagePaymentEvent
  is_excluded_by_sickness_disability_death : Bool
  is_excluded_by_nonbusiness_service : Bool
  is_excluded_by_termination_payment : Bool
  is_excluded_by_agricultural_noncash : Bool
  is_excluded_by_survivor_payment : Bool
  taxable_amount_before_7000_cap : CatalaRuntime.Money
deriving Repr, DecidableEq, Inhabited

structure EmploymentRelationshipEventSection3306EmploymentOutput where
  employment_relationship_event : EmploymentRelationshipEvent
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
deriving Repr, DecidableEq, Inhabited

structure IndividualTaxReturn where
  id : Int
  tax_year : Int
  details : FilingStatusVariant
deriving Repr, DecidableEq, Inhabited

structure EmployerUnemploymentExciseTaxReturn where
  id : Int
  tax_year : Int
  details : EmployerVariant
deriving Repr, DecidableEq, Inhabited

structure TotalWages3306CalculationOutput where
  total_taxable_wages : CatalaRuntime.Money
  wage_results_with_cap : (List WagePaymentEventSection3306WagesOutput)
deriving Repr, DecidableEq, Inhabited

structure EmployerUnemploymentExciseTaxFilerSection3301TaxOutput where
  employer_unemployment_excise_tax_return : EmployerUnemploymentExciseTaxReturn
  total_taxable_wages : CatalaRuntime.Money
  excise_tax : CatalaRuntime.Money
  tax_rate : Rat
deriving Repr, DecidableEq, Inhabited

def is_tax_year_2018_through_2025 := (fun (tax_year_arg : Int) => ((decide (tax_year_arg ≥ (2018 : Int))) && (decide (tax_year_arg ≤ (2025 : Int)))))

def section_2_spouse_death_events_in_window := (fun (spouse_arg : (Optional Individual)) (death_events_arg : (List DeathEvent)) (tax_year_arg : Int) => (match spouse_arg with | Optional.Absent _ => (List.filter ((fun (death_event : DeathEvent) => false)) death_events_arg)| Optional.Present s => (List.filter ((fun (death_event : DeathEvent) => ((decide ((death_event).decedent = s)) && ((decide ((Date_en.get_year (death_event).death_date) ≥ (tax_year_arg - (2 : Int)))) && (decide ((Date_en.get_year (death_event).death_date) < tax_year_arg)))))) death_events_arg)))

def section_2_spouse_death_year := (fun (spouse_death_events_in_window_arg : (List DeathEvent)) => (if (decide ((spouse_death_events_in_window_arg).length > (0 : Int))) then (Optional.Present (match (List.map ((fun (death_event : DeathEvent) => (Date_en.get_year (death_event).death_date))) spouse_death_events_in_window_arg) with | [] => (fun () => default /-unsupported expression-/) () | x0 :: xn => List.foldl (fun (max1 : Int) (max2 : Int) => (if (decide (max1 > max2)) then max1 else max2)) x0 xn)) else (Optional.Absent ())))

def section_2_most_recent_spouse_death_date := (fun (spouse_death_events_in_window_arg : (List DeathEvent)) (tax_year_arg : Int) => (if (decide ((spouse_death_events_in_window_arg).length > (0 : Int))) then (match (List.map ((fun (death_event : DeathEvent) => (death_event).death_date)) spouse_death_events_in_window_arg) with | [] => (fun () => default /-unsupported expression-/) () | x0 :: xn => List.foldl (fun (max1 : CatalaRuntime.Date) (max2 : CatalaRuntime.Date) => (if (decide (max1 > max2)) then max1 else max2)) x0 xn) else (Date_en.of_year_month_day tax_year_arg (1 : Int) (1 : Int))))

def individual_attained_age_65 := (fun (individual_arg : Individual) (birth_events_arg : (List BirthEvent)) (year_end_arg : CatalaRuntime.Date) => (List.foldl ((fun (acc : Bool) (birth_event : BirthEvent) => (decide (acc) || ((decide ((birth_event).individual = individual_arg)) && decide ((Date_en.is_old_enough_rounding_down (birth_event).birth_date (CatalaRuntime.Duration.create 65 0 0) year_end_arg)))))) false birth_events_arg))

def individual_is_blind_at_close := (fun (individual_arg : Individual) (blindness_status_events_arg : (List BlindnessStatusEvent)) (death_events_arg : (List DeathEvent)) (year_end_arg : CatalaRuntime.Date) => (List.foldl ((fun (acc : Bool) (blindness_event : BlindnessStatusEvent) => (decide (acc) || ((decide ((blindness_event).individual = individual_arg)) && ((decide ((blindness_event).status_date ≤ year_end_arg)) && (decide ((blindness_event).is_blind) && (!decide ((List.foldl ((fun (acc : Bool) (death_event : DeathEvent) => (decide (acc) || ((decide ((death_event).decedent = individual_arg)) && ((decide ((death_event).death_date < (blindness_event).status_date)) && (decide ((death_event).death_date ≤ year_end_arg))))))) false death_events_arg))))))))) false blindness_status_events_arg))

def get_year_end := (fun (tax_year_arg : Int) => (Date_en.of_year_month_day tax_year_arg (12 : Int) (31 : Int)))

def get_taxpayer := (fun (individual_tax_return_arg : IndividualTaxReturn) => (match (individual_tax_return_arg).details with | FilingStatusVariant.JointReturn variant => (variant).taxpayer| FilingStatusVariant.SurvivingSpouse variant => (variant).taxpayer| FilingStatusVariant.HeadOfHousehold variant => (variant).taxpayer| FilingStatusVariant.Single variant => (variant).taxpayer| FilingStatusVariant.MarriedFilingSeparate variant => (variant).taxpayer))

def get_spouse := (fun (individual_tax_return_arg : IndividualTaxReturn) => (match (individual_tax_return_arg).details with | FilingStatusVariant.JointReturn variant => (Optional.Present (variant).spouse)| FilingStatusVariant.SurvivingSpouse variant => (Optional.Present (variant).deceased_spouse)| FilingStatusVariant.HeadOfHousehold variant => (Optional.Absent ())| FilingStatusVariant.Single variant => (Optional.Absent ())| FilingStatusVariant.MarriedFilingSeparate variant => (Optional.Present (variant).spouse)))

def extract_spouse_itemization_election := (fun (individual_tax_return_arg : IndividualTaxReturn) => (match (individual_tax_return_arg).details with | FilingStatusVariant.JointReturn variant => false| FilingStatusVariant.SurvivingSpouse variant => false| FilingStatusVariant.HeadOfHousehold variant => false| FilingStatusVariant.Single variant => false| FilingStatusVariant.MarriedFilingSeparate variant => (variant).spouse_itemization_election))

def individual_is_nonresident_alien_during_year := (fun (individual_arg : Individual) (nonresident_alien_status_period_events_arg : (List NonresidentAlienStatusPeriodEvent)) (tax_year_arg : Int) (year_end_arg : CatalaRuntime.Date) => (List.foldl ((fun (acc : Bool) (residency_event : NonresidentAlienStatusPeriodEvent) => (decide (acc) || ((decide ((residency_event).individual = individual_arg)) && ((decide ((residency_event).start_date ≤ year_end_arg)) && ((decide ((residency_event).end_date ≥ (Date_en.of_year_month_day tax_year_arg (1 : Int) (1 : Int)))) && (decide ((residency_event).residency_status = (ResidencyStatus.NonresidentAlien ()))))))))) false nonresident_alien_status_period_events_arg))

structure IndividualSection151ExemptionsList_Input where
  is_joint_or_surviving_spouse : Bool
  dependents : (List Individual)
  income_events : (List IncomeEvent)
  tax_return_events : (List TaxReturnEvent)
  tax_year : Int
  spouse : (Optional Individual)
  individual : Individual
  spouse_personal_exemption_allowed : Bool := (if is_joint_or_surviving_spouse then false else (match spouse with | Optional.Absent _ => false| Optional.Present s => ((fun (spouse_has_no_income : Bool) => ((fun (spouse_is_not_dependent_of_another : Bool) => (decide (spouse_has_no_income) && decide (spouse_is_not_dependent_of_another))) (!decide ((List.foldl ((fun (acc : Bool) (event : TaxReturnEvent) => (decide (acc) || ((!(decide ((event).individual = individual))) && ((decide ((event).tax_year = tax_year)) && decide ((List.foldl ((fun (acc : Bool) (dependent : Individual) => (decide (acc) || (decide (dependent = s))))) false (event).dependents))))))) false tax_return_events))))) (!decide ((List.foldl ((fun (acc : Bool) (income_event : IncomeEvent) => (decide (acc) || ((decide ((income_event).individual = s)) && ((decide ((income_event).tax_year = tax_year)) && decide ((income_event).has_income)))))) false income_events))))))
  individuals_entitled_to_exemptions_under_151 : (List Individual) := ((fun (individual_list : (List Individual)) => ((fun (spouse_list : (List Individual)) => ((individual_list ++ spouse_list) ++ dependents)) (match spouse with | Optional.Absent _ => []| Optional.Present s => (if spouse_personal_exemption_allowed then [s] else [])))) [individual])

def IndividualSection151ExemptionsList_main_output_leaf_0 (input : IndividualSection151ExemptionsList_Input) : Option IndividualSection151ExemptionsListOutput :=
  some (({ individual := input.individual, spouse_personal_exemption_allowed := input.spouse_personal_exemption_allowed, individuals_entitled_to_exemptions_under_151 := input.individuals_entitled_to_exemptions_under_151 } : IndividualSection151ExemptionsListOutput))

structure IndividualSection151ExemptionsList where
  main_output : IndividualSection151ExemptionsListOutput
deriving Repr, DecidableEq, Inhabited
def individualSection151ExemptionsList (input : IndividualSection151ExemptionsList_Input) : IndividualSection151ExemptionsList :=
  let main_output := match IndividualSection151ExemptionsList_main_output_leaf_0 input with | some val => val | _ => default
  { main_output := main_output }

structure IndividualSection152QualifyingChild_Input where
  tax_return_events : (List TaxReturnEvent)
  residence_period_events : (List ResidencePeriodEvent)
  birth_events : (List BirthEvent)
  family_relationship_events : (List FamilyRelationshipEvent)
  tax_year : Int
  taxpayer : Individual
  individual : Individual
  relationship_requirement_met : Bool := (List.foldl ((fun (acc : Bool) (rel_event : FamilyRelationshipEvent) => (decide (acc) || ((decide ((rel_event).person = taxpayer)) && ((decide ((rel_event).relative = individual)) && ((decide ((rel_event).start_date ≤ (Date_en.of_year_month_day tax_year (12 : Int) (31 : Int)))) && ((decide ((rel_event).relationship_type = (FamilyRelationshipType.Child ()))) || ((decide ((rel_event).relationship_type = (FamilyRelationshipType.DescendantOfChild ()))) || ((decide ((rel_event).relationship_type = (FamilyRelationshipType.Brother ()))) || ((decide ((rel_event).relationship_type = (FamilyRelationshipType.Sister ()))) || ((decide ((rel_event).relationship_type = (FamilyRelationshipType.Stepbrother ()))) || ((decide ((rel_event).relationship_type = (FamilyRelationshipType.Stepsister ()))) || (decide ((rel_event).relationship_type = (FamilyRelationshipType.DescendantOfSibling ()))))))))))))))) false family_relationship_events)
  age_requirement_met : Bool := ((fun (year_end : CatalaRuntime.Date) => ((fun (individual_birth_date : CatalaRuntime.Date) => ((fun (taxpayer_birth_date : CatalaRuntime.Date) => ((decide (individual_birth_date > taxpayer_birth_date)) && decide ((Date_en.is_young_enough_rounding_down individual_birth_date (CatalaRuntime.Duration.create 25 0 0) year_end)))) (if (List.foldl ((fun (acc : Bool) (birth_event : BirthEvent) => (decide (acc) || (decide ((birth_event).individual = taxpayer))))) false birth_events) then (match (List.map ((fun (birth_event : BirthEvent) => (birth_event).birth_date)) (List.filter ((fun (birth_event : BirthEvent) => (decide ((birth_event).individual = taxpayer)))) birth_events)) with | [] => (fun () => default /-unsupported expression-/) () | x0 :: xn => List.foldl (fun (min1 : CatalaRuntime.Date) (min2 : CatalaRuntime.Date) => (if (decide (min1 < min2)) then min1 else min2)) x0 xn) else (Date_en.of_year_month_day (1900 : Int) (1 : Int) (1 : Int))))) (if (List.foldl ((fun (acc : Bool) (birth_event : BirthEvent) => (decide (acc) || (decide ((birth_event).individual = individual))))) false birth_events) then (match (List.map ((fun (birth_event : BirthEvent) => (birth_event).birth_date)) (List.filter ((fun (birth_event : BirthEvent) => (decide ((birth_event).individual = individual)))) birth_events)) with | [] => (fun () => default /-unsupported expression-/) () | x0 :: xn => List.foldl (fun (min1 : CatalaRuntime.Date) (min2 : CatalaRuntime.Date) => (if (decide (min1 < min2)) then min1 else min2)) x0 xn) else (Date_en.of_year_month_day (1900 : Int) (1 : Int) (1 : Int))))) (Date_en.of_year_month_day tax_year (12 : Int) (31 : Int)))
  principal_place_of_abode_requirement_met : Bool := ((fun (year_start : CatalaRuntime.Date) => ((fun (year_end : CatalaRuntime.Date) => ((fun (year_midpoint : CatalaRuntime.Date) => (List.foldl ((fun (acc : Bool) (taxpayer_residence : ResidencePeriodEvent) => (decide (acc) || ((decide ((taxpayer_residence).individual = taxpayer)) && (decide ((taxpayer_residence).is_principal_place_of_abode) && ((decide ((taxpayer_residence).start_date ≤ year_end)) && ((decide ((taxpayer_residence).end_date ≥ year_start)) && decide ((List.foldl ((fun (acc : Bool) (individual_residence : ResidencePeriodEvent) => (decide (acc) || ((decide ((individual_residence).individual = individual)) && ((decide ((individual_residence).household = (taxpayer_residence).household)) && (decide ((individual_residence).is_principal_place_of_abode) && ((decide ((individual_residence).start_date ≤ year_midpoint)) && ((decide ((individual_residence).end_date ≥ (Date_en.of_year_month_day tax_year (7 : Int) (1 : Int)))) && ((decide ((individual_residence).start_date ≤ year_end)) && (decide ((individual_residence).end_date ≥ year_start))))))))))) false residence_period_events))))))))) false residence_period_events)) (Date_en.of_year_month_day tax_year (6 : Int) (30 : Int)))) (Date_en.of_year_month_day tax_year (12 : Int) (31 : Int)))) (Date_en.of_year_month_day tax_year (1 : Int) (1 : Int)))
  joint_return_exception_applies : Bool := (List.foldl ((fun (acc : Bool) (event : TaxReturnEvent) => (decide (acc) || ((decide ((event).individual = individual)) && ((decide ((event).tax_year = tax_year)) && (decide ((event).filed_joint_return) && (!decide ((event).is_only_for_refund_claim)))))))) false tax_return_events)
  is_qualifying_child : Bool := (decide (relationship_requirement_met) && (decide (principal_place_of_abode_requirement_met) && (decide (age_requirement_met) && (!decide (joint_return_exception_applies)))))

def IndividualSection152QualifyingChild_main_output_leaf_0 (input : IndividualSection152QualifyingChild_Input) : Option IndividualSection152QualifyingChildOutput :=
  some (({ individual := input.individual, taxpayer := input.taxpayer, is_qualifying_child := input.is_qualifying_child, relationship_requirement_met := input.relationship_requirement_met, principal_place_of_abode_requirement_met := input.principal_place_of_abode_requirement_met, age_requirement_met := input.age_requirement_met, joint_return_exception_applies := input.joint_return_exception_applies } : IndividualSection152QualifyingChildOutput))

structure IndividualSection152QualifyingChild where
  main_output : IndividualSection152QualifyingChildOutput
deriving Repr, DecidableEq, Inhabited
def individualSection152QualifyingChild (input : IndividualSection152QualifyingChild_Input) : IndividualSection152QualifyingChild :=
  let main_output := match IndividualSection152QualifyingChild_main_output_leaf_0 input with | some val => val | _ => default
  { main_output := main_output }

structure IndividualSection152QualifyingRelative_Input where
  marriage_events : (List MarriageEvent)
  income_events : (List IncomeEvent)
  tax_return_events : (List TaxReturnEvent)
  qualifying_child_results : (List IndividualSection152QualifyingChildOutput)
  residence_period_events : (List ResidencePeriodEvent)
  family_relationship_events : (List FamilyRelationshipEvent)
  tax_year : Int
  taxpayer : Individual
  individual : Individual
  not_qualifying_child_requirement_met : Bool := ((fun (is_qualifying_child_of_current_taxpayer : Bool) => ((fun (is_qualifying_child_of_other_taxpayer : Bool) => (!(decide (is_qualifying_child_of_current_taxpayer) || decide (is_qualifying_child_of_other_taxpayer)))) (List.foldl ((fun (acc : Bool) (event : TaxReturnEvent) => (decide (acc) || ((decide ((event).tax_year = tax_year)) && ((!(decide ((event).individual = taxpayer))) && decide ((List.foldl ((fun (acc : Bool) (qualifying_child : Individual) => (decide (acc) || (decide (qualifying_child = individual))))) false (event).qualifying_children))))))) false tax_return_events))) (List.foldl ((fun (acc : Bool) (result : IndividualSection152QualifyingChildOutput) => (decide (acc) || ((decide ((result).individual = individual)) && ((decide ((result).taxpayer = taxpayer)) && decide ((result).is_qualifying_child)))))) false qualifying_child_results))
  no_income_requirement_met : Bool := (!decide ((List.foldl ((fun (acc : Bool) (income_event : IncomeEvent) => (decide (acc) || ((decide ((income_event).individual = individual)) && ((decide ((income_event).tax_year = tax_year)) && decide ((income_event).has_income)))))) false income_events)))
  relationship_requirement_met_H : Bool := ((fun (year_start : CatalaRuntime.Date) => ((fun (year_end : CatalaRuntime.Date) => ((!decide ((List.foldl ((fun (acc : Bool) (marriage_event : MarriageEvent) => (decide (acc) || ((((decide ((marriage_event).spouse1 = taxpayer)) && (decide ((marriage_event).spouse2 = individual))) || ((decide ((marriage_event).spouse1 = individual)) && (decide ((marriage_event).spouse2 = taxpayer)))) && (decide ((marriage_event).marriage_date ≤ year_end)))))) false marriage_events))) && decide ((List.foldl ((fun (acc : Bool) (taxpayer_residence : ResidencePeriodEvent) => (decide (acc) || ((decide ((taxpayer_residence).individual = taxpayer)) && (decide ((taxpayer_residence).is_principal_place_of_abode) && ((decide ((taxpayer_residence).start_date ≤ year_end)) && ((decide ((taxpayer_residence).end_date ≥ year_start)) && decide ((List.foldl ((fun (acc : Bool) (individual_residence : ResidencePeriodEvent) => (decide (acc) || ((decide ((individual_residence).individual = individual)) && ((decide ((individual_residence).household = (taxpayer_residence).household)) && (decide ((individual_residence).is_principal_place_of_abode) && (decide ((individual_residence).is_member_of_household) && ((decide ((individual_residence).start_date ≤ year_end)) && (decide ((individual_residence).end_date ≥ year_start)))))))))) false residence_period_events))))))))) false residence_period_events)))) (Date_en.of_year_month_day tax_year (12 : Int) (31 : Int)))) (Date_en.of_year_month_day tax_year (1 : Int) (1 : Int)))
  relationship_requirement_met : Bool := (decide ((List.foldl ((fun (acc : Bool) (rel_event : FamilyRelationshipEvent) => (decide (acc) || ((decide ((rel_event).person = taxpayer)) && ((decide ((rel_event).relative = individual)) && ((decide ((rel_event).start_date ≤ (Date_en.of_year_month_day tax_year (12 : Int) (31 : Int)))) && ((decide ((rel_event).relationship_type = (FamilyRelationshipType.Child ()))) || ((decide ((rel_event).relationship_type = (FamilyRelationshipType.DescendantOfChild ()))) || ((decide ((rel_event).relationship_type = (FamilyRelationshipType.Brother ()))) || ((decide ((rel_event).relationship_type = (FamilyRelationshipType.Sister ()))) || ((decide ((rel_event).relationship_type = (FamilyRelationshipType.Stepbrother ()))) || ((decide ((rel_event).relationship_type = (FamilyRelationshipType.Stepsister ()))) || ((decide ((rel_event).relationship_type = (FamilyRelationshipType.Father ()))) || ((decide ((rel_event).relationship_type = (FamilyRelationshipType.Mother ()))) || ((decide ((rel_event).relationship_type = (FamilyRelationshipType.AncestorOfFatherOrMother ()))) || ((decide ((rel_event).relationship_type = (FamilyRelationshipType.Stepmother ()))) || ((decide ((rel_event).relationship_type = (FamilyRelationshipType.Stepfather ()))) || ((decide ((rel_event).relationship_type = (FamilyRelationshipType.NieceOrNephew ()))) || ((decide ((rel_event).relationship_type = (FamilyRelationshipType.UncleOrAunt ()))) || ((decide ((rel_event).relationship_type = (FamilyRelationshipType.SonInLaw ()))) || ((decide ((rel_event).relationship_type = (FamilyRelationshipType.DaughterInLaw ()))) || ((decide ((rel_event).relationship_type = (FamilyRelationshipType.FatherInLaw ()))) || ((decide ((rel_event).relationship_type = (FamilyRelationshipType.MotherInLaw ()))) || ((decide ((rel_event).relationship_type = (FamilyRelationshipType.BrotherInLaw ()))) || (decide ((rel_event).relationship_type = (FamilyRelationshipType.SisterInLaw ()))))))))))))))))))))))))))) false family_relationship_events)) || decide (relationship_requirement_met_H))
  is_qualifying_relative : Bool := (decide (relationship_requirement_met) && (decide (no_income_requirement_met) && decide (not_qualifying_child_requirement_met)))

def IndividualSection152QualifyingRelative_main_output_leaf_0 (input : IndividualSection152QualifyingRelative_Input) : Option IndividualSection152QualifyingRelativeOutput :=
  some (({ individual := input.individual, taxpayer := input.taxpayer, is_qualifying_relative := input.is_qualifying_relative, relationship_requirement_met_H := input.relationship_requirement_met_H, relationship_requirement_met := input.relationship_requirement_met, no_income_requirement_met := input.no_income_requirement_met, not_qualifying_child_requirement_met := input.not_qualifying_child_requirement_met } : IndividualSection152QualifyingRelativeOutput))

structure IndividualSection152QualifyingRelative where
  main_output : IndividualSection152QualifyingRelativeOutput
deriving Repr, DecidableEq, Inhabited
def individualSection152QualifyingRelative (input : IndividualSection152QualifyingRelative_Input) : IndividualSection152QualifyingRelative :=
  let main_output := match IndividualSection152QualifyingRelative_main_output_leaf_0 input with | some val => val | _ => default
  { main_output := main_output }

structure IndividualSection7703MaritalStatus_Input where
  individuals_entitled_to_exemptions_under_151 : (List Individual)
  qualifying_children : (List IndividualSection152QualifyingChildOutput)
  household_maintenance_events : (List HouseholdMaintenanceEvent)
  residence_period_events : (List ResidencePeriodEvent)
  individual_tax_return : IndividualTaxReturn
  death_events : (List DeathEvent)
  divorce_or_legal_separation_events : (List DivorceOrLegalSeparationEvent)
  marriage_events : (List MarriageEvent)
  tax_year : Int
  individual : Individual
  section_7703_find_spouse_from_marriage_events : (Individual → (List MarriageEvent) → CatalaRuntime.Date → (Optional Individual)) := fun (individual_arg : Individual) (marriage_events_arg : (List MarriageEvent)) (year_end_arg : CatalaRuntime.Date) => ((fun (valid_marriages : (List (Individual × CatalaRuntime.Date))) => (if (decide ((valid_marriages).length > (0 : Int))) then ((fun (most_recent_marriage : CatalaRuntime.Date) => (List_en.first_element (List.map ((fun (marriage_tuple : (Individual × CatalaRuntime.Date)) => (marriage_tuple).1)) (List.filter ((fun (marriage_tuple : (Individual × CatalaRuntime.Date)) => (decide ((marriage_tuple).2 = most_recent_marriage)))) valid_marriages)))) (match (List.map ((fun (marriage_tuple : (Individual × CatalaRuntime.Date)) => (marriage_tuple).2)) valid_marriages) with | [] => (fun () => default /-unsupported expression-/) () | x0 :: xn => List.foldl (fun (max1 : CatalaRuntime.Date) (max2 : CatalaRuntime.Date) => (if (decide (max1 > max2)) then max1 else max2)) x0 xn)) else (Optional.Absent ()))) (List.map ((fun (marriage_event : MarriageEvent) => ((if (decide ((marriage_event).spouse1 = individual_arg)) then (marriage_event).spouse2 else (marriage_event).spouse1), (marriage_event).marriage_date))) (List.filter ((fun (marriage_event : MarriageEvent) => (((decide ((marriage_event).spouse1 = individual_arg)) || (decide ((marriage_event).spouse2 = individual_arg))) && (decide ((marriage_event).marriage_date ≤ year_end_arg))))) marriage_events_arg)))
  section_7703_get_spouse_death_date_during_year : ((Optional Individual) → (List DeathEvent) → Int → (Optional CatalaRuntime.Date)) := fun (spouse_arg : (Optional Individual)) (death_events_arg : (List DeathEvent)) (tax_year_arg : Int) => (match spouse_arg with | Optional.Absent _ => (Optional.Absent ())| Optional.Present s => ((fun (year_start : CatalaRuntime.Date) => ((fun (year_end : CatalaRuntime.Date) => ((fun (spouse_death_events_during_year : (List DeathEvent)) => (if (decide ((spouse_death_events_during_year).length > (0 : Int))) then (Optional.Present (match (List.map ((fun (death_event : DeathEvent) => (death_event).death_date)) spouse_death_events_during_year) with | [] => (fun () => default /-unsupported expression-/) () | x0 :: xn => List.foldl (fun (min1 : CatalaRuntime.Date) (min2 : CatalaRuntime.Date) => (if (decide (min1 < min2)) then min1 else min2)) x0 xn)) else (Optional.Absent ()))) (List.filter ((fun (death_event : DeathEvent) => ((decide ((death_event).decedent = s)) && ((decide ((death_event).death_date ≥ year_start)) && (decide ((death_event).death_date ≤ year_end)))))) death_events_arg))) (Date_en.of_year_month_day tax_year_arg (12 : Int) (31 : Int)))) (Date_en.of_year_month_day tax_year_arg (1 : Int) (1 : Int))))
  section_7703_spouse_died_before_date : ((Optional Individual) → (List DeathEvent) → CatalaRuntime.Date → Bool) := fun (spouse_arg : (Optional Individual)) (death_events_arg : (List DeathEvent)) (before_date_arg : CatalaRuntime.Date) => (match spouse_arg with | Optional.Absent _ => false| Optional.Present s => ((fun (spouse_death_events_before_date : (List DeathEvent)) => (decide ((spouse_death_events_before_date).length > (0 : Int)))) (List.filter ((fun (death_event : DeathEvent) => ((decide ((death_event).decedent = s)) && (decide ((death_event).death_date < before_date_arg))))) death_events_arg)))
  section_7703_get_spouse_from_tax_return : (Individual → IndividualTaxReturn → (Optional Individual)) := fun (individual_arg : Individual) (individual_tax_return_arg : IndividualTaxReturn) => (match (individual_tax_return_arg).details with | FilingStatusVariant.JointReturn variant => (if (decide ((variant).taxpayer = individual_arg)) then (Optional.Present (variant).spouse) else (Optional.Absent ()))| FilingStatusVariant.SurvivingSpouse variant => (if (decide ((variant).taxpayer = individual_arg)) then (Optional.Present (variant).deceased_spouse) else (Optional.Absent ()))| FilingStatusVariant.HeadOfHousehold variant => (Optional.Absent ())| FilingStatusVariant.Single variant => (Optional.Absent ())| FilingStatusVariant.MarriedFilingSeparate variant => (if (decide ((variant).taxpayer = individual_arg)) then (Optional.Present (variant).spouse) else (Optional.Absent ())))
  section_7703_files_separate_return : (Individual → IndividualTaxReturn → Bool) := fun (individual_arg : Individual) (individual_tax_return_arg : IndividualTaxReturn) => (match (individual_tax_return_arg).details with | FilingStatusVariant.JointReturn variant => false| FilingStatusVariant.SurvivingSpouse variant => false| FilingStatusVariant.HeadOfHousehold variant => false| FilingStatusVariant.Single variant => false| FilingStatusVariant.MarriedFilingSeparate variant => (decide ((variant).taxpayer = individual_arg)))
  section_7703_is_spouse_member_of_household_last_6_months : (Individual → Household → (List ResidencePeriodEvent) → CatalaRuntime.Date → CatalaRuntime.Date → Bool) := fun (spouse_arg : Individual) (household_arg : Household) (residence_period_events_arg : (List ResidencePeriodEvent)) (last_6_months_start_arg : CatalaRuntime.Date) (last_6_months_end_arg : CatalaRuntime.Date) => ((fun (spouse_membership_events : (List ResidencePeriodEvent)) => (if (decide ((spouse_membership_events).length > (0 : Int))) then (List.foldl ((fun (acc : Bool) (membership_event : ResidencePeriodEvent) => (decide (acc) || ((decide ((membership_event).start_date ≤ last_6_months_end_arg)) && (decide ((membership_event).end_date ≥ last_6_months_start_arg)))))) false spouse_membership_events) else false)) (List.filter ((fun (spouse_residence_event : ResidencePeriodEvent) => ((decide ((spouse_residence_event).individual = spouse_arg)) && ((decide ((spouse_residence_event).household = household_arg)) && decide ((spouse_residence_event).is_member_of_household))))) residence_period_events_arg))
  households_with_qualifying_child : (List Household) := ((fun (year_end : CatalaRuntime.Date) => ((fun (year_start : CatalaRuntime.Date) => (List.map ((fun (child_residence_event : ResidencePeriodEvent) => (child_residence_event).household)) (List.filter ((fun (child_residence_event : ResidencePeriodEvent) => (decide ((child_residence_event).is_principal_place_of_abode) && ((decide ((child_residence_event).start_date ≤ (Date_en.of_year_month_day tax_year (6 : Int) (30 : Int)))) && ((decide ((child_residence_event).end_date ≥ (Date_en.of_year_month_day tax_year (7 : Int) (1 : Int)))) && ((decide ((child_residence_event).start_date ≤ year_end)) && ((decide ((child_residence_event).end_date ≥ year_start)) && decide ((List.foldl ((fun (acc : Bool) (qualifying_child_result : IndividualSection152QualifyingChildOutput) => (decide (acc) || (decide ((qualifying_child_result).is_qualifying_child) && ((decide ((qualifying_child_result).taxpayer = individual)) && ((decide ((qualifying_child_result).individual = (child_residence_event).individual)) && decide ((List.foldl ((fun (acc : Bool) (entitled_individual : Individual) => (decide (acc) || ((decide (entitled_individual = (child_residence_event).individual)) && decide ((List.foldl ((fun (acc : Bool) (individual_residence_event : ResidencePeriodEvent) => (decide (acc) || ((decide ((individual_residence_event).individual = individual)) && ((decide ((individual_residence_event).household = (child_residence_event).household)) && ((decide ((individual_residence_event).start_date ≤ (child_residence_event).end_date)) && ((decide ((individual_residence_event).end_date ≥ (child_residence_event).start_date)) && ((decide ((individual_residence_event).start_date ≤ year_end)) && (decide ((individual_residence_event).end_date ≥ year_start)))))))))) false residence_period_events)))))) false individuals_entitled_to_exemptions_under_151)))))))) false qualifying_children))))))))) residence_period_events))) (Date_en.of_year_month_day tax_year (1 : Int) (1 : Int)))) (Date_en.of_year_month_day tax_year (12 : Int) (31 : Int)))
  determination_date : CatalaRuntime.Date := ((fun (year_end : CatalaRuntime.Date) => ((fun (spouse : (Optional Individual)) => ((fun (spouse_death_date_during_year : (Optional CatalaRuntime.Date)) => (match spouse_death_date_during_year with | Optional.Absent _ => year_end| Optional.Present death_date => death_date)) (section_7703_get_spouse_death_date_during_year spouse death_events tax_year))) (section_7703_find_spouse_from_marriage_events individual marriage_events year_end))) (Date_en.of_year_month_day tax_year (12 : Int) (31 : Int)))
  households_maintained_by_individual : (List Household) := ((fun (year_end : CatalaRuntime.Date) => ((fun (year_start : CatalaRuntime.Date) => (List.filter ((fun (household : Household) => (List.foldl ((fun (acc : Bool) (maintenance_event : HouseholdMaintenanceEvent) => (decide (acc) || ((decide ((maintenance_event).individual = individual)) && ((decide ((maintenance_event).household = household)) && ((decide ((maintenance_event).cost_furnished_percentage > (Rat.mk 1 2))) && ((decide ((maintenance_event).start_date ≤ year_end)) && ((decide ((maintenance_event).end_date ≥ year_start)) && decide ((List.foldl ((fun (acc : Bool) (individual_residence_event : ResidencePeriodEvent) => (decide (acc) || ((decide ((individual_residence_event).individual = individual)) && ((decide ((individual_residence_event).household = household)) && ((decide ((individual_residence_event).start_date ≤ (maintenance_event).end_date)) && (decide ((individual_residence_event).end_date ≥ (maintenance_event).start_date)))))))) false residence_period_events)))))))))) false household_maintenance_events))) households_with_qualifying_child)) (Date_en.of_year_month_day tax_year (1 : Int) (1 : Int)))) (Date_en.of_year_month_day tax_year (12 : Int) (31 : Int)))
  is_legally_separated : Bool := ((fun (year_end : CatalaRuntime.Date) => ((fun (spouse : (Optional Individual)) => (match spouse with | Optional.Absent _ => false| Optional.Present s => (List.foldl ((fun (acc : Bool) (divorce_event : DivorceOrLegalSeparationEvent) => (decide (acc) || (((decide ((divorce_event).person1 = individual)) || (decide ((divorce_event).person2 = individual))) && (((decide ((divorce_event).person1 = s)) || (decide ((divorce_event).person2 = s))) && ((decide ((divorce_event).decree_date ≤ determination_date)) && ((decide ((divorce_event).decree_type = (DecreeType.Divorce ()))) || (decide ((divorce_event).decree_type = (DecreeType.SeparateMaintenance ())))))))))) false divorce_or_legal_separation_events))) (section_7703_find_spouse_from_marriage_events individual marriage_events year_end))) (Date_en.of_year_month_day tax_year (12 : Int) (31 : Int)))
  is_married_at_determination_date : Bool := ((fun (year_end : CatalaRuntime.Date) => ((fun (spouse : (Optional Individual)) => (match spouse with | Optional.Absent _ => false| Optional.Present s => (!decide ((section_7703_spouse_died_before_date spouse death_events determination_date))))) (section_7703_find_spouse_from_marriage_events individual marriage_events year_end))) (Date_en.of_year_month_day tax_year (12 : Int) (31 : Int)))
  spouse_not_member_of_household_last_6_months : Bool := ((fun (year_end : CatalaRuntime.Date) => ((fun (last_6_months_start : CatalaRuntime.Date) => ((fun (last_6_months_end : CatalaRuntime.Date) => ((fun (spouse_from_tax_return : (Optional Individual)) => (match spouse_from_tax_return with | Optional.Absent _ => (decide ((households_maintained_by_individual).length > (0 : Int)))| Optional.Present spouse => (List.foldl ((fun (acc : Bool) (household : Household) => (decide (acc) || (!decide ((section_7703_is_spouse_member_of_household_last_6_months spouse household residence_period_events last_6_months_start last_6_months_end)))))) false households_maintained_by_individual))) (section_7703_get_spouse_from_tax_return individual individual_tax_return))) year_end)) (Date_en.of_year_month_day tax_year (7 : Int) (1 : Int)))) (Date_en.of_year_month_day tax_year (12 : Int) (31 : Int)))
  subsection_b_exception_applies : Bool := (match (match processExceptions [if (decide (is_married_at_determination_date) && ((!decide (is_legally_separated)) && (decide ((section_7703_files_separate_return individual individual_tax_return)) && decide (spouse_not_member_of_household_last_6_months)))) then some (true) else none] with | none => some (false) | some r => some r) with | some r => r | _ => default)
  is_married_for_tax_purposes : Bool := (match (match processExceptions [(match processExceptions [if subsection_b_exception_applies then some (false) else none] with | none => if (decide (is_married_at_determination_date) && (!decide (is_legally_separated))) then some (true) else none | some r => some r)] with | none => some (false) | some r => some r) with | some r => r | _ => default)

def IndividualSection7703MaritalStatus_main_output_leaf_0 (input : IndividualSection7703MaritalStatus_Input) : Option IndividualSection7703MaritalStatusOutput :=
  some (({ individual := input.individual, tax_year := input.tax_year, determination_date := input.determination_date, is_married_at_determination_date := input.is_married_at_determination_date, is_legally_separated := input.is_legally_separated, households_with_qualifying_child := input.households_with_qualifying_child, households_maintained_by_individual := input.households_maintained_by_individual, spouse_not_member_of_household_last_6_months := input.spouse_not_member_of_household_last_6_months, subsection_b_exception_applies := input.subsection_b_exception_applies, is_married_for_tax_purposes := input.is_married_for_tax_purposes } : IndividualSection7703MaritalStatusOutput))

structure IndividualSection7703MaritalStatus where
  main_output : IndividualSection7703MaritalStatusOutput
deriving Repr, DecidableEq, Inhabited
def individualSection7703MaritalStatus (input : IndividualSection7703MaritalStatus_Input) : IndividualSection7703MaritalStatus :=
  let main_output := match IndividualSection7703MaritalStatus_main_output_leaf_0 input with | some val => val | _ => default
  { main_output := main_output }

structure OrganizationSection3306EmployerStatus_Input where
  employment_relationship_events : (List EmploymentRelationshipEvent)
  wage_payment_events : (List WagePaymentEvent)
  calendar_year : Int
  organization : Organization
  section_3306_employment_overlaps_date : (EmploymentRelationshipEvent → CatalaRuntime.Date → Bool) := fun (emp_event_arg : EmploymentRelationshipEvent) (check_date_arg : CatalaRuntime.Date) => ((decide ((emp_event_arg).start_date ≤ check_date_arg)) && (decide ((emp_event_arg).end_date ≥ check_date_arg)))
  section_3306_count_unique_employees : ((List EmploymentRelationshipEvent) → Int) := fun (employment_events_arg : (List EmploymentRelationshipEvent)) => ((fun (unique_employee_events : (List EmploymentRelationshipEvent)) => (unique_employee_events).length) (List.filter ((fun (emp_event : EmploymentRelationshipEvent) => (!decide ((List.foldl ((fun (acc : Bool) (prev_emp_event : EmploymentRelationshipEvent) => (decide (acc) || ((decide (((prev_emp_event).employee).id = ((emp_event).employee).id)) && (decide ((prev_emp_event).id < (emp_event).id)))))) false employment_events_arg))))) employment_events_arg))
  section_3306_get_day_of_year : (CatalaRuntime.Date → Int) := fun (date_arg : CatalaRuntime.Date) => ((fun (year_local : Int) => ((fun (month_local : Int) => ((fun (day_local : Int) => ((fun (year_div_4 : Rat) => ((fun (year_mod_4 : Int) => ((fun (year_div_100 : Rat) => ((fun (year_mod_100 : Int) => ((fun (year_div_400 : Rat) => ((fun (year_mod_400 : Int) => ((fun (is_leap_year_local : Bool) => ((fun (days_before_month : Int) => (days_before_month + day_local)) (if (decide (month_local = (1 : Int))) then (0 : Int) else (if (decide (month_local = (2 : Int))) then (31 : Int) else (if (decide (month_local = (3 : Int))) then (if is_leap_year_local then (60 : Int) else (59 : Int)) else (if (decide (month_local = (4 : Int))) then (if is_leap_year_local then (91 : Int) else (90 : Int)) else (if (decide (month_local = (5 : Int))) then (if is_leap_year_local then (121 : Int) else (120 : Int)) else (if (decide (month_local = (6 : Int))) then (if is_leap_year_local then (152 : Int) else (151 : Int)) else (if (decide (month_local = (7 : Int))) then (if is_leap_year_local then (182 : Int) else (181 : Int)) else (if (decide (month_local = (8 : Int))) then (if is_leap_year_local then (213 : Int) else (212 : Int)) else (if (decide (month_local = (9 : Int))) then (if is_leap_year_local then (244 : Int) else (243 : Int)) else (if (decide (month_local = (10 : Int))) then (if is_leap_year_local then (274 : Int) else (273 : Int)) else (if (decide (month_local = (11 : Int))) then (if is_leap_year_local then (305 : Int) else (304 : Int)) else (if is_leap_year_local then (335 : Int) else (334 : Int))))))))))))))) (((decide (year_mod_4 = (0 : Int))) && (!(decide (year_mod_100 = (0 : Int))))) || (decide (year_mod_400 = (0 : Int)))))) (year_local - (CatalaRuntime.multiply (Rat.floor year_div_400) (400 : Int))))) (year_local / (400 : Int)))) (year_local - (CatalaRuntime.multiply (Rat.floor year_div_100) (100 : Int))))) (year_local / (100 : Int)))) (year_local - (CatalaRuntime.multiply (Rat.floor year_div_4) (4 : Int))))) (year_local / (4 : Int)))) (Date_en.get_day date_arg))) (Date_en.get_month date_arg))) (Date_en.get_year date_arg))
  is_domestic_service_employer : Bool := ((fun (relevant_wage_events : (List WagePaymentEvent)) => ((fun (total_domestic_service_wages : CatalaRuntime.Money) => (decide (total_domestic_service_wages ≥ (CatalaRuntime.Money.ofCents 100000)))) (match (List.map ((fun (wage_event : WagePaymentEvent) => (wage_event).amount)) relevant_wage_events) with | [] => (fun () => (CatalaRuntime.Money.ofCents 0)) () | x0 :: xn => List.foldl (fun (sum1 : CatalaRuntime.Money) (sum2 : CatalaRuntime.Money) => (sum1 + sum2)) x0 xn))) (List.filter ((fun (wage_event : WagePaymentEvent) => ((decide (((wage_event).employer).id = (organization).id)) && ((decide ((wage_event).payment_medium = (PaymentMedium.Cash ()))) && (((decide ((Date_en.get_year (wage_event).payment_date) = calendar_year)) || (decide ((Date_en.get_year (wage_event).payment_date) = (calendar_year - (1 : Int))))) && decide ((List.foldl ((fun (acc : Bool) (emp_event : EmploymentRelationshipEvent) => (decide (acc) || ((decide (((emp_event).employer).id = (organization).id)) && ((decide (((emp_event).employee).id = ((wage_event).employee).id)) && (decide ((emp_event).employment_category = (EmploymentCategory.DomesticService ())))))))) false employment_relationship_events))))))) wage_payment_events))
  section_3306_get_candidate_dates_in_year : ((List EmploymentRelationshipEvent) → Int → (List CatalaRuntime.Date)) := fun (employment_events_arg : (List EmploymentRelationshipEvent)) (target_year_arg : Int) => ((fun (year_start : CatalaRuntime.Date) => ((fun (year_end : CatalaRuntime.Date) => ((fun (all_year_days : (List CatalaRuntime.Date)) => (List.filter ((fun (check_date : CatalaRuntime.Date) => ((decide ((Date_en.get_year check_date) = target_year_arg)) && decide ((List.foldl ((fun (acc : Bool) (emp_event : EmploymentRelationshipEvent) => (decide (acc) || decide ((section_3306_employment_overlaps_date emp_event check_date))))) false employment_events_arg))))) all_year_days)) (List.map ((fun (day_num : Int) => (year_start + (CatalaRuntime.multiply (day_num - (1 : Int)) (CatalaRuntime.Duration.create 0 0 1))))) (List_en.sequence (1 : Int) (366 : Int))))) (Date_en.of_year_month_day target_year_arg (12 : Int) (31 : Int)))) (Date_en.of_year_month_day target_year_arg (1 : Int) (1 : Int)))
  section_3306_get_calendar_week_us : (CatalaRuntime.Date → (Int × Int)) := fun (date_arg : CatalaRuntime.Date) => ((fun (year_local : Int) => ((fun (day_of_year : Int) => ((fun (days_minus_one : Int) => ((fun (week_decimal : Rat) => ((fun (week_number : Int) => (year_local, week_number)) ((Rat.floor week_decimal) + (1 : Int)))) ((CatalaRuntime.toRat days_minus_one) / (Rat.mk 7 1)))) (day_of_year - (1 : Int)))) (section_3306_get_day_of_year date_arg))) (Date_en.get_year date_arg))
  section_3306_get_days_with_employment : ((List EmploymentRelationshipEvent) → Int → Int → (List CatalaRuntime.Date)) := fun (employment_events_arg : (List EmploymentRelationshipEvent)) (target_year_arg : Int) (min_individuals_arg : Int) => ((fun (candidate_dates : (List CatalaRuntime.Date)) => (List.filter ((fun (candidate_date : CatalaRuntime.Date) => ((fun (employment_events_on_day : (List EmploymentRelationshipEvent)) => ((fun (unique_employee_count : Int) => (decide (unique_employee_count ≥ min_individuals_arg))) (section_3306_count_unique_employees employment_events_on_day))) (List.filter ((fun (emp_event : EmploymentRelationshipEvent) => (section_3306_employment_overlaps_date emp_event candidate_date))) employment_events_arg)))) candidate_dates)) (section_3306_get_candidate_dates_in_year employment_events_arg target_year_arg))
  section_3306_get_week_identifier : (CatalaRuntime.Date → (Int × Int)) := fun (date_arg : CatalaRuntime.Date) => (section_3306_get_calendar_week_us date_arg)
  section_3306_count_unique_calendar_weeks : ((List CatalaRuntime.Date) → Int) := fun (dates_arg : (List CatalaRuntime.Date)) => ((fun (unique_dates : (List CatalaRuntime.Date)) => (unique_dates).length) (List.filter ((fun (date_item : CatalaRuntime.Date) => ((fun (current_week_id : (Int × Int)) => (!decide ((List.foldl ((fun (acc : Bool) (prev_date : CatalaRuntime.Date) => (decide (acc) || ((decide (prev_date < date_item)) && (decide ((section_3306_get_week_identifier prev_date) = current_week_id)))))) false dates_arg)))) (section_3306_get_week_identifier date_item)))) dates_arg))
  section_3306_has_ten_days_in_different_weeks : ((List EmploymentRelationshipEvent) → Int → Int → Bool) := fun (employment_events_arg : (List EmploymentRelationshipEvent)) (target_year_arg : Int) (min_individuals_arg : Int) => ((fun (days_current_year : (List CatalaRuntime.Date)) => ((fun (preceding_year : Int) => ((fun (days_preceding_year : (List CatalaRuntime.Date)) => ((fun (all_days : (List CatalaRuntime.Date)) => ((fun (unique_week_count : Int) => (decide (unique_week_count ≥ (10 : Int)))) (section_3306_count_unique_calendar_weeks all_days))) (days_current_year ++ days_preceding_year))) (section_3306_get_days_with_employment employment_events_arg preceding_year min_individuals_arg))) (target_year_arg - (1 : Int)))) (section_3306_get_days_with_employment employment_events_arg target_year_arg min_individuals_arg))
  is_agricultural_employer : Bool := (match (match processExceptions [if ((fun (relevant_employment_events : (List EmploymentRelationshipEvent)) => (section_3306_has_ten_days_in_different_weeks relevant_employment_events calendar_year (5 : Int))) (List.filter ((fun (emp_event : EmploymentRelationshipEvent) => ((decide (((emp_event).employer).id = (organization).id)) && ((decide ((emp_event).employment_category = (EmploymentCategory.AgriculturalLabor ()))) && ((decide ((Date_en.get_year (emp_event).start_date) = calendar_year)) || ((decide ((Date_en.get_year (emp_event).start_date) = (calendar_year - (1 : Int)))) || ((decide ((Date_en.get_year (emp_event).end_date) = calendar_year)) || (decide ((Date_en.get_year (emp_event).end_date) = (calendar_year - (1 : Int))))))))))) employment_relationship_events)) then some (true) else none] with | none => some (((fun (relevant_wage_events : (List WagePaymentEvent)) => ((fun (total_agricultural_wages : CatalaRuntime.Money) => (decide (total_agricultural_wages ≥ (CatalaRuntime.Money.ofCents 2000000)))) (match (List.map ((fun (wage_event : WagePaymentEvent) => (wage_event).amount)) relevant_wage_events) with | [] => (fun () => (CatalaRuntime.Money.ofCents 0)) () | x0 :: xn => List.foldl (fun (sum1 : CatalaRuntime.Money) (sum2 : CatalaRuntime.Money) => (sum1 + sum2)) x0 xn))) (List.filter ((fun (wage_event : WagePaymentEvent) => ((decide (((wage_event).employer).id = (organization).id)) && (((decide ((Date_en.get_year (wage_event).payment_date) = calendar_year)) || (decide ((Date_en.get_year (wage_event).payment_date) = (calendar_year - (1 : Int))))) && decide ((List.foldl ((fun (acc : Bool) (emp_event : EmploymentRelationshipEvent) => (decide (acc) || ((decide (((emp_event).employer).id = (organization).id)) && ((decide (((emp_event).employee).id = ((wage_event).employee).id)) && (decide ((emp_event).employment_category = (EmploymentCategory.AgriculturalLabor ())))))))) false employment_relationship_events)))))) wage_payment_events))) | some r => some r) with | some r => r | _ => default)
  is_general_employer : Bool := (match (match processExceptions [if ((fun (relevant_employment_events : (List EmploymentRelationshipEvent)) => (section_3306_has_ten_days_in_different_weeks relevant_employment_events calendar_year (1 : Int))) (List.filter ((fun (emp_event : EmploymentRelationshipEvent) => ((decide (((emp_event).employer).id = (organization).id)) && (((decide ((Date_en.get_year (emp_event).start_date) = calendar_year)) || ((decide ((Date_en.get_year (emp_event).start_date) = (calendar_year - (1 : Int)))) || ((decide ((Date_en.get_year (emp_event).end_date) = calendar_year)) || (decide ((Date_en.get_year (emp_event).end_date) = (calendar_year - (1 : Int))))))) && (!(decide ((emp_event).employment_category = (EmploymentCategory.DomesticService ())))))))) employment_relationship_events)) then some (true) else none] with | none => some (((fun (relevant_wage_events : (List WagePaymentEvent)) => ((fun (total_wages : CatalaRuntime.Money) => (decide (total_wages ≥ (CatalaRuntime.Money.ofCents 150000)))) (match (List.map ((fun (wage_event : WagePaymentEvent) => (wage_event).amount)) relevant_wage_events) with | [] => (fun () => (CatalaRuntime.Money.ofCents 0)) () | x0 :: xn => List.foldl (fun (sum1 : CatalaRuntime.Money) (sum2 : CatalaRuntime.Money) => (sum1 + sum2)) x0 xn))) (List.filter ((fun (wage_event : WagePaymentEvent) => ((decide (((wage_event).employer).id = (organization).id)) && (((decide ((Date_en.get_year (wage_event).payment_date) = calendar_year)) || (decide ((Date_en.get_year (wage_event).payment_date) = (calendar_year - (1 : Int))))) && (!decide ((List.foldl ((fun (acc : Bool) (emp_event : EmploymentRelationshipEvent) => (decide (acc) || ((decide (((emp_event).employer).id = (organization).id)) && ((decide (((emp_event).employee).id = ((wage_event).employee).id)) && (decide ((emp_event).employment_category = (EmploymentCategory.DomesticService ())))))))) false employment_relationship_events))))))) wage_payment_events))) | some r => some r) with | some r => r | _ => default)
  is_employer : Bool := (decide (is_general_employer) || (decide (is_agricultural_employer) || decide (is_domestic_service_employer)))

def OrganizationSection3306EmployerStatus_main_output_leaf_0 (input : OrganizationSection3306EmployerStatus_Input) : Option OrganizationSection3306EmployerStatusOutput :=
  some (({ organization := input.organization, is_employer := input.is_employer, is_general_employer := input.is_general_employer, is_agricultural_employer := input.is_agricultural_employer, is_domestic_service_employer := input.is_domestic_service_employer } : OrganizationSection3306EmployerStatusOutput))

structure OrganizationSection3306EmployerStatus where
  main_output : OrganizationSection3306EmployerStatusOutput
deriving Repr, DecidableEq, Inhabited
def organizationSection3306EmployerStatus (input : OrganizationSection3306EmployerStatus_Input) : OrganizationSection3306EmployerStatus :=
  let main_output := match OrganizationSection3306EmployerStatus_main_output_leaf_0 input with | some val => val | _ => default
  { main_output := main_output }

structure WagePaymentEventSection3306Wages_Input where
  death_events : (List DeathEvent)
  employment_termination_events : (List EmploymentTerminationEvent)
  wage_payment_event : WagePaymentEvent
  is_excluded_by_agricultural_noncash : Bool := ((decide ((wage_payment_event).payment_medium = (PaymentMedium.NonCash ()))) && (decide ((wage_payment_event).payment_reason = (PaymentReason.AgriculturalLaborNonCash ()))))
  is_excluded_by_nonbusiness_service : Bool := ((decide ((wage_payment_event).payment_medium = (PaymentMedium.NonCash ()))) && decide ((wage_payment_event).is_not_in_course_of_trade_or_business))
  is_excluded_by_sickness_disability_death : Bool := (((decide ((wage_payment_event).payment_reason = (PaymentReason.SicknessOrAccidentDisability ()))) || (decide ((wage_payment_event).payment_reason = (PaymentReason.Death ())))) && (decide ((wage_payment_event).is_under_plan_or_system) && (decide ((wage_payment_event).is_for_employee_generally) || decide ((wage_payment_event).is_for_class_of_employees))))
  is_excluded_by_termination_payment : Bool := ((fun (is_termination_payment : Bool) => ((fun (termination_condition_A_met : Bool) => ((fun (plan_condition_B_met : Bool) => ((decide (is_termination_payment) && (decide (termination_condition_A_met) && (!decide ((wage_payment_event).would_have_been_paid_without_termination)))) && decide (plan_condition_B_met))) (decide ((wage_payment_event).is_under_plan_or_system) && (decide ((wage_payment_event).is_for_employee_generally) || decide ((wage_payment_event).is_for_class_of_employees))))) (List.foldl ((fun (acc : Bool) (term_event : EmploymentTerminationEvent) => (decide (acc) || ((decide (((term_event).employer).id = ((wage_payment_event).employer).id)) && ((decide (((term_event).employee).id = ((wage_payment_event).employee).id)) && (((decide ((term_event).reason = (TerminationReason.Death ()))) || (decide ((term_event).reason = (TerminationReason.DisabilityRetirement ())))) && (decide ((term_event).termination_date ≤ (wage_payment_event).payment_date)))))))) false employment_termination_events))) (decide ((wage_payment_event).payment_reason = (PaymentReason.TerminationAfterDeathOrDisabilityRetirement ()))))
  is_excluded_by_survivor_payment : Bool := ((fun (is_paid_to_survivor_or_estate : Bool) => ((fun (payment_year : Int) => ((fun (employee_local : Individual) => ((fun (employee_died_in_previous_year : Bool) => (decide (is_paid_to_survivor_or_estate) && decide (employee_died_in_previous_year))) (List.foldl ((fun (acc : Bool) (death_event : DeathEvent) => (decide (acc) || ((decide (((death_event).decedent).id = (employee_local).id)) && (decide ((Date_en.get_year (death_event).death_date) < payment_year)))))) false death_events))) (wage_payment_event).employee)) (Date_en.get_year (wage_payment_event).payment_date))) (wage_payment_event).is_paid_to_survivor_or_estate)
  taxable_amount_before_7000_cap : CatalaRuntime.Money := (if (decide (is_excluded_by_sickness_disability_death) || (decide (is_excluded_by_nonbusiness_service) || (decide (is_excluded_by_termination_payment) || (decide (is_excluded_by_agricultural_noncash) || decide (is_excluded_by_survivor_payment))))) then (CatalaRuntime.Money.ofCents 0) else (wage_payment_event).amount)

def WagePaymentEventSection3306Wages_main_output_leaf_0 (input : WagePaymentEventSection3306Wages_Input) : Option WagePaymentEventSection3306WagesOutput :=
  some (({ wage_payment_event := input.wage_payment_event, is_excluded_by_sickness_disability_death := input.is_excluded_by_sickness_disability_death, is_excluded_by_nonbusiness_service := input.is_excluded_by_nonbusiness_service, is_excluded_by_termination_payment := input.is_excluded_by_termination_payment, is_excluded_by_agricultural_noncash := input.is_excluded_by_agricultural_noncash, is_excluded_by_survivor_payment := input.is_excluded_by_survivor_payment, taxable_amount_before_7000_cap := input.taxable_amount_before_7000_cap } : WagePaymentEventSection3306WagesOutput))

structure WagePaymentEventSection3306Wages where
  main_output : WagePaymentEventSection3306WagesOutput
deriving Repr, DecidableEq, Inhabited
def wagePaymentEventSection3306Wages (input : WagePaymentEventSection3306Wages_Input) : WagePaymentEventSection3306Wages :=
  let main_output := match WagePaymentEventSection3306Wages_main_output_leaf_0 input with | some val => val | _ => default
  { main_output := main_output }

structure TotalWages3306Calculation_Input where
  wage_results : (List WagePaymentEventSection3306WagesOutput)
  total_taxable_wages : CatalaRuntime.Money := ((fun (total_before_cap : CatalaRuntime.Money) => (if (decide (total_before_cap > (CatalaRuntime.Money.ofCents 700000))) then (CatalaRuntime.Money.ofCents 700000) else total_before_cap)) (match (List.map ((fun (wage_result : WagePaymentEventSection3306WagesOutput) => (wage_result).taxable_amount_before_7000_cap)) wage_results) with | [] => (fun () => (CatalaRuntime.Money.ofCents 0)) () | x0 :: xn => List.foldl (fun (sum1 : CatalaRuntime.Money) (sum2 : CatalaRuntime.Money) => (sum1 + sum2)) x0 xn))

def TotalWages3306Calculation_main_output_leaf_0 (input : TotalWages3306Calculation_Input) : Option TotalWages3306CalculationOutput :=
  some (({ total_taxable_wages := input.total_taxable_wages, wage_results_with_cap := input.wage_results } : TotalWages3306CalculationOutput))

structure TotalWages3306Calculation where
  main_output : TotalWages3306CalculationOutput
deriving Repr, DecidableEq, Inhabited
def totalWages3306Calculation (input : TotalWages3306Calculation_Input) : TotalWages3306Calculation :=
  let main_output := match TotalWages3306Calculation_main_output_leaf_0 input with | some val => val | _ => default
  { main_output := main_output }

structure IndividualSection152Dependents_Input where
  marriage_events : (List MarriageEvent)
  income_events : (List IncomeEvent)
  tax_return_events : (List TaxReturnEvent)
  residence_period_events : (List ResidencePeriodEvent)
  birth_events : (List BirthEvent)
  family_relationship_events : (List FamilyRelationshipEvent)
  individuals : (List Individual)
  tax_year : Int
  taxpayer : Individual
  qualifying_children : (List IndividualSection152QualifyingChildOutput) := ((fun (potential_individuals : (List Individual)) => (List.map ((fun (individual : Individual) => ((individualSection152QualifyingChild ({ tax_return_events := tax_return_events, residence_period_events := residence_period_events, birth_events := birth_events, family_relationship_events := family_relationship_events, tax_year := tax_year, taxpayer := taxpayer, individual := individual } : IndividualSection152QualifyingChild_Input))).main_output)) potential_individuals)) (List.filter ((fun (individual : Individual) => (!(decide (individual = taxpayer))))) individuals))
  qualifying_relatives : (List IndividualSection152QualifyingRelativeOutput) := ((fun (potential_individuals : (List Individual)) => (List.map ((fun (individual : Individual) => ((individualSection152QualifyingRelative ({ marriage_events := marriage_events, income_events := income_events, tax_return_events := tax_return_events, qualifying_child_results := qualifying_children, residence_period_events := residence_period_events, family_relationship_events := family_relationship_events, tax_year := tax_year, taxpayer := taxpayer, individual := individual } : IndividualSection152QualifyingRelative_Input))).main_output)) potential_individuals)) (List.filter ((fun (individual : Individual) => (!(decide (individual = taxpayer))))) individuals))
  dependents_initial : (List Individual) := ((fun (qualifying_children_individuals : (List Individual)) => ((fun (qualifying_relatives_individuals : (List Individual)) => (qualifying_children_individuals ++ qualifying_relatives_individuals)) (List.map ((fun (result : IndividualSection152QualifyingRelativeOutput) => (result).individual)) (List.filter ((fun (result : IndividualSection152QualifyingRelativeOutput) => (result).is_qualifying_relative)) qualifying_relatives)))) (List.map ((fun (result : IndividualSection152QualifyingChildOutput) => (result).individual)) (List.filter ((fun (result : IndividualSection152QualifyingChildOutput) => (result).is_qualifying_child)) qualifying_children)))
  dependents_after_152b1 : (List Individual) := ((fun (initial_dependents : (List Individual)) => ((fun (is_dependent_of_another_taxpayer : Bool) => (if is_dependent_of_another_taxpayer then [] else initial_dependents)) (List.foldl ((fun (acc : Bool) (event : TaxReturnEvent) => (decide (acc) || ((!(decide ((event).individual = taxpayer))) && ((decide ((event).tax_year = tax_year)) && decide ((List.foldl ((fun (acc : Bool) (dependent : Individual) => (decide (acc) || (decide (dependent = taxpayer))))) false (event).dependents))))))) false tax_return_events))) ((fun (qualifying_children_individuals : (List Individual)) => ((fun (qualifying_relatives_individuals : (List Individual)) => (qualifying_children_individuals ++ qualifying_relatives_individuals)) (List.map ((fun (result : IndividualSection152QualifyingRelativeOutput) => (result).individual)) (List.filter ((fun (result : IndividualSection152QualifyingRelativeOutput) => (result).is_qualifying_relative)) qualifying_relatives)))) (List.map ((fun (result : IndividualSection152QualifyingChildOutput) => (result).individual)) (List.filter ((fun (result : IndividualSection152QualifyingChildOutput) => (result).is_qualifying_child)) qualifying_children))))
  dependents_after_152b2 : (List Individual) := ((fun (initial_dependents : (List Individual)) => ((fun (dependents_after_b1 : (List Individual)) => (List.filter ((fun (individual : Individual) => (!decide ((List.foldl ((fun (acc : Bool) (event : TaxReturnEvent) => (decide (acc) || ((decide ((event).individual = individual)) && ((decide ((event).tax_year = tax_year)) && decide ((event).filed_joint_return)))))) false tax_return_events))))) dependents_after_b1)) ((fun (is_dependent_of_another_taxpayer : Bool) => (if is_dependent_of_another_taxpayer then [] else initial_dependents)) (List.foldl ((fun (acc : Bool) (event : TaxReturnEvent) => (decide (acc) || ((!(decide ((event).individual = taxpayer))) && ((decide ((event).tax_year = tax_year)) && decide ((List.foldl ((fun (acc : Bool) (dependent : Individual) => (decide (acc) || (decide (dependent = taxpayer))))) false (event).dependents))))))) false tax_return_events)))) ((fun (qualifying_children_individuals : (List Individual)) => ((fun (qualifying_relatives_individuals : (List Individual)) => (qualifying_children_individuals ++ qualifying_relatives_individuals)) (List.map ((fun (result : IndividualSection152QualifyingRelativeOutput) => (result).individual)) (List.filter ((fun (result : IndividualSection152QualifyingRelativeOutput) => (result).is_qualifying_relative)) qualifying_relatives)))) (List.map ((fun (result : IndividualSection152QualifyingChildOutput) => (result).individual)) (List.filter ((fun (result : IndividualSection152QualifyingChildOutput) => (result).is_qualifying_child)) qualifying_children))))

def IndividualSection152Dependents_main_output_leaf_0 (input : IndividualSection152Dependents_Input) : Option IndividualSection152DependentsOutput :=
  some (({ taxpayer := input.taxpayer, dependents_initial := input.dependents_initial, dependents_after_152b1 := input.dependents_after_152b1, dependents_after_152b2 := input.dependents_after_152b2, qualifying_children := input.qualifying_children, qualifying_relatives := input.qualifying_relatives } : IndividualSection152DependentsOutput))

structure IndividualSection152Dependents where
  main_output : IndividualSection152DependentsOutput
deriving Repr, DecidableEq, Inhabited
def individualSection152Dependents (input : IndividualSection152Dependents_Input) : IndividualSection152Dependents :=
  let main_output := match IndividualSection152Dependents_main_output_leaf_0 input with | some val => val | _ => default
  { main_output := main_output }

structure EmploymentRelationshipEventSection3306Employment_Input where
  marriage_events : (List MarriageEvent)
  birth_events : (List BirthEvent)
  parenthood_events : (List ParenthoodEvent)
  immigration_admission_events : (List ImmigrationAdmissionEvent)
  hospital_patient_events : (List HospitalPatientEvent)
  student_enrollment_events : (List StudentEnrollmentEvent)
  employment_relationship_events : (List EmploymentRelationshipEvent)
  wage_payment_events : (List WagePaymentEvent)
  calendar_year : Int
  employment_relationship_event : EmploymentRelationshipEvent
  is_excluded_penal_institution : Bool := ((decide ((employment_relationship_event).employment_category = (EmploymentCategory.PenalInstitution ()))) || (decide (((employment_relationship_event).employer).organization_type = (OrganizationType.PenalInstitution ()))))
  is_excluded_international_organization : Bool := ((decide ((employment_relationship_event).employment_category = (EmploymentCategory.InternationalOrganization ()))) || (decide (((employment_relationship_event).employer).organization_type = (OrganizationType.InternationalOrganization ()))))
  is_excluded_foreign_government : Bool := ((decide ((employment_relationship_event).employment_category = (EmploymentCategory.ForeignGovernment ()))) || (decide (((employment_relationship_event).employer).organization_type = (OrganizationType.ForeignGovernment ()))))
  is_excluded_state_government : Bool := ((decide ((employment_relationship_event).employment_category = (EmploymentCategory.StateGovernment ()))) || (decide (((employment_relationship_event).employer).organization_type = (OrganizationType.GovernmentState ()))))
  is_excluded_federal_government : Bool := ((decide ((employment_relationship_event).employment_category = (EmploymentCategory.FederalGovernment ()))) || (decide (((employment_relationship_event).employer).organization_type = (OrganizationType.GovernmentFederal ()))))
  is_excluded_domestic_service : Bool := (if (decide ((employment_relationship_event).employment_category = (EmploymentCategory.DomesticService ()))) then ((fun (employer_local : Organization) => ((fun (employer_status : OrganizationSection3306EmployerStatusOutput) => ((fun (employer_is_domestic_service_employer : Bool) => (!decide (employer_is_domestic_service_employer))) (employer_status).is_domestic_service_employer)) ((organizationSection3306EmployerStatus ({ employment_relationship_events := employment_relationship_events, wage_payment_events := wage_payment_events, calendar_year := calendar_year, organization := employer_local } : OrganizationSection3306EmployerStatus_Input))).main_output)) (employment_relationship_event).employer) else false)
  is_excluded_student_nurse : Bool := (((decide ((employment_relationship_event).employment_category = (EmploymentCategory.Hospital ()))) || (decide ((employment_relationship_event).employment_category = (EmploymentCategory.SchoolCollegeUniversity ())))) && decide ((List.foldl ((fun (acc : Bool) (se : StudentEnrollmentEvent) => (decide (acc) || ((decide (((se).student).id = ((employment_relationship_event).employee).id)) && (decide ((se).is_regularly_attending) && ((decide ((se).start_date ≤ (Date_en.of_year_month_day calendar_year (12 : Int) (31 : Int)))) && (decide ((se).end_date ≥ (Date_en.of_year_month_day calendar_year (1 : Int) (1 : Int)))))))))) false student_enrollment_events)))
  is_excluded_hospital_patient_service : Bool := ((decide ((employment_relationship_event).employment_category = (EmploymentCategory.Hospital ()))) && decide ((List.foldl ((fun (acc : Bool) (hpe : HospitalPatientEvent) => (decide (acc) || ((decide (((hpe).patient).id = ((employment_relationship_event).employee).id)) && ((decide (((hpe).hospital).id = ((employment_relationship_event).employer).id)) && ((decide ((hpe).start_date ≤ (Date_en.of_year_month_day calendar_year (12 : Int) (31 : Int)))) && (decide ((hpe).end_date ≥ (Date_en.of_year_month_day calendar_year (1 : Int) (1 : Int)))))))))) false hospital_patient_events)))
  is_excluded_agricultural_labor : Bool := (if (decide ((employment_relationship_event).employment_category = (EmploymentCategory.AgriculturalLabor ()))) then ((fun (employer_local : Organization) => ((fun (employer_status : OrganizationSection3306EmployerStatusOutput) => ((fun (employer_is_agricultural_employer : Bool) => ((fun (is_h2a_alien : Bool) => ((!decide (employer_is_agricultural_employer)) || decide (is_h2a_alien))) (List.foldl ((fun (acc : Bool) (iae : ImmigrationAdmissionEvent) => (decide (acc) || ((decide (((iae).individual).id = ((employment_relationship_event).employee).id)) && (decide ((iae).visa_category = (VisaCategory.H2A ()))))))) false immigration_admission_events))) (employer_status).is_agricultural_employer)) ((organizationSection3306EmployerStatus ({ employment_relationship_events := employment_relationship_events, wage_payment_events := wage_payment_events, calendar_year := calendar_year, organization := employer_local } : OrganizationSection3306EmployerStatus_Input))).main_output)) (employment_relationship_event).employer) else false)
  is_excluded_student_service : Bool := ((decide ((employment_relationship_event).employment_category = (EmploymentCategory.SchoolCollegeUniversity ()))) && (decide ((List.foldl ((fun (acc : Bool) (se : StudentEnrollmentEvent) => (decide (acc) || ((decide (((se).student).id = ((employment_relationship_event).employee).id)) && ((decide (((se).institution).id = ((employment_relationship_event).employer).id)) && (decide ((se).is_regularly_attending) && ((decide ((se).start_date ≤ (Date_en.of_year_month_day calendar_year (12 : Int) (31 : Int)))) && (decide ((se).end_date ≥ (Date_en.of_year_month_day calendar_year (1 : Int) (1 : Int))))))))))) false student_enrollment_events)) || decide ((List.foldl ((fun (acc : Bool) (se : StudentEnrollmentEvent) => (decide (acc) || ((decide (((se).institution).id = ((employment_relationship_event).employer).id)) && (decide ((se).is_regularly_attending) && ((decide ((se).start_date ≤ (Date_en.of_year_month_day calendar_year (12 : Int) (31 : Int)))) && ((decide ((se).end_date ≥ (Date_en.of_year_month_day calendar_year (1 : Int) (1 : Int)))) && decide ((List.foldl ((fun (acc : Bool) (me : MarriageEvent) => (decide (acc) || ((((decide (((me).spouse1).id = ((se).student).id)) && (decide (((me).spouse2).id = ((employment_relationship_event).employee).id))) || ((decide (((me).spouse2).id = ((se).student).id)) && (decide (((me).spouse1).id = ((employment_relationship_event).employee).id)))) && (decide ((me).marriage_date ≤ (employment_relationship_event).end_date)))))) false marriage_events))))))))) false student_enrollment_events))))
  is_excluded_family_employment : Bool := ((fun (employee_local : Individual) => ((fun (employer_local : Organization) => ((fun (employee_is_parent_of_employer : Bool) => ((fun (employee_is_spouse_of_employer : Bool) => ((fun (is_son_daughter_or_spouse : Bool) => ((fun (is_child_under_21 : Bool) => (decide (is_son_daughter_or_spouse) || decide (is_child_under_21))) (List.foldl ((fun (acc : Bool) (pe : ParenthoodEvent) => (decide (acc) || ((decide (((pe).parent).id = (employer_local).id)) && ((decide (((pe).child).id = (employee_local).id)) && (((decide ((pe).parent_type = (ParentType.Biological ()))) || (decide ((pe).parent_type = (ParentType.Adoptive ())))) && decide ((List.foldl ((fun (acc : Bool) (be : BirthEvent) => (decide (acc) || ((decide (((be).individual).id = (employee_local).id)) && decide ((Date_en.is_young_enough_rounding_down (be).birth_date (CatalaRuntime.Duration.create 21 0 0) (Date_en.of_year_month_day calendar_year (12 : Int) (31 : Int)))))))) false birth_events)))))))) false parenthood_events))) (decide (employee_is_parent_of_employer) || decide (employee_is_spouse_of_employer)))) (List.foldl ((fun (acc : Bool) (me : MarriageEvent) => (decide (acc) || ((((decide (((me).spouse1).id = (employee_local).id)) && (decide (((me).spouse2).id = (employer_local).id))) || ((decide (((me).spouse2).id = (employee_local).id)) && (decide (((me).spouse1).id = (employer_local).id)))) && (decide ((me).marriage_date ≤ (employment_relationship_event).end_date)))))) false marriage_events))) (List.foldl ((fun (acc : Bool) (pe : ParenthoodEvent) => (decide (acc) || ((decide (((pe).parent).id = (employee_local).id)) && ((decide (((pe).child).id = (employer_local).id)) && ((decide ((pe).parent_type = (ParentType.Biological ()))) || (decide ((pe).parent_type = (ParentType.Adoptive ()))))))))) false parenthood_events))) (employment_relationship_event).employer)) (employment_relationship_event).employee)
  is_employment : Bool := ((fun (is_within_us : Bool) => ((fun (is_outside_us_by_us_citizen : Bool) => ((decide (is_within_us) || decide (is_outside_us_by_us_citizen)) && ((!decide (is_excluded_agricultural_labor)) && ((!decide (is_excluded_domestic_service)) && ((!decide (is_excluded_family_employment)) && ((!decide (is_excluded_federal_government)) && ((!decide (is_excluded_state_government)) && ((!decide (is_excluded_student_service)) && ((!decide (is_excluded_hospital_patient_service)) && ((!decide (is_excluded_foreign_government)) && ((!decide (is_excluded_student_nurse)) && ((!decide (is_excluded_international_organization)) && (!decide (is_excluded_penal_institution)))))))))))))) ((decide ((employment_relationship_event).service_location = (ServiceLocation.OutsideUnitedStates ()))) && (decide ((employment_relationship_event).employee_is_us_citizen) && decide ((employment_relationship_event).is_american_employer))))) (decide ((employment_relationship_event).service_location = (ServiceLocation.WithinUnitedStates ()))))

def EmploymentRelationshipEventSection3306Employment_main_output_leaf_0 (input : EmploymentRelationshipEventSection3306Employment_Input) : Option EmploymentRelationshipEventSection3306EmploymentOutput :=
  some (({ employment_relationship_event := input.employment_relationship_event, is_employment := input.is_employment, is_excluded_agricultural_labor := input.is_excluded_agricultural_labor, is_excluded_domestic_service := input.is_excluded_domestic_service, is_excluded_family_employment := input.is_excluded_family_employment, is_excluded_federal_government := input.is_excluded_federal_government, is_excluded_state_government := input.is_excluded_state_government, is_excluded_student_service := input.is_excluded_student_service, is_excluded_hospital_patient_service := input.is_excluded_hospital_patient_service, is_excluded_foreign_government := input.is_excluded_foreign_government, is_excluded_student_nurse := input.is_excluded_student_nurse, is_excluded_international_organization := input.is_excluded_international_organization, is_excluded_penal_institution := input.is_excluded_penal_institution } : EmploymentRelationshipEventSection3306EmploymentOutput))

structure EmploymentRelationshipEventSection3306Employment where
  main_output : EmploymentRelationshipEventSection3306EmploymentOutput
deriving Repr, DecidableEq, Inhabited
def employmentRelationshipEventSection3306Employment (input : EmploymentRelationshipEventSection3306Employment_Input) : EmploymentRelationshipEventSection3306Employment :=
  let main_output := match EmploymentRelationshipEventSection3306Employment_main_output_leaf_0 input with | some val => val | _ => default
  { main_output := main_output }

structure EmployerUnemploymentExciseTaxFilerSection3301Tax_Input where
  employment_relationship_employment_results : (List EmploymentRelationshipEventSection3306EmploymentOutput)
  organization_employer_statuses : (List OrganizationSection3306EmployerStatusOutput)
  wage_payment_wages_results : (List WagePaymentEventSection3306WagesOutput)
  employer_unemployment_excise_tax_return : EmployerUnemploymentExciseTaxReturn
  tax_rate : Rat := (Rat.mk 3 50)
  total_taxable_wages : CatalaRuntime.Money := (match (match processExceptions [if ((fun (employer_local : Organization) => (!decide ((List.foldl ((fun (acc : Bool) (org_status : OrganizationSection3306EmployerStatusOutput) => (decide (acc) || ((decide (((org_status).organization).id = (employer_local).id)) && decide ((org_status).is_employer))))) false organization_employer_statuses)))) (match (employer_unemployment_excise_tax_return).details with | EmployerVariant.GeneralEmployer variant => (variant).employer| EmployerVariant.AgriculturalEmployer variant => (variant).employer| EmployerVariant.DomesticServiceEmployer variant => (variant).employer)) then some ((CatalaRuntime.Money.ofCents 0)) else none] with | none => some (((fun (employer_local : Organization) => ((fun (wages_for_employer : (List WagePaymentEventSection3306WagesOutput)) => ((fun (wages_for_employment : (List WagePaymentEventSection3306WagesOutput)) => ((fun (unique_employee_wage_results : (List WagePaymentEventSection3306WagesOutput)) => ((fun (unique_employee_ids : (List Int)) => (match (List.map ((fun (emp_id_local : Int) => ((fun (employee_wages : (List WagePaymentEventSection3306WagesOutput)) => (((totalWages3306Calculation ({ wage_results := employee_wages } : TotalWages3306Calculation_Input))).main_output).total_taxable_wages) (List.filter ((fun (wage_result : WagePaymentEventSection3306WagesOutput) => (decide ((((wage_result).wage_payment_event).employee).id = emp_id_local)))) wages_for_employment)))) unique_employee_ids) with | [] => (fun () => (CatalaRuntime.Money.ofCents 0)) () | x0 :: xn => List.foldl (fun (sum1 : CatalaRuntime.Money) (sum2 : CatalaRuntime.Money) => (sum1 + sum2)) x0 xn)) (List.map ((fun (wage_result : WagePaymentEventSection3306WagesOutput) => (((wage_result).wage_payment_event).employee).id)) unique_employee_wage_results))) (List.filter ((fun (wage_result : WagePaymentEventSection3306WagesOutput) => (!decide ((List.foldl ((fun (acc : Bool) (prev_wage_result : WagePaymentEventSection3306WagesOutput) => (decide (acc) || ((decide ((((prev_wage_result).wage_payment_event).employee).id = (((wage_result).wage_payment_event).employee).id)) && (decide (((prev_wage_result).wage_payment_event).id < ((wage_result).wage_payment_event).id)))))) false wages_for_employment))))) wages_for_employment))) (List.filter ((fun (wage_result : WagePaymentEventSection3306WagesOutput) => (List.foldl ((fun (acc : Bool) (emp_result : EmploymentRelationshipEventSection3306EmploymentOutput) => (decide (acc) || ((decide ((((emp_result).employment_relationship_event).employer).id = (((wage_result).wage_payment_event).employer).id)) && ((decide ((((emp_result).employment_relationship_event).employee).id = (((wage_result).wage_payment_event).employee).id)) && ((decide (((emp_result).employment_relationship_event).start_date ≤ ((wage_result).wage_payment_event).payment_date)) && (((decide ((Date_en.get_year ((emp_result).employment_relationship_event).start_date) = (employer_unemployment_excise_tax_return).tax_year)) || (decide ((Date_en.get_year ((emp_result).employment_relationship_event).end_date) = (employer_unemployment_excise_tax_return).tax_year))) && decide ((emp_result).is_employment)))))))) false employment_relationship_employment_results))) wages_for_employer))) (List.filter ((fun (wage_result : WagePaymentEventSection3306WagesOutput) => ((decide ((((wage_result).wage_payment_event).employer).id = (employer_local).id)) && (decide ((Date_en.get_year ((wage_result).wage_payment_event).payment_date) = (employer_unemployment_excise_tax_return).tax_year))))) wage_payment_wages_results))) (match (employer_unemployment_excise_tax_return).details with | EmployerVariant.GeneralEmployer variant => (variant).employer| EmployerVariant.AgriculturalEmployer variant => (variant).employer| EmployerVariant.DomesticServiceEmployer variant => (variant).employer))) | some r => some r) with | some r => r | _ => default)
  excise_tax : CatalaRuntime.Money := (CatalaRuntime.multiply total_taxable_wages tax_rate)

def EmployerUnemploymentExciseTaxFilerSection3301Tax_main_output_leaf_0 (input : EmployerUnemploymentExciseTaxFilerSection3301Tax_Input) : Option EmployerUnemploymentExciseTaxFilerSection3301TaxOutput :=
  some (({ employer_unemployment_excise_tax_return := input.employer_unemployment_excise_tax_return, total_taxable_wages := input.total_taxable_wages, excise_tax := input.excise_tax, tax_rate := input.tax_rate } : EmployerUnemploymentExciseTaxFilerSection3301TaxOutput))

structure EmployerUnemploymentExciseTaxFilerSection3301Tax where
  tax_rate : Rat
  total_taxable_wages : CatalaRuntime.Money
  excise_tax : CatalaRuntime.Money
  main_output : EmployerUnemploymentExciseTaxFilerSection3301TaxOutput
deriving Repr, DecidableEq, Inhabited
def employerUnemploymentExciseTaxFilerSection3301Tax (input : EmployerUnemploymentExciseTaxFilerSection3301Tax_Input) : EmployerUnemploymentExciseTaxFilerSection3301Tax :=
  let main_output := match EmployerUnemploymentExciseTaxFilerSection3301Tax_main_output_leaf_0 input with | some val => val | _ => default
  { tax_rate := input.tax_rate,
    total_taxable_wages := input.total_taxable_wages,
    excise_tax := input.excise_tax,
    main_output := main_output }

structure IndividualSection151Exemption_Input where
  individuals_entitled_to_exemptions_under_151 : (List Individual)
  applicable_amount : CatalaRuntime.Money
  adjusted_gross_income : CatalaRuntime.Money
  tax_return_events : (List TaxReturnEvent)
  tax_year : Int
  individual_tax_return : IndividualTaxReturn
  individual : Individual
  exemption_amount_base : CatalaRuntime.Money := (CatalaRuntime.Money.ofCents 200000)
  applicable_percentage : Rat := (if (decide (adjusted_gross_income > applicable_amount)) then ((fun (excess_agi : CatalaRuntime.Money) => ((fun (threshold : CatalaRuntime.Money) => ((fun (excess_decimal : Rat) => ((fun (threshold_decimal : Rat) => ((fun (fraction_count_decimal : Rat) => ((fun (fraction_count : Rat) => (Decimal_en.min (CatalaRuntime.multiply fraction_count (Rat.mk 1 50)) (Rat.mk 1 1))) (if (decide (fraction_count_decimal > (CatalaRuntime.toRat (Rat.floor fraction_count_decimal)))) then (CatalaRuntime.toRat ((Rat.floor fraction_count_decimal) + (1 : Int))) else (CatalaRuntime.toRat (Rat.floor fraction_count_decimal))))) (excess_decimal / threshold_decimal))) (CatalaRuntime.toRat threshold))) (CatalaRuntime.toRat excess_agi))) (match (individual_tax_return).details with | FilingStatusVariant.JointReturn _ => (CatalaRuntime.Money.ofCents 250000)| FilingStatusVariant.SurvivingSpouse _ => (CatalaRuntime.Money.ofCents 250000)| FilingStatusVariant.HeadOfHousehold _ => (CatalaRuntime.Money.ofCents 250000)| FilingStatusVariant.Single _ => (CatalaRuntime.Money.ofCents 250000)| FilingStatusVariant.MarriedFilingSeparate variant => (CatalaRuntime.Money.ofCents 125000)))) (adjusted_gross_income - applicable_amount)) else (Rat.mk 0 1))
  number_of_personal_exemptions : Int := (individuals_entitled_to_exemptions_under_151).length
  exemption_amount_after_disallowance : CatalaRuntime.Money := ((fun (taxpayer_is_dependent_of_another : Bool) => (if taxpayer_is_dependent_of_another then (CatalaRuntime.Money.ofCents 0) else exemption_amount_base)) (List.foldl ((fun (acc : Bool) (event : TaxReturnEvent) => (decide (acc) || ((!(decide ((event).individual = individual))) && ((decide ((event).tax_year = tax_year)) && decide ((List.foldl ((fun (acc : Bool) (dependent : Individual) => (decide (acc) || (decide (dependent = individual))))) false (event).dependents))))))) false tax_return_events))
  exemption_amount_after_phaseout : CatalaRuntime.Money := (match (match processExceptions [if (is_tax_year_2018_through_2025 tax_year) then some ((CatalaRuntime.Money.ofCents 0)) else none] with | none => some ((if (decide (adjusted_gross_income > applicable_amount)) then ((fun (reduction : CatalaRuntime.Money) => (exemption_amount_after_disallowance - reduction)) (CatalaRuntime.toMoney (CatalaRuntime.multiply (CatalaRuntime.toRat exemption_amount_after_disallowance) applicable_percentage))) else exemption_amount_after_disallowance)) | some r => some r) with | some r => r | _ => default)
  personal_exemptions_deduction : CatalaRuntime.Money := ((fun (n : Rat) => (CatalaRuntime.toMoney (CatalaRuntime.multiply n (CatalaRuntime.toRat exemption_amount_after_phaseout)))) (CatalaRuntime.toRat number_of_personal_exemptions))

def IndividualSection151Exemption_main_output_leaf_0 (input : IndividualSection151Exemption_Input) : Option IndividualSection151ExemptionOutput :=
  some (({ individual := input.individual, exemption_amount_base := input.exemption_amount_base, exemption_amount_after_disallowance := input.exemption_amount_after_disallowance, exemption_amount_after_phaseout := input.exemption_amount_after_phaseout, number_of_personal_exemptions := input.number_of_personal_exemptions, personal_exemptions_deduction := input.personal_exemptions_deduction, applicable_percentage := input.applicable_percentage } : IndividualSection151ExemptionOutput))

structure IndividualSection151Exemption where
  main_output : IndividualSection151ExemptionOutput
deriving Repr, DecidableEq, Inhabited
def individualSection151Exemption (input : IndividualSection151Exemption_Input) : IndividualSection151Exemption :=
  let main_output := match IndividualSection151Exemption_main_output_leaf_0 input with | some val => val | _ => default
  { main_output := main_output }

structure TaxpayerExemptionsList_Input where
  dependents : (List Individual)
  income_events : (List IncomeEvent)
  tax_return_events : (List TaxReturnEvent)
  individual_tax_return : IndividualTaxReturn
  spouse_result : (Optional IndividualSection151ExemptionsListOutput) := (match (individual_tax_return).details with | FilingStatusVariant.JointReturn variant => ((fun (spouse_local : (Optional Individual)) => ((fun (spouse_result_inner : (Optional IndividualSection151ExemptionsListOutput)) => spouse_result_inner) (match spouse_local with | Optional.Absent _ => (Optional.Absent ())| Optional.Present s => ((fun (taxpayer_local : Individual) => ((fun (spouse_result_scope : IndividualSection151ExemptionsList) => (Optional.Present (spouse_result_scope).main_output)) (individualSection151ExemptionsList ({ is_joint_or_surviving_spouse := true, dependents := dependents, income_events := income_events, tax_return_events := tax_return_events, tax_year := (individual_tax_return).tax_year, spouse := (Optional.Present taxpayer_local), individual := s } : IndividualSection151ExemptionsList_Input)))) (get_taxpayer individual_tax_return))))) (get_spouse individual_tax_return))| FilingStatusVariant.SurvivingSpouse variant => (Optional.Absent ())| FilingStatusVariant.HeadOfHousehold variant => (Optional.Absent ())| FilingStatusVariant.Single variant => (Optional.Absent ())| FilingStatusVariant.MarriedFilingSeparate variant => (Optional.Absent ()))
  taxpayer_exemptions : IndividualSection151ExemptionsList := individualSection151ExemptionsList { individual := (get_taxpayer individual_tax_return), spouse := (get_spouse individual_tax_return), tax_year := (individual_tax_return).tax_year, tax_return_events := tax_return_events, income_events := income_events, dependents := dependents, is_joint_or_surviving_spouse := (match (individual_tax_return).details with | FilingStatusVariant.JointReturn variant => true| FilingStatusVariant.SurvivingSpouse variant => true| FilingStatusVariant.HeadOfHousehold variant => false| FilingStatusVariant.Single variant => false| FilingStatusVariant.MarriedFilingSeparate variant => false) }
  spouse_personal_exemption_allowed : Bool := ((taxpayer_exemptions).main_output).spouse_personal_exemption_allowed
  individuals_entitled_to_exemptions_under_151 : (List Individual) := ((fun (taxpayer_list : (List Individual)) => ((fun (spouse_unique_list : (List Individual)) => (taxpayer_list ++ spouse_unique_list)) (match spouse_result with | Optional.Absent _ => []| Optional.Present s_result => (List.filter ((fun (individual : Individual) => (!decide ((List.foldl ((fun (acc : Bool) (taxpayer_individual : Individual) => (decide (acc) || (decide (taxpayer_individual = individual))))) false taxpayer_list))))) (s_result).individuals_entitled_to_exemptions_under_151)))) ((taxpayer_exemptions).main_output).individuals_entitled_to_exemptions_under_151)

def TaxpayerExemptionsList_main_output_leaf_0 (input : TaxpayerExemptionsList_Input) (taxpayer_exemptions : IndividualSection151ExemptionsList) : Option TaxpayerExemptionsListOutput :=
  some (({ taxpayer_result := (taxpayer_exemptions).main_output, spouse_result := input.spouse_result, individuals_entitled_to_exemptions_under_151 := input.individuals_entitled_to_exemptions_under_151, spouse_personal_exemption_allowed := input.spouse_personal_exemption_allowed } : TaxpayerExemptionsListOutput))

structure TaxpayerExemptionsList where
  main_output : TaxpayerExemptionsListOutput
deriving Repr, DecidableEq, Inhabited
def taxpayerExemptionsList (input : TaxpayerExemptionsList_Input) : TaxpayerExemptionsList :=
  let taxpayer_exemptions := individualSection151ExemptionsList { individual := (get_taxpayer input.individual_tax_return), spouse := (get_spouse input.individual_tax_return), tax_year := (input.individual_tax_return).tax_year, tax_return_events := input.tax_return_events, income_events := input.income_events, dependents := input.dependents, is_joint_or_surviving_spouse := (match (input.individual_tax_return).details with | FilingStatusVariant.JointReturn variant => true| FilingStatusVariant.SurvivingSpouse variant => true| FilingStatusVariant.HeadOfHousehold variant => false| FilingStatusVariant.Single variant => false| FilingStatusVariant.MarriedFilingSeparate variant => false) }
  let main_output := match TaxpayerExemptionsList_main_output_leaf_0 input taxpayer_exemptions with | some val => val | _ => default
  { main_output := main_output }

structure IRCSimplified_Input where
  employer_unemployment_excise_tax_return : EmployerUnemploymentExciseTaxReturn
  employment_termination_events : (List EmploymentTerminationEvent)
  immigration_admission_events : (List ImmigrationAdmissionEvent)
  hospital_patient_events : (List HospitalPatientEvent)
  student_enrollment_events : (List StudentEnrollmentEvent)
  wage_payment_events : (List WagePaymentEvent)
  employment_relationship_events : (List EmploymentRelationshipEvent)
  income_events : (List IncomeEvent)
  tax_return_events : (List TaxReturnEvent)
  family_relationship_events : (List FamilyRelationshipEvent)
  parenthood_events : (List ParenthoodEvent)
  household_maintenance_events : (List HouseholdMaintenanceEvent)
  residence_period_events : (List ResidencePeriodEvent)
  divorce_or_legal_separation_events : (List DivorceOrLegalSeparationEvent)
  remarriage_events : (List RemarriageEvent)
  marriage_events : (List MarriageEvent)
  nonresident_alien_status_period_events : (List NonresidentAlienStatusPeriodEvent)
  death_events : (List DeathEvent)
  blindness_status_events : (List BlindnessStatusEvent)
  birth_events : (List BirthEvent)
  organizations : (List Organization)
  individuals : (List Individual)
  individual_tax_return : IndividualTaxReturn
  itemized_deductions : CatalaRuntime.Money := (CatalaRuntime.Money.ofCents 0)
  adjusted_gross_income : CatalaRuntime.Money
  section_2_a_1_A_spouse_died_in_preceding_two_years : Bool := ((fun (spouse_local : (Optional Individual)) => (match spouse_local with | Optional.Absent _ => false| Optional.Present s => (List.foldl ((fun (acc : Bool) (death_event : DeathEvent) => (decide (acc) || ((decide ((death_event).decedent = s)) && ((decide ((Date_en.get_year (death_event).death_date) ≥ ((individual_tax_return).tax_year - (2 : Int)))) && (decide ((Date_en.get_year (death_event).death_date) < (individual_tax_return).tax_year))))))) false death_events))) (get_spouse individual_tax_return))
  section_2_a_2_B_joint_return_could_have_been_made : Bool := ((fun (spouse_local : (Optional Individual)) => ((fun (taxpayer_local : Individual) => ((fun (spouse_death_events_in_window_local : (List DeathEvent)) => ((fun (spouse_death_year_local : (Optional Int)) => (match spouse_death_year_local with | Optional.Absent _ => false| Optional.Present death_year => ((!decide ((List.foldl ((fun (acc : Bool) (residency_event_taxpayer : NonresidentAlienStatusPeriodEvent) => (decide (acc) || ((decide ((residency_event_taxpayer).individual = taxpayer_local)) && ((decide ((residency_event_taxpayer).residency_status = (ResidencyStatus.NonresidentAlien ()))) && ((decide ((residency_event_taxpayer).start_date ≤ (Date_en.of_year_month_day death_year (12 : Int) (31 : Int)))) && (decide ((residency_event_taxpayer).end_date ≥ (Date_en.of_year_month_day death_year (1 : Int) (1 : Int)))))))))) false nonresident_alien_status_period_events))) && (!(match spouse_local with | Optional.Absent _ => false| Optional.Present s => (List.foldl ((fun (acc : Bool) (residency_event_spouse : NonresidentAlienStatusPeriodEvent) => (decide (acc) || ((decide ((residency_event_spouse).individual = s)) && ((decide ((residency_event_spouse).residency_status = (ResidencyStatus.NonresidentAlien ()))) && ((decide ((residency_event_spouse).start_date ≤ (Date_en.of_year_month_day death_year (12 : Int) (31 : Int)))) && (decide ((residency_event_spouse).end_date ≥ (Date_en.of_year_month_day death_year (1 : Int) (1 : Int)))))))))) false nonresident_alien_status_period_events)))))) (section_2_spouse_death_year spouse_death_events_in_window_local))) (section_2_spouse_death_events_in_window spouse_local death_events (individual_tax_return).tax_year))) (get_taxpayer individual_tax_return))) (get_spouse individual_tax_return))
  section_2_a_2_A_taxpayer_has_remarried : Bool := ((fun (spouse_local : (Optional Individual)) => ((fun (spouse_death_events_in_window_local : (List DeathEvent)) => ((fun (most_recent_spouse_death_date_local : CatalaRuntime.Date) => (List.foldl ((fun (acc : Bool) (remarriage_event : RemarriageEvent) => (decide (acc) || ((decide ((remarriage_event).individual = (get_taxpayer individual_tax_return))) && ((decide ((remarriage_event).remarriage_date > most_recent_spouse_death_date_local)) && (decide ((remarriage_event).remarriage_date ≤ (get_year_end (individual_tax_return).tax_year)))))))) false remarriage_events)) (section_2_most_recent_spouse_death_date spouse_death_events_in_window_local (individual_tax_return).tax_year))) (section_2_spouse_death_events_in_window spouse_local death_events (individual_tax_return).tax_year))) (get_spouse individual_tax_return))
  section_2_b_1_A_i_I_qualifying_child_is_married_at_close_of_year : Bool := ((fun (year_end_local : CatalaRuntime.Date) => (match (individual_tax_return).details with | FilingStatusVariant.JointReturn variant => false| FilingStatusVariant.SurvivingSpouse variant => false| FilingStatusVariant.HeadOfHousehold variant => (List.foldl ((fun (acc : Bool) (marriage_event : MarriageEvent) => (decide (acc) || (((decide ((marriage_event).spouse1 = (variant).qualifying_person)) || (decide ((marriage_event).spouse2 = (variant).qualifying_person))) && ((decide ((marriage_event).marriage_date ≤ year_end_local)) && (!decide ((List.foldl ((fun (acc : Bool) (divorce_event : DivorceOrLegalSeparationEvent) => (decide (acc) || (((decide ((divorce_event).person1 = (variant).qualifying_person)) || (decide ((divorce_event).person2 = (variant).qualifying_person))) && ((decide ((divorce_event).decree_date > (marriage_event).marriage_date)) && (decide ((divorce_event).decree_date ≤ year_end_local))))))) false divorce_or_legal_separation_events)))))))) false marriage_events)| FilingStatusVariant.Single variant => false| FilingStatusVariant.MarriedFilingSeparate variant => false)) (get_year_end (individual_tax_return).tax_year))
  section_2_b_2_is_married_at_close_of_year : Bool := ((fun (spouse_local : (Optional Individual)) => ((fun (taxpayer_local : Individual) => ((fun (year_end_local : CatalaRuntime.Date) => (match spouse_local with | Optional.Absent _ => false| Optional.Present s => (if (List.foldl ((fun (acc : Bool) (divorce_event : DivorceOrLegalSeparationEvent) => (decide (acc) || (((decide ((divorce_event).person1 = taxpayer_local)) || (decide ((divorce_event).person2 = taxpayer_local))) && (((decide ((divorce_event).person1 = s)) || (decide ((divorce_event).person2 = s))) && (decide ((divorce_event).decree_date ≤ year_end_local))))))) false divorce_or_legal_separation_events) then false else (if (List.foldl ((fun (acc : Bool) (residency_event : NonresidentAlienStatusPeriodEvent) => (decide (acc) || ((decide ((residency_event).individual = s)) && ((decide ((residency_event).start_date ≤ year_end_local)) && ((decide ((residency_event).end_date ≥ (Date_en.of_year_month_day (individual_tax_return).tax_year (1 : Int) (1 : Int)))) && (decide ((residency_event).residency_status = (ResidencyStatus.NonresidentAlien ()))))))))) false nonresident_alien_status_period_events) then false else (if (List.foldl ((fun (acc : Bool) (death_event : DeathEvent) => (decide (acc) || ((decide ((death_event).decedent = s)) && ((decide ((Date_en.get_year (death_event).death_date) = (individual_tax_return).tax_year)) && (!decide ((List.foldl ((fun (acc : Bool) (residency_event : NonresidentAlienStatusPeriodEvent) => (decide (acc) || ((decide ((residency_event).individual = s)) && ((decide ((residency_event).start_date ≤ (death_event).death_date)) && ((decide ((residency_event).end_date ≥ (Date_en.of_year_month_day (individual_tax_return).tax_year (1 : Int) (1 : Int)))) && (decide ((residency_event).residency_status = (ResidencyStatus.NonresidentAlien ()))))))))) false nonresident_alien_status_period_events)))))))) false death_events) then true else (List.foldl ((fun (acc : Bool) (marriage_event : MarriageEvent) => (decide (acc) || (((decide ((marriage_event).spouse1 = taxpayer_local)) || (decide ((marriage_event).spouse2 = taxpayer_local))) && (((decide ((marriage_event).spouse1 = s)) || (decide ((marriage_event).spouse2 = s))) && ((decide ((marriage_event).marriage_date ≤ year_end_local)) && (!decide ((List.foldl ((fun (acc : Bool) (divorce_event : DivorceOrLegalSeparationEvent) => (decide (acc) || (((decide ((divorce_event).person1 = taxpayer_local)) || (decide ((divorce_event).person2 = taxpayer_local))) && (((decide ((divorce_event).person1 = s)) || (decide ((divorce_event).person2 = s))) && ((decide ((divorce_event).decree_date > (marriage_event).marriage_date)) && (decide ((divorce_event).decree_date ≤ year_end_local)))))))) false divorce_or_legal_separation_events))))))))) false marriage_events)))))) (get_year_end (individual_tax_return).tax_year))) (get_taxpayer individual_tax_return))) (get_spouse individual_tax_return))
  taxpayer_dependents : IndividualSection152Dependents := individualSection152Dependents { taxpayer := (get_taxpayer individual_tax_return), tax_year := (individual_tax_return).tax_year, individuals := individuals, family_relationship_events := family_relationship_events, birth_events := birth_events, residence_period_events := residence_period_events, tax_return_events := tax_return_events, income_events := income_events, marriage_events := marriage_events }
  wage_payment_wages_results : (List WagePaymentEventSection3306WagesOutput) := (List.map ((fun (wage_event : WagePaymentEvent) => ((wagePaymentEventSection3306Wages ({ death_events := death_events, employment_termination_events := employment_termination_events, wage_payment_event := wage_event } : WagePaymentEventSection3306Wages_Input))).main_output)) wage_payment_events)
  employment_relationship_employment_results : (List EmploymentRelationshipEventSection3306EmploymentOutput) := (List.map ((fun (emp_event : EmploymentRelationshipEvent) => ((employmentRelationshipEventSection3306Employment ({ marriage_events := marriage_events, birth_events := birth_events, parenthood_events := parenthood_events, immigration_admission_events := immigration_admission_events, hospital_patient_events := hospital_patient_events, student_enrollment_events := student_enrollment_events, employment_relationship_events := employment_relationship_events, wage_payment_events := wage_payment_events, calendar_year := (employer_unemployment_excise_tax_return).tax_year, employment_relationship_event := emp_event } : EmploymentRelationshipEventSection3306Employment_Input))).main_output)) employment_relationship_events)
  organization_employer_statuses : (List OrganizationSection3306EmployerStatusOutput) := ((fun (organizations_with_events : (List Organization)) => (List.map ((fun (organization : Organization) => ((organizationSection3306EmployerStatus ({ employment_relationship_events := employment_relationship_events, wage_payment_events := wage_payment_events, calendar_year := (employer_unemployment_excise_tax_return).tax_year, organization := organization } : OrganizationSection3306EmployerStatus_Input))).main_output)) organizations_with_events)) (List.filter ((fun (org : Organization) => (List.foldl ((fun (acc : Bool) (wage_event : WagePaymentEvent) => (decide (acc) || ((decide (((wage_event).employer).id = (org).id)) || decide ((List.foldl ((fun (acc : Bool) (emp_event : EmploymentRelationshipEvent) => (decide (acc) || (decide (((emp_event).employer).id = (org).id))))) false employment_relationship_events)))))) false wage_payment_events))) organizations))
  section_68_eighty_percent_reduction : CatalaRuntime.Money := (CatalaRuntime.multiply itemized_deductions (Rat.mk 4 5))
  taxpayer_dependents_result : IndividualSection152DependentsOutput := (taxpayer_dependents).main_output
  employer_unemployment_excise_tax : EmployerUnemploymentExciseTaxFilerSection3301Tax := employerUnemploymentExciseTaxFilerSection3301Tax { employer_unemployment_excise_tax_return := employer_unemployment_excise_tax_return, wage_payment_wages_results := wage_payment_wages_results, organization_employer_statuses := organization_employer_statuses, employment_relationship_employment_results := employment_relationship_employment_results }
  taxpayer_exemptions_list : TaxpayerExemptionsList := taxpayerExemptionsList { individual_tax_return := individual_tax_return, tax_return_events := tax_return_events, income_events := income_events, dependents := (taxpayer_dependents_result).dependents_after_152b2 }
  section_2_b_1_A_i_II_qualifying_person_not_dependent_by_152b2 : Bool := (match (individual_tax_return).details with | FilingStatusVariant.JointReturn variant => false| FilingStatusVariant.SurvivingSpouse variant => false| FilingStatusVariant.HeadOfHousehold variant => (List.foldl ((fun (acc : Bool) (dependent_individual : Individual) => (decide (acc) || ((decide (dependent_individual = (variant).qualifying_person)) && (!decide ((List.foldl ((fun (acc : Bool) (dependent_individual_final : Individual) => (decide (acc) || (decide (dependent_individual_final = (variant).qualifying_person))))) false (taxpayer_dependents_result).dependents_after_152b2))))))) false (taxpayer_dependents_result).dependents_after_152b1)| FilingStatusVariant.Single variant => false| FilingStatusVariant.MarriedFilingSeparate variant => false)
  employer_unemployment_excise_tax_result : EmployerUnemploymentExciseTaxFilerSection3301TaxOutput := (employer_unemployment_excise_tax).main_output
  taxpayer_exemptions_list_result : TaxpayerExemptionsListOutput := (taxpayer_exemptions_list).main_output
  section_2_b_1_A_i_satisfied : Bool := (match (individual_tax_return).details with | FilingStatusVariant.JointReturn variant => false| FilingStatusVariant.SurvivingSpouse variant => false| FilingStatusVariant.HeadOfHousehold variant => ((fun (qualifying_person_is_qualifying_child_local : Bool) => (decide (qualifying_person_is_qualifying_child_local) && (!(decide (section_2_b_1_A_i_I_qualifying_child_is_married_at_close_of_year) && decide (section_2_b_1_A_i_II_qualifying_person_not_dependent_by_152b2))))) ((fun (result : IndividualSection152QualifyingChild) => ((result).main_output).is_qualifying_child) (individualSection152QualifyingChild ({ tax_return_events := tax_return_events, residence_period_events := residence_period_events, birth_events := birth_events, family_relationship_events := family_relationship_events, tax_year := (individual_tax_return).tax_year, taxpayer := (get_taxpayer individual_tax_return), individual := (variant).qualifying_person } : IndividualSection152QualifyingChild_Input))))| FilingStatusVariant.Single variant => false| FilingStatusVariant.MarriedFilingSeparate variant => false)
  taxpayer_marital_status : IndividualSection7703MaritalStatus := individualSection7703MaritalStatus { individual := (match (individual_tax_return).details with | FilingStatusVariant.JointReturn variant => (variant).taxpayer| FilingStatusVariant.SurvivingSpouse variant => (variant).taxpayer| FilingStatusVariant.HeadOfHousehold variant => (variant).taxpayer| FilingStatusVariant.Single variant => (variant).taxpayer| FilingStatusVariant.MarriedFilingSeparate variant => (variant).taxpayer), tax_year := (individual_tax_return).tax_year, marriage_events := marriage_events, divorce_or_legal_separation_events := divorce_or_legal_separation_events, death_events := death_events, individual_tax_return := individual_tax_return, residence_period_events := residence_period_events, household_maintenance_events := household_maintenance_events, qualifying_children := (taxpayer_dependents_result).qualifying_children, individuals_entitled_to_exemptions_under_151 := (taxpayer_exemptions_list_result).individuals_entitled_to_exemptions_under_151 }
  additional_amount_spouse_blind : CatalaRuntime.Money := (match (match processExceptions [if ((fun (spouse_local : (Optional Individual)) => ((fun (year_end_local : CatalaRuntime.Date) => ((fun (spouse_death_events_local : (List DeathEvent)) => ((fun (spouse_death_date_local : CatalaRuntime.Date) => ((fun (spouse_is_blind_at_close_local : Bool) => (decide (spouse_is_blind_at_close_local) && (decide ((taxpayer_exemptions_list_result).spouse_personal_exemption_allowed) && (match (individual_tax_return).details with | FilingStatusVariant.JointReturn variant => true| FilingStatusVariant.SurvivingSpouse variant => true| FilingStatusVariant.HeadOfHousehold variant => false| FilingStatusVariant.Single variant => false| FilingStatusVariant.MarriedFilingSeparate variant => true)))) (match spouse_local with | Optional.Absent _ => false| Optional.Present s => (individual_is_blind_at_close s blindness_status_events death_events spouse_death_date_local)))) (if (decide ((spouse_death_events_local).length > (0 : Int))) then (match (List.map ((fun (death_event : DeathEvent) => (death_event).death_date)) spouse_death_events_local) with | [] => (fun () => default /-unsupported expression-/) () | x0 :: xn => List.foldl (fun (min1 : CatalaRuntime.Date) (min2 : CatalaRuntime.Date) => (if (decide (min1 < min2)) then min1 else min2)) x0 xn) else year_end_local))) (match spouse_local with | Optional.Absent _ => (List.filter ((fun (death_event : DeathEvent) => false)) death_events)| Optional.Present s => (List.filter ((fun (death_event : DeathEvent) => ((decide ((death_event).decedent = s)) && (decide ((Date_en.get_year (death_event).death_date) = (individual_tax_return).tax_year))))) death_events)))) (get_year_end (individual_tax_return).tax_year))) (get_spouse individual_tax_return)) then some ((CatalaRuntime.Money.ofCents 60000)) else none] with | none => some ((CatalaRuntime.Money.ofCents 0)) | some r => some r) with | some r => r | _ => default)
  additional_amount_spouse_aged : CatalaRuntime.Money := (match (match processExceptions [if ((fun (spouse_local : (Optional Individual)) => ((fun (year_end_local : CatalaRuntime.Date) => ((fun (spouse_attained_age_65_local : Bool) => (decide (spouse_attained_age_65_local) && (decide ((taxpayer_exemptions_list_result).spouse_personal_exemption_allowed) && (match (individual_tax_return).details with | FilingStatusVariant.JointReturn variant => true| FilingStatusVariant.SurvivingSpouse variant => true| FilingStatusVariant.HeadOfHousehold variant => false| FilingStatusVariant.Single variant => false| FilingStatusVariant.MarriedFilingSeparate variant => true)))) (match spouse_local with | Optional.Absent _ => false| Optional.Present s => (individual_attained_age_65 s birth_events year_end_local)))) (get_year_end (individual_tax_return).tax_year))) (get_spouse individual_tax_return)) then some ((CatalaRuntime.Money.ofCents 60000)) else none] with | none => some ((CatalaRuntime.Money.ofCents 0)) | some r => some r) with | some r => r | _ => default)
  section_2_b_1_B_satisfied : Bool := ((fun (taxpayer_local : Individual) => ((fun (year_end_local : CatalaRuntime.Date) => (match (individual_tax_return).details with | FilingStatusVariant.JointReturn variant => false| FilingStatusVariant.SurvivingSpouse variant => false| FilingStatusVariant.HeadOfHousehold variant => ((fun (qualifying_person_is_father_or_mother_local : Bool) => ((fun (father_or_mother_has_principal_place_of_abode_local : Bool) => ((fun (taxpayer_entitled_to_section151_for_father_or_mother_local : Bool) => (decide (father_or_mother_has_principal_place_of_abode_local) && decide (taxpayer_entitled_to_section151_for_father_or_mother_local))) (List.foldl ((fun (acc : Bool) (entitled_individual : Individual) => (decide (acc) || (decide (entitled_individual = (variant).qualifying_person))))) false (taxpayer_exemptions_list_result).individuals_entitled_to_exemptions_under_151))) (List.foldl ((fun (acc : Bool) (maintenance_event : HouseholdMaintenanceEvent) => (decide (acc) || ((decide ((maintenance_event).individual = taxpayer_local)) && ((decide ((maintenance_event).start_date ≤ year_end_local)) && ((decide ((maintenance_event).end_date ≥ (Date_en.of_year_month_day (individual_tax_return).tax_year (1 : Int) (1 : Int)))) && ((decide ((maintenance_event).cost_furnished_percentage > (Rat.mk 1 2))) && decide ((List.foldl ((fun (acc : Bool) (residence_event : ResidencePeriodEvent) => (decide (acc) || ((decide ((residence_event).individual = (variant).qualifying_person)) && ((decide ((residence_event).household = (maintenance_event).household)) && (decide ((residence_event).is_principal_place_of_abode) && ((decide ((residence_event).start_date ≤ year_end_local)) && ((decide ((residence_event).end_date ≥ (Date_en.of_year_month_day (individual_tax_return).tax_year (1 : Int) (1 : Int)))) && decide (qualifying_person_is_father_or_mother_local))))))))) false residence_period_events))))))))) false household_maintenance_events))) (List.foldl ((fun (acc : Bool) (parenthood_event : ParenthoodEvent) => (decide (acc) || ((decide ((parenthood_event).parent = (variant).qualifying_person)) && ((decide ((parenthood_event).child = taxpayer_local)) && ((decide ((parenthood_event).start_date ≤ year_end_local)) && ((decide ((parenthood_event).parent_type = (ParentType.Biological ()))) || (decide ((parenthood_event).parent_type = (ParentType.Adoptive ())))))))))) false parenthood_events))| FilingStatusVariant.Single variant => false| FilingStatusVariant.MarriedFilingSeparate variant => false)) (get_year_end (individual_tax_return).tax_year))) (get_taxpayer individual_tax_return))
  section_2_b_1_A_ii_satisfied : Bool := (match (individual_tax_return).details with | FilingStatusVariant.JointReturn variant => false| FilingStatusVariant.SurvivingSpouse variant => false| FilingStatusVariant.HeadOfHousehold variant => (decide ((List.foldl ((fun (acc : Bool) (dependent_individual : Individual) => (decide (acc) || (decide (dependent_individual = (variant).qualifying_person))))) false (taxpayer_dependents_result).dependents_after_152b2)) && decide ((List.foldl ((fun (acc : Bool) (entitled_individual : Individual) => (decide (acc) || (decide (entitled_individual = (variant).qualifying_person))))) false (taxpayer_exemptions_list_result).individuals_entitled_to_exemptions_under_151)))| FilingStatusVariant.Single variant => false| FilingStatusVariant.MarriedFilingSeparate variant => false)
  section_2_a_1_B_satisfied : Bool := ((fun (taxpayer_local : Individual) => ((fun (year_end_local : CatalaRuntime.Date) => (match (individual_tax_return).details with | FilingStatusVariant.JointReturn variant => false| FilingStatusVariant.SurvivingSpouse variant => ((fun (dependent_is_son_stepson_daughter_stepdaughter_local : Bool) => ((fun (dependent_has_principal_place_of_abode_in_taxpayer_household_local : Bool) => ((fun (taxpayer_entitled_to_section151_deduction_for_dependent_local : Bool) => (decide (dependent_is_son_stepson_daughter_stepdaughter_local) && (decide (dependent_has_principal_place_of_abode_in_taxpayer_household_local) && decide (taxpayer_entitled_to_section151_deduction_for_dependent_local)))) (List.foldl ((fun (acc : Bool) (entitled_individual : Individual) => (decide (acc) || (decide (entitled_individual = (variant).qualifying_dependent))))) false (taxpayer_exemptions_list_result).individuals_entitled_to_exemptions_under_151))) (List.foldl ((fun (acc : Bool) (maintenance_event : HouseholdMaintenanceEvent) => (decide (acc) || ((decide ((maintenance_event).individual = taxpayer_local)) && ((decide ((maintenance_event).start_date ≤ year_end_local)) && ((decide ((maintenance_event).end_date ≥ (Date_en.of_year_month_day (individual_tax_return).tax_year (1 : Int) (1 : Int)))) && ((decide ((maintenance_event).cost_furnished_percentage > (Rat.mk 1 2))) && decide ((List.foldl ((fun (acc : Bool) (residence_event : ResidencePeriodEvent) => (decide (acc) || ((decide ((residence_event).individual = (variant).qualifying_dependent)) && ((decide ((residence_event).household = (maintenance_event).household)) && (decide ((residence_event).is_member_of_household) && (decide ((residence_event).is_principal_place_of_abode) && ((decide ((residence_event).start_date ≤ year_end_local)) && (decide ((residence_event).end_date ≥ (Date_en.of_year_month_day (individual_tax_return).tax_year (1 : Int) (1 : Int)))))))))))) false residence_period_events))))))))) false household_maintenance_events))) (List.foldl ((fun (acc : Bool) (parenthood_event : ParenthoodEvent) => (decide (acc) || ((decide ((parenthood_event).parent = taxpayer_local)) && ((decide ((parenthood_event).child = (variant).qualifying_dependent)) && ((decide ((parenthood_event).start_date ≤ year_end_local)) && ((decide ((parenthood_event).parent_type = (ParentType.Biological ()))) || (decide ((parenthood_event).parent_type = (ParentType.Step ())))))))))) false parenthood_events))| FilingStatusVariant.HeadOfHousehold variant => false| FilingStatusVariant.Single variant => false| FilingStatusVariant.MarriedFilingSeparate variant => false)) (get_year_end (individual_tax_return).tax_year))) (get_taxpayer individual_tax_return))
  individual_marital_statuses : (List IndividualSection7703MaritalStatusOutput) := [(taxpayer_marital_status).main_output]
  standard_deduction_eligible : Bool := (match (match processExceptions [processExceptions [if ((match (individual_tax_return).details with | FilingStatusVariant.JointReturn variant => (variant).is_estate_or_trust| FilingStatusVariant.SurvivingSpouse variant => (variant).is_estate_or_trust| FilingStatusVariant.HeadOfHousehold variant => (variant).is_estate_or_trust| FilingStatusVariant.Single variant => (variant).is_estate_or_trust| FilingStatusVariant.MarriedFilingSeparate variant => (variant).is_estate_or_trust) || ((match (individual_tax_return).details with | FilingStatusVariant.JointReturn variant => (variant).is_common_trust_fund| FilingStatusVariant.SurvivingSpouse variant => (variant).is_common_trust_fund| FilingStatusVariant.HeadOfHousehold variant => (variant).is_common_trust_fund| FilingStatusVariant.Single variant => (variant).is_common_trust_fund| FilingStatusVariant.MarriedFilingSeparate variant => (variant).is_common_trust_fund) || (match (individual_tax_return).details with | FilingStatusVariant.JointReturn variant => (variant).is_partnership| FilingStatusVariant.SurvivingSpouse variant => (variant).is_partnership| FilingStatusVariant.HeadOfHousehold variant => (variant).is_partnership| FilingStatusVariant.Single variant => (variant).is_partnership| FilingStatusVariant.MarriedFilingSeparate variant => (variant).is_partnership))) then some (false) else none, if ((fun (taxpayer_local : Individual) => ((fun (year_end_local : CatalaRuntime.Date) => (individual_is_nonresident_alien_during_year taxpayer_local nonresident_alien_status_period_events (individual_tax_return).tax_year year_end_local)) (get_year_end (individual_tax_return).tax_year))) (get_taxpayer individual_tax_return)) then some (false) else none, if (decide (((taxpayer_marital_status).main_output).is_married_for_tax_purposes) && ((match (individual_tax_return).details with | FilingStatusVariant.JointReturn variant => false| FilingStatusVariant.SurvivingSpouse variant => false| FilingStatusVariant.HeadOfHousehold variant => false| FilingStatusVariant.Single variant => false| FilingStatusVariant.MarriedFilingSeparate variant => true) && ((match (individual_tax_return).details with | FilingStatusVariant.JointReturn variant => (variant).itemization_election| FilingStatusVariant.SurvivingSpouse variant => (variant).itemization_election| FilingStatusVariant.HeadOfHousehold variant => (variant).itemization_election| FilingStatusVariant.Single variant => (variant).itemization_election| FilingStatusVariant.MarriedFilingSeparate variant => (variant).itemization_election) || decide ((extract_spouse_itemization_election individual_tax_return))))) then some (false) else none]] with | none => some (true) | some r => some r) with | some r => r | _ => default)
  section_2_b_1_A_satisfied : Bool := ((fun (taxpayer_local : Individual) => ((fun (year_end_local : CatalaRuntime.Date) => ((fun (qualifying_person_has_principal_place_of_abode_more_than_half_year_local : Bool) => (decide (qualifying_person_has_principal_place_of_abode_more_than_half_year_local) && (decide (section_2_b_1_A_i_satisfied) || decide (section_2_b_1_A_ii_satisfied)))) (match (individual_tax_return).details with | FilingStatusVariant.JointReturn variant => false| FilingStatusVariant.SurvivingSpouse variant => false| FilingStatusVariant.HeadOfHousehold variant => (List.foldl ((fun (acc : Bool) (maintenance_event : HouseholdMaintenanceEvent) => (decide (acc) || ((decide ((maintenance_event).individual = taxpayer_local)) && ((decide ((maintenance_event).start_date ≤ year_end_local)) && ((decide ((maintenance_event).end_date ≥ (Date_en.of_year_month_day (individual_tax_return).tax_year (1 : Int) (1 : Int)))) && ((decide ((maintenance_event).cost_furnished_percentage > (Rat.mk 1 2))) && decide ((List.foldl ((fun (acc : Bool) (residence_event : ResidencePeriodEvent) => (decide (acc) || ((decide ((residence_event).individual = (variant).qualifying_person)) && ((decide ((residence_event).household = (maintenance_event).household)) && (decide ((residence_event).is_member_of_household) && (decide ((residence_event).is_principal_place_of_abode) && ((decide ((residence_event).start_date ≤ (Date_en.of_year_month_day (individual_tax_return).tax_year (6 : Int) (30 : Int)))) && (decide ((residence_event).end_date ≥ (Date_en.of_year_month_day (individual_tax_return).tax_year (7 : Int) (1 : Int)))))))))))) false residence_period_events))))))))) false household_maintenance_events)| FilingStatusVariant.Single variant => false| FilingStatusVariant.MarriedFilingSeparate variant => false))) (get_year_end (individual_tax_return).tax_year))) (get_taxpayer individual_tax_return))
  is_surviving_spouse : Bool := (match (match processExceptions [processExceptions [if section_2_a_2_A_taxpayer_has_remarried then some (false) else none, if (!decide (section_2_a_2_B_joint_return_could_have_been_made)) then some (false) else none]] with | none => some ((decide (section_2_a_1_A_spouse_died_in_preceding_two_years) && decide (section_2_a_1_B_satisfied))) | some r => some r) with | some r => r | _ => default)
  is_head_of_household : Bool := (match (match processExceptions [if (match (individual_tax_return).details with | FilingStatusVariant.JointReturn variant => false| FilingStatusVariant.SurvivingSpouse variant => false| FilingStatusVariant.HeadOfHousehold variant => (List.foldl ((fun (acc : Bool) (result : IndividualSection152QualifyingRelativeOutput) => (decide (acc) || ((decide ((result).individual = (variant).qualifying_person)) && ((decide ((result).taxpayer = (get_taxpayer individual_tax_return))) && (decide ((result).is_qualifying_relative) && ((!decide ((result).relationship_requirement_met)) && decide ((result).relationship_requirement_met_H)))))))) false (taxpayer_dependents_result).qualifying_relatives)| FilingStatusVariant.Single variant => false| FilingStatusVariant.MarriedFilingSeparate variant => false) then some (false) else none, if ((fun (taxpayer_local : Individual) => ((fun (year_end_local : CatalaRuntime.Date) => (List.foldl ((fun (acc : Bool) (residency_event : NonresidentAlienStatusPeriodEvent) => (decide (acc) || ((decide ((residency_event).individual = taxpayer_local)) && ((decide ((residency_event).start_date ≤ year_end_local)) && ((decide ((residency_event).end_date ≥ (Date_en.of_year_month_day (individual_tax_return).tax_year (1 : Int) (1 : Int)))) && (decide ((residency_event).residency_status = (ResidencyStatus.NonresidentAlien ()))))))))) false nonresident_alien_status_period_events)) (get_year_end (individual_tax_return).tax_year))) (get_taxpayer individual_tax_return)) then some (false) else none] with | none => some (((!decide (section_2_b_2_is_married_at_close_of_year)) && ((!decide (is_surviving_spouse)) && (decide (section_2_b_1_A_satisfied) || decide (section_2_b_1_B_satisfied))))) | some r => some r) with | some r => r | _ => default)
  additional_amount_taxpayer_blind : CatalaRuntime.Money := (match (match processExceptions [if ((fun (taxpayer_local : Individual) => ((fun (year_end_local : CatalaRuntime.Date) => (decide ((individual_is_blind_at_close taxpayer_local blindness_status_events death_events year_end_local)) && ((!decide (((taxpayer_marital_status).main_output).is_married_for_tax_purposes)) && (!decide (is_surviving_spouse))))) (get_year_end (individual_tax_return).tax_year))) (get_taxpayer individual_tax_return)) then some ((CatalaRuntime.Money.ofCents 75000)) else none] with | none => some ((if (individual_is_blind_at_close (get_taxpayer individual_tax_return) blindness_status_events death_events (get_year_end (individual_tax_return).tax_year)) then (CatalaRuntime.Money.ofCents 60000) else (CatalaRuntime.Money.ofCents 0))) | some r => some r) with | some r => r | _ => default)
  additional_amount_taxpayer_aged : CatalaRuntime.Money := (match (match processExceptions [if ((fun (taxpayer_local : Individual) => ((fun (year_end_local : CatalaRuntime.Date) => (decide ((individual_attained_age_65 taxpayer_local birth_events year_end_local)) && ((!decide (((taxpayer_marital_status).main_output).is_married_for_tax_purposes)) && (!decide (is_surviving_spouse))))) (get_year_end (individual_tax_return).tax_year))) (get_taxpayer individual_tax_return)) then some ((CatalaRuntime.Money.ofCents 75000)) else none] with | none => some ((if (individual_attained_age_65 (get_taxpayer individual_tax_return) birth_events (get_year_end (individual_tax_return).tax_year)) then (CatalaRuntime.Money.ofCents 60000) else (CatalaRuntime.Money.ofCents 0))) | some r => some r) with | some r => r | _ => default)
  applicable_amount : CatalaRuntime.Money := (match (match processExceptions [(match processExceptions [(match processExceptions [if (decide (((taxpayer_marital_status).main_output).is_married_for_tax_purposes) && (match (individual_tax_return).details with | FilingStatusVariant.JointReturn variant => false| FilingStatusVariant.SurvivingSpouse variant => false| FilingStatusVariant.HeadOfHousehold variant => false| FilingStatusVariant.Single variant => false| FilingStatusVariant.MarriedFilingSeparate variant => true)) then some ((CatalaRuntime.Money.ofCents 15000000)) else none] with | none => if ((!decide (((taxpayer_marital_status).main_output).is_married_for_tax_purposes)) && ((!decide (is_surviving_spouse)) && (!decide (is_head_of_household)))) then some ((CatalaRuntime.Money.ofCents 25000000)) else none | some r => some r)] with | none => if is_head_of_household then some ((CatalaRuntime.Money.ofCents 27500000)) else none | some r => some r)] with | none => some ((if ((decide (((taxpayer_marital_status).main_output).is_married_for_tax_purposes) && (match (individual_tax_return).details with | FilingStatusVariant.JointReturn variant => true| FilingStatusVariant.SurvivingSpouse variant => false| FilingStatusVariant.HeadOfHousehold variant => false| FilingStatusVariant.Single variant => false| FilingStatusVariant.MarriedFilingSeparate variant => false)) || decide (is_surviving_spouse)) then (CatalaRuntime.Money.ofCents 30000000) else (CatalaRuntime.Money.ofCents 0))) | some r => some r) with | some r => r | _ => default)
  basic_standard_deduction : CatalaRuntime.Money := (match (match processExceptions [if ((fun (taxpayer_local : Individual) => ((fun (deduction_allowable_to_another_taxpayer : Bool) => deduction_allowable_to_another_taxpayer) (List.foldl ((fun (acc : Bool) (event : TaxReturnEvent) => (decide (acc) || ((!(decide ((event).individual = taxpayer_local))) && ((decide ((event).tax_year = (individual_tax_return).tax_year)) && decide ((List.foldl ((fun (acc : Bool) (dependent : Individual) => (decide (acc) || (decide (dependent = taxpayer_local))))) false (event).dependents))))))) false tax_return_events))) (get_taxpayer individual_tax_return)) then some (((fun (taxpayer_local : Individual) => ((fun (earned_income_local : CatalaRuntime.Money) => ((Money_en.min (CatalaRuntime.Money.ofCents 50000) (CatalaRuntime.Money.ofCents 25000)) + earned_income_local)) ((fun (income_event_local : (List IncomeEvent)) => (if (decide ((income_event_local).length > (0 : Int))) then (match (List.map ((fun (event : IncomeEvent) => (event).earned_income)) income_event_local) with | [] => (fun () => (CatalaRuntime.Money.ofCents 0)) () | x0 :: xn => List.foldl (fun (sum1 : CatalaRuntime.Money) (sum2 : CatalaRuntime.Money) => (sum1 + sum2)) x0 xn) else (CatalaRuntime.Money.ofCents 0))) (List.filter ((fun (income_event : IncomeEvent) => ((decide ((income_event).individual = taxpayer_local)) && ((decide ((income_event).tax_year = (individual_tax_return).tax_year)) && (!decide ((income_event).is_counterfactual)))))) income_events)))) (get_taxpayer individual_tax_return))) else none, (match processExceptions [(match processExceptions [if (decide ((is_tax_year_2018_through_2025 (individual_tax_return).tax_year)) && ((decide (((taxpayer_marital_status).main_output).is_married_for_tax_purposes) && (match (individual_tax_return).details with | FilingStatusVariant.JointReturn variant => true| FilingStatusVariant.SurvivingSpouse variant => false| FilingStatusVariant.HeadOfHousehold variant => false| FilingStatusVariant.Single variant => false| FilingStatusVariant.MarriedFilingSeparate variant => false)) || decide (is_surviving_spouse))) then some ((CatalaRuntime.Money.ofCents 2400000)) else none] with | none => if (decide ((is_tax_year_2018_through_2025 (individual_tax_return).tax_year)) && decide (is_head_of_household)) then some ((CatalaRuntime.Money.ofCents 1800000)) else none | some r => some r)] with | none => if (is_tax_year_2018_through_2025 (individual_tax_return).tax_year) then some ((CatalaRuntime.Money.ofCents 1200000)) else none | some r => some r), (match processExceptions [if ((!decide ((is_tax_year_2018_through_2025 (individual_tax_return).tax_year))) && ((decide (((taxpayer_marital_status).main_output).is_married_for_tax_purposes) && (match (individual_tax_return).details with | FilingStatusVariant.JointReturn variant => true| FilingStatusVariant.SurvivingSpouse variant => false| FilingStatusVariant.HeadOfHousehold variant => false| FilingStatusVariant.Single variant => false| FilingStatusVariant.MarriedFilingSeparate variant => false)) || decide (is_surviving_spouse))) then some ((CatalaRuntime.Money.ofCents 600000)) else none] with | none => if ((!decide ((is_tax_year_2018_through_2025 (individual_tax_return).tax_year))) && decide (is_head_of_household)) then some ((CatalaRuntime.Money.ofCents 440000)) else none | some r => some r)] with | none => some ((CatalaRuntime.Money.ofCents 300000)) | some r => some r) with | some r => r | _ => default)
  additional_standard_deduction : CatalaRuntime.Money := (((additional_amount_taxpayer_aged + additional_amount_spouse_aged) + additional_amount_taxpayer_blind) + additional_amount_spouse_blind)
  taxpayer_exemption : IndividualSection151Exemption := individualSection151Exemption { individual := (get_taxpayer individual_tax_return), individual_tax_return := individual_tax_return, tax_year := (individual_tax_return).tax_year, tax_return_events := tax_return_events, adjusted_gross_income := adjusted_gross_income, applicable_amount := applicable_amount, individuals_entitled_to_exemptions_under_151 := (taxpayer_exemptions_list_result).individuals_entitled_to_exemptions_under_151 }
  section_68_three_percent_reduction : CatalaRuntime.Money := ((fun (excess_agi : CatalaRuntime.Money) => (if (decide (excess_agi > (CatalaRuntime.Money.ofCents 0))) then (CatalaRuntime.multiply excess_agi (Rat.mk 3 100)) else (CatalaRuntime.Money.ofCents 0))) (adjusted_gross_income - applicable_amount))
  standard_deduction : CatalaRuntime.Money := (match (match processExceptions [if (!decide (standard_deduction_eligible)) then some ((CatalaRuntime.Money.ofCents 0)) else none] with | none => some ((basic_standard_deduction + additional_standard_deduction)) | some r => some r) with | some r => r | _ => default)
  taxpayer_exemption_result : IndividualSection151ExemptionOutput := (taxpayer_exemption).main_output
  section_68_reduction_amount : CatalaRuntime.Money := (if (decide (adjusted_gross_income > applicable_amount)) then (Money_en.min section_68_three_percent_reduction section_68_eighty_percent_reduction) else (CatalaRuntime.Money.ofCents 0))
  itemized_deductions_after_68 : CatalaRuntime.Money := (match (match processExceptions [if (is_tax_year_2018_through_2025 (individual_tax_return).tax_year) then some (itemized_deductions) else none] with | none => some ((itemized_deductions - section_68_reduction_amount)) | some r => some r) with | some r => r | _ => default)
  taxable_income : CatalaRuntime.Money := (match (match processExceptions [if ((fun (itemizes_deductions : Bool) => itemizes_deductions) (match (individual_tax_return).details with | FilingStatusVariant.JointReturn variant => (variant).itemization_election| FilingStatusVariant.SurvivingSpouse variant => (variant).itemization_election| FilingStatusVariant.HeadOfHousehold variant => (variant).itemization_election| FilingStatusVariant.Single variant => (variant).itemization_election| FilingStatusVariant.MarriedFilingSeparate variant => (variant).itemization_election)) then some (((fun (computed_taxable_income : CatalaRuntime.Money) => (if (decide (computed_taxable_income < (CatalaRuntime.Money.ofCents 0))) then (CatalaRuntime.Money.ofCents 0) else computed_taxable_income)) ((adjusted_gross_income - itemized_deductions_after_68) - (taxpayer_exemption_result).personal_exemptions_deduction))) else none] with | none => some (((fun (computed_taxable_income : CatalaRuntime.Money) => (if (decide (computed_taxable_income < (CatalaRuntime.Money.ofCents 0))) then (CatalaRuntime.Money.ofCents 0) else computed_taxable_income)) ((adjusted_gross_income - standard_deduction) - (taxpayer_exemption_result).personal_exemptions_deduction))) | some r => some r) with | some r => r | _ => default)
  tax : CatalaRuntime.Money := (match (match processExceptions [(match processExceptions [(match processExceptions [(match processExceptions [if is_head_of_household then some ((if (decide (taxable_income ≤ (CatalaRuntime.Money.ofCents 2960000))) then (CatalaRuntime.multiply taxable_income (Rat.mk 3 20)) else (if (decide (taxable_income ≤ (CatalaRuntime.Money.ofCents 7640000))) then ((CatalaRuntime.Money.ofCents 444000) + (CatalaRuntime.multiply (taxable_income - (CatalaRuntime.Money.ofCents 2960000)) (Rat.mk 7 25))) else (if (decide (taxable_income ≤ (CatalaRuntime.Money.ofCents 12750000))) then ((CatalaRuntime.Money.ofCents 1754400) + (CatalaRuntime.multiply (taxable_income - (CatalaRuntime.Money.ofCents 7640000)) (Rat.mk 31 100))) else (if (decide (taxable_income ≤ (CatalaRuntime.Money.ofCents 25000000))) then ((CatalaRuntime.Money.ofCents 3338500) + (CatalaRuntime.multiply (taxable_income - (CatalaRuntime.Money.ofCents 12750000)) (Rat.mk 9 25))) else ((CatalaRuntime.Money.ofCents 7748500) + (CatalaRuntime.multiply (taxable_income - (CatalaRuntime.Money.ofCents 25000000)) (Rat.mk 99 250)))))))) else none] with | none => if is_surviving_spouse then some ((if (decide (taxable_income ≤ (CatalaRuntime.Money.ofCents 3690000))) then (CatalaRuntime.multiply taxable_income (Rat.mk 3 20)) else (if (decide (taxable_income ≤ (CatalaRuntime.Money.ofCents 8915000))) then ((CatalaRuntime.Money.ofCents 553500) + (CatalaRuntime.multiply (taxable_income - (CatalaRuntime.Money.ofCents 3690000)) (Rat.mk 7 25))) else (if (decide (taxable_income ≤ (CatalaRuntime.Money.ofCents 14000000))) then ((CatalaRuntime.Money.ofCents 2016500) + (CatalaRuntime.multiply (taxable_income - (CatalaRuntime.Money.ofCents 8915000)) (Rat.mk 31 100))) else (if (decide (taxable_income ≤ (CatalaRuntime.Money.ofCents 25000000))) then ((CatalaRuntime.Money.ofCents 3592850) + (CatalaRuntime.multiply (taxable_income - (CatalaRuntime.Money.ofCents 14000000)) (Rat.mk 9 25))) else ((CatalaRuntime.Money.ofCents 7552850) + (CatalaRuntime.multiply (taxable_income - (CatalaRuntime.Money.ofCents 25000000)) (Rat.mk 99 250)))))))) else none | some r => some r)] with | none => if (decide (((taxpayer_marital_status).main_output).is_married_for_tax_purposes) && (match (individual_tax_return).details with | FilingStatusVariant.JointReturn variant => true| FilingStatusVariant.SurvivingSpouse variant => false| FilingStatusVariant.HeadOfHousehold variant => false| FilingStatusVariant.Single variant => false| FilingStatusVariant.MarriedFilingSeparate variant => false)) then some ((if (decide (taxable_income ≤ (CatalaRuntime.Money.ofCents 3690000))) then (CatalaRuntime.multiply taxable_income (Rat.mk 3 20)) else (if (decide (taxable_income ≤ (CatalaRuntime.Money.ofCents 8915000))) then ((CatalaRuntime.Money.ofCents 553500) + (CatalaRuntime.multiply (taxable_income - (CatalaRuntime.Money.ofCents 3690000)) (Rat.mk 7 25))) else (if (decide (taxable_income ≤ (CatalaRuntime.Money.ofCents 14000000))) then ((CatalaRuntime.Money.ofCents 2016500) + (CatalaRuntime.multiply (taxable_income - (CatalaRuntime.Money.ofCents 8915000)) (Rat.mk 31 100))) else (if (decide (taxable_income ≤ (CatalaRuntime.Money.ofCents 25000000))) then ((CatalaRuntime.Money.ofCents 3592850) + (CatalaRuntime.multiply (taxable_income - (CatalaRuntime.Money.ofCents 14000000)) (Rat.mk 9 25))) else ((CatalaRuntime.Money.ofCents 7552850) + (CatalaRuntime.multiply (taxable_income - (CatalaRuntime.Money.ofCents 25000000)) (Rat.mk 99 250)))))))) else none | some r => some r)] with | none => if (decide (((taxpayer_marital_status).main_output).is_married_for_tax_purposes) && (match (individual_tax_return).details with | FilingStatusVariant.JointReturn variant => false| FilingStatusVariant.SurvivingSpouse variant => false| FilingStatusVariant.HeadOfHousehold variant => false| FilingStatusVariant.Single variant => false| FilingStatusVariant.MarriedFilingSeparate variant => true)) then some ((if (decide (taxable_income ≤ (CatalaRuntime.Money.ofCents 1845000))) then (CatalaRuntime.multiply taxable_income (Rat.mk 3 20)) else (if (decide (taxable_income ≤ (CatalaRuntime.Money.ofCents 4457500))) then ((CatalaRuntime.Money.ofCents 276750) + (CatalaRuntime.multiply (taxable_income - (CatalaRuntime.Money.ofCents 1845000)) (Rat.mk 7 25))) else (if (decide (taxable_income ≤ (CatalaRuntime.Money.ofCents 7000000))) then ((CatalaRuntime.Money.ofCents 1008250) + (CatalaRuntime.multiply (taxable_income - (CatalaRuntime.Money.ofCents 4457500)) (Rat.mk 31 100))) else (if (decide (taxable_income ≤ (CatalaRuntime.Money.ofCents 12500000))) then ((CatalaRuntime.Money.ofCents 1796425) + (CatalaRuntime.multiply (taxable_income - (CatalaRuntime.Money.ofCents 7000000)) (Rat.mk 9 25))) else ((CatalaRuntime.Money.ofCents 3776425) + (CatalaRuntime.multiply (taxable_income - (CatalaRuntime.Money.ofCents 12500000)) (Rat.mk 99 250)))))))) else none | some r => some r)] with | none => some ((if (decide (taxable_income ≤ (CatalaRuntime.Money.ofCents 2210000))) then (CatalaRuntime.multiply taxable_income (Rat.mk 3 20)) else (if (decide (taxable_income ≤ (CatalaRuntime.Money.ofCents 5350000))) then ((CatalaRuntime.Money.ofCents 331500) + (CatalaRuntime.multiply (taxable_income - (CatalaRuntime.Money.ofCents 2210000)) (Rat.mk 7 25))) else (if (decide (taxable_income ≤ (CatalaRuntime.Money.ofCents 11500000))) then ((CatalaRuntime.Money.ofCents 1210700) + (CatalaRuntime.multiply (taxable_income - (CatalaRuntime.Money.ofCents 5350000)) (Rat.mk 31 100))) else (if (decide (taxable_income ≤ (CatalaRuntime.Money.ofCents 25000000))) then ((CatalaRuntime.Money.ofCents 3117200) + (CatalaRuntime.multiply (taxable_income - (CatalaRuntime.Money.ofCents 11500000)) (Rat.mk 9 25))) else ((CatalaRuntime.Money.ofCents 7977200) + (CatalaRuntime.multiply (taxable_income - (CatalaRuntime.Money.ofCents 25000000)) (Rat.mk 99 250)))))))) | some r => some r) with | some r => r | _ => default)

def IRCSimplified_adjusted_gross_income (input : IRCSimplified_Input) : Option CatalaRuntime.Money :=
  some input.adjusted_gross_income

structure IRCSimplified where
  itemized_deductions : CatalaRuntime.Money
  adjusted_gross_income : CatalaRuntime.Money
  section_2_a_1_A_spouse_died_in_preceding_two_years : Bool
  section_2_a_2_B_joint_return_could_have_been_made : Bool
  section_2_a_2_A_taxpayer_has_remarried : Bool
  section_2_b_1_A_i_I_qualifying_child_is_married_at_close_of_year : Bool
  section_2_b_2_is_married_at_close_of_year : Bool
  wage_payment_wages_results : (List WagePaymentEventSection3306WagesOutput)
  employment_relationship_employment_results : (List EmploymentRelationshipEventSection3306EmploymentOutput)
  organization_employer_statuses : (List OrganizationSection3306EmployerStatusOutput)
  section_68_eighty_percent_reduction : CatalaRuntime.Money
  taxpayer_dependents_result : IndividualSection152DependentsOutput
  section_2_b_1_A_i_II_qualifying_person_not_dependent_by_152b2 : Bool
  employer_unemployment_excise_tax_result : EmployerUnemploymentExciseTaxFilerSection3301TaxOutput
  taxpayer_exemptions_list_result : TaxpayerExemptionsListOutput
  section_2_b_1_A_i_satisfied : Bool
  additional_amount_spouse_blind : CatalaRuntime.Money
  additional_amount_spouse_aged : CatalaRuntime.Money
  section_2_b_1_B_satisfied : Bool
  section_2_b_1_A_ii_satisfied : Bool
  section_2_a_1_B_satisfied : Bool
  individual_marital_statuses : (List IndividualSection7703MaritalStatusOutput)
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
  taxpayer_exemption_result : IndividualSection151ExemptionOutput
  section_68_reduction_amount : CatalaRuntime.Money
  itemized_deductions_after_68 : CatalaRuntime.Money
  taxable_income : CatalaRuntime.Money
  tax : CatalaRuntime.Money
deriving Repr, DecidableEq, Inhabited
def iRCSimplified (input : IRCSimplified_Input) : IRCSimplified :=
  let taxpayer_dependents := individualSection152Dependents { taxpayer := (get_taxpayer input.individual_tax_return), tax_year := (input.individual_tax_return).tax_year, individuals := input.individuals, family_relationship_events := input.family_relationship_events, birth_events := input.birth_events, residence_period_events := input.residence_period_events, tax_return_events := input.tax_return_events, income_events := input.income_events, marriage_events := input.marriage_events }
  let employer_unemployment_excise_tax := employerUnemploymentExciseTaxFilerSection3301Tax { employer_unemployment_excise_tax_return := input.employer_unemployment_excise_tax_return, wage_payment_wages_results := input.wage_payment_wages_results, organization_employer_statuses := input.organization_employer_statuses, employment_relationship_employment_results := input.employment_relationship_employment_results }
  let taxpayer_exemptions_list := taxpayerExemptionsList { individual_tax_return := input.individual_tax_return, tax_return_events := input.tax_return_events, income_events := input.income_events, dependents := (input.taxpayer_dependents_result).dependents_after_152b2 }
  let taxpayer_marital_status := individualSection7703MaritalStatus { individual := (match (input.individual_tax_return).details with | FilingStatusVariant.JointReturn variant => (variant).taxpayer| FilingStatusVariant.SurvivingSpouse variant => (variant).taxpayer| FilingStatusVariant.HeadOfHousehold variant => (variant).taxpayer| FilingStatusVariant.Single variant => (variant).taxpayer| FilingStatusVariant.MarriedFilingSeparate variant => (variant).taxpayer), tax_year := (input.individual_tax_return).tax_year, marriage_events := input.marriage_events, divorce_or_legal_separation_events := input.divorce_or_legal_separation_events, death_events := input.death_events, individual_tax_return := input.individual_tax_return, residence_period_events := input.residence_period_events, household_maintenance_events := input.household_maintenance_events, qualifying_children := (input.taxpayer_dependents_result).qualifying_children, individuals_entitled_to_exemptions_under_151 := (input.taxpayer_exemptions_list_result).individuals_entitled_to_exemptions_under_151 }
  let taxpayer_exemption := individualSection151Exemption { individual := (get_taxpayer input.individual_tax_return), individual_tax_return := input.individual_tax_return, tax_year := (input.individual_tax_return).tax_year, tax_return_events := input.tax_return_events, adjusted_gross_income := input.adjusted_gross_income, applicable_amount := input.applicable_amount, individuals_entitled_to_exemptions_under_151 := (input.taxpayer_exemptions_list_result).individuals_entitled_to_exemptions_under_151 }
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
