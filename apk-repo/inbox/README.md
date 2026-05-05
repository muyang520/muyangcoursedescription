# APK 投放目录

把要发布到在线仓库的 APK 放到这个目录，然后在仓库根目录执行：

```powershell
.\tools\publish_apk_repo.ps1
```

脚本会自动：

1. 读取这个目录里的 APK。
2. 计算 sha256 和文件大小。
3. 尝试用 Android SDK 的 `aapt.exe` 解析包名和应用名。
4. 上传 APK 到 GitHub Release。
5. 更新 `apk-repo/apks.tsv`。
6. 提交并推送到 GitHub。

APK 文件会被 `.gitignore` 忽略，不会直接提交进仓库。
