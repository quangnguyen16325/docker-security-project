# Checklist kiểm thử môi trường

Checklist này chỉ dùng để xác nhận LAB trước khi có hoạt động thực nghiệm.

## Hạ tầng và cô lập

- [ ] Docker Host là VM Ubuntu Server 24.04 LTS riêng, không phải máy làm việc chính.
- [ ] Kali và Docker Host cùng subnet LAB nội bộ đã ghi trong sơ đồ.
- [ ] Không có route/bridge ngoài phạm vi được duyệt; egress mặc định bị chặn.
- [ ] Có snapshot `clean-os` và `docker-baseline`; rollback đã được thử.
- [ ] CPU, RAM và dung lượng đĩa đủ cho kịch bản, có ngưỡng dừng rõ ràng.
- [ ] Đồng hồ hai VM đồng bộ để đối chiếu log.

## Phiên bản và dịch vụ

- [ ] `cat /etc/os-release` xác nhận Ubuntu 24.04 LTS.
- [ ] `uname -srmo` được ghi vào biên bản baseline.
- [ ] `docker version` xác nhận cả client và server là 28.5.2.
- [ ] `docker compose version` xác nhận Compose Plugin v2 đã được giảng viên chấp thuận.
- [ ] `docker context show` trỏ tới context LAB, không phải host khác.
- [ ] Chỉ các cổng và dịch vụ đã phê duyệt đang lắng nghe.

## An toàn dữ liệu và quyền

- [ ] Không dùng `.env`, credential, token, private key hoặc dữ liệu thật.
- [ ] Tài khoản thử nghiệm dùng secret giả, có thể hủy sau bài test.
- [ ] Không mount Docker socket hoặc đường dẫn host nhạy cảm trong baseline.
- [ ] Container baseline không chạy privileged và không dùng host network.
- [ ] Log/evidence có nơi lưu riêng và quy trình làm sạch trước khi commit.

## Điều kiện Go/No-Go

- [ ] Test case có mục tiêu, lệnh, expected result, phạm vi mạng và rollback.
- [ ] Trưởng nhóm đã duyệt test case và người quan sát.
- [ ] Có tiêu chí dừng khi lưu lượng thoát LAB, tài nguyên vượt ngưỡng hoặc trạng thái không kiểm soát.
- [ ] Tất cả mục bắt buộc phía trên đạt; nếu không, trạng thái là **NO-GO**.

