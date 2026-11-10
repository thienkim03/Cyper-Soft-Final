# DAX từ A đến Z (áp dụng cho project)

DAX (Data Analysis Expressions) là ngôn ngữ công thức của Power BI, dùng để tạo **measure** (chỉ số tính toán), **calculated column** (cột tính thêm) và **calculated table** (bảng tính thêm).

Ví dụ trong file này dùng đúng tên bảng/cột của model project:
- `fact_order_items`: order_item_id, order_id, user_id, product_id, distribution_center_id, status, order_date, created_at, shipped_at, delivered_at, returned_at, sale_price, cost, gross_profit
- `fact_orders`: order_id, user_id, status, order_date, num_of_item
- `dim_date`: Date, year, quarter, month, month_name, year_month
- `dim_products`, `dim_users`, `dim_distribution_centers`

Quy ước: tên hàm DAX viết thường (DAX không phân biệt hoa thường), tên measure viết rõ nghĩa dạng `Total Revenue`, `Revenue YoY %` (theo `.claude/rules/bi.md`).

---

## Mục lục

1. [Ba loại công thức DAX](#1-ba-loại-công-thức-dax)
2. [Viết DAX ở đâu, tạo bảng `_Measures`](#2-viết-dax-ở-đâu-tạo-bảng-_measures)
3. [Cú pháp cơ bản](#3-cú-pháp-cơ-bản)
4. [Context: khái niệm quan trọng nhất](#4-context-khái-niệm-quan-trọng-nhất)
5. [Hàm tổng hợp](#5-hàm-tổng-hợp)
6. [Iterator: hàm có đuôi X](#6-iterator-hàm-có-đuôi-x)
7. [CALCULATE: thay đổi bộ lọc](#7-calculate-thay-đổi-bộ-lọc)
8. [Hàm điều khiển bộ lọc: ALL, REMOVEFILTERS, FILTER](#8-hàm-điều-khiển-bộ-lọc)
9. [Biến VAR / RETURN](#9-biến-var--return)
10. [Điều kiện: IF, SWITCH, ISBLANK, SELECTEDVALUE](#10-điều-kiện)
11. [Time Intelligence: MoM, YoY, YTD](#11-time-intelligence)
12. [Xếp hạng và Top N](#12-xếp-hạng-và-top-n)
13. [Measure dạng chữ (tiêu đề động)](#13-measure-dạng-chữ)
14. [Định dạng và conditional formatting](#14-định-dạng-và-conditional-formatting)
15. [Kiểm tra DAX: DAX query view](#15-kiểm-tra-dax)
16. [Lỗi hay gặp](#16-lỗi-hay-gặp)
17. [Bộ measure đầy đủ cho project](#17-bộ-measure-đầy-đủ-cho-project)

---

## 1. Ba loại công thức DAX

| Loại | Tính khi nào | Lưu ở đâu | Dùng khi | Ví dụ |
|---|---|---|---|---|
| **Measure** | Lúc hiển thị, theo bộ lọc đang chọn | Không lưu, tính lại mỗi lần | Mọi con số tổng hợp: doanh thu, tỷ lệ, so sánh | `Total Revenue` |
| **Calculated column** | Lúc refresh dữ liệu, từng dòng | Lưu trong bảng (tốn RAM) | Cần cột mới để **lọc, chia nhóm, làm trục** | `price_group` = rẻ/đắt |
| **Calculated table** | Lúc refresh | Lưu như 1 bảng | Bảng phụ: bảng ngày, bảng tham số | `dim_date` |

**Quy tắc chọn:** con số đặt trên Card / giá trị của chart -> **measure**. Thứ cần kéo vào trục hoặc slicer -> **column**.

Lỗi người mới hay mắc: tạo calculated column `revenue = sale_price` rồi kéo vào card -> Power BI tự Sum, nhìn thì đúng, nhưng các phép chia (tỷ lệ, %) sẽ sai vì cộng các tỷ lệ của từng dòng. Tỷ lệ luôn phải làm bằng measure.

---

## 2. Viết DAX ở đâu, tạo bảng `_Measures`

**Tạo bảng chứa measure** (để gom measure vào 1 chỗ, không rải rác trong các bảng fact):
1. **Home** -> **Enter data** -> đặt tên bảng `_Measures` -> **Load**.
2. Chuột phải `_Measures` -> **New measure**, viết measure đầu tiên.
3. Xóa cột `Column1` mặc định. Bảng chỉ còn measure thì Power BI tự đưa nó lên đầu khung Data với biểu tượng máy tính.

**Viết measure:** chọn bảng `_Measures` -> **Home** hoặc **Modeling** -> **New measure** -> gõ công thức vào thanh công thức -> Enter.

**Calculated column:** chọn bảng cần thêm cột -> **Modeling** -> **New column**.

**Calculated table:** **Modeling** -> **New table**.

**Nhóm measure theo thư mục:** chọn measure -> khung Properties (trong Model view) -> **Display folder**, ví dụ `1. Revenue`, `2. Orders`, `3. Time`.

---

## 3. Cú pháp cơ bản

```dax
Tên Measure = biểu thức
```

| Cách viết | Ý nghĩa |
|---|---|
| `fact_order_items[sale_price]` | Cột: `tên_bảng[tên_cột]` |
| `[Total Revenue]` | Measure: chỉ `[tên]`, không ghi tên bảng |
| `'Tên bảng có dấu cách'[cột]` | Tên bảng có dấu cách thì bọc trong nháy đơn |
| `"Cancelled"` | Chuỗi chữ dùng nháy kép |
| `{"Cancelled", "Returned"}` | Danh sách giá trị |
| `&&`, `\|\|`, `not` | Và, hoặc, phủ định |
| `&` | Nối chuỗi |
| `-- ghi chú` hoặc `// ghi chú` | Comment |

**Mẹo:** Shift + Enter để xuống dòng trong thanh công thức. Viết mỗi tham số một dòng cho dễ đọc.

**Quy ước tham chiếu:** cột thì luôn ghi kèm tên bảng, measure thì không. Nhìn vào là biết đâu là cột, đâu là measure.

---

## 4. Context: khái niệm quan trọng nhất

Hiểu context thì hiểu DAX. Có 2 loại:

### Filter context (bộ lọc)
Là **tập bộ lọc đang áp lên phép tính**, đến từ: slicer, trục chart, hàng/cột của bảng, filter pane, và `calculate`.

Ví dụ chart cột "Total Revenue theo năm": cột năm 2023 được tính với filter context `dim_date[year] = 2023`. Cùng 1 measure `Total Revenue` nhưng mỗi cột ra số khác nhau, vì filter context khác nhau.

Bộ lọc **chảy theo quan hệ** từ dim sang fact: lọc `dim_date[year] = 2023` -> chỉ giữ các dòng `fact_order_items` có `order_date` thuộc 2023. Đây là lý do model cần đúng star schema: quan hệ sai thì bộ lọc chảy sai.

### Row context (ngữ cảnh dòng)
Là **"đang ở dòng nào"**, xuất hiện trong calculated column và trong iterator (`sumx`, `averagex`...). Trong row context, `fact_order_items[sale_price]` nghĩa là giá của **dòng hiện tại**.

```dax
-- Calculated column: tính trên từng dòng
margin_pct = divide(fact_order_items[gross_profit], fact_order_items[sale_price])
```

**Row context không tự lọc dữ liệu.** Muốn biến "dòng hiện tại" thành bộ lọc thì phải bọc trong `calculate` (gọi là context transition). Khi gọi 1 measure bên trong row context, Power BI tự bọc `calculate`.

---

## 5. Hàm tổng hợp

| Hàm | Làm gì | Ví dụ |
|---|---|---|
| `sum(cột)` | Tổng | `sum(fact_order_items[sale_price])` |
| `average(cột)` | Trung bình | `average(fact_order_items[sale_price])` |
| `min`, `max` | Nhỏ nhất, lớn nhất | `max(fact_order_items[order_date])` |
| `count(cột)` | Đếm ô không trống | `count(fact_order_items[shipped_at])` |
| `countrows(bảng)` | Đếm số dòng | `countrows(fact_orders)` |
| `distinctcount(cột)` | Đếm giá trị khác nhau | `distinctcount(fact_order_items[user_id])` |
| `divide(a, b)` | Chia an toàn, mẫu = 0 thì trả trống | `divide([Total Profit], [Total Revenue])` |

```dax
Total Orders = countrows(fact_orders)

Total Customers = distinctcount(fact_orders[user_id])

Total Items Sold = countrows(fact_order_items)
```

**Luôn dùng `divide()` thay cho `/`.** Với `/`, mẫu bằng 0 sẽ ra lỗi hoặc vô cực; `divide()` trả về trống (hoặc giá trị bạn đặt ở tham số thứ 3).

---

## 6. Iterator: hàm có đuôi X

`sumx`, `averagex`, `countx`, `maxx`, `minx`, `rankx`... duyệt **từng dòng** của 1 bảng, tính biểu thức trên dòng đó (row context), rồi tổng hợp.

```dax
-- sum chỉ cộng được 1 cột có sẵn
-- sumx tính biểu thức trên từng dòng rồi cộng
Total Profit (sumx) =
sumx(
    fact_order_items,
    fact_order_items[sale_price] - fact_order_items[cost]
)
```

Model đã có sẵn cột `gross_profit` nên dùng `sum(fact_order_items[gross_profit])` là đủ. `sumx` dùng khi cần nhân/trừ nhiều cột mà bảng không có sẵn cột kết quả.

```dax
-- Trung bình doanh thu theo từng khách (trung bình của tổng, không phải trung bình từng dòng)
Avg Revenue per Customer =
averagex(
    values(fact_order_items[user_id]),
    [Total Revenue]
)
```

`values(cột)` trả về danh sách giá trị khác nhau của cột trong context hiện tại. Ở đây `averagex` duyệt từng khách, gọi `[Total Revenue]` cho khách đó (context transition), rồi lấy trung bình.

---

## 7. CALCULATE: thay đổi bộ lọc

`calculate` là hàm quan trọng nhất DAX: **tính biểu thức với bộ lọc đã được sửa đổi**.

```dax
calculate( biểu_thức, bộ_lọc_1, bộ_lọc_2, ... )
```

- Bộ lọc trên **cùng cột** với bộ lọc đang có -> **thay thế** bộ lọc cũ.
- Bộ lọc trên **cột khác** -> **cộng thêm** (AND).

```dax
-- Doanh thu thực thu: bỏ đơn hủy và trả
Total Revenue =
calculate(
    sum(fact_order_items[sale_price]),
    not fact_order_items[status] in {"Cancelled", "Returned"}
)

-- Doanh thu bị mất do hủy / trả
Revenue Lost =
calculate(
    sum(fact_order_items[sale_price]),
    fact_order_items[status] in {"Cancelled", "Returned"}
)

-- Số đơn bị hủy
Cancelled Orders =
calculate(
    countrows(fact_orders),
    fact_orders[status] = "Cancelled"
)

-- Doanh thu của nữ (lọc qua bảng dim)
Revenue Women =
calculate(
    [Total Revenue],
    dim_users[gender] = "F"
)
```

**Ví dụ thay thế bộ lọc:** đặt `Revenue Women` vào chart có slicer gender = "M" -> vẫn ra doanh thu nữ, vì `calculate` đã ghi đè bộ lọc trên cột `gender`.

---

## 8. Hàm điều khiển bộ lọc

| Hàm | Làm gì |
|---|---|
| `all(bảng hoặc cột)` | Bỏ mọi bộ lọc trên bảng/cột đó |
| `removefilters(...)` | Giống `all` khi dùng trong `calculate`, tên rõ nghĩa hơn |
| `allexcept(bảng, cột giữ)` | Bỏ hết bộ lọc trên bảng, trừ các cột chỉ định |
| `allselected(...)` | Bỏ bộ lọc của visual, **giữ** bộ lọc từ slicer |
| `filter(bảng, điều kiện)` | Trả về bảng đã lọc theo điều kiện phức tạp |
| `keepfilters(...)` | Lọc thêm thay vì thay thế bộ lọc cũ |

**Tỷ trọng (% of total):**

```dax
-- % doanh thu của từng category so với tổng (vẫn theo slicer năm, quốc gia...)
Revenue Share % =
divide(
    [Total Revenue],
    calculate([Total Revenue], removefilters(dim_products[category]))
)

-- % so với tổng đang chọn trên slicer (bỏ bộ lọc của chính visual)
Revenue Share of Selected % =
divide(
    [Total Revenue],
    calculate([Total Revenue], allselected(dim_products))
)
```

**`filter` dùng khi điều kiện phức tạp** (so sánh 2 cột, so với measure):

```dax
-- Doanh thu từ món hàng giá trên 138,12 (ngưỡng outlier)
Revenue High Price =
calculate(
    [Total Revenue],
    filter(fact_order_items, fact_order_items[sale_price] > 138.12)
)
```

Điều kiện đơn giản trên 1 cột thì viết thẳng (`fact_orders[status] = "Cancelled"`), không cần `filter`: nhanh hơn.

---

## 9. Biến VAR / RETURN

Dùng biến để: code dễ đọc, không tính lại 1 biểu thức nhiều lần, dễ debug.

```dax
Revenue MoM % =
var cur = [Total Revenue]
var prev = [Revenue LM]
return
    divide(cur - prev, prev)
```

Biến chỉ tính **1 lần** tại chỗ khai báo, theo context lúc đó. Debug: tạm `return prev` để xem giá trị của biến `prev`.

---

## 10. Điều kiện

```dax
-- IF: 2 nhánh
Revenue Status = if([Revenue MoM %] >= 0, "Tăng", "Giảm")

-- SWITCH(TRUE()): nhiều nhánh, thay cho IF lồng nhau
Cancel Level =
switch(
    true(),
    [Cancel Rate %] >= 0.16, "Cao",
    [Cancel Rate %] >= 0.14, "Trung bình",
    "Thấp"
)

-- ISBLANK: kiểm tra trống
Revenue LM Safe = if(isblank([Revenue LM]), 0, [Revenue LM])
```

**`selectedvalue` và `hasonevalue`**: biết người dùng đang chọn gì trên slicer.

```dax
-- Tháng đang chọn (nếu chọn đúng 1 tháng), nếu không thì trả "Tất cả"
Selected Month = selectedvalue(dim_date[year_month], "Tất cả")

-- Chỉ tính MoM khi đang xem đúng 1 tháng, còn lại để trống
Revenue MoM % (1 month) =
if(
    hasonevalue(dim_date[year_month]),
    divide([Total Revenue] - [Revenue LM], [Revenue LM])
)
```

`if` không có nhánh "sai" thì trả trống: card sẽ không hiện số MoM khi đang xem nhiều tháng (vì so sánh lúc đó không có ý nghĩa).

---

## 11. Time Intelligence

### Điều kiện bắt buộc
1. Có bảng ngày riêng (`dim_date`) với **ngày liên tục**, không thiếu ngày nào.
2. **Mark as date table** trên `dim_date`.
3. Quan hệ `dim_date[Date]` -> cột ngày của fact.
4. Trên chart, trục thời gian phải lấy cột của **`dim_date`** (year, year_month...), không lấy `order_date` của fact.

Thiếu 1 trong 4 điều này thì MoM/YoY ra trống hoặc sai.

### Các hàm chính

| Hàm | Trả về | Dùng cho |
|---|---|---|
| `dateadd(dim_date[Date], -1, month)` | Khoảng ngày lùi 1 tháng | Tháng trước (LM) |
| `dateadd(dim_date[Date], -1, year)` | Lùi 1 năm | Cùng kỳ năm trước |
| `sameperiodlastyear(dim_date[Date])` | Cùng kỳ năm trước | LY (tương đương dateadd -1 year) |
| `datesytd(dim_date[Date])` | Từ đầu năm tới ngày đang xét | Lũy kế năm (YTD) |
| `datesmtd(dim_date[Date])` | Từ đầu tháng | Lũy kế tháng (MTD) |
| `totalytd(biểu_thức, dim_date[Date])` | Viết tắt của `calculate(..., datesytd(...))` | YTD |
| `datesinperiod(dim_date[Date], max(dim_date[Date]), -3, month)` | 3 tháng gần nhất | Trung bình trượt |

### Mẫu MoM / YoY / YTD

```dax
Revenue LM = calculate([Total Revenue], dateadd(dim_date[Date], -1, month))

Revenue MoM % = divide([Total Revenue] - [Revenue LM], [Revenue LM])

Revenue LY = calculate([Total Revenue], sameperiodlastyear(dim_date[Date]))

Revenue YoY % = divide([Total Revenue] - [Revenue LY], [Revenue LY])

Revenue YTD = totalytd([Total Revenue], dim_date[Date])

-- Trung bình 3 tháng gần nhất (làm mượt đường xu hướng)
Revenue 3M Avg =
var last_date = max(dim_date[Date])
return
    averagex(
        datesinperiod(dim_date[Date], last_date, -3, month),
        calculate([Total Revenue])
    )
```

### So sánh cho tỷ lệ: dùng hiệu số

```dax
Cancel Rate LM = calculate([Cancel Rate %], dateadd(dim_date[Date], -1, month))

Cancel Rate vs LM = [Cancel Rate %] - [Cancel Rate LM]
```

Tỷ lệ hủy 15% -> 16% là "+1 điểm %", không phải "+6,7%".

### Lưu ý với dữ liệu project
- Dữ liệu kết thúc ngày **21/01/2024**: tháng 01/2024 thiếu ngày -> MoM, YoY của tháng này giảm giả tạo. Không dùng tháng này để kết luận.
- Năm 2024 chỉ có tháng 1 -> không so YoY cả năm 2024 với 2023.

---

## 12. Xếp hạng và Top N

```dax
-- Xếp hạng category theo doanh thu (1 = cao nhất)
Category Rank =
rankx(
    all(dim_products[category]),
    [Total Revenue],
    ,
    desc,
    dense
)
```

- `all(dim_products[category])`: xếp hạng trên **tất cả** category, không chỉ category đang ở dòng hiện tại.
- Tham số thứ 3 để trống, `desc` = lớn xếp trước, `dense` = đồng hạng không nhảy số.

**Top N trên chart không cần DAX:** chọn visual -> Filters pane -> kéo `category` vào **Filters on this visual** -> Filter type: **Top N** -> Show items: Top 10 -> By value: `Total Revenue`.

**Doanh thu của Top 10 category (dùng cho card):**

```dax
Revenue Top 10 Category =
calculate(
    [Total Revenue],
    topn(10, all(dim_products[category]), [Total Revenue])
)
```

**Lợi nhuận Top 5 category - dùng được cho cả chart lẫn card** (đã dùng trong project, chạy thử trên model):

```dax
Profit Top 5 Category =
var top5 = topn(5, all(dim_products[category]), [Total Profit])
return
    calculate([Total Profit], keepfilters(top5))
```

- `topn(5, all(...), [Total Profit])`: lấy 5 category lời nhất, xét trên **toàn bộ** category (nhờ `all`).
- `keepfilters(top5)`: **giữ** bộ lọc đang có của visual rồi lọc thêm top 5. Không có `keepfilters` thì `calculate` sẽ **ghi đè** bộ lọc category của từng dòng chart -> mọi dòng đều hiện tổng top 5.
- Trên bar chart theo category: chỉ 5 category có số, còn lại trống nên tự ẩn.
- Trên card: ra tổng lợi nhuận của top 5 (dữ liệu project: 1.847.883$, khoảng 43,8% tổng lợi nhuận).
- Slicer năm/quốc gia vẫn tác động: top 5 tự tính lại theo bộ lọc.

**So sánh `keepfilters` và không có `keepfilters`** trên chart theo category:

| Dòng chart | `calculate([Total Profit], top5)` | `calculate([Total Profit], keepfilters(top5))` |
|---|---|---|
| Jeans (trong top 5) | 1.847.883 (tổng top 5 - sai) | 437.519 (đúng) |
| Socks (ngoài top 5) | 1.847.883 (sai) | trống (đúng) |

---

## 13. Measure dạng chữ

Dùng cho tiêu đề động, chú thích trên card.

```dax
-- Tiêu đề thay đổi theo tháng được chọn
Title Revenue =
"Doanh thu tháng " & selectedvalue(dim_date[year_month], "(tất cả)")

-- Nhãn so sánh có dấu +/- và chữ "vs LM"
Revenue MoM Label =
var v = [Revenue MoM %]
return
    if(isblank(v), blank(), format(v, "+0.0%;-0.0%") & " vs LM")
```

Gắn vào tiêu đề visual: Format -> General -> Title -> Text -> nút **fx** -> Field value -> chọn measure `Title Revenue`.

`format(giá_trị, "mã")`: `"0.0%"` phần trăm, `"#,0"` số nguyên có phân cách, `"$#,0.0,,\M"` dạng triệu (1,2M), `"mm/yyyy"` tháng/năm.

---

## 14. Định dạng và conditional formatting

**Định dạng measure:** chọn measure -> **Measure tools** -> Format:
- Tiền: Currency, 0 chữ số thập phân.
- Tỷ lệ: Percentage, 1 chữ số thập phân.
- MoM / YoY / vs LM: Custom `+0.0%;-0.0%;0.0%` (luôn có dấu).

**Tô màu theo giá trị (conditional formatting):**
1. Chọn visual -> Format -> phần màu (ví dụ Reference labels -> Value -> Color, hoặc Columns -> Color) -> nút **fx**.
2. Format style: **Rules** -> chọn measure (ví dụ `Revenue MoM %`).
3. Rule: `>= 0` -> xanh ngọc `#17A589`; `< 0` -> đỏ `#E74C3C`.
4. Với tỷ lệ hủy, tỷ lệ trả: **đảo ngược** (tăng là xấu -> đỏ).

**Measure trả về mã màu** (khi quy tắc phức tạp), chọn Format style: **Field value**:

```dax
Color MoM =
if([Revenue MoM %] >= 0, "#17A589", "#E74C3C")
```

---

## 15. Kiểm tra DAX

**DAX query view** (biểu tượng `DAX` ở thanh dọc bên trái Power BI): viết truy vấn để xem kết quả measure dạng bảng, không cần vẽ chart.

```dax
-- Doanh thu, lợi nhuận, MoM theo từng tháng năm 2023
evaluate
summarizecolumns(
    dim_date[year_month],
    filter(values(dim_date[year]), dim_date[year] = 2023),
    "Revenue", [Total Revenue],
    "Profit", [Total Profit],
    "MoM %", [Revenue MoM %]
)
order by dim_date[year_month]
```

```dax
-- Thử 1 measure mới trước khi tạo thật (define chỉ tồn tại trong truy vấn)
define
    measure _Measures[Test AOV] = divide([Total Revenue], [Net Orders])
evaluate
summarizecolumns(dim_date[year], "AOV", [Test AOV])
```

**Thứ tự tham số của `summarizecolumns`:** cột nhóm (group by) đặt **trước**, bảng lọc (`filter`, `treatas`) đặt **sau**, cuối cùng mới là các cặp `"tên", [measure]`. Đặt bảng lọc lên trước cột nhóm sẽ báo lỗi "A single value for column ... cannot be determined".

```dax
evaluate
summarizecolumns(
    dim_products[category],                               -- 1. cột nhóm
    treatas({"Jeans", "Socks"}, dim_products[category]),  -- 2. bảng lọc
    "Profit", [Total Profit]                              -- 3. measure
)
```

**Đối chiếu với nguồn:** số trên Power BI phải khớp với SQL / notebook. Ví dụ doanh thu thực thu toàn bộ phải là **8.127.337$** (tính trong `notebooks/02_eda.ipynb` và SQL) - lệch là có lỗi ở measure hoặc quan hệ.

**Debug từng bước:** đặt measure vào 1 visual **Table** cùng các cột chiều (năm, category) để thấy số ở từng dòng; tách measure phức tạp thành biến và `return` từng biến để xem.

---

## 16. Lỗi hay gặp

| Triệu chứng | Nguyên nhân hay gặp | Cách sửa |
|---|---|---|
| Mọi cột trên chart cùng 1 số | Quan hệ không có / bị tắt, hoặc trục lấy cột của bảng không nối với fact | Kiểm tra Model view, quan hệ phải là nét liền |
| MoM / YoY trống | Chưa Mark as date table, hoặc trục lấy `order_date` của fact | Mark as date table, trục dùng cột `dim_date` |
| Tháng xếp Apr, Aug, Dec... | `month_name` chưa Sort by column | Sort by column theo `month` |
| Tỷ lệ % sai, lớn hơn 100% | Dùng calculated column rồi Sum, hoặc chia trên từng dòng | Viết thành measure với `divide(tổng, tổng)` |
| Lỗi "A single value for column... cannot be determined" | Viết `fact_orders[status]` trần trong measure (measure không có row context) | Bọc trong hàm tổng hợp, hoặc dùng `selectedvalue` |
| Lỗi chia cho 0 / Infinity | Dùng `/` | Dùng `divide()` |
| Tổng (Total) của bảng không bằng tổng các dòng | Bình thường với measure tỷ lệ: Total tính lại trên toàn bộ, không cộng các dòng | Hiểu đúng hành vi; nếu cần tổng các dòng dùng `sumx(values(...), [measure])` |
| Slicer không lọc được visual | Edit interactions đang tắt, hoặc slicer lấy cột từ bảng không nối | Format -> Edit interactions; dùng cột từ bảng dim |

---

## 17. Bộ measure đầy đủ cho project

Tạo trong bảng `_Measures`. Gợi ý Display folder ở đầu mỗi nhóm.

### 1. Revenue & Profit

```dax
Total Revenue =
calculate(
    sum(fact_order_items[sale_price]),
    not fact_order_items[status] in {"Cancelled", "Returned"}
)

Total Profit =
calculate(
    sum(fact_order_items[gross_profit]),
    not fact_order_items[status] in {"Cancelled", "Returned"}
)

Profit Margin % = divide([Total Profit], [Total Revenue])

Revenue Lost =
calculate(
    sum(fact_order_items[sale_price]),
    fact_order_items[status] in {"Cancelled", "Returned"}
)
```

### 2. Orders & Customers

```dax
Total Orders = countrows(fact_orders)

Net Orders =
calculate(
    distinctcount(fact_order_items[order_id]),
    not fact_order_items[status] in {"Cancelled", "Returned"}
)

Avg Order Value = divide([Total Revenue], [Net Orders])

Total Customers = distinctcount(fact_orders[user_id])

Cancel Rate % =
divide(
    calculate(countrows(fact_orders), fact_orders[status] = "Cancelled"),
    [Total Orders]
)

Return Rate % =
divide(
    calculate(countrows(fact_orders), fact_orders[status] = "Returned"),
    [Total Orders]
)
```

- `Total Orders` đếm **mọi** đơn (kể cả hủy) vì là mẫu số của tỷ lệ hủy.
- `Net Orders` chỉ đếm đơn có doanh thu thực thu, là mẫu số của giá trị đơn trung bình (AOV).

### 3. Time Intelligence

```dax
Revenue LM = calculate([Total Revenue], dateadd(dim_date[Date], -1, month))
Revenue MoM % = divide([Total Revenue] - [Revenue LM], [Revenue LM])

Revenue LY = calculate([Total Revenue], sameperiodlastyear(dim_date[Date]))
Revenue YoY % = divide([Total Revenue] - [Revenue LY], [Revenue LY])

Revenue YTD = totalytd([Total Revenue], dim_date[Date])

Profit LM = calculate([Total Profit], dateadd(dim_date[Date], -1, month))
Profit MoM % = divide([Total Profit] - [Profit LM], [Profit LM])

Orders LM = calculate([Total Orders], dateadd(dim_date[Date], -1, month))
Orders MoM % = divide([Total Orders] - [Orders LM], [Orders LM])

Cancel Rate LM = calculate([Cancel Rate %], dateadd(dim_date[Date], -1, month))
Cancel Rate vs LM = [Cancel Rate %] - [Cancel Rate LM]

Margin LM = calculate([Profit Margin %], dateadd(dim_date[Date], -1, month))
Margin vs LM = [Profit Margin %] - [Margin LM]
```

### 4. Định dạng đề xuất

| Measure | Format |
|---|---|
| Total Revenue, Total Profit, Revenue Lost, Avg Order Value, *LM, *LY, *YTD | Currency `$`, 0 số thập phân |
| Total Orders, Net Orders, Total Customers | Whole number, có phân cách hàng nghìn |
| Profit Margin %, Cancel Rate %, Return Rate % | Percentage, 1 số thập phân |
| *MoM %, *YoY %, *vs LM | Custom `+0.0%;-0.0%;0.0%` |

### 5. Kiểm tra nhanh sau khi tạo

Đặt các measure vào 1 visual **Table** không lọc gì và đối chiếu:
- `Total Revenue` = 8.127.337$ (khớp notebook EDA).
- `Total Profit` = 4.217.377$.
- `Profit Margin %` = 51,9%.
- `Total Orders` = 125.226.
