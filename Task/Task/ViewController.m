//
//  ViewController.m
//  Task
//
//  Created by Flame Grace on 2017/6/21.
//  Copyright © 2017年 flamegrace. All rights reserved.
//

#import "ViewController.h"
#import "HttpDownloadHandle.h"
#import "ImageDownloadHandle.h"
#import <QuickLook/QuickLook.h>

@interface ViewController () <DownloadHandleDelegate,UITableViewDelegate,UITableViewDataSource,QLPreviewControllerDelegate,QLPreviewControllerDataSource>

@property (strong, nonatomic) HttpDownloadHandle *downloadhandle;
@property (strong, nonatomic) ImageDownloadHandle *downloadhandle2;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *ar;
@property (strong, nonatomic) NSString *currentImagePath;
- (IBAction)clear:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.ar = [NSMutableArray array];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
//    [HttpDownloadHandle clear];
//    self.downloadhandle = [[HttpDownloadHandle alloc]init];
//    self.downloadhandle.delegate = self;
    
    [ImageDownloadHandle clear];
    self.downloadhandle2 = [[ImageDownloadHandle alloc]init];
    self.downloadhandle2.delegate = self;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)downloadHandle:(id<DownLoadHandleProtocol>)handle downloadNewImage:(NSString *)imagePath
{
    [self.ar addObject:imagePath];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)previewImage
{
    QLPreviewController *previewController = [[QLPreviewController alloc] init];
    //设置数据源
    previewController.dataSource =self;
    previewController.delegate = self;
    previewController.hidesBottomBarWhenPushed = YES;
    [self presentViewController:previewController animated:YES completion:nil];
    
}


- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller
{
    return 1;
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
    
    if (index == 0) {
        return [NSURL fileURLWithPath:self.currentImagePath];
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *image = self.ar[indexPath.row];
    self.currentImagePath = image;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self previewImage];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *image = self.ar[indexPath.row];
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellreuseIdentifier"];
    cell.textLabel.text = [image lastPathComponent];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.ar.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (IBAction)clear:(id)sender {
    
    self.downloadhandle2 = nil;
}
@end
