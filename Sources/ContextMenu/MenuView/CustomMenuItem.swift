//
//  CustomMenuItem.swift
//  ContextMenu
//
//  Created by Айдар Тукаев on 24.05.2025.
//

import UIKit

public enum ImagePosition: Sendable {
    case leading
    case trailing
}

public enum ReturnButtonType: Sendable {
    case returnToParentMenu
    case openNestedMenu
}

public protocol CustomMenuItemProtocol: Hashable, Sendable {
    var id: String { get }
    var title: String { get set }
    var image: UIImage? { get set }
    var customAction: (@Sendable () -> Void)? { get set }
    var customMenuItem: CustomMenu? { get set }
    var imagePosition: ImagePosition? {get set}
}

public struct CustomMenuItem: CustomMenuItemProtocol {
    public let id: String = UUID().uuidString

    public var title: String
    public var image: UIImage?
    public var imagePosition: ImagePosition?
    public var customAction: (@Sendable () -> Void)?
    public var customMenuItem: CustomMenu?
    public var needToCreateReturnButton: Bool?
    public var returnButtonType: ReturnButtonType?
    
    public init(
        title: String,
        image: UIImage? = nil,
        imagePosition: ImagePosition = .trailing,
        withCustomAction customAction: (@Sendable @escaping () -> Void))
    {
        self.title = title
        self.image = image
        self.imagePosition = imagePosition
        self.customAction = customAction
    }
    
    public init(
        title: String,
        image: UIImage? = nil,
        imagePosition: ImagePosition = .trailing,
        withNestedMenu menuCustomItem: CustomMenu,
        needToCreateReturnButton: Bool = true,
        returnButtonType: ReturnButtonType = .openNestedMenu)
    {
        self.title = title
        self.image = image
        self.imagePosition = imagePosition
        self.customMenuItem = menuCustomItem
        self.needToCreateReturnButton = needToCreateReturnButton
        self.returnButtonType = returnButtonType
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}


