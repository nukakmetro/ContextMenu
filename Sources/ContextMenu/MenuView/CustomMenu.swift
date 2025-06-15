//
//  CustomMenu.swift
//  ContextMenu
//
//  Created by Айдар Тукаев on 24.05.2025.
//

public struct CustomMenu: Sendable {
    public var sectionItems: [CustomSectionitem]

    public init(sectionItems: [CustomSectionitem]) {
        self.sectionItems = sectionItems
    }
}
