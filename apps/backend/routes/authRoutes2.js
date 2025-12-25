import express from "express";
import {
  registerUser,
  loginUser,
  refreshAccessToken,
  logoutUser,
} from "../controllers/authController.js";

import { protect } from "../middleware/authMiddleware.js";
import rateLimit from "express-rate-limit";

const router = express.Router();

/* ================================
   RATE LIMITERS (ANTI-BRUTE FORCE)
================================ */

const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 10, // 10 requests per IP
  message: {
    error: "Too many attempts. Please try again later.",
  },
  standardHeaders: true,
  legacyHeaders: false,
});

/* ================================
   INPUT VALIDATION (LIGHTWEIGHT)
================================ */

const validateAuthInput = (req, res, next) => {
  const { username, password, email } = req.body;

  if (!username || !password) {
    return res.status(400).json({
      error: "Username and password are required",
    });
  }

  if (email && !email.includes("@")) {
    return res.status(400).json({
      error: "Invalid email format",
    });
  }

  next();
};

/* ================================
   ROUTES
================================ */

// Register new user
router.post(
  "/register",
  authLimiter,
  validateAuthInput,
  registerUser
);

// Login existing user
router.post(
  "/login",
  authLimiter,
  validateAuthInput,
  loginUser
);

// Refresh access token
router.post(
  "/refresh",
  authLimiter,
  refreshAccessToken
);

// Logout user (protected)
router.post(
  "/logout",
  protect,
  logoutUser
);

export default router;
