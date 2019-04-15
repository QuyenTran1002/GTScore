//
//  SendInvitationViewController.m
//  GTScore
//
//  Created by Hai-Dang Dam on 4/14/19.
//  Copyright © 2019 Hai-Dang Dam. All rights reserved.
//

#import "SendInvitationViewController.h"
@import Firebase;
#import <CommonCrypto/CommonHMAC.h>

@interface SendInvitationViewController ()
@property (weak, nonatomic) IBOutlet UITextField *gameName;
@property (weak, nonatomic) IBOutlet UITextField *message;
@property (weak, nonatomic) IBOutlet UITextField *location;
@property (weak, nonatomic) IBOutlet UIDatePicker *date;
@property (strong, nonatomic) FIRDatabaseReference *ref;

@end

@implementation SendInvitationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"SendInvitationViewController got data: %@", self.data);
    _ref = [[FIRDatabase database] reference];
    [self.message setDelegate:self];
    [self.location setDelegate:self];
    [self.gameName setDelegate:self];
}

- (void)viewDidAppear:(BOOL)animated {
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)send:(id)sender {
    NSDictionary<NSString *, NSString *> *message = @{@"address" : _location.text, @"message" : _message.text, @"title" : _gameName.text, @"sender" : _name, @"date" : [self getCurrentDate], @"time" : [self getTime]};
    [[[[self.ref child:@"Notifications"]child:self.data[@"uid"]] child:[self sha256HashFor:_gameName.text]] setValue:message withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        if (error) {
            NSLog(@"Data could not be saved: %@", error);
            UIAlertController *alertController = [[UIAlertController alloc] init];
            alertController.title = @"Error";
            alertController.message = [error description];
            [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alertController animated:YES completion:nil];
        } else {
            NSLog(@"Data saved successfully.");
        }
    }];
}

- (NSString *) getCurrentDate {
    NSDate *todayDate = [_date date]; //Get todays date
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init]; // here we create NSDateFormatter object for change the Format of date.
    [dateFormatter setDateFormat:@"dd/MM/yyyy"]; //Here we can set the format which we need
    NSString *convertedDateString = [dateFormatter stringFromDate:todayDate];// Here convert date in NSString
    return convertedDateString;
}

- (NSString *) getTime {
    NSDate * now = [_date date];
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"HH:mm:ss"];
    NSString *newDateString = [outputFormatter stringFromDate:now];
    NSLog(@"newDateString %@", newDateString);
    return newDateString;
}
- (NSString*) sha256HashFor:(NSString*)input
{
    const char* str = [input UTF8String];
    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(str, strlen(str), result);
    
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH*2];
    for(int i = 0; i<CC_SHA256_DIGEST_LENGTH; i++)
    {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
