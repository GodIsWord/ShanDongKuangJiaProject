//
//  YDPhotoAlbumViewController.m
//  相册
//
//  Created by yide zhang on 2018/8/25.
//  Copyright © 2018年 yide zhang. All rights reserved.
//

#import "YDPhotoAlbumViewController.h"
#import "YDPhotoAlbumCollectionViewCell.h"
#import <Photos/Photos.h>

#import "YDPhotoAlbumManager.h"

@interface YDPhotoAlbumViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property(nonatomic,strong) UICollectionView *collectionView;
@property(nonatomic,strong) UICollectionViewFlowLayout *collectionLayout;

@property(nonatomic,strong) NSMutableArray *arrSelected;

@property(nonatomic,strong) UILabel *bottomLabel;

@property (nonatomic, assign) CGFloat cellWidth;


@end

@implementation YDPhotoAlbumViewController

static NSString *const cellId = @"cellId";
static NSString *const headerId = @"headerId";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.cellWidth = (self.view.bounds.size.width)/4;
    self.arrSelected = [NSMutableArray array];
    [self initSubbView];
    [self initBottomView];
}
-(void)initSubbView{
    self.collectionLayout= [[UICollectionViewFlowLayout alloc] init];
//    self.collectionLayout.headerReferenceSize = CGSizeMake(self.view.frame.size.width, 50);
//    //该方法也可以设置itemSize
    self.collectionLayout.itemSize =CGSizeMake(self.cellWidth-10, self.cellWidth-10);
    UICollectionView *collection = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:self.collectionLayout];
    collection = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-50) collectionViewLayout:self.collectionLayout];
    collection.backgroundColor = [UIColor whiteColor];
    collection.dataSource = self;
    collection.delegate = self;
    [self.view addSubview:collection];
    self.collectionView = collection;
    
    [collection registerClass:YDPhotoAlbumCollectionViewCell.class forCellWithReuseIdentifier:cellId];
    
    
    UIBarButtonItem  *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(finishSelect:)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame= CGRectMake(10, 0, 25, 25);
    [btn addTarget:self action:@selector(btnClickBack) forControlEvents:UIControlEventTouchUpInside];
    [btn setImage:[UIImage imageNamed:@"ydhoto_back@2x.png"] forState:UIControlStateNormal];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
}
-(void)btnClickBack
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)finishSelect:(UIBarButtonItem*)item
{
    if ([item.title isEqualToString:@"取消"]) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    if ([self.finishDelegate respondsToSelector:@selector(photoAlbumSelectedViewController:result:)]) {
        
        NSMutableArray *array = [NSMutableArray array];
        for (PHAsset *asset in self.arrSelected) {
            [YDPhotoAlbumManager fetchHighQualityImageDataWithAsset:asset progress:nil complate:^(NSData *result) {
                [array addObject:result];
            }];
        }
        [self.finishDelegate photoAlbumSelectedViewController:self.navigationController result:array];
    }
}
-(void)initBottomView
{
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-50, self.view.bounds.size.width, 50)];
    bottomView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:bottomView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:bottomView.bounds];
    [bottomView addSubview:label];
    self.bottomLabel = label;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:18];
    label.text = @"0张";
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.dataSouce.count>0) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.dataSouce.count-1 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
    }
}

-(void)reloadDate{
    [self.collectionView reloadData];
}


#pragma mark -- datasouce

//返回section个数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

//每个section的item个数
- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSouce.count;
}

- (UICollectionReusableView *) collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    YDPhotoAlbumCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    cell.backgroundColor = [UIColor purpleColor];
    cell.backgroundColor = [UIColor blueColor];
    PHAsset *asset = self.dataSouce[indexPath.item];
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize cellSize = cell.frame.size;
    CGSize AssetGridThumbnailSize = CGSizeMake(cellSize.width * scale, cellSize.height * scale);

    [YDPhotoAlbumManager fetchHighQualityImageAsset:asset viewSize:AssetGridThumbnailSize progress:nil complate:^(UIImage *result) {
        cell.imageView.image = result;
    }];
    
    __weak typeof(self) weakSelf = self;
    [cell setSelectBLock:^(BOOL isSelect) {
        if (isSelect) {
            [weakSelf.arrSelected addObject:[weakSelf.dataSouce objectAtIndex:indexPath.row]];
        }else{
            id obj = weakSelf.dataSouce[indexPath.row];
            if ([weakSelf.arrSelected containsObject:obj]) {
                [weakSelf.arrSelected removeObject:obj];
            }
        }
        weakSelf.bottomLabel.text= [NSString stringWithFormat:@"%lu张",(unsigned long)weakSelf.arrSelected.count];
        if (weakSelf.arrSelected.count >0) {
            [weakSelf.navigationItem.rightBarButtonItem setTitle:@"完成"];
        }else{
            [weakSelf.navigationItem.rightBarButtonItem setTitle:@"取消"];
        }
    }];
    return cell;
}
- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


#pragma mark ---- UICollectionViewDelegateFlowLayout
//设置每个item的尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.cellWidth-10, self.cellWidth-10);
}

//设置每个item的UIEdgeInsets
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5, 5, 5, 5);
}

//设置每个item水平间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}


//设置每个item垂直间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 5;
}

#pragma mark ---- UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

// 点击高亮
- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor greenColor];
}


// 选中某item
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"select:%@",indexPath);
}


// 长按某item，弹出copy和paste的菜单
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

// 使copy和paste有效
- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(nullable id)sender
{
//    if ([NSStringFromSelector(action) isEqualToString:@"copy:"] || [NSStringFromSelector(action) isEqualToString:@"paste:"])
//    {
//        return YES;
//    }
    
    return NO;
}

//
- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(nullable id)sender
{
    if([NSStringFromSelector(action) isEqualToString:@"copy:"])
    {
        [_collectionView performBatchUpdates:^{
//            [_section0Array removeObjectAtIndex:indexPath.row];
//            [_collectionView deleteItemsAtIndexPaths:@[indexPath]];
        } completion:nil];
    }
    else if([NSStringFromSelector(action) isEqualToString:@"paste:"])
    {
        NSLog(@"-------------执行粘贴-------------");
    }
}


@end
