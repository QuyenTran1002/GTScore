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
@property (weak, nonatomic) NSString *friendID;
@property (weak, nonatomic) IBOutlet UILabel *gameNameField;
@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) NSMutableDictionary<NSString *, NSObject *> *match;
@property (weak, nonatomic) IBOutlet UILabel *player1Name;
@property (weak, nonatomic) IBOutlet UILabel *player2Name;
@end

@implementation GameDetailViewController
static BOOL haveShown;

+ (void) setHaveShown:(BOOL) value {
    haveShown = value;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _userID = [FIRAuth auth].currentUser.uid;
    _ref = [[FIRDatabase database] reference];
    [self.playerAStepper setValue: 0];
    [self.playerBStepper setValue:0];
    [self configureDatabase];
}

- (IBAction)reportScore:(id)sender {
    if ([self.playerAScore.text length] == 0 || [self.playerBScore.text length] == 0) {
        UIAlertController *alertController = [[UIAlertController alloc] init];
        alertController.title = @"Error";
        alertController.message = @"Not input score to field";
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        NSString *matchID = [NSString stringWithFormat:@"%@",[_match valueForKey:@"matchID"]];
        [_match setValue:[NSNumber numberWithDouble:_playerAStepper.value] forKey:@"score1"];
        [_match setValue:[NSNumber numberWithDouble:_playerBStepper.value] forKey:@"score2"];
        [_match setValue:@true forKey:@"played"];
        if ([[NSString stringWithFormat:@"%@",[_match valueForKey:@"player1ID"]] isEqualToString: _userID]) {
            _friendID = [NSString stringWithFormat:@"%@",[_match valueForKey:@"player2ID"]];
        } else {
            _friendID = [NSString stringWithFormat:@"%@",[_match valueForKey:@"player1ID"]];
        }
        [[[[[self.ref child:@"Users"]child:_userID] child:@"games"] child:matchID] setValue:_match withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
            if (error) {
                NSLog(@"Data could not be saved: %@", error);
                UIAlertController *alertController = [[UIAlertController alloc] init];
                alertController.title = @"Error";
                alertController.message = [error description];
                [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                [self presentViewController:alertController animated:YES completion:nil];
            } else {
                NSLog(@"First Data saved successfully.");
                
                
            }
        }];
        [[[[[self.ref child:@"Users"]child:_userID] child:@"matches"] child:matchID] removeValue];
        
        [[[[[self.ref child:@"Users"]child:_friendID] child:@"games"] child:matchID] setValue:_match withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
            if (error) {
                NSLog(@"Data could not be saved: %@", error);
                UIAlertController *alertController = [[UIAlertController alloc] init];
                alertController.title = @"Error";
                alertController.message = [error description];
                [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                [self presentViewController:alertController animated:YES completion:nil];
            } else {
                NSLog(@"Second Data saved successfully.");
            }
        }];
        [[[[[self.ref child:@"Users"]child:_friendID] child:@"matches"] child:matchID] removeValue];
        haveShown = true;
    }
    
}

- (void) configureDatabase {
    _ref = [[FIRDatabase database] reference];
    
    [[[[_ref child:@"Users"] child:self.userID] child:@"matches"] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSLog(@"changed 1: %@", snapshot);
        if (![snapshot.value isEqual:[NSNull null]]) {
            NSDictionary<NSString *, NSDictionary*> *value = snapshot.value;
            NSString *key = [value allKeys][0];
            [self loadMatch:key];
           
        } else {
            if (!haveShown) {
                UIAlertController *alertController = [[UIAlertController alloc] init];
                alertController.title = @"Error";
                alertController.message = @"You have no ongoing match";
                [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                [self presentViewController:alertController animated:YES completion:nil];
            }
        }
    }];
}

- (void) loadMatch:(NSString *) key {
    _ref = [[FIRDatabase database] reference];
    [[[[[_ref child:@"Users"] child:self.userID] child:@"games"] child:key] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSLog(@"changed: %@", snapshot);
        if (snapshot != nil) {
            _match = snapshot.value;
            [self loadMatchToComponent:_match];
            
        } else {
            UIAlertController *alertController = [[UIAlertController alloc] init];
            alertController.title = @"Error";
            alertController.message = @"You have no ongoing match";
            [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }];
}


- (void) loadMatchToComponent:(NSDictionary *) dictionary {
    _gameNameField.text = [NSString stringWithFormat:@"%@",[dictionary valueForKey:@"name"]];
    _player1Name.text = [NSString stringWithFormat:@"%@",[dictionary valueForKey:@"player1Name"]];
    _player2Name.text = [NSString stringWithFormat:@"%@",[dictionary valueForKey:@"player2Name"]];
    [self.playerAStepper setValue: [(NSNumber*) [dictionary valueForKey:@"score1"] doubleValue]];
    [self.playerBStepper setValue: [(NSNumber*) [dictionary valueForKey:@"score2"] doubleValue]];
    _playerAScore.text = [NSString stringWithFormat:@"%d", 0];
    _playerBScore.text = [NSString stringWithFormat:@"%d",0];
    
}

- (IBAction)scorePlayerAChanged:(id)sender {
    UIStepper *stepper = (UIStepper *)sender;
    if (stepper.value < 0) {
        stepper.value = 0;
    }
    NSInteger score = (NSInteger) stepper.value;
    NSLog([NSString stringWithFormat:@"%d", score]);
    _playerAScore.text = [NSString stringWithFormat:@"%d", score];
}

- (IBAction)scorePlayerBChanged:(id)sender {
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
