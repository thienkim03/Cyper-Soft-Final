# Tips rút ra khi làm project

Ghi lại các lỗi đã gặp và cách làm đúng, theo thứ tự đã gặp trong project. Mỗi tip: **tình huống -> cách làm -> vì sao**.

---

## 1. Git

**Ignore file đã lỡ commit**
- `.gitignore` chỉ bỏ qua file **chưa được git theo dõi**. File đã commit rồi thì phải gỡ:
  ```powershell
  git rm -r --cached docs/cheatsheet/*.md   # gỡ khỏi git, file trên máy vẫn còn
  git add .gitignore
  git commit -m "Ignore cheatsheet"
  git push origin main
  ```
- Không có `--cached` thì file trên máy cũng bị xóa.
- File đã push vẫn còn trong lịch sử commit cũ. Nếu là mật khẩu thì phải đổi mật khẩu.

**Đường dẫn trong `.gitignore` tính từ gốc repo**
- `cheatsheet/*.md` không khớp `docs/cheatsheet/...` -> phải viết `docs/cheatsheet/*.md`.

**Đổi tên file dùng `git mv`** để git hiểu là đổi tên, không phải xóa + tạo mới.

**File chứa mật khẩu** (`src/utils/config.py`) phải nằm trong `.gitignore` ngay từ đầu.

---

## 2. Python và notebook

**Đọc kỹ thứ tự `return`**
- `extract()` trả về 7 bảng theo 1 thứ tự -> chỗ nhận cũng phải đúng thứ tự đó, lệch là gán nhầm bảng.

**Hàm nên nhận tham số, không dùng biến toàn cục**
- `def transform():` dùng thẳng `df_i_items` bên ngoài -> chạy được trong notebook nhưng dễ lỗi khi chạy lại. Nên `def transform(df_d_center, df_events, ...)` và `return`.

**Dòng quá dài thì xuống dòng bằng `\`**
```python
df_d_center, df_events, df_i_items, df_o_items, \
    df_orders, df_products, df_users = extract()
```

**`NameError` sau khi đã sửa file `.py`**
- Python chỉ import module 1 lần. Sửa `config.py` xong phải **Restart kernel** rồi chạy lại.
- Kiểm tra đúng file: notebook import từ `src/utils/config.py`, không phải `config.py` ở thư mục khác.

**Notebook nháp và notebook chính**
- Thử nghiệm trong notebook nháp (`00_scrapt.ipynb`), chắc chắn rồi mới đưa vào pipeline chính.
- Notebook phải chạy được từ đầu đến cuối (Restart & Run All).

---

## 3. Làm sạch dữ liệu (ETL)

**Flow kiểm tra:** kiểu dữ liệu -> ngày -> null -> trùng -> logic.

**Ngày tháng**
- Cột ngày có lúc có phần giây lẻ (`.316147`), lúc không -> `pd.to_datetime(col, format='ISO8601')` đọc được cả hai.
- MySQL `DATETIME` không lưu timezone -> có thể bỏ tz trước khi load.

**Null: hỏi "null này có ý nghĩa không" trước khi fill**
- `shipped_at` null vì đơn bị hủy -> **giữ null**, tạo cột cờ `is_shipped` nếu cần.
- `product_name` null là thiếu dữ liệu thật -> fill `"Unknown Product"`.
- Kiểm chứng bằng `pd.crosstab(df['status'], df['shipped_at'].isnull())`.

**Không fill chữ vào cột số**
- `df_events['user_id'].fillna('Unknown User')` làm cột số thành cột chữ, không nối được với bảng users. Giữ null hoặc dùng kiểu `Int64` (chữ I hoa, cho phép null).

**Cột khoảng thời gian (timedelta) phải đổi ra số trước khi load**
- `sold_at - created_at` là timedelta, MySQL lưu thành nano-giây, null thành số âm khổng lồ. Dùng `.dt.days`.

**Outlier: không phải lúc nào cũng xóa**
- Đo ảnh hưởng trước: trong project, 8,5% món outlier tạo ra 31,6% doanh thu -> là đơn thật, **giữ lại**, chỉ đánh dấu.

**Gộp giá trị viết khác nhau** (`Deutschland` = `Germany`, `Brasil` = `Brazil`) -> nên làm ở Transform để sạch từ gốc.

**Kiểm tra logic, không chỉ null/trùng**
- `shipped_at < created_at`: phát hiện 30,3% món hàng sai logic.

---

## 4. SQL

- Import Power BI bằng câu SQL để: join lấy cột cần (giá vốn), bỏ cột thừa/cá nhân (email), gom bảng lớn (events 2,4 triệu dòng -> 53 nghìn).
- Bảng rất lớn: `group by` trong SQL trước rồi mới đọc vào pandas.
- Trong pandas `read_sql`, ký tự `%` trong `like 'Espa%'` phải viết `%%` (vì `%` bị hiểu là tham số). Trong Power BI thì viết bình thường.

---

## 5. Power BI - mô hình dữ liệu

**Grain (mỗi dòng là gì) quyết định bảng fact**
- `orders`: 1 dòng = 1 đơn. `order_items`: 1 dòng = 1 món. Tỷ lệ hủy tính trên `orders`, doanh thu tính trên `order_items`.

**Star schema: fact nối dim, không nối fact-fact, không nối dim-dim**
- Có 2 đường đi tới cùng 1 bảng -> Power BI tự **tắt 1 đường** (đường nét đứt) -> bộ lọc không tác động -> số sai mà không báo lỗi.
- Kiểm tra trong Model view: đường nét đứt = inactive.

**Power BI tự tạo quan hệ (AutoDetected)**: luôn kiểm tra lại, nó hay nối thừa.

**Bảng ngày `dim_date`**
- Bắt buộc cho MoM/YoY. Tạo bằng `calendar()`, **Mark as date table**.
- Tắt **Auto date/time** (Options -> Current File -> Data Load) để bỏ các bảng ngày ẩn.
- Cột `month_name` phải **Sort by column** theo `month`, nếu không sẽ xếp Apr, Aug, Dec...

**DAX**
- Dùng `divide(a, b)` thay `a / b`: không lỗi khi mẫu số = 0.
- Gom measure vào 1 bảng `_Measures`, đặt tên rõ nghĩa.
- Quyết định nghiệp vụ phải nói rõ (ví dụ: doanh thu không tính Cancelled/Returned).

---

## 6. Công cụ: Claude Code + Power BI MCP

- MCP server Power BI: `npm install -g @microsoft/powerbi-modeling-mcp`, đăng ký bằng đường dẫn file `.exe` (dùng `npx ... @latest` thì mỗi lần mở phải lên mạng kiểm tra -> hay bị quá thời gian chờ).
- Đăng ký ở cấp user (`claude mcp add -s user ...`) để không bị lệch chữ hoa/thường ổ đĩa (`C:` vs `c:`).
- Sau khi thêm MCP phải **reload** cửa sổ VS Code thì phiên chat mới thấy tool.
- Kiểm tra: `claude mcp list` -> `Connected`.
- Kết nối MCP có thể đọc dữ liệu cũ -> kết nối lại khi thấy model chưa cập nhật.
- Nên tự viết DAX/model để hiểu khi Q&A; dùng MCP để **kiểm tra** model và con số.

---

## 7. Thói quen làm việc

- **Kiểm chứng trước khi sửa:** đo xem vấn đề lớn cỡ nào (bao nhiêu dòng, ảnh hưởng bao nhiêu %) rồi mới quyết định xử lý.
- **Mọi con số phải truy được nguồn** (notebook, SQL, dashboard).
- **Ghi lại quyết định và lý do** (README, file giải thích) -> lúc Q&A trả lời được "vì sao".
- **Backup trước khi để công cụ tự sửa** (file `.pbix`).
