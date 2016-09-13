//
//  UIImage+Category.swift
//  PicturesToChoose
//
//  Created by bocai on 16/9/13.
//  Copyright © 2016年 bocai. All rights reserved.
//

import UIKit

extension UIImage{
    
    func imageWithScale(width:CGFloat) -> UIImage
    {
        //根据宽度计算高度
        let height = width * size.height / size.width
        //按照宽高比绘制一张新的图片
        let currentSize = CGSize(width: width, height: height)
        UIGraphicsBeginImageContext(currentSize)
        drawInRect(CGRect(origin: CGPointZero, size: currentSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
}
