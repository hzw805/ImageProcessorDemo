//
//  UIImage+Edit.h
//  ImageDemo
//
//  Created by hzw on 16/6/20.
//  Copyright © 2016年 John Huang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Edit)
/*
 * @brief crop image with rect area
 */
- (UIImage*)cropImageWithRect:(CGRect)cropRect;

/*
 * @brief crop image with path
 */
- (UIImage*)cropImageWithPath:(NSArray*)pointArr;
@end
