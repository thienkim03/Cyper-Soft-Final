---
paths:
  - "notebooks/**"
  - "src/**"
---
# Quy tắc Python & notebook

- Notebook đánh số theo thứ tự chạy: `01_eda.ipynb`, `02_cleaning.ipynb`, `03_analysis.ipynb`.
- Notebook dùng để khám phá; logic dùng lại nhiều lần chuyển vào `src/` rồi import.
- Dùng đường dẫn tương đối từ gốc dự án (`pathlib.Path`), không hard-code `C:\...`.
- Thư viện chính: pandas, numpy, matplotlib/seaborn hoặc plotly.
- Notebook phải chạy lại được từ đầu đến cuối (Restart & Run All) không lỗi.
- Biểu đồ dùng cho báo cáo lưu vào `reports/figures/` dạng `.png`, có tiêu đề và nhãn trục.
