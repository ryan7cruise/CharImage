//
//  YCCharImageFilter.m
//  CharImage
//
//  Created by ycpeng on 2020/7/3.
//  Copyright © 2020 ycpeng. All rights reserved.
//

#import "YCCharImageFilter.h"
#import <GLKit/GLKTextureLoader.h>

NSString *const kYCCharImageFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate; // 纹理坐标
 varying highp vec2 textureCoordinate2; // 纹理坐标(未用到)

 uniform sampler2D inputImageTexture; //字符纹理
 uniform sampler2D inputImageTexture2; // 灰度值参考纹理

 uniform highp vec2 textureSize; // 原图尺寸
 
 void main()
 {
    // 像素点坐标
    highp vec2 coordinate = textureCoordinate * textureSize;
    
    // demo这里写死，可以根据实际情况调整
    highp float width = 10.0;
    // 计算width*width的区域的中点
    highp vec2 midCoor = min((floor(coordinate / width) * width + width * 0.5) / textureSize, 1.0);
    // 得到中点的亮度值
    lowp vec4 color = texture2D(inputImageTexture2, midCoor);
    // 一个字符的归一化纹理坐标
    coordinate = mod(coordinate, width) / width;
    // 为了节约性能，15个字符我们放在一个纹理上，需要根据灰度值进行x偏移
    coordinate.x = (floor(color.r * 14.0) + coordinate.x) / 15.0;
    
//    gl_FragColor = vec4(vec3(floor(color.r * 15.0) / 15.0), 1.0);
    
    gl_FragColor = texture2D(inputImageTexture, coordinate);
 }
);

@interface YCCharImageFilter ()
{
    GLint _textureSizeUniform;
}

@property (nonatomic, strong) GLKTextureInfo *textureInfo;

@end

@implementation YCCharImageFilter

- (instancetype)init
{
    self = [super initWithFragmentShaderFromString:kYCCharImageFragmentShaderString];
    if (self) {
        runSynchronouslyOnVideoProcessingQueue(^{
            [GPUImageContext useImageProcessingContext];
            
            self->_textureSizeUniform = [self->filterProgram uniformIndex:@"textureSize"];
            
            // 加载字符纹理
            NSString *texturePath = [[NSBundle mainBundle] pathForResource:@"all" ofType:@"jpg"];
            if (texturePath.length) {
                self.textureInfo = [GLKTextureLoader textureWithContentsOfFile:texturePath options:nil error:nil];
            }
        });
    }
    return self;
}

- (void)setInputSize:(CGSize)newSize atIndex:(NSInteger)textureIndex
{
    [super setInputSize:newSize atIndex:textureIndex];
    if (textureIndex == 0) {
        [self setSize:inputTextureSize forUniform:_textureSizeUniform program:filterProgram];
    }
}

#pragma mark - Rendering
- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates;
{
    if (self.preventRendering)
    {
        [firstInputFramebuffer unlock];
        [secondInputFramebuffer unlock];
        return;
    }
    
    [GPUImageContext setActiveShaderProgram:filterProgram];
    outputFramebuffer = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:[self sizeOfFBO] textureOptions:self.outputTextureOptions onlyTexture:NO];
    [outputFramebuffer activateFramebuffer];
    if (usingNextFrameForImageCapture)
    {
        [outputFramebuffer lock];
    }

    [self setUniformsForProgramAtIndex:0];
        
    glClearColor(backgroundColorRed, backgroundColorGreen, backgroundColorBlue, backgroundColorAlpha);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glActiveTexture(GL_TEXTURE3);
    glBindTexture(GL_TEXTURE_2D, [secondInputFramebuffer texture]);
    glUniform1i(filterInputTextureUniform2, 3);
    
    if (self.textureInfo) {
        glActiveTexture(GL_TEXTURE2);
        glBindTexture(GL_TEXTURE_2D, self.textureInfo.name);
        glUniform1i(filterInputTextureUniform, 2);
    }
    
    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
    glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    glVertexAttribPointer(filterSecondTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, [[self class] textureCoordinatesForRotation:inputRotation2]);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

    [firstInputFramebuffer unlock];
    [secondInputFramebuffer unlock];
    if (usingNextFrameForImageCapture)
    {
        dispatch_semaphore_signal(imageCaptureSemaphore);
    }
}

@end
