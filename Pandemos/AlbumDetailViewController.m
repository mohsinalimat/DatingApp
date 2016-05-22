//
//  AlbumDetailViewController.m
//  Pandemos
//
//  Created by Michael Sevy on 1/30/16.
//  Copyright © 2016 Michael Sevy. All rights reserved.
//
#import "AlbumDetailViewController.h"
#import "UIColor+Pandemos.h"
#import "FacebookCVCell.h"
#import "SelectedImageViewController.h"
#import "Facebook.h"
#import "FacebookManager.h"
#import "User.h"
#import "UIImage+Additions.h"
#import "UIButton+Additions.h"
#import "UIColor+Pandemos.h"
#import "UICollectionView+Pandemos.h"

@interface AlbumDetailViewController ()
<UICollectionViewDataSource,
UICollectionViewDelegate,
FacebookManagerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *otherAlbumsButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;

@property (strong, nonatomic) NSString *nextURL;
@property (strong, nonatomic) NSString *previousURL;
@property (strong, nonatomic) NSString *selectedImage;
@property (strong, nonatomic) User *currentUser;
@property (strong, nonatomic) FacebookManager *manager;
@property (strong, nonatomic) NSMutableArray *photos;
@property (strong, nonatomic) NSArray *albumPages;

@end

@implementation AlbumDetailViewController

static NSString * const reuseIdentifier = @"FaceCell";

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.currentUser = [User currentUser];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.navigationBar.backgroundColor = [UIColor yellowGreen];
    self.navigationItem.title = self.albumName;

    self.navigationController.navigationBar.tintColor = [UIColor colorWithHexValue:@"f1c40f"];
    NSDictionary *attributes = @{NSForegroundColorAttributeName:[UIColor blackColor],
                                 NSFontAttributeName :[UIFont fontWithName:@"GeezaPro" size:20.0]};
    [self.navigationController.navigationBar setTitleTextAttributes:attributes];
    
//    self.backButton.image = [UIImage imageWithImage:[UIImage imageNamed:@"Back"] scaledToSize:CGSizeMake(25.0, 25.0)];
//    self.backButton.tintColor = [UIColor mikeGray];
//    self.backButton.image = [UIImage imageWithImage:[UIImage imageNamed:@"Back"] scaledToSize:CGSizeMake(25.0, 25.0)];
//    self.navigationItem.leftBarButtonItem.tintColor = [UIColor mikeGray];

    self.photos = [NSMutableArray new];
    self.albumPages = [NSArray new];



    self.collectionView.delegate = self;
    [UICollectionView setupBorder:self.collectionView];
    [self setupCollectionViewFlowLayout];
}

-(void)viewDidAppear:(BOOL)animated
{
    if (self.currentUser)
    {
        self.manager = [FacebookManager new];
        self.manager.facebookNetworker = [FacebookNetwork new];
        self.manager.facebookNetworker.delegate = self.manager;
        self.manager.delegate = self;

        [self.manager loadParsedFBAlbum:self.albumID];

        [UIButton setUpButton:self.nextButton];
        [UIButton setUpButton:self.otherAlbumsButton];
    }
    else
    {
        NSLog(@"no user for face request");
    }
}

#pragma mark -- COLLECTION VIEW DELEGATE
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.photos.count;
}

- (FacebookCVCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FacebookCVCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    Facebook *face = [self.photos objectAtIndex:indexPath.item];
    cell.image.image = [UIImage imageWithString:face.albumImageURL];

    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Facebook *selectedImage = [self.photos objectAtIndex:indexPath.item];
    [self.manager loadPhotoSource:selectedImage.albumImageID];
}

#pragma mark -- NAVIGATION
- (IBAction)onBackButton:(UIBarButtonItem *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onOtherFacebookAlbums:(UIButton *)sender
{
    [self selectButtonStateForSingleButton:self.otherAlbumsButton];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onNextButton:(UIButton *)sender
{
    [self selectButtonStateForSingleButton:self.nextButton];
    [self.manager loadNextPage:self.nextURL];
}

#pragma mark -- SEGUE
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ChooseImage"])
    {
        SelectedImageViewController *sivc = [(UINavigationController*)segue.destinationViewController topViewController];
        sivc.profileImage = self.selectedImage;
    }
        else
        {
            NSLog(@"destination not correct");
        }
}

#pragma mark -- DELEGATES
-(void)didReceiveParsedAlbum:(NSArray *)album
{
    self.photos = [NSMutableArray arrayWithArray:album];
    [self.collectionView reloadData];
}

-(void)didReceiveParsedAlbumPaging:(NSArray *)albumPaging
{
    self.albumPages = albumPaging;
    Facebook *nextPage = [self.albumPages firstObject];
    self.nextURL = nextPage.nextPage;
}

-(void)didReceiveParsedPhotoSource:(NSString *)photoURL
{
    self.selectedImage = photoURL;
    [self performSegueWithIdentifier:@"ChooseImage" sender:self];
}

-(void)didReceiveNextPagePhotos:(NSArray *)nextPhotos
{
    [self.photos removeAllObjects];
    self.photos = [NSMutableArray arrayWithArray:nextPhotos];
    [self deselectButtonStateForSingleButton:self.nextButton];
    [self.collectionView reloadData];
}

#pragma mark -- HELPERS
-(void)setupCollectionViewFlowLayout
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(100, 100)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [self.collectionView setCollectionViewLayout:flowLayout];
}

-(void)selectButtonStateForSingleButton:(UIButton*)button
{
    button.backgroundColor = [UIColor blackColor];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
}

-(void)deselectButtonStateForSingleButton:(UIButton*)button
{
    button.backgroundColor = [UIColor whiteColor];
    [button setTitleColor:[UIColor facebookBlue] forState:UIControlStateNormal];
}
@end