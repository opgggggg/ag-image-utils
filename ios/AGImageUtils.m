#import "RNImageUtils.h"

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
    CGImageRef reference = CGImageCreateWithImageInRect([targetImage CGImage], cropTarget);

    UIImage *cropped = [UIImage imageWithCGImage:reference];
  
    if (width != destWidth || height != destHeight) {
        UIGraphicsBeginImageContext(CGSizeMake(destWidth, destHeight));
        [cropped drawInRect:CGRectMake(0, 0, destWidth, destHeight)];
        cropped = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }

    NSData *rawImageData = nil;
    if ([format isEqual:@"png"]) {
        rawImageData = UIImagePNGRepresentation(cropped);
    } else {
        rawImageData = UIImageJPEGRepresentation(cropped, quality / 100.0);
    }
    CGImageRelease(reference);

    NSError *error = nil;
    NSURL *temporaryFileURL = [NSURL fileURLWithPath:savePath];
    [rawImageData writeToURL:temporaryFileURL options:NSDataWritingAtomic error:&error];
    if (error) {
        reject(@"Failed to Save", @"Failed to save image", error);
    } else {
        resolve([temporaryFileURL absoluteString]);
    }
}

@end
