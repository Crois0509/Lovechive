//
//  ImageManager.swift
//  Lovechive
//
//  Created by 장상경 on 3/10/25.
//

import UIKit

/// 로컬 directory에 이미지를 저장하거나 불러오는 역할을 맡는 객체
final class ImageManager {
    static let shared = ImageManager()
    private init() {}
    
    /// 로컬 디렉토리에 이미지를 저장하는 메소드
    /// - Parameters:
    ///   - image: 저장할 이미지
    ///   - completion: 저장 완료 후에 실행할 액션
    func saveImage(image: UIImage, completion: @escaping (String?) -> Void) {
        guard let data = image.jpegData(compressionQuality: 0.7) ?? image.pngData(),
              let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        else {
            completion(nil)
            return
        }
        
        do {
            let fileName: String = "\(UUID().uuidString).jpg"
            try data.write(to: directory.appendingPathComponent(fileName))
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName)
            debugPrint("✅ 이미지 저장 성공", fileName)
            completion(url.path())
        } catch {
            debugPrint(error.localizedDescription, "❌ 이미지 저장 실패")
            completion(nil)
        }
    }
    
    /// 로컬 디렉토리에서 이미지를 불러오는 메소드
    /// - Parameter url: 불러올 이미지의 경로
    /// - Returns: 불러온 이미지
    func loadImage(path: String) -> UIImage? {
        let fileURL = URL(fileURLWithPath: path)
        
        // 파일이 존재하는지 확인
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            print("❌ 파일이 존재하지 않음: \(fileURL.path)")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let image = UIImage(data: data)
            return image
        } catch {
            debugPrint(error.localizedDescription, "❌ 이미지 불러오기 실패")
            return nil
        }
    }
}
