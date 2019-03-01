//
//  GameDetailViewController.m
//  GTScore
//
//  Created by Hai-Dang Dam on 2/26/19.
//  Copyright © 2019 Hai-Dang Dam. All rights reserved.
//

#import "GameDetailViewController.h"

@interface GameDetailViewController ()

@end

@implementation GameDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.gameNameLabel.text = self.gameName;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *resultLoad = [prefs stringForKey:self.gameName];
    if (resultLoad != nil && [resultLoad length] != 0) {
        NSArray *array = [resultLoad componentsSeparatedByString:@" vs. "];
        self.score1Text.text = array[0];
        self.score2Text.text = array[1];
    }
    NSArray *array = [self.gameName componentsSeparatedByString:@" vs. "];
    self.player1Label.text = array[0];
    self.player2Label.text = array[1];
}

- (IBAction)reportScore:(id)sender {
    if ([self.score1Text.text length] == 0 || [self.score2Text.text length] == 0) {
        UIAlertController *alertController = [[UIAlertController alloc] init];
        alertController.title = @"Error";
        alertController.message = @"Not input score to field";
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSMutableString *result = [@"" mutableCopy];
        [result appendString:self.score1Text.text];
        [result appendString:@" vs. "];
        [result appendString:self.score2Text.text];
        [prefs setObject:result forKey:self.gameName];
        UINavigationController *navigationController = self.navigationController;
        [navigationController popViewControllerAnimated:YES];
    }
    
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
