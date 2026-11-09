# Thiết kế dashboard Power BI

## 1. Flow làm một dashboard

```mermaid
flowchart LR
    A["1. Câu hỏi<br/>nghiệp vụ"] --> B["2. Phác thảo<br/>bố cục trên giấy"] --> C["3. Chọn màu<br/>(palette)"] --> D["4. Làm nền<br/>PowerPoint/Figma"] --> E["5. Theme JSON<br/>trong Power BI"] --> F["6. Đặt visual<br/>lên nền"] --> G["7. Slicer, sync,<br/>tooltip"] --> H["8. Kiểm tra<br/>số + UX"]
```

1. **Câu hỏi trước, chart sau.** Mỗi trang trả lời 1 câu hỏi (ví dụ trang 1: "Doanh thu đang tăng hay giảm?"). Đặt câu hỏi làm tiêu đề trang.
2. **Phác thảo trên giấy** (wireframe): chia khung KPI, chart chính, chart phụ, slicer. Làm bước này trước giúp không phải kéo thả lại nhiều lần.
3. **Chọn bảng màu** 1 lần, dùng cho cả nền và chart.
4. **Làm nền** bằng PowerPoint hoặc Figma (xem mục 2).
5. **Tạo theme** để mọi visual tự lấy đúng màu (xem mục 3).
6. **Đặt visual** vào đúng các ô trên nền, tắt nền của visual.
7. **Slicer và tương tác**: Sync slicers giữa các trang, Edit interactions.
8. **Kiểm tra**: số khớp với SQL/notebook, lọc thử mọi slicer, xem ở chế độ Reading view.

### Bố cục chuẩn (đọc theo chữ Z)

```
+-----------------------------------------------------------+
| Logo  Tiêu đề trang (câu hỏi)               [Slicer năm]   |
+-----------+-----------+-----------+-----------+-----------+
|   KPI 1   |   KPI 2   |   KPI 3   |   KPI 4   | [Slicer]  |
| Doanh thu | Lợi nhuận | Tỷ lệ hủy |  YoY %    | [Slicer]  |
+-----------+-----------+-----------+-----------+           |
|                                   |                       |
|   Chart chính (xu hướng theo      |   Chart phụ           |
|   thời gian - line/area)          |   (top N - bar)       |
|                                   |                       |
+-----------------------------------+-----------------------+
|   Chart chi tiết / bảng           |   Chart phụ           |
+-----------------------------------+-----------------------+
```

- Mắt người đọc từ trái sang phải, trên xuống dưới -> **KPI quan trọng nhất ở góc trên bên trái**.
- KPI luôn có **so sánh** (so với kỳ trước, so với mục tiêu), không chỉ một con số đứng một mình.
- Mỗi trang tối đa 6-8 visual, tối đa 5-6 màu.

---

## 2. Làm nền (background)

Cách mọi người hay làm: **vẽ nền bên ngoài -> xuất ảnh PNG -> đặt làm Canvas background**. Visual trong Power BI chỉ cần đặt lên các ô có sẵn.

### Bước làm bằng PowerPoint (dễ nhất)
1. PowerPoint -> Design -> Slide Size -> **Custom: 13,333 x 7,5 inch** (tỷ lệ 16:9, bằng canvas mặc định 1280x720 của Power BI).
2. Vẽ: thanh tiêu đề, các ô bo góc cho KPI và chart, có thể thêm bóng đổ nhẹ, logo, icon.
3. Chuột phải vào slide -> **Save as Picture** -> PNG.
4. Power BI: chọn trang (bấm vào chỗ trống) -> **Format page** -> **Canvas background** -> Image -> chọn file PNG -> **Image fit: Fit**, **Transparency: 0%**.
5. Với từng visual: Format -> General -> Effects -> **tắt Background** (hoặc transparency 100%) để visual "nằm" trên ô của nền.

### Làm bằng Canva
1. Canva -> **Create a design** -> **Custom size** -> **1920 x 1080 px** (cùng tỷ lệ 16:9 với canvas Power BI, ảnh nét hơn 1280x720).
2. Muốn có sẵn mẫu thì gõ "dashboard background" hoặc "dashboard" trong ô tìm mẫu, rồi sửa màu cho hợp.
3. Vẽ thanh tiêu đề và các ô bo góc (Elements -> Shapes -> hình chữ nhật bo góc), chỉnh độ bo ở **Corner rounding**.
4. Để trống phần bên trong các ô, không đặt chữ hay số liệu (chart sẽ nằm đè lên).
5. **Share** -> **Download** -> **PNG** -> tải về, rồi đặt làm Canvas background trong Power BI như các bước ở trên.
6. Lưu lại thiết kế trên Canva để sửa sau. Tài khoản miễn phí tải PNG được bình thường.

### Làm bằng Figma
- Tạo frame **1280 x 720** (hoặc 1920 x 1080 để ảnh nét hơn), vẽ tương tự, Export PNG 2x.

### Lưu ý
- **Canvas background** là phần trong khung trang; **Wallpaper** là phần ngoài khung. Thường để Wallpaper cùng màu nền.
- Nên lưu file PowerPoint/Figma gốc để sửa nền sau này. Ảnh nền để trong `bi/themes/`.
- Nền đơn giản: nền xám rất nhạt (#F3F4F6) + ô trắng bo góc là kiểu "chuẩn doanh nghiệp" an toàn nhất. Nền tối (dark) đẹp nhưng khó đọc khi chiếu máy chiếu.

---

## 3. Theme và đồng bộ màu

### Theme là gì
Theme là file JSON chứa màu mặc định cho chart (`dataColors`), màu chữ, font, nền visual... Đặt theme 1 lần thì mọi visual mới tạo ra đều đúng màu, không phải chỉnh tay từng cái.

### Cách đổi theme
1. **View** -> **Themes** -> chọn theme có sẵn, hoặc:
2. **Customize current theme**: đổi Name and colors (màu 1-8 là màu các series chart), Text (font, cỡ chữ), Visuals (nền, viền), Page (màu nền trang).
3. **Save current theme** -> lưu file JSON vào `bi/themes/` để dùng lại cho file khác.
4. **Browse for themes** -> nạp file JSON có sẵn (tự làm hoặc tải từ trang tạo theme).

### Làm sao để màu đồng bộ (sync màu)
- **Lấy màu từ nền.** Dùng chính các mã màu (hex) đã dùng khi vẽ nền làm `dataColors` trong theme.
- **Luôn chọn màu trong mục Theme colors** khi tô màu, không gõ mã hex tự do. Đổi theme thì mọi thứ đổi theo.
- **Một ý nghĩa = một màu xuyên suốt.** Ví dụ: doanh thu luôn xanh dương, hủy đơn luôn đỏ, Men/Women luôn 2 màu cố định ở mọi trang.
- **Format painter** (biểu tượng cây cọ ở tab Home): copy định dạng từ visual này sang visual khác.
- **Màu nhấn (accent)**: chỉ 1 màu nổi bật để chỉ chỗ quan trọng (ví dụ cột cao nhất), các cột khác để màu xám.

### Sync slicers (đồng bộ bộ lọc giữa các trang)
- **View** -> **Sync slicers** -> tick các trang mà slicer cần áp dụng. Chọn năm ở trang 1 thì trang 2, 3 cũng lọc theo năm đó.
- **Format** -> **Edit interactions**: chọn visual nào được lọc khi click vào visual khác.

---

## 4. Web tham khảo

**Mẫu dashboard đẹp:**
- **Novypro** (novypro.com): cộng đồng chia sẻ dashboard Power BI, xem được nhiều bố cục thật.
- **Dribbble** (dribbble.com), **Behance** (behance.net): gõ "dashboard" hoặc "analytics dashboard" để lấy ý tưởng bố cục và màu.
- **Power BI Data Stories Gallery**: thư viện dashboard của cộng đồng Microsoft (tìm trên Google).

**Chọn bảng màu:**
- **Coolors** (coolors.co): bấm Space để ra bảng màu ngẫu nhiên, khóa màu thích.
- **Adobe Color** (color.adobe.com): tạo bảng màu từ 1 màu gốc hoặc từ ảnh.
- **ColorBrewer** (colorbrewer2.org): bảng màu cho dữ liệu (tuần tự, phân kỳ), có lọc màu thân thiện với người mù màu.

**Tạo theme JSON:**
- Trang **Theme generator của PowerBI.tips** (tìm "powerbi tips theme generator"): nhập màu, xuất file JSON để nạp vào Power BI.

**Icon cho nền và KPI:**
- **Flaticon** (flaticon.com), **Icons8** (icons8.com): tải PNG/SVG, chọn cùng 1 bộ icon cho đồng bộ.

---

## 5. Checklist trước khi nộp

- [ ] Mỗi trang có tiêu đề là 1 câu hỏi nghiệp vụ.
- [ ] KPI ở góc trên bên trái, có so sánh kỳ trước (MoM/YoY).
- [ ] Mọi màu lấy từ theme, tối đa 5-6 màu mỗi trang.
- [ ] Slicer năm/tháng đã sync giữa các trang.
- [ ] Trục, nhãn, đơn vị ($, %) rõ ràng; số lớn rút gọn (1,2M thay vì 1.234.567).
- [ ] Đã thử lọc mọi slicer, không visual nào bị trống hoặc sai.
- [ ] Số trên dashboard khớp với notebook/SQL.
