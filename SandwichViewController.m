//
//  SandwichViewController.m
//  SandwichFlow
//
//  Created by Daniel Kwiatkowski on 2015-06-01.
//  Copyright (c) 2015 Daniel Kwiatkowski. All rights reserved.
//

#import "SandwichViewController.h"
#import "CollectionViewLabelCell.h"

@interface SandwichViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UICollectionView *keywordCollectionView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *closeButton;

@end

@implementation SandwichViewController
{
    NSDictionary* _sandwich;
}

-(NSDictionary*)sandwich{
    return _sandwich;
}

-(void)setSandwich:(NSDictionary *)sandwich{
    _sandwich = sandwich;
    [self updateSandwichesData];
}


- (void)viewDidLoad {
    [super viewDidLoad];

    UIImageView* background = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Background-LowerLayer"]];
    background.alpha =0.5f;
    [self.view addSubview:background];
    [self.view sendSubviewToBack:background];
    
    //configure the collectionview
    [self.keywordCollectionView registerClass:[CollectionViewLabelCell class] forCellWithReuseIdentifier:@"cell"];
    self.keywordCollectionView.dataSource = self;
    self.keywordCollectionView.backgroundColor = [UIColor clearColor];
    
    UICollectionViewFlowLayout* flowLayout = (UICollectionViewFlowLayout*)self.keywordCollectionView.collectionViewLayout;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.itemSize = CGSizeMake(120, 20);
    
    [self updateSandwichesData];

}




-(void) updateSandwichesData{
    NSString* imageName = self.sandwich[@"image"];
    UIImage* image = [UIImage imageNamed:imageName];
    self.imageView.image = image;
    
    self.navigationBar.topItem.title = self.sandwich[@"title"];
    
    NSArray* instructions = self.sandwich[@"instructions"];
    self.textView.text = [instructions componentsJoinedByString:@"\n\n"];
}

-(IBAction)closeButtonTapped:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSArray* ingredients = _sandwich[@"keywords"];
    return ingredients.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CollectionViewLabelCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    NSArray* ingredients = _sandwich[@"keywords"];
    cell.title.text = ingredients[indexPath.row];
    return cell;
}




@end
