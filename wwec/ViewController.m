
//  ViewController.m
//  wwec
//
//  Created by CQYH on 2018/8/15.
//  Copyright © 2018年 CQYH. All rights reserved.
//
// UIScrollViewDelegate
// UIWebViewDelegate

#import "ViewController.h"
#import "SWQRcode.h"
#import "DownLoad.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "FileUtil.h"

#define kScreen_height [UIScreen mainScreen].bounds.size.height
#define kScreen_width [UIScreen mainScreen].bounds.size.width

@interface ViewController ()<UIWebViewDelegate,UIScrollViewDelegate,UINavigationControllerDelegate,cameraDelegate>{
    UIWebView *_webview;
    JSContext *_context;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *rootPaht = [FileUtil hbo_getRootPath];
    NSString *loadPath = [rootPaht stringByAppendingString:@"web"];
    NSString *zipPath = [rootPaht stringByAppendingString:@"/web.zip"];
    NSString *indexPath2 = [rootPaht stringByAppendingString:@"/web/index.html"];

    BOOL exist = [FileUtil hbo_fileIsExistOfPath:zipPath];
    BOOL exist2 = [FileUtil hbo_fileIsExistOfPath:indexPath2];

    if(exist){
        BOOL unzipOk = [FileUtil hbo_unZip:zipPath unzipPath:loadPath];
        if(unzipOk){
//            NSLog(@"%@",[FileUtil hbo_getFileListInFolderWithPath:rootPaht]);
//            NSLog(@"%@",[FileUtil hbo_getFileListInFolderWithPath:loadPath]);
            [FileUtil hbo_removeFileOfPath:zipPath];
            [self hbo_loadGame:rootPaht];
        }
    }else if(exist2){
        [self hbo_loadGame:loadPath];
    }else{
        [self hbo_loadGame:[[NSBundle mainBundle] resourcePath]];
    }
    [NSThread detachNewThreadSelector:@selector(checkUpdate) toTarget:self withObject:nil];
}
-(void)checkUpdate{
    DownLoad *download = [DownLoad new];
    [download hbo_doInit:self];
    [download hbo_download:@"https://wallet.wwec.top/upgrage/version.json"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)hbo_loadGame:(NSString *)basPath{
    NSString *pathStr = [basPath stringByAppendingPathComponent:@"web"];
    NSString *_pathStr = [pathStr stringByAppendingPathComponent:@"index.html"];
    NSURL *url = [NSURL fileURLWithPath:_pathStr];
    _webview = [[UIWebView alloc]initWithFrame:self.view.frame];
    _webview.backgroundColor = [UIColor blackColor];
    _webview.scrollView.scrollEnabled = NO;
    _webview.scalesPageToFit = YES;
    _webview.delegate = self;
    _webview.scrollView.delegate = self;
    _context = [_webview valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    [_webview loadRequest:[NSURLRequest requestWithURL:url]];
    [self.view addSubview:_webview];
}

/**
 处理扫一扫结果
 @param data 扫描结果
 */
-(void)cameraData:(NSString*)data{
    [self appCalljs:data];
}
// appCalljs
// 目前只有相机有回掉
-(void)appCalljs:(NSString *)data{
    NSDictionary * dic = @{@"type":@"2",@"data":data};
    NSString *jsstring =[self hbo_convertToJSONData:dic];
    jsstring = [jsstring stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSString *textJS = [NSString stringWithFormat:@"%@%@%@", @"native.native.appCalljs('" ,jsstring ,@"')"];
    [_context evaluateScript:textJS];
}

// uiwebview delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    // 获取点击页面加载的url
    NSString *absolutePath = request.URL.absoluteString;
//    absolutePath = @"wwec://jsCallapp?type=2";
//    absolutePath = @"wwec://jsCallapp?type=1&cpvalue=xxxxxx";

    NSString *scheme = @"wwec://";
    if ([absolutePath hasPrefix:scheme]) {
        NSString *subPath = [absolutePath substringFromIndex:scheme.length];
        if ([subPath containsString:@"?"]) {//1个或多个参数
            NSArray *components = [subPath componentsSeparatedByString:@"?"];
            NSString *methodName = [components firstObject];
            methodName = [methodName stringByReplacingOccurrencesOfString:@"_" withString:@":"];
            if([methodName isEqualToString:@"jsCallapp"]){
                NSString *params = [components lastObject];
                NSArray *param = [params componentsSeparatedByString:@"&"];
                NSString *cmd = [param[0] componentsSeparatedByString:@"="][1];
                if(2==cmd.intValue){ //相机
                    SWQRCodeConfig *config = [[SWQRCodeConfig alloc]init];
                    config.scannerType = SWScannerTypeQRCode;
                    SWQRCodeViewController *qrcodeVC = [[SWQRCodeViewController alloc]init];
                    qrcodeVC.codeConfig = config;
                    [qrcodeVC setCameraDele:self];
                    [self.navigationController pushViewController:qrcodeVC animated:YES];
                }
                if(1==cmd.intValue){ //复制,是否禁止页面长按复制
                    NSString *cpvalue = [param[1] componentsSeparatedByString:@"="][1];
                    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                    pasteboard.string = cpvalue;
                }
            }
        }
    }
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

//#pragma mark 去掉导航栏
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

//-----------------------------------------------------------------------util
//字典转jsonstring
- (NSString*)hbo_convertToJSONData:(id)infoDict
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:infoDict
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    
    NSString *jsonString = @"";
    
    if (! jsonData)
    {
        NSLog(@"Got an error: %@", error);
    }else
    {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    jsonString = [jsonString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];  //去除掉首尾的空白字符和换行字符
    
    [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    return jsonString;
}


@end
