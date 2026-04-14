package com.club.service;

import com.club.model.RegistrationStatus;
import com.club.model.User;
import com.club.repository.UserRepository;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
public class UserService implements UserDetailsService {

        private final UserRepository userRepository;
        private final PasswordEncoder passwordEncoder;

        public UserService(
                        UserRepository userRepository,
                        PasswordEncoder passwordEncoder) {
                this.userRepository = userRepository;
                this.passwordEncoder = passwordEncoder;
        }

        @Override
        public UserDetails loadUserByUsername(String email)
                        throws UsernameNotFoundException {

                return userRepository.findByEmail(email)
                                .orElseThrow(() -> new UsernameNotFoundException(
                                                "Utilisateur non trouvé : " + email));
        }

        public User register(User user) {
                if (userRepository.existsByEmail(user.getEmail())) {
                        throw new RuntimeException("Email déjà utilisé");
                }

                user.setPassword(passwordEncoder.encode(user.getPassword()));
                user.setRole(User.Role.INSCRIT);
                user.setRegistrationStatus(RegistrationStatus.PENDING);
                user.setDateInscription(LocalDateTime.now());
                return userRepository.save(user);
        }

        public User createUserByAdmin(User user) {
                if (userRepository.existsByEmail(user.getEmail())) {
                        throw new RuntimeException("Email déjà utilisé");
                }

                // Generate unique activation token
                String activationToken = UUID.randomUUID().toString();
                
                user.setPassword(null);  // No initial password
                user.setActif(false);
                user.setAccountStatus(User.AccountStatus.ACTIVATION_REQUISE);
                user.setRegistrationStatus(RegistrationStatus.PENDING);
                user.setActivationToken(activationToken);
                user.setDateInscription(LocalDateTime.now());
                
                return userRepository.save(user);
        }

        // Activate account on first login
        public User activateAccount(String email, String newPassword, String activationToken) {
                User user = userRepository.findByEmail(email)
                                .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));

                // Verify token
                if (!activationToken.equals(user.getActivationToken())) {
                        throw new RuntimeException("Token d'activation invalide");
                }

                // Check if account needs activation
                if (user.getAccountStatus() != User.AccountStatus.ACTIVATION_REQUISE) {
                        throw new RuntimeException("Ce compte est déjà activé");
                }

                // Validate password
                if (newPassword == null || newPassword.length() < 6) {
                        throw new RuntimeException("Le mot de passe doit contenir au moins 6 caractères");
                }

                // Activate the account
                user.setPassword(passwordEncoder.encode(newPassword));
                user.setActif(true);
                user.setAccountStatus(User.AccountStatus.ACTIF);
                user.setActivationToken(null);  // Remove token after activation
                user.setDerniereConnexion(LocalDateTime.now());

                return userRepository.save(user);
        }

        // Check if user needs activation
        public Map<String, Object> checkActivationStatus(String email) {
                User user = userRepository.findByEmail(email)
                                .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));

                Map<String, Object> response = new HashMap<>();
                response.put("email", user.getEmail());
                response.put("nom", user.getNom());
                response.put("prenom", user.getPrenom());
                
                if (user.getAccountStatus() == User.AccountStatus.ACTIVATION_REQUISE) {
                        response.put("needsActivation", true);
                        response.put("activationToken", user.getActivationToken());
                        response.put("message", "Vous devez définir votre mot de passe");
                } else {
                        response.put("needsActivation", false);
                        response.put("message", "Compte déjà activé");
                }

                return response;
        }

        public User createUser(User user) {
                user.setPassword(passwordEncoder.encode(user.getPassword()));
                user.setDateInscription(LocalDateTime.now());
                return userRepository.save(user);
        }

        public User updateUser(Long id, User userDetails) {

                User user = userRepository.findById(id)
                                .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));

                user.setNom(userDetails.getNom());
                user.setPrenom(userDetails.getPrenom());
                user.setTelephone(userDetails.getTelephone());
                user.setAdresse(userDetails.getAdresse());
                user.setDateNaissance(userDetails.getDateNaissance());
                user.setPhoto(userDetails.getPhoto());

                if (userDetails.getPassword() != null &&
                                !userDetails.getPassword().isEmpty()) {

                        user.setPassword(
                                        passwordEncoder.encode(userDetails.getPassword()));
                }

                return userRepository.save(user);
        }

        public User changeRole(Long id, User.Role role) {
                User user = userRepository.findById(id)
                                .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));
                user.setRole(role);
                return userRepository.save(user);
        }

        public User toggleUserStatus(Long id) {
                User user = userRepository.findById(id)
                                .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));
                user.setActif(!user.getActif());
                return userRepository.save(user);
        }

        public void updateLastLogin(String email) {
                User user = userRepository.findByEmail(email)
                                .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));
                user.setDerniereConnexion(LocalDateTime.now());
                userRepository.save(user);
        }

        public void migratePasswordIfNeeded(String email, String rawPassword) {
                User user = userRepository.findByEmail(email)
                                .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));

                String stored = user.getPassword();
                if (stored == null)
                        return;

                boolean looksLikeBcrypt = stored.startsWith("$2a$") || stored.startsWith("$2b$")
                                || stored.startsWith("$2y$");

                if (!looksLikeBcrypt && passwordEncoder.matches(rawPassword, stored)) {
                        user.setPassword(passwordEncoder.encode(rawPassword));
                        userRepository.save(user);
                }
        }

        public List<User> getAllUsers() {
                return userRepository.findAll();
        }

        public List<User> getUsersByRole(User.Role role) {
                return userRepository.findByRole(role);
        }

        public User getUserById(Long id) {
                return userRepository.findById(id)
                                .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));
        }

        public void deleteUser(Long id) {
                userRepository.deleteById(id);
        }

        public User updateUserPhoto(Long id, String photoUrl) {
                User user = userRepository.findById(id)
                                .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));
                user.setPhoto(photoUrl);
                return userRepository.save(user);
        }
}
