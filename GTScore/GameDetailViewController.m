//
//  GameDetailViewController.m
//  GTScore
//
//  Created by Hai-Dang Dam on 2/26/19.
//  Copyright © 2019 Hai-Dang Dam. All rights reserved.
//

#import "GameDetailViewController.h"
@import Firebase;

@interface GameDetailViewController ()
@property (weak, nonatomic) NSString *userID;
@property (weak, nonatomic) NSDictionary<NSString *, NSString *> *matchScoreLine;
@property (strong, nonatomic) FIRDatabaseReference *ref;
@end

@implementation GameDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _userID = [FIRAuth auth].currentUser.uid;
    _matchScoreLine = self.data[@"Scores"];
    NSArray<NSString *> *players = [_matchScoreLine allKeys];
    NSString *playerA = players[0];
    NSString *playerB = players[1];
    self.playerALabel.text = playerA;
    self.playerBLabel.text = playerB;
    self.playerAScore.text = _matchScoreLine[playerA];
    self.playerBScore.text = _matchScoreLine[playerB];
    [self.playerAStepper setValue: [_matchScoreLine[playerA] doubleValue]];
    [self.playerBStepper setValue:[_matchScoreLine[playerB] doubleValue]];
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
        [_matchScoreLine setValue:self.playerAScore.text forKey:self.playerALabel.text];
        [_matchScoreLine setValue:self.playerBScore.text forKey:self.playerBLabel.text];
        [[[[[[self.ref child:@"Users"]child:_userID] child:@"Matches"] child:_data[@"Identifier"]] child:@"Scores"] setValue:_matchScoreLine withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
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
        if (_data[@"Other Player"] != nil && [_data[@"Other Player"] length] != 0) {
            [[[[[[self.ref child:@"Users"]child:_data[@"Other Player"]] child:@"Matches"] child:_data[@"Identifier"]] child:@"Scores"] setValue:_matchScoreLine withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
                if (error) {
                    NSLog(@"Data could not be saved: %@", error);
                } else {
                    NSLog(@"Data saved successfully.");
                }
            }];
        }
    }
    
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

@end
