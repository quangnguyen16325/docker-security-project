# Kiến trúc LAB Docker Security

## Sơ đồ

```mermaid
flowchart LR
  subgraph LAB[VM/LAB cô lập]
    K[Kali Linux VM<br/>192.168.100.20/24]
    N[docker-security-isolated<br/>virbr100 · Layer 2 only<br/>192.168.100.0/24]
    H[Ubuntu Server 24.04 LTS VM<br/>192.168.100.10/24<br/>Docker Engine 28.5.2]

    subgraph D[docker-security-lab · 172.30.0.0/24 · internal]
      C1[Container LAB<br/>Container Security]
      C2[Container LAB<br/>Host & Daemon]
      C3[Container LAB<br/>Image Security]
      C4[Audit & Detection<br/>Collector]
    end

    K -->|NIC isolated| N
    N --> H
    H --> C1
    H --> C2
    H --> C3
    H --> C4
    C1 -. log .-> C4
    C2 -. log .-> C4
    C3 -. log .-> C4
  end

  M[Libvirt host / VM Manager<br/>Control plane cục bộ] -.->|Quản trị VM| H
  X[Hệ thống bên ngoài]:::blocked
  LAB -. Không NAT · không Internet · không LAN .- X

  classDef blocked fill:#fee,stroke:#b00,color:#700;
```

## Ranh giới tin cậy

- Kali và Ubuntu chỉ giao tiếp qua `docker-security-isolated`; NIC NAT `default` của cả hai VM bị disable.
- `virbr100` không có IP host, gateway, DHCP, DNS, NAT, forwarding hoặc cổng nối vào LAN vật lý.
- Kali chỉ kết nối tới subnet LAB và các cổng được ghi trong test case.
- Docker Host là ranh giới quản trị; không dùng chung với máy cá nhân hoặc dịch vụ thật.
- Container dùng dữ liệu giả, giới hạn CPU/RAM/PID và không có egress mặc định.
- Docker socket, host filesystem, privileged mode và host network bị cấm, trừ kịch bản đã duyệt và có snapshot rollback.
- Máy quản trị chỉ dùng để điều phối, thu log đã làm sạch và lưu tài liệu.

## Luồng vận hành

Trưởng nhóm tạo snapshot baseline, phê duyệt test case, mở đúng kết nối cần thiết và theo dõi log. Sau mỗi test, nhóm lưu bằng chứng đã làm sạch, khôi phục trạng thái hoặc xác minh không còn tài nguyên thử nghiệm rồi mới chuyển sang kịch bản tiếp theo.
