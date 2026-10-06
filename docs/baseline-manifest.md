# Baseline Manifest

Tài liệu này là nguồn chuẩn để đối chiếu LAB của các thành viên. Không coi một môi trường là hợp lệ chỉ vì clone được repository; môi trường phải vượt qua checklist và được trưởng nhóm xác nhận.

## Ubuntu Docker Host

- VM name: `docker-security-ubuntu2404`
- OS: Ubuntu Server 24.04.5 LTS
- Kernel đã xác nhận: `6.8.0-146-generic` x86_64
- Tài nguyên tham chiếu: 4 vCPU, 8 GB RAM, QCOW2 sparse 32 GB
- Docker Engine client/server: `28.5.2`
- Docker Compose Plugin: `2.40.3`
- containerd: `2.3.6`
- LAB IP: `192.168.100.10/24`
- Không có default gateway hoặc DNS trên NIC LAB
- Docker API chỉ dùng Unix socket; không có listener TCP 2375/2376

## Kali Linux

- VM name: `kali-linux`
- LAB IP: `192.168.100.20/24`
- Không có default gateway hoặc DNS trên NIC LAB
- Ghi lại release/kernel thực tế khi dựng; không tự suy đoán phiên bản Kali

## Libvirt Network

- Name: `docker-security-isolated`
- Bridge: `virbr100`
- Logical subnet: `192.168.100.0/24`
- Layer 2 only; không `<forward>` và không host `<ip>`
- Không NAT, DHCP, DNS, gateway, host route hoặc physical bridge port
- NIC nối `default` NAT của cả hai VM phải ở trạng thái down trước khi test

## Docker Network

- Name: `docker-security-lab`
- Driver: bridge
- Subnet: `172.30.0.0/24`
- `internal=true`

## Snapshot và trạng thái sạch

- Snapshot chuẩn: `docker-lab-network-ready`
- Không có container thử nghiệm còn tồn tại tại thời điểm chụp snapshot
- Image `hello-world` đã được chạy thành công trong giai đoạn provisioning
- Không có secret thật, dữ liệu cá nhân hoặc mount host nhạy cảm

## Lệnh fingerprint read-only

```bash
cat /etc/os-release
uname -srmo
docker version
docker compose version
docker network inspect docker-security-lab
ip -brief address
ip route
ss -lnt
```

Không đưa hostname, MAC, credential hoặc đường dẫn cá nhân vào báo cáo. Thành viên gửi kết quả đã làm sạch cùng output của `scripts/validate-lab.sh` cho trưởng nhóm duyệt.
