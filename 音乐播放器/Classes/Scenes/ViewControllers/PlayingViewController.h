//
//  PlayingViewController.h
//  音乐播放器
//
//  Created by lanou3g on 15/11/5.
//  Copyright © 2015年 yrh.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayingViewController : UIViewController

@property (nonatomic,assign)NSInteger  index;



// 写一个单例方法
+ (instancetype)sharePlayingPVC;



@end
