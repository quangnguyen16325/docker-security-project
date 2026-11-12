# Host & Daemon Security Analysis

## Phạm vi

Phân tích `HS-01` đến `HS-05` bằng dữ liệu giả. Không mount Docker socket,
filesystem nhạy cảm hoặc thiết bị host; không thay đổi daemon hay nhóm `docker`.

## Kết quả

### Bind mount

Hai cấu hình dùng cùng image, UID/GID `1000:1000`, dữ liệu giả và Docker
network. Với mount `RW=true`, workload đọc được `sample.txt`, tạo được
`before-write.txt` và host quan sát đúng nội dung `before-write`. Sau khi đổi
duy nhất mount thành `RW=false`, workload vẫn đọc thành công nhưng ghi trả về
RC `2` với lỗi `Read-only file system`.

### Docker socket, daemon và isolation

- Unix socket có mode `660`, owner `root`, group `docker`.
- Docker dùng context `default`; security options gồm AppArmor, Seccomp builtin
  và cgroup namespaces.
- Socket không được mount vào hai workload.
- Cả hai container đều `Privileged=false`, không host PID, không device và chỉ
  có bind mount `/host-data` đã duyệt.
- Không có listener TCP `2375/2376` trước hoặc sau LAB.

Quyền ghi Docker socket cho phép principal gửi yêu cầu tới daemon rootful nên
cần được quản lý như quyền quản trị cao. LAB không đổi permission hoặc thành
viên nhóm và không gửi request qua socket từ container.

### Cleanup

Hai container và file thử nghiệm đã được xóa. Baseline validation đạt
`failures=0`, `warnings=0`; Docker network vẫn internal và VM không có default
route. Log lần đầu không hợp lệ được giữ với hậu tố `attempt1`; kết luận chỉ
dùng log lần chạy lại đã kiểm tra đúng điều kiện Before.
