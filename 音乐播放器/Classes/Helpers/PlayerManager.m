//
//  PlayerManager.m
//  音乐播放器
//
//  Created by lanou3g on 15/11/5.
//  Copyright © 2015年 yrh.com. All rights reserved.
//

#import "PlayerManager.h"
#import <AVFoundation/AVFoundation.h>

@interface PlayerManager ()

// 播放器 ——> 全局唯一，因为如果有两个AVplayer的话，就会同时播放两个音乐。
@property (nonatomic, strong) AVPlayer * player;
// 计时器
@property (nonatomic, strong) NSTimer * timer;

@end

@implementation PlayerManager

static PlayerManager * manager = nil;
// 单例方法
+ (instancetype)sharedManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [PlayerManager new];
        
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        // 添加通知中心，当self发出AVPlayerItemDidPlayToEndTimeNotification时， 触发playDidPlayEnd事件
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playDidPlayEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    }
    return self;
}

- (void)playDidPlayEnd:(NSNotification*)sender{
    // 有代理 且代理实现了这个方法playerDidPlayEnd
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerDidPlayEnd)]) {
        // 接收到item播放结束后，让代理去干一些事情，代理会怎么干，播放器不需要知道
        [self.delegate playerDidPlayEnd];
    }
}

// 改变音量
- (void)changeToVolume:(CGFloat)volume{
    
    self.player.volume = volume;
}
- (CGFloat)volume{
    return self.player.volume;
}


// 播放
- (void)play{
    // 如果正在播放  再点击播放就不播放了，直接返回就行了
   
    
    // 开始播放标记一下
    _isPlaying = YES;
    [self.player play];
    
    // 创建的计时器
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(playingWithSeconds) userInfo:nil repeats:YES];

    
}
- (void)playingWithSeconds{
    
    NSLog(@"%lld",self.player.currentTime.value/self.player.currentTime.timescale);
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(playerPlayingWithTime:)]) {
        // 计算一下播放器现在播放的秒数
        NSTimeInterval time = self.player.currentTime.value/ self.player.currentTime.timescale;
        [self.delegate playerPlayingWithTime:time];
    }
}

// 暂停播放
- (void)pause{
    [self.player pause];
    // 暂停播放后设置为NO；
    _isPlaying = NO;
    
    // 暂停的时候清除计时器
    [self.timer invalidate];
    self.timer = nil;
    
}
// 改变进度 timescale：几帧每秒
// value / timescale = seconds
- (void)seekToTime:(NSTimeInterval)time{
    // 拖动的时候先暂停
    [self pause];
    [self.player seekToTime:CMTimeMakeWithSeconds(time, self.player.currentTime.timescale) completionHandler:^(BOOL finished) {
        // 若拖动条成功了
        if (finished) {
            // 拖拽成功后再播放
            [self play];
        }
    }];
}

- (void)playWithUrlString:(NSString *)urlStr{
    
    // 如果切换歌曲，需要移除正在播放的观察者
    if (self.player.currentItem){
        [self.player.currentItem removeObserver:self forKeyPath:@"status"];
    }
    
    // 创建一个Item
    AVPlayerItem * item = [[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:urlStr]];
    // 对item添加观察
    // 观察Item的状态
    [item addObserver:self forKeyPath:@"status" options:(NSKeyValueObservingOptionNew) context:nil];
    
    
    // 替换当前正在播放的音乐
    [self.player replaceCurrentItemWithPlayerItem:item];
    
    
}

#pragma mark -- lazy load
- (AVPlayer *)player{
    if (!_player) {
        _player = [AVPlayer new];
    }
    return _player;
}
#pragma mark --观察响应
// 观察者事件
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    
    NSLog(@"%@",keyPath);
    NSLog(@"%@",change);
    AVPlayerItemStatus status = [change[@"new"] integerValue];    // 类型转换
    
    switch (status) {
        case AVPlayerItemStatusFailed:
            NSLog(@"加载失败");
            break;
        case AVPlayerItemStatusUnknown:
            NSLog(@"资源不正确");
            break;
        case AVPlayerItemStatusReadyToPlay:
            NSLog(@"准备好了，可以播放了");
            // 开始播放
            [self pause];   // 先暂停（暂停事件中销毁的NSTimer），再播放,创建新的NSTimer
            [self play];
            
            break;
            
        default:
            break;
    }
}


@end
