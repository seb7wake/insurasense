/*
  Warnings:

  - Added the required column `updatedAt` to the `ClaimsAndAppeals` table without a default value. This is not possible if the table is not empty.
  - Added the required column `updatedAt` to the `Coinsurance` table without a default value. This is not possible if the table is not empty.
  - Added the required column `updatedAt` to the `Copays` table without a default value. This is not possible if the table is not empty.
  - Added the required column `updatedAt` to the `Deductibles` table without a default value. This is not possible if the table is not empty.
  - Added the required column `updatedAt` to the `HealthPlan` table without a default value. This is not possible if the table is not empty.
  - Added the required column `updatedAt` to the `Insurer` table without a default value. This is not possible if the table is not empty.
  - Added the required column `updatedAt` to the `Premium` table without a default value. This is not possible if the table is not empty.
  - Added the required column `updatedAt` to the `PrescriptionDrugs` table without a default value. This is not possible if the table is not empty.
  - Added the required column `updatedAt` to the `ServicesCoverage` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "ClaimsAndAppeals" ADD COLUMN     "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN     "updatedAt" TIMESTAMP(3) NOT NULL,
ALTER COLUMN "appealsProcess" DROP NOT NULL,
ALTER COLUMN "claimFilingProcedure" DROP NOT NULL;

-- AlterTable
ALTER TABLE "Coinsurance" ADD COLUMN     "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN     "updatedAt" TIMESTAMP(3) NOT NULL,
ALTER COLUMN "inNetwork" DROP NOT NULL,
ALTER COLUMN "outOfNetwork" DROP NOT NULL;

-- AlterTable
ALTER TABLE "Copays" ADD COLUMN     "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN     "updatedAt" TIMESTAMP(3) NOT NULL,
ALTER COLUMN "specialist" DROP NOT NULL,
ALTER COLUMN "er" DROP NOT NULL,
ALTER COLUMN "primaryCare" DROP NOT NULL,
ALTER COLUMN "urgentCare" DROP NOT NULL;

-- AlterTable
ALTER TABLE "Deductibles" ADD COLUMN     "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN     "updatedAt" TIMESTAMP(3) NOT NULL,
ALTER COLUMN "familyInNetwork" DROP NOT NULL,
ALTER COLUMN "familyOopMax" DROP NOT NULL,
ALTER COLUMN "individualInNetwork" DROP NOT NULL,
ALTER COLUMN "individualOopMax" DROP NOT NULL;

-- AlterTable
ALTER TABLE "HealthPlan" ADD COLUMN     "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN     "updatedAt" TIMESTAMP(3) NOT NULL,
ALTER COLUMN "coverageYear" DROP NOT NULL,
ALTER COLUMN "fileName" DROP NOT NULL,
ALTER COLUMN "planName" DROP NOT NULL,
ALTER COLUMN "planType" DROP NOT NULL;

-- AlterTable
ALTER TABLE "Insurer" ADD COLUMN     "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN     "updatedAt" TIMESTAMP(3) NOT NULL,
ALTER COLUMN "phone" DROP NOT NULL,
ALTER COLUMN "address" DROP NOT NULL,
ALTER COLUMN "website" DROP NOT NULL;

-- AlterTable
ALTER TABLE "Job" ALTER COLUMN "s3Key" DROP NOT NULL,
ALTER COLUMN "fileSize" DROP NOT NULL,
ALTER COLUMN "planId" DROP NOT NULL;

-- AlterTable
ALTER TABLE "Premium" ADD COLUMN     "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN     "updatedAt" TIMESTAMP(3) NOT NULL,
ALTER COLUMN "annualPremium" DROP NOT NULL,
ALTER COLUMN "employerContribution" DROP NOT NULL,
ALTER COLUMN "monthlyPremium" DROP NOT NULL;

-- AlterTable
ALTER TABLE "PrescriptionDrugs" ADD COLUMN     "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN     "updatedAt" TIMESTAMP(3) NOT NULL,
ALTER COLUMN "tier1Generic" DROP NOT NULL,
ALTER COLUMN "tier2Preferred" DROP NOT NULL,
ALTER COLUMN "tier3NonPreferred" DROP NOT NULL;

-- AlterTable
ALTER TABLE "ServicesCoverage" ADD COLUMN     "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN     "updatedAt" TIMESTAMP(3) NOT NULL,
ALTER COLUMN "telehealth" DROP NOT NULL,
ALTER COLUMN "hospitalInpatient" DROP NOT NULL,
ALTER COLUMN "mentalHealthOutpatient" DROP NOT NULL,
ALTER COLUMN "outpatientSurgery" DROP NOT NULL,
ALTER COLUMN "preventiveCare" DROP NOT NULL;
