import UserModel from "../models/userModel.js";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import { dbConnect } from "./dbConnect.js";
import dotenv from "dotenv";
import crypto from "crypto";

dotenv.config();

/**
 * SECURITY CONSTANTS
 */
const JWT_SECRET = process.env.JWT_SECRET;
const TOKEN_EXPIRY = "7d";
const SALT_ROUNDS = 12;

/**
 * Generate JWT safely
 */
const generateToken = (user) => {
  return jwt.sign(
    {
      id: user._id,
      username: user.username,
      role: user.role || "user",
    },
    JWT_SECRET,
    { expiresIn: TOKEN_EXPIRY }
  );
};

/**
 * Prevent timing attacks
 */
const fakePasswordCheck = async () => {
  const fakeHash = await bcrypt.hash("fake_password", SALT_ROUNDS);
  await bcrypt.compare("fake_password", fakeHash);
};

/**
 * MAIN AUTH FUNCTION
 */
export const authUser = async ({ username, email, password }) => {
  try {
    const conn = await dbConnect();
    if (conn.connection.readyState !== 1) {
      return { error: "Database connection failed" };
    }

    // =====================
    // INPUT VALIDATION
    // =====================
    if (!username || !password) {
      return { error: "Username and password are required" };
    }

    username = username.toLowerCase().trim();
    if (email) email = email.toLowerCase().trim();

    // =====================
    // CHECK EXISTING USER
    // =====================
    const user = await UserModel.findOne({ username });

    if (user) {
      const passwordMatch = await bcrypt.compare(password, user.password);

      if (!passwordMatch) {
        // Prevent timing attacks
        await fakePasswordCheck();
        return { error: "Invalid credentials" };
      }

      const token = generateToken(user);
      user.password = undefined;

      return {
        message: "Login successful",
        user,
        token,
      };
    }

    // =====================
    // REGISTER NEW USER
    // =====================
    if (!email) {
      return { error: "Email is required for registration" };
    }

    const emailExists = await UserModel.findOne({ email });
    if (emailExists) {
      return { error: "Email already in use" };
    }

    const hashedPassword = await bcrypt.hash(password, SALT_ROUNDS);

    const newUser = new UserModel({
      username,
      email,
      password: hashedPassword,
    });

    await newUser.save();

    const token = generateToken(newUser);
    newUser.password = undefined;

    return {
      message: "User registered successfully",
      user: newUser,
      token,
    };

  } catch (error) {
    console.error("Auth Error:", error.message);
    return { error: "Internal server error" };
  }
};

