# Kế hoạch nghiên cứu

Quy trình chuẩn áp dụng cho mọi chủ đề:

## 1. Research

Xác định tài sản, tác nhân đe dọa, giả thuyết và lỗ hổng/cấu hình yếu. Ưu tiên tài liệu chính thức và nguồn từ năm 2024 trở đi; ghi URL, phiên bản và ngày truy cập.

## 2. Build Lab

Thiết kế topology tối thiểu, tạo snapshot sạch và dùng dữ liệu giả. Ghi image, phiên bản, cổng, quyền, giới hạn tài nguyên và rollback. Kịch bản quyền cao phải được trưởng nhóm duyệt.

## 3. Test

Chạy test case trong LAB cô lập theo từng bước có thể lặp lại. Thu thập log, trạng thái container/host và bằng chứng kỹ thuật; không ghi secret hoặc dữ liệu cá nhân.

## 4. Analyze

So sánh kết quả với giả thuyết. Xác định nguyên nhân gốc, điều kiện cần, tác động, khả năng phát hiện và giới hạn. Phân biệt rõ quan sát với suy luận.

## 5. Harden

Áp dụng biện pháp phù hợp: giảm capability, non-root, read-only filesystem, seccomp/AppArmor, daemon an toàn, image tối giản và audit/detection. Ghi từng thay đổi để có thể hoàn tác.

## 6. Retest

Chạy lại đúng test case và điều kiện đo ban đầu. Xác minh rủi ro bị chặn hoặc giảm tác động, đồng thời chức năng hợp lệ vẫn hoạt động.

## 7. Evaluate

Đánh giá mức giảm rủi ro, độ bao phủ phát hiện, false positive, hiệu năng, khả năng vận hành và tính tái lập. Kết luận phải liên kết bằng chứng trước/sau và nêu hạn chế.

## Đầu ra bắt buộc

Mỗi chủ đề cần threat model ngắn, hướng dẫn LAB, test case, bằng chứng đã làm sạch, phân tích nguyên nhân, cấu hình hardening, retest và kết luận. Trưởng nhóm duyệt an toàn trước test và duyệt tính nhất quán trước tích hợp.

