import os
from PyPDF2 import PdfReader, PdfWriter
from pdf2image import convert_from_path
from PIL import Image

def merge_pdfs(input_paths: list[str], output_path: str):
    writer = PdfWriter()
    for path in input_paths:
        reader = PdfReader(path)
        for page in reader.pages:
            writer.add_page(page)
    with open(output_path, "wb") as out_pdf:
        writer.write(out_pdf)

def split_pdf(input_path: str, output_dir: str) -> list[str]:
    reader = PdfReader(input_path)
    output_paths = []
    base_name = os.path.splitext(os.path.basename(input_path))[0]
    for i, page in enumerate(reader.pages):
        writer = PdfWriter()
        writer.add_page(page)
        out_path = os.path.join(output_dir, f"{base_name}_page_{i+1}.pdf")
        with open(out_path, "wb") as out_pdf:
            writer.write(out_pdf)
        output_paths.append(out_path)
    return output_paths

def images_to_pdf(image_paths: list[str], output_path: str):
    images = []
    for path in image_paths:
        img = Image.open(path)
        if img.mode != 'RGB':
            img = img.convert('RGB')
        images.append(img)
    
    if images:
        images[0].save(output_path, save_all=True, append_images=images[1:])

def compress_pdf(input_path: str, output_path: str):
    # PyPDF2 compression is limited, but we can do a basic compression
    reader = PdfReader(input_path)
    writer = PdfWriter()
    for page in reader.pages:
        page.compress_content_streams()
        writer.add_page(page)
    with open(output_path, "wb") as out_pdf:
        writer.write(out_pdf)

def rotate_pdf(input_path: str, output_path: str, angle: int):
    reader = PdfReader(input_path)
    writer = PdfWriter()
    for page in reader.pages:
        page.rotate(angle)
        writer.add_page(page)
    with open(output_path, "wb") as out_pdf:
        writer.write(out_pdf)

def delete_pages(input_path: str, output_path: str, pages_to_delete: list[int]):
    reader = PdfReader(input_path)
    writer = PdfWriter()
    # pages_to_delete should be 0-indexed internally, exposed as 1-indexed to user if needed
    for i, page in enumerate(reader.pages):
        if i not in pages_to_delete:
            writer.add_page(page)
    with open(output_path, "wb") as out_pdf:
        writer.write(out_pdf)
