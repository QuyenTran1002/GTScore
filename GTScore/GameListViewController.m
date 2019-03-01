//
//  GameListViewController.m
//  GTScore
//
//  Created by Hai-Dang Dam on 2/26/19.
//  Copyright © 2019 Hai-Dang Dam. All rights reserved.
//

#import "GameListViewController.h"
#import "GameDetailViewController.h"

@interface GameListViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray<NSString *> *tableItems;
@end

@implementation GameListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableItems = [@[@"You vs. Andrew", @"You vs. John", @"You vs. Georgia State", @"You vs. Buzz"] mutableCopy];
    // Do any additional setup after loading the view.
}

- (IBAction)addNewListItem:(id)sender {
    [self.tableItems addObject:[NSString stringWithFormat:@"You vs. %@", [NSDate date]]];
    [self.tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UITableViewCell *cell = sender;
    NSInteger row = [self.tableView indexPathForCell:cell].row;
    GameDetailViewController *detail = segue.destinationViewController;
    detail.gameName = self.tableItems[row];
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [self performSegueWithIdentifier:@"GameListRowSegue" sender:self];
//}
//

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GameRowCell"];
    cell.textLabel.text = self.tableItems[indexPath.row];
    return (UITableViewCell *)cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableItems.count;
}

@end
