//
//  ViewController.m
//  CharImage
//
//  Created by ycpeng on 2020/7/3.
//  Copyright © 2020 ycpeng. All rights reserved.
//

#import "ViewController.h"
#import <GPUImage/GPUImage.h>
#import "YCScaleGrayscaleFilter.h"
#import "YCCharImageFilter.h"

@interface ViewController ()

@property (nonatomic, strong) GPUImageView *preview;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    
    self.preview = [[GPUImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_preview];
    
    UIImage *image = [UIImage imageNamed:@"saber"];
    GPUImagePicture *pic = [[GPUImagePicture alloc] initWithImage:image];
    
    YCScaleGrayscaleFilter *grayFilter = [[YCScaleGrayscaleFilter alloc] init];
    grayFilter.scale = 0.1;
    
    YCCharImageFilter *charImageFilter = [[YCCharImageFilter alloc] init];
    
    GPUImageFilterGroup *filterGroup = [[GPUImageFilterGroup alloc] init];
    [filterGroup addFilter:grayFilter];
    [filterGroup addFilter:charImageFilter];
    [grayFilter addTarget:charImageFilter atTextureLocation:1];
    filterGroup.initialFilters = @[grayFilter, charImageFilter];
    filterGroup.terminalFilter = charImageFilter;
    
    [filterGroup useNextFrameForImageCapture];
    
    [pic addTarget:filterGroup];
    [filterGroup addTarget:_preview];
    [pic processImage];
    
    UIImage *result = [filterGroup imageFromCurrentFramebuffer];
    
    NSLog(@"finish");
}

@end
