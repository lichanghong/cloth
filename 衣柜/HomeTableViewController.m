//
//  HomeTableViewController.m
//  衣柜
//
//  Created by lichanghong on 12/5/17.
//  Copyright © 2017 lichanghong. All rights reserved.
//

#import "HomeTableViewController.h"
#import <CHBaseUtil.h>
#import "HomeAddAlert.h"
#import "WardrobesData.h"
#import "WardrobesEntity+CoreDataClass.h"
#import "HomeTableViewCell.h"

@interface HomeTableViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *add;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *edit;

@end

@implementation HomeTableViewController
- (IBAction)handleAction:(id)sender {
    __weak typeof(self) weakself = self;
    if (sender == self.add) {
        [HomeAddAlert alertInVC:self success:^(NSString *title) {
            [WardrobesData addWardrobesItemWithTitle:title];
            [weakself.tableView reloadData];
        }];
    }
    else if (sender == self.edit)
    {
        if (self.edit.tag==0) {
            [self.tableView setEditing:YES animated:YES];
            self.edit.tag = 1;
            self.edit.title = @"完成";
        }
        else
        {
            self.edit.tag = 0;
            self.edit.title = @"删除";
            [self.tableView setEditing:NO animated:YES];

        }
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle==UITableViewCellEditingStyleDelete) {
        //更新数据
        [WardrobesData removeWardrobesItemAtIndexPath:indexPath];
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:indexPath.section];
        [tableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationRight];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
 
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger count = [WardrobesData count];
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSArray *entities = [WardrobesData entities];
    WardrobesEntity*entity = [entities objectAtIndex:section];
    return [NSString stringWithFormat:@"%@",entity.title];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomeTableViewCell" forIndexPath:indexPath];
    cell.tag = (NSInteger)indexPath.section;
    [cell.homeCollectionView reloadData];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
/*
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
