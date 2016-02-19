//
//  AnimationNavigationController.m
//  CustomNavigationController
//
//  Created by coder on 16/2/18.
//  Copyright © 2016年 coder. All rights reserved.
//

#define kDefaultAlpha 1.0
#define kDefaultScale 0.6
#define kTargetTranslateScale 0.55

#import "AnimationNavigationController.h"
#import "ViewController.h"
@interface AnimationNavigationController ()
@property (strong, nonatomic) UIImageView       *imageView;
@property (strong, nonatomic) UIView            *coverView;
@property (strong, nonatomic) NSMutableArray    *shots;
@end

@implementation AnimationNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.interactivePopGestureRecognizer.enabled = false;
    self.imageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.coverView = [[UIView alloc] initWithFrame:self.imageView.bounds];
    self.coverView.backgroundColor = [UIColor blackColor];
    self.shots = [NSMutableArray array];
    
    //添加手势
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
    [self.view addGestureRecognizer:panGesture];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}
//在跳转之前进行截图
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.viewControllers.count >= 1) {
        [self screenShot];
    }
    
    self.view.window.backgroundColor = [UIColor whiteColor];
    [super pushViewController:viewController animated:animated];
}

//截图
- (void)screenShot
{
    UIViewController *viewController = self.topViewController;//self.view.window.rootViewController;
    CGSize size = viewController.view.frame.size;
    UIGraphicsBeginImageContextWithOptions(size, YES, 0.0);
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    [viewController.view drawViewHierarchyInRect:rect afterScreenUpdates:NO];
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    [self.shots addObject:snapshot];
    UIGraphicsEndImageContext();
}

//手势
- (void)tapGestureAction:(UIPanGestureRecognizer *)sender
{
    if (self.topViewController == self.viewControllers[0]) {
        return;
    }
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self dragBegin];
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        [self draging:sender];
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        [self dragEnd];
    }
}

//开始拖拽
- (void)dragBegin {
    [self.view.window insertSubview:self.imageView atIndex:0];
    [self.view.window insertSubview:self.coverView aboveSubview:self.imageView];
    
    self.imageView.transform = CGAffineTransformMakeScale(kDefaultScale, kDefaultScale);
    self.imageView.image = [self.shots lastObject];
}

//正在拖拽
- (void)draging:(UIPanGestureRecognizer *)gesture
{
    CGFloat offsetX = [gesture translationInView:self.view].x;
    if (offsetX < 0) {
        offsetX = 0;
    }
    
    self.view.transform = CGAffineTransformMakeTranslation(offsetX, 0);
    CGFloat currentTranslateX = offsetX / self.view.frame.size.width;
    CGFloat scale = kDefaultScale + (currentTranslateX/kTargetTranslateScale) * (1 - kDefaultScale);
    CGFloat alpha = kDefaultAlpha - (currentTranslateX/kTargetTranslateScale) * kDefaultAlpha;
    
    scale = scale > 1.0 ? 1.0 : scale;
    self.imageView.transform = CGAffineTransformMakeScale(scale, scale);
    self.coverView.alpha = alpha;
    
}

//拖拽结束
- (void)dragEnd {
    
    CGFloat tx    = self.view.transform.tx;
    CGFloat width = CGRectGetWidth(self.view.frame);
    if (tx < width * 0.5) {
        [UIView animateWithDuration:0.15f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.view.transform = CGAffineTransformIdentity;
            self.imageView.transform = CGAffineTransformMakeScale(kDefaultScale, kDefaultScale);
        } completion:^(BOOL finished) {
            [self.coverView removeFromSuperview];
            [self.imageView removeFromSuperview];
        }];
    } else {
        
        self.view.transform = CGAffineTransformIdentity;
        [self.coverView removeFromSuperview];
        [self.imageView removeFromSuperview];
        [self.shots removeAllObjects];
        [self popViewControllerAnimated:NO];
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
