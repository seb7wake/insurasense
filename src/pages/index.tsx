import React, { useState, useRef } from "react";
import { AiOutlineCloudUpload, AiOutlineFileAdd } from "react-icons/ai";
import { IoLockClosedOutline } from "react-icons/io5";
import Image from "next/image";

export default function Home() {
  const [file, setFile] = useState<File | null>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);
  const [isUploading, setIsUploading] = useState(false);

  const handleFileChange = async (e: React.ChangeEvent<HTMLInputElement>) => {
    if (!e.target.files) {
      return;
    }

    setIsUploading(true);
    const uploadFile = e.target.files?.[0];
    if (uploadFile) {
      setFile(uploadFile);
    }
    const fileName = uploadFile.name + " - " + Date.now();
    const presignedUrlResponse = await fetch("/api/document/presigned-url", {
      method: "POST",
      body: JSON.stringify({
        fileName,
        fileType: uploadFile.type,
      }),
      headers: {
        "Content-Type": "application/json",
      },
    });

    if (!presignedUrlResponse.ok) {
      throw new Error("Failed to get presigned URL");
    }

    const { presignedUrl } = await presignedUrlResponse.json();

    const uploadResponse = await fetch(presignedUrl, {
      method: "PUT",
      body: uploadFile,
      headers: {
        "Content-Type": uploadFile.type,
      },
    });

    if (!uploadResponse.ok) {
      throw new Error("Failed to upload file");
    }

    const response = await fetch("/api/document/parse", {
      method: "POST",
      body: JSON.stringify({ s3Key: fileName, size: uploadFile.size }),
      headers: {
        "Content-Type": "application/json",
      },
    });
    setIsUploading(false);
    const data = await response.json();
    console.log(data);
  };

  return (
    <div className="min-h-screen bg-white p-8 md:p-16">
      <div className="max-w-6xl mx-auto">
        <div className="space-y-16">
          {/* Main Content */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-16 items-stretch">
            {/* Left Column - Text Content */}
            <div className="space-y-8">
              <h1 className="text-5xl md:text-5xl font-bold bg-gradient-to-r from-gray-800 to-gray-600 bg-clip-text text-transparent leading-tight">
                Effortless Insurance Plan Analysis—All in One Place
              </h1>

              <p className="text-lg text-gray-600 leading-relaxed">
                Upload your insurance policy documents and let our AI instantly
                summarize, compare, and clarify coverage details. Spend less
                time reading the fine print, and more time making confident
                decisions.
              </p>

              {/* Testimonial Card */}
              <div className="bg-gradient-to-br from-white to-gray-50 p-8 rounded-2xl shadow-lg border border-gray-100 mt-12">
                <p className="text-gray-700 text-lg italic mb-6">
                  &quot;This tool helps me quickly understand and explain
                  complex insurance policies to our 200+ employees. The AI
                  summaries save me hours each month.&quot;
                </p>
                <div className="flex items-center gap-4">
                  <div className="w-12 h-12 bg-gradient-to-br from-gray-400 to-gray-300 rounded-full overflow-hidden shadow-md">
                    {/* Placeholder for profile image */}
                  </div>
                  <div>
                    <p className="font-semibold text-gray-800 text-lg">
                      Sarah Martinez
                    </p>
                    <p className="text-gray-500">HR Director</p>
                  </div>
                </div>
              </div>
            </div>

            {/* Right Column - Upload Box */}
            <div className="relative flex justify-center h-full">
              {/* Background illustration */}
              {/* <div className="absolute inset-0 pointer-events-none scale-150 -z-4">
                <Image
                  src="/people-searching.png"
                  alt="People searching for information"
                  className="absolute -left-[10%] -top-[10%] w-[120%] h-[120%] object-contain"
                  width={800}
                  height={800}
                  priority
                />
              </div> */}

              <div
                onClick={() => {
                  fileInputRef.current?.click();
                }}
                className="bg-white hover:bg-gray-50 rounded-lg border-2 border-dashed border-gray-300 p-8 max-w-md w-full h-full transition-all duration-300 hover:border-[#4F46E5] hover:[animation:dash_move_animation_1s_linear_infinite] group cursor-pointer"
              >
                <div className="flex flex-col items-center justify-center space-y-6 h-full">
                  {isUploading ? (
                    <>
                      <div className="relative mb-2">
                        <AiOutlineCloudUpload className="w-16 h-16 text-[#4F46E5] animate-bounce" />
                      </div>
                      <p className="text-xl font-bold text-gray-700">
                        Uploading your file...
                      </p>
                      <p className="text-sm text-gray-500">Please wait</p>
                    </>
                  ) : (
                    <>
                      <div className="relative mb-2">
                        <AiOutlineFileAdd className="w-12 h-12 text-red-500" />
                        <span className="absolute -bottom-1 -right-1 text-xs font-bold bg-red-500 text-white px-1 rounded">
                          PDF
                        </span>
                      </div>
                      <p className="text-xl font-bold text-gray-700">
                        Drop policy file here to start
                      </p>
                      <p className="text-sm text-gray-500 -mt-2">
                        Supports PDF
                      </p>
                      <button className="px-6 py-3 bg-[#4F46E5] text-white rounded-md hover:bg-[#4338CA] transition-colors mt-4">
                        Choose file
                      </button>
                      <input
                        ref={fileInputRef}
                        type="file"
                        accept=".pdf"
                        onChange={handleFileChange}
                        className="hidden"
                      />
                      <div className="flex items-center gap-2 text-sm text-gray-500 mt-6">
                        <IoLockClosedOutline />
                        <span>Files stay private</span>
                      </div>
                    </>
                  )}
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
