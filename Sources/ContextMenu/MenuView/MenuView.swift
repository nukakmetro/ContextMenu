//
//  MenuView.swift
//  ContextMenu
//
//  Created by Айдар Тукаев on 24.05.2025.
//

import UIKit

public protocol MenuViewDelegate: AnyObject {
    func didDismiss()
    func needToResize(with height: CGFloat)
}

// MARK: - MenuViewProtocol
public protocol MenuViewProtocol: UIView {
    var sectionItems: [CustomSectionitem] { get }
    func didSelect(item: CustomMenuItem)
    func highlightItem(at location: CGPoint)
    func selectItem(at location: CGPoint)
    func removeHighlight()
    func update(with menuItem: CustomMenuItem)
    var height: CGFloat { get }
    var delegate: MenuViewDelegate? { get set }
}

// MARK: - MenuView
public final class MenuView: UIView, MenuViewProtocol {
    // MARK: - Properties
    public var isScrollEnabled: Bool = true { // по умолчанию отключен
        didSet {
            collectionView.isScrollEnabled = isScrollEnabled
        }
    }
    
    public var height: CGFloat {
        return calculateTableHeight()
    }
    
    public var sectionItems: [CustomSectionitem] = [] {
        didSet {
//            updateSnapshot()
        }
    }
    
    weak public var delegate: MenuViewDelegate?


    private lazy var collectionView: UICollectionView = {
        return UICollectionView()
    }()
    private var dataSource: UICollectionViewDiffableDataSource<Int, CustomMenuItem>?

    var panGestureRecognizer: UIPanGestureRecognizer?


    // MARK: - Initialization
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public init(menu: CustomMenu, delegate: MenuViewDelegate? = nil) {
        self.sectionItems = menu.sectionItems
        self.delegate = delegate
        super.init(frame: .zero)
        isUserInteractionEnabled = true
        
        let effect = UIBlurEffect(style: .systemChromeMaterial)
        let visualEffectView = UIVisualEffectView(effect: effect)
        visualEffectView.alpha = 1
        visualEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(visualEffectView)
        
        self.setupCollectionView()
        self.configureDataSource()

        self.setupPanGestureRecognizer()

        updateSnapshot()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Collection View
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: getCollectionViewLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.layer.cornerRadius = 12
        collectionView.clipsToBounds = true
        isScrollEnabled.toggle()
        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // MARK: - UICollectionViewCompositionalLayout
    
    private func getCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { sectionIndex, environment in
            let sectionItem = self.sectionItems[sectionIndex]
            let section = self.createSectionLayout(for: sectionItem)
            
            if sectionIndex != 0 {
                let headerSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(Constraints.sectionDividerHeight))
                let header = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerSize,
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )
                header.pinToVisibleBounds = false
                section.boundarySupplementaryItems = [header]
            }
            
            return section
        }
    }

    private func createSectionLayout(for section: any CustomSectionItemProtocol) -> NSCollectionLayoutSection {
        
        let itemHeights = calculateItemsHeight(with: section)
        
        let spacings = CGFloat(max(0, itemHeights.count - 1)) * Constraints.menuItemSeparatorHeight
        let groupHeight = itemHeights.reduce(0, +) + spacings
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(groupHeight))
        
        let group = NSCollectionLayoutGroup.custom(layoutSize: groupSize) { environment in
            let contentInsets = environment.container.contentInsets
            let containerWidth = environment.container.effectiveContentSize.width
            
            return itemHeights.reduce(into: []) { result, itemHeight in
                let yOffset = result.last?.frame.maxY ?? 0
                let item = NSCollectionLayoutGroupCustomItem(
                    frame: .init(
                        origin: .init(x: contentInsets.leading, y: yOffset),
                        size: .init(width: containerWidth, height: itemHeight)
                    ),
                    zIndex: result.count
                )
                
                result.append(item)
            }
        }
        let section = NSCollectionLayoutSection(group: group)
        
        return section
        
    }
    
    private func calculateItemsHeight(with section: any CustomSectionItemProtocol) -> [CGFloat] {
        let rowHeightArray = section.items.map { $0.title.boundingRectangle(
            withMaximumWidth: Constraints.menuWidth - (Constraints.Padding.leading * 2 + Constraints.Padding.trailing + Constraints.imageSize),
            font: Constraints.font)
        .height
        }
        return rowHeightArray.map { $0 + Constraints.Padding.bottom + Constraints.Padding.top }
    }
    
    private func calculateTableHeight() -> CGFloat {
        var totalHeight: CGFloat = -Constraints.sectionDividerHeight
        
        for section in sectionItems {
            totalHeight += calculateItemsHeight(with: section).reduce(0, +)
            totalHeight += Constraints.sectionDividerHeight
        }
        return totalHeight
    }
    // MARK: - Configure Data Source
    private func configureDataSource() {

        collectionView.register(CustomMenuViewCell.self, forCellWithReuseIdentifier: "CustomMenuViewCell")
        collectionView.register(SectionDivider.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: "SectionDivider")
        
        dataSource = UICollectionViewDiffableDataSource<Int, CustomMenuItem>(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomMenuViewCell", for: indexPath) as? CustomMenuViewCell else {
                return nil
            }
            
            let isLastItem = indexPath.item == (self.sectionItems[indexPath.section].items.count - 1)
            cell.configure(with: itemIdentifier, isLastItem: isLastItem)
            collectionView.layoutIfNeeded()
            
            return cell
        }
        
        dataSource?.supplementaryViewProvider = { collectionView, kind, indexPath in
            if kind == UICollectionView.elementKindSectionHeader {
                let header = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: "SectionDivider",
                    for: indexPath
                ) as? SectionDivider
                return header
            }
            return nil
        }
        
        collectionView.layoutIfNeeded()

        collectionView.delegate = self
    }
    
    // MARK: - Update Snapshot
    private func updateSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, CustomMenuItem>()
        for (index, sectionItem) in sectionItems.enumerated() {
            snapshot.appendSections([index])
            snapshot.appendItems(sectionItem.items, toSection: index)
        }
        dataSource?.apply(snapshot, animatingDifferences: false)
        collectionView.layoutIfNeeded()
    }
    
    private func showNestedMenu(with nestedMenu: CustomMenu) {
        let transition = CATransition()
        transition.duration = 0.2
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        collectionView.layer.add(transition, forKey: kCATransition)

        sectionItems = nestedMenu.sectionItems

        delegate?.needToResize(with: height)

        updateSnapshot()

    }

    func returnToPreviousMenu(with nestedMenu: CustomMenu) {
        let transition = CATransition()
        transition.duration = 0.2
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        collectionView.layer.add(transition, forKey: kCATransition)
        
        sectionItems = nestedMenu.sectionItems
        
        delegate?.needToResize(with: height)
        
        updateSnapshot()
    }
    
    public func didSelect(item: CustomMenuItem) {
        if var nestedMenu = item.customMenuItem {
            switch item.returnButtonType {
            case .returnToParentMenu:
                returnToPreviousMenu(with: nestedMenu)
            case .openNestedMenu:
                if let needToCreateReturnButton = item.needToCreateReturnButton, needToCreateReturnButton {
                    nestedMenu.sectionItems.append(CustomSectionitem(items: [
                        CustomMenuItem(title: "Назад", image: UIImage(systemName: "chevron.left"), imagePosition: .leading, withNestedMenu: CustomMenu(sectionItems: sectionItems), needToCreateReturnButton: false, returnButtonType: .returnToParentMenu)
                    ]))
                }
                showNestedMenu(with: nestedMenu)
            case .none:
                return
            }
        } else if let action = item.customAction {
            action()
            delegate?.didDismiss()
        }
    }

    func didSelectPan(item: CustomMenuItem) {
        if var nestedMenu = item.customMenuItem {
            switch item.returnButtonType {
            case .returnToParentMenu:
                removeHighlight()
                returnToPreviousMenu(with: nestedMenu)
            case .openNestedMenu:
                removeHighlight()
                if let needToCreateReturnButton = item.needToCreateReturnButton, needToCreateReturnButton {
                    nestedMenu.sectionItems.append(CustomSectionitem(items: [
                        CustomMenuItem(title: "Назад", image: UIImage(systemName: "chevron.left"), imagePosition: .leading, withNestedMenu: CustomMenu(sectionItems: sectionItems), needToCreateReturnButton: false, returnButtonType: .returnToParentMenu)
                    ]))
                }
                showNestedMenu(with: nestedMenu)
            case .none:
                return
            }
        } else if let action = item.customAction {
            removeHighlight()
            action()
            delegate?.didDismiss()
        }
    }

    public func setupPanGestureRecognizer() {
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGestureRecognizer(_:)))
        guard let panGestureRecognizer else { return }
        addGestureRecognizer(panGestureRecognizer)
    }

    @objc
    public func handlePanGestureRecognizer(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard collectionView.bounds.contains(gestureRecognizer.location(in: self)) else {
            removeHighlight()
            return
        }

        switch gestureRecognizer.state {
        case .began, .changed:
            highlightItem(at: gestureRecognizer.location(in: self))
        case .ended:
            selectItem(at: gestureRecognizer.location(in: self))
        case .cancelled, .failed:
            removeHighlight()
        case .possible:
            break
        @unknown default:
            break
        }
    }

    public var previousIndexPath: IndexPath?
    public let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)

    public func highlightItem(at location: CGPoint) {
        if let indexPath = collectionView.indexPathForItem(at: location) {
            if previousIndexPath != indexPath {
                if let previousIndexPath = previousIndexPath,
                   let previousCell = collectionView.cellForItem(at: previousIndexPath)
                {
                    previousCell.contentView.backgroundColor = .clear
                }

                if let cell = collectionView.cellForItem(at: indexPath) {
                    cell.contentView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
                    feedbackGenerator.impactOccurred()
                }
                previousIndexPath = indexPath
            }
        } else {
            if let previousIndexPath = previousIndexPath,
               let previousCell = collectionView.cellForItem(at: previousIndexPath) {
                previousCell.contentView.backgroundColor = .clear
                self.previousIndexPath = nil
                feedbackGenerator.impactOccurred()
            }
        }
    }

    public func removeHighlight() {
        if let previousIndexPath, let previousCell = collectionView.cellForItem(at: previousIndexPath) {
            previousCell.contentView.backgroundColor = .clear
            feedbackGenerator.impactOccurred()
        }
        self.previousIndexPath = nil
    }

    public func selectItem(at location: CGPoint) {
        guard
            let indexPath = collectionView.indexPathForItem(at: location),
            let item = dataSource?.itemIdentifier(for: indexPath)
        else { return }
        didSelectPan(item: item)
    }
    
    public func update(with menuItem: CustomMenuItem) {
        // TODO: - update menuItem
    }
}

// MARK: - UICollectionViewDelegate
extension MenuView: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource?.itemIdentifier(for: indexPath) else { return }

        didSelect(item: item)
    }

    public func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.contentView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)

    }

    public func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.contentView.backgroundColor = .clear
    }
}

private extension MenuView {
    struct Constraints {
        static let menuItemHeight: CGFloat = 44.0
        static let sectionDividerHeight: CGFloat = 8
        static let menuItemSeparatorHeight: CGFloat = 0.5
        
        static let imageSize: CGFloat = 24.0
        
        static let font: UIFont = UIFont.systemFont(ofSize: UIFont.labelFontSize)
        
        static let menuWidth: CGFloat = 250
        
        struct Padding {
            static let leading: CGFloat = 16.0
            static let trailing: CGFloat = 16.0
            static let top: CGFloat = 11.5
            static let bottom: CGFloat = 11.5
        }
    }
}

public extension String {
    func boundingRectangle(withMaximumWidth width: CGFloat, font: UIFont) -> CGRect {
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping
        
        let rectangle = self.boundingRect(
            with: CGSize(width: width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: attributes,
            context: nil
        )
        
        return CGRect(
            origin: rectangle.origin,
            size: .init(
                width: rectangle.width.rounded(.up),
                height: rectangle.height.rounded(.up)
            )
        )
    }
}

