//
//  CircularProgressView.swift
//  SnapHabit
//
//  Created by Sajid Shanta on 1/6/25.
//

import UIKit

class CircularProgressView: UIView {
    
    private let trackLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()
    private let percentageLabel = UILabel()

    var progress: CGFloat = 0 {
        didSet {
            setProgress(progress)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = .clear

        // Track circle
        trackLayer.strokeColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineWidth = 20
        layer.addSublayer(trackLayer)

        // Progress circle
        progressLayer.strokeColor = UIColor.background.cgColor
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineWidth = 20
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0
        layer.addSublayer(progressLayer)

        // Percentage label
        percentageLabel.text = "0%"
        percentageLabel.font = .roundedSystemFont(ofSize: 22, weight: .bold)
        percentageLabel.textColor = .background
        percentageLabel.textAlignment = .center
        addSubview(percentageLabel)
        percentageLabel.fillSuperview()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2 - progressLayer.lineWidth / 2
        let circularPath = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: -CGFloat.pi / 2,
            endAngle: 1.5 * CGFloat.pi,
            clockwise: true
        )
        trackLayer.path = circularPath.cgPath
        progressLayer.path = circularPath.cgPath
    }

    func setProgress(_ progress: CGFloat) {
        let clamped = max(0, min(progress, 1)) // Clamp 0-1
        progressLayer.strokeEnd = clamped
        percentageLabel.text = "\(Int(clamped * 100))%"
    }
}
