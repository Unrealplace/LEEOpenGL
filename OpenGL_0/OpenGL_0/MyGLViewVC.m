//
//  MyGLViewVC.m
//  OpenGL_0
//
//  Created by NicoLin on 2017/12/4.
//  Copyright © 2017年 NicoLin. All rights reserved.
//

#import "MyGLViewVC.h"
// 三角形顶点数据
static GLfloat vertex[6] = {
    -1,-1,// 左下
    -1,1, // 左上
    1,1  // 右上
};
@interface MyGLViewVC () {
    
    GLint _program;
    GLuint vertShader, fragShader;
    int _vertexcolor;
    GLuint  _vertexBuffer;
    GLKView *view;
    
}

@property (nonatomic ,strong)EAGLContext *eagcontext;

@end

@implementation MyGLViewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createEagContext];
    [self configure];
    [self compileShader];
    [self linkShader];
    [self getColor];
    [self loadVertex];
    [self glkView:view drawInRect:CGRectMake(0, 0, 375, 667)];
    
   
    
}

// MARK: - 创建一个EAGContext
-(void)createEagContext{
    self.eagcontext = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:self.eagcontext];
}

// MARK: - 配置GLKView
-(void)configure{
    view = (GLKView*)self.view;
    view.context = self.eagcontext;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
}

- (BOOL)compileShader {
    // 1.创建标示
    // 2.获取文件路径
    NSString *vertShaderPathname, *fragShaderPathname;
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"vertor" ofType:@"vsh"];
    // 3.编译
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        NSLog(@"编译失败 vertex shader");
        return NO;
    }
    
    // 创建 编译 片断着色器
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"frgment" ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    _program = glCreateProgram();
    // 第九步 将顶点着色器加到程序中
    glAttachShader(_program, vertShader);
    
    // 将片断着色器加到程序中
    glAttachShader(_program, fragShader);
    // 绑定着色器的属性
    glBindAttribLocation(_program, 0, "position");  // 0代表枚举位置
    
    return YES;
    
}

- (BOOL)linkShader {
    if (![self linkProgram:_program]) {
        NSLog(@"Failed to link program: %d", _program);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_program) {
            glDeleteProgram(_program);
            _program = 0;
        }
        
        return NO;
    }
    return YES;
}

- (void)getColor {
    _vertexcolor = glGetUniformLocation(_program, "color");

}

// 加载数据，具体的参数说明暂时不写了，后面会专门讲
-(void)loadVertex{
    glGenBuffers(1, &_vertexBuffer); // 申请内存标识
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);// 绑定
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertex), vertex, GL_STATIC_DRAW);// 申请内存空间
    glEnableVertexAttribArray(GLKVertexAttribPosition);// 开启顶点数据
    // 设置指针
    glVertexAttribPointer(GLKVertexAttribPosition,
                          2,
                          GL_FLOAT,
                          GL_FALSE,
                          8,
                          0);
}
-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    static NSInteger count = 0;
    // 清除颜色缓冲区
    glClearColor(1, 1, 1, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    count ++;
    if (count > 50 ) {
        count = 0;
        // 根据颜色索引值,设置颜色数据，就是刚才我们从着色器程序中获取的颜色索引值
        glUniform4f(_vertexcolor,   arc4random_uniform(255)/225.0, arc4random_uniform(255)/225.0, arc4random_uniform(255)/225.0, 1);
    }
    // 使用着色器程序
    glUseProgram(_program);
    // 绘制
    glDrawArrays(GL_TRIANGLES, 0, 3);
}


- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    
    //1  获取文件的内容 并进行NSUTF8StringEncoding 编码
    const GLchar *source;
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    //2 根据类型创建着色器
    *shader = glCreateShader(type);
    //3. 获取着色器的数据源
    glShaderSource(*shader, 1, &source, NULL);
    //4. 开始编译
    glCompileShader(*shader);
    // 方便调试，可以不用
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    //5. 查看是否编译成功
    GLint status;
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}
- (BOOL)linkProgram:(GLuint)prog
{
    // 1链接程序
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    // 2 检查链接结果
    GLint status;
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    return YES;
    
}

@end
