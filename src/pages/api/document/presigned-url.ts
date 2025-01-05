import { PutObjectCommand } from "@aws-sdk/client-s3";
import { NextApiRequest } from "next";
import { NextApiResponse } from "next";
import { s3Client } from "../../../../lib/aws";
import { getSignedUrl } from "@aws-sdk/s3-request-presigner";

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  try {
    const { fileName, fileType } = req.body;
    if (!fileName || !fileType) {
      return res.status(400).json({ error: "Missing fileName or fileType" });
    }

    const params = {
      Bucket: process.env.AWS_S3_BUCKET_NAME,
      Key: fileName,
      ContentType: fileType,
    };

    // Generate a presigned URL for a PUT
    const presignedUrl = await getSignedUrl(
      s3Client,
      new PutObjectCommand(params),
      { expiresIn: 60 * 5 } // URL expires in 5 minutes
    );

    res.status(200).json({ presignedUrl });
  } catch (error) {
    console.error("Error generating presigned URL:", error);
    res.status(500).json({ error: "Error generating presigned URL" });
  }
}
