//
//  ViewController.m
//  Opengl_1
//
//  Created by NicoLin on 2017/12/19.
//  Copyright © 2017年 NicoLin. All rights reserved.
//

#import "ViewController.h"
#import "OpenGLESView.h"

@interface ViewController ()

@property (nonatomic ,strong)OpenGLESView * showView;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.view = [[OpenGLESView alloc] initWithFrame:self.view.bounds];
    
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
