/*
  Warnings:

  - You are about to drop the column `prescriptionDrugsId` on the `Copays` table. All the data in the column will be lost.
  - You are about to drop the `PrescriptionDrugs` table. If the table is not empty, all the data it contains will be lost.

*/
-- DropForeignKey
ALTER TABLE "Copays" DROP CONSTRAINT "Copays_prescriptionDrugsId_fkey";

-- DropForeignKey
ALTER TABLE "PrescriptionDrugs" DROP CONSTRAINT "PrescriptionDrugs_healthPlanId_fkey";

-- AlterTable
ALTER TABLE "Copays" DROP COLUMN "prescriptionDrugsId",
ADD COLUMN     "prescriptionDrugsTier1Generic" DOUBLE PRECISION,
ADD COLUMN     "prescriptionDrugsTier2Preferred" DOUBLE PRECISION,
ADD COLUMN     "prescriptionDrugsTier3NonPreferred" DOUBLE PRECISION;

-- DropTable
DROP TABLE "PrescriptionDrugs";
