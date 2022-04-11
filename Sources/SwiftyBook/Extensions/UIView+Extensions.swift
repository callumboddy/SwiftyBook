//
//  UIView+Extensions.swift
//  
//
//  Created by Callum Boddy on 17/01/2022.
//

import Foundation
import UIKit

extension UIView {
    public func convertedToImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}
