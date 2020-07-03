//
//  YCScaleGrayGrayscaleFilter.m
//  CharImage
//
//  Created by ycpeng on 2020/7/3.
//  Copyright © 2020 ycpeng. All rights reserved.
//

#import "YCScaleGrayscaleFilter.h"
#import <GPUImage/GPUImage.h>

@implementation YCScaleGrayscaleFilter

#pragma mark -
#pragma mark Initialization and teardown

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kGPUImageLuminanceFragmentShaderString]))
    {
        return nil;
    }
    
    return self;
}

- (void)setInputSize:(CGSize)newSize atIndex:(NSInteger)textureIndex;
{
    CGSize scaledSize = CGSizeMake((int)(newSize.width * self.scale),
                                   (int)(newSize.height * self.scale));
    [super setInputSize:scaledSize atIndex:textureIndex];
}

@end
