# Báo Cáo Đối Sánh Kỹ Thuật & Vận Hành (Technical Comparison)

- **Môi trường đối sánh:** Ubuntu Server 24.04 LTS (Isolated Network 192.168.100.10)
- **Công cụ đo lường:** Docker CLI (`docker images`, `docker inspect`, `docker exec`)
- **Đối tượng:** `app:vulnerable` vs `app:hardened`

---

## 1. Bảng Đối Sánh Kỹ Thuật & Bề Mặt Tấn Công

| Tiêu chí Kỹ thuật | Phiên bản Dễ tổn thương (`app:vulnerable`) | Phiên bản Đã gia cố (`app:hardened`) | Ý nghĩa Bảo mật / Tối ưu |
| :--- | :--- | :--- | :--- |
| **Base Image & Tag** | `python:3.8-slim` (Dynamic Tag) | `python:3.11-slim` (Updated Base) | Cập nhật hệ thống bản vá an toàn mới nhất từ Upstream |
| **Kiến trúc Build** | Single-stage Build | Multi-stage Build (Stage 1: Builder, Stage 2: Runtime) | Loại bỏ hoàn toàn công cụ build thừa (`gcc`, `make`), tối giản bề mặt tấn công |
| **Quyền Container User** | `root` (UID 0) | `appuser` (UID 10001 - Non-root) | Ngăn chặn nguy cơ Container Escape (Leo thang quyền hạn chiếm máy Host) |
| **Bảo mật Secret (Hygiene)** | Lộ Mật khẩu/Secret trực tiếp trong biến `ENV` | Loại bỏ 100% Secret khỏi Dockerfile | Ngăn rò rỉ Credential qua lệnh `docker inspect` hoặc scan các Layer |
| **Build Context Filter** | Không sử dụng bộ lọc đầy đủ | Sử dụng `.dockerignore` chuẩn | Ngăn chặn đưa file rác, file `.env`, `.git` và tài liệu nhạy cảm vào Layer |
| **Dọn dẹp Cache** | Giữ lại `pip cache` và bộ biên dịch | Sử dụng tham số `--no-cache-dir` | Giảm dung lượng rác tích tụ trong các Layer runtime |

---

## 2. Kết Quả Kiểm Thử Chức Năng & Thực Thể Quyền (Smoke Test)

Sau khi gia cố, container đã được khởi chạy thử nghiệm để kiểm tra tính sẵn sàng vận hành và phân quyền tối thiểu:

1. **Khởi chạy Container test:**
   ```bash
   docker run -d --name test-hardened -p 5000:5000 app:hardened