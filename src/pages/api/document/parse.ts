import { NextApiResponse } from "next";
import { NextApiRequest } from "next";
import { ProcessDocument } from "../../../../services/process_document";

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method === "POST") {
    try {
      const s3Key = req.body.s3Key;
      const size = req.body.size;
      const processDocument = new ProcessDocument();
      await processDocument.process(s3Key, size);

      res.status(200).json({ message: "File processed successfully" });
    } catch (error) {
      console.error("Error processing file:", error);
      res.status(500).json({ error: "Error processing file" });
    }
  } else {
    res.status(405).json({ error: "Method not allowed" });
  }
}
