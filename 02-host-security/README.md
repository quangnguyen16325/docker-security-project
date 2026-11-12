# Docker Host & Daemon Security LAB

## Mục tiêu

Đánh giá ranh giới tin cậy giữa container, Docker daemon và Ubuntu host. LAB
thực nghiệm bind mount read-write/read-only bằng dữ liệu giả; Docker socket,
nhóm `docker` và daemon listener chỉ được kiểm tra metadata ở chế độ read-only.

## Baseline

- Ubuntu Server 24.04.5 LTS; Docker Engine `28.5.2`.
- Docker Compose Plugin `2.40.3`.
- Image pin theo digest:
  `ubuntu@sha256:2198e4c65076e9cb0b3d695219df667c0e3b0072da64ca3c2648aca17dcecaf5`.
- Docker network `docker-security-lab`, `172.30.0.0/24`, `internal=true`.
- Không có default route, Internet hoặc Docker TCP listener `2375/2376`.

## Test case

- `HS-01`: bind mount dữ liệu giả read-write so với read-only.
- `HS-02`: kiểm tra owner/mode của Docker Unix socket; không mount socket.
- `HS-03`: kiểm tra nguyên tắc quyền nhóm `docker`; không đổi membership.
- `HS-04`: xác minh daemon không lắng nghe TCP `2375/2376`.
- `HS-05`: xác minh workload không privileged, không host namespace/device và
  không có mount ngoài đường dẫn giả đã duyệt.

Thực hiện theo **Research → Build → Test → Analyze → Harden → Retest → Compare
→ Document**.

## Giới hạn an toàn

Không mount `/var/run/docker.sock`, `/`, `/etc`, `/var` hoặc thiết bị host.
Không đổi `daemon.json`, systemd, socket permission, nhóm `docker`, firewall,
NIC, route, snapshot hoặc Docker network. Không bật Docker API TCP.

## Lệnh tái hiện HS-01

Chạy trong thư mục này trên Ubuntu Docker VM:

```bash
sudo docker compose -f compose.before.yml config --quiet
sudo docker compose -f compose.before.yml up -d
sudo docker compose -f compose.before.yml exec -T lab \
  sh -c 'cat /host-data/sample.txt; echo before-write > /host-data/before-write.txt'
cat lab-data/before-write.txt
sudo docker compose -f compose.before.yml down

sudo docker compose -f compose.hardened.yml config --quiet
sudo docker compose -f compose.hardened.yml up -d
sudo docker compose -f compose.hardened.yml exec -T lab \
  sh -c 'cat /host-data/sample.txt; echo retest > /host-data/retest.txt'
sudo docker compose -f compose.hardened.yml down
```

Before phải đọc và ghi được dữ liệu giả. Retest phải đọc được nhưng thao tác
ghi phải thất bại với filesystem read-only.

## Cleanup

```bash
sudo docker compose -f compose.before.yml down --remove-orphans
sudo docker compose -f compose.hardened.yml down --remove-orphans
sudo docker ps -a
cd ..
sudo ./scripts/validate-lab.sh ubuntu
```

Chỉ xóa file thử nghiệm do LAB tạo. Không sửa quyền hoặc nội dung nào ngoài
`02-host-security/lab-data/`.

## Kết quả đã xác nhận

`HS-01` đến `HS-05` đều PASS. Before đọc/ghi được bind mount giả; Retest vẫn
đọc nhưng chặn ghi. Socket không được mount, group membership không đổi,
`2375/2376` không mở và baseline cuối không còn container.
