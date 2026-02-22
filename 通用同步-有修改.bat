@echo off
chcp 65001 >nul
title 同步上游更新（保留本地修改）

echo.
echo ========================================
echo    同步上游更新工具
echo    （自动保留本地修改）
echo ========================================
echo.

cd /d "%~dp0"

REM ========== 配置区 ==========
REM 分支名称：main 或 master
set BRANCH=main

REM upstream 仓库名称（如果没配置 upstream，改为 origin）
set REMOTE=upstream
REM ===========================

echo [1/7] 检查本地状态...
git status --short
echo.

echo [2/7] 暂存本地修改...
git stash push -m "本地修改备份 - %date% %time%"
if errorlevel 1 (
    echo.
    echo ⚠️ 暂存失败或无内容，继续...
) else (
    echo ✓ 本地修改已安全暂存
)
echo.

echo [3/7] 拉取上游更新...
git fetch %REMOTE%
if errorlevel 1 (
    echo.
    echo ❌ 拉取失败！请检查:
    echo    1. 网络连接
    echo    2. 是否配置了 %REMOTE% 仓库
    pause
    exit /b 1
)
echo ✓ 上游更新已拉取
echo.

echo [4/7] 合并上游更新到本地...
git merge %REMOTE%/%BRANCH% --no-edit
if errorlevel 1 (
    echo.
    echo ❌ 合并失败！恢复本地修改中...
    git stash pop
    pause
    exit /b 1
)
echo ✓ 合并成功
echo.

echo [5/7] 恢复本地修改...
git stash pop
echo ✓ 本地修改已恢复
echo.

echo [6/7] 推送到 GitHub...
set /p confirm="是否现在推送？(Y/N): "
if /i "%confirm%"=="Y" (
    git push origin %BRANCH%
    echo ✓ 推送完成
) else (
    echo 跳过推送
)
echo.

echo [7/7] 查看更新日志...
echo.
git log --oneline -5
echo.

echo ✅ 同步完成！
echo.

pause
