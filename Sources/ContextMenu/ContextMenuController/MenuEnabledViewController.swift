//
//  MenuEnabledViewController.swift
//  ContextMenu
//
//  Created by Айдар Тукаев on 24.05.2025.
//

import UIKit

open class MenuEnabledViewController: UIViewController, UIGestureRecognizerDelegate, @preconcurrency MenuViewDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    public func needToResize(with height: CGFloat) {
        // TODO
    }

    public func didDismiss() {
        if let presented = presentedViewController {
            presented.dismiss(animated: false)
        }
    }
}
