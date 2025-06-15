//
//  CustomContextMenu.swift
//  ContextMenu
//
//  Created by Айдар Тукаев on 24.05.2025.
//

import UIKit

public final class CustomContextMenu: UIViewController {
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    private var customView: CustomContextMenuView!
    private let transitionDelegate = ContextMenuTransitioningDelegate()

    convenience init(_ previewController: UIViewController, menuConfiguration: MenuConfiguration, sourceView: UIView) {
        self.init(previewController, menuConfiguration: menuConfiguration, sourceView: sourceView, hasPreview: true)
    }
    
    convenience init(_ previewView: UIView, menuConfiguration: MenuConfiguration, sourceView: UIView) {
        let vc = DummyPreviewVC(previewView)
        self.init(vc, menuConfiguration: menuConfiguration, sourceView: sourceView, hasPreview: true)
    }
    
    convenience init(menuConfiguration: MenuConfiguration, sourceView: UIView) {
        let snapshot = sourceView.snapshotView(afterScreenUpdates: true) ?? UIView()
        let preview = DummyPreviewVC(snapshot)
        self.init(preview, menuConfiguration: menuConfiguration, sourceView: sourceView, hasPreview: false)
    }
    
    private init(_ previewController: UIViewController, menuConfiguration: MenuConfiguration, sourceView: UIView, hasPreview: Bool) {
        super.init(nibName: nil, bundle: nil)
        customView = CustomContextMenuView(preview: previewController, menuConfiguration: menuConfiguration, sourceView: sourceView, parent: self, hasPreview: hasPreview)
        self.modalPresentationStyle = .overCurrentContext
        self.transitioningDelegate = transitionDelegate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func loadView() {
        self.view = customView
        
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
   
    func dismissFinalPosition() {
        customView.dismissFinalPosition()
    }
    
    func willDissmiss() {
        customView.willDissmiss()
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        view.frame.size = size
        view.setNeedsLayout()
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    public override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        feedbackGenerator.impactOccurred()
    }
   
    func appearanceFinalPosition() {
        customView.appearanceFinalPosition()
    }
    
    func appearanceStartPosition() {
        customView.appearanceStartPosition()
    }

    
    func highlightMenu(_ location: CGPoint){
        customView.highlightMenu(location)
    }

    func selectMenu(_ location: CGPoint){
        customView.selectMenu(location)
    }
}

final private class CustomContextMenuAppearingAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func animateTransition(using transitionContext: any UIViewControllerContextTransitioning) {
        guard let toVC = transitionContext.viewController(forKey: .to) as? CustomContextMenu , let toView = toVC.view else { return }
        
        let containerView = transitionContext.containerView
        containerView.addSubview(toView)
        toView.frame = containerView.bounds
        toView.layoutIfNeeded()
        toView.layer.opacity = 1
        print(toView.frame)
        toVC.appearanceStartPosition()
        
        UIView.animate(withDuration: 0.4,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.8,
                       options: [.curveEaseInOut],
                       animations: {
            toVC.appearanceFinalPosition()
        }, completion: { finished in
            transitionContext.completeTransition(true)
        })
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        0.4
    }
}

final private class CustomContextMenuDisappearingAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func animateTransition(using transitionContext: any UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from) as? CustomContextMenu , let fromView = fromVC.view else { return }
        
        let containerView = transitionContext.containerView
        containerView.addSubview(fromView)
        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       options: [.curveEaseInOut],
                       animations: {
            fromVC.dismissFinalPosition()
        }, completion: { finished in
            fromVC.willDissmiss()
            fromView.removeFromSuperview()
            transitionContext.completeTransition(finished)
        })
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        0.2
    }
}

final private class ContextMenuTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
        return CustomContextMenuAppearingAnimator()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
        return CustomContextMenuDisappearingAnimator()
    }
}

final private class DummyPreviewVC: UIViewController {
    init(_ preview: UIView) {
        super.init(nibName: nil, bundle: nil)
        self.view = preview
        if preview.intrinsicContentSize.width > 0 {
            preferredContentSize = preview.intrinsicContentSize
        } else {
            preferredContentSize = preview.frame.size
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


