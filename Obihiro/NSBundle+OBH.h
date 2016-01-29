#import <Foundation/Foundation.h>

@interface NSBundle (OBH)

/**
 Specify name of .lproj bundle to be used localization of string via `NSLocalizedString`.
 
 @param localeString Name of .lproj, or nil to clear.
 */
+ (void)setMessageLocalizationLocale:(NSString *)localeString;

@end
