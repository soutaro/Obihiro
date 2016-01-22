#import "OBHViewControllerObject.h"

@interface OBHAlertControllerObject : OBHViewControllerObject<UIAlertController *>

- (NSString *)alertTitle;
- (NSString *)alertMessage;

- (NSArray<NSString *> *)buttonTitles;
- (void)tapAlertButtonForTitle:(NSString *)buttonTitle;

@end
