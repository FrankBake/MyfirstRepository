//
//  MusicListController.m
//  音乐播放器
//
//  Created by lanou3g on 15/11/4.
//  Copyright © 2015年 yrh.com. All rights reserved.
//

#import "MusicListController.h"
#import "MusicCell.h"
#import "DataManager.h"
#import "PlayerManager.h"
#import "PlayingViewController.h"

@interface MusicListController ()

@end

static NSString * cellIdentifier = @"musicCell";
static NSString * customCell = @"customcell";

@implementation MusicListController
// 代码规范，每一个模块之间要空一行
- (void)viewDidLoad {
    [super viewDidLoad];
    // 注册自定义cell
    [self.tableView registerNib:[UINib nibWithNibName:@"MusicCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:customCell];
    
    [DataManager sharedManager].myUpdataUI= ^(){
        [self.tableView reloadData];
    };
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return [DataManager sharedManager].allMusic.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MusicCell *cell = [tableView dequeueReusableCellWithIdentifier:customCell forIndexPath:indexPath];
    cell.musicModel = [[DataManager sharedManager] musicModelWithIndex:indexPath.row];
    //cell.textLabel.text = @"音乐";
    // 设置点击效果为无
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 150;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // 打印当前点击的row 的 model数据
    MusicCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"%@",cell.musicModel);
    
    // 播放音乐   一个页面的时候实现的播放
//    [[PlayerManager sharedManager] playWithUrlString:cell.musicModel.mp3Url];
    
    
    
    // 拿到要模态出来的控制器
    PlayingViewController * playingVC = [PlayingViewController sharePlayingPVC];
    playingVC.index = indexPath.row;
//    [self presentViewController:playingVC animated:YES completion:nil];
    // 两个模态推出都可以
    [self showDetailViewController:playingVC sender:nil];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
