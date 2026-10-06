# Thành viên 2 — Container Security

## 1. Mục tiêu

Đánh giá tác động của quyền root, `--privileged` và Linux capabilities trong container; chứng minh nguyên tắc least privilege bằng kết quả trước/sau hardening trong LAB cô lập.

## 2. Phạm vi nghiên cứu

- So sánh tiến trình root và non-root trong container.
- Rủi ro của privileged container và capability dư thừa.
- Giới hạn UID/GID, filesystem và quyền tiến trình. Không nghiên cứu container escape ngoài kịch bản đã duyệt.

## 3. Kiến thức cần tìm hiểu

Docker user model, namespaces, UID/GID, capability bounding set, `no-new-privileges`, bind mount permissions và khác biệt giữa root trong container với root trên host.

## 4. LAB phải xây dựng

Trong `01-container-security/`, chuẩn bị một ứng dụng tối giản với hai cấu hình: cố ý cấp quyền rộng và đã harden. Chỉ dùng dữ liệu giả, image được pin và Docker network `docker-security-lab`.

## 5. Các bước thực hiện ở mức kế hoạch

Thực hiện đúng chuỗi **Research → Build → Test → Analyze → Harden → Retest → Compare → Document**:

1. Viết threat model, giả thuyết và tiêu chí dừng.
2. Trình trưởng nhóm duyệt Dockerfile/Compose và command dự kiến.
3. Build hai cấu hình; kiểm tra user, capabilities và quyền ghi.
4. Phân tích nguyên nhân, giảm quyền rồi chạy lại cùng test case.
5. Lập bảng so sánh và dọn sạch tài nguyên thử nghiệm.

## 6. Kết quả mong đợi

Cấu hình yếu cho phép nhiều hành vi hơn dự kiến; cấu hình harden vẫn chạy đúng chức năng nhưng chặn thao tác cần quyền dư thừa.

## 7. Hardening

Dùng `USER` non-root, `cap_drop: [ALL]`, chỉ thêm capability thật sự cần, `security_opt: [no-new-privileges:true]`, quyền file tối thiểu và tránh `privileged: true`.

## 8. Retest

Chạy lại nguyên bộ test với cùng image tag, input và điều kiện mạng. Ghi rõ chức năng hợp lệ còn hoạt động và hành vi nguy hiểm đã bị từ chối.

## 9. Deliverables

- `01-container-security/README.md`: cách tái hiện và rollback.
- Dockerfile/Compose yếu và harden, dùng tên/tag rõ ràng.
- `analysis.md`, `comparison.md` và bằng chứng đã làm sạch.

## 10. Screenshot/log cần thu thập

Chụp user chạy tiến trình, capability set, kết quả quyền ghi và thông báo từ chối sau hardening. Log phải có timestamp, test-case ID; che hostname, MAC, credential và dữ liệu cá nhân.

## 11. Tiêu chí nghiệm thu

- Có ít nhất một test root/non-root, privileged/unprivileged và capability.
- Kịch bản tái hiện được, có expected/actual result và rollback.
- Bản harden không dùng privileged, không làm hỏng chức năng chính.
- Không còn container, volume hoặc image tạm không được khai báo.

## 12. Những việc không được phép thay đổi trên baseline

Không sửa libvirt network, IP, NIC NAT, Docker daemon, firewall, AppArmor/Seccomp toàn host, snapshot hoặc Docker network hiện có. Không mount Docker socket, `/`, `/etc`, `/var` hay thiết bị host. Không expose cổng ra LAN/Internet.

## 13. Checklist để trưởng nhóm review

- [ ] Phạm vi, command và rollback đã được duyệt trước khi chạy.
- [ ] Image/version được pin; không chứa secret.
- [ ] Test chỉ chạy trong VM/LAB cô lập.
- [ ] Bằng chứng trước/sau dùng cùng điều kiện.
- [ ] Hardening theo least privilege và có retest.
- [ ] Tài nguyên tạm đã được kiểm kê và dọn sạch.
