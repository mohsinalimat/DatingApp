//  PFLoginViewController.m
//  Pandemos
//
//  Created by Michael Sevy on 12/16/15.
//  Copyright © 2015 Michael Sevy. All rights reserved.
//

#import "PFLoginViewController.h"
#import <Foundation/Foundation.h>
#import <Bolts/BFTask.h>
#import <FBSDKCoreKit/FBSDKAccessToken.h>
#import <FBSDKLoginKit/FBSDKLoginManager.h>
#import <ParseFacebookUtilsV4.h>
#import <Parse/PFConstants.h>
#import "ProfileViewController.h"
#import "User.h"
#import "UserManager.h"
#import "UIColor+Pandemos.h"

@interface PFLoginViewController ()
@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (strong, nonatomic) User *currentUser;
@property (strong, nonatomic) UserManager *userManager;
@end

@implementation PFLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.footerView.backgroundColor = [UIColor facebookBlue];
}

- (IBAction)loginWFacebook:(UIButton *)sender
{
    // Set permissions required from the facebook user account
    NSArray *permissionsArray = @[ @"public_profile", @"user_about_me", @"user_birthday", @"user_location", @"user_photos", @"user_work_history", @"user_hometown", @"user_likes", @"pages_show_list", @"user_education_history"];

    // Login PFUser using Facebook
    [PFFacebookUtils logInInBackgroundWithReadPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        if (!user) {
            NSLog(@"Uh oh. The user cancelled the Facebook login.");
        }
        else if (user.isNew)
        {
            [self.userManager signUp:user];
            NSLog(@"User signed up and logged in through Facebook!");
            [self performSegueWithIdentifier:@"LoggedIn" sender:self];
        }
        else
        {
            NSLog(@"User logged in through Facebook!");
            self.currentUser = [User currentUser];
        }
    }];

    [self performSegueWithIdentifier:@"LoggedIn" sender:self];
}

- (void)saveToUserDefaultsWithObject:(id)object andKey:(NSString*)key
{
    [[NSUserDefaults standardUserDefaults] setObject:object forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"SAVED %@ TO USER DEFAULTS", object);
}
//-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    //check idenifier if more than one
//    ViewController *vc = segue.destinationViewController;
//
//    if ([segue.identifier isEqualToString:@"LoggedIn"]) {
//  //      [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
//        vc.pfUser = self.pfUser;
//    }
//}


@end
