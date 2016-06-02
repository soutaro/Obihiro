#import "OBHTableViewControllerObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface OBHTableViewControllerObject ()

@property (nonatomic, readonly) UITableViewController *viewController;

@end

@implementation OBHTableViewControllerObject

@dynamic viewController;

- (NSArray<UITableViewCell *> *)visibleCells {
    [self.viewController.tableView layoutIfNeeded];
    
    return [self.viewController.tableView visibleCells];
}

- (nullable __kindof UITableViewCell *)visibleCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.viewController.tableView layoutIfNeeded];
    
    UITableViewCell *cell = [self cellForRowAtIndexPath:indexPath];
    if (cell) {
        if ([self.visibleCells containsObject:cell]) {
            return cell;
        }
    }
    
    return nil;
}

- (nullable __kindof UITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.viewController.tableView layoutIfNeeded];
    
    return [self.viewController.tableView cellForRowAtIndexPath:indexPath];
}

@end

NS_ASSUME_NONNULL_END
