
#import <Foundation/Foundation.h>


@interface NSDate (Additions)

+ (NSDate *)dateWithLongFormatString:(NSString *)string;
- (NSString *)longFormatString;

@end
