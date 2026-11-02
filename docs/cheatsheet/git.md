# Git

Repo: https://github.com/thienkim03/Cyper-Soft-Final

## Thiết lập (1 lần)

```bash
git config --global user.name "Ten Ban"
git config --global user.email "email@gmail.com"
git init                                  # tạo repo
git clone <url>                           # tải repo về
git remote add origin <url>               # gắn GitHub
git remote set-url origin <url>           # đổi link
git remote -v                             # xem link
```

## Hằng ngày

```bash
git status                                # file nào thay đổi
git add <file>                            # chọn 1 file
git add .                                 # chọn tất cả
git commit -m "noi dung"                  # lưu mốc
git push                                  # đẩy lên GitHub
git pull                                  # kéo code mới về
git push -u origin main                   # push lần đầu, gắn nhánh (-u chỉ cần 1 lần)
```

## Lịch sử

```bash
git log --oneline                         # mỗi commit 1 dòng
git log --oneline --graph --all           # dạng cây
git diff                                  # thay đổi chưa add
git diff --staged                         # đã add, chưa commit
git show <commit_id>                      # chi tiết 1 commit
```

## Nhánh

```bash
git branch                                # danh sách nhánh
git switch -c feature/eda                 # tạo + chuyển nhánh
git switch main                           # về main
git merge feature/eda                     # gộp nhánh
git branch -d feature/eda                 # xoá nhánh
git push -u origin feature/eda            # đẩy nhánh mới
```

## Hoàn tác

| Lệnh | Tác dụng | Mức nguy hiểm |
|---|---|---|
| `git restore --staged <file>` | Bỏ add, giữ thay đổi | An toàn |
| `git rm --cached <file>` | Ngừng theo dõi, file vẫn còn | An toàn |
| `git revert <id>` | Commit mới đảo ngược commit cũ | An toàn |
| `git commit --amend -m "msg"` | Sửa commit cuối | Chỉ khi CHƯA push |
| `git restore <file>` | Bỏ thay đổi chưa add | MẤT code |
| `git reset --hard <id>` | Quay về commit cũ | MẤT code |

## Cất tạm

```bash
git stash                                 # cất thay đổi dở
git stash list                            # xem các lần cất
git stash pop                             # lấy lại
```

## Quy trình mẫu

```bash
git pull
git switch -c feature/transform
# ... sửa code ...
git status                                # kiểm tra không dính CSV / config.py
git add notebooks/02_etl_pipeline.ipynb
git commit -m "Add transform for orders"
git push -u origin feature/transform      # rồi tạo Pull Request trên GitHub
```

## Lỗi hay gặp

| Lỗi | Cách sửa |
|---|---|
| `remote origin already exists` | `git remote set-url origin <url>` |
| `Repository not found` | Repo chưa tạo trên GitHub hoặc sai tên / sai tài khoản |
| `rejected ... fetch first` | `git pull` rồi push lại |
| `file exceeds 100 MB` | Thêm vào `.gitignore`, `git rm --cached <file>`, `git commit --amend` |
| `>> : The term '>>' is not recognized` | Bỏ dấu `>>` khi dán lệnh |
