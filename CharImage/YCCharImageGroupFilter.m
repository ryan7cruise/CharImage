//
//  YCCharImageGroupFilter.m
//  CharImage
//
//  Created by ycpeng on 2020/7/3.
//  Copyright © 2020 ycpeng. All rights reserved.
//

#import "YCCharImageGroupFilter.h"
#import "YCScaleGrayscaleFilter.h"
#import "YCCharImageFilter.h"

@implementation YCCharImageGroupFilter

- (instancetype)init
{
    self = [super init];
    if (self) {
        YCScaleGrayscaleFilter *grayFilter = [[YCScaleGrayscaleFilter alloc] init];
        grayFilter.scale = 0.1;
        
        YCCharImageFilter *charImageFilter = [[YCCharImageFilter alloc] init];
        
        [self addFilter:grayFilter];
        [self addFilter:charImageFilter];
        [grayFilter addTarget:charImageFilter atTextureLocation:1];
        
        self.initialFilters = @[grayFilter, charImageFilter];
        self.terminalFilter = charImageFilter;
    }
    return self;
}

@end
