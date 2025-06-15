//
//  CustomContextMenuView.swift
//  ContextMenu
//
//  Created by Айдар Тукаев on 24.05.2025.
//

import UIKit

public final class CustomContextMenuView: UIView {
    private unowned var parent: UIViewController
    private let preview: UIViewController
    private let menu: MenuViewProtocol
    private let menuAlignment: menuAlignment
    private let menuPosition: MenuPosition
    private let sourceView: UIView
    private let sourceSnapshot: UIView
    private var startPosition: CGPoint = .zero
    private var blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
    private var heightDiff: CGFloat = 0
    private var menuOrigin: CGPoint = .zero
    private var previewOrigin: CGPoint = .zero
    private var scaleRatioX: CGFloat = 1
    private var scaleRatioY: CGFloat = 1
    private let hasPreview: Bool
    
    private var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        
        scroll.isScrollEnabled = true
        scroll.alwaysBounceVertical = true
        scroll.bounces = true
        return scroll
    }()
    
    private var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowRadius = 32
        view.layer.shadowOffset = .zero
        view.layer.shadowOpacity = 0.2
        return view
    }()
    
    
    init(preview: UIViewController,
         menuConfiguration: MenuConfiguration,
         sourceView: UIView,
         parent: UIViewController,
         hasPreview: Bool
    ) {
        self.parent = parent
        self.preview = preview
        self.menu = menuConfiguration.menu
        self.menuAlignment = menuConfiguration.alignment
        self.menuPosition = menuConfiguration.position
        self.sourceView = sourceView
        self.hasPreview = hasPreview
        if let snapshot = sourceView.snapshotView(afterScreenUpdates: false) {
            self.sourceSnapshot = snapshot
        } else {
            self.sourceSnapshot = UIView()
        }
        
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .clear
        setupBlurEffect()
        setupScrollView()
        setupMenu()
        setupPreview()
        setupTapDismissGesture()
        if hasPreview {
            setupSourceView()
        }
    }
    
    private func setupTapDismissGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissTap(_:)))
        tapGesture.delegate = self
        addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissTap(_ sender: UITapGestureRecognizer) {
        parent.dismiss(animated: true)
    }
    
    private func setupSourceView() {
        contentView.addSubview(sourceSnapshot)
        sourceSnapshot.layer.shadowColor = UIColor.black.cgColor
    }
    
    private func setupBlurEffect() {
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(blurEffectView)
        NSLayoutConstraint.activate([
            blurEffectView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurEffectView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurEffectView.topAnchor.constraint(equalTo: topAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        blurEffectView.layer.opacity = 0
    }
    
    private func setupScrollView() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .always
    }
    
    fileprivate func setupMenu() {
        contentView.addSubview(menu)
        menu.frame = .init(origin: .zero, size: .init(width: 250, height: menu.height))
        menu.layer.cornerRadius = 12
        menu.clipsToBounds = true
        
        menu.delegate = self
    }
    
    private func setupPreview() {
        parent.addChild(preview)
        preview.view.frame = .init(origin: startPosition, size: preview.preferredContentSize)
        
        preview.view.layer.cornerRadius = 12
        preview.view.clipsToBounds = true
    
        contentView.addSubview(preview.view)
        preview.didMove(toParent: parent)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        positionContent()
    }
    
    func positionContent() {
        //MARK: Content Size
        heightDiff = menu.frame.height + preview.view.frame.height + LayoutConstants.componentsPadding - bounds.height + safeAreaInsets.bottom
        if heightDiff > 0 {
            let width = bounds.width - safeAreaInsets.left - safeAreaInsets.right
            let height = menu.frame.height + preview.view.frame.height + LayoutConstants.componentsPadding
            contentView.frame.size = .init(width: width, height: height)
            scrollView.contentSize = contentView.bounds.size
            scrollView.isScrollEnabled = true
        } else {
            let width = bounds.width
            let height = bounds.height - safeAreaInsets.top
            contentView.frame.size = .init(width: width, height: height)
            scrollView.contentSize = contentView.frame.size
            scrollView.isScrollEnabled = false
        }
        
        if case .bottom = menuPosition {
            scrollView.contentOffset.y = max(0, heightDiff)
        }
        
        //MARK: Preview Position
        self.startPosition = sourceView.convert(sourceView.bounds.origin, to: self)
        preview.view.frame = .init(origin: startPosition, size: preview.preferredContentSize)
        
        if preview.view.frame.width > frame.width - LayoutConstants.leftInset - LayoutConstants.rightInset {
            preview.view.frame.size = .init(width: frame.width - LayoutConstants.leftInset - LayoutConstants.rightInset ,
                                            height: preview.view.frame.height)
        }

        var rightPoint = preview.view.frame.maxX
        if menuAlignment == .left {
            rightPoint = max(rightPoint, preview.view.frame.origin.x + menu.frame.width)
        } else if menuAlignment == .center {
            rightPoint = max(rightPoint, preview.view.center.x - menu.frame.width / 2)
        }
        
        if rightPoint > frame.width - LayoutConstants.rightInset {
            preview.view.frame.origin.x -= rightPoint - frame.width + LayoutConstants.rightInset
        }
        
        var leftPosition = preview.view.frame.minX
        if menuAlignment == .right {
            leftPosition = min(leftPosition, preview.view.frame.maxX - menu.frame.width)
        } else if menuAlignment == .center {
            leftPosition = min(leftPosition, preview.view.frame.maxX - menu.frame.width - (preview.view.frame.width - menu.frame.width) / 2)
        }
        if leftPosition < LayoutConstants.leftInset {
            preview.view.frame.origin.x += LayoutConstants.leftInset - leftPosition
        }
        
        
        //MARK: Menu position
        switch menuPosition {
        case .bottom:
            menuOrigin.y = preview.view.frame.maxY + LayoutConstants.componentsPadding
        case .top:
            menuOrigin.y = preview.view.frame.origin.y - menu.frame.height - LayoutConstants.componentsPadding
        }
        
        if menuOrigin.y < 0 {
            preview.view.frame.origin.y += abs(menuOrigin.y)
            menuOrigin.y = 0
        } else if menuOrigin.y + menu.frame.height > contentView.frame.maxY {
            let diff = menuOrigin.y + menu.frame.height - contentView.frame.maxY
            preview.view.frame.origin.y -= diff
            menuOrigin.y -= diff
        }
        
        if preview.view.frame.maxY > contentView.frame.maxY {
            let diff = preview.view.frame.maxY - contentView.frame.maxY
            preview.view.frame.origin.y -= diff
            menuOrigin.y -= diff
        }
        
        switch menuAlignment {
        case .left:
            menuOrigin.x = preview.view.frame.origin.x
        case .right:
            menuOrigin.x = preview.view.frame.maxX - menu.frame.width
        case .center:
            menuOrigin.x = preview.view.frame.origin.x + ((preview.view.frame.width - menu.frame.width) / 2)
        }
        
        //MARK: Save state
        menu.frame.origin = menuOrigin
        previewOrigin = preview.view.frame.origin
        
        scaleRatioX = sourceView.frame.width / preview.view.frame.width
        scaleRatioY = sourceView.frame.height / preview.view.frame.height
    }
    
    func willDissmiss(){
        sourceView.layer.opacity = 1
    }
    
    func dismissFinalPosition() {
        appearanceStartPosition()
        contentView.layer.shadowOpacity = 0
    }
   
    func appearanceFinalPosition() {
        preview.view.transform = .identity
        preview.view.frame.origin = previewOrigin
        preview.view.layer.opacity = 1

        menu.layer.opacity = 1
        menu.transform = .identity
        menu.frame.origin = menuOrigin
        
        blurEffectView.layer.opacity = 1
        
        sourceSnapshot.layer.opacity = 0
        sourceSnapshot.transform = .init(scaleX: 1/scaleRatioX, y: 1/scaleRatioY)
        sourceSnapshot.frame.origin = previewOrigin
        
        contentView.layer.shadowOpacity = 0.2
    }
    
    func appearanceStartPosition() {
        sourceSnapshot.frame = sourceView.frame
        sourceSnapshot.frame.origin = .init(x: startPosition.x, y: startPosition.y + scrollView.contentOffset.y)
        sourceSnapshot.layer.opacity = 1
        sourceView.layer.opacity = 0
        
        preview.view.transform = .init(scaleX: scaleRatioX, y: scaleRatioY)
        preview.view.center = .init(x: startPosition.x + sourceView.bounds.width / 2, y: startPosition.y + scrollView.contentOffset.y + sourceView.bounds.height / 2)
        if hasPreview {
            preview.view.layer.opacity = 0
        }
        
        blurEffectView.layer.opacity = 0
        
        menu.transform = .init(scaleX: 0.1, y: 0.1)
        menu.center = .init(x: startPosition.x + sourceView.bounds.width / 2, y: startPosition.y + scrollView.contentOffset.y + sourceView.bounds.height / 2)
        menu.layer.opacity = 0

        contentView.layer.shadowOpacity = 0
    }
    
    func highlightMenu(_ location: CGPoint){
        let location = self.convert(location, to: menu)
        if location.x >= 0,
           location.x <= menu.frame.width,
           location.y >= 0,
           location.y <= menu.frame.height
        {
            menu.highlightItem(at: location)
        } else {
            menu.removeHighlight()
        }
    }

    func selectMenu(_ location: CGPoint){
        let location = self.convert(location, to: menu)
        if location.x >= 0,
           location.x <= menu.frame.width,
           location.y >= 0,
           location.y <= menu.frame.height
        {
            menu.selectItem(at: location)
            menu.removeHighlight()
        }
    }
}
    


extension CustomContextMenuView: @preconcurrency MenuViewDelegate {
    public func didDismiss() {
        parent.dismiss(animated: true)
    }
    
    public func needToResize(with height: CGFloat) {
        UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut]) {
            self.menu.frame.size = .init(width: 250, height: height)
//            self.setNeedsLayout()
        }
    }
}

extension CustomContextMenuView: UIGestureRecognizerDelegate {
    public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let location = gestureRecognizer.location(in: contentView)
        if menu.frame.contains(location) {
            return false
        } else {
            return true
        }
    }
}

fileprivate struct LayoutConstants {
    static let leftInset: CGFloat = 16
    static let rightInset: CGFloat = 16
    static let componentsPadding: CGFloat = 18
}
