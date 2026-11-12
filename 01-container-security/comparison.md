# Before / Hardening / Retest Comparison

| Test ID | Before expected | Hardened expected | Actual result | Evidence |
|---|---|---|---|---|
| CS-01 | `UID 0` | `UID 10001` | Chưa thực hiện | Chưa có |
| CS-02 | Có capability mặc định | `CapEff` bằng 0 | Chưa thực hiện | Chưa có |
| CS-03 | Ghi được vào `/data` | Ghi bị từ chối | Chưa thực hiện | Chưa có |
| CS-04 | `NoNewPrivs` bằng 0 | `NoNewPrivs` bằng 1 | Chưa thực hiện | Chưa có |
| CS-05 | Root filesystem ghi được | Root filesystem RO, `/tmp` ghi được | Chưa thực hiện | Chưa có |

Chỉ cập nhật cột Actual result sau khi chạy cùng test case trên snapshot và
baseline đã ghi trong `README.md`.
