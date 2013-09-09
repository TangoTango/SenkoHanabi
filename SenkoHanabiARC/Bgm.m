//
//  Bgm.m
//  SenkoHanabiARC
//
//  Created by lethe on 2013/09/09.
//  Copyright (c) 2013年 PTA. All rights reserved.
//

#import "Bgm.h"

@implementation Bgm
// 文字列型のファイルパスを入力し、対応する音源のインスタンスを得る
- (id)initWithPath:(NSString*)path {
    self = [super init];
    
    self.path = path;
    
    // ファイルパスからファイル名を取得
    NSString* fileName = [self.path lastPathComponent];
    NSLog(@"fileName:%@", fileName);
    NSLog(@"path:%@", [fileName stringByDeletingPathExtension]);
    
    // ファイル名から絶対パスを取得
    NSString* absPath = [[NSBundle mainBundle] pathForResource:[fileName stringByDeletingPathExtension] ofType:[fileName pathExtension]];
    
    // 絶対パスからURLを取得
    NSURL* url = [NSURL fileURLWithPath:absPath];
    
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    
    return self;
}

// プレイヤをメモリに読み込む
-(void) prepareToPlay {
    [self.player prepareToPlay];
}

// ループ回数を設定(負の値を入力すると無限ループ)
- (void)setNumberOfLoops:(NSInteger)loopNum {
    [self.player setNumberOfLoops:loopNum];
}

// 音量を設定
- (void)setVolume:(float)volume {
    self.player.volume = volume;
}

// 再生
- (void)play {
    [self.player play];
}

// 停止
- (void)stop {
    [self.player stop];
}
@end
