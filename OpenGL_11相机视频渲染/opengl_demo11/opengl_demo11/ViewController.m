//
//  ViewController.m
//  opengl_demo11
//
//  Created by LiYang on 2017/12/24.
//  Copyright © 2017年 LiYang. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "libyuv.h"
#import "OpenGLESView.h"
@interface ViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate>
@property (nonatomic, strong) AVCaptureSession    *captureSession;
@property (nonatomic, strong) AVCaptureDeviceInput    *videoInput;
@property (nonatomic, strong) AVCaptureVideoDataOutput    *videoOutput;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 30, 120, 30)];
    [btn addTarget:self action:@selector(startBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"开始" forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor greenColor]];
    [self.view addSubview:btn];
   
    [self setupSession];
    
}
- (void)startBtnClick:(UIButton *)sender
{
    if (![_captureSession isRunning]) {
        [_captureSession startRunning];
    }
}

- (void)setupSession {
    
    // 设置 输入 的摄像头
    
    AVCaptureDevice * inputCamera = nil;
    NSArray * devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice * device in devices) {
        if (device.position == AVCaptureDevicePositionBack) {
            inputCamera  = device;
        }
    }
    if (!inputCamera) return;
    
    // 绑定输入 session
    NSError * error = nil;
    _videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:inputCamera error:&error];
    if ([self.captureSession canAddInput:_videoInput]) {
        [self.captureSession addInput:_videoInput];
    }
    
    // 绑定输出
    if ([self.captureSession canAddOutput:self.videoOutput]) {
        [self.captureSession addOutput:self.videoOutput];
    }
    
    [self.captureSession commitConfiguration];
    
    
}


- (AVCaptureSession*)captureSession {
    if (!_captureSession) {
        _captureSession = [[AVCaptureSession alloc] init];
        [_captureSession beginConfiguration];
        [_captureSession setSessionPreset:AVCaptureSessionPreset640x480];
    }
    return _captureSession;
}

- (AVCaptureVideoDataOutput *)videoOutput {
    if (!_videoOutput) {
        _videoOutput = [[AVCaptureVideoDataOutput alloc] init];
        [_videoOutput setAlwaysDiscardsLateVideoFrames:NO];
        [_videoOutput setVideoSettings:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange],kCVPixelBufferPixelFormatTypeKey, nil]];
        [_videoOutput setSampleBufferDelegate:self queue:dispatch_get_global_queue(0, 0)];
    }
    return _videoOutput;
}

#pragma mark outputBuffer 代理
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if (!self.captureSession.isRunning) {
        return;
    }else if (output == _videoOutput  ){
        NSLog(@"%@",sampleBuffer);
    }
}



@end
