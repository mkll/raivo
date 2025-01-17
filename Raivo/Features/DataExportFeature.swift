//
// Raivo OTP
//
// Copyright (c) 2019 Tijme Gommers. All rights reserved. Raivo OTP
// is provided 'as-is', without any express or implied warranty.
//
// This source code is licensed under the CC BY-NC 4.0 license found 
// in the LICENSE.md file in the root directory of this source tree.
// 

import Foundation
import UIKit
import RealmSwift
import SSZipArchive
import EFQRCode

class DataExportFeature {
    
    public enum Representation {
        case html
        case json
    }
    
    public enum Result {
        case success(archive: URL)
        case failure
    }
    
    private var archiveFile: URL? = nil
    
    public func generateArchive(protectedWith password: String) -> Result {
        let html = getHTMLRepresentation()
        let json = getJSONRepresentation()
        
        guard let htmlPath = saveRepresentationToFile(html, .html) else {
            return .failure
        }
        
        guard let jsonPath = saveRepresentationToFile(json, .json) else {
            return .failure
        }
        
        guard let archive = saveToArchive(representationFiles: [htmlPath, jsonPath], protectedWith: password) else {
            return .failure
        }
        
        deleteFile(htmlPath)
        deleteFile(jsonPath)
        
        return .success(archive: archive)
    }
    
    public func deleteArchive() {
        if let archiveFile = archiveFile {
            deleteFile(archiveFile)
        }
    }
    
    private func deleteFile(_ file: URL) {
        try? FileManager.default.removeItem(at: file)
    }
    
    private func getHTMLRepresentation() -> String {
        let realm = try! Realm()

        let sortProperties = [SortDescriptor(keyPath: "issuer"), SortDescriptor(keyPath: "account")]
        let passwords = realm.objects(Password.self).filter("deleted == 0").sorted(by: sortProperties)

        let wrapperTemplateFile = Bundle.main.path(forResource: "all-passwords", ofType: "html")
        let passwordTemplateFile = Bundle.main.path(forResource: "single-password", ofType: "html")
        
        var wrapperText = try! String(contentsOfFile: wrapperTemplateFile!, encoding: .utf8)
        let passwordText = try! String(contentsOfFile: passwordTemplateFile!, encoding: .utf8)
        
        var passwordTextArray: [String] = []
        
        for password in passwords {
            var text = passwordText
            
            text = text.replacingOccurrences(of: "{{issuer}}", with: password.issuer)
            text = text.replacingOccurrences(of: "{{account}}", with: password.account)
            text = text.replacingOccurrences(of: "{{secret}}", with: password.secret)
            text = text.replacingOccurrences(of: "{{algorithm}}", with: password.algorithm)
            text = text.replacingOccurrences(of: "{{digits}}", with: String(password.digits))
            text = text.replacingOccurrences(of: "{{kind}}", with: password.kind)
            text = text.replacingOccurrences(of: "{{timer}}", with: String(password.timer))
            text = text.replacingOccurrences(of: "{{counter}}", with: String(password.counter))
            text = text.replacingOccurrences(of: "{{qrcode}}", with: getQuickResponseCodeHTML(password))
            
            passwordTextArray.append(text)
        }
        
        wrapperText = wrapperText.replacingOccurrences(of: "{{date}}", with: Date().description)
        wrapperText = wrapperText.replacingOccurrences(of: "{{passwords}}", with: passwordTextArray.joined(separator: "<hr>"))
        
        return wrapperText
    }
    
    private func getQuickResponseCodeHTML(_ password: Password) -> String {
        guard let qrcodeImage = EFQRCode.generate(
            content: try! password.getToken().toURL().absoluteString + "&secret=" + password.secret,
            size: EFIntSize(width: 300, height: 300)
        ) else {
            return "QR code could not be generated."
        }
        
        guard let qrcodeData = UIImage(cgImage: qrcodeImage).pngData() else {
            return "PNG data could not be extracted from QR code."
        }
        
        return "<img src='data:image/png;base64," + qrcodeData.base64EncodedString() + "' height=300 width=300 />"
    }
    
    private func getJSONRepresentation() -> String {
        let realm = try! Realm()
        let passwords = Array(realm.objects(Password.self))
        
        guard let json = try? JSONSerialization.data(withJSONObject: passwords.map { $0.getExportFields() }, options: []) else {
            return "{\"message\": \"Could not convert OTPs to JSON\"}"
        }
        
        if let result = String(data: json, encoding: String.Encoding.utf8) {
            return result
        }
        
        return "{\"message\": \"Could not convert JSON to a string\"}"
    }
    
    private func saveRepresentationToFile(_ text: String, _ type: Representation) -> URL? {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let filePath = directory.appendingPathComponent("raivo-otp-export." + getFileExtension(type))
        
        do {
            try text.write(to: filePath, atomically: false, encoding: .utf8)
        } catch {
            deleteFile(filePath)
            return nil
        }
        
        return filePath
    }
    
    private func saveToArchive(representationFiles files: [URL], protectedWith password: String) -> URL? {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        archiveFile = directory.appendingPathComponent("raivo-otp-export.zip")
        
        SSZipArchive.createZipFile(
            atPath: archiveFile!.path,
            withFilesAtPaths: files.map { $0.path },
            withPassword: password
        )
        
        return archiveFile
    }
    
    private func getFileExtension(_ type: Representation) -> String {
        switch type {
        case .html:
            return "html"
        case .json:
            return "json"
        }
    }
}
