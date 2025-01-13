# مرحله اول: ساختن وابستگی‌ها
FROM python:3.9-slim AS builder

# نصب ابزارهای لازم برای ساخت و اجرای پروژه
RUN apt-get update && apt-get install -y --no-install-recommends gcc && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# تنظیم دایرکتوری کاری
WORKDIR /app

# کپی فایل‌های مورد نیاز
COPY requirements.txt .

# نصب وابستگی‌ها بدون ذخیره کش
RUN pip install --no-cache-dir -r requirements.txt && \
    python -m spacy download en_core_web_sm

# مرحله دوم: ایمیج نهایی
FROM python:3.9-slim

# تنظیم دایرکتوری کاری
WORKDIR /app

# کپی فقط فایل‌های مورد نیاز از مرحله قبلی
COPY --from=builder /usr/local/lib/python3.9 /usr/local/lib/python3.9
COPY --from=builder /usr/local/bin /usr/local/bin

# کپی کدهای پروژه به ایمیج نهایی
COPY . .

# تنظیم متغیرهای محیطی
ENV FLASK_APP=app.py
ENV FLASK_ENV=production

# حذف فایل‌های غیرضروری
RUN apt-get purge -y gcc && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

# پورت قابل دسترس
EXPOSE 5000

# فرمان اجرا
CMD ["python", "app.py"]
