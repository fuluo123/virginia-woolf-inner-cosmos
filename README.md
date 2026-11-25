# 伍尔夫 · 意识星河 — 开发包

单页网站。**零依赖、零 CDN、零外部图片、零网络请求**（连环境音乐都是 WebAudio 实时合成的，仓库里没有一个音频文件）。

```
codex-kit/
├── AGENTS.md                     ← 给 Codex 的作业单：环境、构建、坑、验收标准（先读这个）
├── README.md                     ← 本文件
├── index.html                    ← 构建产物：桌面 / 宽屏版（≈3.3 MB，双击即开）
├── index-mobile.html             ← 构建产物：手机版（≈3.4 MB）
├── dist/site/                    ← 要上传到静态托管的三件套（路由器 + d.html + m.html）
├── src/                          ← 源码（唯一真源）
│   ├── app.js                    全部逻辑 ≈3560 行
│   ├── style.css                 视觉系统 + 断点
│   ├── body.html                 页面骨架
│   ├── router.html               按 UA 分派
│   ├── build.sh / build-mobile.sh  把 CSS/JS 内联成单文件
│   ├── mobile-*.css / mobile-fix.js  手机版补丁
│   ├── fonts-inline.css + fonts/  思源宋体子集（base64 内联用）
│   └── sound-new.js, make-fonts.py 素材与工具
├── qa/                           ← Playwright 自检脚本（见 AGENTS.md §4）
└── docs/                         ← 设计说明、历次改动、状态与待办
```

## 三分钟上手

```bash
bash build-all.sh           # 语法检查 + 构建两个单文件 + 组装 dist/site + 打包
open index.html             # 或直接用浏览器打开
```

改代码的路子：改 `src/app.js` 或 `src/style.css` → `bash build-all.sh` → 刷新 `index.html`。
单文件是拼出来的，**不要在 index.html 里直接改**，下次构建会被覆盖。

## 三层空间

| 层 | 内容 | 交互 |
|---|---|---|
| **RIVER** 星河 | 1000–2500 颗粒子沿一条贝塞尔曲线流动（远/中/近视差 + 靠近星辰的引力偏折），五部作品是河上的五颗星 | 鼠标视差；悬停星体，星核脉冲、名称聚拢 |
| **CONSTELLATION** 星系 | 点击星辰后星河内坍缩，三条椭圆轨道展开（周期 17.3s / 26.5s / 39.0s，互不整除） | 轨道缓慢自转；`‹ ›` 或 `←` `→` 换作品；点行星读原文 |
| **STREAM** 意识流 | 原文逐字浮现（28–55ms 不等速，逗号 180ms、句号 420ms） | 连点两颗行星长出联想曲线并合成一句新话；空闲 6 秒有英文独白飘过 |

## 当前状态

见 `docs/状态-2026-11-06.md`：已修完的、正在做一半的、下一步该干什么，都写在那里。

## 联系方式 / 交付

线上托管（Cloudflare Pages 项目 `woolf`）需要手动上传 `woolf-site.zip`。
仓库里不带任何凭证，也不应该带。
