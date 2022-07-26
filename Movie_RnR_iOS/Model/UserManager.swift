//
//  UserManager.swift
//  Movie_RnR_iOS
//
//  Created by 엄태양 on 2022/07/20.
//

import Foundation
import Alamofire

class UserManager {
    private static var user: UserData?
    
    
    private init() {
        UserManager.user = nil
    }
    
    static func getInstance() -> UserData? {
        return UserManager.user
    }
    
    static func loginPost(id: String, password: String, errorHandler: (() -> Void)? = nil, completion: (() -> Void)? = nil) {
        AF.request("\(Constant.serverURL)/auth/login", method: .post, parameters: ["id": id, "password": password])
            .validate(statusCode: 200..<300)
            .responseDecodable(of: LoginResponse.self) { response in
                
                if let err = response.value?.error {
                    print("Post Login Error : \(err)")
                    errorHandler?()
                    return
                } else if let userData = response.value?.data {
                    print("Post Login: \(userData)")
                    
                    UserDefaults.standard.set(id, forKey: "id")
                    UserDefaults.standard.set(password, forKey: "password")
                    
                    UserManager.user = userData
                    completion?()
                }
            }
    }
    
    static func loginGet(errorHandler: (() -> Void)? = nil, completion: (() -> Void)? = nil) {
        AF.request("\(Constant.serverURL)/auth/login", method: .get)
            .validate(statusCode: 200..<500)
            .responseDecodable(of: LoginResponse.self) { response in
                
                if let err = response.value?.error {
                    print("Get Login Error: \(err)")
                    return
                } else if let userData = response.value?.data {
                    print("Get Login : \(userData)")
                    
                    UserManager.user = userData
                    completion?()
                }
                
            }
        
    }
    
    static func logout(completion: (()->Void)? = nil) {
        AF.request("\(Constant.serverURL)/auth/logout", method: .get)
            .validate(statusCode: 200..<300)
            .response { response in
                switch response.result {
                case .success(_):
                    self.user = nil
                    
                    UserDefaults.standard.removeObject(forKey: "id")
                    UserDefaults.standard.removeObject(forKey: "password")
                    
                    completion?()
                    
                case .failure(let error):
                    print("Logout Error: \(error)")
                    return
                    
                default:
                    return
                }
            }
    }
    
    static func update(with parameter: UserUpdateRequest, completion: (() -> Void)? = nil) {
        AF.request("\(Constant.serverURL)/user/profile", method: .post, parameters: ["nickname":parameter.nickname, "biography":parameter.biography, "gender": parameter.gender, "instagram":parameter.instagram , "facebook": parameter.facebook, "twitter": parameter.twitter])
            .validate(statusCode: 200..<300)
            .responseDecodable(of: UserUpdateResponse.self) { response in
                if let res = response.value {
                    UserManager.loginGet( completion: completion )
                } else {
                    print("Error updating profile")
                }
                
            }
    }
    
    static func removeAccount(completion: (()->Void)? = nil) {
        AF.request("\(Constant.serverURL)/user/", method: .delete)
            .validate(statusCode: 200..<300)
            .response { response in
                UserManager.user = nil
                
                UserDefaults.standard.removeObject(forKey: "id")
                UserDefaults.standard.removeObject(forKey: "password")
                
                completion?()
            }
    }
    
    static func changePassword(current: String, new: String, errorHandler: ((String) -> Void)? = nil, completion: (() -> Void)? = nil) {
        AF.request("\(Constant.serverURL)/user/password", method: .post, parameters: ["password": current, "newPassword": new])
            .validate(statusCode: 200...400)
            .responseDecodable(of: PwdResponse.self) { response in
                
                if let res = response.value {
                    if let error = res.error {
                        errorHandler?(error)
                    } else {
                        UserDefaults.standard.set(new, forKey: "password")
                        completion?()
                    }
                }
            }
        
    }
    
}

