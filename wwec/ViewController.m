//
//  ViewController.m
//  wwec
//
//  Created by CQYH on 2018/8/15.
//  Copyright © 2018年 CQYH. All rights reserved.
//
// UIScrollViewDelegate
// UIWebViewDelegate

#import "ViewController.h"

@interface ViewController ()<UIWebViewDelegate,UIScrollViewDelegate>{
    
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
    webview.scalesPageToFit = YES;
    webview.delegate = self;
    webview.scrollView.delegate = self;
    [webview loadRequest:[NSURLRequest requestWithURL:url]];
    [self.view addSubview:webview];
}

// uiwebview delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView{

}
- (void)webViewDidFinishLoad:(UIWebView *)webView{

}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    
}

// 唤出键盘内容不移动
- (UIView*)viewForZoomingInScrollView:(UIScrollView*)scrollView{
    return nil;
}

// 背景黑色，状态栏文字白色适配所有机型
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

@end
