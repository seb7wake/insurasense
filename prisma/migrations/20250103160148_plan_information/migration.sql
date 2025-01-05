/*
  Warnings:

  - Added the required column `fileSize` to the `Job` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "Job" ADD COLUMN     "fileSize" INTEGER NOT NULL;

-- CreateTable
CREATE TABLE "HealthPlan" (
    "id" TEXT NOT NULL,
    "plan_name" TEXT NOT NULL,
    "file_name" TEXT NOT NULL,
    "plan_type" TEXT NOT NULL,
    "coverage_year" TEXT NOT NULL,
    "insurerId" TEXT,
    "premiumId" TEXT,
    "deductiblesId" TEXT,
    "copaysId" TEXT,
    "coinsuranceId" TEXT,
    "servicesCoverageId" TEXT,
    "exclusions" TEXT[],
    "prior_authorization_required" TEXT[],
    "claimsAndAppealsId" TEXT,
    "disclaimers" TEXT[],

    CONSTRAINT "HealthPlan_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Insurer" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "phone" TEXT NOT NULL,
    "address" TEXT NOT NULL,
    "website" TEXT NOT NULL,

    CONSTRAINT "Insurer_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Premium" (
    "id" TEXT NOT NULL,
    "monthly_premium" DOUBLE PRECISION NOT NULL,
    "annual_premium" DOUBLE PRECISION NOT NULL,
    "employer_contribution" DOUBLE PRECISION NOT NULL,

    CONSTRAINT "Premium_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Deductibles" (
    "id" TEXT NOT NULL,
    "individual_in_network" DOUBLE PRECISION NOT NULL,
    "family_in_network" DOUBLE PRECISION NOT NULL,
    "individual_oop_max" DOUBLE PRECISION NOT NULL,
    "family_oop_max" DOUBLE PRECISION NOT NULL,

    CONSTRAINT "Deductibles_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Copays" (
    "id" TEXT NOT NULL,
    "primary_care" DOUBLE PRECISION NOT NULL,
    "specialist" DOUBLE PRECISION NOT NULL,
    "er" DOUBLE PRECISION NOT NULL,
    "urgent_care" DOUBLE PRECISION NOT NULL,
    "prescriptionDrugsId" TEXT NOT NULL,

    CONSTRAINT "Copays_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PrescriptionDrugs" (
    "id" TEXT NOT NULL,
    "tier_1_generic" DOUBLE PRECISION NOT NULL,
    "tier_2_preferred" DOUBLE PRECISION NOT NULL,
    "tier_3_non_preferred" DOUBLE PRECISION NOT NULL,
    "healthPlanId" TEXT,

    CONSTRAINT "PrescriptionDrugs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Coinsurance" (
    "id" TEXT NOT NULL,
    "in_network" DOUBLE PRECISION NOT NULL,
    "out_of_network" DOUBLE PRECISION NOT NULL,

    CONSTRAINT "Coinsurance_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ServicesCoverage" (
    "id" TEXT NOT NULL,
    "preventive_care" TEXT NOT NULL,
    "hospital_inpatient" TEXT NOT NULL,
    "outpatient_surgery" TEXT NOT NULL,
    "mental_health_outpatient" TEXT NOT NULL,
    "telehealth" TEXT NOT NULL,

    CONSTRAINT "ServicesCoverage_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ClaimsAndAppeals" (
    "id" TEXT NOT NULL,
    "claim_filing_procedure" TEXT NOT NULL,
    "appeals_process" TEXT NOT NULL,

    CONSTRAINT "ClaimsAndAppeals_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "HealthPlan_insurerId_key" ON "HealthPlan"("insurerId");

-- CreateIndex
CREATE UNIQUE INDEX "HealthPlan_premiumId_key" ON "HealthPlan"("premiumId");

-- CreateIndex
CREATE UNIQUE INDEX "HealthPlan_deductiblesId_key" ON "HealthPlan"("deductiblesId");

-- CreateIndex
CREATE UNIQUE INDEX "HealthPlan_copaysId_key" ON "HealthPlan"("copaysId");

-- CreateIndex
CREATE UNIQUE INDEX "HealthPlan_coinsuranceId_key" ON "HealthPlan"("coinsuranceId");

-- CreateIndex
CREATE UNIQUE INDEX "HealthPlan_servicesCoverageId_key" ON "HealthPlan"("servicesCoverageId");

-- CreateIndex
CREATE UNIQUE INDEX "HealthPlan_claimsAndAppealsId_key" ON "HealthPlan"("claimsAndAppealsId");

-- AddForeignKey
ALTER TABLE "HealthPlan" ADD CONSTRAINT "HealthPlan_insurerId_fkey" FOREIGN KEY ("insurerId") REFERENCES "Insurer"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "HealthPlan" ADD CONSTRAINT "HealthPlan_premiumId_fkey" FOREIGN KEY ("premiumId") REFERENCES "Premium"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "HealthPlan" ADD CONSTRAINT "HealthPlan_deductiblesId_fkey" FOREIGN KEY ("deductiblesId") REFERENCES "Deductibles"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "HealthPlan" ADD CONSTRAINT "HealthPlan_copaysId_fkey" FOREIGN KEY ("copaysId") REFERENCES "Copays"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "HealthPlan" ADD CONSTRAINT "HealthPlan_coinsuranceId_fkey" FOREIGN KEY ("coinsuranceId") REFERENCES "Coinsurance"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "HealthPlan" ADD CONSTRAINT "HealthPlan_servicesCoverageId_fkey" FOREIGN KEY ("servicesCoverageId") REFERENCES "ServicesCoverage"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "HealthPlan" ADD CONSTRAINT "HealthPlan_claimsAndAppealsId_fkey" FOREIGN KEY ("claimsAndAppealsId") REFERENCES "ClaimsAndAppeals"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Copays" ADD CONSTRAINT "Copays_prescriptionDrugsId_fkey" FOREIGN KEY ("prescriptionDrugsId") REFERENCES "PrescriptionDrugs"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PrescriptionDrugs" ADD CONSTRAINT "PrescriptionDrugs_healthPlanId_fkey" FOREIGN KEY ("healthPlanId") REFERENCES "HealthPlan"("id") ON DELETE SET NULL ON UPDATE CASCADE;
