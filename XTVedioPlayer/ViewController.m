//
//  ViewController.m
//  XTVedioPlayer
//
//  Created by Admin on 2017/5/10.
//  Copyright © 2017年 Summer. All rights reserved.
//
#import "XTPlayerManager.h"
#import "ViewController.h"

@interface ViewController ()
@property (strong, nonatomic) XTPlayerManager *manager;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    NSURL *url = [[NSBundle mainBundle]URLForResource:@"hubblecast.m4v" withExtension:nil];
//    self.manager = [[XTPlayerManager alloc] initWithURL:url];
//    UIView *playerView = self.manager.view;
//    playerView.frame = self.view.frame;
//    [self.view addSubview:playerView];
}
-(BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end
