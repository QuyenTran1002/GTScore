//
//  SendInvitationViewController.h
//  GTScore
//
//  Created by Hai-Dang Dam on 4/14/19.
//  Copyright © 2019 Hai-Dang Dam. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SendInvitationViewController : UIViewController
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *data;
@property (nonatomic, strong) NSString *name;
@end

NS_ASSUME_NONNULL_END
