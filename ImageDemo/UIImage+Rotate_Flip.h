//
//  UIImage+Rotate_Flip.h
//  ImageDemo
//
//  Created by hzw on 16/6/20.
//  Copyright © 2016年 John Huang. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 * @brief 固定角度旋转图像 根据图像imageOrientation参数进行旋转  速度快
 *        任意角度旋转  灵活 牵扯到了实际的绘制和重新采样生成图片的过程
 */

enum {
    enSvCropClip,               // the image size will be equal to orignal image, some part of image may be cliped
    enSvCropExpand,             // the image size will expand to contain the whole image, remain area will be transparent
};
typedef NSInteger SvCropMode;


@interface UIImage (Rotate_Flip)
/*
 * @brief rotate image 90 withClockWise
 */
- (UIImage*)rotate90Clockwise;

/*
 * @brief rotate image 90 counterClockwise
 */
- (UIImage*)rotate90CounterClockwise;

/*
 * @brief rotate image 180 degree
 */
- (UIImage*)rotate180;

/*
 * @brief rotate image to default orientation
 */
- (UIImage*)rotateImageToOrientationUp;

/*
 * @brief flip horizontal
 */
- (UIImage*)flipHorizontal;

/*
 * @brief flip vertical
 */
- (UIImage*)flipVertical;

/*
 * @brief flip horizontal and vertical
 */
- (UIImage*)flipAll;

/*
 * @brief rotate image with radian
 */
- (UIImage*)rotateImageWithRadian:(CGFloat)radian cropMode:(SvCropMode)cropMode;

@end
