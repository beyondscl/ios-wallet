//
//  NetworkUtil.m
//  UiLearn
//
//  Created by xianming on 2018/3/14.
//  Copyright © 2018年 hzqzh. All rights reserved.
// 采用代理的方式进行下载
//

#import <Foundation/Foundation.h>
#import "DownLoad.h"
#import "FileUtil.h"
#import "ViewController.h"

@interface DownLoad()<NSURLSessionDownloadDelegate>
@property NSURLSession *session;
@end

@implementation DownLoad


-(void)hbo_doInit:(id)viewContraoller{
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration  defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
}
-(Boolean)hbo_checkSession{
    if (_session==nil) {
        NSLog(@"session didnot init");
        return false;
    }
    return true;
}
-(void)hbo_download:(NSString*)urlStr{
    [self hbo_checkSession];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLSessionDownloadTask *downTask = [_session downloadTaskWithURL:url];
    [downTask resume];
}
//写入本地代理
//比如下载web.zip 最后目录:xxx/web/web/xxx
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    NSString *rootPaht = [FileUtil hbo_getRootPath];
    NSString *filePath = @"";
    NSString *fileName = downloadTask.response.suggestedFilename;
    
    NSString *fullPath = [rootPaht stringByAppendingFormat:@"%@%@",filePath,fileName];
    if (fileName && [fileName containsString:@".zip"]) {
        [FileUtil hbo_moveFileFromDown:location toFullPath:fullPath];
        [FileUtil hbo_moveFileFromDown:[NSURL fileURLWithPath:[rootPaht stringByAppendingString:@"version.json_temp"]] toFullPath:[rootPaht stringByAppendingString:@"version.json"]];
    }
    if (fileName && [fileName containsString:@"version.json"]) {
        //本地文件
        NSString *version_path=[rootPaht stringByAppendingString:@"version.json"];
        if([FileUtil hbo_fileIsExistOfPath:version_path]){
            NSData *data=[NSData dataWithContentsOfFile:version_path];
            NSMutableDictionary *dictFromData = [NSJSONSerialization JSONObjectWithData:data
                                                                                options:NSJSONReadingAllowFragments
                                                                                  error:nil];
            NSString *version = [dictFromData objectForKey:@"version"];
            NSString *upgrade_app = [dictFromData objectForKey:@"upgrade_app"];
            NSString *build = [dictFromData objectForKey:@"build"];
            //临时文件
            NSData *jdata = [[NSData alloc] initWithContentsOfFile:location];
            NSMutableDictionary *new_v = [NSJSONSerialization JSONObjectWithData:jdata
                                                                         options:NSJSONReadingAllowFragments
                                                                           error:nil];
            NSString *new_build = [new_v objectForKey:@"build"];
            NSString *new_version = [new_v objectForKey:@"version"];
            //更新或提示
            if(new_build.integerValue > build.integerValue){
                NSString *fullPath = [rootPaht stringByAppendingFormat:@"%@%@",filePath,[fileName stringByAppendingString:@"_temp"]];
                [FileUtil hbo_moveFileFromDown:location toFullPath:fullPath];
                [NSThread detachNewThreadSelector:@selector(checkUpdate) toTarget:self withObject:nil];
            }
            if(upgrade_app.integerValue == 1 && ![new_version isEqualToString:version]){//提示更新app了。
                
            }
        }else{
            [FileUtil hbo_moveFileFromDown:location toFullPath:fullPath];
        }
    }
}
-(void)checkUpdate{
    [self hbo_download:@"https://wallet.wwec.top/upgrage/web.zip"];
    //test url 
}
//恢复下载代理
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes{
    
}
//下载过程
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    float downPercent = 1.0*totalBytesWritten/totalBytesExpectedToWrite;
    NSLog(@"总下载百分比%1f:",downPercent);
}
//请求完成,错误的代理方法
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    if (error) {
        NSLog(@"下载出错%@:",error);
    }
}

@end
