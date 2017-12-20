//
//  ViewController.m
//  opengl_demo
//
//  Created by NicoLin on 2017/12/20.
//  Copyright © 2017年 NicoLin. All rights reserved.
//

#import "ViewController.h"
#import "OpenGLESView.h"
#import "GLUtil.h"
#import "JpegUtil.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view = (OpenGLESView*)[[OpenGLESView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 200)];
    
    
 }


@end
