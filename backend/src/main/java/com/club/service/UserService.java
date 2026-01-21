package com.club.service;

import com.club.model.User;
import com.club.repository.UserRepository;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

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
                user.setDateInscription(LocalDateTime.now());
                return userRepository.save(user);
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
