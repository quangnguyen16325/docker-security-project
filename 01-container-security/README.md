# Container Security LAB

## Mục tiêu

So sánh một container chạy với quyền rộng và phiên bản áp dụng least
privilege. LAB chỉ dùng dữ liệu giả và chạy trong Docker network nội bộ của dự
án. Không mount Docker socket, thiết bị hoặc thư mục hệ thống của host.

## Baseline

- Docker Engine: `28.5.2`
- Docker Compose Plugin: `2.40.3`
- Image đã pin:
  `ubuntu@sha256:2198e4c65076e9cb0b3d695219df667c0e3b0072da64ca3c2648aca17dcecaf5`
- Docker network: `docker-security-lab`, `172.30.0.0/24`, `internal=true`
- Không có Internet/default route trong lúc chạy LAB.

## Test case

- `CS-01`: root (`UID 0`) so với non-root (`UID 10001`).
- `CS-02`: capabilities mặc định so với `cap_drop: ALL`.
- `CS-03`: bind mount dữ liệu giả read-write so với read-only.
- `CS-04`: `NoNewPrivs=0` so với `no-new-privileges:true`.
- `CS-05`: xác minh filesystem chỉ đọc nhưng `/tmp` vẫn ghi được.

Mỗi test phải theo thứ tự **Before → Harden → Retest → Compare** và dùng cùng
image, input và Docker network.

## Chuẩn bị đã hoàn thành

- Image đã được tải trước trong maintenance window và pin bằng digest.
- `compose.before.yml` và `compose.hardened.yml` đã được kiểm tra cú pháp.
- `lab-data/sample.txt` là dữ liệu giả duy nhất được mount vào container.
- Output thực nghiệm trong `evidence/` được giữ cục bộ và không commit mặc định.

## Lệnh tái hiện

Chạy từ thư mục này trên Ubuntu Docker VM.

### Before

```bash
sudo docker compose -f compose.before.yml up -d
sudo docker compose -f compose.before.yml ps
sudo docker compose -f compose.before.yml exec lab id
sudo docker compose -f compose.before.yml exec lab \
  sh -c "grep -E 'CapEff|NoNewPrivs' /proc/1/status"
sudo docker compose -f compose.before.yml exec lab \
  sh -c "echo before-write > /data/before-write.txt"
cat lab-data/before-write.txt
sudo docker compose -f compose.before.yml down
```

### Hardened và retest

```bash
sudo docker compose -f compose.hardened.yml up -d
sudo docker compose -f compose.hardened.yml ps
sudo docker compose -f compose.hardened.yml exec lab id
sudo docker compose -f compose.hardened.yml exec lab \
  sh -c "grep -E 'CapEff|NoNewPrivs' /proc/1/status"
sudo docker compose -f compose.hardened.yml exec lab \
  sh -c "echo retest > /data/retest.txt"
sudo docker compose -f compose.hardened.yml exec lab \
  sh -c "echo allowed > /tmp/allowed.txt && cat /tmp/allowed.txt"
sudo docker compose -f compose.hardened.yml down
```

Ở retest, ghi vào `/data` phải thất bại; ghi vào `/tmp` phải thành công. Không
tiếp tục nếu hành vi khác expected result.

### So sánh privileged và unprivileged

Test `CS-06` chỉ đọc trạng thái tiến trình. Hai container không có network,
mount, port hoặc Docker socket; root filesystem đặt read-only và container được
xóa ngay sau test.

```bash
IMAGE='ubuntu@sha256:2198e4c65076e9cb0b3d695219df667c0e3b0072da64ca3c2648aca17dcecaf5'

sudo docker run --rm --network none --read-only "$IMAGE" \
  sh -c 'id; grep -E "^(CapEff|NoNewPrivs|Seccomp):" /proc/self/status'

sudo docker run --rm --network none --read-only --privileged "$IMAGE" \
  sh -c 'id; grep -E "^(CapEff|NoNewPrivs|Seccomp):" /proc/self/status'
```

Không thêm volume, thiết bị, Docker socket hoặc lệnh thay đổi host vào test này.
Kết quả đã quan sát: privileged cấp tập capability rất rộng và không áp dụng
Seccomp filter mặc định.

## Cleanup và kiểm tra cuối

```bash
sudo docker compose -f compose.before.yml down --remove-orphans
sudo docker compose -f compose.hardened.yml down --remove-orphans
rm -f lab-data/before-write.txt lab-data/retest.txt
sudo docker ps -a
cd ..
sudo ./scripts/validate-lab.sh ubuntu
```

Không xóa image dùng chung và không thay đổi daemon, firewall, NIC, snapshot
hoặc Docker network.
