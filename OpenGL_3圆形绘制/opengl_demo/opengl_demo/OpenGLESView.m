//
//  OpenGLESView.m
//  Opengl_1
//
//  Created by NicoLin on 2017/12/19.
//  Copyright © 2017年 NicoLin. All rights reserved.
//

#import "OpenGLESView.h"
#import <OpenGLES/ES2/gl.h>
#import "GLUtil.h"
typedef struct {
    GLfloat x,y,z;
    GLfloat r,g,b;
} Vertex;

@interface OpenGLESView()
{
    CAEAGLLayer * _eaglayer; // 当前图层的layer
    EAGLContext * _context; // 当前的绘图上下文
    GLuint        _colorRenderBuffer; //渲染缓存的标识
    GLuint        _frameBuffer; //帧缓存的标识
    GLuint        _program; //gl 管理程序
    
    GLint          _vertCount; //分割数
    
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
        [self setupGLProgram];
        
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

- (void)setupGLProgram {
    NSString *vertFile = [[NSBundle mainBundle] pathForResource:@"vert.glsl" ofType:nil];
    NSString *fragFile = [[NSBundle mainBundle] pathForResource:@"frag.glsl" ofType:nil];
    // 内部编译，链接，容错处理，创建着色器程序 并返回地址
    _program = createGLProgramFromFile(vertFile.UTF8String, fragFile.UTF8String);
    //使用着色器程序
    glUseProgram(_program);
}

- (void)setupVertexData {
        
    _vertCount = 200;//
    
    Vertex * vertext =  (Vertex*)malloc(sizeof(Vertex) * _vertCount);//申请100份结构体内存空间
    memset(vertext, 0x00, sizeof(Vertex)*_vertCount);//内存空间初始化为0x00;
    
    // 此处思维要转换，不能直接用正方形来想问题，要先从矩形来想问题，然后进行矫正，如果是矩形那么就是椭圆，有两个不同的半径。
    float a = 0.8;//水平方向的半径
    float b = a * self.frame.size.width / self.frame.size.height; //垂直方向的半径，没看懂
    
    //我们选择使用圆的三角函数表示方式*** f(x, y）= r * (cosθ, sinθ)*** 来计算圆上面每一点的坐标。(当然也可以根据公式 (x-a)(x-a) + (y-b)(y-b) = r*r** 计算圆上点的坐标，在此选择第一种方式)
//    1、分割。根据圆的方程θ取值范围[0 - 2*PI]进行等份分割，方便我们创建一定数量的顶点数据，之后我们便可用线段来代替曲线进行圆的绘制。
    float delta = 2.0*M_PI/_vertCount;
    for (int i = 0; i < _vertCount; i++) {
        GLfloat x = a * cos(delta * i);
        //坐标校正。由于我们屏幕宽高比并不为1，因此我们设置的半径0.8在水平和竖直方向对应的设备像素坐标并不相等。
//        因此，在绘制过程中我们必须校正水平和竖直方向的半径值，已达到看起来相等的效果。
        GLfloat y = b * sin(delta * i);
        GLfloat z = 0.0;
        vertext[i] = (Vertex){x, y, z, x, y, x+y};
        
        printf("%f , %f\n", x, y);
    }
    
    //着色器能否读取到数据，由是否启用了对应的属性决定，这就是glEnableVertexAttribArray的功能，允许顶点着色器读取GPU（服务器端）数据。
    glEnableVertexAttribArray(glGetAttribLocation(_program, "position"));
    glVertexAttribPointer(glGetAttribLocation(_program, "position"), 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), vertext);
    glEnableVertexAttribArray(glGetAttribLocation(_program, "color"));
    glVertexAttribPointer(glGetAttribLocation(_program, "color"), 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), vertext+sizeof(GLfloat)*3);
    
//    OpenGLES图元的绘制方式有GL_POINTS 、GL_LINES、 GL_LINE_LOOP 、GL_LINE_STRIP、GL_TRIANGLES 、GL_TRIANGLE_STRIP 、GL_TRIANGLE_FAN 这几种，每个都有自己独特的作用。在使用时根据自己的需求选择不同的绘制方式进行绘制。
    //GL_POINTS    点
//    GL_LINES    线段
//    GL_LINE_STRIP    多段线
//    GL_LINE_LOOP    线圈
//    GL_TRIANGLES    三角形
//    GL_TRIANGLE_STRIP    三角形条带
//    GL_TRIANGLE_FAN    三角形扇
    
    //GL_TRIANGLE_FAN 以(v0,v1,v2),(v0,v2,v3),(v0,v3,v4)的形式绘制三角形。
    //GL_TRIANGLE_STRIP 它是由最少3个点构成（正好3个点就是一个GL_TRIANGLES）每增加1个点，新增的点会和之前已有的两个点构成新的三角形，依次类推。（由于是圆形，效果并不明显）
    //GL_TRIANGLES 每三个顶之间绘制三角形，之间不连接。(由于是圆形，效果并不明显）
    //GL_POINTS 每个坐标就是一个点。
//    GL_LINE_STRIP 以(v0,v1),(v1,v2),(v2,v3),(v3,v4),(v4,v5)的形式绘制直线。
//    GL_LINE_LOOP以(v0,v1),(v1,v2),(v2,v3),(v3,v4),(v4,v5),(v5,v0)的形式绘制直线，比GL_LINE_STRIP多一条(v5,v0)的直线。
    //GL_LINES 以(v0,v1),(v2,v3),(v4,v5)的形式绘制直线。(当绘制的点只有两个时，GL_LINES与GL_LINE_STRIP绘线方式没有差异）

    
    
    glDrawArrays(GL_TRIANGLE_FAN, 0, _vertCount);

    free(vertext);
    vertext = NULL;
    
    //glVertexAttribPointer (GLuint indx, GLint size, GLenum type, GLboolean normalized, GLsizei stride, const GLvoid* ptr)
//    indx 指定要修改的顶点着色器中顶点变量id；
//    size 指定每个顶点属性的组件数量。必须为1、2、3或者4。
//    type 指定数组中每个组件的数据类型。可用的符号常量有GL_BYTE, GL_UNSIGNED_BYTE, GL_SHORT,GL_UNSIGNED_SHORT, GL_FIXED, 和 GL_FLOAT，初始值为GL_FLOAT；
//    normalized 指定当被访问时，固定点数据值是否应该被归一化（GL_TRUE）或者直接转换为固定点值（GL_FALSE）；
//    stride 指定连续顶点属性之间的偏移量。如果为0，那么顶点属性会被理解为：它们是紧密排列在一起的。初始值为0；
//    ptr 顶点数据指针。
    

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
    glClearColor(1.0, 1.0, 1.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    
    [self setupVertexData];
    
    //将指定 renderbuffer 呈现在屏幕上，在这里我们指定的是前面已经绑定为当前 renderbuffer 的那个，在 renderbuffer 可以被呈现之前，必须调用renderbufferStorage:fromDrawable: 为之分配存储空间。
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}


@end
