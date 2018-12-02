//
//  OpenCVWrapper.m
//  EatSafe
//
//  Created by Goldstein, Bryan (BCG Platinion) on 12/2/18.
//  Copyright © 2018 Edward Arenberg. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import <UIKit/UIKit.h>
#import "OpenCVWrapper.h"


@implementation OpenCVWrapper

-(UIImage *) preprocessImage:(UIImage *)sourceImage
{
    cv::Mat processMat;

    UIImageToMat(sourceImage, processMat);
    
    cv::Mat grayImage;
    cvtColor(processMat, grayImage, CV_BGR2GRAY);
    
    cv::Mat cannyImage;
    cv::Canny(grayImage, cannyImage, 0, 50);

    return MatToUIImage(cannyImage);
}

-(NSString *) openCVVersionString
{
    return [NSString stringWithFormat:@"OpenCV Version %s", CV_VERSION];
}

@end
