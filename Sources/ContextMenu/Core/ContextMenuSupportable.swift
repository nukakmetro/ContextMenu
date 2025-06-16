//
//  ContextMenuSupportable.swift
//  BootcampContextMenus
//
//  Created by Nikita Konashenko on 03.11.2024.
//

import UIKit

public protocol ContextMenuSupportable {
    var contextMenuConfiguration: ContextMenuConfiguration? { get }
    var previewForHighlightingContextMenu: UITargetedPreview? { get }
    var previewForDismissingContextMenu: UITargetedPreview? { get }
}

public extension ContextMenuSupportable {
    var previewForHighlightingContextMenu: UITargetedPreview? { nil }
    var previewForDismissingContextMenu: UITargetedPreview? { nil }
}

/// Convenience wrapper for UIContextMenuConfiguration.
public struct ContextMenuConfiguration {
    public typealias ContextMenuContentPreviewTransform = (UIViewController?) -> Void
    public typealias ContextMenuActionTransform = (UIMenu?) -> Void

    public let previewProvider: UIContextMenuContentPreviewProvider?
    public let actionProvider: UIContextMenuActionProvider?

    public init(
        previewProvider: UIContextMenuContentPreviewProvider? = nil,
        actionProvider: UIContextMenuActionProvider? = nil
    ) {
        self.previewProvider = previewProvider
        self.actionProvider = actionProvider
    }
    @MainActor
    public func make(
        with identifier: NSCopying? = nil,
        previewTransform: ContextMenuContentPreviewTransform? = nil,
        actionTransform: ContextMenuActionTransform? = nil
    ) -> UIContextMenuConfiguration {
        return .init(
            identifier: identifier,
            previewProvider: previewProvider.flatMap { previewProvider in
                return {
                    let preview = previewProvider()
                    previewTransform?(preview)
                    return preview
                }
            },
            actionProvider: actionProvider.flatMap { actionProvider in
                return { suggestedActions in
                    let action = actionProvider(suggestedActions)
                    actionTransform?(action)
                    return action
                }
            }
        )
    }
}

// MARK: - Helpers

public extension UICollectionView {
    func contextMenuSupportableCell(for identifier: NSCopying) -> ContextMenuSupportable? {
        return contextMenuSupportableCell(for: identifier as? IndexPath)
    }

    func contextMenuSupportableCell(for indexPath: IndexPath?) -> ContextMenuSupportable? {
        return indexPath.flatMap { indexPath in cellForItem(at: indexPath) as? ContextMenuSupportable }
    }
}
