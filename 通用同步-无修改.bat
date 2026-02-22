@echo off
chcp 65001 >nul
title 同步上游更新

echo.
echo ========================================
echo    同步上游更新工具
echo ========================================
echo.

cd /d "%~dp0"

REM ========== 配置区 ==========
REM 分支名称：main 或 master
set BRANCH=main

REM upstream 仓库名称（如果没配置 upstream，改为 origin）
set REMOTE=upstream
REM ===========================

echo [1/5] 检查本地状态...
git status --short
echo.

echo [2/5] 拉取上游更新...
git fetch %REMOTE%
if errorlevel 1 (
    echo.
    echo ❌ 拉取失败！请检查:
    echo    1. 网络连接
    echo    2. 是否配置了 %REMOTE% 仓库
    echo    配置命令: git remote add %REMOTE% [上游仓库URL]
    pause
    exit /b 1
)
echo ✓ 上游更新已拉取
echo.

echo [3/5] 合并上游更新到本地...
git merge %REMOTE%/%BRANCH% --no-edit
if errorlevel 1 (
    echo.
    echo ❌ 合并失败！可能存在冲突
    pause
    exit /b 1
)
echo ✓ 合并成功
echo.

echo [4/5] 推送到 GitHub...
git push origin %BRANCH%
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

echo ✅ 同步完成！
echo.

pause
