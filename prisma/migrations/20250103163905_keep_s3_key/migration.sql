/*
  Warnings:

  - Made the column `s3Key` on table `Job` required. This step will fail if there are existing NULL values in that column.

*/
-- AlterTable
ALTER TABLE "Job" ALTER COLUMN "s3Key" SET NOT NULL;
