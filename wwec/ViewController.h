//
//  ViewController.h
//  wwec
//
//  Created by CQYH on 2018/8/15.
//  Copyright © 2018年 CQYH. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol cameraDelegate <NSObject>
-(void)cameraData:(NSString*)data;
@end

@interface ViewController : UIViewController

-(void)hbo_loadGame:(NSString *)basPath;
@end

