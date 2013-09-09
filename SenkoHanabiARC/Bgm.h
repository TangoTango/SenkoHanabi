//
//  Bgm.h
//  SenkoHanabiARC
//
//  Created by lethe on 2013/09/09.
//  Copyright (c) 2013年 PTA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

// BGMを表すクラス
@interface Bgm : NSObject

@property (strong)NSString* path; // ファイルパス
@property (strong)AVAudioPlayer* player; // プレイヤ
@property (assign)bool played; // 再生されているかどうか

// 文字列型のファイルパスを入力し、対応する音源のインスタンスを得る
- (id)initWithPath:(NSString*)path;

// プレイヤをメモリに読み込む
- (void)prepareToPlay;

// ループ回数を設定(負の値を入力すると無限ループ)
- (void)setNumberOfLoops:(NSInteger)loopNum;

// 音量を設定
- (void)setVolume:(float)volume;

// 再生
- (void)play;

// 停止
- (void)stop;
@end
