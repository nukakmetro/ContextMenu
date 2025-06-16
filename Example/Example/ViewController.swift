//
//  ViewController.swift
//  Example
//
//  Created by Айдар Тукаев on 16.06.2025.
//

import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        let bubble = ChatBubbleView(message: "Привет, это сообщение!", isIncoming: true)
        bubble.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bubble)

        NSLayoutConstraint.activate([
            bubble.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            bubble.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            bubble.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20)
        ])
    }
}

class ChatBubbleView: UIView {
    private let messageLabel = UILabel()
    private let bubbleBackgroundView = UIView()

    init(message: String, isIncoming: Bool = true) {
        super.init(frame: .zero)
        setupViews(message: message, isIncoming: isIncoming)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews(message: String, isIncoming: Bool) {
        messageLabel.text = message
        messageLabel.numberOfLines = 0
        messageLabel.textColor = isIncoming ? .black : .white
        messageLabel.translatesAutoresizingMaskIntoConstraints = false

        bubbleBackgroundView.backgroundColor = isIncoming ? UIColor(white: 0.9, alpha: 1) : .systemBlue
        bubbleBackgroundView.layer.cornerRadius = 16
        bubbleBackgroundView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(bubbleBackgroundView)
        bubbleBackgroundView.addSubview(messageLabel)

        let constraints = [
            messageLabel.topAnchor.constraint(equalTo: bubbleBackgroundView.topAnchor, constant: 8),
            messageLabel.bottomAnchor.constraint(equalTo: bubbleBackgroundView.bottomAnchor, constant: -8),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleBackgroundView.leadingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleBackgroundView.trailingAnchor, constant: -12),

            bubbleBackgroundView.topAnchor.constraint(equalTo: topAnchor),
            bubbleBackgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
            bubbleBackgroundView.widthAnchor.constraint(lessThanOrEqualToConstant: 250)
        ]

        NSLayoutConstraint.activate(constraints)

        // Выравнивание по левому или правому краю
        if isIncoming {
            bubbleBackgroundView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        } else {
            bubbleBackgroundView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        }
    }
}
