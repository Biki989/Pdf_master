from fastapi import APIRouter, File, UploadFile, Form, HTTPException
import os

from app.utils.file_manager import save_upload_file, get_processed_file_path, cleanup_file
from app.services.pdf_service import rotate_pdf

router = APIRouter()

@router.post("/rotate-pdf")
async def rotate_pdf_endpoint(
    angle: int = Form(...),
    file: UploadFile = File(...)
):
    if not file.filename.endswith('.pdf'):
        raise HTTPException(status_code=400, detail="Only PDF files are allowed.")
        
    if angle not in [90, 180, 270]:
        raise HTTPException(status_code=400, detail="Angle must be 90, 180, or 270.")
        
    saved_path = None
    try:
        saved_path = await save_upload_file(file)
        
        output_path = get_processed_file_path('.pdf')
        rotate_pdf(saved_path, output_path, angle)
        
        filename = os.path.basename(output_path)
        return {"status": "success", "download_url": f"/files/{filename}"}
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if saved_path:
            cleanup_file(saved_path)
