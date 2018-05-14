import Foundation
import UIKit

class ImageService {
    private static let imagesDirectoryName = "images"
    
    private var cachedImagePath: URL
    private var baseImageURL: URL
    
    init(baseUrl: URL) {
        cachedImagePath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        cachedImagePath.appendPathComponent(ImageService.imagesDirectoryName)
        
        if !FileManager.default.fileExists(atPath: cachedImagePath.path) {
            try! FileManager.default.createDirectory(atPath: cachedImagePath.path, withIntermediateDirectories: false, attributes: nil)
        }
        
        baseImageURL = baseUrl
    }
    
    func getImage(imageUrl: String, completion: @escaping (UIImage?) -> Void ) {
        DispatchQueue.global().async {
            let cachedImageUrlString = self.cachedImagePath.appendingPathComponent(imageUrl).path
            if FileManager.default.fileExists(atPath: cachedImageUrlString) {
                DispatchQueue.main.async { completion(UIImage(contentsOfFile: cachedImageUrlString)!) }
            }
            else {
                guard let data = try? Data(contentsOf: URL(string: self.baseImageURL.absoluteString + imageUrl)!) else {
                    DispatchQueue.main.async { completion(nil) }
                    return
                }
                
                let folders = imageUrl.split(separator: "/")
                if folders.count > 1 {
                    let path = self.cachedImagePath.appendingPathComponent(folders.dropLast().joined(separator: "/")).path
                    try! FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
                }
                
                FileManager.default.createFile(atPath: self.cachedImagePath.appendingPathComponent(imageUrl).path, contents: data, attributes: nil)

                let image = UIImage(data: data)
                
                DispatchQueue.main.async { completion(image) }
            }
        }
    }
}
