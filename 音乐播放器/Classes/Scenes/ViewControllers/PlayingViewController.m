//
//  PlayingViewController.m
//  音乐播放器
//
//  Created by lanou3g on 15/11/5.
//  Copyright © 2015年 yrh.com. All rights reserved.
//

#import "PlayingViewController.h"
#import "PlayerManager.h"
#import "DataManager.h"
#import "LyricManger.h"
#import "LyricModel.h"


@interface PlayingViewController ()<PlayerMangerDelegate,UITableViewDataSource,UITableViewDelegate>
// 记录下当前播放音乐的索引
@property (nonatomic,assign) NSInteger currentIndex;
// 记录当前正在播放的音乐
@property (nonatomic,assign) MusicModel* currentModel;

#pragma mark---控件

@property (strong, nonatomic) IBOutlet UILabel *songNameLB;
@property (strong, nonatomic) IBOutlet UILabel *singerNameLB;
@property (strong, nonatomic) IBOutlet UIImageView *img4Pic;
@property (strong, nonatomic) IBOutlet UIImageView *imgBack;
@property (strong, nonatomic) IBOutlet UIButton *btn4playOrPause;


@property (strong, nonatomic) IBOutlet UILabel *lab4playedTime;
@property (strong, nonatomic) IBOutlet UILabel *lab4LastTime;
@property (strong, nonatomic) IBOutlet UISlider *slider4Time;
@property (strong, nonatomic) IBOutlet UISlider *slider4Volume;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

#pragma mark---控件事件
// 上一首
- (IBAction)action4Prev:(UIButton *)sender;
- (IBAction)acton4PlayOrPause:(UIButton *)sender;
- (IBAction)action4Next:(UIButton *)sender;
- (IBAction)action4ChangeTime:(UISlider *)sender;
// 改变音量
- (IBAction)action4ChangeVolume:(UISlider *)sender;

@end

static PlayingViewController * playingVC = nil;
static NSString * identifier = @"cell";
@implementation PlayingViewController


+ (instancetype)sharePlayingPVC{
    static dispatch_once_t onceToken;
    // 创建一个线程  (就执行一次)
    dispatch_once(&onceToken, ^{
        // 创建一个storyBoard
        UIStoryboard * sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        // 在main sb  （storyBoard） 拿到我们需要的视图控制器
        playingVC = [sb instantiateViewControllerWithIdentifier:@"playingVC"];
        NSLog(@"%@",[NSThread currentThread]);
    });
    return playingVC;
}

// 返回的事件
- (IBAction)avtionBack:(UIButton *)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

// 播放事件
- (void)startPlay{
    
    // 调用单例 播放链接
    [[PlayerManager sharedManager] playWithUrlString:self.currentModel.mp3Url];
    
    [self buildUI];  // 开始播放后调用UI
}
#pragma mark ----getter
// 确保当前播放音乐是最新的
- (MusicModel *)currentModel{
    // 取到要播放的model
    MusicModel * model = [[DataManager sharedManager] musicModelWithIndex:self.currentIndex];
    return model;
}



- (void)buildUI{
    self.songNameLB.text = self.currentModel.name;
    self.singerNameLB.text = self.currentModel.singer;
    // 圆圈里的图片
    [self.img4Pic sd_setImageWithURL:[NSURL URLWithString:self.currentModel.picUrl]];
    // 背景图片
    [self.imgBack sd_setImageWithURL:[NSURL URLWithString:self.currentModel.blurPicUrl]];
    // 更改Button 暂停播放
//    [self.btn4playOrPause setTitle:@"暂停" forState:(UIControlStateNormal)];
    [self.btn4playOrPause setImage:[UIImage imageNamed:@"pause.png"] forState:(UIControlStateNormal)];
    
    // 改变进度条的最大值  注意 毫秒/1000变为秒
#warning mark ----只有self才走Get方法
    self.slider4Time.maximumValue = [self.currentModel.duration integerValue] /1000;
    // 进度条播放下一首歌的时候  进度条归0
    self.slider4Time.value = 0;
    
    // 更改旋转的角度,图片归位  （点下一首的时候图片出现问题）
    self.img4Pic.transform = CGAffineTransformMakeRotation(0);
    
    // 调用歌词解析的方法
    [[LyricManger sharedManger] loadLyricWith:self.currentModel.lyric];
    // 刷新歌词
    [self.tableView reloadData];
}

// 将出现开始播放
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
   
    // 如果要播放的音乐和当前音乐一样，就什么也不干
    if (_index == _currentIndex) {
        return;
    }
    // 如果要播放的音乐和当前音乐不一样  当前音乐改变为要播放的音乐
    _currentIndex = _index;
    
     [self startPlay];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 给个初始值   以前的初始值是0
    _currentIndex = -1;
    
    // 设置自己为播放器的代理，帮播放器干一些事情
    [PlayerManager sharedManager].delegate =self;
    
    // 专辑旋转   scheduledTimerWithTimeInterval时间间隔设置小一点转圈就会连续了
//    [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(scroll) userInfo:nil repeats:YES];
    // 注册
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:identifier ];
    
    // 加圆角切割图片
    self.img4Pic.layer.masksToBounds = YES;
    self.img4Pic.layer.cornerRadius = 120;
    
    
    // 设置音量进度条
    self.slider4Volume.value = [[PlayerManager sharedManager] volume];

}
#pragma mark---PlayerMangerDelegate
// 播放器播放结束了，开始播放下一首
- (void)playerDidPlayEnd{
//    _currentIndex++;
//    [self startPlay];
    // 
    [self action4Next:nil];
}
#pragma mark----只要点击暂停的时候图片也暂停了 说明只有一个NSTimer
// 播放器每0.1秒会让代理（也就是这个页面）执行一下这个事件
- (void)playerPlayingWithTime:(NSTimeInterval)time{
    self.slider4Time.value = time;
    
    self.lab4playedTime.text = [self stringWithTime:time];
    // 获取剩余时间
    
    // 歌曲总时间 - 播放的时间
    NSTimeInterval time2 = [self.currentModel.duration integerValue] / 1000 - time;
    self.lab4LastTime.text = [self stringWithTime:time2];
#pragma 旋转方法2
    // 每0.1秒旋转1度
    self.img4Pic.transform = CGAffineTransformRotate(self.img4Pic.transform,M_PI/180);
    
    // 根据当前播放时间获取到应该播放哪句歌词
    NSInteger index = [[LyricManger sharedManger]indexWith:time];
    NSIndexPath * path = [NSIndexPath indexPathForRow:index inSection:0];
    // 让tableView选中与我们找到的歌词
    [self.tableView selectRowAtIndexPath:path animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    
    

}
// 根据时间获取到字符串
- (NSString*)stringWithTime:(NSTimeInterval)time{
    NSInteger minutes = time/60;
    NSInteger seconds = (int)time % 60;   // double  不能取余 转换类型
    return [NSString stringWithFormat:@"%ld:%ld",(long)minutes,(long)seconds];
}


// 专辑旋转
//- (void)scroll{
//
//    _img4Pic.layer.transform = CATransform3DRotate(_img4Pic.layer.transform, M_PI/300, 0, 0, 1);
//
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



// 上一首
- (IBAction)action4Prev:(UIButton *)sender {
    _currentIndex--;
    // 如果是第一首   等于0播第一首  小于0 播最后一首
    if (_currentIndex < 0 ) {
        // 播放最后一首
        _currentIndex = [DataManager sharedManager].allMusic.count - 1;
    }
    
    [self startPlay];
    
}
// 暂停或播放状态
- (IBAction)acton4PlayOrPause:(UIButton *)sender {
    // 判断是否正在播放
    if ([PlayerManager sharedManager].isPlaying) {
        // 如果正在播放，就让播放器暂停，同时改变button的text
        [[PlayerManager sharedManager] pause];
//        [sender setTitle:@"播放" forState:(UIControlStateNormal)];
        [sender setImage:[UIImage imageNamed:@"play.png"] forState:(UIControlStateNormal)];
        
    }else{
        // 暂停状态：开始播放，并改变btn为  暂停
        [[PlayerManager sharedManager] play];
//        [sender setTitle:@"暂停" forState:(UIControlStateNormal)];
        [sender setImage:[UIImage imageNamed:@"pause.png"] forState:(UIControlStateNormal)];
    }
#pragma 插件 //TODO: 标识按钮
    
    //TODO:bug,暂停之后，点击下一首就不能播放了
    
    
}
// 下一首
- (IBAction)action4Next:(UIButton *)sender {
    // 在播放下一首时先暂停，销毁Timer
    [[PlayerManager sharedManager] pause];
    
    _currentIndex++;
    // 如果是最后一首
    if (_currentIndex == [DataManager sharedManager].allMusic.count) {
        // 如果是最后一首播放第一首
        _currentIndex = 0;
    }
    [self startPlay];
    
}
// 改变播放的进度
- (IBAction)action4ChangeTime:(UISlider *)sender {
    
    UISlider * slider = sender;
    // 调用接口
    [[PlayerManager sharedManager] seekToTime:slider.value];
    
}
// 改变音量
- (IBAction)action4ChangeVolume:(UISlider *)sender {
    
    [[PlayerManager sharedManager] changeToVolume:sender.value];
    
}

#pragma mark ------UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    LyricManger * lyric = [LyricManger sharedManger];

    return lyric.allLyric.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
//    cell.textLabel.text = @"歌词";
    
    
    // 设置歌词  // 取到对应的cell
    LyricModel * lyric = [LyricManger sharedManger].allLyric[indexPath.row];
    // 设置歌词
    cell.textLabel.text = lyric.lyricContext;
    // 居中
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    // 背景颜色透明
    cell.backgroundColor = [UIColor clearColor];
    
     return cell;
}


@end
