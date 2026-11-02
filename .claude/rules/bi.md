---
paths:
  - "bi/**"
  - "reports/**"
---
# Quy tắc BI & báo cáo

- Dashboard chỉ lấy dữ liệu từ `data/processed/` hoặc bảng `fact_`/`dim_`, không lấy từ `data/raw/`.
- Mỗi trang dashboard trả lời một câu hỏi nghiệp vụ rõ ràng; đặt câu hỏi làm tiêu đề trang.
- KPI chính đặt ở góc trên bên trái; có so sánh kỳ trước hoặc mục tiêu.
- Measure DAX đặt tên rõ nghĩa (`Total Revenue`, `Revenue YoY %`), gom vào một bảng `_Measures`.
- Thống nhất màu sắc theo theme trong `bi/themes/`; tối đa 5-6 màu mỗi trang.
- Insight trong báo cáo viết theo dạng: Phát hiện -> Bằng chứng (số liệu) -> Đề xuất hành động.
