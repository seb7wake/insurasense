import os
import json
import boto3
import PyPDF2
from io import BytesIO
from supabase import create_client, Client
import openai
from datetime import datetime
import uuid

def process(event, context):
    print("Loading function in Python")
    
    records = event.get("Records", [])
    for record in records:
        try:
            message_id = record.get("messageId")
            body_str = record.get("body", "{}")
            body = json.loads(body_str)  # e.g. { "s3Key": "uploads/mydoc.pdf", "bucket": "my-bucket" }
            print(f"I am here: {message_id} - {body}")

            # 2. Extract S3 info (adjust if you store bucket differently)
            bucket_name = 'insurance-policy-pdfs'
            s3_key = body.get("s3Key")
            job_id = body.get("jobId")

            if not s3_key:
                print("Missing bucket or s3Key in the message body.")
                continue

            # 3. Download PDF from S3
            pdf_bytes = download_file_from_s3(bucket_name, s3_key)

            # 4. Extract text from PDF, page by page
            pages_text = extract_text_from_pdf(pdf_bytes)

            print(f"Extracted text from PDF: {len(pages_text)} pages")

            # 5. Chunk each page's text into ~500-word segments
            #    (Optionally detect headings or combine them with the text.)
            chunks = []
            for page_number, text in enumerate(pages_text, start=1):
                print(f"Processing page {page_number}")
                page_chunks = chunk_text(text, page_number, max_words=400)
                chunks.extend(page_chunks)

            # 6. Insert chunks into Supabase (vector DB or standard table)
            #    Adjust to your schema / table name / vector embeddings approach
            supabase_client = get_supabase_vector_db_client()
            store_chunks_in_supabase(supabase_client, chunks, s3_key)

            plan_id = save_plan_insurer_data(s3_key, supabase_client)
            save_financial_data(plan_id, s3_key, supabase_client)
            save_coverage_data(plan_id, s3_key, supabase_client)
            update_job_status(job_id, "completed")
        except Exception as e:
            print(f"Error processing message {message_id}: {e}")
            update_job_status(job_id, "failed")

    return f"Successfully processed {len(records)} messages."


def download_file_from_s3(bucket_name: str, key: str) -> bytes:
    """
    Downloads the file from S3 and returns it as bytes.
    """
    s3 = boto3.client("s3")
    file_stream = BytesIO()
    s3.download_fileobj(bucket_name, key, file_stream)
    file_stream.seek(0)
    return file_stream.read()


def extract_text_from_pdf(pdf_data: bytes) -> list[str]:
    """
    Extracts text from each page of a PDF.
    Returns a list of strings, one per page.
    """
    pages_text = []
    with BytesIO(pdf_data) as pdf_stream:
        reader = PyPDF2.PdfReader(pdf_stream)
        for page_index in range(len(reader.pages)):
            page = reader.pages[page_index]
            text = page.extract_text() or ""  # handle None
            pages_text.append(text.strip())
    return pages_text


def chunk_text(text: str, page_number: int, max_words=500) -> list[dict]:
    """
    Splits text into ~max_words segments.
    Returns a list of dictionaries: 
      [ { "page_number": <int>, "heading": <str>, "chunk_text": <str> }, ... ]
    Currently doesn't detect headings; `heading` remains an empty string or placeholder.
    """
    words = text.split()
    chunks = []
    start_index = 0

    while start_index < len(words):
        end_index = start_index + max_words
        subset = words[start_index:end_index]
        chunk_str = " ".join(subset)
        chunk_data = {
            "page_number": page_number,
            "heading": "",  # or implement heading detection logic
            "chunk_text": chunk_str
        }
        chunks.append(chunk_data)
        start_index = end_index

    return chunks


def get_supabase_vector_db_client() -> Client:
    """
    Creates and returns a Supabase client.
    Requires SUPABASE_URL and SUPABASE_KEY in environment variables.
    """
    url = os.getenv("VECTOR_DATABASE_URL")
    key = os.getenv("SERVICE_ROLE_SECRET")
    return create_client(url, key)

def get_supabase_client() -> Client:
    """
    Creates and returns a Supabase client.
    Requires SUPABASE_URL and SUPABASE_KEY in environment variables.
    """
    url = os.getenv("DATABASE_URL_DEV")
    key = os.getenv("SERVICE_ROLE_SECRET_DEV")
    return create_client(url, key)


def store_chunks_in_supabase(supabase_client: Client, chunks: list[dict], s3_key: str):
    openai.api_key = os.getenv("OPENAI_API_KEY")
    if not openai.api_key:
        raise RuntimeError("OPENAI_API_KEY environment variable not set")

    all_rows = []
    for chunk in chunks:
        chunk_text = chunk["chunk_text"]
        page_number = chunk["page_number"]

        # 1. Generate the embedding via OpenAI
        response = openai.embeddings.create(
            model="text-embedding-ada-002",
            input=chunk_text
        )
        # Extract the embedding array from the response
        embedding_vector = response.data[0].embedding

        # 2. Prepare the row for insertion
        row_data = {
            "page_number": page_number,
            "content": chunk_text,
            "embedding": embedding_vector,  # pgvector column
            "plan_name": s3_key,
            "created_at": datetime.now().isoformat()
        }
        all_rows.append(row_data)

    # 3. Batch insert all rows into Supabase 'documents' table
    response = supabase_client.table("documents").insert(all_rows).execute()

def save_plan_insurer_data(s3_key: str, vector_db_client: Client) -> str:
    db_client = get_supabase_client()
    json_structure = """
        {
            "planName": "XYZ Health Choice Silver 2000", 
            "insurer": {
                "name": "XYZ Insurance Co.",
                "phone": "1-800-123-4567",
                "address": "1234 Main St, Anytown, USA 12345",
                "website": "https://xyzinsurance.com"
            },
            "planType": "PPO",
            "coverageYear": "2024"
        }
    """
    print("embedding response")
    embedding_response = openai.embeddings.create(
        model="text-embedding-ada-002",
        input="Please extract the plan name, insurer name, insurer phone number, insurer address, insurer website, insurance plan type (PPO, HMO, POS, etc), and coverage year."
    )
    embedding_vector = embedding_response.data[0].embedding

    embeddings = vector_db_client.rpc(
        'match_documents', 
        {
            'query_embedding': embedding_vector,
            'match_threshold': 0.6,
            'match_count': 5,
            'file_name': s3_key
        }
    ).execute()
    print("insurer embeddings: ", embeddings)

    try:
        json_result = get_json_result(embeddings, json_structure)
        if not json_result or json_result.isspace():
            raise ValueError("Empty or whitespace-only JSON result")
        plan_dict = json.loads(json_result)
    except (json.JSONDecodeError, ValueError) as e:
        print(f"Error parsing JSON result: {e}")
        # Provide a default structure matching the schema
        plan_dict = {
            "planName": s3_key,
            "insurer": {
                "name": "Unknown",
                "phone": None,
                "address": None, 
                "website": None
            },
            "planType": None,
            "coverageYear": None
        }

    print("plan_dict: ", plan_dict)

    # First create the insurer record
    insurer_data = plan_dict.pop("insurer")  # Remove insurer from plan_dict
    insurer_data["id"] = str(uuid.uuid4())  # Add an ID for the insurer
    insurer_data["updatedAt"] = datetime.now().isoformat()  # Add updatedAt timestamp
    print("saving insurer: ", insurer_data)
    insurer_result = db_client.from_("Insurer").insert(insurer_data).execute()
    insurer_id = insurer_result.data[0]["id"]

    # Add the insurer ID reference to the plan
    plan_dict["insurerId"] = insurer_id
    
    # Now create the health plan with the insurer reference
    plan_dict["id"] = str(uuid.uuid4())  # Add an ID for the health plan
    plan_dict["updatedAt"] = datetime.now().isoformat()  # Add updatedAt timestamp
    plan_dict["createdAt"] = datetime.now().isoformat()  # Add createdAt timestamp
    print("saving health plan: ", plan_dict)
    plan_result = db_client.from_("HealthPlan").insert(plan_dict).execute()
    plan_id = plan_result.data[0]["id"]
    return plan_id

def save_financial_data(plan_id: str, s3_key: str, vector_db_client: Client):
    db_client = get_supabase_client()
    json_structure = """
        {
            "premium": {
                "monthlyPremium": 350,
                "annualPremium": 4200,
                "employerContribution": 200
            },
            "deductibles": {
                "individualInNetwork": 2000,
                "familyInNetwork": 4000,
                "individualOopMax": 6000,
                "familyOopMax": 12000
            },
            "copays": {
                "primaryCare": 20,
                "specialist": 40,
                "er": 300,
                "urgentCare": 75,
                "prescriptionDrugs": {
                    "tier1Generic": 10,
                    "tier2Preferred": 30,
                    "tier3NonPreferred": 50
                }
            }
        }
    """
    embedding_response = openai.embeddings.create(
        model="text-embedding-ada-002",
        input="Please extract the premium, deductibles, copays, and prescription drugs information from the plan and their cost ($)."
    )
    embedding_vector = embedding_response.data[0].embedding

    embeddings = vector_db_client.rpc(
        'match_documents', 
        {
            'query_embedding': embedding_vector,
            'match_threshold': 0.6,
            'match_count': 5,
            'file_name': s3_key
        }
    ).execute()
    print("financial embeddings: ", embeddings)

    json_result = get_json_result(embeddings, json_structure)
    financial_dict = json.loads(json_result)

    print("saving financial data: ", financial_dict)

    # Save premium data
    premium_result = db_client.from_("Premium").insert({
        "id": str(uuid.uuid4()),
        "monthlyPremium": financial_dict["premium"]["monthlyPremium"],
        "annualPremium": financial_dict["premium"]["annualPremium"], 
        "employerContribution": financial_dict["premium"]["employerContribution"],
        "createdAt": datetime.now().isoformat(),
        "updatedAt": datetime.now().isoformat()
    }).execute()
    premium_id = premium_result.data[0]["id"]

    print("saving deductibles: ", financial_dict["deductibles"])
    # Save deductibles data
    deductibles_result = db_client.from_("Deductibles").insert({
        "id": str(uuid.uuid4()),
        "individualInNetwork": financial_dict["deductibles"]["individualInNetwork"],
        "familyInNetwork": financial_dict["deductibles"]["familyInNetwork"],
        "individualOopMax": financial_dict["deductibles"]["individualOopMax"],
        "familyOopMax": financial_dict["deductibles"]["familyOopMax"],
        "createdAt": datetime.now().isoformat(),
        "updatedAt": datetime.now().isoformat()
    }).execute()
    deductibles_id = deductibles_result.data[0]["id"]

    # Save copays data
    print("saving copays: ", financial_dict["copays"])
    copays_result = db_client.from_("Copays").insert({
        "id": str(uuid.uuid4()),
        "primaryCare": financial_dict["copays"]["primaryCare"],
        "specialist": financial_dict["copays"]["specialist"],
        "er": financial_dict["copays"]["er"],
        "urgentCare": financial_dict["copays"]["urgentCare"],
        "prescriptionDrugsTier1Generic": financial_dict["copays"]["prescriptionDrugs"]["tier1Generic"],
        "prescriptionDrugsTier2Preferred": financial_dict["copays"]["prescriptionDrugs"]["tier2Preferred"],
        "prescriptionDrugsTier3NonPreferred": financial_dict["copays"]["prescriptionDrugs"]["tier3NonPreferred"],
        "createdAt": datetime.now().isoformat(),
        "updatedAt": datetime.now().isoformat()
    }).execute()
    copays_id = copays_result.data[0]["id"]

    # Update HealthPlan with relation IDs
    print("updating health plan: ", plan_id)
    db_client.from_("HealthPlan").update({
        "premiumId": premium_id,
        "deductiblesId": deductibles_id,
        "copaysId": copays_id,
        "updatedAt": datetime.now().isoformat()
    }).eq("id", plan_id).execute()

def save_coverage_data(plan_id: str, s3_key: str, vector_db_client: Client):
    db_client = get_supabase_client()
    json_structure = """
        {
            "coinsurance": {
                "inNetwork": 0.2,
                "outOfNetwork": 0.4
            },
            "servicesCoverage": {
                "preventiveCare": "Covered at 100% in-network",
                "hospitalInpatient": "20% coinsurance after deductible",
                "outpatientSurgery": "20% coinsurance after deductible",
                "mentalHealthOutpatient": "40% after deductible (out-of-network)",
                "telehealth": "$10 copay"
            },
            "exclusions": [
                "Cosmetic procedures",
                "Experimental treatments"
            ],
            "priorAuthorizationRequired": [
                "MRI/CT scans",
                "Specialty drugs"
            ],
            "claimsAndAppeals": {
                "claimFilingProcedure": "Submit claims within 90 days of service. Include member ID, provider info, and itemized bill. File electronically through provider portal or mail to claims address.",
                "appealsProcess": "Appeals must be filed within 180 days of claim denial. Submit written appeal with supporting documentation. First level review completed within 30 days. Second level review available if needed."
            },
            "disclaimers": [
                "This is a summary of benefits only. Please refer to your plan documents for complete coverage details.",
                "Benefits and coverage may vary by state and are subject to applicable laws and regulations.",
                "Coverage decisions are subject to medical necessity and plan policies.",
                "Provider network participation may change without notice.",
                "Premium rates and benefits are subject to change upon renewal."
            ]
        }
    """
    embedding_response = openai.embeddings.create(
        model="text-embedding-ada-002",
        input="Please extract the coinsurance, services coverage, exclusions, prior authorization required, claims and appeals, and disclaimers information from the plan."
    )
    embedding_vector = embedding_response.data[0].embedding

    embeddings = vector_db_client.rpc(
        'match_documents', 
        {
            'query_embedding': embedding_vector,
            'match_threshold': 0.6,
            'match_count': 5,
            'file_name': s3_key
        }
    ).execute()

    json_result = get_json_result(embeddings, json_structure)
    coverage_dict = json.loads(json_result)

    print("saving coverage data: ", coverage_dict)

    # Update coinsurance
    if "coinsurance" in coverage_dict:
        coinsurance_data = coverage_dict.pop("coinsurance")
        coinsurance_data["id"] = str(uuid.uuid4())
        coinsurance_data["createdAt"] = datetime.now().isoformat()
        coinsurance_data["updatedAt"] = datetime.now().isoformat()
        db_client.from_("Coinsurance").insert(coinsurance_data).execute()

    # Update services coverage
    if "servicesCoverage" in coverage_dict:
        services_coverage_data = coverage_dict.pop("servicesCoverage")
        services_coverage_data["id"] = str(uuid.uuid4())
        services_coverage_data["createdAt"] = datetime.now().isoformat()
        services_coverage_data["updatedAt"] = datetime.now().isoformat()
        db_client.from_("ServicesCoverage").insert(services_coverage_data).execute()

    # Update exclusions, prior auth, disclaimers
    health_plan_updates = {
        "exclusions": coverage_dict.get("exclusions", []),
        "priorAuthorizationRequired": coverage_dict.get("priorAuthorizationRequired", []),
        "disclaimers": coverage_dict.get("disclaimers", [])
    }
    db_client.from_("HealthPlan").update(health_plan_updates).eq("id", plan_id).execute()

    # Update claims and appeals
    if "claimsAndAppeals" in coverage_dict:
        claims_and_appeals_data = coverage_dict.pop("claimsAndAppeals")
        claims_and_appeals_data["id"] = str(uuid.uuid4())
        claims_and_appeals_data["createdAt"] = datetime.now().isoformat()
        claims_and_appeals_data["updatedAt"] = datetime.now().isoformat()
        db_client.from_("ClaimsAndAppeals").insert(claims_and_appeals_data).execute()

def update_job_status(job_id: str, status: str):
    db_client = get_supabase_client()
    db_client.from_("Job").update({"status": status}).eq("id", job_id).execute()

def get_json_result(embeddings: str, json_structure: str) -> str:
    res = openai.chat.completions.create(
        model="gpt-4-turbo",
        messages=[
            {
                "role": "system",
                "content": (
                    "You are an assistant designed to extract structured data about insurance plans "
                    "from text embeddings. Please return the information in the format provided below. "
                ),
            },
            {
                "role": "user",
                "content": (
                    f"Given the following extracted embeddings from a PDF, extract the required data. "
                    f"Do not provide explanations or commentary in your response; respond with the JSON object only.\n"
                    f"JSON structure example:\n{json_structure}\n\n"
                    f"Embeddings content:\n{embeddings}"
                ),
            },
        ],
    )
    return res.choices[0].message.content