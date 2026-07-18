from fastapi import APIRouter, File, UploadFile, Form, HTTPException
import os
import json

from app.utils.file_manager import save_upload_file, get_processed_file_path, cleanup_file
from app.services.pdf_service import delete_pages

router = APIRouter()

@router.post("/delete-pages")
async def delete_pages_endpoint(
    pages: str = Form(...),  # Expecting JSON string of 0-indexed page numbers like "[0, 2]"
    file: UploadFile = File(...)
):
    if not file.filename.endswith('.pdf'):
        raise HTTPException(status_code=400, detail="Only PDF files are allowed.")
        
    try:
        pages_to_delete = json.loads(pages)
        if not isinstance(pages_to_delete, list):
            raise ValueError()
    except:
        raise HTTPException(status_code=400, detail="pages must be a valid JSON list of integers.")
        
    saved_path = None
    try:
        saved_path = await save_upload_file(file)
        
        output_path = get_processed_file_path('.pdf')
        delete_pages(saved_path, output_path, pages_to_delete)
        
        filename = os.path.basename(output_path)
        return {"status": "success", "download_url": f"/files/{filename}"}
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if saved_path:
            cleanup_file(saved_path)
