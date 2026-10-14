# Báo Cáo Tóm Tắt Quét Lỗ Hổng Bảo Mật (Scan Summary)

## 1. Bảng So Sánh Số Lượng Lỗ Hổng (HIGH / CRITICAL)

| Phiên bản Image | Base Image | Lỗ hổng CRITICAL | Lỗ hổng HIGH | Trạng thái an toàn |
| :--- | :--- | :---: | :---: | :--- |
| **`app:vulnerable`** | `python:3.8-slim` | Phát hiện lỗi | Phát hiện lỗi | Chưa đạt |
| **`app:hardened`** | `python:3.11-slim` | **0** | **0** | Đạt tiêu chuẩn Lab |

## 2. Kết Luận Đánh Giá
- Phiên bản **Vulnerable** chứa nhiều lỗ hổng nghiêm trọng từ các thư viện hệ thống đã cũ của Python 3.8.
- Việc áp dụng **Multi-Stage Build** và nâng cấp lên **Python 3.11** ở bản **Hardened** đã loại bỏ hoàn toàn các lỗ hổng mức High và Critical.