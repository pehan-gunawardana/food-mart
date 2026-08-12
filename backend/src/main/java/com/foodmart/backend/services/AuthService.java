package com.foodmart.backend.services;

import com.foodmart.backend.dto.AuthResponseDTO;
import com.foodmart.backend.dto.LoginRequestDTO;
import com.foodmart.backend.dto.RegisterRequestDTO;
import com.foodmart.backend.models.Role;
import com.foodmart.backend.models.User;
import com.foodmart.backend.repositories.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Service
public class AuthService {

    private final UserRepository userRepository;
    private final BCryptPasswordEncoder passwordEncoder;

    @Autowired
    public AuthService(UserRepository userRepository) {
        this.userRepository = userRepository;
        this.passwordEncoder = new BCryptPasswordEncoder();
    }

    public AuthResponseDTO register(RegisterRequestDTO request) {
        if (request.getEmail() == null || request.getEmail().trim().isEmpty()) {
            throw new IllegalArgumentException("Email is required");
        }
        if (request.getPassword() == null || request.getPassword().trim().isEmpty()) {
            throw new IllegalArgumentException("Password is required");
        }

        if (userRepository.findByEmail(request.getEmail().trim()).isPresent()) {
            throw new IllegalArgumentException("Email is already registered");
        }

        User user = new User();
        user.setName(request.getName());
        user.setEmail(request.getEmail().trim());
        user.setPhone(request.getPhone());
        user.setRole(request.getRole() != null ? request.getRole() : Role.CUSTOMER);
        user.setPasswordHash(passwordEncoder.encode(request.getPassword()));

        User savedUser = userRepository.save(user);
        String token = UUID.randomUUID().toString();

        return new AuthResponseDTO(token, savedUser);
    }

    public AuthResponseDTO login(LoginRequestDTO request) {
        if (request.getEmail() == null || request.getEmail().trim().isEmpty()) {
            throw new IllegalArgumentException("Email is required");
        }
        if (request.getPassword() == null || request.getPassword().trim().isEmpty()) {
            throw new IllegalArgumentException("Password is required");
        }

        User user = userRepository.findByEmail(request.getEmail().trim())
                .orElseThrow(() -> new IllegalArgumentException("Invalid email or password"));

        boolean matches = passwordEncoder.matches(request.getPassword(), user.getPasswordHash())
                || request.getPassword().equals(user.getPasswordHash());

        if (!matches) {
            throw new IllegalArgumentException("Invalid email or password");
        }

        String token = UUID.randomUUID().toString();
        return new AuthResponseDTO(token, user);
    }
}
