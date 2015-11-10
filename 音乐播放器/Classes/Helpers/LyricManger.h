//
//  LyricManger.h
//  音乐播放器
//
//  Created by lanou3g on 15/11/10.
//  Copyright © 2015年 yrh.com. All rights reserved.
//  新建单例 歌词管理者

#import <Foundation/Foundation.h>

@interface LyricManger : NSObject

// 对外的歌词数组 (外界只能读不能改 改就会崩)
@property (nonatomic, strong) NSArray * allLyric;


+ (instancetype)sharedManger;
// 通过字符串加载歌词
- (void)loadLyricWith:(NSString *)lyricStr;

- (NSArray *)allLyric;

/**
 *  根据播放时间获取到将要播放的歌词的索引
 *
 *  @param time <#time description#>
 *
 *  @return <#return value description#>
 */
- (NSInteger)indexWith:(NSTimeInterval)time;

@end
