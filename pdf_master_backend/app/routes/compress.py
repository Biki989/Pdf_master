from fastapi import APIRouter, File, UploadFile, HTTPException
import os

from app.utils.file_manager import save_upload_file, get_processed_file_path, cleanup_file
from app.services.pdf_service import compress_pdf

router = APIRouter()

@router.post("/compress-pdf")
async def compress_pdf_endpoint(file: UploadFile = File(...)):
    if not file.filename.endswith('.pdf'):
        raise HTTPException(status_code=400, detail="Only PDF files are allowed.")
        
    saved_path = None
    try:
        saved_path = await save_upload_file(file)
        
        output_path = get_processed_file_path('.pdf')
        compress_pdf(saved_path, output_path)
        
        filename = os.path.basename(output_path)
        return {"status": "success", "download_url": f"/files/{filename}"}
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if saved_path:
            cleanup_file(saved_path)
