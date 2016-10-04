//
//  SampleViewController.m
//  SABlurImageViewSample
//
//  Created by 鈴木大貴 on 2016/10/05.
//  Copyright © 2016年 鈴木大貴. All rights reserved.
//

#import "SampleViewController.h"
#import <SABlurImageView/SABlurImageView-Swift.h>

@interface SampleViewController ()

@property (weak, nonatomic, nullable) IBOutlet UISlider *slide;
@property (strong, nonatomic, nullable) SABlurImageView *imageView;

@end

@implementation SampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    UIGraphicsBeginImageContextWithOptions(self.view.frame.size, NO, 1.0f);
    [self.view.window drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.imageView = [[SABlurImageView alloc] initWithImage:image];
    [self.imageView configrationForBlurAnimation:100.0f];
    [self.view insertSubview:self.imageView belowSubview:self.slide];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didChangeSliderValue:(UISlider *)sender {
    [self.imageView blur:(CGFloat)sender.value];
}

@end
