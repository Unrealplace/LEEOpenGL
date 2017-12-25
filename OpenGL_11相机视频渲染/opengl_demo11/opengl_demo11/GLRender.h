//
//  GLRender.h
//  opengl_demo11
//
//  Created by NicoLin on 2017/12/25.
//  Copyright © 2017年 LiYang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLUtil.h"
#import "GLTexture.h"

/**
 该类主要用来处理 YUV 图片数据 和 RGBA 图片数据的渲染过程
 
 */
@interface GLRender : NSObject

@property (nonatomic, assign)GLuint  program;

@property (nonatomic, assign)GLuint  vertextVBO;

@property (nonatomic, assign)int     vertextCount;


/**
 设置 纹理

 @param texture 纹理对象
 */
- (void)setupTexture:(GLTexture*)texture;


/**
 准备渲染
 */
- (void)prepareRender ;


@end


/**
 处理RGB 数据
 */
@interface GLRenderRGB : GLRender

@property (nonatomic, assign)GLuint rgb;

@end


/**
 处理YUV 数据
 */
@interface GLRenderYUV : GLRender

@property (nonatomic, assign)GLuint y;

@property (nonatomic, assign)GLuint u;

@property (nonatomic, assign)GLuint v;

@end
