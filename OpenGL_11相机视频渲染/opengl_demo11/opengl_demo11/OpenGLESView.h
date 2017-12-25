//
//  OpenGLESView.h
//  opengl_demo11
//
//  Created by LiYang on 2017/12/25.
//  Copyright © 2017年 LiYang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLTexture.h"
#import "GLRender.h"

@interface OpenGLESView : UIView

@property (nonatomic, strong) GLRender    *render;

- (void)setTexture:(GLTexture *)texture;

- (void)setNeedDraw;


@end
