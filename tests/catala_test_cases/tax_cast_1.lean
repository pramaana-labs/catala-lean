import CaseStudies.Pramaana.CatalaRuntime

import CaseStudies.Pramaana.Stdlib.Stdlib

open CatalaRuntime

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

structure TestTaxCase1_Input where


def TestTaxCase1_computation_leaf_0  : Option Sections.IRCSimplified :=
  (some (((fun (alice : Sections.Individual) => ((fun (jail : Sections.Organization) => ((fun (other_employer : Sections.Organization) => ((fun (jail_employment : Sections.EmploymentRelationshipEvent) => ((fun (post_jail_employment : Sections.EmploymentRelationshipEvent) => ((fun (jail_wage_payment : Sections.WagePaymentEvent) => ((fun (post_jail_wage_payment : Sections.WagePaymentEvent) => ((fun (alice_income : Sections.IncomeEvent) => ((fun (tax_return_event : Sections.TaxReturnEvent) => ((fun (single_variant : Sections.SingleVariant) => ((fun (individual_tax_return : Sections.IndividualTaxReturn) => ((fun (employer_general_variant : Sections.EmployerGeneralVariant) => ((fun (employer_tax_return : Sections.EmployerUnemploymentExciseTaxReturn) => ((fun (income_events_list : (List Sections.IncomeEvent)) => ((fun (employment_events_list : (List Sections.EmploymentRelationshipEvent)) => ((fun (wage_payment_events_list : (List Sections.WagePaymentEvent)) => ((fun (adjusted_gross_income : CatalaRuntime.Money) => (sections.IRCSimplified {adjusted_gross_income:=adjusted_gross_income,employer_unemployment_excise_tax_return:=employer_tax_return,employment_termination_events:=[],immigration_admission_events:=[],hospital_patient_events:=[],student_enrollment_events:=[],wage_payment_events:=wage_payment_events_list,employment_relationship_events:=employment_events_list,income_events:=income_events_list,tax_return_events:=[tax_return_event],family_relationship_events:=[],parenthood_events:=[],household_maintenance_events:=[],residence_period_events:=[],divorce_or_legal_separation_events:=[],remarriage_events:=[],marriage_events:=[],nonresident_alien_status_period_events:=[],death_events:=[],blindness_status_events:=[],birth_events:=[],organizations:=([jail] ++ [other_employer]),individuals:=[alice],individual_tax_return:=individual_tax_return})) (CatalaRuntime.Money.ofCents 652000))) ([jail_wage_payment] ++ [post_jail_wage_payment]))) ([jail_employment] ++ [post_jail_employment]))) [alice_income])) ({ id := (0 : Int), tax_year := (2019 : Int), details := (Sections.EmployerVariant.GeneralEmployer employer_general_variant) } : Sections.EmployerUnemploymentExciseTaxReturn))) ({ employer := other_employer } : Sections.EmployerGeneralVariant))) ({ id := (1 : Int), tax_year := (2019 : Int), details := (Sections.FilingStatusVariant.Single single_variant) } : Sections.IndividualTaxReturn))) ({ taxpayer := alice, itemization_election := false, is_estate_or_trust := false, is_common_trust_fund := false, is_partnership := false } : Sections.SingleVariant))) ({ id := (1 : Int), individual := alice, tax_year := (2019 : Int), filed_joint_return := false, is_only_for_refund_claim := false, qualifying_children := [], dependents := [], is_counterfactual := false } : Sections.TaxReturnEvent))) ({ id := (1 : Int), individual := alice, tax_year := (2019 : Int), has_income := true, earned_income := (CatalaRuntime.Money.ofCents 652000), is_counterfactual := false } : Sections.IncomeEvent))) ({ id := (2 : Int), employer := other_employer, employee := alice, payment_date := (Date_en.of_year_month_day (2019 : Int) (12 : Int) (31 : Int)), amount := (CatalaRuntime.Money.ofCents 532000), payment_medium := (Sections.PaymentMedium.Cash ()), payment_reason := (Sections.PaymentReason.RegularCompensation ()), is_under_plan_or_system := false, is_for_employee_generally := true, is_for_class_of_employees := false, is_for_dependents := false, is_not_in_course_of_trade_or_business := false, would_have_been_paid_without_termination := false, is_paid_to_survivor_or_estate := false, is_counterfactual := false } : Sections.WagePaymentEvent))) ({ id := (1 : Int), employer := jail, employee := alice, payment_date := (Date_en.of_year_month_day (2019 : Int) (5 : Int) (5 : Int)), amount := (CatalaRuntime.Money.ofCents 120000), payment_medium := (Sections.PaymentMedium.Cash ()), payment_reason := (Sections.PaymentReason.RegularCompensation ()), is_under_plan_or_system := false, is_for_employee_generally := true, is_for_class_of_employees := false, is_for_dependents := false, is_not_in_course_of_trade_or_business := false, would_have_been_paid_without_termination := false, is_paid_to_survivor_or_estate := false, is_counterfactual := false } : Sections.WagePaymentEvent))) ({ id := (2 : Int), employer := other_employer, employee := alice, start_date := (Date_en.of_year_month_day (2019 : Int) (5 : Int) (5 : Int)), end_date := (Date_en.of_year_month_day (2019 : Int) (12 : Int) (31 : Int)), employment_category := (Sections.EmploymentCategory.General ()), service_location := (Sections.ServiceLocation.WithinUnitedStates ()), is_american_employer := true, employee_is_us_citizen := true, is_counterfactual := false } : Sections.EmploymentRelationshipEvent))) ({ id := (1 : Int), employer := jail, employee := alice, start_date := (Date_en.of_year_month_day (2019 : Int) (1 : Int) (1 : Int)), end_date := (Date_en.of_year_month_day (2019 : Int) (5 : Int) (5 : Int)), employment_category := (Sections.EmploymentCategory.PenalInstitution ()), service_location := (Sections.ServiceLocation.WithinUnitedStates ()), is_american_employer := true, employee_is_us_citizen := true, is_counterfactual := false } : Sections.EmploymentRelationshipEvent))) ({ id := (2 : Int), organization_type := (Sections.OrganizationType.Business ()), is_counterfactual := false } : Sections.Organization))) ({ id := (1 : Int), organization_type := (Sections.OrganizationType.PenalInstitution ()), is_counterfactual := false } : Sections.Organization))) ({ id := (1 : Int), is_counterfactual := false } : Sections.Individual))))

structure TestTaxCase1 where
  computation : Sections.IRCSimplified
deriving DecidableEq, Inhabited
def testTaxCase1 (input : TestTaxCase1_Input) : TestTaxCase1 :=
  let computation := match TestTaxCase1_computation_leaf_0  with | some val => val | _ => default 
  { computation := computation }
