/*
See LICENSE folder for this sample’s licensing information.

Abstract:
View controller responsible for the game flow.
     The game flow consists of the following tasks:
     - player detection
     - trajectory detection
     - player action classification
     - release angle, release speed and score computation
*/

import UIKit
import AVFoundation
import Vision

class GameViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet var beanBags: [UIImageView]!
    @IBOutlet weak var gameStatusLabel: OverlayLabel!
    @IBOutlet weak var throwTypeLabel: UILabel!
    @IBOutlet weak var releaseAngleLabel: UILabel!
    @IBOutlet weak var metricsStackView: UIStackView!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var speedStackView: UIStackView!
    @IBOutlet weak var throwTypeImage: UIImageView!
    @IBOutlet weak var dashboardView: DashboardView!
    @IBOutlet weak var underhandThrowView: ProgressView!
    @IBOutlet weak var overhandThrowView: ProgressView!
    @IBOutlet weak var underlegThrowView: ProgressView!
    @IBOutlet weak var stopButton: UIButton!
    private let gameManager = GameManager.shared
    private let detectPlayerRequest = VNDetectHumanBodyPoseRequest()
    private var playerDetected = false
    private var isBagInTargetRegion = false
    private var throwRegion = CGRect.null
    private var targetRegion = CGRect.null
    private let trajectoryView = TrajectoryView()
    private let playerBoundingBox = BoundingBoxView()
    private let jointSegmentView = JointSegmentView()
    private var noObservationFrameCount = 0
    private var trajectoryInFlightPoseObservations = 0
    private var showSummaryGesture: UITapGestureRecognizer!
    private let trajectoryQueue = DispatchQueue(label: "com.ActionAndVision.trajectory", qos: .userInteractive)
    private let bodyPoseDetectionMinConfidence: VNConfidence = 0.6
    private let trajectoryDetectionMinConfidence: VNConfidence = 0.9
    private let bodyPoseRecognizedPointMinConfidence: VNConfidence = 0.1
    private lazy var detectTrajectoryRequest: VNDetectTrajectoriesRequest! =
                        VNDetectTrajectoriesRequest(frameAnalysisSpacing: .zero, trajectoryLength: GameConstants.trajectoryLength)
    
    var summaryView: ExerciseSummaryViewController?
    
    var legCount: Int = 0
    var workoutType : String? = ""
    
    //Variables - KPIs
    var lastThrowMetrics: ThrowMetrics {
        get {
            return gameManager.lastThrowMetrics
        }
        set {
            gameManager.lastThrowMetrics = newValue
        }
    }

    var playerStats: PlayerStats {
        get {
            return gameManager.playerStats
        }
        set {
            gameManager.playerStats = newValue
        }
    }
    
    var  lowerStats: LowerStats {
            get {
                return gameManager.lowerStats
            }
            set {
                gameManager.lowerStats = newValue
            }
        }
    
    var upperStats: UpperStats {
            get {
                return gameManager.upperStats
            }
            set {
                gameManager.upperStats = newValue
            }
        }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUIElements()
//        showSummaryGesture = UITapGestureRecognizer(target: self, action: #selector(handleShowSummaryGesture(_:)))
//        showSummaryGesture.numberOfTapsRequired = 2
//        view.addGestureRecognizer(showSummaryGesture)
        view.bringSubviewToFront(stopButton)
        self.tabBarController?.tabBar.isHidden = true;
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        gameStatusLabel.perform(transition: .fadeIn, duration: 0.25)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        detectTrajectoryRequest = nil
    }
    
    func getScoreLabelAttributedStringForScore(_ score: Int) -> NSAttributedString {
        let totalScore = NSMutableAttributedString(string: "Total Score ", attributes: [.foregroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.65)])
        totalScore.append(NSAttributedString(string: "\(score)", attributes: [.foregroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)]))
        totalScore.append(NSAttributedString(string: "/10", attributes: [.foregroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.65)]))
        return totalScore
    }

    func setUIElements() {
        resetKPILabels()
        playerBoundingBox.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        playerBoundingBox.backgroundOpacity = 0
        playerBoundingBox.isHidden = true
        view.addSubview(playerBoundingBox)
        view.addSubview(jointSegmentView)
//        view.addSubview(trajectoryView)
        gameStatusLabel.text = "자세를 잡아주세요"
        // Set throw type counters
//        underhandThrowView.throwType = .underhand
//        overhandThrowView.throwType = .overhand
//        underlegThrowView.throwType = .underleg
//        scoreLabel.attributedText = getScoreLabelAttributedStringForScore(0)
    }

    func resetKPILabels() {
        // Reset Speed and throwType image
        dashboardView.speed = 0
        throwTypeImage.image = nil
        // Hode KPI labels
        dashboardView.isHidden = true
        speedStackView.isHidden = true
        metricsStackView.isHidden = true
    }

    func updateKPILabels() -> Int {
        // Show KPI labels
        dashboardView.isHidden = false
        speedStackView.isHidden = false
        metricsStackView.isHidden = false
        // Update text for KPI labels
        speedLabel.text = "\(lastThrowMetrics.releaseSpeed)"
        throwTypeLabel.text = lastThrowMetrics.throwType.rawValue.capitalized
        
        var legCount = updateLegPosition(angle: kneeAngle2)
        var armCount = updateArmPosition(angle: elbowAngle2)
            
            // Update release angle label and get the count based on throw type
        switch lastThrowMetrics.throwType {
            case .legpress, .legextension:
                legCount = updateLegPosition(angle: kneeAngle2)
                releaseAngleLabel.text = "\(legCount+1) 회"
            case .chestpress, .latpulldown:
                armCount = updateArmPosition(angle: elbowAngle2)
                releaseAngleLabel.text = "\(armCount+1) 회"
            }
        print("운동횟수: \(legCount+1)")
        
        scoreLabel.attributedText = getScoreLabelAttributedStringForScore(gameManager.playerStats.totalScore)
        // Update throw type counters
        throwTypeImage.image = UIImage(named: lastThrowMetrics.throwType.rawValue)
        switch lastThrowMetrics.throwType {
            default:
                break
        }
        // Update score labels
        let beanBagView = beanBags[playerStats.throwCount - 1]
        beanBagView.image = UIImage(named: "Score\(lastThrowMetrics.score.rawValue)")
        
        return legCount+1
    }

    func updateBoundingBox(_ boundingBox: BoundingBoxView, withRect rect: CGRect?) {
        // Update the frame for player bounding box
        boundingBox.frame = rect ?? .zero
        boundingBox.perform(transition: (rect == nil ? .fadeOut : .fadeIn), duration: 0.1)
    }

    func humanBoundingBox(for observation: VNHumanBodyPoseObservation) -> CGRect {
        var box = CGRect.zero
        var normalizedBoundingBox = CGRect.null
        // Process body points only if the confidence is high.
        guard observation.confidence > bodyPoseDetectionMinConfidence, let points = try? observation.recognizedPoints(forGroupKey: .all) else {
            return box
        }
        // Only use point if human pose joint was detected reliably.
        for (_, point) in points where point.confidence > bodyPoseRecognizedPointMinConfidence {
            normalizedBoundingBox = normalizedBoundingBox.union(CGRect(origin: point.location, size: .zero))
        }
        if !normalizedBoundingBox.isNull {
            box = normalizedBoundingBox
        }
        // Fetch body joints from the observation and overlay them on the player.
        let joints = getBodyJointsFor(observation: observation)
        DispatchQueue.main.async {
            self.jointSegmentView.joints = joints
        }
        // Store the body pose observation in playerStats when the game is in TrackThrowsState.
        // We will use these observations for action classification once the throw is complete.
        if gameManager.stateMachine.currentState is GameManager.TrackThrowsState {
            playerStats.storeObservation(observation)
            if trajectoryView.inFlight {
                trajectoryInFlightPoseObservations += 1
            }
        }
        return box
    }

    // Define regions to filter relavant trajectories for the game
    // throwRegion: Region to the right of the player to detect start of throw
    // targetRegion: Region around the board to determine end of throw
    func resetTrajectoryRegions() {
//        let boardRegion = gameManager.boardRegion
        let playerRegion = playerBoundingBox.frame
        let throwWindowXBuffer: CGFloat = 50
        let throwWindowYBuffer: CGFloat = 50
//        let targetWindowXBuffer: CGFloat = 50
        let throwRegionWidth: CGFloat = 400
        throwRegion = CGRect(x: playerRegion.maxX + throwWindowXBuffer, y: 0, width: throwRegionWidth, height: playerRegion.maxY - throwWindowYBuffer)
//        targetRegion = CGRect(x: boardRegion.minX - targetWindowXBuffer, y: 0,
//                              width: boardRegion.width + 2 * targetWindowXBuffer, height: boardRegion.maxY)
    }

    // Adjust the throwRegion based on location of the bag.
    // Move the throwRegion to the right until we reach the target region.
    func updateTrajectoryRegions() {
        let trajectoryLocation = trajectoryView.fullTrajectory.currentPoint
        let didBagCrossCenterOfThrowRegion = trajectoryLocation.x > throwRegion.origin.x + throwRegion.width / 2
        guard !(throwRegion.contains(trajectoryLocation) && didBagCrossCenterOfThrowRegion) else {
            return
        }
        // Overlap buffer window between throwRegion and targetRegion
        let overlapWindowBuffer: CGFloat = 50
        if targetRegion.contains(trajectoryLocation) {
            // When bag is in target region, set the throwRegion to targetRegion.
            throwRegion = targetRegion
        } else if trajectoryLocation.x + throwRegion.width / 2 - overlapWindowBuffer < targetRegion.origin.x {
            // Move the throwRegion forward to have the bag at the center.
            throwRegion.origin.x = trajectoryLocation.x - throwRegion.width / 2
        }
        trajectoryView.roi = throwRegion
    }
    
    func processTrajectoryObservations(_ controller: CameraViewController, _ results: [VNTrajectoryObservation]) {
        if self.trajectoryView.inFlight && results.count < 1 {
            // The trajectory is already in flight but VNDetectTrajectoriesRequest doesn't return any trajectory observations.
            self.noObservationFrameCount += 1
            if self.noObservationFrameCount > GameConstants.noObservationFrameLimit {
                // Ending the throw as we don't see any observations in consecutive GameConstants.noObservationFrameLimit frames.
                self.updatePlayerStats(controller)
            }
        } else {
            for path in results where path.confidence > trajectoryDetectionMinConfidence {
                // VNDetectTrajectoriesRequest has returned some trajectory observations.
                // Process the path only when the confidence is over 90%.
                self.trajectoryView.duration = path.timeRange.duration.seconds
                self.trajectoryView.points = path.detectedPoints
                self.trajectoryView.perform(transition: .fadeIn, duration: 0.25)
                if !self.trajectoryView.fullTrajectory.isEmpty {
                    // Hide the previous throw metrics once a new throw is detected.
                    if !self.dashboardView.isHidden {
                        self.resetKPILabels()
                    }
                    self.updateTrajectoryRegions()
                    if self.trajectoryView.isThrowComplete {
                        // Update the player statistics once the throw is complete.
                        self.updatePlayerStats(controller)
                    }
                }
                self.noObservationFrameCount = 0
            }
        }
    }
    
    func updatePlayerStats(_ controller: CameraViewController) {
        let finalBagLocation = trajectoryView.finalBagLocation
        playerStats.storePath(self.trajectoryView.fullTrajectory.cgPath)
        trajectoryView.resetPath()
        lastThrowMetrics.updateThrowType(playerStats.getLastThrowType())
        let score = computeScore(controller.viewPointForVisionPoint(finalBagLocation))
        // Compute the speed in mph
        // trajectoryView.speed is in points/second, convert that to meters/second by multiplying the pointToMeterMultiplier.
        // 1 meters/second = 2.24 miles/hour
        let releaseSpeed = round(trajectoryView.speed * gameManager.pointToMeterMultiplier * 2.24 * 100) / 100
        let releaseAngle = playerStats.getReleaseAngle()
        lastThrowMetrics.updateMetrics(newScore: score, speed: releaseSpeed, angle: releaseAngle)
        self.gameManager.stateMachine.enter(GameManager.ThrowCompletedState.self)
    }
    
    // 스코어 계산
    func computeScore(_ finalBagLocation: CGPoint) -> Scoring {
        
        switch lastThrowMetrics.throwType {
        case .chestpress, .latpulldown:
            // Handle chestpress scoring logic here
            return lastThrowMetrics.throwType == .latpulldown ? Scoring.one : Scoring.one

        case .legpress, .legextension:
            // Handle legextension scoring logic here
            return lastThrowMetrics.throwType == .legpress ? Scoring.one : Scoring.one
        }
    }
    
    // 버튼
    @IBAction func stopButtonAct(_ sender: Any) {
        // 현재 뷰를 dismiss 처리 작업번호 TSK-67 자세코치 화면 구현 트러블 슈팅 확인
        
        self.dismiss(animated: false, completion: {
            let resultBoard = UIStoryboard(name: "ExerciseSummaryViewController", bundle: nil)
            guard let vc = resultBoard.instantiateViewController(withIdentifier: "ExerciseSummaryViewController") as? ExerciseSummaryViewController else {return}
            vc.workoutType = self.throwTypeLabel.text
            vc.count = self.updateKPILabels()
            self.navigationController?.pushViewController(vc, animated: true)
        })
    }
    
}

extension GameViewController: GameStateChangeObserver {
    func gameManagerDidEnter(state: GameManager.State, from previousState: GameManager.State?) {
        switch state {
        case is GameManager.DetectedPlayerState:
            playerDetected = true
            playerStats.reset()
            playerBoundingBox.perform(transition: .fadeOut, duration: 1.0)
            gameStatusLabel.text = "시작"
            gameStatusLabel.perform(transitions: [.popUp, .popOut], durations: [0.25, 0.12], delayBetween: 1) {
                self.gameManager.stateMachine.enter(GameManager.TrackThrowsState.self)
            }
        case is GameManager.TrackThrowsState:
            resetTrajectoryRegions()
            trajectoryView.roi = throwRegion
        case is GameManager.ThrowCompletedState:
            dashboardView.speed = lastThrowMetrics.releaseSpeed
            dashboardView.animateSpeedChart()
            playerStats.adjustMetrics(score: lastThrowMetrics.score, speed: lastThrowMetrics.releaseSpeed,
                                      releaseAngle: lastThrowMetrics.releaseAngle, throwType: lastThrowMetrics.throwType)
            playerStats.resetObservations()
            trajectoryInFlightPoseObservations = 0
            self.updateKPILabels()
            
            gameStatusLabel.text = lastThrowMetrics.score.rawValue > 0 ? "+\(lastThrowMetrics.score.rawValue)" : ""
            gameStatusLabel.perform(transitions: [.popUp, .popOut], durations: [0.25, 0.12], delayBetween: 1) {
                if self.playerStats.throwCount == GameConstants.maxThrows {
                    self.gameManager.stateMachine.enter(GameManager.ShowSummaryState.self)
                } else {
                    self.gameManager.stateMachine.enter(GameManager.TrackThrowsState.self)
                }
            }
        default:
            break
        }
    }
}

extension GameViewController: CameraViewControllerOutputDelegate {
    func cameraViewController(_ controller: CameraViewController, didReceiveBuffer buffer: CMSampleBuffer, orientation: CGImagePropertyOrientation) {
        // Vision 요청 핸들러를 설정하고, 현재 게임 상태가 'TrackThrowsState'인지 확인
        let visionHandler = VNImageRequestHandler(cmSampleBuffer: buffer, orientation: orientation, options: [:])
        if gameManager.stateMachine.currentState is GameManager.TrackThrowsState {
            DispatchQueue.main.async {
                // Get the frame of rendered view
                // 렌더링된 뷰의 프레임을 가져와서 정규화
                let normalizedFrame = CGRect(x: 0, y: 0, width: 1, height: 1)
                // 관절 세그먼트 뷰와 경로 뷰의 프레임을 설정
                self.jointSegmentView.frame = controller.viewRectForVisionRect(normalizedFrame)
                self.trajectoryView.frame = controller.viewRectForVisionRect(normalizedFrame)
            }
            // Perform the trajectory request in a separate dispatch queue.
            // 동작 감지하여 Observations 에 반영, 코드 없애지 말 것
            // 궤적 탐지 요청을 별도의 디스패치 큐에서 수행
            trajectoryQueue.async {
                do {
                    // 궤적 탐지 요청을 실행합니다.
                    try visionHandler.perform([self.detectTrajectoryRequest])
                    if let results = self.detectTrajectoryRequest.results {
                        DispatchQueue.main.async {
                            // 궤적 관측 결과를 처리
                            self.processTrajectoryObservations(controller, results)
                        }
                    }
                } catch {
                    // 오류가 발생하면 오류를 표시
                    AppError.display(error, inViewController: self)
                }
            }
        }
        // Body pose request is performed on the same camera queue to ensure the highlighted joints are aligned with the player.
        // Run bodypose request for additional GameConstants.maxPostReleasePoseObservations frames after the first trajectory observation is detected.
        // 플레이어 본문 요청은 관절 세그먼트와 정렬되도록 동일한 카메라 큐에서 수행.
        // 최초 궤적 관측이 감지된 후 GameConstants.maxTrajectoryInFlightPoseObservations 프레임의 추가 GameConstants.maxPostReleasePoseObservations 프레임에 대해 본문 요청을 실행.
        if !(self.trajectoryView.inFlight && self.trajectoryInFlightPoseObservations >= GameConstants.maxTrajectoryInFlightPoseObservations) {
            do {
                // 플레이어 요청을 실행합니다.
                try visionHandler.perform([detectPlayerRequest])
                if let result = detectPlayerRequest.results?.first {
                    // 인간 바운딩 상자를 가져오기
                    let box = humanBoundingBox(for: result)
                    let boxView = playerBoundingBox
                    DispatchQueue.main.async {
                        // 상자의 뷰 프레임을 업데이트
                        let inset: CGFloat = -20.0
                        let viewRect = controller.viewRectForVisionRect(box).insetBy(dx: inset, dy: inset)
                        self.updateBoundingBox(boxView, withRect: viewRect)
                        if !self.playerDetected && !boxView.isHidden {
                            // 플레이어가 감지되지 않았고 상자 뷰가 숨겨지지 않았다면 게임 상태를 'DetectedPlayerState'로 설정
                            self.gameStatusLabel.alpha = 0
                            self.resetTrajectoryRegions()
                            self.gameManager.stateMachine.enter(GameManager.DetectedPlayerState.self)
                        }
                    }
                }
            } catch {
                AppError.display(error, inViewController: self)
            }
        } else {
            // Hide player bounding box
            // 플레이어 바운딩 상자를 숨기기
            DispatchQueue.main.async {
                if !self.playerBoundingBox.isHidden {
                    self.playerBoundingBox.isHidden = true
                    self.jointSegmentView.resetView()
                }
            }
        }
    }
}

//extension GameViewController {
//    @objc
//    func handleShowSummaryGesture(_ gesture: UITapGestureRecognizer) {
//        if gesture.state == .ended {
//            // 사용자가 화면을 탭했을 때, 게임 매니저의 상태를 'ShowSummaryState'로 변경
//            self.gameManager.stateMachine.enter(GameManager.ShowSummaryState.self)
//        }
//    }
//}
