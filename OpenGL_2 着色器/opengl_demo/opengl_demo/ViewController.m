//
//  ViewController.m
//  opengl_demo
//
//  Created by NicoLin on 2017/12/19.
//  Copyright © 2017年 NicoLin. All rights reserved.
//

#import "ViewController.h"
#import "OpenGLESView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view = (OpenGLESView*)[[OpenGLESView alloc] initWithFrame:self.view.bounds];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
