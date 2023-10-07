/*
See LICENSE folder for this sample’s licensing information.

Abstract:
View that displays a speed gauge.
*/

import UIKit

// 차트 애니메이팅 -> Summary View에서 사용할 수 있도록 확인
class DashboardView: UIView, AnimatedTransitioning {
    
    var speed = 0.0 {
        didSet {
            updatePathLayer()
        }
    }
    private var maxSpeed = 30.0
    private var halfWidth: CGFloat = 0
    
    private var startAngle = CGFloat.pi * 5 / 6
    private var maxAngle = CGFloat.pi * 4 / 3
    private var pathLayer = CAShapeLayer()
    private var speedLayer = CAShapeLayer()
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialSetup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialSetup()
    }
    
    func animateSpeedChart() {
        let progressAnimation = CABasicAnimation(keyPath: "strokeEnd")
        progressAnimation.duration = 1
        progressAnimation.fromValue = 0
        progressAnimation.toValue = 1
        progressAnimation.fillMode = .forwards
        progressAnimation.isRemovedOnCompletion = false
        speedLayer.add(progressAnimation, forKey: "animateSpeedChart")
    }
    
    // 스피드 결과 출력 함수
    private func initialSetup() {
        isOpaque = false
        backgroundColor = .clear
        halfWidth = bounds.width / 2
        let endAngle = CGFloat.pi / 6
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: halfWidth, y: halfWidth), radius: bounds.width / 2,
                                      startAngle: startAngle, endAngle: endAngle, clockwise: true)
        pathLayer.path = circlePath.cgPath
        pathLayer.fillColor = UIColor.clear.cgColor
        pathLayer.strokeColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.4499411387).cgColor
        pathLayer.lineCap = .round
        pathLayer.lineWidth = 22
        layer.addSublayer(pathLayer)
    }

    // 각도 값을 차트 애니메이션에 전달
    private func updatePathLayer() {
        let endAngle = updatePosition(angle: ankleAngle2)
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: halfWidth, y: halfWidth), radius: bounds.width / 2,
                                      startAngle: startAngle, endAngle: CGFloat(endAngle), clockwise: true)
        speedLayer.path = circlePath.cgPath
        speedLayer.fillColor = UIColor.clear.cgColor
        speedLayer.strokeColor = #colorLiteral(red: 0.6078431373, green: 0.9882352941, blue: 0, alpha: 0.7539934132).cgColor
        speedLayer.lineCap = .round
        speedLayer.lineWidth = 22
        speedLayer.strokeEnd = 1.0
        layer.addSublayer(speedLayer)
    }
}
