# Môi trường LAB

## Mục tiêu

LAB dùng để tái hiện cấu hình yếu và kiểm chứng biện pháp phòng chống Docker mà không ảnh hưởng hệ thống thật. Chỉ dùng dữ liệu giả và tài nguyên do nhóm quản lý.

## Thành phần dự kiến

- **Docker Host VM:** Ubuntu Server 24.04 LTS, Docker Engine 28.5.2, Docker Compose Plugin v2.
- **Testing VM:** Kali Linux, chỉ dùng cho kiểm thử đã được phê duyệt.
- **Management:** hypervisor hỗ trợ snapshot; máy quản trị lưu tài liệu và quan sát.
- **Network:** mạng LAB nội bộ dành cho lưu lượng thử nghiệm; không bridge trực tiếp tới mạng trường/cơ quan. Chỉ bật Internet tạm thời khi tải dependency đã xác minh.

## Sơ đồ logic

```text
[Máy quản trị]
      |
[Mạng LAB cô lập]
   |           |
[Kali VM]  [Ubuntu Docker Host VM]
                   |
             [Containers thử nghiệm]
```

## Baseline an toàn

- Chụp snapshot sạch trước từng nhóm thử nghiệm; đặt tên theo ngày và kịch bản.
- Gán IP LAB cố định, ghi subnet và chỉ mở cổng cần thiết.
- Không dùng thông tin xác thực thật; secret thử nghiệm phải là dữ liệu giả.
- Giới hạn CPU, RAM, PID, filesystem và kết nối mạng của container.
- Đồng bộ thời gian để đối chiếu log; làm sạch dữ liệu nhạy cảm khỏi bằng chứng.
- Không gắn Docker socket, thư mục hệ thống hoặc chạy privileged ngoài kịch bản đã duyệt.

## Phiếu ghi nhận thử nghiệm

Ghi phiên bản OS/Docker/tool, topology, snapshot ban đầu, lệnh dự kiến, expected result, actual result, log/bằng chứng đã làm sạch và thủ tục rollback. Nếu lưu lượng thoát LAB hoặc trạng thái mất kiểm soát, dừng thử nghiệm và khôi phục snapshot.

