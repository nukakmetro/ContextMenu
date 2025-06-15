//
//  CustomMenuViewCell.swift
//  ContextMenu
//
//  Created by Айдар Тукаев on 24.05.2025.
//

import UIKit

public final class CustomMenuViewCell: UICollectionViewCell {
    
    private var constraintsWhereImageFirst: [NSLayoutConstraint] = []
    private var constraintsWhereTitleFirst: [NSLayoutConstraint] = []

    
    // MARK: - Subviews
    private let titleLabel = UILabel()
    private let imageView = UIImageView()
    private let separatorView = UIView()
    
    // MARK: - Constants
    private struct Constraints {
        static let paddingLeading: CGFloat = 16.0
        static let paddingTrailing: CGFloat = 16.0
        static let paddingTop: CGFloat = 11.5
        static let paddingBottom: CGFloat = 11.5
        static let imageSize: CGFloat = 24.0
        static let separatorHeight: CGFloat = 0.5
    }
    
    // MARK: - Initializers
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    private func setupViews() {
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        // Настраиваем изображение
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .black
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        
        // Настраиваем разделитель
        separatorView.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.55)
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(separatorView)
    }
    
    private func setupConstraints() {
        constraintsWhereTitleFirst = [
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constraints.paddingLeading),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -(Constraints.paddingTrailing + Constraints.imageSize + Constraints.paddingLeading)),

            
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constraints.paddingTrailing),
        ]
        
        constraintsWhereImageFirst = [
            imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: Constraints.paddingLeading),
            
            titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: Constraints.paddingTrailing),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constraints.paddingTrailing),
        ]
        
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            imageView.widthAnchor.constraint(equalToConstant: Constraints.imageSize),
            imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            imageView.heightAnchor.constraint(equalToConstant: Constraints.imageSize),
            
            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: Constraints.separatorHeight)
        ])
    }
    
    // MARK: - Configuration
    public func configure(with item: any CustomMenuItemProtocol, isLastItem: Bool) {
        switch item.imagePosition {
        case .leading:
            constraintsWhereImageFirst.forEach {
                $0.isActive = true
            }
            constraintsWhereTitleFirst.forEach {
                $0.isActive = false
            }
        case .trailing:
            constraintsWhereTitleFirst.forEach {
                $0.isActive = true
            }
            constraintsWhereImageFirst.forEach {
                $0.isActive = false
            }
        case .none:
            return
        }
        titleLabel.text = item.title
        imageView.image = item.image
        separatorView.isHidden = isLastItem
    }
}
