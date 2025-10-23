#!/bin/bash
# Flutter Linux 앱 실행 스크립트
# ATK 접근성 및 GDK 커서 테마 경고 무시

export GTK_A11Y=none
export GDK_DEBUG=""
export QT_AUTO_SCREEN_SCALE_FACTOR=1

# Flutter 경로 설정
FLUTTER_PATH="/home/najoan/develop/flutter-sdk/flutter/bin/flutter"

# 첫 실행 시 빌드
if [ ! -d "build/linux/x64/release/bundle" ]; then
    echo "빌드 중..."
    $FLUTTER_PATH build linux
fi

# 앱 실행
echo "Agora 실행 중..."
$FLUTTER_PATH run -d linux
