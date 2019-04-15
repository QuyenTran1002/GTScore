//
//  CreateMatchViewController.m
//  GTScore
//
//  Created by Hai-Dang Dam on 4/10/19.
//  Copyright © 2019 Hai-Dang Dam. All rights reserved.
//

#import "CreateMatchViewController.h"
@import Firebase;
#import <CommonCrypto/CommonHMAC.h>
#import "GameDetailViewController.h"

@interface CreateMatchViewController ()
@property (weak, nonatomic) IBOutlet UITextField *gameName;
@property (weak, nonatomic) IBOutlet UIPickerView *dropdownListOpponent;
@property (weak, nonatomic) NSString *userID;
@property (weak, nonatomic) NSString *username;
@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) NSMutableArray<NSDictionary *> *friendList;

@end

@implementation CreateMatchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.friendList = [[NSMutableArray alloc] init];
    self.userID = [FIRAuth auth].currentUser.uid;
    self.dropdownListOpponent.delegate = self;
    self.dropdownListOpponent.dataSource = self;
    [self configureDatabase];
    [self.gameName setDelegate:self];
    [GameDetailViewController setHaveShown:FALSE];
    // Do any additional setup after loading the view.
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)addMatch:(id)sender {
    NSString *identifier = [self sha256HashFor:_gameName.text];
    NSMutableDictionary<NSString *, NSNumber *> *matchScore = @{@"score1" : @0, @"score2" : @0};
    [[[[[self.ref child:@"Users"]child:_userID] child:@"matches"] child:identifier] setValue:matchScore withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
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
    NSString *friendID = self.friendList[[_dropdownListOpponent selectedRowInComponent:0]][@"uid"];
    NSString *friendName = self.friendList[[_dropdownListOpponent selectedRowInComponent:0]][@"name"];
    [[[[[self.ref child:@"Users"]child:friendID] child:@"matches"] child:identifier] setValue:matchScore withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
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
    NSMutableDictionary<NSString *, NSObject *> *data = @{@"matchID" : identifier, @"name" : _gameName.text, @"played" : @false, @"player1ID" : _userID, @"player1Name" : _username, @"player2ID" : friendID, @"player2Name" : friendName, @"score1" : @0, @"score2" : @0};
    [[[[[self.ref child:@"Users"]child:_userID] child:@"games"] child:identifier] setValue:data withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
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
    [[[[[self.ref child:@"Users"]child:friendID] child:@"games"] child:identifier] setValue:data withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
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

- (void) configureDatabase {
    _ref = [[FIRDatabase database] reference];_refHandleChanged = [[[[_ref child:@"Users"] child:self.userID] child:@"name"] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSLog(@"changed: %@", snapshot);
        if (![snapshot.value isEqual:[NSNull null]]) {
            _username = snapshot.value;
        }
    }];
    _refHandleChanged = [[[[_ref child:@"Users"] child:self.userID] child:@"friends"] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSLog(@"changed: %@", snapshot);
        [self.friendList removeAllObjects];
        if (![snapshot.value isEqual:[NSNull null]]) {
            NSDictionary<NSString *, NSDictionary*> *value = snapshot.value;
            for (NSString *key in value) {
                [self.friendList addObject:value[key]];
            }
            [self.dropdownListOpponent reloadAllComponents];
        }
    }];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    return 1;  // Or return whatever as you intend
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    return self.friendList.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSDictionary<NSString*, NSString*> *opponent = self.friendList[row];
    return opponent[@"name"];
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
