//
//  main.m
//  URLEncode
//
//  Created by YZK on 2023/9/1.
//

#import <Foundation/Foundation.h>

@interface NSCharacterSet (YZKCharacters)
- (NSString *)allCharacters;
@end

@implementation NSCharacterSet (YZKCharacters)

- (NSString *)allCharacters {
    NSMutableArray *array = [NSMutableArray array];
    for (int plane = 0; plane <= 16; plane++) {
        if ([self hasMemberInPlane:plane]) {
            UTF32Char c;
            for (c = plane << 16; c < (plane+1) << 16; c++) {
                if ([self longCharacterIsMember:c]) {
                    UTF32Char c1 = OSSwapHostToLittleInt32(c); // To make it byte-order safe
                    NSString *s = [[NSString alloc] initWithBytes:&c1 length:4 encoding:NSUTF32LittleEndianStringEncoding];
                    [array addObject:s];
                }
            }
        }
    }
    return [array componentsJoinedByString:@""];
}

@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {        
        // 方式一编码
        NSString *urlStr = @"你好0123456789abcxyzABCXYZ-_.~&!*'();:@&=+$,/?#[]% ";
        NSString *encodingString = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"url编码 = %@",encodingString);
        
        // 方式二编码，定义一个需要转义的合法字符集
        // 定义空字符集
        NSString *encodeStr = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)urlStr, NULL, (CFStringRef)@"", kCFStringEncodingUTF8));
        NSLog(@"url编码2-1 = %@",encodeStr);

        // 定义 :!*();@/&?+$,=' 字符集
        NSString *encodeStr2 = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)urlStr, NULL, (CFStringRef)@":!*();@/&?+$,='", kCFStringEncodingUTF8));
        NSLog(@"url编码2-2 = %@",encodeStr2);
        
        // 方式三编码
        NSString *encodeStr3 = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSLog(@"url编码3-1 = %@",encodeStr3);

        NSCharacterSet *characterSet1 = [NSCharacterSet characterSetWithCharactersInString:@"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-_.~"];
        NSString *encodeStr4 = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:characterSet1];
        NSLog(@"url编码3-2 = %@",encodeStr4);

        NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:@""];
        NSString *encodeStr5 = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:characterSet];
        NSLog(@"url编码3-3 = %@",encodeStr5);
        
        
        
        NSString *decodedString = [encodingString stringByRemovingPercentEncoding];
        NSLog(@"url解码 = %@",decodedString);
        
        NSString *decodedStr2 = [encodeStr2 stringByRemovingPercentEncoding];
        NSLog(@"url解码2-2 = %@",decodedStr2);
        
        NSString *decodedStr3 = [encodeStr5 stringByRemovingPercentEncoding];
        NSLog(@"url解码3-3 = %@",decodedStr3);

        
        NSString *decodedStr4 = [@"%HJ" stringByRemovingPercentEncoding];
        NSLog(@"url解码4-1 = %@",decodedStr4);
    }
    return 0;
}
