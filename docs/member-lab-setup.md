# Hướng dẫn thành viên dựng Docker Security LAB từ đầu

Tài liệu này có thể gửi riêng cho thành viên. Chỉ thực hiện trên máy/VM thuộc quyền quản lý của thành viên và được trưởng nhóm cho phép. Các lệnh có `sudo` chỉ chạy trong giai đoạn dựng VM, không chạy trên máy làm việc chính hoặc trong giai đoạn thực nghiệm nếu chưa được duyệt.

## 1. Kiến trúc cần đạt

```text
Kali Linux VM                  Ubuntu Docker VM
192.168.100.20/24              192.168.100.10/24
          \                    /
           docker-security-isolated
           virbr100 · Layer 2 only
           no NAT · no gateway · no Internet
                         |
               docker-security-lab
               172.30.0.0/24 · internal=true
```

Đối chiếu phiên bản và tên tài nguyên tại [baseline-manifest.md](baseline-manifest.md).

## 2. Điều kiện ban đầu

- Host hỗ trợ KVM/libvirt và Virtual Machine Manager.
- ISO Ubuntu Server 24.04 LTS và Kali lấy từ nguồn chính thức, checksum đã kiểm tra.
- Ubuntu VM tham chiếu: 4 vCPU, 8 GB RAM, disk 32 GB.
- Có quyền quản trị trên host/VM của chính thành viên.
- Ghi lại command, nguồn tải, version và rollback ngay từ đầu.

Nếu host đã có subnet `192.168.100.0/24`, bridge `virbr100` hoặc network cùng tên, dừng và báo trưởng nhóm; không tự chọn subnet khác nếu mục tiêu là tái tạo đúng baseline.

## 3. Tạo VM và snapshot hệ điều hành sạch

1. Tạo Ubuntu VM tên `docker-security-ubuntu2404` và Kali VM tên `kali-linux`.
2. Tạm gắn NIC vào libvirt `default` NAT chỉ để cập nhật/cài package.
3. Cài QEMU Guest Agent trong hai VM nếu image chưa có.
4. Cập nhật hệ điều hành trong maintenance window đã duyệt.
5. Tắt VM sạch và tạo snapshot `clean-os`.

Không dùng credential thật. Không thêm tài khoản vào nhóm `docker`; quyền nhóm này tương đương quyền cao trên host.

## 4. Cài Docker trên Ubuntu

Thực hiện theo tài liệu chính thức: <https://docs.docker.com/engine/install/ubuntu/>. Không dùng script `curl | sh`.

Thiết lập Docker APT repository trong lúc NIC NAT tạm thời còn bật:

```bash
sudo apt update
sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

sudo apt update
apt-cache madison docker-ce | grep '28.5.2'
apt-cache madison docker-ce-cli | grep '28.5.2'
apt-cache madison docker-compose-plugin | grep '2.40.3'
```

Sao chép chính xác version string từ output. Nếu không tìm thấy, dừng và báo trưởng nhóm; không cài bản gần đúng.

```bash
DOCKER_VERSION='<VERSION_STRING_28.5.2>'
COMPOSE_VERSION='<VERSION_STRING_2.40.3>'

sudo apt install \
  docker-ce="$DOCKER_VERSION" \
  docker-ce-cli="$DOCKER_VERSION" \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin="$COMPOSE_VERSION" \
  docker-ce-rootless-extras="$DOCKER_VERSION"
```

Xác minh và chạy smoke test khi Internet còn được phép:

```bash
sudo docker version
sudo docker compose version
sudo docker run --rm hello-world
```

Sau khi trưởng nhóm xác nhận version, có thể hold các package baseline:

```bash
sudo apt-mark hold docker-ce docker-ce-cli docker-compose-plugin docker-ce-rootless-extras
```

## 5. Tạo Docker internal network

```bash
sudo docker network create \
  --driver bridge \
  --subnet 172.30.0.0/24 \
  --internal \
  docker-security-lab

sudo docker network inspect docker-security-lab
```

Kết quả bắt buộc: subnet `172.30.0.0/24` và `Internal: true`.

## 6. Tạo isolated libvirt network trên host

Trước tiên chạy read-only:

```bash
virsh -c qemu:///system net-list --all
ip -brief address
ip route
```

Tạo file XML cục bộ, không commit XML chứa metadata domain:

```xml
<network>
  <name>docker-security-isolated</name>
  <bridge name="virbr100" stp="on" delay="0"/>
</network>
```

Sau khi trưởng nhóm duyệt XML:

```bash
virsh -c qemu:///system net-define docker-security-isolated.xml
virsh -c qemu:///system net-start docker-security-isolated
virsh -c qemu:///system net-autostart docker-security-isolated
```

Xác minh XML không có `<forward>` hoặc `<ip>`. Libvirt có thể tạo rule isolation mặc định cho bridge; không tự sửa firewall host.

## 7. Gắn và cấu hình NIC LAB

Trong Virtual Machine Manager, gắn thêm một NIC dùng `docker-security-isolated` cho mỗi VM. Chưa tắt NIC NAT cho đến khi package/image cần thiết đã sẵn sàng.

Trên Ubuntu, xác định đúng NIC mới bằng `ip -brief link`, sau đó tạo Netplan riêng. Thay `<UBUNTU_LAB_IFACE>` bằng interface đã kiểm chứng:

```yaml
network:
  version: 2
  ethernets:
    <UBUNTU_LAB_IFACE>:
      dhcp4: false
      dhcp6: false
      addresses:
        - 192.168.100.10/24
      optional: true
```

Lưu dưới `/etc/netplan/60-docker-security-isolated.yaml`, đặt quyền `0600`, chạy `sudo netplan try`, rồi mới `sudo netplan apply`. Không thêm `gateway4`, default route hoặc nameserver.

Trên Kali, xác định NIC mới bằng `ip -brief link`, rồi dùng NetworkManager:

```bash
sudo nmcli connection add \
  type ethernet \
  ifname '<KALI_LAB_IFACE>' \
  con-name docker-security-lab \
  ipv4.method manual \
  ipv4.addresses 192.168.100.20/24 \
  ipv4.never-default yes \
  ipv4.ignore-auto-dns yes \
  ipv6.method disabled \
  connection.autoconnect yes

sudo nmcli connection up docker-security-lab
```

Không chạy lệnh nếu chưa xác định chắc chắn NIC isolated; cấu hình sai interface có thể làm mất kết nối quản trị.

## 8. Đưa repository vào VM

Clone trong maintenance window hoặc tạo bundle trên máy có GitHub access:

```bash
git clone https://github.com/quangnguyen16325/docker-security-project.git
cd docker-security-project
git bundle create ../docker-security-project.bundle --all
```

Chuyển bundle qua kênh offline được duyệt, rồi trong VM:

```bash
git clone docker-security-project.bundle docker-security-project
```

Không đặt token trong URL và không copy `.env`, private key hoặc credential vào VM/repository.

## 9. Cắt Internet và khóa baseline

1. Tắt sạch hai VM.
2. Trong Virtual Machine Manager, bỏ chọn **Link state: active** cho NIC `default` NAT của cả hai VM; giữ NIC isolated active.
3. Khởi động lại hai VM.
4. Xác nhận không có default route, DNS hoặc Internet route. Không ping địa chỉ Internet; dùng `ip route get 1.1.1.1` và yêu cầu lệnh thất bại.
5. Xác nhận ping hai chiều `192.168.100.10` ↔ `192.168.100.20`.
6. Chạy script validation theo mục tiếp theo.
7. Tắt Ubuntu sạch và tạo snapshot `docker-lab-network-ready`.

## 10. Validation và điều kiện GO

Trên libvirt host:

```bash
./scripts/validate-lab.sh host
```

Trên Ubuntu và Kali tương ứng:

```bash
./scripts/validate-lab.sh ubuntu
./scripts/validate-lab.sh kali
```

Chỉ bắt đầu dự án khi cả ba kết quả là `PASS`, output đã làm sạch được gửi cho trưởng nhóm và trạng thái được duyệt là **GO**. Nếu có `FAIL`, không tự thay đổi firewall/network để sửa; báo trưởng nhóm kèm command và kết quả.

## 11. Quy tắc trong giai đoạn thực nghiệm

- Khôi phục baseline trước mỗi nhóm test và dùng snapshot/clone dùng một lần.
- Không bật lại NIC NAT, expose Docker API, đổi subnet hoặc sửa daemon.
- Không quét/tấn công hệ thống ngoài `192.168.100.0/24` và container LAB được duyệt.
- Không dùng dữ liệu thật; không commit log thô hoặc thông tin định danh.
- Thực hiện đúng Before → Hardening → Retest và cleanup sau test.
