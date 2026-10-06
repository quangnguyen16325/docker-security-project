# Thành viên 3 — Docker Host & Daemon Security

## 1. Mục tiêu

Phân tích ranh giới tin cậy giữa Docker daemon, host và container; đánh giá rủi ro Docker socket, unsafe volume mount và thành viên nhóm `docker` mà không làm thay đổi baseline chuẩn.

## 2. Phạm vi nghiên cứu

- Quyền điều khiển qua Unix socket và nhóm `docker`.
- Bind mount quá rộng hoặc ghi được.
- Cô lập host/container và bề mặt daemon.
- Không expose daemon qua TCP và không thử container escape ngoài kịch bản duyệt.

## 3. Kiến thức cần tìm hiểu

Kiến trúc client–daemon, quyền Unix socket, đặc quyền tương đương root của nhóm `docker`, bind propagation, namespaces, daemon attack surface và nguyên tắc bảo vệ host.

## 4. LAB phải xây dựng

Trong `02-host-security/`, xây dựng mô hình dùng thư mục dữ liệu giả để so sánh bind mount read-write với read-only. Mô phỏng quyền socket bằng tài nguyên dùng một lần trên nhánh snapshot/clone; mọi truy cập Docker socket thật cần trưởng nhóm duyệt riêng.

## 5. Các bước thực hiện ở mức kế hoạch

Theo **Research → Build → Test → Analyze → Harden → Retest → Compare → Document**:

1. Lập sơ đồ trust boundary và inventory socket/mount dự kiến.
2. Viết test case, command, ảnh hưởng và rollback; xin duyệt.
3. Build workload với dữ liệu giả, kiểm tra quyền đọc/ghi và mức kiểm soát daemon.
4. Phân tích đường leo thang quyền, áp dụng hardening.
5. Retest cùng input, so sánh và xác minh host sạch.

## 6. Kết quả mong đợi

Chỉ ra vì sao socket, nhóm `docker` và mount ghi được có thể phá vỡ ranh giới container; cấu hình harden loại bỏ quyền truy cập không cần thiết.

## 7. Hardening

Không mount Docker socket vào workload; giới hạn người thuộc nhóm `docker`; dùng named volume hoặc bind mount read-only theo đường dẫn hẹp; cấm host PID/network và device không cần thiết; giữ daemon trên Unix socket.

## 8. Retest

Xác nhận workload vẫn đọc dữ liệu được phép nhưng không ghi ra host, không điều khiển daemon và không nhìn thấy tài nguyên host ngoài phạm vi khai báo.

## 9. Deliverables

- `02-host-security/README.md` và threat model.
- Compose/config yếu và harden dùng dữ liệu giả.
- Ma trận socket/mount/quyền, `analysis.md`, `comparison.md`.
- Hướng dẫn rollback và biên bản cleanup.

## 10. Screenshot/log cần thu thập

Thu trạng thái socket dưới dạng quyền/owner cần thiết, danh sách mount đã làm sạch, kết quả read/write và daemon listener. Không chụp nội dung file host, tài khoản cá nhân, MAC, token hoặc credential.

## 11. Tiêu chí nghiệm thu

- Giải thích đúng quyền thực tế của Docker socket và nhóm `docker`.
- Có test mount read-write/read-only bằng dữ liệu giả.
- Không có listener 2375/2376 trước và sau LAB.
- Hardening chặn hành vi rủi ro và workload hợp lệ vẫn chạy.
- Có bằng chứng host/baseline không bị thay đổi ngoài tài nguyên đã duyệt.

## 12. Những việc không được phép thay đổi trên baseline

Không sửa `daemon.json`, systemd unit, socket permission, membership nhóm `docker`, firewall, libvirt network, NIC, route, snapshot hoặc `/etc` của host. Không mount `/`, Docker socket hay thư mục nhạy cảm vào container nếu chưa có phê duyệt riêng và rollback đã thử. Không bật Docker TCP API.

## 13. Checklist để trưởng nhóm review

- [ ] Trust boundary và rủi ro host impact đã rõ.
- [ ] Dùng dữ liệu/thư mục giả, không đọc dữ liệu thật.
- [ ] Command, snapshot và rollback đã được duyệt.
- [ ] Không expose Docker daemon hoặc Internet.
- [ ] So sánh trước/sau có cùng test case.
- [ ] Cleanup và kiểm tra listener/mount cuối đã đạt.

