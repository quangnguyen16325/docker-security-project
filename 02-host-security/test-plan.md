# Kế hoạch kiểm thử Docker Host & Daemon

## Điều kiện tiên quyết

- Baseline `host`, `ubuntu` và `kali` phải PASS.
- Không có default route, Internet hoặc container tồn tại trước test.
- Docker network phải giữ `internal=true`.
- Chỉ dùng dữ liệu giả trong `02-host-security/lab-data/`.
- Hai cấu hình dùng cùng UID/GID `1000:1000`, khớp chủ sở hữu thư mục giả;
  biến kiểm thử duy nhất của HS-01 là mount `rw` hoặc `ro`.
- Dừng nếu có listener `2375/2376`, mount ngoài dự kiến hoặc thay đổi baseline.

## Ma trận kiểm thử

| ID | Before | Hardening/Retest | Expected result |
|---|---|---|---|
| HS-01 | `/host-data` bind mount `rw` | Cùng path chuyển sang `ro` | Before ghi được; Retest chỉ đọc được |
| HS-02 | Đọc mode/owner socket từ host | Workload không nhận socket | Không có socket mount trong container |
| HS-03 | Kiểm tra quyền nhóm socket | Không đổi membership | Giải thích quyền daemon, baseline không đổi |
| HS-04 | Kiểm tra listener trước | Kiểm tra lại sau | Không có TCP `2375/2376` |
| HS-05 | Inspect mount/namespace/device | Giữ least privilege | Không privileged/host namespace/device |

## Command read-only trên host

```bash
stat -c 'mode=%a owner=%U group=%G type=%F' /var/run/docker.sock
docker context show
docker info --format '{{json .SecurityOptions}}'
ss -lnt
docker inspect CONTAINER --format \
  'Privileged={{.HostConfig.Privileged}} PidMode={{.HostConfig.PidMode}} NetworkMode={{.HostConfig.NetworkMode}} Devices={{json .HostConfig.Devices}}'
```

Không dùng `getent group docker` trong evidence vì có thể hiển thị danh tính
tài khoản. Chỉ ghi nhận nguyên tắc: principal có quyền ghi socket có thể gửi
yêu cầu tới daemon rootful và cần được quản lý như quyền quản trị cao.

## Rollback và cleanup

1. Dừng hai Compose stack và chỉ xóa container/network tạm do chúng tạo.
2. Xóa `before-write.txt` hoặc `retest.txt` nếu LAB đã tạo trong thư mục giả.
3. Xác nhận `docker ps -aq` rỗng.
4. Kiểm tra lại route, network internal và listener `2375/2376`.
5. Chạy `scripts/validate-lab.sh ubuntu`; dừng nếu kết quả không PASS.

Không chỉnh daemon, socket, group, firewall hoặc mạng để xử lý lỗi. Nếu cleanup
không đạt, dừng và báo trưởng nhóm.
