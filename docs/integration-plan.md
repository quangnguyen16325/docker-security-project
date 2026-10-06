# Kế hoạch tích hợp kết quả

## Mục tiêu

Tích hợp kết quả của bốn thành viên thành một chuỗi chứng minh nhất quán: baseline yếu → quan sát rủi ro → hardening → retest → đánh giá. Trưởng nhóm sở hữu cấu trúc chung, tiêu chí chất lượng và bản demo trong `05-integration/`.

## Hợp đồng bàn giao chung

Mỗi thành viên nộp trong thư mục phụ trách:

- `README.md`: mục tiêu, phạm vi, phiên bản, threat model và điều kiện an toàn.
- `lab/`: cấu hình tái lập; không chứa secret hoặc dữ liệu thật.
- `evidence/`: log/ảnh đã làm sạch, đặt tên `YYYYMMDD-test-id-stage`.
- `analysis.md`: nguyên nhân gốc, tác động, giới hạn và quan sát.
- `hardening.md`: thay đổi phòng chống, trade-off và rollback.
- `retest.md`: cùng test case/điều kiện đo, so sánh trước và sau.

## Luồng tích hợp

1. **Freeze baseline:** chốt topology, phiên bản, naming và biểu mẫu bằng chứng.
2. **Review từng mảng:** trưởng nhóm kiểm tra tính tái lập, an toàn và liên kết evidence.
3. **Chuẩn hóa đầu ra:** thống nhất ID test case, mức độ rủi ro và chỉ số trước/sau.
4. **Ghép kịch bản:** đưa các cấu hình được duyệt vào `05-integration/`; không sao chép secret.
5. **Dry run:** chạy lần lượt image → container → host/daemon → detection trong snapshot LAB.
6. **Hardening và retest:** áp dụng biện pháp theo lớp, ghi rõ biện pháp nào ảnh hưởng test nào.
7. **Đánh giá:** tổng hợp mức giảm rủi ro, detection coverage, false positive, hiệu năng và hạn chế.
8. **Release candidate:** peer review chéo, làm sạch evidence, khóa phiên bản báo cáo và slide.

## Ma trận trách nhiệm

- **Thành viên 2:** test case và kết quả Container Security.
- **Thành viên 3:** điều kiện host/daemon, logging nền và ranh giới Docker socket.
- **Thành viên 4:** image/Dockerfile, dependency, SBOM và kết quả scan.
- **Thành viên 5:** cấu hình hardening, audit/detection và chỉ số cảnh báo.
- **Trưởng nhóm:** phê duyệt baseline, giải quyết xung đột, điều phối retest, tổng hợp đánh giá và demo.

## Quality gate

Không tích hợp khi thiếu phiên bản, rollback, bằng chứng đã làm sạch hoặc review chéo. Không đưa test case có egress ngoài LAB vào demo. Một kết luận chỉ được dùng trong báo cáo khi có evidence trước/sau và có thể tái hiện từ snapshot baseline.

