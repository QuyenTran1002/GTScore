//
//  ViewController.m
//  GTScore
//
//  Created by Hai-Dang Dam on 2/26/19.
//  Copyright © 2019 Hai-Dang Dam. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)loginClicked:(id)sender {
    if (([_usernameTextfield.text isEqualToString:@"demo@gatech.edu"] && [_passwordTextfield.text isEqualToString:@"password"]) || ([_usernameTextfield.text isEqualToString:@"d"] && [_passwordTextfield.text isEqualToString:@"p"])) {
        [self performSegueWithIdentifier:@"LoginSucceed" sender:self];
    } else {
        UIAlertController *alertController = [[UIAlertController alloc] init];
        alertController.title = @"Error";
        alertController.message = @"Wrong username or password.";
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}


- (IBAction)registerClicked:(id)sender {
    
}

@end
