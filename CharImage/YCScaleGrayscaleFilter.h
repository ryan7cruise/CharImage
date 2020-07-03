//
//  YCScaleGrayGrayscaleFilter.h
//  CharImage
//
//  Created by ycpeng on 2020/7/3.
//  Copyright © 2020 ycpeng. All rights reserved.
//

#import <GPUImage/GPUImageFilter.h>

NS_ASSUME_NONNULL_BEGIN

@interface YCScaleGrayscaleFilter : GPUImageFilter

@property (nonatomic, assign) CGFloat scale;

@end

NS_ASSUME_NONNULL_END
