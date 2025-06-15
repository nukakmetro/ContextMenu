//
//  CustomSectionitem.swift
//  ContextMenu
//
//  Created by Айдар Тукаев on 24.05.2025.
//

public protocol CustomSectionItemProtocol: Hashable, Sendable {
    var items: [CustomMenuItem] { get set }
}

public struct CustomSectionitem: CustomSectionItemProtocol {
    public var items: [CustomMenuItem] = []
}
