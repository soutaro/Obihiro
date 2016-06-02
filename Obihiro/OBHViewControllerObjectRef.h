#import "OBHViewControllerObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface OBHViewControllerObjectRef : NSObject

+ (instancetype)referenceWithObject:(OBHViewControllerObject *)object;
- (instancetype)initWithObject:(OBHViewControllerObject *)object;

@property (nonatomic, readonly) OBHViewControllerObject *object;
@property (nonatomic, readonly) UIViewController *viewController;

@end

NS_ASSUME_NONNULL_END
