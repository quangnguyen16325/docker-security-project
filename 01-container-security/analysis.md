# Container Security Analysis

## Phạm vi

Phân tích `CS-01` đến `CS-05` bằng dữ liệu giả. Không thử container escape,
không dùng `privileged: true`, không mount Docker socket hoặc filesystem hệ
thống của host.

## Before

Chưa thực hiện. Khi chạy, ghi cho từng test:

- Command và thời điểm.
- Expected result.
- Actual result.
- Evidence đã làm sạch.
- Nguyên nhân kỹ thuật của hành vi quan sát được.

## Hardening

Các thay đổi duy nhất giữa hai cấu hình:

- Chuyển từ root sang UID/GID `10001`.
- Drop toàn bộ Linux capabilities.
- Bật `no-new-privileges`.
- Đặt root filesystem read-only.
- Chuyển bind mount `/data` sang read-only.
- Dùng `tmpfs` giới hạn cho `/tmp`.

## Giới hạn

Kết quả chỉ chứng minh tác động của cấu hình trong workload này. Không được suy
diễn thành container escape hoặc khả năng chiếm host nếu chưa có bằng chứng.
