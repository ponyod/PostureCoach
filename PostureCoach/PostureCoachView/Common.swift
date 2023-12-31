/*
See LICENSE folder for this sample’s licensing information.

Abstract:
This is a collection of common data types, constants and helper functions used in the app.
*/

import UIKit
import Vision

enum ThrowType: String, CaseIterable {
//    case overhand = "Overhand"
//    case underleg = "Underleg"
//    case underhand = "Underhand"
//    case none = "None"
    case chestpress = "ChestPress"
    case latpulldown = "LatPullDown"
    case legextension = "LegExtension"
    case legpress = "Leg Press"
}

enum Scoring: Int {
    case zero = 0
    case one = 1
    case three = 3
    case five = 5
    case fifteen = 15
}
struct ThrowMetrics {
    var score = Scoring.zero
    var releaseSpeed = 0.0
    var releaseAngle = 0.0
    var throwType = ThrowType.legpress
    var upperType = ThrowType.latpulldown
    var lowerType = ThrowType.legextension
    var finalBagLocation: CGPoint = .zero

    mutating func updateThrowType(_ type: ThrowType) {
        throwType = type
    }
    
    mutating func updateExercisesType(_ type: ThrowType) {
        upperType = type
    }

    mutating func updateFinalBagLocation(_ location: CGPoint) {
        finalBagLocation = location
    }

    mutating func updateMetrics(newScore: Scoring, speed: Double, angle: Double) {
        score = newScore
        releaseSpeed = speed
        releaseAngle = angle
    }
}

struct PlayerStats {
    var totalScore = 0
    var throwCount = 0
    var topSpeed = 0.0
    var avgSpeed = 0.0
    var releaseAngle = 0.0
    var avgReleaseAngle = 0.0
    var poseObservations = [VNHumanBodyPoseObservation]()
    var throwPaths = [CGPath]()
    
    mutating func reset() {
        topSpeed = 0
        avgSpeed = 0
        totalScore = 0
        throwCount = 0
        releaseAngle = 0
        poseObservations = []
    }

    mutating func resetObservations() {
        poseObservations = []
    }

    mutating func adjustMetrics(score: Scoring, speed: Double, releaseAngle: Double, throwType: ThrowType) {
        throwCount += 1
//        totalScore += score.rawValue
//        avgSpeed = (avgSpeed * Double(throwCount - 1) + speed) / Double(throwCount)
        avgReleaseAngle = (avgReleaseAngle * Double(throwCount - 1) + releaseAngle) / Double(throwCount)
//        if speed > topSpeed {
//            topSpeed = speed
//        }
    }

    mutating func storePath(_ path: CGPath) {
        throwPaths.append(path)
    }

    mutating func storeObservation(_ observation: VNHumanBodyPoseObservation) {
        if poseObservations.count >= GameConstants.maxPoseObservations {
            poseObservations.removeFirst()
        }
        poseObservations.append(observation)
    }

    mutating func getReleaseAngle() -> Double {
        if !poseObservations.isEmpty {
            let observationCount = poseObservations.count
            let postReleaseObservationCount = GameConstants.trajectoryLength + GameConstants.maxTrajectoryInFlightPoseObservations
            let keyFrameForReleaseAngle = observationCount > postReleaseObservationCount ? observationCount - postReleaseObservationCount : 0
            let observation = poseObservations[keyFrameForReleaseAngle]
            let (rightHip, _, rightAnkle) = legPressJoints(for: observation)
//            let (rightElbow, rightWrist) = armJoints(for: observation)
//            let (leftElbow, leftWrist) = armJointsLeft(for: observation)
            // Release angle is computed by measuring the angle forearm (elbow to wrist) makes with the horizontal
            releaseAngle = rightHip.angleFromHorizontal(to: rightAnkle)
        }
        return releaseAngle
    }

    mutating func getLastThrowType() -> ThrowType {
        guard let actionClassifier = try? PostureActionClassifier(configuration: MLModelConfiguration()),
              let poseMultiArray = prepareInputWithObservations(poseObservations),
              let predictions = try? actionClassifier.prediction(poses: poseMultiArray),
              let throwType = ThrowType(rawValue: predictions.label.capitalized) else {
            return .legpress
        }
        return throwType
    }
}

struct LowerStats {
    var totalScore = 0
    var throwCount = 0
    var topSpeed = 0.0
    var avgSpeed = 0.0
    var releaseAngle = 0.0
    var avgReleaseAngle = 0.0
    var poseObservations = [VNHumanBodyPoseObservation]()
    var throwPaths = [CGPath]()
    
    mutating func reset() {
        topSpeed = 0
        avgSpeed = 0
        totalScore = 0
        throwCount = 0
        releaseAngle = 0
        poseObservations = []
    }

    mutating func resetObservations() {
        poseObservations = []
    }

    mutating func adjustMetrics(score: Scoring, speed: Double, releaseAngle: Double, throwType: ThrowType) {
        throwCount += 1
//        totalScore += score.rawValue
//        avgSpeed = (avgSpeed * Double(throwCount - 1) + speed) / Double(throwCount)
        avgReleaseAngle = (avgReleaseAngle * Double(throwCount - 1) + releaseAngle) / Double(throwCount)
//        if speed > topSpeed {
//            topSpeed = speed
//        }
    }

    mutating func storePath(_ path: CGPath) {
        throwPaths.append(path)
    }

    mutating func storeObservation(_ observation: VNHumanBodyPoseObservation) {
        if poseObservations.count >= GameConstants.maxPoseObservations {
            poseObservations.removeFirst()
        }
        poseObservations.append(observation)
    }

    mutating func getReleaseAngle() -> Double {
        if !poseObservations.isEmpty {
            let observationCount = poseObservations.count
            let postReleaseObservationCount = GameConstants.trajectoryLength + GameConstants.maxTrajectoryInFlightPoseObservations
            let keyFrameForReleaseAngle = observationCount > postReleaseObservationCount ? observationCount - postReleaseObservationCount : 0
            let observation = poseObservations[keyFrameForReleaseAngle]
            let (rightHip, _, rightAnkle) = legPressJoints(for: observation)
            // Release angle is computed by measuring the angle forearm (elbow to wrist) makes with the horizontal
            releaseAngle = rightHip.angleFromHorizontal(to: rightAnkle)
        }
        return releaseAngle
    }

    mutating func getLastThrowType() -> ThrowType {
        guard let actionClassifier = try? PostureActionClassifier(configuration: MLModelConfiguration()),
              let poseMultiArray = prepareInputWithObservations(poseObservations),
              let predictions = try? actionClassifier.prediction(poses: poseMultiArray),
              let throwType = ThrowType(rawValue: predictions.label.capitalized) else {
            return .legpress
        }
        return throwType
    }
}

struct UpperStats {
    var totalScore = 0
    var throwCount = 0
    var topSpeed = 0.0
    var avgSpeed = 0.0
    var releaseAngle = 0.0
    var avgReleaseAngle = 0.0
    var poseObservations = [VNHumanBodyPoseObservation]()
    var throwPaths = [CGPath]()
    
    mutating func reset() {
        topSpeed = 0
        avgSpeed = 0
        totalScore = 0
        throwCount = 0
        releaseAngle = 0
        poseObservations = []
    }

    mutating func resetObservations() {
        poseObservations = []
    }

    mutating func adjustMetrics(score: Scoring, speed: Double, releaseAngle: Double, throwType: ThrowType) {
        throwCount += 1
//        totalScore += score.rawValue
//        avgSpeed = (avgSpeed * Double(throwCount - 1) + speed) / Double(throwCount)
        avgReleaseAngle = (avgReleaseAngle * Double(throwCount - 1) + releaseAngle) / Double(throwCount)
//        if speed > topSpeed {
//            topSpeed = speed
//        }
    }

    mutating func storePath(_ path: CGPath) {
        throwPaths.append(path)
    }

    mutating func storeObservation(_ observation: VNHumanBodyPoseObservation) {
        if poseObservations.count >= GameConstants.maxPoseObservations {
            poseObservations.removeFirst()
        }
        poseObservations.append(observation)
    }

    mutating func getReleaseAngle() -> Double {
        if !poseObservations.isEmpty {
            let observationCount = poseObservations.count
            let postReleaseObservationCount = GameConstants.trajectoryLength + GameConstants.maxTrajectoryInFlightPoseObservations
            let keyFrameForReleaseAngle = observationCount > postReleaseObservationCount ? observationCount - postReleaseObservationCount : 0
            let observation = poseObservations[keyFrameForReleaseAngle]
//            let (rightHip, _, rightAnkle) = legJoints(for: observation)
            let (rightShoulder, _, rightWrist) = latPullDownJoints(for: observation)
            // Release angle is computed by measuring the angle forearm (elbow to wrist) makes with the horizontal
            releaseAngle = rightShoulder.angleFromHorizontal(to: rightWrist)
        }
        return releaseAngle
    }

    mutating func getLastThrowType() -> ThrowType {
        guard let actionClassifier = try? PostureActionClassifier(configuration: MLModelConfiguration()),
              let poseMultiArray = prepareInputWithObservations(poseObservations),
              let predictions = try? actionClassifier.prediction(poses: poseMultiArray),
              let throwType = ThrowType(rawValue: predictions.label.capitalized) else {
            return .latpulldown
        }
        return throwType
    }
}

struct GameConstants {
    static let maxThrows = 8
    static let newGameTimer = 5
//    static let boardLength = 1.22
    static let trajectoryLength = 15
    static let maxPoseObservations = 45
    static let noObservationFrameLimit = 20
    static let maxDistanceWithCurrentTrajectory: CGFloat = 250
    static let maxTrajectoryInFlightPoseObservations = 10
}

let jointsOfInterest: [VNHumanBodyPoseObservation.JointName] = [
    .rightWrist,
    .rightElbow,
    .rightShoulder,
    .rightHip,
    .rightKnee,
    .rightAnkle,
    .leftWrist,
    .leftElbow,
    .leftShoulder,
    .leftHip,
    .leftKnee,
    .leftAnkle,
]

enum LegPressState {
    case initial
    case movingTowardsHip
    case returningToStart
}

enum LatPullDownState {
    case initial
    case movingTowardsShoulder
    case returningToStart
}

// Initialize the LegPressCounter
var legPressCounter = LegPressCounter()
var latPullDownCounter = LatPullDownCounter()

let kneeAngle1 = 10.0 // Assuming the ankle is closer to the hip
let kneeAngle2 = 40.0 // Assuming the ankle is away from the hip

let elbowAngle1 = 10.0 // Assuming the ankle is closer to the Shoulder
let elbowAngle2 = 40.0 // Assuming the ankle is away from the Shoulder

func latPullDownJoints(for observation: VNHumanBodyPoseObservation) -> (CGPoint, CGPoint, CGPoint) {
    var rightShoulder = CGPoint(x: 0, y: 0)
    var rightElbow = CGPoint(x: 0, y: 0)
    var rightWrist = CGPoint(x: 0, y: 0)

    guard let identifiedPoints = try? observation.recognizedPoints(.all) else {
        return (rightShoulder, rightElbow, rightWrist)
    }
    for (key, point) in identifiedPoints where point.confidence > 0.1 {
        switch key {
        case .rightShoulder:
            rightShoulder = point.location
        case .rightElbow:
            rightElbow = point.location
        case .rightWrist:
            rightWrist = point.location
        default:
            break
        }
    }
    updateArmPosition(angle: elbowAngle1) // This will not increase the count
    updateArmPosition(angle: elbowAngle2)// This will increase the count by 1
    
    return (rightShoulder, rightElbow, rightWrist)
}

func legPressJoints(for observation: VNHumanBodyPoseObservation) -> (CGPoint, CGPoint, CGPoint) {
    var rightHip = CGPoint(x: 0, y: 0)
    var rightKnee = CGPoint(x: 0, y: 0)
    var rightAnkle = CGPoint(x: 0, y: 0)

    guard let identifiedPoints = try? observation.recognizedPoints(.all) else {
        return (rightHip, rightKnee, rightAnkle)
    }
    for (key, point) in identifiedPoints where point.confidence > 0.1 {
        switch key {
        case .rightHip:
            rightHip = point.location
        case .rightKnee:
            rightKnee = point.location
        case .rightAnkle:
            rightAnkle = point.location
        default:
            break
        }
    }
    updateLegPosition(angle: kneeAngle1) // This will not increase the count
    updateLegPosition(angle: kneeAngle2)// This will increase the count by 1
    
    return (rightHip, rightKnee, rightAnkle)
}

struct LegPressCounter {
    
    private var state: LegPressState = .initial
    private var count: Int = 0
    private var legCount: Int = 0

    // Call this function whenever the position of the ankle joint is updated
    mutating func updateAnglePosition(isCloserToHip: Bool) {
        switch state {
        case .initial:
            // Check if the ankle is moving towards the hip
            if isCloserToHip {
                state = .movingTowardsHip
            }
        case .movingTowardsHip:
            // Check if the ankle is returning to the start position
            if !isCloserToHip {
                state = .returningToStart
            }
        case .returningToStart:
            // Check if the ankle has reached the start position
            if isCloserToHip {
                // Increment the count and reset the state
                count += 1
                state = .movingTowardsHip
            }
        }
    }
    
    // Call this function to get the current count
    func getCount() -> Int {
        return count
    }

    // Call this function to reset the count
    mutating func resetCount() {
        count = 0
        state = .initial
    }
}

struct LatPullDownCounter {
    
    private var state: LatPullDownState = .initial
    private var count: Int = 0

    // Call this function whenever the position of the ankle joint is updated
    mutating func updateAnglePosition(isCloserToShoulder: Bool) {
        switch state {
        case .initial:
            // Check if the ankle is moving towards the hip
            if isCloserToShoulder {
                state = .movingTowardsShoulder
            }
        case .movingTowardsShoulder:
            // Check if the ankle is returning to the start position
            if !isCloserToShoulder {
                state = .returningToStart
            }
        case .returningToStart:
            // Check if the ankle has reached the start position
            if isCloserToShoulder {
                // Increment the count and reset the state
                count += 1
                state = .movingTowardsShoulder
            }
        }
    }
    
    // Call this function to get the current count
    func getCount() -> Int {
        return count
    }

    // Call this function to reset the count
    mutating func resetCount() {
        count = 0
        state = .initial
    }
}

// Update the ankle position and check for counting
func updateLegPosition(angle: Double) -> Int {
    // Set a threshold angle that determines when the ankle is closer to the hip
    let thresholdAngle: Double = 30.0 // Adjust this value as needed
    
    // Check if the ankle angle is within the threshold
    let isCloserToHip = angle < thresholdAngle
    
    // Update the LegPressCounter
    legPressCounter.updateAnglePosition(isCloserToHip: isCloserToHip)
    
    // Get the current count
    let count = legPressCounter.getCount()
    
    // Print or use the count as needed
    return count
}

// 카운터 업데이트를 위한 팔꿈치 위치 확인

func updateArmPosition(angle: Double) -> Int {
    // Set a threshold angle that determines when the ankle is closer to the hip
    let thresholdAngle: Double = 30.0 // Adjust this value as needed
    
    // Check if the ankle angle is within the threshold
    let isCloserToShoulder = angle < thresholdAngle
    
    // Update the LatPullDownCounter
    latPullDownCounter.updateAnglePosition(isCloserToShoulder: isCloserToShoulder)
    
    // Get the current count
    let count = latPullDownCounter.getCount()
    
    // Print or use the count as needed
    return count
}


//func armJointsRight(for observation: VNHumanBodyPoseObservation) -> (CGPoint, CGPoint) {
//    var rightElbow = CGPoint(x: 0, y: 0)
//    var rightWrist = CGPoint(x: 0, y: 0)
//
//    guard let identifiedPoints = try? observation.recognizedPoints(.all) else {
//        return (rightElbow, rightWrist)
//    }
//    for (key, point) in identifiedPoints where point.confidence > 0.1 {
//        switch key {
//        case .rightElbow:
//            rightElbow = point.location
//        case .rightWrist:
//            rightWrist = point.location
//        default:
//            break
//        }
//    }
//    return (rightElbow, rightWrist)
//}
//
//func armJointsLeft(for observation: VNHumanBodyPoseObservation) -> (CGPoint, CGPoint) {
//    var leftElbow = CGPoint(x: 0, y: 0)
//    var leftWrist = CGPoint(x: 0, y: 0)
//
//    guard let identifiedPoints = try? observation.recognizedPoints(.all) else {
//        return (leftElbow, leftWrist)
//    }
//    for (key, point) in identifiedPoints where point.confidence > 0.1 {
//        switch key {
//        case .leftElbow:
//            leftElbow = point.location
//        case .leftWrist:
//            leftWrist = point.location
//        default:
//            break
//        }
//    }
//    return (leftElbow, leftWrist)
//}

//func armJoints(for observation: VNHumanBodyPoseObservation) -> (CGPoint, CGPoint) {
//    var rightElbow = CGPoint(x: 0, y: 0)
//    var rightWrist = CGPoint(x: 0, y: 0)
//
//    guard let identifiedPoints = try? observation.recognizedPoints(.all) else {
//        return (rightElbow, rightWrist)
//    }
//    for (key, point) in identifiedPoints where point.confidence > 0.1 {
//        switch key {
//        case .rightElbow:
//            rightElbow = point.location
//        case .rightWrist:
//            rightWrist = point.location
//        default:
//            break
//        }
//    }
//    return (rightElbow, rightWrist)
//}

func getBodyJointsFor(observation: VNHumanBodyPoseObservation) -> ([VNHumanBodyPoseObservation.JointName: CGPoint]) {
    var joints = [VNHumanBodyPoseObservation.JointName: CGPoint]()
    guard let identifiedPoints = try? observation.recognizedPoints(.all) else {
        return joints
    }
    for (key, point) in identifiedPoints {
        guard point.confidence > 0.1 else { continue }
        if jointsOfInterest.contains(key) {
            joints[key] = point.location
        }
    }
    return joints
}

// MARK: - Pipeline warmup

func warmUpVisionPipeline() {
    // In order to preload the models and all associated resources
    // we perform all Vision requests used in the app on a small image (we use one of the assets bundled with our app).
    // This allows to avoid any model loading/compilation costs later when we run these requests on real time video input.
//    guard let image = #imageLiteral(resourceName: "Score1").cgImage else {
//          let detectorModel = try? GameBoardDetector(configuration: MLModelConfiguration()).model,
//          let boardDetectionRequest = try? VNCoreMLRequest(model: VNCoreMLModel(for: detectorModel)) else {
//        return
//    }
    let bodyPoseRequest = VNDetectHumanBodyPoseRequest()
//    let handler = VNImageRequestHandler(cgImage: image, options: [:])
//    try? handler.perform([bodyPoseRequest, boardDetectionRequest])
}

// MARK: - Activity Classification Helpers

func prepareInputWithObservations(_ observations: [VNHumanBodyPoseObservation]) -> MLMultiArray? {
    let numAvailableFrames = observations.count
    let observationsNeeded = 45
    var multiArrayBuffer = [MLMultiArray]()

    for frameIndex in 0 ..< min(numAvailableFrames, observationsNeeded) {
        let pose = observations[frameIndex]
        do {
            let oneFrameMultiArray = try pose.keypointsMultiArray()
            multiArrayBuffer.append(oneFrameMultiArray)
        } catch {
            continue
        }
    }
    
    // If poseWindow does not have enough frames (45) yet, we need to pad 0s
    if numAvailableFrames < observationsNeeded {
        for _ in 0 ..< (observationsNeeded - numAvailableFrames) {
            do {
                let oneFrameMultiArray = try MLMultiArray(shape: [1, 3, 18], dataType: .double)
                try resetMultiArray(oneFrameMultiArray)
                multiArrayBuffer.append(oneFrameMultiArray)
            } catch {
                continue
            }
        }
    }
    return MLMultiArray(concatenating: [MLMultiArray](multiArrayBuffer), axis: 0, dataType: .float)
}

func resetMultiArray(_ predictionWindow: MLMultiArray, with value: Double = 0.0) throws {
    let pointer = try UnsafeMutableBufferPointer<Double>(predictionWindow)
    pointer.initialize(repeating: value)
}

// MARK: - Helper extensions

extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        return hypot(x - point.x, y - point.y)
    }
    
    func angleFromHorizontal(to point: CGPoint) -> Double {
        let angle = atan2(point.y - y, point.x - x)
        let deg = abs(angle * (180.0 / CGFloat.pi))
        return Double(round(100 * deg) / 100)
    }
}

extension CGAffineTransform {
    static var verticalFlip = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -1)
    static var horizontalFlip = CGAffineTransform(scaleX: -1, y: 1).translatedBy(x: -1, y: 0)
}

extension UIBezierPath {
    convenience init(cornersOfRect borderRect: CGRect, cornerSize: CGSize, cornerRadius: CGFloat) {
        self.init()
        let cornerSizeH = cornerSize.width
        let cornerSizeV = cornerSize.height
        // top-left
        move(to: CGPoint(x: borderRect.minX, y: borderRect.minY + cornerSizeV + cornerRadius))
        addLine(to: CGPoint(x: borderRect.minX, y: borderRect.minY + cornerRadius))
        addArc(withCenter: CGPoint(x: borderRect.minX + cornerRadius, y: borderRect.minY + cornerRadius),
               radius: cornerRadius,
               startAngle: CGFloat.pi,
               endAngle: -CGFloat.pi / 2,
               clockwise: true)
        addLine(to: CGPoint(x: borderRect.minX + cornerSizeH + cornerRadius, y: borderRect.minY))
        // top-right
        move(to: CGPoint(x: borderRect.maxX - cornerSizeH - cornerRadius, y: borderRect.minY))
        addLine(to: CGPoint(x: borderRect.maxX - cornerRadius, y: borderRect.minY))
        addArc(withCenter: CGPoint(x: borderRect.maxX - cornerRadius, y: borderRect.minY + cornerRadius),
               radius: cornerRadius,
               startAngle: -CGFloat.pi / 2,
               endAngle: 0,
               clockwise: true)
        addLine(to: CGPoint(x: borderRect.maxX, y: borderRect.minY + cornerSizeV + cornerRadius))
        // bottom-right
        move(to: CGPoint(x: borderRect.maxX, y: borderRect.maxY - cornerSizeV - cornerRadius))
        addLine(to: CGPoint(x: borderRect.maxX, y: borderRect.maxY - cornerRadius))
        addArc(withCenter: CGPoint(x: borderRect.maxX - cornerRadius, y: borderRect.maxY - cornerRadius),
               radius: cornerRadius,
               startAngle: 0,
               endAngle: CGFloat.pi / 2,
               clockwise: true)
        addLine(to: CGPoint(x: borderRect.maxX - cornerSizeH - cornerRadius, y: borderRect.maxY))
        // bottom-left
        move(to: CGPoint(x: borderRect.minX + cornerSizeH + cornerRadius, y: borderRect.maxY))
        addLine(to: CGPoint(x: borderRect.minX + cornerRadius, y: borderRect.maxY))
        addArc(withCenter: CGPoint(x: borderRect.minX + cornerRadius,
                                   y: borderRect.maxY - cornerRadius),
               radius: cornerRadius,
               startAngle: CGFloat.pi / 2,
               endAngle: CGFloat.pi,
               clockwise: true)
        addLine(to: CGPoint(x: borderRect.minX, y: borderRect.maxY - cornerSizeV - cornerRadius))
    }
}

// MARK: - Errors

enum AppError: Error {
    case captureSessionSetup(reason: String)
    case createRequestError(reason: String)
    case videoReadingError(reason: String)
    
    static func display(_ error: Error, inViewController viewController: UIViewController) {
        if let appError = error as? AppError {
            appError.displayInViewController(viewController)
        } else {
            print(error)
        }
    }
    
    func displayInViewController(_ viewController: UIViewController) {
        let title: String?
        let message: String?
        switch self {
        case .captureSessionSetup(let reason):
            title = "AVSession Setup Error"
            message = reason
        case .createRequestError(let reason):
            title = "Error Creating Vision Request"
            message = reason
        case .videoReadingError(let reason):
            title = "Error Reading Recorded Video."
            message = reason
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        viewController.present(alert, animated: true)
    }
}
