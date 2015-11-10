//
//  LyricManger.m
//  音乐播放器
//
//  Created by lanou3g on 15/11/10.
//  Copyright © 2015年 yrh.com. All rights reserved.
//

#import "LyricManger.h"
#import "LyricModel.h"


@interface LyricManger ()

// 用来存放歌词de 数组
@property (nonatomic,strong)NSMutableArray * lyrics;

@end

static LyricManger * manager = nil;
@implementation LyricManger

- (NSArray *)allLyric{
    
    return self.lyrics;
}

+ (instancetype)sharedManger{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        
        manager = [LyricManger new];
    });
    return manager;
}
// 通过字符串加载歌词
- (void)loadLyricWith:(NSString *)lyricStr{
    // 1、分行
    NSMutableArray * lyricStringArray = [[lyricStr componentsSeparatedByString:@"\n"] mutableCopy];
    // 最后一行是@""
    [lyricStringArray removeLastObject];
    
    // 要先将之前歌曲的歌词数据移除
    [self.lyrics removeAllObjects];
    
    for (NSString * str in lyricStringArray) {
#pragma 方法1    方法2 把数组改为可变数组 删除最后一个元素
        // 如果是最后一行
//        if ([str isEqualToString:@""]) {
//            continue;
//        }

        // 2、分开时间和歌词
        NSArray * timeAndLyric = [str componentsSeparatedByString:@"]"];
        
        NSLog(@"%@",timeAndLyric);
        // 3、去掉时间左边的"["
        NSString * time = [timeAndLyric[0] substringFromIndex:1];
        // time =     02:32:38
        // 4、截取时间获取分和秒
        NSArray * minuteAndSecond = [time componentsSeparatedByString:@":"];
        // 分
        NSInteger minute = [minuteAndSecond[0] integerValue];  // 类型转换
        // 秒
        double second = [minuteAndSecond[1] doubleValue]; // 类型转换
        // 5、装成一个model
        LyricModel * model = [[LyricModel alloc] initWithTime:(minute * 60 + second) lyric:timeAndLyric[1]];
        // 6、添加到数组中
        [self.lyrics addObject:model];
        
    }
    
}
#pragma mark -- 歌词懒加载
- (NSMutableArray *)lyrics{
    if (!_lyrics) {
        _lyrics = [NSMutableArray new];
        
    }
    return _lyrics;
}

- (NSInteger)indexWith:(NSTimeInterval)time{
    NSInteger index = 0;
    // 遍历数组，找到还没有播放的那句歌词
    for (int i = 0; i < self.lyrics.count; i++) {
        LyricModel * model = self.lyrics[i];
        if (model.time > time) {
            // 注意如果是第0个元素，而且元素时间比要播放的时间大，i - 1 就会小于0，这样tableView就会cash
            index = (i - 1 > 0)? i - 1 : 0;
            // 一定要break 要不会一直循环下去
            break;  // 结束for循环
        }
    }
    return index;
}


@end
