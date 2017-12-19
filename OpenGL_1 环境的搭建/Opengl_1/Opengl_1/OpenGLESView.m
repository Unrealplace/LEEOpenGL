//
//  OpenGLESView.m
//  Opengl_1
//
//  Created by NicoLin on 2017/12/19.
//  Copyright © 2017年 NicoLin. All rights reserved.
//

#import "OpenGLESView.h"
#import <OpenGLES/ES2/gl.h>

@interface OpenGLESView()
{
    CAEAGLLayer * _eaglayer; // 当前图层的layer
    EAGLContext * _context; // 当前的绘图上下文
    GLuint        _colorRenderBuffer; //渲染缓存的标识
    GLuint        _frameBuffer; //帧缓存的标识
    
}
@end

@implementation OpenGLESView

+ (Class)layerClass {
    // 据说只有CAEAGLLayer 类型的 layer 才 支持 OpenGL 绘图
    return [CAEAGLLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setuplayer];
        [self setupContext];
    }
    return self;
}

- (void)dealloc {
    [self destoryRenderAndFrameBuffer];
}

- (void)layoutSubviews {
    [EAGLContext setCurrentContext:_context];
    [self destoryRenderAndFrameBuffer];
    [self setupFrameBufferAndRenderBuffer];
    [self render];
    
}

#pragma mark - init Setup

- (void)setuplayer {
    _eaglayer = (CAEAGLLayer*)self.layer;
    // CALayer 默认是透明的，必须将它设为不透明才能让其可见
    _eaglayer.opaque = YES;
    // 设置绘图相关的 属性 ，具体设置可以点击进去看看就好了
    _eaglayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],kEAGLDrawablePropertyRetainedBacking,kEAGLColorFormatRGBA8,kEAGLDrawablePropertyColorFormat, nil];
    
}

- (void)setupContext {
    //创建绘图上下文
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!_context) {
        NSLog(@"Failed to initialize OpenGLES 2.0 context");
        exit(1);
    }
    //设置当前上下文为我们创建的
    if (![EAGLContext setCurrentContext:_context]) {
        NSLog(@"Failed to set current OpenGL context");
        exit(1);
    }
    
    
}

//帧缓存：它是屏幕所显示画面的一个直接映象，又称为位映射图(Bit Map)或光栅。
//帧缓存的每一存储单元对应屏幕上的一个像素，整个帧缓存对应一帧图像。

//渲染缓存：是OpenGLES管理的一处高效内存区域，它可以储存格式化的图像数据。
//渲染缓存中的数据只有关联到一个帧缓存对象才有意义，并且需要保正图像缓存格式必须与OpenGLES要求的渲染格式相符
//（比如:不能将颜色值渲染到深度缓存中）。

- (void)setupFrameBufferAndRenderBuffer {

//    分配n个未使用的渲染缓存对象，并将它存储到renderbuffers中。
//    注意：返回的 id不会为0，0是OpenGL ES 保留的，我们也不能使用 id 为0的 renderbuffer。
    glGenRenderbuffers(1, &_colorRenderBuffer);
//    创建并绑定渲染缓存。当第一次来绑定某个渲染缓存的时候，它会分配这个对象的存储空间并初始化，此后再调用这个函数的时候会将指定的渲染缓存对象绑定为当前的激活状态。
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    // 为 color renderbuffer 分配存储空间 为当前绑定的渲染缓存对象分配图像数据空间。
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglayer];
    
//    分配n个未使用的帧缓存对象，并将它存储到framebuffers中。
    glGenFramebuffers(1, &_frameBuffer);
//    设置一个可读可写的帧缓存。当第一次来绑定某个帧缓存的时候，它会分配这个对象的存储空间并初始化，此后再调用这个函数的时候会将指定的帧缓存对象绑定为当前的激活状态。
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    
//    该函数是将相关的 buffer（三大buffer之一）attach到framebuffer上（如果 renderbuffer不为 0，知道前面为什么说glGenRenderbuffers 返回的id 不会为 0 吧）或从 framebuffer上detach（如果 renderbuffer为 0）。参数 attachment 是指定 renderbuffer 被装配到那个装配点上，其值是GL_COLOR_ATTACHMENTi, GL_DEPTH_ATTACHMENT, GL_STENCIL_ATTACHMENT中的一个，分别对应 color，depth和 stencil三大buffer。
    
    // 将 _colorRenderbuffer 装配到 GL_COLOR_ATTACHMENT0 这个装配点上
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderBuffer);
    
    
}
- (void)destoryRenderAndFrameBuffer {
    glDeleteFramebuffers(1, &_frameBuffer);
    glDeleteRenderbuffers(1, &_colorRenderBuffer);
    _frameBuffer = 0;
    _colorRenderBuffer = 0;
}

#pragma mark - Render

- (void)render {
//    用来设置清屏颜色，默认为黑色；
//    glClear (GLbitfieldmask)用来指定要用清屏颜色来清除由mask指定的buffer，mask 可以是 GL_COLOR_BUFFER_BIT，GL_DEPTH_BUFFER_BIT和GL_STENCIL_BUFFER_BIT的自由组合。
    glClearColor(1.0, 0.5, 1.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    //将指定 renderbuffer 呈现在屏幕上，在这里我们指定的是前面已经绑定为当前 renderbuffer 的那个，在 renderbuffer 可以被呈现之前，必须调用renderbufferStorage:fromDrawable: 为之分配存储空间。
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}


@end
