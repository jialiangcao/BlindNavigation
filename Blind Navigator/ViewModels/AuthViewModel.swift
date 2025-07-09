//
//  AuthViewModel.swift
//  Blind Navigator
//
//  Created by Jialiang Cao on 4/26/25.
//
// Handles Signed In/Out user-state
//

import SwiftUI
import FirebaseAuth

protocol AuthViewModelType: AnyObject {
     var user: FirebaseAuth.User? { get }
     var idToken: String? { get }
     var errorMessage: String? { get }
     
     var signInEmail: String { get set }
     var signInPassword: String { get set }
     var signUpConfirmPassword: String { get set }
     
     func signIn(completion: @escaping (Bool) -> Void)
     func signUp(completion: @escaping (Bool) -> Void)
     func resetPassword()
     func signOut()
     func getUserEmail() -> String?
}

final class AuthViewModel: ObservableObject, AuthViewModelType {
    // MARK: - Global auth state
    @Published var user: FirebaseAuth.User? // nil if signed out
    @Published var idToken: String?
    @Published var errorMessage: String?
    
    private var authHandle: AuthStateDidChangeListenerHandle?
    private let auth = Auth.auth()
    
    // MARK: – Form state for Sign‑In
    @Published var signInEmail = ""
    @Published var signInPassword = ""
    
    // MARK: – Form state for Sign‑Up
    @Published var signUpConfirmPassword = ""
    
    func setError(as message: String) {
        errorMessage = message
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            withAnimation {
                self.errorMessage = nil
            }
        }
    }
    
    init() {
        self.user = Auth.auth().currentUser
        authHandle = Auth.auth().addStateDidChangeListener { _, user in
            self.user = user
            user?.getIDToken { idToken, error in
            self.idToken = idToken
            }
        }
    }
    
    deinit {
        if let handle = authHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    // MARK: - Auth functions
    func signIn(completion: @escaping (Bool) -> Void) {
        guard !signInEmail.isEmpty, !signInPassword.isEmpty else {
            setError(as: "Email and password cannot be blank.")
            completion(false)
            return
        }
        auth.signIn(withEmail: signInEmail, password: signInPassword) { [weak self] _, err in
            DispatchQueue.main.async {
                if let err = err {
                    self?.errorMessage = err.localizedDescription
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
    }
    
    func signUp(completion: @escaping (Bool) -> Void) {
        guard !signInEmail.isEmpty,
              !signInPassword.isEmpty
        else {
            setError(as: "Email and password cannot be blank.")
            completion(false)
            return
        }
        
        guard signInPassword == signUpConfirmPassword else {
            setError(as: "Passwords do not match.")
            completion(false)
            return
        }

        auth.createUser(withEmail: signInEmail, password: signInPassword) { [weak self] _, err in
            DispatchQueue.main.async {
                if let err = err?.localizedDescription {
                    self?.setError(as: err)
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
    }
    
    func resetPassword() {
        errorMessage = nil
        guard !signInEmail.isEmpty else {
            setError(as: "Enter your email to reset.")
            return
        }
        auth.sendPasswordReset(withEmail: signInEmail) { [weak self] err in
            DispatchQueue.main.async {
                if let err = err?.localizedDescription {
                    self?.setError(as: err)
                } else {
                    self?.setError(as: "Reset email sent.")
                }
            }
        }
    }
    
    func signOut() {
        do {
            try auth.signOut()
            user = nil
        } catch {
            setError(as: error.localizedDescription)
        }
    }
    
    func getUserEmail() -> String? {
        return Auth.auth().currentUser?.email
    }
}
