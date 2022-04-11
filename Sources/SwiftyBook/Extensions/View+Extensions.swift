//
//  View+Extensions.swift
//  
//
//  Created by Callum Boddy on 17/01/2022.
//

import Foundation
import UIKit
import SwiftUI

extension View {
    internal func convertedToImage() -> UIImage {
        let controller = UIHostingController(rootView: self.padding())
        controller.view.frame = .zero
        UIApplication.shared.windows.first!.rootViewController?.view.addSubview(controller.view)
        let size = controller.sizeThatFits(in: UIScreen.main.bounds.size)
        controller.view.bounds = CGRect(origin: .zero, size: size)
        controller.view.backgroundColor = .clear
        controller.view.sizeToFit()
        controller.view.frame = CGRect(x: 0, y: 0, width: controller.view.frame.width, height: controller.view.frame.height)
        let image = controller.view.convertedToImage()
        controller.view.removeFromSuperview()
        return image
    }
}
