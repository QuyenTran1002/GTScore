//
//  AddContactActionViewController.m
//  GTScore
//
//  Created by Hai-Dang Dam on 4/14/19.
//  Copyright © 2019 Hai-Dang Dam. All rights reserved.
//

#import "AddContactActionViewController.h"
#import <CommonCrypto/CommonHMAC.h>

@import Firebase;
@interface AddContactActionViewController ()
@property (weak, nonatomic) IBOutlet UITextField *Message;
@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (weak, nonatomic) NSString *userID;
@property (weak, nonatomic) NSString *userEmail;

@end

@implementation AddContactActionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _ref = [[FIRDatabase database] reference];
    [self.Message setDelegate:self];
    self.userID = [FIRAuth auth].currentUser.uid;
    self.userEmail = [FIRAuth auth].currentUser.email;
    // Do any additional setup after loading the view.
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)sendFriendReqeust:(id)sender {
    NSDictionary<NSString *, NSString *> *message = @{@"senderID" : _userID, @"senderName" : _name, @"email" : self.userEmail, @"status" : @"received", @"message":_Message.text};
    [[[[self.ref child:@"FriendRequests"]child:self.data[@"uid"]] child:[self sha256HashFor:_Message.text]] setValue:message withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
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
