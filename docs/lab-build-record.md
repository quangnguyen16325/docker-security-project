# Biên bản dựng Docker LAB

## Trạng thái hoàn thành

Môi trường được dựng ngày 2026-10-07 bằng libvirt backend của Virtual Machine Manager. Không sửa thủ công firewall hoặc mạng vật lý của host; không expose Docker daemon qua TCP. Libvirt quản lý bridge và các rule isolation mặc định cho mạng LAB.

- **VM:** `docker-security-ubuntu2404`
- **Tài nguyên:** 4 vCPU, 8 GB RAM, disk QCOW2 sparse 32 GB
- **OS:** Ubuntu Server 24.04.5 LTS
- **Kernel:** 6.8.0-146-generic x86_64
- **Docker Engine:** client/server 28.5.2
- **Docker Compose Plugin:** v2.40.3
- **containerd:** 2.3.6
- **Docker network:** `docker-security-lab`, internal bridge, `172.30.0.0/24`
- **Snapshots:** `docker-baseline`, `docker-lab-network-ready`

Các package `docker-ce`, `docker-ce-cli`, `docker-ce-rootless-extras` và `docker-compose-plugin` được đặt trạng thái hold để tránh tự động lệch baseline. Cần review định kỳ trước khi áp dụng bản vá bảo mật.

## Kết quả kiểm chứng

- Docker daemon và QEMU Guest Agent hoạt động.
- `hello-world` tải và chạy thành công; container đã được xóa bằng `--rm`.
- Không còn container chạy hoặc dừng sau bài kiểm tra.
- Docker API không lắng nghe trên TCP 2375/2376.
- Docker service dùng Unix socket qua `dockerd -H fd://`.
- Root filesystem LVM đã mở rộng dùng toàn bộ volume, khoảng 30 GB.
- Workspace `/home/labadmin/docker-security-project/` có đầy đủ tám thư mục của đề tài.

## Trạng thái mạng

Mạng libvirt `docker-security-isolated` dùng bridge `virbr100` ở Layer 2, không có NAT, forwarding, DHCP, DNS, gateway, địa chỉ host hoặc kết nối tới interface vật lý. Mạng chỉ chứa NIC isolated của hai VM:

- Ubuntu Docker VM: `192.168.100.10/24`
- Kali Linux VM: `192.168.100.20/24`

NIC nối vào libvirt network `default` của cả hai VM bị disable trong cấu hình persistent và live. Hai VM không có default route, DNS hoặc đường Internet qua mạng LAB. Ping hai chiều trên `192.168.100.0/24` đã thành công. Rule firewall sau cấu hình khớp về ngữ nghĩa với baseline Phase 1; chỉ có các rule isolation mặc định do libvirt tạo và không có NAT/SNAT/DNAT cho `virbr100`.

Docker network `docker-security-lab` vẫn là internal bridge `172.30.0.0/24`; Docker API không lắng nghe trên TCP 2375/2376. Cấu hình đã được kiểm tra lại sau khi reboot Ubuntu.

## Rollback

- Domain XML trước khi gắn mạng được lưu tại `docs/rollback/` và `/tmp`.
- Snapshot nội bộ `docker-lab-network-ready` được tạo khi Ubuntu VM đã tắt sạch; snapshot `docker-baseline` vẫn được giữ nguyên.
- Nếu cần rollback mạng, tắt hai VM, khôi phục domain XML đã lưu, rồi destroy/undefine `docker-security-isolated`. Không chỉnh trực tiếp firewall của host; để libvirt thu hồi rule do chính nó quản lý.

## Vận hành tiếp theo

- Dùng snapshot `docker-lab-network-ready` cho các bài thử cần mạng Kali–Ubuntu; dùng `docker-baseline` để quay lại trạng thái trước khi tích hợp mạng.
- Chỉ bật lại kết nối package tạm thời khi cần cập nhật có kiểm soát.
- Đổi mật khẩu tài khoản LAB trước khi nhóm sử dụng vì thông tin đăng nhập đã từng được truyền qua kênh chat.
- Không thêm thành viên vào nhóm `docker` nếu chưa đánh giá rủi ro quyền tương đương root.
