# Báo Cáo Tóm Tắt Quét Lỗ Hổng Bảo Mật (Scan Summary)

- **Công cụ quét:** Trivy Vulnerability Scanner v0.71.2
- **Đối tượng quét:** `app:vulnerable` vs `app:hardened`
- **Môi trường thử nghiệm:** Ubuntu Server 24.04 LTS (Isolated Network 192.168.100.10/24)

---

## 1. Bảng Đối Sánh Định Lượng Lỗ Hổng Bảo Mật

| Cấp độ Nghiêm trọng (Severity) | Phiên bản Dễ tổn thương (`app:vulnerable`) | Phiên bản Đã gia cố (`app:hardened`) | Mức độ Cải thiện / Ý nghĩa |
| :--- | :---: | :---: | :--- |
| **CRITICAL** | **9** | **0** | **Giảm 100%** (Sạch hoàn toàn lỗi chí mạng) |
| **HIGH** | **179** | **51** | **Giảm 71.5%** (Triệt tiêu toàn bộ lỗi có bản vá) |
| **TỔNG LỖ HỔNG (High + Critical)** | **188** | **51** | **Giảm tổng cộng 137 lỗ hổng nghiêm trọng** |
| **Lỗ hổng có bản vá (Fixed Status)** | **Có sẵn bản vá** | **0** | **ĐẠT TIÊU CHUẨN GO (Nghiệm thu)** |

---

## 2. Bảng Đối Sánh Cấu Hình & Bề Mặt Tấn Công

| Tiêu chí Kiểm thử | Phiên bản Dễ tổn thương (`app:vulnerable`) | Phiên bản Đã gia cố (`app:hardened`) |
| :--- | :--- | :--- |
| **Base Image** | `python:3.8-slim` (Tag động, không Pin Digest) | `python:3.11-slim` (Base Debian cập nhật) |
| **Kiến trúc Build** | Single-stage Build (Giữ lại công cụ thừa) | Multi-stage Build (Tối giản Layer) |
| **Quyền Container User** | `root` (UID 0) | `appuser` (UID 10001 - Non-root) |
| **Secret Hygiene** | Lộ Password/Secret trong biến `ENV` | Bỏ 100% Secret khỏi Dockerfile |

---

## 3. Kết Luận Đánh Giá

1. **Phiên bản Vulnerable (`app:vulnerable`):** Tồn tại **188 lỗ hổng nghiêm trọng** (9 Critical, 179 High) do sử dụng Base Image cũ (`python:3.8-slim`) và các thư viện phụ thuộc chứa lỗ hổng RCE và Memory Corruption.
2. **Phiên bản Hardened (`app:hardened`):** 
   - Đã triệt tiêu **100% lỗ hổng CRITICAL** và loại bỏ toàn bộ các lỗ hổng mức **HIGH** có bản sửa lỗi (Fixed status). 51 lỗ hổng HIGH còn lại là các hạn chế OS chưa có bản vá từ nhà phát triển (Unfixed/Will Not Fix).
   - Áp dụng thành công **Multi-stage Build**, thực thi dưới quyền **Non-root user (`appuser`)**, vượt qua bài Smoke Test với mã phản hồi HTTP 200.