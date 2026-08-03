package com.kumayokeru.kumayokeru_app

import com.ryanheise.audioservice.AudioServiceActivity

// 存在通知機能のバックグラウンド再生継続(audio_service)のため、
// FlutterActivityではなくAudioServiceActivityを継承する。
class MainActivity : AudioServiceActivity()
