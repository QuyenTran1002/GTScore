//
//  RegisterViewController.m
//  GTScore
//
//  Created by Hai-Dang Dam on 3/4/19.
//  Copyright © 2019 Hai-Dang Dam. All rights reserved.
//

#import "RegisterViewController.h"
@import Firebase;

@interface RegisterViewController ()
@property (strong, nonatomic) FIRDatabaseReference *ref;
@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.ref = [[FIRDatabase database] reference];
    // Do any additional setup after loading the view.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)signUp:(id)sender {
    if ([_userEmail.text length] == 0 || [_userPassword.text length] < 5) {
        UIAlertController *alertController = [[UIAlertController alloc] init];
        alertController.title = @"Error";
        alertController.message = @"Not correct format email and password";
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        [[FIRAuth auth] createUserWithEmail:_userEmail.text password:_userPassword.text completion:^(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable error) {
            if (error) {
                UIAlertController *alertController = [[UIAlertController alloc] init];
                alertController.title = @"Error";
                alertController.message = [error localizedDescription];
                [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                [self presentViewController:alertController animated:YES completion:nil];
            } else {
                NSDictionary *userInfo = @{@"name" : _userName.text, @"email" : _userEmail.text, @"uid" : authResult.user.uid};
                [[[_ref child:@"Users"] child:authResult.user.uid] setValue:userInfo];
                NSLog(@"%@ created", authResult.user.email);
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
    }
}

@end
