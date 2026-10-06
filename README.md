# Nghiên cứu Docker Security

Đề tài: **Nghiên cứu, thực nghiệm khai thác và phòng chống các lỗ hổng bảo mật trong môi trường Docker Container**.

Repository tập trung khảo sát bề mặt tấn công của container, Docker host/daemon và image; xây dựng các bài thực nghiệm có kiểm soát; sau đó áp dụng hardening, audit và detection để đo mức cải thiện. Nhóm gồm 5 thành viên, làm việc theo phân công trong [TASKS.md](TASKS.md).

## Nguyên tắc an toàn

Mọi bài thử chỉ được thực hiện trong VM/LAB cô lập, trên hệ thống thuộc quyền quản lý của nhóm hoặc được cho phép rõ ràng. Không tấn công, quét hoặc thu thập dữ liệu từ hệ thống bên ngoài. Không lưu `.env`, khóa API, mật khẩu, token, private key, dữ liệu cá nhân hoặc database dump trong repository.

## Môi trường dự kiến

- Ubuntu Server 24.04 LTS làm Docker host.
- Docker Engine 28.5.2 và Docker Compose Plugin v2.
- Kali Linux làm máy kiểm thử.
- Snapshot VM và mạng LAB cô lập để khôi phục sau thử nghiệm.

Chi tiết xem [docs/environment.md](docs/environment.md). Quy trình xem [docs/research-plan.md](docs/research-plan.md).

Tài liệu điều phối của trưởng nhóm:

- [Kế hoạch chuẩn hóa môi trường](docs/setup-plan.md)
- [Kiến trúc LAB](docs/lab-architecture.md)
- [Checklist kiểm thử môi trường](docs/environment-checklist.md)
- [Kế hoạch tích hợp](docs/integration-plan.md)
- [Biên bản dựng Docker LAB](docs/lab-build-record.md)

## Cấu trúc repository

```text
.
├── 01-container-security/     # Container isolation và runtime controls
├── 02-host-security/          # Docker host, daemon và socket
├── 03-image-security/         # Dockerfile và image supply chain
├── 04-hardening-detection/    # Hardening, audit, logging, detection
├── 05-integration/            # Tích hợp, retest và đánh giá
├── docs/                      # Thiết kế LAB và kế hoạch nghiên cứu
├── report/                    # Báo cáo học phần
└── slides/                    # Slide thuyết trình
```

## Trạng thái hiện tại

Giai đoạn này chỉ khởi tạo cấu trúc và tài liệu. Chưa có dịch vụ, image, công cụ khai thác hay lệnh cài đặt nào. Khi bắt đầu thực nghiệm, mỗi thư mục cần README riêng ghi mục tiêu, điều kiện an toàn, cách tái hiện, bằng chứng, biện pháp khắc phục và kết quả retest.
