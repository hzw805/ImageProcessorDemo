//
//  ViewController.m
//  ImageDemo
//
//  Created by hzw on 16/6/17.
//  Copyright © 2016年 John Huang. All rights reserved.
//

#import "ViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "ImageProcessor.h"
#import "UIImage+OrientationFix.h"
#import "UIImage+Rotate_Flip.h"
#import "UIImage+Zoom.h"
#import "UIImage+Edit.h"
#import "ZWScrollViewController.h"
#import "ShowImageController.h"

#define IMAGE_FOLDER @"imageFolder"

#define OPERATEFORIMAGE 1

@interface ViewController ()<UIImagePickerControllerDelegate,  UINavigationControllerDelegate, ImageProcessorDelegate>
{
    UIImageView *pictureView;
    UIImage * workingImage;
    UIImage * orginalImage;
    
    NSMutableArray *imageArray;
    
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.title = @"图像处理";
    [self createSubViews];
    [self createImageFolderPath];
    [self loadImageData];
}


- (void)createSubViews
{
    if (!pictureView) {
        pictureView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 80, self.view.frame.size.width - 30, self.view.frame.size.height - 80)];
        pictureView.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:pictureView];
    }
    
}

- (void) alertAction:(NSString *)message
{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alertVC addAction:action];
    [self presentViewController:alertVC animated:YES completion:nil];
    
}


-(void)loadImageData{
    if (imageArray == nil) {
        imageArray = [NSMutableArray arrayWithCapacity:0];
    }
    for (int i=0; i<7; i++) {
        NSString *imageName = [NSString stringWithFormat:@"%d.jpg", i];
        [imageArray addObject:imageName];
        
    }
}


- (IBAction)loadPhotoAction:(UIBarButtonItem *)sender {
    [self LoadPhoto];
}
- (IBAction)photoRoteAction:(UIBarButtonItem *)sender {

    if (!workingImage) {
        [self alertAction:@"请先加载图片到浏览区域"];
    }
    else
    {
#if OPERATEFORIMAGE
        [self rotateForImage];
#else
        [self rotateForImageView];
#endif
    }
    
}


- (IBAction)photoScaleAction:(UIBarButtonItem *)sender {
    
    if (!workingImage) {
        [self alertAction:@"请先加载图片到浏览区域"];
    }
    else
    {
#if OPERATEFORIMAGE
        [self scaleForImage];
#else
        [self scaleForImageView];
#endif
    }
}

- (IBAction)savePhotoAction:(UIBarButtonItem *)sender {
    
    UIImage *image = pictureView.image;
    [self savePhoto:image imageName:@"0-0.png"];
    
}
- (IBAction)cropPhotoAction:(UIBarButtonItem *)sender {
    if(workingImage == nil)
    {
        [self alertAction:@"请先加载图片到浏览区域"];
    }
    else
    {
        [self cropForImage];
    }
}


- (IBAction)combinePhotoAction:(UIBarButtonItem *)sender {
//    workingImage = [[ImageProcessor sharedProcessor] combine:workingImage rightImage:orginalImage];
//    pictureView.image = workingImage;
    
    pictureView.image = [[ImageProcessor sharedProcessor] conCatImages:imageArray];
}


- (IBAction)resetAction:(UIBarButtonItem *)sender {
    pictureView.image = orginalImage;
    workingImage = orginalImage;
}
- (IBAction)lookImageAction:(UIBarButtonItem *)sender {
    
    if(workingImage == nil)
    {
        [self alertAction:@"请先加载图片到浏览区域"];
    }
    else
    {
        ZWScrollViewController *nextVC = [[ZWScrollViewController alloc] init];
        nextVC.targetImage = workingImage;
        [self.navigationController pushViewController:nextVC animated:YES];
    }
}

- (IBAction)playImageAction:(UIBarButtonItem *)sender {
    ShowImageController *nextVC = [[ShowImageController alloc] init];
    [self.navigationController pushViewController:nextVC animated:YES];
}

#pragma mark - 相机相关方法
// 照相机拍照
- (void) takePhoto
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        picker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        picker.allowsEditing = YES;
        // 显示视图控制器
        [self presentViewController:picker animated:YES completion:nil];
    }
    else
    {
        NSLog(@"模拟器无法打开摄像头，请在真机中测试");
    }
}

// 本地加载照片
- (void) LoadPhoto
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    picker.allowsEditing = YES;
    [self presentViewController:picker animated:YES completion:nil];
}

// 照片回调
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    if ([type isEqualToString:(NSString *)kUTTypeImage])
    {
        UIImage *image = nil;
        if (picker.allowsEditing) {
            image = [info objectForKey:UIImagePickerControllerEditedImage];
        }
        else
        {
            image = [info objectForKey:UIImagePickerControllerOriginalImage];
        }
        
        pictureView.alpha = 1.0;
        [self setupWithImage:image];

        [picker dismissViewControllerAnimated:YES completion:nil];
        
    }
}

// 释放控制器
- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 文件相关操作
// 设置保存路径
- (void)createImageFolderPath
{
    NSString *folderPath = [self imageFolderPath];
    BOOL isDir = NO;
    BOOL isDirExist = [[NSFileManager defaultManager] fileExistsAtPath:folderPath isDirectory:&isDir];
    
    if(!(isDirExist && isDir))
    {
        BOOL bCreateDir = [[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
        if(!bCreateDir){
            NSLog(@"创建imageFolder失败");
        }
    }
}

- (NSString *)imageFolderPath
{
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:IMAGE_FOLDER];
}

- (void)savePhoto:(UIImage *)image imageName:(NSString *)imageName
{
    NSString *imagePath = [[self imageFolderPath] stringByAppendingPathComponent:imageName];
    NSData *imageData = UIImagePNGRepresentation(image);
    [imageData writeToFile:imagePath atomically:YES];
}

#pragma mark - ImageProcessor图像处理相关操作

- (void)setupWithImage:(UIImage*)image {
    UIImage * fixedImage = [image imageWithFixedOrientation];
    workingImage = fixedImage;
    
    // Commence with processing!
    [ImageProcessor sharedProcessor].delegate = self;
    [[ImageProcessor sharedProcessor] processImage:fixedImage];
}

#pragma mark - ImageProcessorDelegate

- (void)imageProcessorFinishedProcessingWithImage:(UIImage *)outputImage {
    workingImage = outputImage;
    orginalImage = outputImage;
    pictureView.image = outputImage;
}

#pragma mark - 对Image做各种CGAffineTransform变化
- (void)rotateForImage
{
        workingImage = [workingImage rotate90Clockwise];
//        workingImage = [workingImage rotateImageWithRadian:90 cropMode:enSvCropClip];
        pictureView.image = workingImage;
}

- (void)scaleForImage
{
    workingImage = [workingImage resizeImageToSize:CGSizeMake(workingImage.size.width*1.5, workingImage.size.height*1.5) resizeMode:enSvResizeAspectFill];
    
    pictureView.image = workingImage;
}

- (void)translateForImage
{
    
}

- (void)cropForImage
{
    // 矩形区域剪裁
    workingImage = [workingImage cropImageWithRect:CGRectMake(20, 20, workingImage.size.width - 40, workingImage.size.height - 40)];
    
    
    // 任意形状剪裁
//    CGPoint point1 = CGPointMake(50, 50);
//    CGPoint point2 = CGPointMake(500, 400);
//    CGPoint point3 = CGPointMake(50, 400);
//    NSArray *pathArray = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:point1],[NSValue valueWithCGPoint:point2],[NSValue valueWithCGPoint:point3], nil];
//    workingImage = [workingImage cropImageWithPath:pathArray];
    
    pictureView.image = workingImage;
    
}
#pragma mark - 对ImageView做各种CGAffineTransform变化
- (void)rotateForImageView
{
    [self animationDuration:0.5 animations:^{
        CGFloat angle=M_PI_4;
        pictureView.transform = CGAffineTransformRotate(pictureView.transform, angle);
    }];
}

- (void)scaleForImageView
{
    //通常我们使用UIView的静态方法实现动画而不是自己写一个方法
    [UIView animateWithDuration:0.5 animations:^{
        CGFloat scalleOffset = 0.9;
        pictureView.transform= CGAffineTransformScale(pictureView.transform, scalleOffset, scalleOffset);
    }];
}

- (void)traslateForImageView
{
    [self animationDuration:0.5 animations:^{
        CGFloat translateY = 50;
        pictureView.transform = CGAffineTransformTranslate(pictureView.transform, 0, translateY);
    }];
}

// 自定义动画方法
- (void)animationDuration:(NSTimeInterval)duration animations:(void (^)(void))animations
{
    [UIView beginAnimations:@"animation" context:nil];
    [UIView setAnimationDuration:duration];
    animations();
    [UIView commitAnimations];
}
@end


