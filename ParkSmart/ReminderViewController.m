//
//  ReminderViewController.m
//  ParkSmart
//
//  Created by Rao, Amit on 12/5/14.
//  Copyright (c) 2014 Rao, Amit. All rights reserved.
//

@import Photos;
#import "ReminderViewController.h"


@interface ReminderViewController () <UIActionSheetDelegate>

@property (nonatomic, weak) IBOutlet UIButton *photoBoxButton;
@property (nonatomic, weak) IBOutlet UILabel  *expiryTimeLabel;
@property (nonatomic, weak) IBOutlet UIButton *setReminderButton;

@property (nonatomic, strong) UIImagePickerController *mediaPicker;
@property (nonatomic, strong) UIImage *takenImage;
@property (nonatomic, weak) IBOutlet UIImageView *resultView;
@property (nonatomic, weak) IBOutlet UIButton *cameraButton;
@property (nonatomic, weak) IBOutlet UIDatePicker *expiryTimePicker;

@end

@implementation ReminderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.title = @"Reminder";
    self.cameraButton.hidden = YES;
    self.expiryTimePicker.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)handleSetReminderTap
{
    NSLog(@"Set Reminder Button tapped");
    self.expiryTimePicker.hidden = NO;
    
    UIDatePicker *datePicker = [[UIDatePicker alloc] init];
    datePicker.datePickerMode = UIDatePickerModeTime;
   
    [datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    
}


- (void) datePickerValueChanged : (id)sender
{
    
    
}


- (IBAction)TakePhoto:(id)sender
{
    self.mediaPicker = [[UIImagePickerController alloc] init];
    self.mediaPicker.delegate=self;
    self.mediaPicker.allowsEditing = YES;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:
                                      @"Take a photo or choose existing, and use the control to center the announce"
                                                                 delegate: self
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"Take photo", @"Choose Existing", nil];
        [actionSheet showInView:self.view];
    } else {
        self.mediaPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:self.mediaPicker animated:YES completion:nil];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(buttonIndex != actionSheet.cancelButtonIndex)
    {
        if (buttonIndex == 0) {
            self.mediaPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        } else if (buttonIndex == 1) {
            self.mediaPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        
        [self presentViewController:self.mediaPicker animated:YES completion:nil];
    }
    
    else [self dismissViewControllerAnimated:YES completion:nil];
    
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    //I take the coordinate of the cropping
    CGRect croppedRect=[[info objectForKey:UIImagePickerControllerCropRect] CGRectValue];
    
    UIImage *original=[info objectForKey:UIImagePickerControllerOriginalImage];
    
    
    CGImageRef ref= CGImageCreateWithImageInRect(original.CGImage, croppedRect);
    self.takenImage= [UIImage imageWithCGImage:ref];
    self.resultView.image=[self takenImage];
    
    self.photoBoxButton.enabled = NO;
    [self.photoBoxButton.imageView setHidden:YES];
    self.cameraButton.hidden = NO;
    
    
    
}




@end
