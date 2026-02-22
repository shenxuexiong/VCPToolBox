@echo off
chcp 65001 >nul
title VCPToolBox 同步上游更新

echo.
echo ========================================
echo    VCPToolBox 同步上游更新工具
echo ========================================
echo.

cd /d "%~dp0"

echo [1/5] 检查本地状态...
git status --short
echo.

echo [2/5] 拉取上游更新...
git fetch upstream
if errorlevel 1 (
    echo.
    echo ❌ 拉取上游失败！请检查网络连接或 upstream 配置
    pause
    exit /b 1
)
echo ✓ 上游更新已拉取
echo.

echo [3/5] 合并上游更新到本地...
git merge upstream/main --no-edit
if errorlevel 1 (
    echo.
    echo ❌ 合并失败！可能存在冲突
    echo    请手动解决冲突后运行: git merge --continue
    pause
    exit /b 1
)
echo ✓ 合并成功
echo.

echo [4/5] 推送到你的 GitHub fork...
git push origin main
if errorlevel 1 (
    echo.
    echo ❌ 推送失败！请检查 GitHub 认证
    pause
    exit /b 1
)
echo ✓ 推送成功
echo.

echo [5/5] 查看更新日志...
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

pause
