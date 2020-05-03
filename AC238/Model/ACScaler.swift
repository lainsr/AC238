//
//  ACScaler.swift
//  AC238
//
//  Created by Stéphane Rossé on 19.04.20.
//  Copyright © 2020 Stéphane Rossé. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI


final class ImageScaler {
    
    static var shared = ImageScaler()
    
    
    static func scale(_ image:UIImage, toSize newSize: CGSize, transformed with: Int, oriented deviceOrientation: UIDeviceOrientation) -> UIImage {
        
        var scaleFactor = UIScreen.main.scale

        var outputWidth: CGFloat
        var outputHeight: CGFloat
        var scaledOutputWidth: CGFloat
        var scaledOutputHeight: CGFloat
        
        if deviceOrientation.isLandscape {
            outputWidth = newSize.height
            outputHeight = newSize.width
            scaledOutputWidth = outputWidth * scaleFactor
            scaledOutputHeight = outputHeight * scaleFactor
        } else {
            outputWidth = newSize.width
            outputHeight = newSize.height
            scaledOutputWidth = outputWidth * scaleFactor
            scaledOutputHeight = outputHeight * scaleFactor
        }
        
        let imgRef = image.cgImage;
        var width = imgRef?.width
        var height = imgRef?.height
        
        var transposed:Bool = false;
        let imgOrientation = image.imageOrientation
        if imgOrientation == UIImage.Orientation.left
            || imgOrientation == UIImage.Orientation.leftMirrored
            || imgOrientation == UIImage.Orientation.right
            || imgOrientation == UIImage.Orientation.rightMirrored {
                
            let tzre = width;
            width = height;
            height = tzre;
            transposed = true;
        }
        
        let fWidth = CGFloat(Double(width!))
        let fHeight = CGFloat(Double(height!))
        if fWidth <= scaledOutputWidth && fHeight <= scaledOutputHeight {
            if scaleFactor < 1.9 {
                //*transformed = [NSNumber numberWithBool:NO];
                return image;
            } else if fWidth <= outputWidth && fHeight <= outputHeight {
                //*transformed = [NSNumber numberWithBool:NO];
                let refImage = image.cgImage!;
                return UIImage(cgImage:refImage, scale:1.0, orientation:UIImage.Orientation.up);
            } else {
                //for image beetwen 480x320 and 960x640 on retina, scale them with a sacle factor
                //of 1.0 to fill the screen with a lower quality image
                scaleFactor = 1.0;
                scaledOutputWidth = outputWidth;
                scaledOutputHeight = outputHeight;
            }
        }
        
        //*transformed = [NSNumber numberWithBool:YES];
        
        let ratio = fWidth / fHeight
        let outputRatio = scaledOutputWidth / scaledOutputHeight

        var scaledWidth = CGFloat(0.0)
        var scaledHeight = CGFloat(0.0)
        //scale to fit
        if ratio > outputRatio {
            scaledWidth = scaledOutputWidth
            scaledHeight = (fHeight * scaledOutputWidth) / fWidth
        } else {
            scaledWidth = (fWidth * scaledOutputHeight) / fHeight
            scaledHeight = scaledOutputHeight
        }
            
        if(scaledWidth < 1) {
            scaledWidth = 1
        }
        if(scaledHeight < 1) {
            scaledHeight = 1
        }
        
        let refImage = image.cgImage!;
        let context = CGContext(data: nil, width: Int(scaledWidth), height: Int(scaledHeight),
                                bitsPerComponent: refImage.bitsPerComponent, bytesPerRow: refImage.bytesPerRow,
                                space: refImage.colorSpace ?? CGColorSpace(name: CGColorSpace.sRGB)!,
                                bitmapInfo: refImage.bitmapInfo.rawValue)

        let flip = false
        let scaledSize = CGSize(width: scaledWidth, height: scaledHeight)
        let transformation = transformForOrientation(scaledSize, of:image, flipImage:flip)
        context?.concatenate(transformation)
        
        var rect = CGRect(x:0, y:0, width:scaledWidth, height:scaledHeight)
        if(transposed) {
            rect = CGRect(x:0, y:0, width:scaledHeight, height:scaledWidth)
        }
        
        context?.draw(refImage, in: rect)
        if let refNewImage = context?.makeImage() {
            if(scaleFactor < 1.9) {
                return UIImage(cgImage:refNewImage)
            } else {
                return UIImage(cgImage:refNewImage, scale:scaleFactor, orientation:UIImage.Orientation.up)
            }
        }
        
        return UIImage()
    }
    
    static func transformForOrientation(_ newSize: CGSize, of image: UIImage, flipImage flip: Bool) -> CGAffineTransform {
        var transform = CGAffineTransform.identity
        
        let imageOrientation = image.imageOrientation
        if imageOrientation == UIImage.Orientation.down || imageOrientation == UIImage.Orientation.downMirrored {
            // EXIF = 3 // EXIF = 4
            transform = transform.translatedBy(x: newSize.width, y: newSize.height)
            transform = transform.rotated(by: CGFloat.pi)
        } else if imageOrientation == UIImage.Orientation.left || imageOrientation == UIImage.Orientation.leftMirrored {
            // EXIF = 6  // EXIF = 5
            transform = transform.translatedBy(x: newSize.width, y: 0.0);
            transform = transform.rotated(by: CGFloat.pi / 2.0);
        } else if imageOrientation == UIImage.Orientation.right || imageOrientation == UIImage.Orientation.rightMirrored {
            // EXIF = 8  // EXIF = 7
            transform = transform.translatedBy(x: 0.0, y: newSize.height);
            transform = transform.rotated(by: -1.0 * CGFloat.pi / 2.0);
        } else if imageOrientation == UIImage.Orientation.up || imageOrientation == UIImage.Orientation.upMirrored {
            //do nothing
        }
        
        /*
        if(flip) {
            switch (image.imageOrientation) {
                case UIImageOrientationUp:            // EXIF = 1
                case UIImageOrientationDown:          // EXIF = 3
                    transform = CGAffineTransformTranslate(transform, 0.0, newSize.height);
                    transform = CGAffineTransformScale(transform, 1.0, -1.0);
                    break;
                    
                case UIImageOrientationUpMirrored:    // EXIF = 2
                case UIImageOrientationDownMirrored:  // EXIF = 4
                    transform = CGAffineTransformTranslate(transform, newSize.width, newSize.height);
                    transform = CGAffineTransformScale(transform, -1.0, -1.0);
                    break;
                
                case UIImageOrientationLeftMirrored:  // EXIF = 5
                case UIImageOrientationRightMirrored: // EXIF = 7
                    break;
                    
                case UIImageOrientationLeft:          // EXIF = 6
                case UIImageOrientationRight:         // EXIF = 8
                    transform = CGAffineTransformTranslate(transform, newSize.height, 0.0);
                    transform = CGAffineTransformScale(transform, -1.0, 1.0);
                    break;
            }
        } else {
            switch (image.imageOrientation) {
                case UIImageOrientationUpMirrored:     // EXIF = 2
                case UIImageOrientationDownMirrored:   // EXIF = 4
                    transform = CGAffineTransformTranslate(transform, newSize.width, 0.0);
                    transform = CGAffineTransformScale(transform, -1, 1);
                    break;
                
                case UIImageOrientationLeftMirrored:   // EXIF = 5
                case UIImageOrientationRightMirrored:  // EXIF = 7
                    transform = CGAffineTransformTranslate(transform, newSize.height, 0.0);
                    transform = CGAffineTransformScale(transform, -1.0, 1.0);
                    break;

                case UIImageOrientationUp:
                case UIImageOrientationDown:
                case UIImageOrientationLeft:
                case UIImageOrientationRight:
                    //do nothing
                    break;
            }
        }
 */
        return transform;
    }

}
