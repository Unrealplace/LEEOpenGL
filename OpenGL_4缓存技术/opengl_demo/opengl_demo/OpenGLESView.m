//
//  OpenGLESView.m
//  OpenGLES01-环境搭建
//
//  Created by qinmin on 2017/2/9.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#import "OpenGLESView.h"
#import <OpenGLES/ES3/gl.h>
#import "GLUtil.h"
//#import "UIImage+GLES.h"

typedef struct {
    GLfloat x,y,z;
    GLfloat r,g,b;
} Vertex;

@interface OpenGLESView ()
{
    CAEAGLLayer     *_eaglLayer;
    EAGLContext     *_context;
    GLuint          _colorRenderBuffer;
    GLuint          _frameBuffer;
    
    GLuint          _program;
    int             _vertCount;
    
    Vertex          *_vertext;
    GLuint          _vao;
}
@end

@implementation OpenGLESView

+ (Class)layerClass
{
    // 只有 [CAEAGLLayer class] 类型的 layer 才支持在其上描绘 OpenGL 内容。
    return [CAEAGLLayer class];
}

- (void)dealloc
{
    if (_vertext) {
        free(_vertext);
    }
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupLayer];
        [self setupContext];
        [self setupGLProgram];
        [self setupVertexData];
        [self setupVAO];
    }
    return self;
}

- (void)layoutSubviews
{
    [EAGLContext setCurrentContext:_context];
    
    [self destoryRenderAndFrameBuffer];
    
    [self setupFrameAndRenderBuffer];
    
    [self render];
}


#pragma mark - Setup
- (void)setupLayer
{
    _eaglLayer = (CAEAGLLayer*) self.layer;
    
    // CALayer 默认是透明的，必须将它设为不透明才能让其可见
    _eaglLayer.opaque = YES;
    
    // 设置描绘属性，在这里设置不维持渲染内容以及颜色格式为 RGBA8
    _eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
}

- (void)setupContext
{
    // 设置OpenGLES的版本为3.0
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    if (!_context) {
        NSLog(@"Failed to initialize OpenGLES 3.0 context");
        exit(1);
    }
    
    // 将当前上下文设置为我们创建的上下文
    if (![EAGLContext setCurrentContext:_context]) {
        NSLog(@"Failed to set current OpenGL context");
        exit(1);
    }
}

- (void)setupFrameAndRenderBuffer
{
    glGenRenderbuffers(1, &_colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    // 为 color renderbuffer 分配存储空间
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
    
    glGenFramebuffers(1, &_frameBuffer);
    // 设置为当前 framebuffer
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    // 将 _colorRenderBuffer 装配到 GL_COLOR_ATTACHMENT0 这个装配点上
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
                              GL_RENDERBUFFER, _colorRenderBuffer);
}

- (void)setupGLProgram
{
    NSString *vertFile = [[NSBundle mainBundle] pathForResource:@"vert.glsl" ofType:nil];
    NSString *fragFile = [[NSBundle mainBundle] pathForResource:@"frag.glsl" ofType:nil];
    _program = createGLProgramFromFile(vertFile.UTF8String, fragFile.UTF8String);
    
    glUseProgram(_program);
}

- (void)setupVertexData
{
    CGPoint p1 = CGPointMake(-0.8, 0);
    CGPoint p2 = CGPointMake(0.8, 0.2);
    CGPoint control = CGPointMake(0, -0.9);
    CGFloat deltaT = 0.01;
    
    _vertCount = 1.0/deltaT;
    _vertext = (Vertex *)malloc(sizeof(Vertex) * _vertCount);
    
    // t的范围[0,1]
    for (int i = 0; i < _vertCount; i++) {
        float t = i * deltaT;
        
        // 二次方计算公式
        float cx = (1-t)*(1-t)*p1.x + 2*t*(1-t)*control.x + t*t*p2.x;
        float cy = (1-t)*(1-t)*p1.y + 2*t*(1-t)*control.y + t*t*p2.y;
        _vertext[i] = (Vertex){cx, cy, 0.0, 1.0, 0.0, 0.0};
        
        printf("%f, %f\n",cx, cy);
    }
}


//顶点缓存VBO

//普通的顶点数组的传输，需要在绘制的时候频繁地从CPU到GPU传输顶点数据，这种做法效率低下，为了加快显示速度，显卡增加了一个扩展 VBO (Vertex Buffer object)，即顶点缓存。
//它直接在 GPU 中开辟一个缓存区域来存储顶点数据，因为它是用来缓存储顶点数据，因此被称之为顶点缓存。
//使用顶点缓存能够大大较少了CPU到GPU 之间的数据拷贝开销，因此显著地提升了程序运行的效率。


//注意：如果需要在OpenGL ES2.0上使用VAO，可以使用苹果扩展的相关的API，具体扩展如下：
//
//GLvoid glGenVertexArraysOES(GLsizei n, GLuint *arrays)
//GLvoid glBindVertexArrayOES(GLuint array);
//GLvoid glDeleteVertexArraysOES(GLsizei n, const GLuint *arrays);;
//GLboolean glIsVertexArrayOES(GLuint array);


- (void)setupVAO
{
//    顶点数组对象VAO
//
//    VAO的全名是Vertex ArrayObject。它不用作存储数据，但它与顶点绘制相关。
//    它的定位是状态对象，记录存储状态信息。
//    VAO记录的是一次绘制中做需要的信息，这包括数据在哪里、数据格式是什么等信息。
//    VAO其实可以看成一个容器，可以包括多个VBO。
//    由于它进一步将VBO容于其中，所以绘制效率将在VBO的基础上更进一步。
//    目前OpenGL ES3.0及以上才支持顶点数组对象。
    
    
    //创建顶点数组对象
    //参数 n ： 表示顶点数组对象的个数
    //参数 arrays ：顶点数组对象句柄
    glGenVertexArrays(1, &_vao);
    
    //将顶点数组对象设置为当前顶点数组对象
    glBindVertexArray(_vao);
    
    // VBO 生成顶点缓存对象 vertext buffer object
    GLuint vbo = createVBO(GL_ARRAY_BUFFER, GL_STATIC_DRAW, sizeof(Vertex) * (_vertCount + 1), _vertext);
    
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), NULL);
    
    glEnableVertexAttribArray(1);
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), NULL+sizeof(GLfloat)*3);
    
    glBindVertexArray(0);
    
    //      释放顶点数组对象
    //     glDeleteVertexArrays (GLsizei n, const GLuint* arrays);

}

#pragma mark - Clean
- (void)destoryRenderAndFrameBuffer
{
    glDeleteFramebuffers(1, &_frameBuffer);
    _frameBuffer = 0;
    glDeleteRenderbuffers(1, &_colorRenderBuffer);
    _colorRenderBuffer = 0;
}

#pragma mark - Render
- (void)render
{
    glClearColor(1.0, 1.0, 0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    glLineWidth(3.0);
    
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    
    // VAO
    //创建顶点数组对象VAO。通过VAO容易我们包裹了VBO和数组传递等操作，使用的时候只要激活当前的VAO便可以完成绘制，加快了绘制效率。
    glBindVertexArray(_vao);
    
    glDrawArrays(GL_LINE_STRIP, 0, _vertCount);
    
    //将指定 renderbuffer 呈现在屏幕上，在这里我们指定的是前面已经绑定为当前 renderbuffer 的那个，在 renderbuffer 可以被呈现之前，必须调用renderbufferStorage:fromDrawable: 为之分配存储空间。
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

@end

