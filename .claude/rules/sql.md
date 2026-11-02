---
paths:
  - "sql/**"
---
# Quy tắc SQL

- Từ khoá SQL viết HOA (`SELECT`, `FROM`, `JOIN`); tên bảng, cột viết thường snake_case.
- `sql/staging/`: tiền tố `stg_` - làm sạch, đổi tên cột, ép kiểu, 1 bảng nguồn -> 1 bảng staging.
- `sql/marts/`: tiền tố `fact_` và `dim_` - mô hình hình sao (star schema) cho dashboard.
- Không dùng `SELECT *` trong query cuối; liệt kê rõ cột.
- Dùng CTE (`WITH ...`) thay cho subquery lồng nhiều tầng.
- Đầu mỗi file ghi 1 dòng comment mô tả mục đích và bảng nguồn.
