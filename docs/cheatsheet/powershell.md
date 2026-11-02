# PowerShell

> Tên thư mục dự án có `[ ]` -> dùng `-LiteralPath` hoặc backtick: `` `[ `` `` `] ``.

## Điều hướng

```powershell
Set-Location -LiteralPath "C:\cache\CyperSoft\[CyperSoft] Final Project"   # về gốc dự án
cd ..                       # lên 1 cấp
cd notebooks                # vào thư mục con
pwd                         # đang ở đâu
ls                          # liệt kê file
ls -Force                   # liệt kê cả file ẩn (.git, .venv)
ls -Recurse -Filter *.py    # tìm file .py trong mọi thư mục con
code .                      # mở thư mục hiện tại bằng VS Code
explorer .                  # mở thư mục bằng File Explorer
cls                         # xoá màn hình
```

## Thao tác file / thư mục

```powershell
mkdir data\interim\tmp                  # tạo thư mục
ni notes.md                             # tạo file rỗng (New-Item)
cp a.csv b.csv                          # copy
mv a.csv data\raw\                      # di chuyển / đổi tên
rm file.txt                             # xoá file
rm -Recurse -Force folder               # xoá thư mục (KHÔNG vào thùng rác)
Rename-Item old.py new.py               # đổi tên
```

## Xem nhanh dữ liệu

```powershell
Get-Content data\raw\orders.csv -TotalCount 5      # 5 dòng đầu
Get-Content log\ETL_Project_20261029.log -Tail 20   # 20 dòng cuối
Get-Content log\*.log -Wait -Tail 10                # theo dõi log trực tiếp
(Get-Content data\raw\orders.csv | Measure-Object -Line).Lines   # đếm dòng (file nhỏ)
ls data\raw | Select Name, @{n='MB';e={[math]::Round($_.Length/1MB,1)}}   # dung lượng file
Select-String -Path src\**\*.py -Pattern "def "     # tìm chuỗi trong file (như grep)
```

## Tiện ích

```powershell
Get-History                 # các lệnh đã gõ
Ctrl + C                    # dừng lệnh đang chạy
Tab                         # tự hoàn thành tên file
Mũi tên lên / xuống         # lệnh trước / sau
$env:PATH                   # xem biến môi trường
```

> Khi dán nhiều lệnh, KHÔNG dán dấu `>>` ở đầu dòng - đó là ký hiệu chờ của terminal.
