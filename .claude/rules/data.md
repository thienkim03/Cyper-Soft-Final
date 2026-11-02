---
paths:
  - "data/**"
---
# Quy tắc dữ liệu

- `data/raw/`: chỉ đọc. Tuyệt đối không sửa, ghi đè hay xoá file trong đây.
- Luồng dữ liệu một chiều: raw -> interim -> processed. Không ghi ngược lại.
- Tên file: `ten_bang_YYYYMMDD.csv` (ví dụ `sales_20261102.csv`).
- Ưu tiên lưu dữ liệu đã xử lý dạng `.parquet` (nhanh, giữ kiểu dữ liệu); xuất `.csv` khi cần nạp vào BI.
- Khi làm sạch, ghi lại số dòng trước/sau và lý do loại bỏ dòng.
- Mọi bảng mới phải được mô tả trong `docs/data_dictionary.md` (tên cột, kiểu, ý nghĩa, nguồn).
