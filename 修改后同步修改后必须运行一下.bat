@echo off
chcp 65001 >nul
title VCPToolBox 修改后同步（保留本地修改）

echo.
echo ========================================
echo    VCPToolBox 修改后同步工具
echo    （自动保留你的本地修改）
echo ========================================
echo.

cd /d "%~dp0"

echo [1/7] 检查本地状态...
git status --short
echo.

echo [2/7] 暂存你的本地修改...
git stash push -m "本地修改备份 - %date% %time%"
if errorlevel 1 (
    echo.
    echo ❌ 暂存失败！但可能没有需要暂存的内容，继续...
) else (
    echo ✓ 本地修改已安全暂存
)
echo.

echo [3/7] 拉取上游更新...
git fetch upstream
if errorlevel 1 (
    echo.
    echo ❌ 拉取上游失败！请检查网络连接
    pause
    exit /b 1
)
echo ✓ 上游更新已拉取
echo.

echo [4/7] 合并上游更新到本地...
git merge upstream/main --no-edit
if errorlevel 1 (
    echo.
    echo ❌ 合并失败！可能存在冲突
    echo    恢复本地修改中...
    git stash pop
    pause
    exit /b 1
)
echo ✓ 合并成功
echo.

echo [5/7] 恢复你的本地修改...
git stash pop
if errorlevel 1 (
    echo.
    echo ⚠️ 恢复修改失败或没有暂存内容，请检查
)
echo ✓ 本地修改已恢复
echo.

echo [6/7] 推送到你的 GitHub fork...
echo.
echo ⚠️ 注意：如果本地有未提交的修改，需要先提交才能推送
echo.
set /p confirm="是否现在推送？(Y/N): "
if /i "%confirm%"=="Y" (
    git push origin main
    if errorlevel 1 (
        echo.
        echo ❌ 推送失败！
        pause
        exit /b 1
    )
    echo ✓ 推送成功
) else (
    echo 跳过推送，你可以稍后手动推送
)
echo.

echo [7/7] 查看更新日志...
echo.
echo ========================================
echo    最新 5 条提交记录
echo ========================================
git log --oneline -5
echo.

echo ========================================
echo    ✅ 同步完成！
echo ========================================
echo.
echo 📌 提示：你的本地修改已恢复
echo    如需提交修改，请运行:
echo    git add .
echo    git commit -m "你的提交信息"
echo    git push origin main
echo.

pause
