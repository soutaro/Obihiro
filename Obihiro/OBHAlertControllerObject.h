#import "OBHViewControllerObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface OBHAlertControllerObject : OBHViewControllerObject<UIAlertController *>

- (nullable NSString *)alertTitle;
- (nullable NSString *)alertMessage;

- (NSArray<NSString *> *)buttonTitles;
- (void)tapAlertButtonForTitle:(NSString *)buttonTitle;

@end

NS_ASSUME_NONNULL_END
