# Before / Hardening / Retest Comparison

| Test ID | Before expected | Hardened expected | Actual result | Evidence |
|---|---|---|---|---|
| CS-01 | `UID 0` | `UID 10001` | Before: `uid=0`; Retest: `uid=10001` — PASS | Hai log ngày `2026-11-12` |
| CS-02 | Có capability mặc định | `CapEff` bằng 0 | Before: `a80425fb`; Retest: toàn số 0 — PASS | Hai log ngày `2026-11-12` |
| CS-03 | Ghi được vào `/data` | Ghi bị từ chối | Before ghi thành công; Retest trả RC 2, read-only — PASS | Hai log ngày `2026-11-12` |
| CS-04 | `NoNewPrivs` bằng 0 | `NoNewPrivs` bằng 1 | Before: `0`; Retest: `1` — PASS | Hai log ngày `2026-11-12` |
| CS-05 | Root filesystem ghi được | Root filesystem RO, `/tmp` ghi được | Before ghi rootfs thành công; Retest chặn `/root`, cho phép `/tmp` — PASS | Hai log ngày `2026-11-12` |

Kết luận: cấu hình hardened giảm quyền thực thi và vùng có thể ghi nhưng vẫn
duy trì hai chức năng hợp lệ của workload mẫu: đọc `/data/sample.txt` và ghi dữ
liệu tạm vào `/tmp`. Kết quả chỉ áp dụng cho các test case đã mô tả trong LAB.
