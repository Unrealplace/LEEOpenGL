//
//  ViewController.m
//  opengl_demo
//
//  Created by NicoLin on 2017/12/20.
//  Copyright © 2017年 NicoLin. All rights reserved.
//

#import "ViewController.h"
#import "OpenGLESView.h"
#import "JpegUtil.h"
#import "GLUtil.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view = (OpenGLESView*)[[OpenGLESView alloc] initWithFrame:self.view.bounds];
}



@end
