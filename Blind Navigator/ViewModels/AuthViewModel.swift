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
import Combine

final class AuthViewModel: ObservableObject {
    // MARK: - Global auth state
    @Published var user: FirebaseAuth.User? // nil if signed out
    @Published var idToken: String?
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    private var authHandle: AuthStateDidChangeListenerHandle?
    private let auth = Auth.auth()
    
    // MARK: – Form state for Sign‑In
    @Published var signInEmail = ""
    @Published var signInPassword = ""
    
    // MARK: – Form state for Sign‑Up
    @Published var signUpEmail = ""
    @Published var signUpPassword = ""
    @Published var signUpConfirmPassword = ""
    
    init() {
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
    func signIn() {
        errorMessage = nil
        guard !signInEmail.isEmpty, !signInPassword.isEmpty else {
            errorMessage = "Email and password cannot be blank."
            return
        }
        isLoading = true
        auth.signIn(withEmail: signInEmail, password: signInPassword) { [weak self] _, err in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let err = err {
                    self?.errorMessage = err.localizedDescription
                }
            }
        }
    }
    
    func signUp() {
        errorMessage = nil
        guard !signUpEmail.isEmpty,
              !signUpPassword.isEmpty,
              signUpPassword == signUpConfirmPassword else
        {
            errorMessage = "Check your email/password fields."
            return
        }
        isLoading = true
        auth.createUser(withEmail: signUpEmail, password: signUpPassword) { [weak self] _, err in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let err = err {
                    self?.errorMessage = err.localizedDescription
                }
            }
        }
    }
    
    func resetPassword() {
        errorMessage = nil
        guard !signInEmail.isEmpty else {
            errorMessage = "Enter your email to reset."
            return
        }
        isLoading = true
        auth.sendPasswordReset(withEmail: signInEmail) { [weak self] err in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.errorMessage = err == nil
                ? "Reset email sent."
                : err!.localizedDescription
            }
        }
    }
    
    func signOut() {
        do {
            try auth.signOut()
            user = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func getUserEmail() -> String? {
        return Auth.auth().currentUser?.email
    }
}
