#import "AGImageUtils.h"

@implementation AGImageUtils

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(crop:(NSString *) path
                  options:(NSDictionary *) opts
                  resolve:(RCTPromiseResolveBlock) resolve
                  reject:(RCTPromiseRejectBlock) reject) {
    NSInteger x = [RCTConvert NSInteger:opts[@"x"]] ?: 0;
    NSInteger y = [RCTConvert NSInteger:opts[@"y"]] ?: 0;
    NSInteger width = [RCTConvert NSInteger:opts[@"width"]];
    NSInteger height = [RCTConvert NSInteger:opts[@"height"]];
    NSInteger destWidth = [RCTConvert NSInteger:opts[@"dest_width"]] ?: width;
    NSInteger destHeight = [RCTConvert NSInteger:opts[@"dest_height"]] ?: height;
    NSInteger quality = [RCTConvert NSInteger:opts[@"quality"]] ?: 100;
    NSString *format = [RCTConvert NSString:opts[@"format"]] ?: @"jpg";
    NSString *savePath = [RCTConvert NSString:opts[@"save_path"]] ?: nil;
  
    if (!savePath) {
        reject(@"Bad request", @"save_path is required", nil);
        return;
    }

    CGRect cropTarget = CGRectMake(x, y, width, height);
    UIImage *targetImage = [UIImage imageWithContentsOfFile:path];
    if (!targetImage) {
        reject(@"Bad request", [NSString stringWithFormat:@"invalid source image path:%s", path], nil);
        return;
    }

    CGImageRef reference = CGImageCreateWithImageInRect([targetImage CGImage], cropTarget);

    UIImage *cropped = [UIImage imageWithCGImage:reference];
    if (!cropped) {
        reject(@"Bad request", [NSString stringWithFormat:@"invalid crop position:%d %d %d %d", x, y, width, height], nil);
        return;
    }
  
    if (width != destWidth || height != destHeight) {
        UIGraphicsBeginImageContext(CGSizeMake(destWidth, destHeight));
        [cropped drawInRect:CGRectMake(0, 0, destWidth, destHeight)];
        cropped = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }

    NSData *rawData = nil;
    if ([format isEqual:@"png"]) {
        rawData = UIImagePNGRepresentation(cropped);
    } else {
        rawData = UIImageJPEGRepresentation(cropped, quality / 100.0);
    }

    CGImageRelease(reference);
    if ([rawData writeToFile:savePath atomically:YES]) {
        resolve(savePath);
    } else {
        reject(@"Failed to Save", [@"Failed to save image" stringByAppendingString:savePath], nil);
    }
}

@end
