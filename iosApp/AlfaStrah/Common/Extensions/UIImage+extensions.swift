//
//  UIImage+tint.swift
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 19.04.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import UIKit

extension UIImage {
    static func backgroundImage(withColor color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        UIGraphicsBeginImageContext(size)

        color.setFill()
        UIGraphicsGetCurrentContext()?.fill(CGRect(origin: .zero, size: size))

        let image = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()

        if let image = image {
            return image
        } else {
            return UIImage()
        }
    }

    static func tintedImage(withName name: String, tintColor: UIColor) -> UIImage? {
        UIImage(named: name)?.tintedImage(withColor: tintColor)
    }
	
    func tintedImage(withColor color: UIColor) -> UIImage {
		guard self.size != .zero
		else { return UIImage() }
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0.0)

        color.set()

        let rect = CGRect(origin: CGPoint.zero, size: self.size)
        UIRectFillUsingBlendMode(rect, CGBlendMode.screen)
		draw(in: rect, blendMode: CGBlendMode.destinationIn, alpha: 1.0)

        let image = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()

        if let image = image {
            return image
        } else {
            return UIImage()
        }
    }

    var roundedImage: UIImage? {
		if size == .zero {
			return nil
		}
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 1)
        UIBezierPath(
            roundedRect: rect,
            cornerRadius: size.height
        ).addClip()
        draw(in: rect)
        return UIGraphicsGetImageFromCurrentImageContext()
    }

    // caution with ceil() - give visible errors on image bounds calculations with scaling operation
    func resized(newWidth: CGFloat, insets: UIEdgeInsets = .zero) -> UIImage? {
		return resized(scale: newWidth / size.width, insets: insets)
    }
	
	func resized(scale: CGFloat, insets: UIEdgeInsets = .zero) -> UIImage {
		let newHeight = size.height * scale
		let newWidth = size.width * scale
		
		let frameSize = CGSize(width: newWidth, height: newHeight)
		
		let targetSize = CGSize(
			width: newWidth - insets.left - insets.right,
			height: newHeight - insets.top - insets.bottom
		)
		
		var targetOrigin: CGPoint = .zero

		if insets != .zero {
			targetOrigin = CGPoint(
				x: insets.left,
				y: insets.top
			)
		}
		
		return UIGraphicsImageRenderer(size: frameSize).image { _ in
			self.draw(
				in: CGRect(
					origin: targetOrigin,
					size: targetSize
				)
			)
		}
	}

    static func from(
        color: UIColor,
        size: CGSize = CGSize(width: 1, height: 1),
        opaque: Bool = false,
        scale: CGFloat = 0,
        cornerRadius: CGFloat = 0
    ) -> UIImage {
        // rendering zero size image leads to crash since iOS 17
        guard size.width > 0,
              size.height > 0
        else { return .init() }
        
        let rect = CGRect(origin: .zero, size: size)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).cgPath
        
        UIGraphicsBeginImageContextWithOptions(rect.size, opaque, scale)
        
        guard let context = UIGraphicsGetCurrentContext()
        else { return UIImage() }
        
        context.addPath(path)
        context.setFillColor(color.cgColor)
        
        context.closePath()
        context.fillPath()
        
        defer { UIGraphicsEndImageContext() }
        
        if let image = UIGraphicsGetImageFromCurrentImageContext() {
            return image
        } else {
            return UIImage()
        }
    }
    
    static func gradientImage(from beginColor: UIColor, to endColor: UIColor, with frame: CGRect) -> UIImage {
		// rendering zero size image leads to crash since iOS 17
		guard frame.size != .zero
		else { return UIImage() }
		
        let layer = CAGradientLayer()
        
        layer.frame = frame
        layer.colors = [beginColor.cgColor, endColor.cgColor]
        
        UIGraphicsBeginImageContext(CGSize(width: frame.width, height: frame.height))
        
        guard let context = UIGraphicsGetCurrentContext()
        else { return UIImage() }
        
        layer.render(in: context)
   
        defer { UIGraphicsEndImageContext() }
        
        if let image = UIGraphicsGetImageFromCurrentImageContext() {
            return image
        } else {
            return UIImage()
        }
    }
    
	func overlay(with image: UIImage, insets: UIEdgeInsets = .zero) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: self.size)
        
        let image = renderer.image { _ in
            let size = renderer.format.bounds.size
			let newSize = CGSize(
				width: size.width - 1 - insets.left - insets.right,
				height: size.height - 1 - insets.top - insets.bottom
			) /// - 1 fix image bounds cutting edge on export with .zero insets
            
			image.draw(in:
				CGRect(
					origin: CGPoint(
						x: 0.5 + insets.left,
						y: 0.5 + insets.top
					),
					size: newSize
				)
			)
            self.draw(in: CGRect(origin: .zero, size: size))
        }
        
        return image
    }
}
