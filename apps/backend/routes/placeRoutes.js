import express from "express";
import {
  addCurrentPlace,
  getUserPlaces,
  deletePlace
} from "../controllers/placeController.js";
import { protect } from "../middleware/authMiddleware.js";

const router = express.Router();

// Add user's current location as a place
router.post("/add-current", protect, addCurrentPlace);

// Get all saved places of user
router.get("/", protect, getUserPlaces);

// Delete a place
router.delete("/:placeId", protect, deletePlace);

export default router;
