# Python & uv

## Môi trường

```powershell
uv sync                                   # cài đúng thư viện theo uv.lock vào .venv
.venv\Scripts\activate                    # kích hoạt .venv
deactivate                                # thoát .venv
uv run python --version                   # chạy lệnh trong .venv, không cần activate
```

> Lỗi "running scripts is disabled": chạy 1 lần
> `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`

## Thư viện

```powershell
uv add pandas                             # thêm thư viện (ghi vào pyproject.toml)
uv add --dev ipykernel                    # thư viện chỉ dùng khi phát triển
uv remove seaborn                         # gỡ
uv pip list                               # danh sách đã cài
uv lock --upgrade                         # nâng cấp các thư viện
```

## Chạy code

```powershell
uv run python src\utils\stats.py          # chạy 1 file
uv run python -c "import pandas; print(pandas.__version__)"
uv run jupyter lab                        # mở Jupyter Lab (cần: uv add --dev jupyterlab)
uv run jupyter nbconvert --to notebook --execute notebooks\02_etl_pipeline.ipynb --inplace
                                          # chạy notebook từ đầu đến cuối
```

## Dọn dẹp

```powershell
Get-ChildItem -Recurse -Directory __pycache__ | Remove-Item -Recurse -Force
Get-ChildItem -Recurse -Directory .ipynb_checkpoints | Remove-Item -Recurse -Force
```
