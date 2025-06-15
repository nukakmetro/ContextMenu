//
//  MenuConfiguration.swift
//  ContextMenu
//
//  Created by Айдар Тукаев on 24.05.2025.
//

public struct MenuConfiguration {
    var menu: MenuViewProtocol
    var alignment: menuAlignment
    var position: MenuPosition
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
