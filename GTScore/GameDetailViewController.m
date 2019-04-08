//
//  GameDetailViewController.m
//  GTScore
//
//  Created by Hai-Dang Dam on 2/26/19.
//  Copyright © 2019 Hai-Dang Dam. All rights reserved.
//

#import "GameDetailViewController.h"
@import Firebase;
#import <CommonCrypto/CommonHMAC.h>

@interface GameDetailViewController ()
@property (weak, nonatomic) NSString *userID;
@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (weak, nonatomic) IBOutlet UITextField *gameNameField;
@end

@implementation GameDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _userID = [FIRAuth auth].currentUser.uid;
    [self.playerAStepper setValue: 0];
    [self.playerBStepper setValue:0];
    _ref = [[FIRDatabase database] reference];
}

- (IBAction)reportScore:(id)sender {
    if ([self.playerAScore.text length] == 0 || [self.playerBScore.text length] == 0) {
        UIAlertController *alertController = [[UIAlertController alloc] init];
        alertController.title = @"Error";
        alertController.message = @"Not input score to field";
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        NSMutableDictionary<NSString*, NSString*> *matchScoreLine = [[NSMutableDictionary alloc] init];
        [matchScoreLine setValue:self.playerAScore.text forKey:self.playerALabel.text];
        [matchScoreLine setValue:self.playerBScore.text forKey:self.playerBLabel.text];
        NSString *identifier = [self sha256HashFor:self.gameNameField.text];
        [[[[[self.ref child:@"Users"]child:_userID] child:@"Matches"] child:identifier] setValue:matchScoreLine withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
            if (error) {
                NSLog(@"Data could not be saved: %@", error);
                UIAlertController *alertController = [[UIAlertController alloc] init];
                alertController.title = @"Error";
                alertController.message = [error description];
                [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                [self presentViewController:alertController animated:YES completion:nil];
            } else {
                NSLog(@"Data saved successfully.");
                UINavigationController *navigationController = self.navigationController;
                [navigationController popViewControllerAnimated:YES];
            }
        }];
        /*
        if (_data[@"Other Player"] != nil && [_data[@"Other Player"] length] != 0) {
            [[[[[[self.ref child:@"Users"]child:_data[@"Other Player"]] child:@"Matches"] child:_data[@"Identifier"]] child:@"Scores"] setValue:_matchScoreLine withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
                if (error) {
                    NSLog(@"Data could not be saved: %@", error);
                } else {
                    NSLog(@"Data saved successfully.");
                }
            }];
        }
         */
    }
    
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
- (IBAction)stepperScorePlayerAChanged:(id)sender {
    UIStepper *stepper = (UIStepper *)sender;
    if (stepper.value < 0) {
        stepper.value = 0;
    }
    NSInteger score = (NSInteger) stepper.value;
    NSLog([NSString stringWithFormat:@"%d", score]);
    _playerAScore.text = [NSString stringWithFormat:@"%d", score];
}

- (IBAction)stepperScorePlayerBChanged:(id)sender {
    UIStepper *stepper = (UIStepper *)sender;
    if (stepper.value < 0) {
        stepper.value = 0;
    }
    NSInteger score = (NSInteger) stepper.value;
    NSLog([NSString stringWithFormat:@"%d", score]);
    _playerBScore.text = [NSString stringWithFormat:@"%d", score];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



- (IBAction)gameField:(id)sender {
}
- (IBAction)nameGameField:(id)sender {
}
@end
