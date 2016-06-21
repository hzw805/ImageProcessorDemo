//
//  UIImage+CovertToPixel.m
//  ImageDemo
//
//  Created by hzw on 16/6/20.
//  Copyright © 2016年 John Huang. All rights reserved.
//

#import "UIImage+CovertToPixel.h"

@implementation UIImage (CovertToPixel)

/*完成获取像素需要以下四步:

　　a、申请图像大小的内存。

　　b、使用CGBitmapContextCreate方法创建画布。

　　c、使用UIImage的draw方法绘制图像到画布中。

　　d、使用CGBitmapContextGetData方法获取画布对应的像素数据。
*/

// 从UIImage获取像素
- (BOOL)getImageData:(void**)data width:(NSInteger*)width height:(NSInteger*)height alphaInfo:(CGImageAlphaInfo*)alphaInfo
{
    int imgWidth = self.size.width * self.scale;
    int imgHegiht = self.size.height * self.scale;
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    if (colorspace == NULL) {
        NSLog(@"Create Colorspace Error!");
        return NO;
    }
    
    void *imgData = NULL;
    imgData = malloc(imgWidth * imgHegiht * 4);
    if (imgData == NULL) {
        NSLog(@"Memory Error!");
        return NO;
    }
    
    CGContextRef bmpContext = CGBitmapContextCreate(imgData, imgWidth, imgHegiht, 8, imgWidth * 4, colorspace, kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(bmpContext, CGRectMake(0, 0, imgWidth, imgHegiht), self.CGImage);
    
    *data = CGBitmapContextGetData(bmpContext);
    *width = imgWidth;
    *height = imgHegiht;
    *alphaInfo = kCGImageAlphaLast;
    
    CGColorSpaceRelease(colorspace);
    CGContextRelease(bmpContext);
    
    return YES;
}


// 从像素创建UIImage
+ (UIImage*)createImageWithData:(Byte*)data width:(NSInteger)width height:(NSInteger)height alphaInfo:(CGImageAlphaInfo)alphaInfo
{
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    if (!colorSpaceRef) {
        NSLog(@"Create ColorSpace Error!");
    }
    CGContextRef bitmapContext = CGBitmapContextCreate(data, width, height, 8, width * 4, colorSpaceRef, kCGImageAlphaPremultipliedLast);
    if (!bitmapContext) {
        NSLog(@"Create Bitmap context Error!");
        CGColorSpaceRelease(colorSpaceRef);
        return nil;
    }
    
    CGImageRef imageRef = CGBitmapContextCreateImage(bitmapContext);
    UIImage *image = [[UIImage alloc] initWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    CGColorSpaceRelease(colorSpaceRef);
    CGContextRelease(bitmapContext);
    
    return image;
}

@end
