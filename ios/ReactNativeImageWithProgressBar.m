// ReactNativeImageWithProgressBar.m

#import "ReactNativeImageWithProgressBar.h"
#import "PIRImageWithSpinner.h"

@implementation ReactNativeImageWithProgressBar

RCT_EXPORT_MODULE(ImageWithSpinner);

- (UIView *)view {
  return [[PIRImageWithSpinner alloc] init];
}

RCT_EXPORT_VIEW_PROPERTY(onLoadError, RCTBubblingEventBlock);

RCT_CUSTOM_VIEW_PROPERTY(imageUrl, NSString, PIRImageWithSpinner){
  [view loadImageUrlString:[RCTConvert NSString:json]];
}


-(UIColor *)getUIColorForInt:(int)colorInInt{
  UIColor *color = [UIColor colorWithRed:((float)((colorInInt & 0xFF0000) >> 16))/255.0
                             green:((float)((colorInInt & 0xFF00) >> 8))/255.0
                              blue:((float)(colorInInt & 0xFF))/255.0
                             alpha:((float)((colorInInt & 0xFF000000) >> 24))/255.0];
  return color;
}


RCT_CUSTOM_VIEW_PROPERTY(barColorInt, int, PIRImageWithSpinner){
  int colorInInt = [RCTConvert int:json];
  UIColor *color = [self getUIColorForInt:colorInInt];
  [view setProgressBarColorWithUIColor:color];
}

RCT_CUSTOM_VIEW_PROPERTY(trackColorInt, int, PIRImageWithSpinner){
  int colorInInt = [RCTConvert int:json];
  UIColor *color = [self getUIColorForInt:colorInInt];
  [view setProgressBarTrackColorWithUIColor:color];
}



RCT_CUSTOM_VIEW_PROPERTY(alternativeColor, NSString, PIRImageWithSpinner){
  
  long rgbValue = 4282811060;
  UIColor *color = [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0
                             green:((float)((rgbValue & 0xFF00) >> 8))/255.0
                              blue:((float)(rgbValue & 0xFF))/255.0
                             alpha:((float)((rgbValue & 0xFF000000) >> 24))/255.0];
  [view setBackgroundColor:color];
}

RCT_CUSTOM_VIEW_PROPERTY(mode, NSString, PIRImageWithSpinner){
  
  NSString *string = [RCTConvert NSString:json];
  if([string isEqualToString:@"spinner"] || [string isEqualToString:@"bar"]){
    [view updateMode:string];
  } else {
    NSString *message = [NSString stringWithFormat:@"Wrong mode prop passed to an instance of the component exported by react-native-image-with-progress-bar\n\nAvailable modes are \"bar\" and \"spinner\"\n\nReceived: \"%@\"", string];
    RCTLogError(message);
  }
}

@end
