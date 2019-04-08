//
//  GameDetailViewController.h
//  GTScore
//
//  Created by Hai-Dang Dam on 2/26/19.
//  Copyright © 2019 Hai-Dang Dam. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GameDetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *gameNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *playerALabel;
@property (weak, nonatomic) IBOutlet UILabel *playerBLabel;
@property (weak, nonatomic) IBOutlet UITextField *playerBScore;
@property (weak, nonatomic) IBOutlet UITextField *playerAScore;
@property (weak, nonatomic) IBOutlet UIStepper *playerAStepper;
@property (weak, nonatomic) IBOutlet UIStepper *playerBStepper;

@end

NS_ASSUME_NONNULL_END
