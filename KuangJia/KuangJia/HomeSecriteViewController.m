//
//  HomeSecriteViewController.m
//  KuangJia
//
//  Created by yide zhang on 2018/11/4.
//  Copyright © 2018年 yidezhang. All rights reserved.
//

#import "HomeSecriteViewController.h"

#import "YDSecritManger.h"
#import "YDCamoraViewController.h"
#import "YDPhotoAlbumNaviViewController.h"
#import "YDScanerNaviViewController.h"

@interface HomeSecriteViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic,copy) NSArray *dataSource;
@end

@implementation HomeSecriteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.dataSource = @[@"通讯录",@"短信获取",@"短信发送",@"通话记录",@"拨打电话",@"调用相机",@"打开相册",@"二维码 条形码扫描"];
    [self createTableView];
}

-(void)createTableView
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ddd"];
    cell.textLabel.text = self.dataSource[indexPath.row];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
        {
            [YDSecritManger selectPhoneNumViewController:self complection:^(NSString *name, NSString *phone) {
                NSLog(@"name:%@,phone:%@",name,phone);
            }];
        }
            break;
        case 1:
        {
            //获取短信
        }
            break;
        case 2:
        {
            //发送短信
            [YDSecritManger sendMessageWithNum:@[@"100086"] message:@"test" viewController:self complation:^(YDSecritMangerMessageResult result) {

            }];

        }
            break;
        case 3:
        {
            
        }
            break;
        case 4:
        {
            //拨打电话
            [YDSecritManger callPhoneWithNum:@"10086"];
        }
            break;
        case 5:
        {
            //打开相机
            YDCamoraViewController *camora = [[YDCamoraViewController alloc] init];
            [self presentViewController:camora animated:YES completion:nil];
        }
            break;
        case 6:
        {
            //打开相册
            YDPhotoAlbumNaviViewController *controller = [[YDPhotoAlbumNaviViewController alloc] init];
//            [self.navigationController pushViewController:controller animated:YES];
            [self presentViewController:controller animated:YES completion:nil];
        }
            break;
        case 7:
        {
            //二维码扫描 条形码也可以
            YDScanerNaviViewController *navi = [[YDScanerNaviViewController alloc] init];
            [self presentViewController:navi animated:YES completion:nil];
        }
            break;
            
        default:
            break;
    }
}




@end