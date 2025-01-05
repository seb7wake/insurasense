import { sqsClient } from "../lib/aws";
import { SendMessageCommand } from "@aws-sdk/client-sqs";
import prisma from "../lib/prisma";
export class ProcessDocument {
  constructor() {}

  async process(s3Key: string, size: number) {
    const jobId = await this.createJob(s3Key, size);
    await this.sendToQueue(s3Key, jobId);
  }

  async sendToQueue(s3Key: string, jobId: string) {
    const params = {
      QueueUrl: process.env.AWS_SQS_QUEUE_URL!,
      MessageBody: JSON.stringify({ s3Key, jobId })
    };
    await sqsClient.send(new SendMessageCommand(params));
  }

  async createJob(s3Key: string, size: number) {
    const job = await prisma.job.create({
      data: {
        s3Key,
        fileSize: size,
        status: "pending",
        userId: "1",
      },
    });
    return job.id;
  }
}
