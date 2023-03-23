//
//  AVFrameCaptureViewController.swift
//  PlakasApp
//
//  Created by Murat BAKIRTAS on 16.02.2022.
//

import UIKit
import AVKit
import Vision
/*
 
 import SDWebImage
 import SCLAlertView
 import NotificationBannerSwift
 */
 
@available(iOS 13.0, *)
class AVFrameCaptureViewController: UIViewController {

    var captureSession = AVCaptureSession()
    var previewLayer = AVCaptureVideoPreviewLayer()
    var currentVideoDevice: AVCaptureDevice?

    var imageCropAndScaleOption = true
    
    var selfViewScale = CGAffineTransform()
    var selfViewTransform = CGAffineTransform()

    var currentValidPlakas = [String]()
    
    var vnMLCoreRequests = [VNCoreMLRequest]()
    var vnRecTextRequests = [VNRecognizeTextRequest]()
    var currentQueueImage: CVPixelBuffer?
    var currentQueueImageCVPixel: CVPixelBuffer?
    var currentQueueAreaofInter: CGRect?
    
    var emojisDic = [String: UIView]()

    var objectDetected = false
    var firsttry = true
    
    var isRegisteredUser = false
    var selfUseruid = String()
    
    var detectedPlatesTargetId: String?
    var detectedSignPlate: String?
    var detectedSignPlateIsUser: Bool?

    let heavyVibrationGenerator = UIImpactFeedbackGenerator(style: .heavy)
    let notiFeedBackGene = UINotificationFeedbackGenerator()
    
    
    
    let signPlateFrameIndicatorLayer: CALayer = {
        let layer = CALayer()
        layer.cornerRadius = 4
        layer.backgroundColor = UIColor(rgb: 0xfbc531).cgColor
        layer.opacity = 0.4
        layer.borderColor = UIColor(rgb: 0x2f3640).cgColor
        layer.borderWidth = 2
        return layer
    }()
    
    let placeSignPlateHereLayer: CALayer = {
        let layer = CALayer()
        layer.cornerRadius = 4
        layer.backgroundColor = UIColor.systemBlue.cgColor
        layer.opacity = 0.4
        return layer
    }()
    
    let placeSignPlateHereDashedBorder: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.lineDashPattern = [10, 5]
        shapeLayer.fillColor = UIColor(rgb: 0x2f3640).cgColor
        return shapeLayer
    }()

    let zoomUISlider: UISlider = {
        let slider = UISlider()
        slider.transform = CGAffineTransform(rotationAngle: -.pi/2)
        slider.minimumValue = 1.0
        slider.maximumValue = 5.0
        slider.isContinuous = true
        slider.tintColor = UIColor(rgb: 0xfbc531)
        slider.setValue(1.5, animated: false)
        //slider.setThumbImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        return slider
    }()
    
    
    let zoomInPlusLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.text = "+"
        label.font = label.font.withSize(30)
        return label
    }()
    
    let zoomOutMinusLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.text = "-"
        label.font = label.font.withSize(30)
        return label
    }()
    
    
    let pageContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    let signPlateFoundTopLabel: UILabel = {
        //0xfbc531 is sari
        //0x2f3640 is kapli gri
        let label = UILabel()
        label.backgroundColor = UIColor(rgb: 0x2f3640)
        label.isHidden = true
        label.layer.masksToBounds = true
        label.layer.borderWidth = 10
        label.layer.cornerRadius = 15
        label.textAlignment = .center
        label.textColor = .white
        label.font = label.font.withSize(40)
        label.layer.borderColor = UIColor(rgb: 0xfbc531).cgColor
        return label
    }()
    
    let retakeSignPlateButton: UIButton = {
        //0xfbc531 is sari
        //0x2f3640 is kapli gri
        let button = UIButton()
        button.isHidden = true
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 10
        button.backgroundColor = .white
        button.tintColor = .darkGray
        button.setTitleColor(UIColor.darkGray, for: .normal)
        button.setImage(UIImage(named: "retake-scan"), for: .normal)
        button.setTitle("Tekrar Dene", for: .normal)
        return button
    }()
    
    let exitPageImgView: UIImageView = {
        let imageview = UIImageView()
       return imageview
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDefaultObjectSettings()
        
        setupSelfViewFrameConstants()
        
        setupMLCoreRequest()
        setupTextRecRequst()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        captureSession.startRunning()
        DispatchQueue.main.async {
            self.signPlateFoundTopLabel.isHidden = true
            self.retakeSignPlateButton.isHidden = true
        }
        //cosmosRatingOperations()

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        captureSession.stopRunning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        navigationController?.navigationBar.isHidden = false
       
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    @objc func didTapClosePageButton(){
        DispatchQueue.main.async {
            self.dismiss(animated: true)
            
        }
    }
    
    @objc func didTapFlashOnOffButton(){
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return }
            guard device.hasTorch else { return }

            do {
                try device.lockForConfiguration()

                if (device.torchMode == AVCaptureDevice.TorchMode.on) {
                    device.torchMode = AVCaptureDevice.TorchMode.off
                    navigationItem.rightBarButtonItem!.image = UIImage(named: "flash-off-icon")

                } else {
                    do {
                        try device.setTorchModeOn(level: 1.0)
                        navigationItem.rightBarButtonItem!.image = UIImage(named: "flash-on-icon")
                    } catch {
                        print(error)
                    }
                }

                device.unlockForConfiguration()
            } catch {
                print(error)
            }
    }
    
    @objc func sliderValueDidChange(_ sender:UISlider!){
        guard let device = currentVideoDevice else{
            return
        }
        do {
            try device.lockForConfiguration()
            device.videoZoomFactor = CGFloat(sender.value)
            if 2.0 < sender.value && sender.value < 2.1{
                let generator = UIImpactFeedbackGenerator(style: .heavy)
                // generator.impactOccurred()
            }
            device.unlockForConfiguration()
        } catch {
            
            
            
        }
    }
    
    @objc func pinchRecognized(_ sender: UIPinchGestureRecognizer) {
        guard let device = currentVideoDevice else{
            return
        }
        if sender.state == .changed {
            
            let maxZoomFactor = 5.0
            let pinchVelocityDividerFactor: CGFloat = 5.0
            
            do {
                try device.lockForConfiguration()
                defer { device.unlockForConfiguration() }
                
                let desiredZoomFactor = device.videoZoomFactor + atan2(sender.velocity, pinchVelocityDividerFactor)
                device.videoZoomFactor = max(1.0, min(desiredZoomFactor, maxZoomFactor))
                zoomUISlider.value = Float(desiredZoomFactor)
            } catch {
                print(error)
            }
        }
        
    }
    
    private func setupMLCoreRequest(){
        let context = MLModelConfiguration()
        context.computeUnits = .all
        guard let duzPlakaModal = try? VNCoreMLModel(for: PlakaRecML_1_1(configuration: context).model) else {
            return
            
        }
        
        let requestml = VNCoreMLRequest(model: duzPlakaModal) { [weak self] finishedReq, error in
            if error != nil{
                print("VNCoreMLRequest error: ", error)
                return
            }
            self?.currentValidPlakas.removeAll()
            guard let results = finishedReq.results as? [VNRecognizedObjectObservation] else {
                print("non666")
                return
            }
            self?.observeResults(results: results)
        }

        requestml.imageCropAndScaleOption = .centerCrop
        vnMLCoreRequests = [requestml]
    }
    
    private func setupTextRecRequst(){
        let requesttext = VNRecognizeTextRequest{request, error in
            guard error == nil else{
                      print("444as text rec hata", error, Date())
                      return
                  }
            guard let observations = request.results as? [VNRecognizedTextObservation] else{
                print("non444")
                return
            }
            for currObservation in observations{
                let topCandidate = currObservation.topCandidates(1)
                if let recognizedText = topCandidate.first{
                    //print("plaka is read 444as", recognizedText.string)
                    print("33221122",currObservation.confidence, Date())
                    
                    let plateToShow = recognizedText.string.uppercased().onlyLettersAndNumbers
                    let readSignPlate = recognizedText.string.uppercased().onlyLettersAndNumbers.filter {!$0.isWhitespace}
                    let plateForUrl = plateToShow.replacingOccurrences(of: " ", with: "%20")
                    if SystemFunctionalities.shared.isRepresentingSignPlate(text: readSignPlate){
                        DispatchQueue.main.async {
                            self.captureSession.stopRunning()
                            if let currentQueueImage = self.currentQueueImage{
                                if let imgData = SystemFunctionalities().cvPixelBufferToDataConverter(with: currentQueueImage){
                                    SystemFunctionalities().uploadScannedPlateFile(fileData: imgData, fileName: "fileName07", plateNumber: plateForUrl, completion: { (uploadedUrl, uploadErr) in
                                        if let uploadedUrl = uploadedUrl{
                                            print("asf23f_f23 \(uploadedUrl)")
                                        }
                                         if let uploadErr = uploadErr{
                                            print("asf2300f_f23 \(uploadErr)")
                                        }
                                    })
                                }
                            }
                            self.signPlateFoundTopLabel.isHidden = false
                            self.retakeSignPlateButton.isHidden = false
                            self.zoomUISlider.isHidden = true
                            self.zoomOutMinusLabel.isHidden = true
                            self.zoomInPlusLabel.isHidden = true
                            self.signPlateFoundTopLabel.text = plateToShow
                            self.detectedSignPlate = readSignPlate
                            ///flutter requires only the plate num from  'VISION of SWIFT'
                            
                            NotificationCenter.default.post(name: Notification.Name("listenForPlateNumber"), object: nil, userInfo: ["plateNumber": self.detectedSignPlate ?? ""])
                            
                            DispatchQueue.main.async {
                                self.dismiss(animated: true);
                            }
                            return
                            ///
                            //self.checkAndProgressPlate(signPlate: readSignPlate)
                           // self.heavyVibrationGenerator.impactOccurred()
                        }
                    }
                }
            }
        }
        requesttext.usesLanguageCorrection = false
        requesttext.recognitionLevel = .accurate
        vnRecTextRequests = [requesttext]
    }
    
    
    private func drawRectanglesToBoundingboxes(boundingBoxes: [CGRect]){
        if boundingBoxes.count > 0  {
            DispatchQueue.main.async {
                self.signPlateFrameIndicatorLayer.isHidden = false
                self.signPlateFrameIndicatorLayer.frame = boundingBoxes[0]
            }
        }
    }
    
    
    private func setupInputCapture(){
        guard let device = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera, .builtInTrueDepthCamera],
            mediaType: .video,
            position: .back).devices.first else {
                print("No back camera device found.")
                return
            }
        currentVideoDevice = device
        let cameraInput = try! AVCaptureDeviceInput(device: device)
        self.captureSession.addInput(cameraInput)
        
        do {
            try device.lockForConfiguration()
            device.videoZoomFactor = 1.5
            device.focusMode = .continuousAutoFocus
            device.unlockForConfiguration()
        } catch {
            
        }
    }
    
    private func setupOutputCapture() {
        let outputCapture = AVCaptureVideoDataOutput()
        outputCapture.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(outputCapture)
    }
    
    private func setupDefaultObjectSettings(){
        if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
            setupInputCapture()
            setupOutputCapture()
        } else {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                if granted {
                    self.setupInputCapture()
                    self.setupOutputCapture()
                } else {
                   print("kamera izi  yok abeyy 123f2_G2g")
                
                }
            })
        }
        
        setupLayersAndViews()
        setupNavigationBarItems()
        
        
    }
    
    private func setupNavigationBarItems(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "flash-off-icon"), style: .plain, target: self, action: #selector(didTapFlashOnOffButton))
        navigationItem.rightBarButtonItem?.tintColor = .darkGray
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "multiply-icon"), style: .plain, target: self, action: #selector(didTapClosePageButton))
        navigationItem.leftBarButtonItem?.tintColor = .darkGray
        title = "Plaka Tanıma"
    }
    
    private func setupLayersAndViews(){
        
        makePreviewLayer()
        view.addSubview(pageContainerView)
        view.addSubview(zoomUISlider)
        view.addSubview(signPlateFoundTopLabel)
        view.addSubview(retakeSignPlateButton)
        view.addSubview(zoomInPlusLabel)
            view.addSubview(zoomOutMinusLabel)
        view.addSubview(exitPageImgView)
        
        
        
        pageContainerView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        zoomUISlider.frame = CGRect(x: self.view.frame.size.width-40, y: self.view.frame.size.height/2-100, width: 30, height: 200)
        
        exitPageImgView.frame = CGRect(x: 20, y: 50, width: 30, height: 30)
        exitPageImgView.image = UIImage(named: "multiply-white-icon")
        
        let exitgest = UITapGestureRecognizer(target: self, action: #selector(didTapClosePageButton))
        exitPageImgView.addGestureRecognizer(exitgest)
        
        self.pageContainerView.layer.insertSublayer(signPlateFrameIndicatorLayer, above: self.previewLayer)
        self.pageContainerView.layer.insertSublayer(placeSignPlateHereLayer, above: self.previewLayer)
        placeSignPlateHereLayer.frame = CGRect(x: 50, y: self.view.frame.height/2-80, width: self.view.frame.width-100, height: 100)
        
        zoomUISlider.addTarget(self, action: #selector(self.sliderValueDidChange(_:)), for: .valueChanged)
        
        
        placeSignPlateHereDashedBorder.frame = placeSignPlateHereLayer.bounds
        placeSignPlateHereDashedBorder.path = UIBezierPath(roundedRect: placeSignPlateHereLayer.bounds, cornerRadius: 5).cgPath
        placeSignPlateHereLayer.addSublayer(placeSignPlateHereDashedBorder)
        
        
        
        signPlateFoundTopLabel.frame = CGRect(x: 75, y: 150, width: view.frame.size.width-150, height: 70)
        
        retakeSignPlateButton.frame = CGRect(x: view.frame.size.width-165, y:  view.frame.size.height - 330, width: 150, height: 40)
        retakeSignPlateButton.addTarget(self, action: #selector(retakeSignPlateButtonTapped), for: .touchUpInside)
        
        zoomInPlusLabel.frame = CGRect(x: self.view.frame.size.width-37, y: self.view.frame.size.height/2-130, width: 25, height: 25)
        zoomOutMinusLabel.frame = CGRect(x: self.view.frame.size.width-37, y: self.view.frame.size.height/2+95, width: 25, height: 25)
    
        
        let pinchToZoomGesRec = UIPinchGestureRecognizer(target: self, action:#selector(pinchRecognized(_:)))
        pageContainerView.addGestureRecognizer(pinchToZoomGesRec)
       
    }
    
    

    @objc func retakeSignPlateButtonTapped(){
        DispatchQueue.main.async {
            self.captureSession.startRunning()
            self.signPlateFoundTopLabel.isHidden = true
            self.retakeSignPlateButton.isHidden = true
            self.zoomUISlider.isHidden = false
            self.zoomOutMinusLabel.isHidden = false
            self.zoomInPlusLabel.isHidden = false
        }
    }
    
    

 
   
    private func makePreviewLayer(){
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
       // previewLayer.videoGravity = .resizeAspectFill
        pageContainerView.layer.addSublayer(previewLayer)
        
        previewLayer.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        //
        
    }
    
    private func imageProccessRequest(pixelBuffImage: CVPixelBuffer) {
        do{
            try VNImageRequestHandler(cvPixelBuffer:pixelBuffImage, options: [:]).perform(vnMLCoreRequests)
        }
        catch{
            print("non555")
        }
    }
    
    private func observeResults(results: [VNRecognizedObjectObservation]){
        var objectsBoundingBoxes: [CGRect] = [CGRect]()
        for i in 0..<results.count{
            let currResult = results[i]
            if currResult.confidence > 0.5{
                //print("\(results.count) tane plaka bulundu")
                objectsBoundingBoxes.append(currResult.boundingBox.applying(selfViewScale).applying(selfViewTransform))
                self.observePlakaText(areaOfInterrest: currResult.boundingBox)
                //print(currResult.boundingBox, currResult.boundingBox.minX, currResult.boundingBox.minY)
                
            }
        }
        if results.isEmpty{
            DispatchQueue.main.async {
                self.signPlateFrameIndicatorLayer.isHidden = true
            }
        }else{
            self.drawRectanglesToBoundingboxes(boundingBoxes: objectsBoundingBoxes)
        }
    }
    
    private func makePlakaClean(text: String) -> String{
        let string = text.trimmingCharacters(in: .whitespaces).removeExtraSpaces
        return string
    }
    
    private func isRepresentingPlaka(text: String) -> Bool{
        
        var string = text.trimmingCharacters(in: .whitespaces)
        string = string.removeExtraSpaces
        let textArr = string.split(separator: " ")
       // print(text, " => ", string)
        if textArr.count == 3{
            if "\(textArr[0])".count == 2 &&
                "\(textArr[0])".isInt &&
                "\(textArr[1])".isUpperNLatinAlp &&
                "\(textArr[2])".count >= 2 &&
                "\(textArr[2])".isInt{
                return true
            }
        }
       // print("4444\(string)")
        return false
        
        //split is same woth removing extra and both end white spaces
    }
    
    
    private func observePlakaText(areaOfInterrest: CGRect){
        guard let image = currentQueueImage else{
            return
        }
        
        guard let currReq = vnRecTextRequests.first else{
            return
        }
        currReq.regionOfInterest = areaOfInterrest

        let handler = VNImageRequestHandler(cvPixelBuffer: image, options: [:])
        
        do{
            try handler.perform(vnRecTextRequests)
        }
        catch{
            print("error performing ([request]) 444as", error)
        }
        
    }
    
    
    private func setupSelfViewFrameConstants(){
        let selfViewWidth = self.view.bounds.width
        let height =  selfViewWidth * 16 / 9
        let offsetY = (self.view.bounds.height - height) / 2
        selfViewScale = CGAffineTransform.identity.scaledBy(x: selfViewWidth, y: height)
        selfViewTransform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -height - offsetY)
    }
}

@available(iOS 13.0, *)
extension AVFrameCaptureViewController: AVCaptureVideoDataOutputSampleBufferDelegate{
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        connection.videoOrientation = .portrait
        guard let cvPixel: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        self.imageProccessRequest(pixelBuffImage: cvPixel)
        currentQueueImage = cvPixel
    }
}

