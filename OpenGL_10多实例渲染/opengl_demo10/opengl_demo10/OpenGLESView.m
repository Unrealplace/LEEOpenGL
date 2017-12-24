//
//  OpenGLESView.m
//  opengl_demo10
//
//  Created by LiYang on 2017/12/24.
//  Copyright © 2017年 LiYang. All rights reserved.
//

#import "OpenGLESView.h"
#import <OpenGLES/ES3/gl.h>
#import "GLUtil.h"
#import "JpegUtil.h"
@interface OpenGLESView ()
{
    CAEAGLLayer     * _eaglLayer;
    EAGLContext     * _context;
    GLuint                 _colorRenderBuffer;
    GLuint                _frameBuffer;
    
    GLuint               _program;
    GLuint              _vbo;
    GLuint              _offsetVBO;
    GLuint             _texture;
    int                   _vertCount;
    
}
@end
@implementation OpenGLESView

+ (Class)layerClass {
    return [CAEAGLLayer class];
}
- (void)dealloc {
    glDeleteBuffers(1, &_vbo);
    glDeleteBuffers(1, &_offsetVBO);
    glDeleteTextures(1, &_texture);
    glDeleteProgram(_program);
    
}
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupLayer];
        [self setupContext];
        [self setupGLProgram];
        [self setupOffset];
        [self setupVBO];
        [self setupTexure];
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
- (void)setupLayer {
    _eaglLayer  = (CAEAGLLayer*)self.layer;
    
    _eaglLayer.opaque = YES;
    
    _eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],kEAGLDrawablePropertyRetainedBacking,kEAGLColorFormatRGBA8 ,kEAGLDrawablePropertyColorFormat,nil];
    
}

- (void)setupContext {
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!_context) {
        exit(1);
    }
    if (![EAGLContext setCurrentContext:_context]) {
        exit(1);
    }
    
}

- (void)setupFrameAndRenderBuffer {
    glGenRenderbuffers(1, &_colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
    
    glGenFramebuffers(1, &_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderBuffer);
    
    
}

- (void)setupGLProgram
{
    NSString *vertFile = [[NSBundle mainBundle] pathForResource:@"vert.glsl" ofType:nil];
    NSString *fragFile = [[NSBundle mainBundle] pathForResource:@"frag.glsl" ofType:nil];
    
    _program = createGLProgramFromFile(vertFile.UTF8String, fragFile.UTF8String);
    glUseProgram(_program);
}

- (void)setupVBO {
    _vertCount = 6;
    
    GLfloat vertices[] = {
        -0.5f,  1.0f, 0.0f, 1.0f, 0.0f,   // 右上
        -0.5f,  0.5f, 0.0f, 1.0f, 1.0f,   // 右下
        -1.0f,  0.5f, 0.0f, 0.0f, 1.0f,  // 左下
        -1.0f,  0.5f, 0.0f, 0.0f, 1.0f,  // 左下
        -1.0f,  1.0f, 0.0f, 0.0f, 0.0f,  // 左上
        -0.5f,  1.0f, 0.0f, 1.0f, 0.0f,   // 右上
    };
    
    // 创建VBO
    _vbo = createVBO(GL_ARRAY_BUFFER, GL_STATIC_DRAW, sizeof(vertices), vertices);
    
    glEnableVertexAttribArray(glGetAttribLocation(_program, "position"));
    glVertexAttribPointer(glGetAttribLocation(_program, "position"), 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, NULL);
    
    glEnableVertexAttribArray(glGetAttribLocation(_program, "texcoord"));
    glVertexAttribPointer(glGetAttribLocation(_program, "texcoord"), 2, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*5, NULL+sizeof(GL_FLOAT)*3);
    
    
}

//
//设置偏移量。
//偏移量和普通的顶点数据一样可以使用VBO来存储。
//我们希望每次绘制顶点数组都发生一定的偏移，总共发生三次偏移（gl_Position = vec4(position+offset, 1.0)）。
//这样我们总共需要9个GLfloat的空间来存储偏移数据。


- (void)setupOffset {
    GLfloat vertices[] = {
        0.1f, -0.1f, 0.0f,
        0.6f, -0.5f, 0.0f,
        1.3f, -1.3f, 0.0f,
    };
    
    // 创建VBO
    _offsetVBO = createVBO(GL_ARRAY_BUFFER, GL_STATIC_DRAW, sizeof(vertices), vertices);
    
    glEnableVertexAttribArray(glGetAttribLocation(_program, "offset"));
    glVertexAttribPointer(glGetAttribLocation(_program, "offset"), 3, GL_FLOAT, GL_FALSE, 0, NULL);
    
}

- (void)setupTexure
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"wood" ofType:@"jpg"];
    
    unsigned char *data;
    int size;
    int width;
    int height;
    
    // 加载纹理
    if (read_jpeg_file(path.UTF8String, &data, &size, &width, &height) < 0) {
        printf("%s\n", "decode fail");
    }
    
    // 创建纹理
    _texture = createTexture2D(GL_RGB, width, height, data);
    
    if (data) {
        free(data);
        data = NULL;
    }
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
    glClearColor(1.0, 1.0, 1.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    
    // 激活纹理
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _texture);
    glUniform1i(glGetUniformLocation(_program, "image"), 0);
    
    // 每次绘制之后，对offset进行1个偏移
    glVertexAttribDivisor(glGetAttribLocation(_program, "offset"), 1);
    
//    实例化（instancing）或者多实例渲染（instancd rendering）是一种连续执行多条相同渲染命令的方法。
//    并且每个命令的所产生的渲染结果都会有轻微的差异。是一种非常有效的，实用少量api调用来渲染大量几何体的方法。OpenGL提供多种机制，允许着色器对不同渲染实例赋予不同的顶点属性。
    
   
//    参数 mode ：绘制方式，例如：GL_POINTS、GL_LINES。
//    参数 first ：从数组缓存中的哪一位开始绘制，一般为0。
//    参数 count ：数组中顶点的数量。
//    参数 instancecount ：该参数用于设置渲染实例个数。
    
//    void glDrawArraysInstanced (GLenum mode, GLint first, GLsizei count, GLsizei instancecount)

    glDrawArraysInstanced(GL_TRIANGLES, 0, _vertCount, 3);
    
    //将指定 renderbuffer 呈现在屏幕上，在这里我们指定的是前面已经绑定为当前 renderbuffer 的那个，在 renderbuffer 可以被呈现之前，必须调用renderbufferStorage:fromDrawable: 为之分配存储空间。
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}


//由于上述API都是OpenGL ES 3.0的相关API，因此如果在OpenGL ES 2.0想实现相同的效果，我们可以用苹果的OpenGL ES 2.0的扩展API。OpenGL ES 2.0的扩展都在glext.h中，区别就是API加了EXT、APPLE、OES等后缀。比如多实例渲染OpenGL ES 2.0的扩展API为 glVertexAttribDivisorEXT、 glDrawArraysInstancedEXT、glDrawElementsInstancedEXT




@end
