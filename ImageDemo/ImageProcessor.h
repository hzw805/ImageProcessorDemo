//
//  ImageProcessor.h
//  SpookCam
//
//  Created by Jack Wu on 2/21/2014.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol ImageProcessorDelegate <NSObject>

- (void)imageProcessorFinishedProcessingWithImage:(UIImage*)outputImage;

@end

@interface ImageProcessor : NSObject

@property (weak, nonatomic) id<ImageProcessorDelegate> delegate;

+ (instancetype)sharedProcessor;

- (void)processImage:(UIImage*)inputImage;
- (UIImage *)combine:(UIImage*)leftImage rightImage:(UIImage*)rightImage ;
- (UIImage *)conCatImages:(NSMutableArray *)images;
@end
