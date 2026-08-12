package com.foodmart.backend.dto;

import com.foodmart.backend.models.Role;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class RegisterRequestDTO {
    private String name;
    private String email;
    private String phone;
    private String password;
    private Role role;
}
