#import "OBHTableViewControllerObject.h"

@interface OBHTableViewControllerObject ()

@property (nonatomic, readonly) UITableViewController *viewController;

@end

@implementation OBHTableViewControllerObject

@dynamic viewController;

- (NSArray<UITableViewCell *> *)visibleCells {
    [self.viewController.tableView layoutIfNeeded];
    
    return [self.viewController.tableView visibleCells];
}

- (UITableViewCell *)visibleCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.viewController.tableView layoutIfNeeded];
    
    UITableViewCell *cell = [self cellForRowAtIndexPath:indexPath];
    if ([self.visibleCells containsObject:cell]) {
        return cell;
    } else {
        return nil;
    }
}

- (UITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.viewController.tableView layoutIfNeeded];
    
    return [self.viewController.tableView cellForRowAtIndexPath:indexPath];
}

@end
