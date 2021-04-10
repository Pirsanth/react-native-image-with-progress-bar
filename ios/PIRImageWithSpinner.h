//
//  PIRImageWithSpinner.h
//  loadingImageIos
//
//  Created by Pirsanth on 24/03/2021.
//

#import <Foundation/Foundation.h>
#import <React/RCTViewManager.h>

NS_ASSUME_NONNULL_BEGIN


@interface PIRImageWithSpinner : UIView
@property (nonatomic, copy) RCTBubblingEventBlock onLoadError;

//Designated intitializer
- (instancetype)init;

-(void)loadImageUrlString:(NSString *)imageUrlString;

-(void)updateMode:(NSString *)mode;

-(void)setProgressBarColorWithUIColor:(UIColor *)color;
-(void)setProgressBarTrackColorWithUIColor:(UIColor *)color;

@end

NS_ASSUME_NONNULL_END
