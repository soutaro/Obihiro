#import "OBHViewControllerObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface OBHViewControllerObject (Private)

- (__kindof OBHViewControllerObject *)childObjectWithViewController:(UIViewController *)viewController;

- (void)cacheObject:(OBHViewControllerObject *)object;

@end

NS_ASSUME_NONNULL_END
