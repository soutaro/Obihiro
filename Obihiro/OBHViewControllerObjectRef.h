#import "OBHViewControllerObject.h"

@interface OBHViewControllerObjectRef : NSObject

+ (instancetype)referenceWithObject:(OBHViewControllerObject *)object;
- (instancetype)initWithObject:(OBHViewControllerObject *)object;

@property (nonatomic, readonly) OBHViewControllerObject *object;
@property (nonatomic, readonly) UIViewController *viewController;

@end
