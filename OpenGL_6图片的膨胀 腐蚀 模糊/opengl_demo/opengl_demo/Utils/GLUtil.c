//
//  GLUtil.c
//  GLKit
//
//  Created by qinmin on 2017/1/4.
//  Copyright © 2017年 qinmin. All rights reserved.
//

#include "GLUtil.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

long getFileContent(char *buffer, long len, const char *filePath)
{
    FILE *file = fopen(filePath, "rb");
    if (file == NULL) {
        return -1;
    }
    
    fseek(file, 0, SEEK_END);
    long size = ftell(file);
    rewind(file);
    
    if (len < size) {
        GLlog("file is large than the size(%ld) you give\n", len);
        return -1;
    }
    
    fread(buffer, 1, size, file);
    buffer[size] = '\0';
    
    fclose(file);
    
    return size;
}

static GLuint createGLShader(const char *shaderText, GLenum shaderType)
{
    GLuint shader = glCreateShader(shaderType);
    glShaderSource(shader, 1, &shaderText, NULL);
    glCompileShader(shader);
    
    int compiled = 0;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &compiled);
    if (!compiled) {
        GLint infoLen = 0;
        glGetShaderiv (shader, GL_INFO_LOG_LENGTH, &infoLen);
        if (infoLen > 1) {
            char *infoLog = (char *)malloc(sizeof(char) * infoLen);
            if (infoLog) {
                glGetShaderInfoLog (shader, infoLen, NULL, infoLog);
                GLlog("Error compiling shader: %s\n", infoLog);
                free(infoLog);
            }
        }
        glDeleteShader(shader);
        return 0;
    }
    
    return shader;
}

GLuint createGLProgram(const char *vertext, const char *frag)
{
    GLuint program = glCreateProgram();
    
    GLuint vertShader = createGLShader(vertext, GL_VERTEX_SHADER);
    GLuint fragShader = createGLShader(frag, GL_FRAGMENT_SHADER);
    
    if (vertShader == 0 || fragShader == 0) {
        return 0;
    }
    
    glAttachShader(program, vertShader);
    glAttachShader(program, fragShader);
    
    glLinkProgram(program);
    GLint success;
    glGetProgramiv(program, GL_LINK_STATUS, &success);
    if (!success) {
        GLint infoLen;
        glGetProgramiv(program, GL_INFO_LOG_LENGTH, &infoLen);
        if (infoLen > 1) {
            GLchar *infoText = (GLchar *)malloc(sizeof(GLchar)*infoLen + 1);
            if (infoText) {
                memset(infoText, 0x00, sizeof(GLchar)*infoLen + 1);
                glGetProgramInfoLog(program, infoLen, NULL, infoText);
                GLlog("%s", infoText);
                free(infoText);
            }
        }
        glDeleteShader(vertShader);
        glDeleteShader(fragShader);
        glDeleteProgram(program);
        return 0;
    }
    
    glDetachShader(program, vertShader);
    glDetachShader(program, fragShader);
    glDeleteShader(vertShader);
    glDeleteShader(fragShader);
    
    return program;
}

GLuint createGLProgramFromFile(const char *vertextPath, const char *fragPath)
{
    char vBuffer[2048] = {0};
    char fBuffer[2048] = {0};
    
    if (getFileContent(vBuffer, sizeof(vBuffer), vertextPath) < 0) {
        return 0;
    }
    
    if (getFileContent(fBuffer, sizeof(fBuffer), fragPath) < 0) {
        return 0;
    }
    
    return createGLProgram(vBuffer, fBuffer);
}

GLuint createVBO(GLenum target, int usage, int datSize, void *data)
{
    GLuint vbo;
    glGenBuffers(1, &vbo);
    glBindBuffer(target, vbo);
    glBufferData(target, datSize, data, usage);
    return vbo;
}

GLuint createTexture2D(GLenum format, int width, int height, void *data)
{
    //纹理坐标在x和y轴上，范围为0到1之间（当然也可以大于1）。
//    使用纹理坐标获取纹理颜色叫做采样(Sampling)。
//    纹理坐标起始于(0, 0)，也就是纹理图片的左下角，终始于(1, 1)，即纹理图片的右上角。
    GLuint texture;

    
//    生成纹理
//
//    和之前生成的VBO、VAO对象一样，纹理生成也类似之前缓存对象的生成，生成步骤也相差无几。
//    参数 n ： 表示需要创建纹理对象的个数
//    参数 textures ：用于存储创建好的纹理对象句柄
    glGenTextures(1, &texture);
    
    
//    将纹理对象设置为当前纹理对象
//    void  glBindTexture (GLenum target, GLuint texture);
//    参数 target ：指定绑定的目标
//    参数 texture ：纹理对象句柄
    glBindTexture(GL_TEXTURE_2D, texture);
    
    //纹理过滤
    
//    纹理坐标不依赖于分辨率，它可以是任意浮点值，所以OpenGL ES需要知道怎样将纹理像素映射到纹理坐标。
//    OpenGL ES默认的纹理过滤方式是邻近过滤。
    
    
//    |纹理过滤 | 描述|总结|
//    |:---:|:---:|:---:|:---:|
//    |GL_LINEAR 线性过滤| 它会基于纹理坐标附近的纹理像素，计算出一个插值，近似出这些纹理像素之间的颜色。一个纹理像素的中心距离纹理坐标越近，那么这个纹理像素的颜色对最终的样本颜色的贡献越大 | GL_LINEAR能够产生更平滑的图案，很难看出单个的纹理像素。
//    |GL_NEAREST 邻近过滤|当设置为GL_NEAREST的时候，会选择中心点最接近纹理坐标的那个像素。|GL_NEAREST产生了颗粒状的图案，我们能够清晰看到组成纹理的像素|
    
    

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    
    //    环绕方式(Wrapping)    描述
    //    GL_REPEAT    对纹理的默认行为，重复纹理图像。
    //    GL_MIRRORED_REPEAT    和GL_REPEAT一样，但每次重复图片是镜像放置的。
    //    GL_CLAMP_TO_EDGE    纹理坐标会被约束在0到1之间，超出的部分会重复纹理坐标的边缘，产生一种边缘被拉伸的效果。
    //    GL_CLAMP_TO_BORDER    超出的坐标为用户指定的边缘颜色。
    //
    //我们可以使用glTexParameter*函数对单独的一个坐标轴设置（二维纹理为s、t坐标，三维纹理为s、t、r坐标）
    // GL_APIENTRY glTexParameteri (GLenum target, GLenum pname, GLint param);
    //    参数 target：纹理目标是；
    //    参数 pname ：指定坐标轴S轴、T轴、R轴；
    //    参数 param ：环绕方式；
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

    
    
    
//    指定纹理
//    void glTexImage2D (GLenum target, GLint level, GLint internalformat, GLsizei width, GLsizei height, GLint border, GLenum format, GLenum type, const GLvoid* pixels);
//    参数 target ：指定纹理单元的类型，二维纹理需要指定为GL_TEXTURE_2D
//    参数 level：指定纹理单元的层次，非mipmap纹理level设置为0，mipmap纹理设置为纹理的层级
//    参数 internalFormat：指定OpenGL ES是如何管理纹理单元中数据格式的
//    参数 width：指定纹理单元的宽度
//    参数 height：指定纹理单元的高度
//    参数 border：指定纹理单元的边框，如果包含边框取值为1，不包含边框取值为0
//    参数 format：指定data所指向的数据的格式
//    参数 type：指定data所指向的数据的类型
//    参数 data：实际指向的数据
    
    
    glTexImage2D(GL_TEXTURE_2D, 0, format, width, height, 0, format, GL_UNSIGNED_BYTE, data);
    glBindTexture(GL_TEXTURE_2D, 0);
    
    // 激活纹理单元在外面使用
    return texture;
}

GLuint createVAO(void(*setting)())
{
    GLuint vao;
    glGenVertexArrays(1, &vao);
    glBindVertexArray(vao);
    if (setting) {
        setting();
    }
    glBindVertexArray(0);
    return vao;
}
