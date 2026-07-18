# PDF Master Tools - Deployment Guide

This project consists of two components:
1. **pdf_master_backend**: FastAPI Python backend for advanced PDF processing
2. **pdf_master_tools_app**: Flutter cross-platform mobile app

## 1. FastAPI Backend Deployment

### Run Locally for Testing
Navigate to the backend directory and run:
```bash
cd pdf_master_backend
pip install -r requirements.txt
uvicorn app.main:app --host 0.0.0.0 --port 8000
```
*Note: Make sure your Flutter app `ApiService` updates the `baseUrl` to point to the server's public IP.*

### Docker Deployment
Inside the `pdf_master_backend` folder, you can deploy using Docker.
```dockerfile
# Dockerfile snippet example
FROM python:3.10-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
EXPOSE 8000
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```
Build and run:
`docker build -t pdfmaster-api .`
`docker run -p 8000:8000 pdfmaster-api`

### Cloud Deployment (Render / Railway)
1. Push the `pdf_master_backend` folder to a GitHub repository.
2. Link the repository to your Render or Railway dashboard.
3. Set the Start Command:
   `uvicorn app.main:app --host 0.0.0.0 --port $PORT`
   
### AWS (Elastic Beanstalk or EC2)
1. Provision an EC2 instance with Python 3.10.
2. Install dependencies via `pip install -r requirements.txt`.
3. Use a production Server like Gunicorn with Uvicorn workers:
   `gunicorn app.main:app -w 4 -k uvicorn.workers.UvicornWorker -b 0.0.0.0:8000`
4. Setup Nginx reverse-proxy targeting port `8000`.

---

## 2. Flutter Mobile App Build

### Setup
Ensure you have the Flutter SDK installed and configure your environment (Android Studio / Xcode).
```bash
cd pdf_master_tools_app
flutter pub get
```

### Adjusting API URL
Before building for production, open `lib/services/api_service.dart` and change `baseUrl` from `http://10.0.2.2:8000` to your production URL (e.g., `https://api.pdfmaster.com`).

### Build Android APK
Generate a release FAT APK for Android devices:
```bash
flutter build apk --release
```
The file will be output to: `build/app/outputs/flutter-apk/app-release.apk`

### Build iOS App
Generate the iOS build for App Store deployment (Requires macOS and Xcode):
```bash
flutter build ios --release
```
Open `ios/Runner.xcworkspace` in Xcode to configure signing and publish via App Store Connect.
