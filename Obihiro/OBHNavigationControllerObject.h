#import "OBHViewControllerObject.h"

@interface OBHNavigationControllerObject : OBHViewControllerObject<UINavigationController *>

- (BOOL)hasTopViewControllerOfClass:(Class)klass;

+ (instancetype)objectWithEmptyNavigationController;

#pragma mark - Navigation Stack

- (void)pushViewControllerObject:(OBHViewControllerObject *)object;
- (void)pushViewController:(UIViewController *)viewController;

- (__kindof OBHViewControllerObject *)topObject;

- (__kindof OBHViewControllerObject *)topObjectOfViewControllerClass:(Class)klass;

#pragma mark -

@property (nonatomic, readonly) BOOL hasBackButton;
@property (nonatomic, readonly) BOOL hasLeftButton;
@property (nonatomic, readonly) BOOL hasRightButton;

@property (nonatomic, readonly) BOOL isLeftButtonAvailable;
@property (nonatomic, readonly) BOOL isRightButtonAvailable;

- (void)tapRightButton;

#pragma mark - Navigation

- (void)back;

@end
