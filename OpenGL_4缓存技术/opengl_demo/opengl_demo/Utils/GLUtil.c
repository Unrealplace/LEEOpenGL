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
//    创建顶点缓存对象
    //参数 n ： 表示需要创建顶点缓存对象的个数
    //参数 buffers ：用于存储创建好的顶点缓存对象句柄
    glGenBuffers(1, &vbo);
    
    //将顶点缓存对象设置为当前数组缓存对象
    //参数 target ：指定绑定的目标，取值为 GL_ARRAY_BUFFER（用于顶点数据） 或 GL_ELEMENT_ARRAY_BUFFER（用于索引数据）
//    参数 buffer ：顶点缓存对象句柄
    glBindBuffer(target, vbo);
    //为顶点缓存对象分配空间
//    参数 target：与 glBindBuffer 中的参数 target 相同；
//    参数 size ：指定顶点缓存区的大小，以字节为单位计数；
//    参数 data ：用于初始化顶点缓存区的数据，可以为 NULL，表示只分配空间，之后再由 glBufferSubData 进行初始化；
//    参数 usage ：表示该缓存区域将会被如何使用，它的主要目的是用于对该缓存区域做何种程度的优化，比如经常修改的数据可能就会放在GPU缓存中达到快速操作的目的。
    
    glBufferData(target, datSize, data, usage);
    
    
//    |参数|解释|
//    |:---:|:---:|
//    |GL_STATIC_DRAW|表示该缓存区不会被修改|
//    |GL_DYNAMIC_DRAW|表示该缓存区会被周期性更改|
//    |GL_STREAM_DRAW|表示该缓存区会被频繁更改|
    
    
//    更新顶点缓冲区数据
//    参数 offset: 表示需要更新的数据的起始偏移量；
//    参数 size: 表示需要更新的数据的个数，也是以字节为计数单位；
//    参数 data: 用于更新的数据；
//    void glBufferSubData (GLenum target, GLintptr offset, GLsizeiptr size, const GLvoid* data);
    
    
//    释放顶点缓存
//    参数 n ： 表示顶点缓存对象的个数
//    参数 buffers ：顶点缓存对象句柄
//    void glDeleteBuffers (GLsizei n, const GLuint* buffers);
    
    return vbo;
}

GLuint createTexture2D(GLenum format, int width, int height, void *data)
{
    GLuint texture;
    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexImage2D(GL_TEXTURE_2D, 0, format, width, height, 0, format, GL_UNSIGNED_BYTE, data);
    glBindTexture(GL_TEXTURE_2D, 0);
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
