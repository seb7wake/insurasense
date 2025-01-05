/*
  Warnings:

  - You are about to drop the column `appeals_process` on the `ClaimsAndAppeals` table. All the data in the column will be lost.
  - You are about to drop the column `claim_filing_procedure` on the `ClaimsAndAppeals` table. All the data in the column will be lost.
  - You are about to drop the column `in_network` on the `Coinsurance` table. All the data in the column will be lost.
  - You are about to drop the column `out_of_network` on the `Coinsurance` table. All the data in the column will be lost.
  - You are about to drop the column `primary_care` on the `Copays` table. All the data in the column will be lost.
  - You are about to drop the column `urgent_care` on the `Copays` table. All the data in the column will be lost.
  - You are about to drop the column `family_in_network` on the `Deductibles` table. All the data in the column will be lost.
  - You are about to drop the column `family_oop_max` on the `Deductibles` table. All the data in the column will be lost.
  - You are about to drop the column `individual_in_network` on the `Deductibles` table. All the data in the column will be lost.
  - You are about to drop the column `individual_oop_max` on the `Deductibles` table. All the data in the column will be lost.
  - You are about to drop the column `coverage_year` on the `HealthPlan` table. All the data in the column will be lost.
  - You are about to drop the column `file_name` on the `HealthPlan` table. All the data in the column will be lost.
  - You are about to drop the column `plan_name` on the `HealthPlan` table. All the data in the column will be lost.
  - You are about to drop the column `plan_type` on the `HealthPlan` table. All the data in the column will be lost.
  - You are about to drop the column `prior_authorization_required` on the `HealthPlan` table. All the data in the column will be lost.
  - You are about to drop the column `annual_premium` on the `Premium` table. All the data in the column will be lost.
  - You are about to drop the column `employer_contribution` on the `Premium` table. All the data in the column will be lost.
  - You are about to drop the column `monthly_premium` on the `Premium` table. All the data in the column will be lost.
  - You are about to drop the column `tier_1_generic` on the `PrescriptionDrugs` table. All the data in the column will be lost.
  - You are about to drop the column `tier_2_preferred` on the `PrescriptionDrugs` table. All the data in the column will be lost.
  - You are about to drop the column `tier_3_non_preferred` on the `PrescriptionDrugs` table. All the data in the column will be lost.
  - You are about to drop the column `hospital_inpatient` on the `ServicesCoverage` table. All the data in the column will be lost.
  - You are about to drop the column `mental_health_outpatient` on the `ServicesCoverage` table. All the data in the column will be lost.
  - You are about to drop the column `outpatient_surgery` on the `ServicesCoverage` table. All the data in the column will be lost.
  - You are about to drop the column `preventive_care` on the `ServicesCoverage` table. All the data in the column will be lost.
  - Added the required column `appealsProcess` to the `ClaimsAndAppeals` table without a default value. This is not possible if the table is not empty.
  - Added the required column `claimFilingProcedure` to the `ClaimsAndAppeals` table without a default value. This is not possible if the table is not empty.
  - Added the required column `inNetwork` to the `Coinsurance` table without a default value. This is not possible if the table is not empty.
  - Added the required column `outOfNetwork` to the `Coinsurance` table without a default value. This is not possible if the table is not empty.
  - Added the required column `primaryCare` to the `Copays` table without a default value. This is not possible if the table is not empty.
  - Added the required column `urgentCare` to the `Copays` table without a default value. This is not possible if the table is not empty.
  - Added the required column `familyInNetwork` to the `Deductibles` table without a default value. This is not possible if the table is not empty.
  - Added the required column `familyOopMax` to the `Deductibles` table without a default value. This is not possible if the table is not empty.
  - Added the required column `individualInNetwork` to the `Deductibles` table without a default value. This is not possible if the table is not empty.
  - Added the required column `individualOopMax` to the `Deductibles` table without a default value. This is not possible if the table is not empty.
  - Added the required column `coverageYear` to the `HealthPlan` table without a default value. This is not possible if the table is not empty.
  - Added the required column `fileName` to the `HealthPlan` table without a default value. This is not possible if the table is not empty.
  - Added the required column `planName` to the `HealthPlan` table without a default value. This is not possible if the table is not empty.
  - Added the required column `planType` to the `HealthPlan` table without a default value. This is not possible if the table is not empty.
  - Added the required column `annualPremium` to the `Premium` table without a default value. This is not possible if the table is not empty.
  - Added the required column `employerContribution` to the `Premium` table without a default value. This is not possible if the table is not empty.
  - Added the required column `monthlyPremium` to the `Premium` table without a default value. This is not possible if the table is not empty.
  - Added the required column `tier1Generic` to the `PrescriptionDrugs` table without a default value. This is not possible if the table is not empty.
  - Added the required column `tier2Preferred` to the `PrescriptionDrugs` table without a default value. This is not possible if the table is not empty.
  - Added the required column `tier3NonPreferred` to the `PrescriptionDrugs` table without a default value. This is not possible if the table is not empty.
  - Added the required column `hospitalInpatient` to the `ServicesCoverage` table without a default value. This is not possible if the table is not empty.
  - Added the required column `mentalHealthOutpatient` to the `ServicesCoverage` table without a default value. This is not possible if the table is not empty.
  - Added the required column `outpatientSurgery` to the `ServicesCoverage` table without a default value. This is not possible if the table is not empty.
  - Added the required column `preventiveCare` to the `ServicesCoverage` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "ClaimsAndAppeals" DROP COLUMN "appeals_process",
DROP COLUMN "claim_filing_procedure",
ADD COLUMN     "appealsProcess" TEXT NOT NULL,
ADD COLUMN     "claimFilingProcedure" TEXT NOT NULL;

-- AlterTable
ALTER TABLE "Coinsurance" DROP COLUMN "in_network",
DROP COLUMN "out_of_network",
ADD COLUMN     "inNetwork" DOUBLE PRECISION NOT NULL,
ADD COLUMN     "outOfNetwork" DOUBLE PRECISION NOT NULL;

-- AlterTable
ALTER TABLE "Copays" DROP COLUMN "primary_care",
DROP COLUMN "urgent_care",
ADD COLUMN     "primaryCare" DOUBLE PRECISION NOT NULL,
ADD COLUMN     "urgentCare" DOUBLE PRECISION NOT NULL;

-- AlterTable
ALTER TABLE "Deductibles" DROP COLUMN "family_in_network",
DROP COLUMN "family_oop_max",
DROP COLUMN "individual_in_network",
DROP COLUMN "individual_oop_max",
ADD COLUMN     "familyInNetwork" DOUBLE PRECISION NOT NULL,
ADD COLUMN     "familyOopMax" DOUBLE PRECISION NOT NULL,
ADD COLUMN     "individualInNetwork" DOUBLE PRECISION NOT NULL,
ADD COLUMN     "individualOopMax" DOUBLE PRECISION NOT NULL;

-- AlterTable
ALTER TABLE "HealthPlan" DROP COLUMN "coverage_year",
DROP COLUMN "file_name",
DROP COLUMN "plan_name",
DROP COLUMN "plan_type",
DROP COLUMN "prior_authorization_required",
ADD COLUMN     "coverageYear" TEXT NOT NULL,
ADD COLUMN     "fileName" TEXT NOT NULL,
ADD COLUMN     "planName" TEXT NOT NULL,
ADD COLUMN     "planType" TEXT NOT NULL,
ADD COLUMN     "priorAuthorizationRequired" TEXT[];

-- AlterTable
ALTER TABLE "Premium" DROP COLUMN "annual_premium",
DROP COLUMN "employer_contribution",
DROP COLUMN "monthly_premium",
ADD COLUMN     "annualPremium" DOUBLE PRECISION NOT NULL,
ADD COLUMN     "employerContribution" DOUBLE PRECISION NOT NULL,
ADD COLUMN     "monthlyPremium" DOUBLE PRECISION NOT NULL;

-- AlterTable
ALTER TABLE "PrescriptionDrugs" DROP COLUMN "tier_1_generic",
DROP COLUMN "tier_2_preferred",
DROP COLUMN "tier_3_non_preferred",
ADD COLUMN     "tier1Generic" DOUBLE PRECISION NOT NULL,
ADD COLUMN     "tier2Preferred" DOUBLE PRECISION NOT NULL,
ADD COLUMN     "tier3NonPreferred" DOUBLE PRECISION NOT NULL;

-- AlterTable
ALTER TABLE "ServicesCoverage" DROP COLUMN "hospital_inpatient",
DROP COLUMN "mental_health_outpatient",
DROP COLUMN "outpatient_surgery",
DROP COLUMN "preventive_care",
ADD COLUMN     "hospitalInpatient" TEXT NOT NULL,
ADD COLUMN     "mentalHealthOutpatient" TEXT NOT NULL,
ADD COLUMN     "outpatientSurgery" TEXT NOT NULL,
ADD COLUMN     "preventiveCare" TEXT NOT NULL;
