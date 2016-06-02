//
//  DraggableView.m
//  testing swiping
//
//  Created by Richard Kim on 5/21/14.
//  Copyright (c) 2014 Richard Kim. All rights reserved.
//
//  @cwRichardKim for updates and requests

#define ACTION_MARGIN 120 //%%% distance from center where the action applies. Higher = swipe further in order for the action to be called
#define SCALE_STRENGTH 4 //%%% how quickly the card shrinks. Higher = slower shrinking
#define SCALE_MAX .93 //%%% upper bar for how much the card shrinks. Higher = shrinks less
#define ROTATION_MAX 1 //%%% the maximum rotation allowed in radians.  Higher = card can keep rotating longer
#define ROTATION_STRENGTH 320 //%%% strength of rotation. Higher = weaker rotation
#define ROTATION_ANGLE M_PI/8 //%%% Higher = stronger rotation angle

#import "UIColor+Pandemos.h"
#import "DraggableView.h"
#import "UIButton+Additions.h"

@implementation DraggableView
{
    CGFloat xFromCenter;
    CGFloat yFromCenter;
}

//delegate is instance of ViewController
@synthesize delegate;

@synthesize panGestureRecognizer;
@synthesize information;
@synthesize overlayView;
@synthesize schoolLabel;
@synthesize b1;
@synthesize b2;
@synthesize b3;
@synthesize b4;
@synthesize b5;
@synthesize b6;
@synthesize noButton;
@synthesize yesButton;
@synthesize profileImageView;
@synthesize imageScroll;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];

        UIView *matchDescView = [[UIView alloc]init];
        matchDescView.translatesAutoresizingMaskIntoConstraints = NO;
        NSDictionary *viewsDictionary = @{@"matchView":matchDescView};
        matchDescView.backgroundColor = [UIColor lightGrayColor];
        matchDescView.layer.cornerRadius = 8;
        [self addSubview:matchDescView];

        NSArray *constraint_H = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[matchView(70)]"
                                                                        options:0
                                                                        metrics:nil
                                                                          views:viewsDictionary];

        NSArray *constraint_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[matchView]-15-|"
                                                                            options:0
                                                                            metrics:nil
                                                                              views:viewsDictionary];

        NSArray *constraint_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-32-[matchView]-32-|"
                                                                            options:0
                                                                            metrics:nil
                                                                              views:viewsDictionary];
        //view specific constraints
        [matchDescView addConstraints:constraint_H];
        //superView contraints
        [self addConstraints:constraint_POS_H];
        [self addConstraints:constraint_POS_V];

        information = [UILabel new];
        information.translatesAutoresizingMaskIntoConstraints = NO;
        [matchDescView insertSubview:information aboveSubview:matchDescView];
        [information setFont:[UIFont fontWithName:@"GeezaPro" size:18.0]];
        [information setTextAlignment:NSTextAlignmentCenter];
        [self addNameAndAgeLabelConstraints:information andSuperView:matchDescView];

        schoolLabel = [UILabel new];
        schoolLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [matchDescView addSubview:schoolLabel];
        [schoolLabel setFont:[UIFont fontWithName:@"GeezaPro" size:16.0]];
        schoolLabel.text = @"Loading...";
        schoolLabel.lineBreakMode = NSLineBreakByWordWrapping;
        schoolLabel.numberOfLines = 0;
        [schoolLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSchoolLabelConstraints:schoolLabel andSuperView:matchDescView];

        panGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(beingDragged:)];
        [self addGestureRecognizer:panGestureRecognizer];

        imageScroll = [[ImageScroll alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        imageScroll.backgroundColor = [UIColor blueColor];
        imageScroll.alpha = 0.3;
        imageScroll.delegate = self;
        imageScroll.pagingEnabled = YES;
        imageScroll.scrollEnabled = YES;
        imageScroll.userInteractionEnabled = YES;
        [self addSubview:imageScroll];
        imageScroll.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height *2);//multiplied by profileimages.count

        //load view for all the proffile images but that data is in draggableviewbackgroud







        overlayView = [[OverlayView alloc]initWithFrame:CGRectMake(self.frame.size.width/2-100, 0, 100, 100)];
        overlayView.alpha = 1;
        [self addSubview:overlayView];

        b1 = [UIButton new];
        b1.translatesAutoresizingMaskIntoConstraints = NO;
        b1.layer.masksToBounds = YES;
        b1.layer.cornerRadius = 6;
        [self addSubview:b1];
        [self addButton1Constraints:b1 withSuper:self];

        b2 = [UIButton new];
        b2.translatesAutoresizingMaskIntoConstraints = NO;
        b2.layer.masksToBounds = YES;
        b2.layer.cornerRadius = 6;
        [self addSubview:b2];
        [self addButton2Constraints:b2 withSuper:self];

        b3 = [UIButton new];
        b3.translatesAutoresizingMaskIntoConstraints = NO;
        b3.layer.masksToBounds = YES;
        b3.layer.cornerRadius = 6;
        [self addSubview:b3];
        [self addButton3Constraints:b3 withSuper:self];

        b4 = [UIButton new];
        b4.translatesAutoresizingMaskIntoConstraints = NO;
        b4.layer.masksToBounds = YES;
        b4.layer.cornerRadius = 6;
        [self addSubview:b4];
        [self addButton4Constraints:b4 withSuper:self];

        b5 = [UIButton new];
        b5.translatesAutoresizingMaskIntoConstraints = NO;
        b5.layer.masksToBounds = YES;
        b5.layer.cornerRadius = 6;
        [self addSubview:b5];
        [self addButton5Constraints:b5 withSuper:self];

        b6 = [UIButton new];
        b6.layer.masksToBounds = YES;
        b6.layer.cornerRadius = 6;
        b6.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:b6];
        [self addButton6Constraints:b6 withSuper:self];

        noButton = [UIButton new];
        noButton.translatesAutoresizingMaskIntoConstraints = NO;
        noButton.layer.masksToBounds = YES;
        noButton.layer.cornerRadius = 25;
        [UIButton noButton:noButton];
        [noButton setTitle:@"✖️" forState:UIControlStateNormal];
        noButton.titleLabel.text = @"X";
        noButton.backgroundColor = [UIColor redColor];
        noButton.layer.borderWidth = 1.0;
        noButton.layer.borderColor = [UIColor blackColor].CGColor;
        [self addSubview:noButton];
        [self addNoButtonConstraints:noButton withSuper:self];

        yesButton = [UIButton new];
        yesButton.translatesAutoresizingMaskIntoConstraints = NO;
        yesButton.layer.masksToBounds = YES;
        yesButton.layer.cornerRadius = 25;
        [UIButton yesButton:yesButton];
        [yesButton setTitle:@"✔️" forState:UIControlStateNormal];
        yesButton.backgroundColor = [UIColor greenColor];
        yesButton.layer.borderWidth = 1.0;
        yesButton.layer.borderColor = [UIColor blackColor].CGColor;
        [self addSubview:yesButton];
        [self addYesButtonConstraints:yesButton withSuper:self];

        profileImageView = [UIImageView new];
        profileImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self insertSubview:profileImageView belowSubview:matchDescView];

        NSDictionary *imageDict = @{@"imageView":profileImageView};
        NSArray *imgConstraint_POS_V = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[imageView]-0-|"
                                                                               options:0
                                                                               metrics:nil
                                                                                 views:imageDict];

        NSArray *imgConstraint_POS_H = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[imageView]-0-|"
                                                                               options:0
                                                                               metrics:nil
                                                                                 views:imageDict];
        [self addConstraints:imgConstraint_POS_H];
        [self addConstraints:imgConstraint_POS_V];
    }
    return self;
}

-(void)setupView
{
    self.layer.cornerRadius = 4;
    self.layer.shadowRadius = 3;
    self.layer.shadowOpacity = 0.2;
    self.layer.shadowOffset = CGSizeMake(1, 1);
}

#pragma mark SCROLLVIEW DELEGATES
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    NSLog(@"page up on scrollview");
    if (scrollView.contentOffset.y > self.frame.size.height)//and less than third image
    {
        NSLog(@"load image 2");
    }
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    NSLog(@"dragging in scroll view");
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"Did end decelerating");
    //do your code here
}

//%%% called when you move your finger across the screen.
// called many times a second
-(void)beingDragged:(UIPanGestureRecognizer *)gestureRecognizer
{
    //%%% this extracts the coordinate data from your swipe movement. (i.e. How much did you move?)
    xFromCenter = [gestureRecognizer translationInView:self].x; //%%% positive for right swipe, negative for left
    //yFromCenter = [gestureRecognizer translationInView:self].y; //%%% positive for up, negative for down

    //%%% checks what state the gesture is in. (are you just starting, letting go, or in the middle of a swipe?)
    switch (gestureRecognizer.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            self.originalPoint = self.center;
            break;
        };
            //%%% in the middle of a swipe
        case UIGestureRecognizerStateChanged:
        {
            //%%% dictates rotation (see ROTATION_MAX and ROTATION_STRENGTH for details)
            CGFloat rotationStrength = MIN(xFromCenter / ROTATION_STRENGTH, ROTATION_MAX);

            //%%% degree change in radians
            CGFloat rotationAngel = (CGFloat) (ROTATION_ANGLE * rotationStrength);

            //%%% amount the height changes when you move the card up to a certain point
            CGFloat scale = MAX(1 - fabs(rotationStrength) / SCALE_STRENGTH, SCALE_MAX);

            //%%% move the object's center by center + gesture coordinate
            self.center = CGPointMake(self.originalPoint.x + xFromCenter, self.originalPoint.y);
    
            //%%% rotate by certain amount
            CGAffineTransform transform = CGAffineTransformMakeRotation(rotationAngel);

            //%%% scale by certain amount
            CGAffineTransform scaleTransform = CGAffineTransformScale(transform, scale, scale);

            //%%% apply transformations
            self.transform = scaleTransform;
            [self updateOverlay:xFromCenter];

            break;
        };
            //%%% let go of the card
        case UIGestureRecognizerStateEnded: {
            [self afterSwipeAction];
            break;
        };
        case UIGestureRecognizerStatePossible:break;
        case UIGestureRecognizerStateCancelled:break;
        case UIGestureRecognizerStateFailed:break;
    }
}

//%%% checks to see if you are moving right or left and applies the correct overlay image
-(void)updateOverlay:(CGFloat)distance
{
    if (distance > 0) {
        overlayView.mode = GGOverlayViewModeRight;
    } else {
        overlayView.mode = GGOverlayViewModeLeft;
    }

    overlayView.alpha = MIN(fabs(distance)/100, 0.4);
}

//%%% called when the card is let go
- (void)afterSwipeAction
{
    if (xFromCenter > ACTION_MARGIN)
    {
        [self rightAction];
    }
    else if (xFromCenter < -ACTION_MARGIN)
    {
        [self leftAction];
    }
//    else if (yFromCenter > ACTION_MARGIN)
//    {
//        [self downImageAction];
//    }
//    else if(yFromCenter < -ACTION_MARGIN)
//    {
//        [self upImageAction];
//    }
    else
    { //%%% resets the card
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.center = self.originalPoint;
                             self.transform = CGAffineTransformMakeRotation(0);
                             overlayView.alpha = 0;
                         }];
    }
}

//%%% called when a swipe exceeds the ACTION_MARGIN to the right
-(void)rightAction
{
    CGPoint finishPoint = CGPointMake(500, 2*yFromCenter +self.originalPoint.y);
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.center = finishPoint;
                     }completion:^(BOOL complete){
                         [self removeFromSuperview];
                     }];

    [delegate cardSwipedRight:self];

    NSLog(@"YES");
}

//%%% called when a swip exceeds the ACTION_MARGIN to the left
-(void)leftAction
{
    CGPoint finishPoint = CGPointMake(-500, 2*yFromCenter +self.originalPoint.y);
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.center = finishPoint;
                     }completion:^(BOOL complete){
                         [self removeFromSuperview];
                     }];

    [delegate cardSwipedLeft:self];

    NSLog(@"NO");
}

-(void)rightClickAction
{
    CGPoint finishPoint = CGPointMake(600, self.center.y);
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.center = finishPoint;
                         self.transform = CGAffineTransformMakeRotation(1);
                     }completion:^(BOOL complete){
                         [self removeFromSuperview];
                     }];

    [delegate cardSwipedRight:self];

    NSLog(@"YES");
}

-(void)leftClickAction
{
    CGPoint finishPoint = CGPointMake(-600, self.center.y);
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.center = finishPoint;
                         self.transform = CGAffineTransformMakeRotation(-1);
                     }completion:^(BOOL complete){
                         [self removeFromSuperview];
                     }];

    [delegate cardSwipedLeft:self];

    NSLog(@"NO");
}

-(void)imagesForMatch:(NSArray *)images
{
    NSLog(@"images: %@", images);
}

#pragma mark -- VIEW HELPERS
-(void)addNameAndAgeLabelConstraints:(UIView*)view andSuperView:(UIView*)superView
{
    NSDictionary *informationDict = @{@"info":information};

    NSArray *infoCon_H = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[info(20)]"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:informationDict];

    NSArray *infoCon_PosH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[info]-5-|"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:informationDict];

    NSArray *infoCon_PosV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[info]"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:informationDict];
    [information addConstraints:infoCon_H];
    [superView addConstraints:infoCon_PosH];
    [superView addConstraints:infoCon_PosV];
}

-(void)addSchoolLabelConstraints:(UIView*)view andSuperView:(UIView*)superView
{

    NSDictionary *informationDict = @{@"school": schoolLabel, @"info":information};
    NSArray *infoCon_PosH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[school]-15-|"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:informationDict];

    NSArray *infoCon_PosV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-25-[school]"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:informationDict];
    [superView addConstraints:infoCon_PosH];
    [superView addConstraints:infoCon_PosV];
}

-(void)addButton1Constraints:(UIButton*)button withSuper:(UIView*)superView
{
    NSDictionary *buttonDict = @{@"b1": b1};
    NSArray *buttonHeight = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[b1(12)]"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:buttonDict];
    NSArray *buttonWidth = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[b1(12)]"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:buttonDict];
    NSArray *infoCon_PosH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[b1]-10-|"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:buttonDict];
    NSArray *infoCon_PosV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-32-[b1]"
                                                                    options:0
                                                                    metrics:nil
                                                                    views:buttonDict];
    [b1 addConstraints:buttonHeight];
    [b1 addConstraints:buttonWidth];
    [superView addConstraints:infoCon_PosH];
    [superView addConstraints:infoCon_PosV];
}

-(void)addButton2Constraints:(UIButton*)button withSuper:(UIView*)superView
{
    NSDictionary *buttonDict = @{@"b2": b2};
    NSArray *buttonHeight = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[b2(12)]"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:buttonDict];
    NSArray *buttonWidth = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[b2(12)]"
                                                                   options:0
                                                                   metrics:nil
                                                                     views:buttonDict];
    NSArray *infoCon_PosH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[b2]-10-|"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:buttonDict];
    NSArray *infoCon_PosV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-47-[b2]"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:buttonDict];
    [b2 addConstraints:buttonHeight];
    [b2 addConstraints:buttonWidth];
    [superView addConstraints:infoCon_PosH];
    [superView addConstraints:infoCon_PosV];
}

-(void)addButton3Constraints:(UIButton*)button withSuper:(UIView*)superView
{
    NSDictionary *buttonDict = @{@"b3": b3};
    NSArray *buttonHeight = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[b3(12)]"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:buttonDict];
    NSArray *buttonWidth = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[b3(12)]"
                                                                   options:0
                                                                   metrics:nil
                                                                     views:buttonDict];
    NSArray *infoCon_PosH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[b3]-10-|"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:buttonDict];
    NSArray *infoCon_PosV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-62-[b3]"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:buttonDict];
    [b3 addConstraints:buttonHeight];
    [b3 addConstraints:buttonWidth];
    [superView addConstraints:infoCon_PosH];
    [superView addConstraints:infoCon_PosV];
}

-(void)addButton4Constraints:(UIButton*)button withSuper:(UIView*)superView
{
    NSDictionary *buttonDict = @{@"b4": b4};
    NSArray *buttonHeight = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[b4(12)]"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:buttonDict];
    NSArray *buttonWidth = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[b4(12)]"
                                                                   options:0
                                                                   metrics:nil
                                                                     views:buttonDict];
    NSArray *infoCon_PosH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[b4]-10-|"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:buttonDict];
    NSArray *infoCon_PosV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-77-[b4]"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:buttonDict];
    [b4 addConstraints:buttonHeight];
    [b4 addConstraints:buttonWidth];
    [superView addConstraints:infoCon_PosH];
    [superView addConstraints:infoCon_PosV];
}
-(void)addButton5Constraints:(UIButton*)button withSuper:(UIView*)superView
{
    NSDictionary *buttonDict = @{@"b5": b5};
    NSArray *buttonHeight = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[b5(12)]"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:buttonDict];
    NSArray *buttonWidth = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[b5(12)]"
                                                                   options:0
                                                                   metrics:nil
                                                                     views:buttonDict];
    NSArray *infoCon_PosH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[b5]-10-|"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:buttonDict];
    NSArray *infoCon_PosV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-92-[b5]"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:buttonDict];
    [b5 addConstraints:buttonHeight];
    [b5 addConstraints:buttonWidth];
    [superView addConstraints:infoCon_PosH];
    [superView addConstraints:infoCon_PosV];
}

-(void)addButton6Constraints:(UIButton*)button withSuper:(UIView*)superView
{
    NSDictionary *buttonDict = @{@"b6": b6};
    NSArray *buttonHeight = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[b6(12)]"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:buttonDict];
    NSArray *buttonWidth = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[b6(12)]"
                                                                   options:0
                                                                   metrics:nil
                                                                     views:buttonDict];
    NSArray *infoCon_PosH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[b6]-10-|"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:buttonDict];
    NSArray *infoCon_PosV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-107-[b6]"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:buttonDict];
    [b6 addConstraints:buttonHeight];
    [b6 addConstraints:buttonWidth];
    [superView addConstraints:infoCon_PosH];
    [superView addConstraints:infoCon_PosV];
}

-(void)addNoButtonConstraints:(UIButton*)button withSuper:(UIView*)superView
{
    NSDictionary *buttonDict = @{@"noButton": noButton};
    NSArray *buttonHeight = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[noButton(50)]"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:buttonDict];
    NSArray *buttonWidth = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[noButton(50)]"
                                                                   options:0
                                                                   metrics:nil
                                                                     views:buttonDict];
    NSArray *infoCon_PosH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(-13)-[noButton]"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:buttonDict];
    NSArray *infoCon_PosV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[noButton]-20-|"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:buttonDict];
    [noButton addConstraints:buttonHeight];
    [noButton addConstraints:buttonWidth];
    [superView addConstraints:infoCon_PosH];
    [superView addConstraints:infoCon_PosV];
}

-(void)addYesButtonConstraints:(UIButton*)button withSuper:(UIView*)superView
{
    NSDictionary *buttonDict = @{@"yesButton": yesButton};
    NSArray *buttonHeight = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[yesButton(50)]"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:buttonDict];
    NSArray *buttonWidth = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[yesButton(50)]"
                                                                   options:0
                                                                   metrics:nil
                                                                     views:buttonDict];
    NSArray *infoCon_PosH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[yesButton]-(-10)-|"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:buttonDict];
    NSArray *infoCon_PosV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[yesButton]-20-|"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:buttonDict];
    [yesButton addConstraints:buttonHeight];
    [yesButton addConstraints:buttonWidth];
    [superView addConstraints:infoCon_PosH];
    [superView addConstraints:infoCon_PosV];
}
@end










