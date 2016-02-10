#import "OBHViewControllerObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface OBHTableViewControllerObject<ViewController: UITableViewController *> : OBHViewControllerObject<ViewController>

/**
 Array of visible cells.
 */
@property (nonatomic, readonly) NSArray<__kindof UITableViewCell *> *visibleCells;

/**
 Returns visible cell at given index path.
 Returns `nil` when invisible.
 */
- (nullable __kindof UITableViewCell *)visibleCellForRowAtIndexPath:(NSIndexPath *)indexPath;

/**
 Returns cell at given index path.
 */
- (nullable __kindof UITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END