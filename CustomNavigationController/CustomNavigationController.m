//
//  CustomNavigationController.m
//  CustomNavigationController
//
//  Created by coder on 16/2/19.
//  Copyright © 2016年 coder. All rights reserved.
//
#define kDefaultScale  0.7
#define kDefaultAlpha  1.0
#define kTagerTranslation 0.55

#import "CustomNavigationController.h"

@interface CustomNavigationController ()
@property (strong, nonatomic) UIView          *coverView;
@property (strong, nonatomic) UIImageView     *imageView;
@property (strong, nonatomic) NSMutableArray  *screenShots;
@end

@implementation CustomNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.interactivePopGestureRecognizer.enabled = false;
    self.coverView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.coverView.backgroundColor = [UIColor blackColor];
    self.imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    self.screenShots = [NSMutableArray array];
    
    [self.view addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)]];
}

//跳转之前截取屏幕
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.viewControllers.count >= 1) {
        [self screenShot];
    }
    self.view.window.backgroundColor = [UIColor whiteColor];
    [super pushViewController:viewController animated:animated];
}

//截屏
- (void)screenShot
{
    //获取最顶层的控制器 也就是自己
    UIViewController *viewController = self.view.window.rootViewController;
    CGSize size = viewController.view.bounds.size;
    //开始截屏前的参数设置
    UIGraphicsBeginImageContextWithOptions(size, YES, 0.0);
    //设置截取区域 并进行截屏
    [viewController.view drawViewHierarchyInRect:CGRectMake(0, 0, size.width, size.height) afterScreenUpdates:NO];
    //获取截屏
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    [self.screenShots addObject:image];
    //关闭截屏资源
    UIGraphicsEndImageContext();
}


//手势
- (void)panGestureAction:(UIPanGestureRecognizer *)pan
{
    //如果当前最顶层的控制器是自己 则不让其进行偏移
    if (self.topViewController == self.viewControllers[0]) {
        return;
    }
    if (pan.state == UIGestureRecognizerStateBegan) {
        [self dragBegin];
    } else if (pan.state == UIGestureRecognizerStateChanged) {
        [self draging:pan];
    } else if (pan.state == UIGestureRecognizerStateEnded) {
        [self dragEnd];
    }
}

- (void)dragBegin
{
    //添加截屏
    self.imageView.transform = CGAffineTransformMakeScale(kDefaultScale, kDefaultScale);
    self.imageView.image = [self.screenShots lastObject];
    [self.view.window insertSubview:self.imageView atIndex:0];
    //将蒙板添加到截屏图片上面
    [self.view.window insertSubview:self.coverView aboveSubview:self.imageView];
    
}

- (void)draging:(UIPanGestureRecognizer *)pan
{
    //获取偏移量
    CGFloat tx = [pan translationInView:self.view].x;
    tx = tx > 0 ? tx : 0;
    //设置偏移
    self.view.transform = CGAffineTransformMakeTranslation(tx, 0);
    
    CGFloat offsetX = tx / CGRectGetWidth(self.view.frame);
    
    CGFloat alpha = kDefaultAlpha - (offsetX/kTagerTranslation) * kDefaultAlpha;
    CGFloat scale = kDefaultScale + (offsetX/kTagerTranslation) * (1 - kDefaultScale);
    scale = scale > 1.0 ? 1.0 : scale;
    
    self.imageView.transform = CGAffineTransformMakeScale(scale, scale);
    self.coverView.alpha = alpha;
}

- (void)dragEnd
{
    CGFloat offsetX = self.view.transform.tx;
    CGFloat width   = CGRectGetWidth(self.view.frame);
    if (offsetX < width * 0.5) {
        [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.view.transform = CGAffineTransformIdentity;
            self.imageView.transform = CGAffineTransformMakeScale(kDefaultScale, kDefaultScale);
        } completion:^(BOOL finished) {
            [self.imageView removeFromSuperview];
            [self.coverView removeFromSuperview];
        }];
    } else {
        self.view.transform = CGAffineTransformIdentity;
        [self.imageView removeFromSuperview];
        [self.coverView removeFromSuperview];
        [self.screenShots removeAllObjects];
        [self popViewControllerAnimated:NO];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
