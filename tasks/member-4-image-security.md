# Thành viên 4 — Docker Image Security

## 1. Mục tiêu

Đánh giá lỗ hổng và cấu hình không an toàn trong image; dùng Trivy và review Dockerfile để tạo, đo lường và giải thích phiên bản image đã harden.

## 2. Phạm vi nghiên cứu

- CVE trong base image và dependency.
- Tag/digest, provenance cơ bản và bề mặt package.
- Dockerfile security, secret hygiene và build context.
- So sánh vulnerable image với hardened image; không khai thác CVE.

## 3. Kiến thức cần tìm hiểu

CVE/CVSS, false positive, fixed version, distro advisory, image layers, multi-stage build, `.dockerignore`, non-root user, pin digest và định dạng báo cáo Trivy.

## 4. LAB phải xây dựng

Trong `03-image-security/`, chuẩn bị một ứng dụng nhỏ với hai Dockerfile: phiên bản phụ thuộc dễ tổn thương được chọn có chủ đích và phiên bản cập nhật/tối giản. Chỉ dùng image công khai, dữ liệu giả và phiên bản từ 2024 trở đi khi phù hợp yêu cầu môn học.

## 5. Các bước thực hiện ở mức kế hoạch

Theo **Research → Build → Test → Analyze → Harden → Retest → Compare → Document**:

1. Chọn image/dependency và xác minh nguồn advisory.
2. Trình duyệt Dockerfile, nguồn tải, digest và command scan.
3. Build image tái lập được; scan theo severity đã thống nhất.
4. Phân loại CVE thật, chưa sửa và không áp dụng.
5. Cập nhật base/dependency, tối giản layer, retest và so sánh.

## 6. Kết quả mong đợi

Báo cáo chỉ ra CVE theo package/fixed version, giảm số phát hiện có thể khắc phục và giảm bề mặt/image size mà ứng dụng vẫn hoạt động.

## 7. Hardening

Pin version/digest, chọn base image được duy trì, cập nhật dependency, dùng multi-stage build, bỏ build tools/cache, chạy non-root, dùng `.dockerignore` và không đưa secret vào `ARG`, `ENV` hoặc layer.

## 8. Retest

Scan lại với cùng Trivy DB/policy khi so sánh; chạy smoke test chức năng, kiểm tra user và image history đã làm sạch. Giải thích CVE còn lại thay vì che giấu.

## 9. Deliverables

- Dockerfile vulnerable/hardened và `.dockerignore` trong `03-image-security/`.
- `scan-summary.md`, `analysis.md`, `comparison.md`.
- Báo cáo scan máy đọc được đã loại dữ liệu không cần thiết; không commit Trivy DB/cache.
- Danh mục nguồn advisory và lệnh tái hiện.

## 10. Screenshot/log cần thu thập

Ghi phiên bản Trivy, image tag/digest rút gọn, thời điểm DB, tổng CVE theo severity, fixed version, image size và smoke-test. Không chụp registry credential, token hoặc đường dẫn cá nhân.

## 11. Tiêu chí nghiệm thu

- Mỗi CVE kết luận đều có advisory đáng tin cậy và trạng thái fix.
- Cùng một policy scan được dùng trước/sau.
- Hardened image không có HIGH/CRITICAL có bản vá, trừ ngoại lệ được giải trình.
- Dockerfile vượt review secret, user và pinning; ứng dụng vẫn chạy.

## 12. Những việc không được phép thay đổi trên baseline

Không cập nhật Docker Engine/Compose, daemon, network, firewall, VM package hoặc snapshot. Không push image ra registry, đăng nhập registry, tải image không rõ nguồn hoặc xóa image dùng chung. Không chạy exploit cho CVE.

## 13. Checklist để trưởng nhóm review

- [ ] Nguồn image/advisory và license được ghi rõ.
- [ ] Version/digest và Trivy DB timestamp có thể đối chiếu.
- [ ] Không có secret trong context, layer, log hay artifact.
- [ ] Phân loại false positive/không áp dụng có lý do.
- [ ] Có smoke test và so sánh định lượng trước/sau.
- [ ] Không làm thay đổi baseline hoặc image dùng chung.

