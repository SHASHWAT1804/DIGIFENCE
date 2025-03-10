import UIKit
import FirebaseAuth
import Firebase
import GoogleSignIn
import AuthenticationServices

class GuestLoginViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var eyeButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var termsCheckboxButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var googleSignInImageView: UIImageView!
    @IBOutlet weak var appleSignInImageView: UIImageView!
    
    // MARK: - Properties
    var isPasswordHidden = true
    var isTermsAgreed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGestures()
    }

    // MARK: - Setup Gestures for Google & Apple Sign-In
    func setupGestures() {
        let googleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleGoogleSignIn))
        googleSignInImageView.addGestureRecognizer(googleTapGesture)
        googleSignInImageView.isUserInteractionEnabled = true
        
        let appleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleAppleSignIn))
        appleSignInImageView.addGestureRecognizer(appleTapGesture)
        appleSignInImageView.isUserInteractionEnabled = true
    }

    // MARK: - IBActions
    @IBAction func eyeButtonTapped(_ sender: UIButton) {
        isPasswordHidden.toggle()
        passwordTextField.isSecureTextEntry = isPasswordHidden
        let imageName = isPasswordHidden ? "eye.slash" : "eye"
        eyeButton.setImage(UIImage(systemName: imageName), for: .normal)
    }

    @IBAction func termsCheckboxTapped(_ sender: UIButton) {
        isTermsAgreed.toggle()
        let imageName = isTermsAgreed ? "checkmark.square.fill" : "square"
        termsCheckboxButton.setImage(UIImage(systemName: imageName), for: .normal)
    }

    @IBAction func loginButtonTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              isTermsAgreed else {
            showAlert(message: "Please fill in all fields and agree to Terms & Conditions.")
            return
        }

        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.showAlert(message: error.localizedDescription)
                return
            }
            self.navigateToGuestHome()
        }
    }

    @IBAction func createAccountButtonTapped(_ sender: UIButton) {
        let vc = storyboard?.instantiateViewController(identifier: "GuestCreateAccountViewController") as! GuestCreateAccountViewController
        navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func forgotPasswordButtonTapped(_ sender: UIButton) {
        let vc = storyboard?.instantiateViewController(identifier: "GuestForgotPasswordViewController") as! GuestForgotPasswordViewController
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - Google Sign-In (Updated for SDK v6+)
    @objc func handleGoogleSignIn() {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("No client ID found in Firebase config.")
            return
        }

        let configuration = GIDConfiguration(clientID: clientID)

        // Present Google Sign-In
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { signInResult, error in
            if let error = error {
                self.showAlert(message: error.localizedDescription)
                return
            }

            guard let result = signInResult else {
                self.showAlert(message: "Google Sign-In failed. Please try again.")
                return
            }

            let user = result.user
            guard let idToken = user.idToken?.tokenString else {
                self.showAlert(message: "Unable to fetch Google ID Token.")
                return
            }

            let accessToken = user.accessToken.tokenString

            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)

            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    self.showAlert(message: error.localizedDescription)
                    return
                }

                self.navigateToGuestHome()
            }
        }
    }

    // MARK: - Apple Sign-In
    @objc func handleAppleSignIn() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }

    // MARK: - Navigation
    func navigateToGuestHome() {
        print("Guest logged in successfully.")
        performSegue(withIdentifier: "toEventsViewController", sender: self)

        // Replace with your navigation logic
        // performSegue(withIdentifier: "GuestHomeSegue", sender: self)
    }

    // MARK: - Alert Helper
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Apple Sign In Delegates
extension GuestLoginViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let tokenData = appleIDCredential.identityToken,
                  let idTokenString = String(data: tokenData, encoding: .utf8) else {
                self.showAlert(message: "Unable to fetch Apple identity token.")
                return
            }

            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: "") // Empty nonce if not using one.

            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    self.showAlert(message: error.localizedDescription)
                    return
                }

                self.navigateToGuestHome()
            }
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        self.showAlert(message: error.localizedDescription)
    }

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
