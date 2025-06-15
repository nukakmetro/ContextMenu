//
//  MenuConfiguration.swift
//  ContextMenu
//
//  Created by Айдар Тукаев on 24.05.2025.
//

public struct MenuConfiguration {
    public var menu: MenuViewProtocol
    public var alignment: menuAlignment
    public var position: MenuPosition
}

public enum MenuPosition {
    case top
    case bottom
}

public enum menuAlignment {
    case left
    case right
    case center
}
