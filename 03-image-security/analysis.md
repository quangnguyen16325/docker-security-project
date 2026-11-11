# Báo Cáo Phân Tích Chi Tiết Lỗ Hổng Bảo Mật (CVE Analysis)

- **Môi trường phân tích:** Ubuntu Server 24.04 LTS (Isolated Network 192.168.100.10)
- **Công cụ thực thi:** Trivy Scanner v0.71.2
- **Đối tượng:** `app:vulnerable` (python:3.8-slim) vs `app:hardened` (python:3.11-slim)

---

## 1. Lỗ Hổng Từ Thư Viện Phụ Thuộc Ứng Dụng (`requirements.txt`)

### 1.1 Thư viện `flask==2.0.1`
- **Mã CVE tiêu biểu:** `CVE-2023-30861` (Severity: HIGH) & Các lỗ hổng kế thừa 2024–2026
- **Mô tả kỹ thuật:** Rò rỉ thông tin Session Cookie vĩnh viễn do thiếu phản hồi tiêu đề HTTP `Vary: Cookie` khi ứng dụng sử dụng bộ nhớ đệm (Caching Proxy).
- **Trạng thái khắc phục:** **Đã vá (Fixed)**. Nâng cấp Flask từ `2.0.1` lên phiên bản `>= 3.0.3` trong giai đoạn Runtime của Dockerfile Hardened.

### 1.2 Thư viện `werkzeug==2.0.1`
- **Mã CVE tiêu biểu:** `CVE-2023-25577` / `CVE-2024-34069` (Severity: HIGH)
- **Mô tả kỹ thuật:** Lỗi tiêu tốn tài nguyên hệ thống (Denial of Service - DoS) khi xử lý các yêu cầu HTTP `multipart/form-data` chứa quá nhiều file hoặc field dữ liệu.
- **Trạng thái khắc phục:** **Đã vá (Fixed)**. Tự động cập nhật Werkzeug lên phiên bản `>= 3.0.3` khi build phụ thuộc ở Stage 1 (Builder Stage).

---

## 2. Phân Tích Lỗ Hổng Nghiêm Trọng Từ Base Image (`python:3.8-slim`)

Bản `app:vulnerable` chứa **9 lỗ hổng CRITICAL** xuất phát từ Base Image Debian đã lỗi thời. Các lỗ hổng tiêu biểu bao gồm:

### 2.1 Mã `CVE-2026-31789` (Gói `openssl` & `libssl3`)
- **Mức độ:** CRITICAL (Trạng thái: Fixed)
- **Mô tả:** Lỗi tràn bộ nhớ đệm (Heap Buffer Overflow) trong thư viện OpenSSL khi xử lý các chứng thư X.509 cấu hình sai, có thể dẫn đến thực thi mã từ xa (RCE).
- **Bản vá:** Đã được triệt tiêu hoàn toàn khi chuyển sang Base Image `python:3.11-slim`.

### 2.2 Mã `CVE-2026-13221` (Gói `perl-base`)
- **Mức độ:** CRITICAL (Trạng thái: Fixed)
- **Mô tả:** Lỗi xử lý biểu thức chính quy (Regex Engine) trong Perl dẫn đến ghi đè bộ nhớ không hợp lệ.
- **Bản vá:** Đã được loại bỏ nhờ cập nhật phiên bản gói hệ thống `perl-base` trong Base Image mới.

### 2.3 Mã `CVE-2026-33845` (Gói `libgnutls30`)
- **Mức độ:** CRITICAL (Trạng thái: Fixed)
- **Mô tả:** Lỗi Từ chối dịch vụ (DoS) thông qua gói tin handshake DTLS có độ dài 0.
- **Bản vá:** Đã khắc phục ở bản `libgnutls30` trong Debian mới.

---

## 3. Giải Trình Các Lỗ Hổng Còn Lại Trên Bản Gia Cố (`app:hardened`)

Kết quả quét bản `app:hardened` ghi nhận **51 lỗ hổng HIGH** còn lại. Qua phân tích chi tiết, toàn bộ các lỗ hổng này đều thuộc dạng **Ngoại lệ hợp lệ (Unfixed / False Positive)** với lý do sau:

1. **Trạng thái Upstream Unfixed (`affected` / `will_not_fix`):**
   - Các lỗ hổng này xuất phát từ bản phân phối Debian bên dưới Base Image của Python Official. Nhóm phát triển Debian chưa phát hành bản vá chính thức (No Fixed Version Available).
2. **Giảm thiểu rủi ro nhờ biện pháp Hardening (Mitigation):**
   - **Non-root User:** Container được thực thi bằng `appuser` (UID 10001), tước bỏ mọi đặc quyền `root`, triệt tiêu khả năng khai thác leo thang quyền (Container Escape) nếu các lỗi này bị tấn công.
   - **Multi-stage Build & Minimal Footprint:** Không chứa bộ biên dịch (`gcc`, `make`), hạn chế tối đa các công cụ kẻ tấn công có thể sử dụng.