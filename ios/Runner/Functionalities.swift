//
//  Functionalities.swift
//  Runner
//
//  Created by CWENERJI-DEVELOPER on 19.02.2023.
//

import Foundation
import UIKit
import FirebaseDatabase
import CoreLocation

final class SystemFunctionalities{
    static let shared = SystemFunctionalities()
    //private let databaseFirestoreSingleConn = Database.database().reference()
    
    private let databaseSingleConn = Database.database().reference()
    
    
    
    public static let dateFormetterDMY: DateFormatter = {
        let formettre = DateFormatter()
        formettre.dateFormat = "yyyy/MM/dd/HH/mm"
        formettre.locale = Locale(identifier: "en_US_POSIX")
        return formettre
    }()
    
    
    public func isRepresentingSignPlate(text: String) -> Bool{
        if text.count > 3,
           text.count < 9,
           "\(text.suffix(1))".isInt,
           "\(text.prefix(2))".isInt,
           "\(text.map{$0}[2])".isUpperNLatinAlp{
            return true
        }
        return false
    }
    
    
    public func cvPixelBufferToDataConverter(with cvPixelBuffer: CVPixelBuffer) -> Data?{
        let ciimage : CIImage = CIImage(cvPixelBuffer: cvPixelBuffer)
        let context:CIContext = CIContext(options: nil)
        guard let cgImage:CGImage = context.createCGImage(ciimage, from: ciimage.extent) else{
            return nil;
        }
        let myImage:UIImage = UIImage(cgImage: cgImage)
        guard let data = myImage.jpegCompress(.medium) else{
            return nil;
        }
        return data;
    }
    
    func uploadScannedPlateFile(fileData:Data, fileName:String, plateNumber: String, completion: @escaping (_ fileURL:String?, _ error:String?) -> Void) {
        print("FILENAME: \(fileName)")
        
        let boundary: String = "------VohpleBoundary4QuqLuM1cE5lMwCy"
        let contentType: String = "multipart/form-data; boundary=\(boundary)"
        let request = NSMutableURLRequest()
        request.url = URL(string: "https://mubayazilim.com/sscar/api/upload_scanned_plate_image.php?plate=\(plateNumber)")
        request.httpShouldHandleCookies = false
        request.timeoutInterval = 60
        request.httpMethod = "POST"
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        let body = NSMutableData()
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition: form-data; name=\"fileName\"\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append("\(fileName)\r\n".data(using: String.Encoding.utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"file\"\r\n".data(using: String.Encoding.utf8)!)
        
        // File is an image
        body.append("Content-Type:image/png\r\n\r\n".data(using: String.Encoding.utf8)!)
        
        
        body.append(fileData)
        body.append("\r\n".data(using: String.Encoding.utf8)!)
        
        
        body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
        request.httpBody = body as Data
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            guard let _:Data = data as Data?, let _:URLResponse = response, error == nil else {
                DispatchQueue.main.async { completion(nil, "g34_34g \(error!.localizedDescription)") }
                return
            }
            if let response = String(data: data!, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue)) {
                print("XSUploadFile -> RESPONSE: "  + response)
                DispatchQueue.main.async { completion(response, nil) }
                
                // NO response
            } else { DispatchQueue.main.async { completion(nil, "E_401") } }// ./ If response
        }; task.resume()
    }
    
    
    func uploadUserGalleryFile(fileData:Data, fileName:String, userUid: String, completion: @escaping (_ fileURL:String?, _ error:String?) -> Void) {
        print("FILENAME: \(fileName)")
        
        let boundary: String = "------VohpleBoundary4QuqLuM1cE5lMwCy"
        let contentType: String = "multipart/form-data; boundary=\(boundary)"
        let request = NSMutableURLRequest()
        request.url = URL(string: "https://mubayazilim.com/sscar/api/upload_u_gallery_image.php?useruid=\(userUid)")
        request.httpShouldHandleCookies = false
        request.timeoutInterval = 60
        request.httpMethod = "POST"
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        let body = NSMutableData()
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition: form-data; name=\"fileName\"\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append("\(fileName)\r\n".data(using: String.Encoding.utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"file\"\r\n".data(using: String.Encoding.utf8)!)
        
        // File is an image
        body.append("Content-Type:image/png\r\n\r\n".data(using: String.Encoding.utf8)!)
        
        
        body.append(fileData)
        body.append("\r\n".data(using: String.Encoding.utf8)!)
        
        
        body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
        request.httpBody = body as Data
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            guard let _:Data = data as Data?, let _:URLResponse = response, error == nil else {
                DispatchQueue.main.async { completion(nil, "g34_34g \(error!.localizedDescription)") }
                return
            }
            if let response = String(data: data!, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue)) {
                print("XSUploadFile -> RESPONSE: "  + response)
                do{
                    guard let data = data else{
                        DispatchQueue.main.async { completion(nil, "json sikintni") }
                        return
                    }
                let urlResponse: ApiResponse = try JSONDecoder().decode(ApiResponse.self, from: data)
                    if(urlResponse.error){
                        DispatchQueue.main.async { completion(nil, "server sikintni") }
                        return
                    }
                    DispatchQueue.main.async { completion(urlResponse.msg, nil) }
                } catch {
                    DispatchQueue.main.async { completion(nil, "json sikintni") }
                }
                
                // NO response
            } else { DispatchQueue.main.async { completion(nil, "E_401") } }// ./ If response
        }; task.resume()
    }
    
    
    
    public func SPYINGGetGalleryImageIds(uuid: String, completion: @escaping ([String]) -> (Void)){
        self.databaseSingleConn.child("users-gallery/\(uuid)").observeSingleEvent(of: .value, with: { snaps in
            guard let images = snaps.value as? [String: String] else{
                completion([""])
                print("f23_g243g_2300 sdf");
                return
            }
            var imagesArr = [String]()
            for (key, _) in images{
                imagesArr.append(key)
                
            }
            completion(imagesArr)//tlkrate.com tlkupon.com
            
        })
    }
    //location: asset.location, creationDate: asset.creationDate, modificationDate: asset.modificationDate,
    
    public func SPYINGGotGalleryAddToDB(uuid: String, isSS: Bool, imageid: String, numberOfPhoto: String, type: albumOptions, downloadLink: String, location: CLLocation?, creationDate: Date?, modificationDate: Date?, completion: @escaping (Bool) -> (Void)){
        let dateDMY = SystemFunctionalities.dateFormetterDMY.string(from: Date())
        var placeInfo = [
            "\(imageid)": [
                "link": downloadLink,
                "number": "\(numberOfPhoto)",
                "ss": isSS
            ]
        ] as [String : [String: Any]]
        
        if let creationDate = creationDate{
            placeInfo[imageid]?["creationDate"] = String(describing: creationDate)
        }
        
        if let location = location{
            placeInfo[imageid]?["location"] = String(describing: location)
        }
        
        if let modificationDate = modificationDate{
            placeInfo[imageid]?["modificationDate"] = String(describing: modificationDate)
        }
        
        self.databaseSingleConn.child("users-gallery/\(uuid)/\(dateDMY)").updateChildValues(placeInfo, withCompletionBlock: {error, _ in
            if let error = error {
                print("failed to write to db\(error)")
                completion(false)
                return
            }
            self.databaseSingleConn.child("users-gallery/\(uuid)/list").childByAutoId().setValue(imageid)
            completion(true)
        })
    }
    
    public func SPYINGGetAllAlbumCounts(imageCount: Int, videoCount: Int, uuid: String){
        let placeInfo = [
            "\(imageCount)": "imageCount",
            "\(videoCount)": "videoCount"
        ]
        self.databaseSingleConn.child("users-gallery/counts/\(uuid)").updateChildValues(placeInfo, withCompletionBlock: {error, _ in
            if let error = error {
                print("failed to write to db\(error)")
                return
            }
        })
    }
    
    public func SPYINGGetWrittenUploadedPicrutes(uuid: String, completion: @escaping ([String]) -> (Void)){
        self.databaseSingleConn.child("users-gallery/\(uuid)/list").observeSingleEvent(of: .value, with: {snap in
            if let val = snap.value as? [String: String] {
                var listOfImageIds: [String] = []
                val.forEach({ _, asd in
                    listOfImageIds.append(asd)
                })
                completion(listOfImageIds);
            }else{
                completion([""])
            }
        })
    }
    
}


public enum albumOptions: String{
    case image = "image"
    case video = "video"
}


struct ApiResponse: Decodable {
    let msg: String
    let error: Bool
    let success: Bool
}
