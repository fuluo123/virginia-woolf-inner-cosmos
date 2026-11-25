#!/usr/bin/env bash
# Rebuild everything from source, then assemble what goes on the web.
#
#   bash build-all.sh
#
# Output
#   index.html           桌面版（单文件，3.4 MB，音乐在里面）
#   index-mobile.html    手机版（单文件，3.5 MB）
#   dist/site/           要上传到静态托管的三个文件（index.html 是路由器）
#   woolf-site.zip       上面三个文件打成的包，拖到 Cloudflare Pages / Netlify 就行
#
# No dependencies: bash + coreutils only. No npm, no network.
set -euo pipefail
cd "$(dirname "$0")"

echo "— 语法检查"
node -e "new Function(require('fs').readFileSync('src/app.js','utf8'))" \
  && echo "  src/app.js OK"

echo "— 构建两个单文件"
( cd src && bash build.sh && bash build-mobile.sh )

echo "— 组装 dist/site"
mkdir -p dist/site
cp src/router.html dist/site/index.html
cp index.html       dist/site/d.html
cp index-mobile.html dist/site/m.html

echo "— 打包"
rm -f woolf-site.zip
( cd dist/site && zip -q -9 ../../woolf-site.zip index.html d.html m.html )

echo
echo "完成："
ls -lh index.html index-mobile.html woolf-site.zip | awk '{printf "  %-20s %s\n", $9, $5}'
