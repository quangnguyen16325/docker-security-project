# Container Security Analysis

## Phạm vi

Phân tích `CS-01` đến `CS-05` bằng dữ liệu giả. Không thử container escape,
không dùng `privileged: true`, không mount Docker socket hoặc filesystem hệ
thống của host.

## Before

Đã thực hiện trên Ubuntu Docker VM. Container chạy bằng `UID 0`, giữ bộ
capability mặc định (`CapEff=00000000a80425fb`), có
`NoNewPrivs=0`, ghi được vào bind mount `/data` và root filesystem. Container
không chạy ở chế độ privileged. Kết quả này chứng minh cấu hình Before cấp
nhiều quyền hơn nhu cầu của workload mẫu, không chứng minh container escape.

## Hardening

Các thay đổi duy nhất giữa hai cấu hình:

- Chuyển từ root sang UID/GID `10001`.
- Drop toàn bộ Linux capabilities.
- Bật `no-new-privileges`.
- Đặt root filesystem read-only.
- Chuyển bind mount `/data` sang read-only.
- Dùng `tmpfs` giới hạn cho `/tmp`.

## Retest

Retest đạt toàn bộ kỳ vọng:

- Tiến trình chạy bằng `UID/GID 10001`, không phải root.
- `CapEff=0000000000000000` và `NoNewPrivs=1`.
- Ghi vào `/data` bị chặn vì bind mount read-only.
- Ghi vào `/root` bị chặn; root filesystem đặt read-only.
- Đọc dữ liệu giả trong `/data` và ghi tạm vào `/tmp` vẫn thành công.

Sau kiểm thử, Compose stack đã được gỡ. Script kiểm tra baseline trả về
`failures=0`, `warnings=0`; không còn container, default route hoặc listener
Docker TCP `2375/2376`.

## Privileged và unprivileged

Test `CS-06` dùng cùng image và lệnh chỉ đọc. Cả hai container đều có
`network=none`, root filesystem read-only, không mount, không port và không
Docker socket. Container unprivileged có `CapEff=00000000a80425fb` và
`Seccomp=2`; container privileged có `CapEff=000001ffffffffff` và `Seccomp=0`.

Kết quả cho thấy `--privileged` mở rộng mạnh tập capability và vô hiệu hóa
Seccomp filter mặc định. Test không thực hiện thao tác đặc quyền hoặc tác động
host. Hai container đã được xóa và baseline sau test vẫn đạt.

Log bằng chứng cục bộ trong VM:
`evidence/20261112-CS-before.txt` và
`evidence/20261112-CS-hardened-retest.txt`, cùng log
`evidence/CS-06-privileged-comparison.txt`. Thư mục evidence bị loại khỏi Git.

## Giới hạn

Kết quả chỉ chứng minh tác động của cấu hình trong workload này. Không được suy
diễn thành container escape hoặc khả năng chiếm host nếu chưa có bằng chứng.
