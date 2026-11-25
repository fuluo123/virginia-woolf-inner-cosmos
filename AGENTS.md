# AGENTS.md — 给 Codex / 自动化 agent 的作业单

这是一个**已经做完的作品**：弗吉尼亚·伍尔夫的「意识星河」单页网站。
你的任务是**继续修 bug、按用户反馈微调**，不是重新设计它。

不要做的事：换框架、引入依赖 / CDN / 外部图片 / 任何网络请求、重写视觉系统、
把 canvas 换成 WebGL、"顺手优化"音频引擎、动配色与字体。

---

## 1. 环境与构建

需要：`bash`、`node`（**只用于语法检查**）、`zip`。可选：`python3` + Playwright（跑自检时才用）。

```bash
bash build-all.sh          # 在仓库根目录：语法检查 → 构建两个单文件 → 组装 dist/site → 打包
```

产物与成功判据：

| 文件 | 大小 |
|---|---|
| `index.html` | ≈ 3.3 MB（桌面/宽屏） |
| `index-mobile.html` | ≈ 3.4 MB（手机版，同一套代码，只多手机适配） |
| `dist/site/index.html` | 路由器：按 UA 分派到 `d.html` / `m.html` |
| `dist/site/d.html`、`dist/site/m.html` | 上面两个文件改名 |
| `woolf-site.zip` | 要上传到静态托管的那一份 |

构建中途会打印 `src/app.js OK`（`node -e "new Function(...)"`）。**改完 app.js 一定要先过这一步**，
否则打出来的单文件会在真机上白屏。

单独构建某一版（在 `src/` 里）：

```bash
cd src && bash build.sh        # → ../index.html
cd src && bash build-mobile.sh # → ../index-mobile.html
```

## 2. 代码地图

```
src/app.js        ≈ 3560 行，全部逻辑（IIFE，无模块）
src/style.css      视觉系统 + 断点（900px 是手机/桌面分界）
src/body.html      页面骨架（DOM）
src/router.html    分派页
src/build*.sh      把 CSS/JS 内联进单文件（cat 拼接，无构建工具）
```

`app.js` 里的关键位置：

| 函数 | 作用 | 改动风险 |
|---|---|---|
| `buildParticles` / `drawRiver` | 星河粒子（三层视差 + 靠近星点的引力偏折 `gravityFor`） | 中 |
| `bakeNebula` / `drawNebula` | 河底那层薄雾光（烤成一张图，每帧画 1 次） | 低 |
| `buildStars` / `layoutStars` | 星河上的 5 颗书星（DOM，`.star-node`） | 低 |
| `buildSystem` / `placePlanet` | 星系：三条椭圆轨道 + 行星（DOM，`.planet`） | **高** |
| `solvePlanetLabels` | 行星名字的**一次性**静态求解（见 §3） | **高** |
| `measurePlanetLabels` / `placeStream` | 测量文字盒 / 决定引文栏落在哪里 | 中 |
| `showQuote` / `typeInto` | 引文逐字浮现 | 低 |
| `Sound.*` | WebAudio 实时合成的环境音乐与点击音（无任何音频文件） | 中 |

## 3. 已经踩过的坑，不要重犯

### 星星标签（行星名）

- 现在的模型是**焊死**：名字是 `.planet` 元素的子节点，位移是**一次性**写死的
  `translate(-50%,-50%) translate3d(dx,dy,0)`，之后**任何帧都不再写**。
  父元素 `placePlanet()` 每帧移动，名字自然一起动——**零延迟、零漂移、零贴边**。
- `solvePlanetLabels()` 在建图 / resize 时跑一次：24 个方向、18 个时间采样（62 秒轨道），
  选「不出界、不压中心核、不压别的词、离外向射线最近」的方向。
- **不要再引入这些东西**（全都试过，全都被用户否掉）：
  - 每帧重新搜索角度 + 缓动追赶（`relax`）→ 用户的原话是「字在追光圈」
  - 把 `clamp(minX,maxX)` 夹回屏幕 → 「字卡在屏幕边上」
  - 绕星滑行（每帧 8°）→ 「字在漂移，星星走了字没走」
  - 平滑**偏移向量**再反解角度 → 间隙漂移 12–35px，90 帧以上重叠

### 首屏

- 书名的 `filter:blur(.6px)` 已经删掉——用户说「字太糊」。不要再加模糊。
- 书星的"光环"是 **5 层 `box-shadow` + 一层径向渐晕**，没有实体描边圆环。
  用户截图里那个"大光圈 + 一圈硬边"就是旧版的 `border` 圆环，别再画回来。

### 引文栏（`.stream`）

- `placeStream()` 决定引文栏落在哪：够宽就留在星系左侧（桌面）并把宽度撑到舒适行宽；
  不够（< 24 字符宽，或与星系重叠）就整块移到星系**下方**，下方也放不下再移到**上方**，
  永远是整块满宽，绝不挤成一条细缝。手机上它本来就在星系下面（`position:relative`，直接跳过）。
- 改这个函数之后要同时看 `measurePlanetLabels()`：标签安全区是用引文栏的矩形算出来的。

### 性能（别改回去）

- 手机画布按 `devicePixelRatio` **原生**分辨率画（上限 3×，另有 3.6M 设备像素预算），
  桌面 2×。以前手机压到 2×，dpr=3 的 iPhone / 华为整层星空被拉伸，是糊的。
- 大渐变按视口缓存、星尘按「颜色 × 亮度」分桶、`Path2D` 批量描边、只在值变了时写 style。
- 一个 rAF 循环，没有 `setInterval`；失焦暂停。

## 4. 自检（Playwright）

```bash
pip install playwright && python3 -m playwright install chromium && python3 -m playwright install-deps chromium
```

| 脚本 | 查什么 | 通过线 |
|---|---|---|
| `qa/label_rigid.py <file> <W> <H> <DPR>` | 行星名与星的同步、贴边、压字 | `gapDriftPx ≤ 1.5`、`lagPx ≤ 6.5`、`edgeFrames = 0`、`longestOverlapFrames ≤ 12` |
| `qa/label_sync.py` | 首屏书名的跟随 | 单帧位移 > 8px 的帧数 = 0 |
| `qa/shot.py <file> <W> <H> <DPR> <书\|home> <waitms> <out.png> [--click=词]` | 截图 | 肉眼看 |
| `qa/jank_check.py` | 4× CPU 降速下的掉帧 | 与上一版持平 |
| `qa/atmos_mobile.py`、`qa/river_check.py`、`qa/sharp_check.py`、`qa/lead_check.py` | 各层视觉/清晰度 | `verdict: PASS` |

注意：`qa/qa.py`、`verify.py`、`bughunt.py`、`finalcheck.py` 依赖 `127.0.0.1:8080` 上的本地服务器；
`qa/typing.py` 会遮蔽标准库同名模块（用 `typewriter.py`）。

## 5. 部署

```bash
npx wrangler pages deploy dist/site --project-name woolf
# 或 netlify deploy --prod --dir=dist/site
# 或把 woolf-site.zip 拖进 Cloudflare Pages 网页版
```

线上地址（用户手上那份）：`https://1af261f8.werfu.pages.dev` —— **目前是旧版**，
用户需要重新上传本仓库最新构建出来的 `woolf-site.zip`。

## 6. 验收标准（用户的原话）

1. 字和光点**必须始终一起移动**，不许有偏移、缓动、绕障漂移。
2. 字**不许卡在屏幕边上**（iPhone 13 必现过；华为 Pura 同样不许）。
3. 引文**不许挤成一条细缝**：空间不够就移到上面或下面去。
4. 首屏的光晕要**自然**，不要一个能看见边界的大光盘。
5. 首屏文字要**清晰**，不许发糊。
6. 音乐：**默认直接播放**，不要那个播放按钮（此条见 `docs/状态-2026-11-06.md` 的待办）。
7. 每改一轮都要跑完整 QA 并逐条对照，**没达标不许收尾**。

零依赖 / 零 CDN / 零外部图片 / 零网络请求 / 1 秒内出内容，这几条任何时候都不许破。
