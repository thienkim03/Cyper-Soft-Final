# [CyperSoft] Final Project - Phân tích dữ liệu & BI

Dự án phân tích dữ liệu thương mại điện tử (bán quần áo online): xây pipeline ETL từ dữ liệu CSV gốc, làm sạch, mô hình hoá dữ liệu và trực quan hoá bằng dashboard BI.

**Trạng thái hiện tại**

| Giai đoạn | Trạng thái |
|---|---|
| Thu thập dữ liệu gốc (7 bảng CSV) | Xong |
| EDA cơ bản (nháp) | Đang làm - `notebooks/00_scrapt.ipynb` |
| ETL - Extract | Xong |
| ETL - Transform | Xong |
| ETL - Load | Xong - MySQL database `looker_ecommerce` |
| Advanced EDA | Xong - `notebooks/02_eda.ipynb`, giải thích tại `docs/eda_explanation.md` |
| SQL staging / marts | Chưa làm |
| Power BI - Import + Data model | Đang làm - file `Dashboard Looker Peformance` |
| Dashboard BI | Chưa làm |
| Báo cáo & slide | Chưa làm |

---

## 1. Bộ dữ liệu

Nằm trong `data/raw/`, gồm 7 bảng (cấu trúc dạng TheLook eCommerce).

| Bảng | Dung lượng | Mô tả | Cột chính |
|---|---|---|---|
| `users.csv` | ~17 MB | Khách hàng | `id`, `age`, `gender`, `country`, `city`, `traffic_source`, `created_at` |
| `orders.csv` | ~10 MB | Đơn hàng | `order_id`, `user_id`, `status`, `created_at`, `shipped_at`, `delivered_at`, `returned_at`, `num_of_item` |
| `order_items.csv` | ~20 MB | Chi tiết từng sản phẩm trong đơn | `id`, `order_id`, `user_id`, `product_id`, `inventory_item_id`, `status`, `sale_price` |
| `products.csv` | ~4 MB | Danh mục sản phẩm | `id`, `name`, `brand`, `category`, `department`, `cost`, `retail_price`, `distribution_center_id` |
| `inventory_items.csv` | ~94 MB | Hàng tồn kho, thời điểm nhập/bán | `id`, `product_id`, `created_at`, `sold_at`, `cost`, `product_*` |
| `distribution_centers.csv` | < 1 KB | 10 trung tâm phân phối | `id`, `name`, `latitude`, `longitude` |
| `events.csv` | ~390 MB | Hành vi truy cập web | `id`, `user_id`, `session_id`, `event_type`, `traffic_source`, `browser`, `uri`, `created_at` |

**Quan hệ giữa các bảng**

```
users ──< orders ──< order_items >── products >── distribution_centers
  │                       │             │
  │                       └──> inventory_items >──┘
  └──< events
```

- `orders.user_id` -> `users.id`
- `order_items.order_id` -> `orders.order_id`
- `order_items.product_id` -> `products.id`
- `order_items.inventory_item_id` -> `inventory_items.id`
- `products.distribution_center_id` -> `distribution_centers.id`
- `events.user_id` -> `users.id` (có thể rỗng với khách vãng lai)

> `events.csv` rất lớn, đã được loại khỏi git. Nên đọc theo chunk hoặc dùng `optimize_dtypes` để giảm RAM.

---

## 2. Cấu trúc thư mục

```
.
├── .claude/
│   ├── skills/token/          # Skill /token: trả lời ngắn gọn, tiết kiệm token
│   └── rules/                 # Quy tắc cho Claude: general, data, python, sql, bi
├── data/
│   ├── raw/                   # 7 file CSV gốc - CHỈ ĐỌC, không sửa
│   ├── external/              # Dữ liệu bổ sung từ nguồn ngoài
│   ├── interim/               # Kết quả trung gian giữa các bước làm sạch
│   └── processed/             # Dữ liệu sạch, dùng cho phân tích / BI
├── notebooks/
│   ├── 00_scrapt.ipynb        # EDA: đọc 7 bảng, kiểm tra kiểu dữ liệu
│   ├── 01_etl_pipeline.ipynb  # ETL: extract -> transform -> load, có ghi log
│   └── 02_eda.ipynb           # Advanced EDA: phân phối, outlier, tương quan, funnel
├── src/
│   ├── utils/                 # Hàm tiện ích dạng function (dùng nhiều nhất)
│   ├── analysis/              # Class phân tích EDA (Strategy/Template pattern)
│   └── etl/                   # Class xử lý dữ liệu (Strategy/Factory pattern)
├── sql/
│   ├── staging/               # stg_*: làm sạch, chuẩn hoá từng bảng gốc
│   └── marts/                 # fact_* / dim_*: mô hình hình sao cho dashboard
├── bi/
│   ├── dashboards/            # File Power BI (.pbix) / Tableau (.twbx)
│   ├── themes/                # Theme màu, logo
│   └── exports/               # Ảnh / PDF xuất từ dashboard
├── reports/
│   ├── figures/               # Biểu đồ dùng trong báo cáo (eda_*.png từ 02_eda.ipynb)
│   └── slides/                # Slide thuyết trình
├── docs/
│   ├── project_workflow.md    # Quy trình cả project, câu SQL import Power BI, DAX
│   ├── eda_explanation.md     # Giải thích notebook EDA + insight
│   ├── presentation_notes.md  # Lời nói thuyết trình + câu hỏi Q&A
│   ├── guide/                 # Hướng dẫn học tập: thiết kế Power BI, tìm insight, tips project, DAX A-Z
│   └── cheatsheet/            # Lệnh terminal: PowerShell, git, uv
├── log/                       # Log ETL: ETL_Project_YYYYMMDD.log
├── pyproject.toml / uv.lock   # Khai báo thư viện (quản lý bằng uv)
└── README.md
```

---

## 3. Cài đặt

Yêu cầu: Python >= 3.12, [uv](https://docs.astral.sh/uv/), MySQL (nếu dùng bước Load / đọc từ database).

```bash
# Cài thư viện vào .venv
uv sync

# Các module trong src/etl/ cần thêm scikit-learn
uv add scikit-learn

# Để chạy notebook trong VS Code / Jupyter
uv add --dev ipykernel
```

**Cấu hình database**: sửa `src/utils/config.py` (host, port, user, password, database).
File này chứa mật khẩu nên đã bị loại khỏi git - mỗi người tự tạo bản của mình.

---

## 4. Cách chạy

1. Mở notebook trong `notebooks/`, chọn kernel `.venv`.
2. Cell đầu tiên tự động:
   - chuyển thư mục làm việc về gốc dự án (nên đường dẫn `data/raw/...`, `log/...` luôn đúng);
   - thêm `src/` vào `sys.path` (nên `from utils.db import *` chạy được).
3. Chạy theo thứ tự số: `01_` -> `02_` -> ...

**Pipeline ETL** (`01_etl_pipeline.ipynb`):

| Bước | Hàm | Việc làm |
|---|---|---|
| Extract | `extract()` | Đọc 7 file CSV từ `data/raw/`, log số dòng mỗi bảng |
| Transform | `transform()` | Ép kiểu ngày (ISO8601), điền giá trị thiếu (`Unknown Product`, `Unknown Brand`, `Unknown City`), tạo cột `time_to_sell` |
| Load | `load()` | Ghi 7 bảng vào MySQL (`LOOKER_ECOMMERCE` trong `src/utils/config.py`), `if_exists='replace'` |
| Main | - | Chạy `extract()` -> `transform()` -> `load()` |

Log ghi đồng thời ra màn hình và `log/ETL_Project_YYYYMMDD.log`.

---

## 5. Mô hình dữ liệu Power BI

Dữ liệu được import từ MySQL bằng câu SQL ngay tại bước Get Data (chi tiết từng câu trong [docs/project_workflow.md](docs/project_workflow.md)).

### 5.1. Vì sao có 2 bảng fact: `orders` và `order_items` khác nhau thế nào

Hai bảng khác nhau ở **grain** (mức chi tiết - mỗi dòng đại diện cho cái gì):

| | `fact_orders` | `fact_order_items` |
|---|---|---|
| 1 dòng là | 1 **đơn hàng** | 1 **món hàng** trong đơn |
| Số dòng | 125.226 | 181.759 |
| Có giá tiền | Không | Có (`sale_price`, `cost`, `gross_profit`) |
| Gắn với sản phẩm | Không | Có (`product_id`) |
| Cột riêng | `num_of_item` (đơn có mấy món, 1-4) | `distribution_center_id` |

Ví dụ: khách đặt 1 đơn gồm 1 áo + 1 quần -> `fact_orders` có **1 dòng**, `fact_order_items` có **2 dòng** cùng `order_id`.

Đã kiểm tra khi làm ETL: số món đếm trong `order_items` khớp 100% với `num_of_item`, và `status` của từng món luôn giống `status` của đơn.

**Dùng bảng nào cho chỉ số nào:**
- **Doanh thu, Lợi nhuận** -> `fact_order_items` (chỉ bảng này có giá và nối được với sản phẩm).
- **Tỷ lệ hủy đơn** -> `fact_orders` (đề hỏi theo **đơn**; nếu đếm trên `order_items`, đơn 4 món bị hủy sẽ bị tính thành 4 lần).

### 5.2. Sơ đồ model (Star Schema)

```
                      dim_products
                           | 1
                           |
                           * 
 dim_users 1 ---- * fact_order_items * ---- 1 dim_distribution_centers
     1 |                   * 
       |                   |
       *                   | 1
  fact_orders * ------ 1 dim_date
```

- Mỗi bảng fact cùng các dim của nó là một star schema. Hai fact dùng chung `dim_users` và `dim_date` nên lọc đồng bộ được.
- Mọi quan hệ là **One-to-many** (dim là phía 1, fact là phía nhiều), chiều lọc **Single**.

| Dim (1) | Fact (nhiều) | Cột nối |
|---|---|---|
| `dim_products` | `fact_order_items` | `product_id` |
| `dim_users` | `fact_order_items` | `user_id` |
| `dim_distribution_centers` | `fact_order_items` | `distribution_center_id` |
| `dim_users` | `fact_orders` | `user_id` |
| `dim_date` | `fact_order_items` | `Date` -> `order_date` |
| `dim_date` | `fact_orders` | `Date` -> `order_date` |

### 5.3. Những quan hệ cố ý KHÔNG tạo

| Quan hệ | Lý do không tạo |
|---|---|
| `fact_orders` <-> `fact_order_items` (qua `order_id`) | Fact nối fact tạo 2 lối đi từ `dim_users` tới `fact_orders` -> Power BI phải tắt 1 đường, bộ lọc khách hàng không còn tác động lên Tỷ lệ hủy |
| `dim_products` <-> `dim_distribution_centers` | Fact đã có `distribution_center_id`; nối thêm tạo 2 lối đi (ambiguous) và biến model thành snowflake |
| `events` | Không import: dữ liệu click web (khác grain), 46% dòng không có `user_id`, 2,4 triệu dòng. Dành cho phần EDA |

### 5.4. Bảng `dim_date`

Tạo bằng DAX trong Power BI (không lấy từ MySQL), đánh dấu **Mark as date table**. Cần cho các hàm Time Intelligence (MoM, YoY).
Tắt **Auto date/time** để Power BI không tự sinh bảng ngày ẩn cho từng cột ngày.

---

## 6. Advanced EDA

Notebook [notebooks/02_eda.ipynb](notebooks/02_eda.ipynb), cấu trúc bám theo notebook mẫu của khóa học. Đọc dữ liệu đã sạch từ MySQL (1 dòng = 1 món hàng, join 6 bảng), phần funnel đọc bảng `events` đã gom bằng SQL.

| Phần | Nội dung | Biểu đồ |
|---|---|---|
| Chất lượng | Null, trùng, lỗi logic thời gian | - |
| Xu hướng & phân phối | `describe`, skew, histogram, doanh thu theo tháng/năm, boxplot | `eda_01`, `eda_02`, `eda_03` |
| Outlier | IQR, ảnh hưởng tới doanh thu, lý do giữ lại | - |
| Đa biến & tương quan | Heatmap món hàng / khách hàng, giá và thời gian giao vs hủy/trả, danh mục doanh thu vs biên lợi nhuận, mua lại | `eda_04`, `eda_05` |
| Insight phụ | Funnel xem -> giỏ -> mua từ bảng `events` | `eda_06` |

Giải thích chi tiết và số liệu: [docs/eda_explanation.md](docs/eda_explanation.md).

---

## 7. Thư viện code trong `src/`

### `src/utils/` - hàm tiện ích

| File | Hàm | Công dụng |
|---|---|---|
| `config.py` | `DB_CONFIG`, `SAKILA_CONFIG`, `INTRO_DE`, `LOOKER_ECOMMERCE` | Thông tin kết nối MySQL |
| `db.py` | `make_engine`, `test_connection`, `load_main_dataset`, `load_main_dataset_chunked` | Kết nối MySQL, đọc dữ liệu (kể cả theo chunk) |
| `cleaning.py` | `optimize_dtypes`, `quality_report`, `check_duplicates`, `check_data_issues`, `add_datetime_features` (+ bản `_chunked`) | Giảm RAM, báo cáo chất lượng dữ liệu, tạo cột ngày/tháng/năm |
| `outlier.py` | `detect_outliers`, `outlier_summary`, `plot_outlier`, `cap_outliers` (+ bản `_chunked`) | Phát hiện và xử lý ngoại lai |
| `stats.py` | `describe_all` | Thống kê mô tả |
| `visual.py` | `plot_histogram`, `plot_bar`, `plot_countbar`, `plot_boxplot`, `plot_line`, `plot_heatmap_corr` | Vẽ biểu đồ nhanh |

### `src/analysis/` - EDA theo class

| File | Class chính |
|---|---|
| `basic_data_inspection.py` | `DataInspector` + `DataTypesInspectionStrategy`, `SummaryStatisticsInspectionStrategy` |
| `univariate_analysis.py` | `UnivariateAnalyzer` + `NumericalUnivariateAnalysis`, `CategoricalUnivariateAnalysis` |
| `bivariate_analysis.py` | `BivariateAnalyzer` + `NumericalVsNumericalAnalysis`, `CategoricalVsNumericalAnalysis` |
| `multivariate_analysis.py` | `SimpleMultivariateAnalysis` |
| `missing_values_analysis.py` | `SimpleMissingValuesAnalysis` |

### `src/etl/` - xử lý dữ liệu theo class

| File | Class chính |
|---|---|
| `ingest_data.py` | `DataIngestorFactory`, `ZipDataIngestor` |
| `handle_missing_values.py` | `MissingValueHandler` + `DropMissingValuesStrategy`, `FillMissingValuesStrategy` |
| `outlier_detection.py` | `OutlierDetector` + `ZScoreOutlierDetection`, `IQROutlierDetection` |
| `feature_engineering.py` | `FeatureEngineer` + `LogTransformation`, `StandardScaling`, `MinMaxScaling`, `OneHotEncoding` |
| `data_splitter.py` | `DataSplitter` + `SimpleTrainTestSplitStrategy` |

Ví dụ:

```python
from utils.cleaning import optimize_dtypes, quality_report
from analysis.univariate_analysis import UnivariateAnalyzer, NumericalUnivariateAnalysis

df = optimize_dtypes(pd.read_csv('data/raw/orders.csv'))
UnivariateAnalyzer(NumericalUnivariateAnalysis()).execute_analysis(df, 'num_of_item')
```

---

## 8. Luồng dữ liệu

```
data/raw  ->  data/interim  ->  data/processed  ->  sql/marts  ->  bi/dashboards  ->  reports
 (gốc)       (đang xử lý)      (bản sạch)        (fact/dim)      (dashboard)       (insight)
```

- **interim**: file trung gian, xoá đi tạo lại được.
- **processed**: bản chốt; dashboard chỉ đọc từ đây hoặc từ bảng `fact_` / `dim_`.

---

## 9. Quy ước

- Notebook đánh số theo thứ tự chạy: `01_`, `02_`, ...
- Tên file dữ liệu: `ten_bang_YYYYMMDD.csv` hoặc `.parquet`.
- Code: tên biến, hàm, cột viết tiếng Anh `snake_case`; báo cáo viết tiếng Việt.
- SQL: từ khoá viết HOA, tiền tố `stg_`, `fact_`, `dim_`, không dùng `SELECT *` ở query cuối.
- Insight: **Phát hiện -> Bằng chứng (số liệu) -> Đề xuất hành động**.
- Chi tiết xem `.claude/rules/`.
