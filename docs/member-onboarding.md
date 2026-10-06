# Onboarding thành viên

## Mục tiêu

Mỗi thành viên có repository làm việc riêng và một LAB đạt baseline trước khi thực nghiệm. Clone Git không tạo VM; VM phải được dựng theo [hướng dẫn setup](member-lab-setup.md) hoặc sử dụng LAB chung do trưởng nhóm quản lý.

## 1. Nhận quyền repository

Chấp nhận lời mời collaborator, sau đó clone repository trên máy làm việc:

```bash
git clone https://github.com/quangnguyen16325/docker-security-project.git
cd docker-security-project
```

Không clone bằng token ghi trực tiếp trong URL và không lưu credential vào repository.

## 2. Chọn đúng nhiệm vụ

- Thành viên 2: `tasks/member-2-container-security.md`
- Thành viên 3: `tasks/member-3-host-daemon-security.md`
- Thành viên 4: `tasks/member-4-image-security.md`
- Thành viên 5: `tasks/member-5-hardening-detection.md`

Đọc thêm `AGENTS.md`, `TASKS.md`, [baseline manifest](baseline-manifest.md) và tài liệu nhiệm vụ trước khi tạo file LAB.

## 3. Tạo branch cá nhân

```bash
git switch main
git pull --ff-only
git switch -c member-N/ten-nhiem-vu
```

Ví dụ: `member-2/container-security`. Không push trực tiếp vào `main`; gửi Pull Request để trưởng nhóm review.

## 4. Chuẩn bị LAB

Chọn một phương án:

1. Dùng LAB chung theo lịch và quy trình snapshot của trưởng nhóm.
2. Dựng LAB riêng theo [member-lab-setup.md](member-lab-setup.md), chạy script validation và chờ trưởng nhóm duyệt trạng thái **GO**.

Không đưa QCOW2, OVA, ISO, snapshot, log thô hoặc credential lên GitHub. Nếu cần chuyển repository vào VM không có Internet, dùng `git bundle` hoặc kênh offline được trưởng nhóm duyệt.

## 5. Quy trình một LAB

Mọi kịch bản phải đi theo:

```text
Research → Build → Test → Analyze → Harden → Retest → Compare → Document
```

Trước khi chạy, Pull Request hoặc phiếu duyệt phải ghi command, expected result, phạm vi, ảnh hưởng, tiêu chí dừng và rollback. Bằng chứng cần thể hiện **Before → Hardening → Retest** dưới cùng điều kiện.

## 6. Bàn giao

- README trong thư mục phụ trách.
- Dockerfile/Compose/config có phiên bản và tên rõ ràng.
- Command đã chạy, screenshot/log đã làm sạch.
- Phân tích, hardening, retest và bảng so sánh.
- Cleanup/rollback record và báo cáo tiến độ cho trưởng nhóm.

Nếu lưu lượng thoát LAB, baseline thay đổi ngoài kế hoạch hoặc test có tác động không dự kiến: dừng ngay, không tự sửa thêm và báo trưởng nhóm.
