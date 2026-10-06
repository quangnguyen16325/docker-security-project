# Kế hoạch chuẩn hóa môi trường

## Snapshot kiểm tra ngày 2026-10-07

Các lệnh chỉ đọc đã dùng: `sed -n '1,80p' /etc/os-release`, `uname -srmo`, `docker --version`, `docker version` và `docker compose version`.

- **OS hiện tại:** Ubuntu 24.04.5 LTS (Noble Numbat) — phù hợp yêu cầu Ubuntu Server 24.04 LTS.
- **Kernel:** Linux 7.0.0-38-generic, x86_64 — đã ghi nhận; đề tài chưa đặt phiên bản kernel bắt buộc.
- **Docker Engine:** client 29.8.2 (build `7fc2dff`) và server 29.8.2 (build `8af9fe3`) — đã cài và daemon phản hồi, nhưng không khớp baseline 28.5.2.
- **Docker Compose:** v5.6.0 — đã cài dưới dạng lệnh `docker compose`, nhưng không khớp yêu cầu Compose Plugin v2.

Kiểm tra này xác nhận executable, phiên bản client/server và Compose plugin. Không chạy container và không thay đổi hệ thống.

## Kết luận

Không hạ cấp hoặc sửa Docker trên máy hiện tại. Tạo một **Ubuntu Server 24.04 LTS VM riêng** làm Docker Host LAB, sau đó chuẩn hóa VM theo baseline môn học. Cách này tránh ảnh hưởng môi trường phát triển và cho phép rollback bằng snapshot.

## Các bước trưởng nhóm cần thực hiện trên VM LAB

1. Tạo VM Ubuntu Server 24.04 LTS, mạng nội bộ cô lập và snapshot `clean-os`.
2. Dùng repository APT chính thức của Docker cho Ubuntu. Trước khi cài, chỉ liệt kê phiên bản khả dụng bằng `apt list --all-versions docker-ce` và `apt list --all-versions docker-compose-plugin`.
3. Xác nhận gói Docker Engine 28.5.2 còn khả dụng cho Ubuntu 24.04. Nếu có, chọn đúng version string cho cả `docker-ce` và `docker-ce-cli`; không đoán tên gói.
4. Xác nhận một bản Compose Plugin dòng v2 tương thích. Nếu repository hiện tại không còn cung cấp, xin giảng viên duyệt nguồn phát hành chính thức/phiên bản thay thế trước khi dùng bản lưu trữ.
5. Chỉ sau khi trưởng nhóm duyệt version string, thực hiện cài đặt thủ công trên VM LAB theo tài liệu Docker chính thức; không thực hiện trên máy hiện tại.
6. Ghi manifest phiên bản, checksum của artifact tải thủ công (nếu có), ngày cài và nguồn tải. Tạo snapshot `docker-baseline`.
7. Chạy checklist tại `docs/environment-checklist.md`; lưu kết quả đã loại bỏ dữ liệu nhạy cảm.

Tài liệu tham chiếu chính thức:

- Docker Engine trên Ubuntu: <https://docs.docker.com/engine/install/ubuntu/>
- Docker Compose Plugin trên Linux: <https://docs.docker.com/compose/install/linux/>

## Điểm cần xác nhận với giảng viên

- Docker Engine **phải đúng 28.5.2** hay có thể dùng bản mới hơn thuộc giai đoạn 2024+.
- “Compose Plugin v2” là yêu cầu major version bắt buộc hay chỉ yêu cầu kiến trúc plugin (`docker compose`) thay cho standalone `docker-compose`.
- Có chấp nhận artifact chính thức đã lưu trữ nếu repository APT không còn bản yêu cầu hay không.
