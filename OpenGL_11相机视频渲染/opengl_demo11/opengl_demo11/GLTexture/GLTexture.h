//
//  GLTexture.h
//  opengl_demo11
//
//  Created by NicoLin on 2017/12/25.
//  Copyright © 2017年 LiYang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GLTexture : NSObject
@property (nonatomic, assign) int    width;
@property (nonatomic, assign) int     height;
@end

@interface GLTextureRGB : GLTexture
@property (nonatomic, assign) uint8_t    *RGBA;

@end

@interface GLTextureYUV :GLTexture
@property (nonatomic, assign) uint8_t    *Y;
@property (nonatomic, assign) uint8_t    *U;
@property (nonatomic, assign) uint8_t    *V;

@end
