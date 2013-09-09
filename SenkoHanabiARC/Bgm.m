//
//  Bgm.m
//  SenkoHanabiARC
//
//  Created by lethe on 2013/09/09.
//  Copyright (c) 2013年 PTA. All rights reserved.
//

#import "Bgm.h"

@implementation Bgm
- (id)initWithPath:(NSString*)path {
    self = [super init];
    
    self.path = path;
    
    NSString* fileName = [self.path lastPathComponent];
    NSLog(@"fileName:%@", fileName);
    NSLog(@"path:%@", [fileName stringByDeletingPathExtension]);
    
    NSString* absPath = [[NSBundle mainBundle] pathForResource:[fileName stringByDeletingPathExtension] ofType:[fileName pathExtension]];
    NSURL* url = [NSURL fileURLWithPath:absPath];
    
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    
    return self;
}

-(void) prepareToPlay {
    [self.player prepareToPlay];
}

- (void)setNumberOfLoops:(NSInteger)loopNum {
    [self.player setNumberOfLoops:loopNum];
}

- (void)setVolume:(float)volume {
    self.player.volume = volume;
}

- (void)play {
    [self.player play];
}

- (void)stop {
    [self.player stop];
}
@end
