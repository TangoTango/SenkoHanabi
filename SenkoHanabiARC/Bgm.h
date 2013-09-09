//
//  Bgm.h
//  SenkoHanabiARC
//
//  Created by lethe on 2013/09/09.
//  Copyright (c) 2013年 PTA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface Bgm : NSObject

@property (strong)NSString* path;
@property (strong)AVAudioPlayer* player;

- (id)initWithPath:(NSString*)path;
- (void)prepareToPlay;
- (void)setNumberOfLoops:(NSInteger)loopNum;
- (void)setVolume:(float)volume;
- (void)play;
- (void)stop;
@end
