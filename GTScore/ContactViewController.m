//
//  ContactViewController.m
//  GTScore
//
//  Created by Hai-Dang Dam on 4/1/19.
//  Copyright © 2019 Hai-Dang Dam. All rights reserved.
//

#import "ContactViewController.h"
@import Firebase;

@interface ContactViewController ()
@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) NSMutableArray<NSDictionary *> *contacts;
@property (weak, nonatomic) NSString *userID;
@property (weak, nonatomic) IBOutlet UITableView *tableView;


@end

@implementation ContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.userID = [FIRAuth auth].currentUser.uid;
    [self configureDatabase];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
}

- (void) configureDatabase {
    _ref = [[FIRDatabase database] reference];
    _refHandleChanged = [[[[_ref child:@"Users"] child:self.userID] child:@"Friends"] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        [self.contacts removeAllObjects];
        if (snapshot != nil) {
            NSDictionary<NSString *, NSDictionary*> *value = snapshot.value;
            for (NSString *key in value) {
                [self.contacts addObject:@{@"Identifier" : key, @"Name" : value[key][@"Name"]}];
            }
            [self.tableView reloadData];
        }
    }];
}
- (IBAction)invite:(id)sender {
    CGPoint touchPoint = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *clickedButtonIndexPath = [self.tableView indexPathForRowAtPoint:touchPoint];
    
    NSLog(@"index path.row ==%ld",(long)clickedButtonIndexPath.row);
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
