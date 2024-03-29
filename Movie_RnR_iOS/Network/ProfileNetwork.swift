//
//  ProfileNetwork.swift
//  Movie_RnR_iOS
//
//  Created by 엄태양 on 2022/08/19.
//

import Foundation
import RxSwift
import RxCocoa

struct ProfileNetwork {
    let session: URLSession
    
    init(_ session: URLSession = .shared) {
        self.session = session
    }
    
    func requestNicknameCheck(nickname: String) -> Single<Result<DuplicateCheckResponse, NetworkError>> {
        let urlString = "\(Constant.serverURL)/join/nick"
        
        guard let url = URL(string: urlString) else {
            return .just(.failure(.invalidURL))
        }
        do {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            let parameter = ["nickname": nickname]
            
            request.setValue("application/json", forHTTPHeaderField:"Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.httpBody = try JSONSerialization.data(withJSONObject: parameter)
            
            return session.rx.data(request: request)
                .map { data in
                    do {
                        let decodedData = try JSONDecoder().decode(DuplicateCheckResponse.self, from: data)
                        return .success(decodedData)
                    } catch {
                        return .failure(NetworkError.invalidJSON)
                    }
                }
                .catch { _ in
                    return .just(.failure(NetworkError.networkError))
                }
                .asSingle()
        } catch {
            return .just(.failure(.invalidQuery))
        }
    }
    
    func requestIdCheck(id: String) -> Single<Result<DuplicateCheckResponse, NetworkError>> {
        let urlString = "\(Constant.serverURL)/join/id"
        
        guard let url = URL(string: urlString) else {
            return .just(.failure(.invalidURL))
        }
        do {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            let parameter = ["id": id]
            
            request.setValue("application/json", forHTTPHeaderField:"Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.httpBody = try JSONSerialization.data(withJSONObject: parameter)
            
            return session.rx.data(request: request)
                .map { data in
                    do {
                        let decodedData = try JSONDecoder().decode(DuplicateCheckResponse.self, from: data)
                        return .success(decodedData)
                    } catch {
                        return .failure(NetworkError.invalidJSON)
                    }
                }
                .catch { _ in
                    return .just(.failure(NetworkError.networkError))
                }
                .asSingle()
        } catch {
            return .just(.failure(.invalidQuery))
        }
    }
    
    func fetchProfile(userID: Int) -> Single<Result<ProfileResponse, NetworkError>> {
        let urlString = "\(Constant.serverURL)/user/\(userID)"
        
        guard let url = URL(string: urlString) else { return .just(.failure(.invalidURL))}
        
        let request = URLRequest(url: url)
        
        return session.rx.data(request: request)
            .map { data in
                do {
                    let result = try JSONDecoder().decode(ProfileResponse.self, from: data)
                    return .success(result)
                } catch {
                    return .failure(NetworkError.invalidJSON)
                }
            }
            .catch { _ in
                return .just(.failure(NetworkError.networkError))
            }
            .asSingle()
    }
    
    func updateProfile(with profile: Profile) -> Single<Result<ProfileResponse, NetworkError>> {
        let urlString = "\(Constant.serverURL)/user/profile"
        
        guard let url = URL(string: urlString) else {
            return .just(.failure(.invalidURL))
        }
        do {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            let parameter = ["nickname": profile.nickname, "gender": profile.gender, "biography": profile.biography, "facebook": profile.facebook, "instagram": profile.instagram, "twitter": profile.twitter]
            
            request.setValue("application/json", forHTTPHeaderField:"Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.httpBody = try JSONSerialization.data(withJSONObject: parameter)
            
            return session.rx.data(request: request)
                .map { data in
                    do {
                        let decodedData = try JSONDecoder().decode(ProfileResponse.self, from: data)
                        return .success(decodedData)
                    } catch {
                        return .failure(NetworkError.invalidJSON)
                    }
                }
                .catch { _ in
                    return .just(.failure(NetworkError.networkError))
                }
                .asSingle()
        } catch {
            return .just(.failure(.invalidQuery))
        }
    }
    
    func updatePassword(password: String, newPassword: String) -> Single<Result<DefaultResponse, NetworkError>> {
        let urlString = "\(Constant.serverURL)/user/password"
        
        guard let url = URL(string: urlString) else {
            return .just(.failure(.invalidURL))
        }
        do {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            let parameter = ["password": password, "newPassword": newPassword]
            
            request.setValue("application/json", forHTTPHeaderField:"Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.httpBody = try JSONSerialization.data(withJSONObject: parameter)
            
            return session.rx.data(request: request)
                .map { data in
                    do {
                        let decodedData = try JSONDecoder().decode(DefaultResponse.self, from: data)
                        if decodedData.code == 201 {
                            _ = UserRepository().getLoginRequest()
                            UserDefaults.standard.set(newPassword, forKey: "password")
                        }
                        return .success(decodedData)
                    } catch {
                        return .failure(NetworkError.invalidJSON)
                    }
                }
                .catch { _ in
                    return .just(.failure(NetworkError.networkError))
                }
                .asSingle()
        } catch {
            return .just(.failure(.invalidQuery))
        }
    }
    

    func deleteAccount() -> Single<Result<DefaultResponse, NetworkError>> {
        let urlString = "\(Constant.serverURL)/user"
        
        guard let url = URL(string: urlString) else { return .just(.failure(.invalidURL)) }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        return session.rx.data(request: request)
            .map { data in
                do {
                    let response = try JSONDecoder().decode(DefaultResponse.self, from: data)
                    
                    if response.code == 200 {
                        UserDefaults.standard.removeObject(forKey: "id")
                        UserDefaults.standard.removeObject(forKey: "password")
                        UserManager.logout()
                    }
                    
                    return .success(response)
                } catch {
                    return .failure(.invalidJSON)
                }
                
            }
            .catch { _ in
                return .just(.failure(.networkError))
            }
            .asSingle()
    }
    
    func requestJoin(with data : (id: String, password: String, nickname: String, gender: String)) -> Single<Result< LoginResponse ,NetworkError>> {
        
        let urlString = "\(Constant.serverURL)/join"
        
        guard let url = URL(string: urlString) else {
            return .just(.failure(.invalidURL))
        }
        do {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            let parameter = ["id": data.id, "password": data.password, "nickname": data.nickname, "gender": data.gender]
            
            request.setValue("application/json", forHTTPHeaderField:"Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.httpBody = try JSONSerialization.data(withJSONObject: parameter)
            
            return session.rx.data(request: request)
                .map { data in
                    do {
                        let decodedData = try JSONDecoder().decode(LoginResponse.self, from: data)
                        return .success(decodedData)
                    } catch {
                        return .failure(NetworkError.invalidJSON)
                    }
                }
                .catch { _ in
                    return .just(.failure(NetworkError.networkError))
                }
                .asSingle()
        } catch {
            return .just(.failure(.invalidQuery))
        }
    }
}
