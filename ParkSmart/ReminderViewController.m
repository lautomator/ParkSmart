//
//  ReminderViewController.m
//  ParkSmart
//
//  Created by Rao, Amit on 12/5/14.
//  Copyright (c) 2014 Rao, Amit. All rights reserved.
//

@import Photos;
#import "ImageProcessingProtocol.h"
#import "ImageProcessingImplementation.h"
#import "ImageLocationManager.h"
#import "ImageViewController.h"
#import "ReminderManager.h"
#import "ReminderViewController.h"
#import "StringParser.h"
#import "UIImage+operation.h"



const NSInteger kReminderInterval = 15; //15 min reminder

@interface ReminderViewController () <UIActionSheetDelegate>

@property (nonatomic, weak) IBOutlet UIButton *photoBoxButton;
@property (nonatomic, weak) IBOutlet UILabel  *expiryTimeLabel;

@property (nonatomic, strong) UIImagePickerController *mediaPicker;
@property (nonatomic, strong) UIImage *takenImage;
@property (nonatomic, weak) IBOutlet UIImageView *resultView;
@property (nonatomic, weak) IBOutlet UIButton *cameraButton;
@property (nonatomic, weak) IBOutlet UIDatePicker *expiryTimePicker;

@property (strong, nonatomic) id <ImageProcessingProtocol> imageProcessor;

@property (strong, nonatomic) NSString* ocrString;


@end

@implementation ReminderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.imageProcessor= [[ImageProcessingImplementation alloc]  init];
    
    self.title = @"Reminder";
    self.cameraButton.hidden = YES;
    self.expiryTimePicker.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

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

- (IBAction)takePhoto:(id)sender
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


- (IBAction)photoBoxButtonTapped:(id)sender
{
    if(!self.takenImage)
    {
        [self takePhoto:sender];
    }
    else
    {
        self.photoBoxButton.imageView.image = [self takenImage];
        [self displayParkingStubImage];
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
    else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *rotatedCorrectly;
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    //I take the coordinate of the cropping
    CGRect croppedRect=[[info objectForKey:UIImagePickerControllerCropRect] CGRectValue];
    
    UIImage *original=[info objectForKey:UIImagePickerControllerOriginalImage];
    
    if (original.imageOrientation != UIImageOrientationUp){
        rotatedCorrectly=[original rotate:original.imageOrientation];
    }
    else {
        rotatedCorrectly=original;
    }

    // Save image in the iPhone photo library
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        UIImageWriteToSavedPhotosAlbum(original, nil,nil,nil);
    }
    
    CGImageRef ref= CGImageCreateWithImageInRect(rotatedCorrectly.CGImage, croppedRect);
    self.takenImage= [UIImage imageWithCGImage:ref];
    self.resultView.image=[self takenImage];


    self.photoBoxButton.enabled = YES;
    [self.photoBoxButton.imageView setHidden:NO];
    self.cameraButton.hidden = NO;


    [self OCR:nil];

    NSData *originalImgData = [[ImageLocationManager sharedInstance] getImageWithMetaData:self.takenImage];
    //NSLog(@"IMAGE EXIF DATA %@", originalImgData);

    [[ImageLocationManager sharedInstance] processImageEXIFData:originalImgData];

}

- (void)displayParkingStubImage
{
    NSLog(@"Display parking stub");
    ImageViewController *imageViewController = [[ImageViewController alloc] init];
    [imageViewController setImage:[self takenImage]];

    [self.navigationController pushViewController:imageViewController animated:YES];
}



- (IBAction)OCR:(id)sender {
    
    self.ocrString = [self.imageProcessor OCRImage:self.takenImage];

    NSLog(@"ocr string = %@:",self.ocrString);

    NSString *expiryTimeString = [StringParser expiryDateFromString:self.ocrString];
    
    NSLog(@"parking expires at : %@", expiryTimeString);

    if(expiryTimeString)
    {
        self.expiryTimeLabel.text = expiryTimeString;
        
        [[ReminderManager sharedInstance] setReminder:expiryTimeString Before:kReminderInterval];
    }
    
}





@end
