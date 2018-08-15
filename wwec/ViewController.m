//
//  ViewController.m
//  wwec
//
//  Created by CQYH on 2018/8/15.
//  Copyright © 2018年 CQYH. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UIWebViewDelegate>{
    
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self hbo_loadGame];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)hbo_loadGame{
    NSString *pathStr = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"web"];
    NSString *_pathStr = [NSString stringWithFormat:@"%@/index.html",pathStr];
    NSURL *url = [NSURL fileURLWithPath:_pathStr];
    UIWebView *webview = [[UIWebView alloc]initWithFrame:self.view.frame];
    webview.backgroundColor = [UIColor blackColor];
    webview.scrollView.scrollEnabled = NO;
    webview.delegate = self;
    [webview loadRequest:[NSURLRequest requestWithURL:url]];
    [self.view addSubview:webview];
}

@end
