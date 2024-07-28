import Foundation
import SwiftUI

extension String {
    
    func isValidEmail() -> Bool {

        let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
        return regex.firstMatch(in: self, range: NSRange(location: 0, length: count)) != nil
    }
    
    func isValidPassword() -> Bool {
           if self.count < 6 {
               return false
           }
           
           return true
       }
    
    func isValidBlockNumber() -> Bool {
        if Int(self) != nil {
            return true
        }
        return false
    }
    
    func isValidFloorNumber() -> Bool {
        if Int(self) != nil {
            return true
        }
        return false
    }
    
    func isValidFullname() -> Bool {
        let trimmedSelf = self.trimmingCharacters(in: .whitespacesAndNewlines)
        let components = trimmedSelf.split(separator: " ")
        return !trimmedSelf.isEmpty && components.count >= 2
    }
}

extension Color {
    static let customGreen = Color(red: 111/255, green: 192/255, blue: 83/255)
}
