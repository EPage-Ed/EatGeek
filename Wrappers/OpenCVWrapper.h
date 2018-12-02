//
//  OpenCVWrapper.h
//  EatSafe
//
//  Created by Goldstein, Bryan (BCG Platinion) on 12/2/18.
//  Copyright © 2018 Edward Arenberg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface OpenCVWrapper : NSObject
-(UIImage *) preprocessImage:(UIImage *)sourceImage;
-(NSString *) openCVVersionString;
@end

NS_ASSUME_NONNULL_END
