# Kế hoạch kiểm thử: Docker Host & Daemon

**Thành viên phụ trách:** Lê Đình Phương — 23IT.B170  
**Trạng thái:** Kế hoạch mốc 1; chưa được duyệt để thực hiện.

## 1. Trạng thái môi trường và phê duyệt

- LAB nền của nhóm: trưởng nhóm báo cáo đã dựng theo baseline.
- Quyền truy cập LAB chung của thành viên: **Chưa xác nhận**.
- Output validation `host`/`ubuntu`/`kali` do thành viên lưu: **Chưa có**.
- Snapshot được phép sử dụng: **Chưa xác nhận**.
- Trưởng nhóm duyệt kế hoạch và xác nhận GO: **Chưa xác nhận**.

### Baseline do trưởng nhóm báo cáo

| Thành phần | Thông số/trạng thái |
|---|---|
| Ubuntu Docker Host | Ubuntu Server 24.04.5; Docker Engine 28.5.2; Compose 2.40.3 |
| Smoke test | `hello-world` chạy thành công |
| Docker network | `172.30.0.0/24`, `internal=true` |
| Docker API | TCP `2375/2376` không mở |
| Mạng Kali–Ubuntu | Kali `.20`, Ubuntu `.10`, subnet `192.168.100.0/24`; ping hai chiều; không NAT/gateway/Internet |
| Snapshot | `docker-baseline`, `docker-lab-network-ready` |

Đây là thông tin nhóm báo cáo, không thay thế output validation của thành viên. Không chạy test cho đến khi được cấp LAB, test case được duyệt và có xác nhận GO. Docker socket thật cần phê duyệt riêng, chỉ xem xét trên clone/tài nguyên dùng một lần.

## 2. Mục tiêu

1. Xác định trust boundary và các luồng liên quan giữa host, daemon và container.
2. So sánh bind mount read-write với read-only trên cùng thư mục dữ liệu giả.
3. Phân tích quyền Docker socket và nhóm `docker`; không thay đổi quyền hoặc membership trên baseline.
4. Xác nhận Docker daemon không expose TCP API trên `2375/2376`.
5. Đề xuất hardening và retest với cùng workload, input và điều kiện như Before.

## 3. Điều kiện tiên quyết

- Trưởng nhóm xác nhận LAB và snapshot được phép dùng.
- Có output validation đã làm sạch cho `host`, `ubuntu`, `kali`; nếu môi trường không dùng libvirt, phương án thay thế phải được trưởng nhóm duyệt.
- Trưởng nhóm duyệt test case, command cụ thể, tiêu chí dừng và rollback.
- Dùng thư mục/file giả, không chứa dữ liệu thật.
- Ghi baseline ban đầu: OS/kernel, Docker/Compose, context/endpoint, Docker network, IP/route và trạng thái listener.
- Dừng nếu phát hiện sai lệch baseline chưa được xử lý.

## 4. Ma trận kiểm thử dự kiến

| ID | Nội dung | Before | Hardening/Retest | Kết quả cần ghi | Phê duyệt |
|---|---|---|---|---|---|
| HS-01 | Bind mount | Cùng workload dùng thư mục giả hẹp với quyền read-write | Giữ nguyên workload/path; chuyển mount sang read-only | Đọc có thành công không; ghi được/từ chối; dữ liệu host-side thay đổi ra sao | Chưa duyệt; cần duyệt command và Compose |
| HS-02 | Docker socket | Phân tích quyền/cấu hình; không mount socket thật vào workload baseline | Không cấp socket cho workload | Ma trận quyền và tác động suy ra từ evidence | Socket thật cần phê duyệt riêng và clone dùng một lần |
| HS-03 | Nhóm `docker` | Chỉ đọc thông tin theo cách trưởng nhóm duyệt | Đề xuất giới hạn membership; không thay đổi baseline | Tài khoản/principal có quyền gửi yêu cầu daemon và mức quyền liên quan | Chưa duyệt kiểm tra trên host |
| HS-04 | Docker API TCP | Ghi nhận listener trước kiểm thử | Không bật TCP API; xác minh lại | Có/không có listener `2375/2376` | Chưa có output validation của thành viên |
| HS-05 | Cô lập workload | Ghi cấu hình namespace, privileged, capabilities, device và mount | Bỏ quyền host/thiết bị không cần thiết | Khác biệt cấu hình và chức năng hợp lệ còn hoạt động | Chưa duyệt; giữ cùng workload/input |

Ma trận là kế hoạch, không phải giấy phép chạy lệnh. Lệnh cụ thể và expected result phải được trưởng nhóm duyệt trước.

## 5. Quy tắc so sánh

- Dùng cùng image, workload, input, Ubuntu VM, phiên bản Docker, network và thư mục dữ liệu giả trong Before/Hardening/Retest.
- Chỉ thay đổi cấu hình đang đánh giá; ghi nhận mọi khác biệt ngoài dự kiến.
- Ghi test ID, snapshot, thời điểm, kết quả mong đợi/thực tế và evidence đã làm sạch.
- Không tự sửa baseline để làm các giai đoạn khớp nhau.

## 6. Tiêu chí dừng

Dừng ngay nếu:

- Lưu lượng rời subnet LAB hoặc xuất hiện kết nối LAN/Internet ngoài dự kiến.
- Workload truy cập/ghi ngoài thư mục giả đã duyệt.
- Phát hiện listener Docker TCP `2375/2376`.
- Host, daemon, NIC, route, firewall, quyền socket, membership nhóm `docker` hoặc snapshot thay đổi ngoài kế hoạch.
- Tài nguyên vượt ngưỡng, workload mất kiểm soát hoặc rollback không chắc chắn.

Khi dừng, không tiếp tục thao tác; lưu output đã làm sạch, báo trưởng nhóm và chỉ rollback theo hướng dẫn/ủy quyền.

## 7. Rollback, cleanup và evidence

1. Dừng workload; chỉ xóa tài nguyên LAB đã được duyệt.
2. Xác nhận không còn container, mount hoặc file thử nghiệm ngoài phạm vi.
3. Kiểm tra lại listener `2375/2376`, IP/route và Docker network.
4. Không tự sửa daemon, permission, group, firewall, NIC, route, libvirt network hoặc snapshot để cleanup.
5. Chỉ khôi phục snapshot trên clone/LAB riêng hoặc theo hướng dẫn trưởng nhóm.
6. Ghi cleanup record và người review.

Evidence cần có khi thực nghiệm được duyệt: output validation đã làm sạch; trạng thái listener trước/sau; cấu hình mount và kết quả đọc/ghi trên dữ liệu giả; ma trận quyền; so sánh Before/Hardening/Retest; cleanup record. Không commit credential, dữ liệu cá nhân, log thô, nội dung file host, disk image hoặc snapshot. Hạng mục chưa chạy phải ghi **Chưa thực hiện**.

## 8. Nội dung cần trưởng nhóm xác nhận

1. Cách truy cập LAB chung và việc thành viên cần tự chạy validation hay dùng output validation của nhóm.
2. Snapshot được phép dùng: `docker-baseline` hay `docker-lab-network-ready`.
3. Hạn mốc 1 áp dụng: email phân công ghi 11/10/2026, báo cáo tiến độ ngày 08/10/2026 ghi 14/10/2026.
4. Duyệt kế hoạch, lệnh test, rollback và thời điểm xác nhận GO.
5. Phê duyệt riêng cho mọi thử nghiệm Docker socket thật trên clone/tài nguyên dùng một lần.
