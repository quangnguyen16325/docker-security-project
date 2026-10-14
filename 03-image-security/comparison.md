# Báo Cáo So Sánh Kỹ Thuật Giữa 2 Bản Dockerfile

## 1. Bảng So Sánh Kỹ Thuật

| Tiêu chí kỹ thuật | Bản Vulnerable (`app:vulnerable`) | Bản Hardened (`app:hardened`) | Ý nghĩa bảo mật |
| :--- | :--- | :--- | :--- |
| **Quyền chạy User** | `root` (UID 0) | `appuser` (UID 10001) | Ngăn chặn kỹ thuật leo thang quyền hạn (Privilege Escalation) |
| **Lộ mật khẩu (Secret)** | Có (`ENV DATABASE_PASSWORD`) | **Không** | Tránh rò rỉ secret qua lệnh `docker inspect` |
| **Dung lượng Image** | Lớn hơn (chứa cache/build tools) | Nhỏ gọn hơn (đã dọn dẹp cache) | Tối ưu lưu trữ và giảm bề mặt tấn công |
| **File không cần thiết** | Copy toàn bộ folder (thiếu ignore) | Sử dụng `.dockerignore` | Tránh đưa file rác, file `.env` vào image |

## 2. Kết Quả Kiểm Thử Chức Năng (Smoke Test)

- Lệnh kiểm tra user chạy container: `sudo docker exec test-hardened whoami`
- **Kết quả thu được:** `appuser`
- **Xác nhận:** Ứng dụng Flask vận hành bình thường và an toàn dưới quyền user hạn chế.