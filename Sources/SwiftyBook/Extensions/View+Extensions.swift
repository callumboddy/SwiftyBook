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

    @MainActor
    internal func convertedToImage(delay: TimeInterval = 0) async -> UIImage {
            let controller = UIHostingController(rootView: self)
            controller.view.frame = .zero
            UIApplication.shared.windows.first!.rootViewController?.view.addSubview(controller.view)
            let size = controller.sizeThatFits(in: UIScreen.main.bounds.size)
            controller.view.bounds = CGRect(origin: .zero, size: size)
            controller.view.backgroundColor = .white
            controller.view.sizeToFit()
            controller.view.frame = CGRect(x: 0, y: 0, width: controller.view.frame.width, height: controller.view.frame.height)

        return await withCheckedContinuation { continuation in
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                let image = controller.view.convertedToImage()
                controller.view.removeFromSuperview()
                continuation.resume(with: .success(image))
            }
        }
    }
}
