# Before / Hardening / Retest Comparison

| Test ID | Before expected | Hardened expected | Actual result |
|---|---|---|---|
| HS-01 | Đọc và ghi được `/host-data` | Đọc được, ghi bị từ chối | Before read/write RC `0`; Retest read RC `0`, write RC `2` — PASS |
| HS-02 | Socket chỉ được quan sát từ host | Không có socket mount trong workload | Socket metadata được ghi nhận; trong container socket absent — PASS |
| HS-03 | Ghi nhận quyền socket | Không đổi group membership | Mode `660`, owner `root`, group `docker`; membership không đổi — PASS |
| HS-04 | Không có listener `2375/2376` | Vẫn không có listener sau LAB | Không có listener trước/sau — PASS |
| HS-05 | Không privileged/host namespace/device | Giữ nguyên least privilege | `Privileged=false`, không host PID/device, chỉ mount dữ liệu giả — PASS |
