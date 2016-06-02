#import "OBHViewControllerObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface OBHNavigationControllerObject : OBHViewControllerObject<UINavigationController *>

- (BOOL)hasTopViewControllerOfClass:(Class)klass;

+ (instancetype)objectWithEmptyNavigationController;

#pragma mark - Navigation Stack

- (void)pushViewControllerObject:(OBHViewControllerObject *)object;
- (void)pushViewController:(UIViewController *)viewController;

- (nullable __kindof OBHViewControllerObject *)topObject;

- (nullable __kindof OBHViewControllerObject *)topObjectOfViewControllerClass:(Class)klass;

#pragma mark -

@property (nonatomic, readonly) OBHUIPredicate *backButtonPresented;
@property (nonatomic, readonly) OBHUIPredicate *leftButtonPresented;
@property (nonatomic, readonly) OBHUIPredicate *rightButtonPresented;

@property (nonatomic, readonly) OBHUIPredicate *leftButtonAvailable;
@property (nonatomic, readonly) OBHUIPredicate *rightButtonAvailable;

@property (nonatomic, readonly) BOOL hasBackButton __deprecated;
@property (nonatomic, readonly) BOOL isBackButtonHidden __deprecated;

@property (nonatomic, readonly) BOOL hasLeftButton __deprecated;
@property (nonatomic, readonly) BOOL isLeftButtonHidden __deprecated;

@property (nonatomic, readonly) BOOL hasRightButton __deprecated;
@property (nonatomic, readonly) BOOL isRightButtonHidden __deprecated;

@property (nonatomic, readonly) BOOL isLeftButtonAvailable __deprecated;
@property (nonatomic, readonly) BOOL isLeftButtonUnavailable __deprecated;

@property (nonatomic, readonly) BOOL isRightButtonAvailable __deprecated;
@property (nonatomic, readonly) BOOL isRightButtonUnavailable __deprecated;

- (void)tapRightButton;

#pragma mark - Navigation

- (void)back;

@end

NS_ASSUME_NONNULL_END
