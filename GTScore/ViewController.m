//
//  ViewController.m
//  GTScore
//
//  Created by Hai-Dang Dam on 2/26/19.
//  Copyright © 2019 Hai-Dang Dam. All rights reserved.
//

#import "ViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
@import Firebase;

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;
@property (strong, nonatomic) FIRUser *user;
@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
    // Optional: Place the button in the center of your view.
    loginButton.center = self.view.center;
    loginButton.delegate = self;
    loginButton.readPermissions = @[@"public_profile", @"email"];
    [self.view addSubview:loginButton];
    if ([FBSDKAccessToken currentAccessToken]) {
        [self performSegueWithIdentifier:@"LoginSucceed" sender:self];
    }
    [self.usernameTextfield setDelegate:self];
    [self.passwordTextfield setDelegate:self];
    // Do any additional setup after loading the view, typically from a nib.
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)loginClicked:(id)sender {
    NSLog(@"%@", self.usernameTextfield.text);
    NSLog(@"%@", self.passwordTextfield.text);
    if ([_usernameTextfield.text length] == 0 || [_passwordTextfield.text length] < 5) {
        UIAlertController *alertController = [[UIAlertController alloc] init];
        alertController.title = @"Error";
        alertController.message = @"Not correct format email and password";
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        [[FIRAuth auth] signInWithEmail:self.usernameTextfield.text password:self.passwordTextfield.text completion:^(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable error) {
            if (error) {
                UIAlertController *alertController = [[UIAlertController alloc] init];
                alertController.title = @"Error";
                alertController.message = [error localizedDescription];
                [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                [self presentViewController:alertController animated:YES completion:nil];
            } else {
                NSLog(@"%@ sign in success", authResult.user.email);
                [self performSegueWithIdentifier:@"LoginSucceed" sender:self];
            }
        }];
    }
    /*
    if (([_usernameTextfield.text isEqualToString:@"demo"] && [_passwordTextfield.text isEqualToString:@"password"]) || ([_usernameTextfield.text isEqualToString:@"d"] && [_passwordTextfield.text isEqualToString:@"p"])) {
        [self performSegueWithIdentifier:@"LoginSucceed" sender:self];
    } else {
        UIAlertController *alertController = [[UIAlertController alloc] init];
        alertController.title = @"Error";
        alertController.message = @"Wrong username or password.";
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
     */
}

- (void)loginButton:(FBSDKLoginButton *)loginButton
didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result
              error:(NSError *)error {
    if (error == nil) {
        FIRAuthCredential *credential = [FIRFacebookAuthProvider
                                         credentialWithAccessToken:[FBSDKAccessToken currentAccessToken].tokenString];
        [[FIRAuth auth] signInAndRetrieveDataWithCredential:credential
                                                 completion:^(FIRAuthDataResult * _Nullable authResult,
                                                              NSError * _Nullable error) {
                                                     if (error) {
                                                         // ...
                                                         NSLog(error.localizedDescription);
                                                         return;
                                                     }
                                                     // User successfully signed in. Get user data from the FIRUser object
                                                     if (authResult == nil) { return; }
                                                     _user = authResult.user;
                                                     FIRAdditionalUserInfo *info = authResult.additionalUserInfo;
                                                     if (info.isNewUser) {
                                                         [FBSDKProfile loadCurrentProfileWithCompletion:^(FBSDKProfile *profile, NSError *error) {
                                                             if (profile) {
                                                                 NSDictionary *userInfo = @{@"name" : profile.name, @"email" : _user.email, @"uid" : _user.uid, @"num_wins":@0};
                                                                 [[[[[FIRDatabase database] reference] child:@"Users"] child:authResult.user.uid] setValue:userInfo];
                                                                 
                                                             }
                                                         }];
                                                     }
                                                     [self performSegueWithIdentifier:@"LoginSucceed" sender:self];
                                                 }];
    } else {
        NSLog(error.localizedDescription);
    }
}


- (IBAction)registerClicked:(id)sender {
    
}

@end
