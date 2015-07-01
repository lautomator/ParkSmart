//
//  ImageViewController.m
//  ParkSmart
//
//  Created by Rao, Amit on 5/13/15.
//  Copyright (c) 2015 Rao, Amit. All rights reserved.
//

#import "ImageViewController.h"
#import "ImageScrollView.h"

@interface ImageViewController ()

@property (nonatomic, strong) ImageScrollView *imageScrollView;

@end

@implementation ImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIBarButtonItem* sendImageButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"mail-icon"] style:UIBarButtonItemStylePlain target:self action:@selector(sendImageButton:)];
    self.navigationItem.rightBarButtonItem = sendImageButton;


    ImageScrollView *scrollView = [[ImageScrollView alloc] init];
    [scrollView displayImage:self.image];
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view = scrollView;
    self.view.backgroundColor = [UIColor whiteColor];

}

- (void)sendImageButton:(id)sender
{
    NSLog(@"Send Image button tapped");
}

@end
