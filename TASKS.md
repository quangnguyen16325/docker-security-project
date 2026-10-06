# Phân công công việc

## Vai trò 1 — Trưởng nhóm

- Thiết kế kiến trúc VM, phân đoạn mạng LAB, snapshot và quy trình khôi phục.
- Nghiên cứu tổng quan Docker Security, threat model và phạm vi đạo đức.
- Chuẩn hóa biểu mẫu, tích hợp kết quả và đánh giá trước/sau hardening.
- Điều phối review; chủ trì `05-integration/`, báo cáo và slide.

## Vai trò 2 — Container Security

- Nghiên cứu namespace, cgroup, Linux capabilities, seccomp và AppArmor.
- Xây dựng kịch bản sai cấu hình trong `01-container-security/`.
- Phân tích tác động, giảm quyền và thực hiện retest.

## Vai trò 3 — Docker Host & Daemon Security

- Phân tích Docker daemon, Unix socket, remote API và quyền nhóm `docker`.
- Đánh giá host, logging và ranh giới tin cậy trong `02-host-security/`.
- Xây dựng checklist giảm bề mặt tấn công và xác minh sau khắc phục.

## Vai trò 4 — Docker Image Security

- Nghiên cứu base image, dependency, Dockerfile và software supply chain.
- Thực nghiệm quét image, secret giả lập, provenance/SBOM trong `03-image-security/`.
- So sánh image trước/sau tối giản, cập nhật và loại bỏ dữ liệu nhạy cảm.

## Vai trò 5 — Hardening, Audit & Detection

- Nghiên cứu benchmark, rootless/user namespace, policy và runtime monitoring.
- Xây dựng audit, logging và cảnh báo trong `04-hardening-detection/`.
- Đo độ bao phủ phát hiện, false positive và chi phí vận hành.

## Mốc chung và Definition of Done

1. Chốt phạm vi, threat model, topology và baseline phiên bản.
2. Hoàn thành nghiên cứu và kịch bản LAB đã được trưởng nhóm duyệt.
3. Thu thập bằng chứng đã làm sạch; phân tích nguyên nhân gốc.
4. Áp dụng hardening, chạy lại cùng điều kiện và so sánh kết quả.
5. Peer review chéo, tích hợp demo, hoàn thiện báo cáo và slide.

Một đầu việc hoàn thành khi có hướng dẫn tái hiện, kết quả quan sát, biện pháp phòng chống, retest và review của ít nhất một thành viên khác.

