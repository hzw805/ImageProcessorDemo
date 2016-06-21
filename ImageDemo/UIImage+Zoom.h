//
//  UIImage+Zoom.h
//  ImageDemo
//
//  Created by hzw on 16/6/20.
//  Copyright © 2016年 John Huang. All rights reserved.
//

#import <UIKit/UIKit.h>

enum {
    enSvResizeScale,            // image scaled to fill
    enSvResizeAspectFit,        // image scaled to fit with fixed aspect. remainder is transparent
    enSvResizeAspectFill,       // image scaled to fill with fixed aspect. some portion of content may be cliped
};
typedef NSInteger SvResizeMode;

@interface UIImage (Zoom)
/*
 * @brief resizeImage
 * @param newsize the dimensions（pixel） of the output image
 */
- (UIImage*)resizeImageToSize:(CGSize)newSize resizeMode:(SvResizeMode)resizeMode;

@end
