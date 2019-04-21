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
@property (strong, nonatomic) NSUserDefaults *prefs;
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
    _prefs = [NSUserDefaults standardUserDefaults];
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
        [self saveToDatabase:@true];
    }
    
}

- (void) saveToDatabase:(BOOL) played  {
    NSString *matchID = [NSString stringWithFormat:@"%@",[_match valueForKey:@"matchID"]];
    [_match setValue:[NSNumber numberWithDouble:_playerAStepper.value] forKey:@"score1"];
    [_match setValue:[NSNumber numberWithDouble:_playerBStepper.value] forKey:@"score2"];
    [_prefs setBool:true forKey:_match.description];
    if (played) {
        [_match setValue:@YES forKey:@"played"];
        [self saveRanking:_match];
        [self resetMatch];
    } else {
        [_match setValue:@NO forKey:@"played"];
    }
    
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
}

- (void) saveRanking:(NSDictionary *) game {
    NSString *winnerID = nil;
    NSString *loserID = nil;
    double score1 = [(NSNumber*) [game valueForKey:@"score1"] doubleValue];
    double score2 = [(NSNumber*) [game valueForKey:@"score2"] doubleValue];
    if (score1 > score2) {
        winnerID = [game valueForKey:@"player1ID"];
        loserID = [game valueForKey:@"player2ID"];
    } else if (score1 == score2) {
        return;
    } else {
        winnerID = [game valueForKey:@"player2ID"];
        loserID = [game valueForKey:@"player1ID"];
    }
    [[[[self.ref child:@"Users"] child: winnerID] child:@"num_wins"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
         if (![snapshot.value isEqual:[NSNull null]]) {
             NSNumber *num = snapshot.value;
             int value = [num integerValue];
             value = value - 1;
             [[[[self.ref child:@"Users"] child: winnerID] child:@"num_wins"] setValue:[NSNumber numberWithInteger:value]];
        }
    }];
}

- (void) configureDatabase {
    _ref = [[FIRDatabase database] reference];
    
    [[[[_ref child:@"Users"] child:self.userID] child:@"games"] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSLog(@"changed 1: %@", snapshot);
        NSDictionary<NSString *, NSDictionary*> *value = snapshot.value;
        BOOL havePlayed = false;
        if (![snapshot.value isEqual:[NSNull null]]) {
            for (NSString *key in value) {
                NSDictionary<NSString *, NSObject *> *game = value[key];
                NSNumber* a = [game valueForKey:@"played"];
                if ([a integerValue] == 0) {
                    havePlayed = true;
                    if (![self checkedRegister:game]) {
                        [self loadMatchToComponent:game];
                    }
                    [self loadMatchToComponent:game];
                }
            }
        }
        if (!havePlayed && !haveShown) {
            UIAlertController *alertController = [[UIAlertController alloc] init];
            alertController.title = @"Error";
            alertController.message = @"You have no on going match";
            [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }];
}


- (BOOL) checkedRegister:(NSDictionary *) dictionary {
    NSString *key = dictionary.description;
    BOOL result = [_prefs boolForKey:key];
    if (result == nil || result == false) {
        [_prefs setBool:true forKey:key];
        return false;
    }
    return true;
}

- (void) loadMatchToComponent:(NSDictionary *) dictionary {
    _gameNameField.text = [NSString stringWithFormat:@"%@",[dictionary valueForKey:@"name"]];
    _player1Name.text = [NSString stringWithFormat:@"%@",[dictionary valueForKey:@"player1Name"]];
    _player2Name.text = [NSString stringWithFormat:@"%@",[dictionary valueForKey:@"player2Name"]];
    [self.playerAStepper setValue: [(NSNumber*) [dictionary valueForKey:@"score1"] doubleValue]];
    [self.playerBStepper setValue: [(NSNumber*) [dictionary valueForKey:@"score2"] doubleValue]];
    _playerAScore.text = [NSString stringWithFormat:@"%d", (int) self.playerAStepper.value];
    _playerBScore.text = [NSString stringWithFormat:@"%d", (int) self.playerBStepper.value];
    _match = dictionary;
    
}

- (void) resetMatch {
    _gameNameField.text = [NSString stringWithFormat:@"%@", @"Game Name"];
    _player1Name.text = [NSString stringWithFormat:@"%@",@"Player 1"];
    _player2Name.text = [NSString stringWithFormat:@"%@",@"Player 2"];
    [self.playerAStepper setValue: 0];
    [self.playerBStepper setValue: 0];
    _playerAScore.text = [NSString stringWithFormat:@"%d", (int) self.playerAStepper.value];
    _playerBScore.text = [NSString stringWithFormat:@"%d", (int) self.playerBStepper.value];
}

- (IBAction)scorePlayerAChanged:(id)sender {
    UIStepper *stepper = (UIStepper *)sender;
    if (stepper.value < 0) {
        stepper.value = 0;
    }
    NSInteger score = (NSInteger) stepper.value;
    NSLog([NSString stringWithFormat:@"%d", score]);
    _playerAScore.text = [NSString stringWithFormat:@"%d", score];
    [self saveToDatabase:false];
    
}

- (IBAction)scorePlayerBChanged:(id)sender {
    UIStepper *stepper = (UIStepper *)sender;
    if (stepper.value < 0) {
        stepper.value = 0;
    }
    NSInteger score = (NSInteger) stepper.value;
    NSLog([NSString stringWithFormat:@"%d", score]);
    _playerBScore.text = [NSString stringWithFormat:@"%d", score];
    [self saveToDatabase:false];
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
