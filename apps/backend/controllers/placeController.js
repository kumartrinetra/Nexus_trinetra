import PlaceModel from "../models/placeModel.js";
import { limitUserEntries } from "../utils/limitUserEntries.js";
import mongoose from "mongoose";

/**
 * Add current location as a place
 */
export const addCurrentPlace = async (req, res) => {
  try {
    const userId = req.user._id;
    let { placeName, lat, lng, address } = req.body;

    if (!placeName || lat === undefined || lng === undefined) {
      return res.status(400).json({
        success: false,
        message: "placeName, lat and lng are required",
      });
    }

    placeName = placeName.trim().toLowerCase();

    if (placeName.length < 2) {
      return res.status(400).json({
        success: false,
        message: "Place name too short",
      });
    }

    // Prevent duplicate place names per user
    const existingPlace = await PlaceModel.findOne({
      user: userId,
      name: placeName,
    });

    if (existingPlace) {
      return res.status(409).json({
        success: false,
        message: "Place already exists",
      });
    }

    const place = await PlaceModel.create({
      user: userId,
      name: placeName,
      address: address || "",
      location: {
        type: "Point",
        coordinates: [lng, lat], // IMPORTANT: [longitude, latitude]
      },
      geofenceRadiusMeters: 50,
    });

    // this limits number of places for any user to atmost 20
    await limitUserEntries(PlaceModel,userId,20);

    return res.status(201).json({
      success: true,
      place,
    });
  } catch (err) {
    console.error("Add place error:", err);
    return res.status(500).json({
      success: false,
      message: "Failed to add place",
    });
  }
  
};

/**
 * Get all places of logged-in user
 */
export const getUserPlaces = async (req, res) => {
  try {
    const userId = req.user._id;

    const places = await PlaceModel.find({ user: userId }).sort({
      createdAt: -1,
    });

    return res.json({
      success: true,
      count: places.length,
      data: places,
    });
  } catch (err) {
    console.error("Get places error:", err);
    return res.status(500).json({
      success: false,
      message: "Failed to fetch places",
    });
  }
};

/**
 * Delete a place
 */
export const deletePlace = async (req, res) => {
  try {
    const userId = req.user._id;
    const { placeId } = req.params;

    if (!mongoose.Types.ObjectId.isValid(placeId)) {
      return res.status(400).json({
        success: false,
        message: "Invalid place ID",
      });
    }

    const place = await PlaceModel.findOneAndDelete({
      _id: placeId,
      user: userId,
    });

    if (!place) {
      return res.status(404).json({
        success: false,
        message: "Place not found",
      });
    }

    return res.json({
      success: true,
      message: "Place deleted successfully",
    });
  } catch (err) {
    console.error("Delete place error:", err);
    return res.status(500).json({
      success: false,
      message: "Failed to delete place",
    });
  }
};
