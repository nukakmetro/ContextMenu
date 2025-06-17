//
//  ViewController.swift
//  Example
//
//  Created by Айдар Тукаев on 16.06.2025.
//

import UIKit
import ContextMenu

class ViewController: UIViewController {
    let bubble: UIView = ChatBubbleView(message: "Привет, это сообщение!", isIncoming: true)
    let chatView = ChatCellView(frame: CGRect(x: 0, y: 300, width: UIScreen.main.bounds.width, height: 74))

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        chatView.configure(name: "Иван", message: "Привет, как дела?", time: "14:32", avatar: nil)
        view.addSubview(chatView)
        
        let longTap = UILongPressGestureRecognizer(target: self, action: #selector(longTap))
        longTap.minimumPressDuration = 0.2
        bubble.addGestureRecognizer(longTap)
        
        let longTap2 = UILongPressGestureRecognizer(target: self, action: #selector(longTapChat))
        longTap2.minimumPressDuration = 0.2
        chatView.addGestureRecognizer(longTap2)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panGesture.delegate = self
        bubble.addGestureRecognizer(panGesture)
        let panGesture1 = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panGesture1.delegate = self
        chatView.addGestureRecognizer(panGesture)

        bubble.isUserInteractionEnabled = true
        view.addSubview(bubble)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let size = bubble.intrinsicContentSize
        bubble.frame = CGRect(x: 150, y: 150, width: size.width, height: size.height)
    }
    
    override func viewWillLayoutSubviews() {
        print(bubble.frame)

    }
    
    @objc func handlePan(_ sender: UIPanGestureRecognizer) {
        print("handlePan")
        guard let menuController = self.presentedViewController as? CustomContextMenu else { return }
        let location = sender.location(in: view)
        switch sender.state {
        case .began, .changed:
            menuController.highlightMenu(location)
        case .ended:
            menuController.selectMenu(location)
        default:
            break
        }
    }
    
    @objc func longTap() {
        print("longTap")
        guard self.presentedViewController == nil else { return }
        let preview = UIView()
        preview.backgroundColor = .green
        preview.frame = bubble.frame
        
        let vc = ChatBubbleView(message: "Привет, это сообщение!", isIncoming: true)
//        vc.frame = .init(x: 50, y: 50, width: 400, height: 800)

        preview.layoutIfNeeded()

        let actionView = MenuView(menu: customMenu)
        let menuConfiguration = MenuConfiguration(menu: actionView, alignment: .left, position: .bottom)
        
        let customContextMenu = CustomContextMenu(menuConfiguration: menuConfiguration, sourceView: bubble)
//        let customContextMenu = CustomContextMenu(preview, menuConfiguration: menuConfiguration, sourceView: testView3)
//        let customContextMenu = CustomContextMenu(menuConfiguration: menuConfiguration, sourceView: testView3)
        
        self.present(customContextMenu, animated: true)
    }
    
    @objc func longTapChat() {
        print("longTap")
        guard self.presentedViewController == nil else { return }
        
        let vc = ExampleCollectionViewController()
        
        let actionView = MenuView(menu: customMenu)
        let menuConfiguration = MenuConfiguration(menu: actionView, alignment: .left, position: .bottom)
        
        let customContextMenu = CustomContextMenu(vc, menuConfiguration: menuConfiguration, sourceView: chatView)
        
        self.present(customContextMenu, animated: true)
    }
}

extension ViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension ViewController: MenuViewDelegate {
    func needToResize(with height: CGFloat) {
        // TODO: - обработать анимацию
    }
    
    func didDismiss() {
        print("tap")
        if let presented = self.presentedViewController {
            presented.dismiss(animated: false)
        }
    }
}

let sectionForNestedMenu = CustomSectionitem(items: [
    CustomMenuItem(title: "Section 1 Item 1оакакиакоактоткоткоаткоткоткоатктакатоктакта", withCustomAction: {
                print("Section 2 Item 1 pressed")
            }),
    CustomMenuItem(title: "Section 1 Item 1оакакиакоактоткоткоаткоткоткоатктакатоктакта", withCustomAction: {
                print("Section 2 Item 2 pressed")
            }),
    CustomMenuItem(title: "Section 2 Item 3", withCustomAction: {
                print("Section 2 Item 3 pressed")
            }),
    CustomMenuItem(title: "open empty menu", withNestedMenu: CustomMenu(sectionItems: []))
        ])
let nestedMenu = CustomMenu(sectionItems: [sectionForNestedMenu])
let bigStr = "Section 1 Item 1оакакиакоактоткоткоаткоткоткоатктакатоктакта"
let sectionItems: [CustomSectionitem] = [
    CustomSectionitem(items: [
        CustomMenuItem(title: "Section 1 Item 1оакакиакоактоткоткоаткоткоткоатктакатоктакта", image: UIImage(systemName: "pencil"), imagePosition: .leading, withCustomAction: {
                    print("Section 2 Item 1 pressed")
                }),
        CustomMenuItem(title: "Section 1 Item 2", image: UIImage(systemName: "pencil"), withCustomAction: {
                    print("Section 1 Item 2 pressed")
                }),
        CustomMenuItem(title: "Section 1 Item 3", withCustomAction: {
                    print("Section 1 Item 3 pressed")
                }),
            ]),
    CustomSectionitem(items: [
        CustomMenuItem(title: "Section 1 Item 1", withCustomAction: {
                    print("Section 2 Item 1 pressed")
                }),
        CustomMenuItem(title: "Open new menu", withNestedMenu: nestedMenu),
        CustomMenuItem(title: "Section 2 Item 3", withCustomAction: {
                    print("Section 2 Item 3 pressed")
                }),
            ]),
        ]

var customMenu = CustomMenu(sectionItems: sectionItems)

class ChatCellView: UIView {
    
    private let avatarImageView = UIImageView()
    private let nameLabel = UILabel()
    private let messageLabel = UILabel()
    private let timeLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        backgroundColor = .white
        
        avatarImageView.image = UIImage(systemName: "person.circle")
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = 25
        addSubview(avatarImageView)
        
        nameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        addSubview(nameLabel)
        
        messageLabel.font = UIFont.systemFont(ofSize: 14)
        messageLabel.textColor = .gray
        addSubview(messageLabel)
        
        timeLabel.font = UIFont.systemFont(ofSize: 12)
        timeLabel.textColor = .lightGray
        timeLabel.textAlignment = .right
        addSubview(timeLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let padding: CGFloat = 12
        avatarImageView.frame = CGRect(x: padding, y: padding, width: 50, height: 50)
        
        let nameX = avatarImageView.frame.maxX + 10
        nameLabel.frame = CGRect(x: nameX, y: padding, width: bounds.width - nameX - 60, height: 20)
        
        messageLabel.frame = CGRect(x: nameX, y: nameLabel.frame.maxY + 4, width: bounds.width - nameX - 60, height: 20)
        
        timeLabel.frame = CGRect(x: bounds.width - 50 - padding, y: padding, width: 50, height: 20)
    }
    
    func configure(name: String, message: String, time: String, avatar: UIImage?) {
        nameLabel.text = name
        messageLabel.text = message
        timeLabel.text = time
        avatarImageView.image = avatar ?? UIImage(systemName: "person.circle")
    }
}

class ChatBubbleView: UIView {
    private let messageLabel = UILabel()
    private let bubbleBackgroundView = UIView()
    private let maxBubbleWidth: CGFloat = 250
    private var message: String
    private var isIncoming: Bool

    init(message: String, isIncoming: Bool = true) {
        self.message = message
        self.isIncoming = isIncoming
        super.init(frame: .zero)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        let horizontalPadding: CGFloat = 12 + 12  // left + right padding у messageLabel
        let verticalPadding: CGFloat = 8 + 8      // top + bottom padding у messageLabel

        let maxLabelWidth = maxBubbleWidth - horizontalPadding

        let font = messageLabel.font ?? UIFont.systemFont(ofSize: 17)
        let height = heightForText(message, font: font, width: maxLabelWidth)

        return CGSize(width: maxBubbleWidth, height: height + verticalPadding)
    }

    private func setupViews() {
           messageLabel.text = message
           messageLabel.numberOfLines = 0
           messageLabel.textColor = isIncoming ? .black : .white
           messageLabel.font = UIFont.systemFont(ofSize: 17)
           messageLabel.translatesAutoresizingMaskIntoConstraints = false

           bubbleBackgroundView.backgroundColor = isIncoming ? UIColor(white: 0.9, alpha: 1) : .systemBlue
           bubbleBackgroundView.layer.cornerRadius = 16
           bubbleBackgroundView.translatesAutoresizingMaskIntoConstraints = false
           bubbleBackgroundView.isUserInteractionEnabled = false

           addSubview(bubbleBackgroundView)
           bubbleBackgroundView.addSubview(messageLabel)

           NSLayoutConstraint.activate([
               messageLabel.topAnchor.constraint(equalTo: bubbleBackgroundView.topAnchor, constant: 8),
               messageLabel.bottomAnchor.constraint(equalTo: bubbleBackgroundView.bottomAnchor, constant: -8),
               messageLabel.leadingAnchor.constraint(equalTo: bubbleBackgroundView.leadingAnchor, constant: 12),
               messageLabel.trailingAnchor.constraint(equalTo: bubbleBackgroundView.trailingAnchor, constant: -12),

               bubbleBackgroundView.topAnchor.constraint(equalTo: topAnchor),
               bubbleBackgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
               bubbleBackgroundView.widthAnchor.constraint(lessThanOrEqualToConstant: maxBubbleWidth)
           ])

           if isIncoming {
               bubbleBackgroundView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
           } else {
               bubbleBackgroundView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
           }
       }

    
    private func heightForText(_ text: String, font: UIFont, width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = text.boundingRect(
            with: constraintRect,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font],
            context: nil
        )
        return ceil(boundingBox.height)
    }
}

final class ExampleCollectionViewController: UIViewController {
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, Section.Item>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Section.Item>
    
    private lazy var collectionView: UICollectionView = makeCollectionView()
    private lazy var dataSource: DataSource = makeDataSource()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayouts()
        
       
        var snapshot = Snapshot()
        snapshot.appendSections([Constants.exampleSection])
        snapshot.appendItems(Constants.exampleSection.items)
        dataSource.apply(snapshot, animatingDifferences: false)
        
        preferredContentSize = .init(width: UIScreen.main.bounds.width - 50, height: UIScreen.main.bounds.width - 50)
    }
    
    private func setupLayouts() {
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    // MARK: Layouts
    
    private func makeCollectionLayout() -> UICollectionViewLayout {
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        let sectionProvider: UICollectionViewCompositionalLayoutSectionProvider = { [weak self] index, environment in
            guard let self, let section = dataSource.sectionIdentifier(for: index) else { return nil }

            return switch section.type {
            case .first: makeFirstSection()
            }
        }

        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider, configuration: configuration)
    }
    
    private func makeFirstSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(50.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.6),
            heightDimension: .estimated(50.0)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 1)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 16
        section.contentInsets = .init(top: 16, leading: 16, bottom: 16, trailing: 16)
        return section
    }
    
    // MARK: Collection View
    
    private func makeCollectionView() -> UICollectionView {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeCollectionLayout())
        collectionView.delegate = self
        
        collectionView.register(
            ExampleCollectionViewCell.self,
            forCellWithReuseIdentifier: ExampleCollectionViewCell.reuseIdentifier
        )
        
        return collectionView
    }
    
    // MARK: Data Source

    private func makeDataSource() -> DataSource {
        let dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ExampleCollectionViewCell.reuseIdentifier,
                for: indexPath
            ) as! ExampleCollectionViewCell

            cell.configure(with: item.text)

            return cell
        }

        return dataSource
    }
}

// MARK: - Collection Delegate

extension ExampleCollectionViewController: UICollectionViewDelegate {
    // MARK: Context Menu
    
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemsAt indexPaths: [IndexPath],
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
//        assert(indexPaths.count == 1, "Unsupported multiple selection")
        let indexPath = indexPaths.first!
        let cell = collectionView.contextMenuSupportableCell(for: indexPath)
        return cell?.contextMenuConfiguration?.make(
            with: indexPath as NSIndexPath,
            previewTransform: { preview in preview?.view.tag = Constants.contextMenuPreviewTag }
        )
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfiguration configuration: UIContextMenuConfiguration,
        highlightPreviewForItemAt indexPath: IndexPath
    ) -> UITargetedPreview? {
        let cell = collectionView.contextMenuSupportableCell(for: configuration.identifier)
        return cell?.previewForDismissingContextMenu
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfiguration configuration: UIContextMenuConfiguration,
        dismissalPreviewForItemAt indexPath: IndexPath
    ) -> UITargetedPreview? {
        let cell = collectionView.contextMenuSupportableCell(for: configuration.identifier)
        return cell?.previewForDismissingContextMenu
    }
}

// MARK: - Custom Collection View

private final class CollectionView: UICollectionView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if var topVC = window?.rootViewController {
            while let presentedVC = topVC.presentedViewController {
                topVC = presentedVC
            }

            // Prevent SwiftUI from intercepting background touches of popover and context menus
            if topVC.popoverPresentationController != nil || topVC.view.tag == Constants.contextMenuPreviewTag {
                return self
            }
        }

        return super.hitTest(point, with: event)
    }
}

// MARK: - Section

private struct Section: Hashable {
    enum SectionType: Hashable {
        case first
    }

    let type: SectionType = .first
    var items: [Item]

    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.type == rhs.type
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(type)
    }
}

// MARK: - Item

private extension Section {
    struct Item: Hashable {
        let text: String
    }
}

// MARK: - Constants

private enum Constants {
    static let contextMenuPreviewTag = 101
    static let exampleSection = Section(
        items: [
            Section.Item(text: "Text 1"),
            Section.Item(text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."),
            Section.Item(text: "Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?"),
        ]
    )
}

final class ExampleCollectionViewCell: UICollectionViewCell {
    static var reuseIdentifier: String { String(describing: self) }
    
    private var isContextMenusEnabled: Bool = true
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.textColor = .label
        label.numberOfLines = 0
        contentView.addSubview(label)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLayouts()
        setupAppearance()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func configure(with text: String) {
        label.text = text
    }
    
    private func setupLayouts() {
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
        ])
    }
    
    private func setupAppearance() {
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 16
        contentView.layer.cornerCurve = .continuous
    }
}

// MARK: - ContextMenuSupportable

extension ExampleCollectionViewCell: ContextMenuSupportable {
    var contextMenuConfiguration: ContextMenuConfiguration? {
        guard isContextMenusEnabled else {
            // No interaction with cell.
            return nil
        }
        
        guard let actions = makeContextActions() else {
            // An empty menu notifies the user that the context menu is available, but not at the moment.
            return .init()
        }
        
        return ContextMenuConfiguration(
            actionProvider:  { _ in actions }
        )
    }
    
    private func makeContextActions() -> UIMenu? {
        UIMenu(
            title: "Menu",
            children: [
                UIAction(title: "Action 1", handler: { _ in print("Action 1")})
            ]
        )
    }
}
