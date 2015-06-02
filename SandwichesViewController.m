//
//  SandwichesViewController.m
//  SandwichFlow
//
//  Created by Daniel Kwiatkowski on 2015-06-01.
//  Copyright (c) 2015 Daniel Kwiatkowski. All rights reserved.
//

#import "SandwichesViewController.h"
#import "SandwichViewController.h"
#import "AppDelegate.h"



@interface SandwichesViewController ()

@end

@implementation SandwichesViewController


-(NSArray*)sandwiches
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    return appDelegate.sandwiches;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView* headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 350)];
    headerView.backgroundColor = [UIColor clearColor];
    
    UIImageView* header = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Sarnie"]];
    header.center = CGPointMake(220, 190);
    [headerView addSubview:header];
    
    self.tableView.tableHeaderView = headerView;
    
    [self.tableView setBackgroundView:[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Background-LowerLayer"]]];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self sandwiches].count;
}

 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     SandwichViewController* sandwichVC = (SandwichViewController*)segue.destinationViewController;
     
     NSIndexPath *path = [self.tableView indexPathForSelectedRow];
     sandwichVC.sandwich = [self sandwiches][path.row];
 }

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


@end
