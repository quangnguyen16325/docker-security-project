# Thành viên 5 — Docker Hardening, Audit & Detection

## 1. Mục tiêu

Đánh giá baseline bằng Docker Bench for Security và kiểm chứng các kiểm soát runtime: AppArmor, Seccomp, read-only filesystem, resource limits, logging và phát hiện cơ bản.

## 2. Phạm vi nghiên cứu

- Audit theo benchmark phù hợp phiên bản hiện tại.
- AppArmor/Seccomp ở cấp container.
- Filesystem read-only, CPU/memory/PID limits.
- Docker logging và rule phát hiện hành vi bất thường cơ bản.

## 3. Kiến thức cần tìm hiểu

CIS Docker Benchmark, cách diễn giải PASS/WARN/INFO, AppArmor profile, seccomp syscall filtering, cgroups v2, log driver/rotation và nguyên tắc tín hiệu–nhiễu trong detection.

## 4. LAB phải xây dựng

Trong `04-hardening-detection/`, chuẩn bị workload sinh sự kiện vô hại, có mã test-case rõ ràng. Tạo cấu hình yếu/hardened bằng option cấp container; Docker Bench chạy audit-only và không tự sửa host.

## 5. Các bước thực hiện ở mức kế hoạch

Theo **Research → Build → Test → Analyze → Harden → Retest → Compare → Document**:

1. Chốt phiên bản benchmark/tool và ánh xạ control áp dụng được.
2. Viết workload, event, expected log, command và rollback để duyệt.
3. Chạy audit và baseline test trong cửa sổ thời gian xác định.
4. Áp dụng policy/limit cấp container, không sửa toàn host.
5. Retest, đo khả năng chặn/phát hiện, false positive và overhead.

## 6. Kết quả mong đợi

Có báo cáo audit được giải thích theo bối cảnh; cấu hình harden chặn syscall/ghi file/vượt tài nguyên đã chọn và tạo log đủ để nhận biết test event.

## 7. Hardening

Dùng AppArmor/Seccomp profile được duyệt, `read_only: true`, `tmpfs` cho đường dẫn cần ghi, giới hạn CPU/memory/PIDs, `no-new-privileges`, log rotation và trường nhận diện test case.

## 8. Retest

Lặp lại workload và event giống baseline; kiểm tra chức năng hợp lệ, denial mong đợi, limit thực thi và log/detection xuất hiện đúng thời gian. Ghi false positive/negative.

## 9. Deliverables

- `04-hardening-detection/README.md` và mapping benchmark.
- Compose/policy cấp container yếu và harden.
- `audit-summary.md`, `detection-results.md`, `comparison.md`.
- Mẫu log đã làm sạch, rollback và cleanup checklist.

## 10. Screenshot/log cần thu thập

Thu phiên bản tool/benchmark, control ID và kết quả; trạng thái profile, denial event, resource-limit event và Docker log liên quan. Chỉ lấy cửa sổ log cần thiết; che hostname, MAC, user, token và dữ liệu ngoài LAB.

## 11. Tiêu chí nghiệm thu

- Mỗi cảnh báo Docker Bench được phân loại: áp dụng, không áp dụng hoặc chấp nhận rủi ro.
- Có test riêng cho read-only filesystem, Seccomp/AppArmor và ít nhất hai resource limits.
- Detection liên kết được test-case ID với sự kiện; ghi tỷ lệ phát hiện và false positive.
- Retest chứng minh workload hợp lệ vẫn hoạt động.

## 12. Những việc không được phép thay đổi trên baseline

Không chạy auto-remediation; không sửa profile AppArmor/Seccomp hệ thống, auditd, daemon logging toàn cục, `daemon.json`, systemd, sysctl, firewall, network, NIC hoặc snapshot. Không tắt control bảo vệ để tạo bằng chứng. Mọi profile tùy chỉnh chỉ dùng file dự án và phải được duyệt trước khi load.

## 13. Checklist để trưởng nhóm review

- [ ] Tool/benchmark phù hợp Docker 28.5.2 và có nguồn rõ ràng.
- [ ] Audit chỉ đọc; không auto-fix baseline.
- [ ] Policy và giới hạn được áp dụng ở cấp container.
- [ ] Event an toàn, có test-case ID và thời gian xác định.
- [ ] Bằng chứng đã làm sạch, không chứa dữ liệu ngoài phạm vi.
- [ ] Retest, false positive/negative, overhead và cleanup đã ghi nhận.
