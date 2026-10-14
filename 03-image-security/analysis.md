# Phân Tích Chi Tiết Mã Lỗi Lỗ Hổng (CVE Analysis)

## 1. Lỗ Hổng Từ Thư Viện Ứng Dụng (`requirements.txt`)

* **Thư viện bị ảnh hưởng:** `flask==2.0.1`
* **Mã CVE tiêu biểu:** `CVE-2023-30861` (Mức độ: HIGH)
  * **Mô tả:** Rò rỉ Cookie Session vĩnh viễn do thiếu tiêu đề `Vary: Cookie`.
  * **Bản vá (Fixed Version):** Nâng cấp Flask lên phiên bản `2.2.5` hoặc `>= 2.3.2`.

* **Thư viện bị ảnh hưởng:** `werkzeug==2.0.1`
* **Mã CVE tiêu biểu:** `CVE-2023-25577` / `CVE-2024-34069` (Mức độ: HIGH)
  * **Mô tả:** Lỗi tiêu tốn tài nguyên hệ thống / DoS khi xử lý dữ liệu multipart có quá nhiều field.
  * **Bản vá (Fixed Version):** Nâng cấp Werkzeug lên phiên bản `>= 2.2.3` hoặc `3.0.3`.

## 2. Lỗ Hổng Từ Base Image (`python:3.8-slim`)

* **Gói hệ thống lỗi:** `glibc`, `openssl`, `zlib`, `tar` trong hệ điều hành Debian cũ.
* **Giải pháp khắc phục:** 
  - Chuyển sang sử dụng Base Image mới hơn (`python:3.11-slim`).
  - Dùng cơ chế **Multi-stage Build** để chỉ giữ lại các thành phần thực sự cần thiết khi chạy ứng dụng.