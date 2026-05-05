# 沐阳调试助手 APK 在线仓库

这个目录给“沐阳调试助手”读取在线 APK 列表使用。

推荐结构：

- `apk-repo/apks.tsv`：在线 APK 清单，提交到仓库。
- GitHub Releases：存放真正的 APK 文件，不建议把大 APK 直接提交进仓库。

## apks.tsv 格式

每一行一个 APK，字段用 Tab 分隔：

```text
文件名	下载地址	sha256	大小	包名	显示名
```

示例：

```text
MT2.26.4.apk	https://github.com/muyang520/muyangcoursedescription/releases/download/apks-v1/MT2.26.4.apk	d012e52c7f45559e3afe71225cb6b909c808bbc2a768675cd5414d08180580b0	30219687	bin.mt.plus	MT管理器
```

## 模块配置

把下面这个 raw 地址填进模块的 `config/remote-repo.conf`：

```sh
REMOTE_APK_MANIFEST_URL="https://raw.githubusercontent.com/muyang520/muyangcoursedescription/main/apk-repo/apks.tsv"
```

刷入模块并重启后，打开“沐阳调试助手”，点击刷新即可读取在线 APK。

## 更新流程

一键方式：

1. 把 APK 放进 `apk-repo/inbox/`。
2. 在仓库根目录执行：

```bat
publish_apk_repo.bat
```

脚本会自动上传 Release、更新 `apks.tsv`、提交并推送。

如果本机没装 GitHub CLI，可以先只生成清单：

```bat
publish_apk_repo.bat -SkipUpload -SkipCommit
```

后续新增 APK，只需要更新 Release asset 和 `apks.tsv`，不需要重新打模块。
