# Docker Host & Daemon Security

**Thành viên phụ trách:** Lê Đình Phương — 23IT.B170  
**Phạm vi:** Docker socket, nhóm `docker`, bind mount và ranh giới cô lập host/container.

## Báo cáo mốc 1

Mốc 1 tập trung xác nhận baseline LAB, phân tích trust boundary và lập kế hoạch kiểm thử. Các bài thử Before/Hardening/Retest chưa được thực hiện; chỉ bắt đầu sau khi kế hoạch được duyệt và trưởng nhóm xác nhận GO.

Theo báo cáo tiến độ ngày 08/10/2026 và thông tin trưởng nhóm cung cấp, LAB nền của nhóm có:

- Ubuntu Server 24.04.5, Docker Engine 28.5.2, Docker Compose 2.40.3.
- `hello-world` chạy thành công.
- Docker network `172.30.0.0/24`, `internal=true`.
- Docker API TCP `2375/2376` không mở.
- Kali `.20` và Ubuntu `.10` trên mạng `192.168.100.0/24`, ping hai chiều; không NAT, gateway hoặc Internet.
- Snapshot `docker-baseline` và `docker-lab-network-ready`.

Đây là thông tin baseline do trưởng nhóm báo cáo, không phải kết quả validation do thành viên phụ trách tự chạy. Quyền truy cập LAB chung và output validation được giao cho thành viên: **Chưa xác nhận**.

## Tài liệu mốc 1

- [Threat model](threat-model.md): trust boundary, tài sản và rủi ro host impact.
- [Kế hoạch kiểm thử](test-plan.md): điều kiện tiên quyết, phạm vi dự kiến, tiêu chí dừng và rollback.

## Trạng thái

| Hạng mục | Trạng thái |
|---|---|
| Nghiên cứu phạm vi và threat model | Đã chuẩn bị; chờ trưởng nhóm review |
| Kế hoạch kiểm thử | Đã chuẩn bị; chưa được duyệt để chạy |
| Quyền truy cập LAB và output validation của thành viên | Chưa xác nhận / chưa có |
| GO thực nghiệm | Chưa xác nhận |
| Kết quả Before/Hardening/Retest | Chưa thực hiện |

## Nguyên tắc an toàn

- Chỉ dùng LAB được nhóm phê duyệt và dữ liệu giả.
- Không bật Docker API TCP; không mount `/`, thư mục nhạy cảm hoặc Docker socket thật vào workload nếu chưa được duyệt riêng.
- Không tự thay đổi daemon, quyền socket, nhóm `docker`, firewall, mạng, NIC, route hoặc snapshot trên baseline.
- Làm sạch log và ảnh trước khi đưa vào repository; không lưu credential hoặc dữ liệu thật.

## Nội dung cần trưởng nhóm xác nhận

1. Cách truy cập LAB chung và việc thành viên có cần tự chạy validation `host`/`ubuntu`/`kali` hay không.
2. Snapshot được phép dùng cho task: `docker-baseline` hay `docker-lab-network-ready`.
3. Hạn mốc 1 áp dụng: email phân công ghi 11/10/2026, báo cáo tiến độ ngày 08/10/2026 ghi 14/10/2026.
4. Phê duyệt test plan và xác nhận GO trước thực nghiệm; Docker socket thật cần duyệt riêng trên clone/tài nguyên dùng một lần.
