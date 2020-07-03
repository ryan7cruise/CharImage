//
//  ViewController.m
//  CharImage
//
//  Created by ycpeng on 2020/7/3.
//  Copyright © 2020 ycpeng. All rights reserved.
//

#import "ViewController.h"
#import <GPUImage/GPUImage.h>
#import "YCCharImageGroupFilter.h"

@interface ViewController ()

@property (nonatomic, strong) GPUImageView *preview;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    
    self.preview = [[GPUImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_preview];
    
    [self imageDemo];
}

- (void)imageDemo
{
    UIImage *image = [UIImage imageNamed:@"saber"];
    GPUImagePicture *pic = [[GPUImagePicture alloc] initWithImage:image];
    
    YCCharImageGroupFilter *filterGroup = [[YCCharImageGroupFilter alloc] init];
    
//    [filterGroup useNextFrameForImageCapture];
    
    [pic addTarget:filterGroup];
    [filterGroup addTarget:_preview];
    [pic processImage];
    
//    UIImage *result = [filterGroup imageFromCurrentFramebuffer];
//    
//    NSLog(@"finish");
}

@end
