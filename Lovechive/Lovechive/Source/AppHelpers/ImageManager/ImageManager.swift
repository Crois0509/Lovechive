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
    func saveImage(image: UIImage?, completion: @escaping (String?) -> Void) {
        guard let image,
              let data = image.jpegData(compressionQuality: 0.7) ?? image.pngData(),
              let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        else {
            completion(nil)
            return
        }
        
        do {
            let fileName = "\(UUID().uuidString).jpg"
            let filePath = directory.appendingPathComponent(fileName).path
            try data.write(to: URL(fileURLWithPath: filePath))
            
            debugPrint("✅ 이미지 저장 성공: \(filePath)")
            completion(filePath) // ✅ 절대 경로를 반환
        } catch {
            debugPrint(error.localizedDescription, "❌ 이미지 저장 실패")
            completion(nil)
        }
    }
    
    /// 로컬 디렉토리에서 이미지를 불러오는 메소드
    /// - Parameter url: 불러올 이미지의 경로
    /// - Returns: 불러온 이미지
    func loadImage(path: String) -> UIImage? {
        var fileURL = URL(fileURLWithPath: path)

        if !FileManager.default.fileExists(atPath: fileURL.path) {
            print("❌ 파일이 존재하지 않음: \(fileURL.path)")

            // 상대 경로로 저장되었을 경우 보정
            if let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
                fileURL = directory.appendingPathComponent(path)
                print("🔄 상대 경로 보정 후 다시 확인: \(fileURL.path)")
                if !FileManager.default.fileExists(atPath: fileURL.path) {
                    return nil
                }
            } else {
                return nil
            }
        }

        do {
            let data = try Data(contentsOf: fileURL)
            debugPrint("✅ 이미지 불러오기 성공!!")
            return UIImage(data: data)
        } catch {
            debugPrint(error.localizedDescription, "❌ 이미지 불러오기 실패")
            return nil
        }
    }
}
