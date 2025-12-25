import TaskModel from "../models/taskModel.js";
import PlaceModel from "../models/placeModel.js";
import UserModel from "../models/userModel.js";
import mongoose from "mongoose";
import { limitUserEntries } from "../utils/limitUserEntries.js";

/**
 * CREATE TASK
 */
export const createTask = async (req, res) => {
  const {
    title,
    description,
    priority,
    dueDate,
    estimatedDuration,
    category,
    tags,
    linkedLocation,
    subtasks,
  } = req.body;

  const userId = req.user.id;

  if (!title) {
    return res.status(400).json({
      success: false,
      error: {
        code: "VALIDATION_ERROR",
        message: "Title is required.",
      },
    });
  }

  try {
    let placeId = null;

    // ---------- HANDLE LINKED LOCATION ----------
    if (linkedLocation?.lat && linkedLocation?.lng) {
      const savedPlace = await PlaceModel.create({
        user: userId,
        name: linkedLocation.name || "Task Location",
        location: {
          type: "Point",
          coordinates: [linkedLocation.lng, linkedLocation.lat],
        },
        geofenceRadiusMeters: linkedLocation.radius || 100,
      });

      placeId = savedPlace._id;

      // Add place reference to user
      await UserModel.findByIdAndUpdate(userId, {
        $push: { savedPlaces: savedPlace._id },
      });

      // Trim places (non-blocking)
      limitUserEntries(PlaceModel, userId, 20)
        .catch(err => console.error("Place trim failed:", err));
    }

    // ---------- CREATE TASK ----------
    const task = await TaskModel.create({
      user: userId,
      title,
      description,
      priority,
      dueDate,
      estimatedDuration,
      category,
      tags,
      subtasks: subtasks || [],
      location: placeId,
      status: "Pending",
    });

    // Push task reference FIRST
    await UserModel.findByIdAndUpdate(userId, {
      $push: { tasks: task._id },
    });

    // Trim tasks (non-blocking)
    limitUserEntries(TaskModel, userId, 20)
      .catch(err => console.error("Task trim failed:", err));

    return res.status(201).json({
      success: true,
      data: {
        id: task._id,
        title: task.title,
        status: task.status.toLowerCase(),
        createdAt: task.createdAt,
      },
    });
  } catch (err) {
    return res.status(500).json({
      success: false,
      error: {
        code: "INTERNAL_ERROR",
        message: "Server error while creating task.",
        details: err.message,
      },
    });
  }
};

/**
 * GET ALL TASKS
 */
export const getAllUserTasks = async (req, res) => {
  try {
    const query = { user: req.user.id };

    if (req.query.status && req.query.status !== "all") {
      query.status =
        req.query.status.charAt(0).toUpperCase() +
        req.query.status.slice(1);
    }

    if (req.query.priority && req.query.priority !== "all") {
      query.priority =
        req.query.priority.charAt(0).toUpperCase() +
        req.query.priority.slice(1);
    }

    if (req.query.date) {
      const start = new Date(req.query.date);
      const end = new Date(start);
      end.setDate(end.getDate() + 1);
      query.dueDate = { $gte: start, $lt: end };
    }

    const limit = Number(req.query.limit) || 50;
    const offset = Number(req.query.offset) || 0;

    const tasks = await TaskModel.find(query)
      .sort({ createdAt: -1 })
      .skip(offset)
      .limit(limit)
      .populate("location");

    const total = await TaskModel.countDocuments(query);

    return res.status(200).json({
      success: true,
      data: {
        tasks: tasks.map(t => ({
          id: t._id,
          title: t.title,
          description: t.description,
          status: t.status.toLowerCase(),
          priority: t.priority.toLowerCase(),
          dueDate: t.dueDate,
          estimatedDuration: t.estimatedDuration,
          category: t.category,
          tags: t.tags,
          createdAt: t.createdAt,
          updatedAt: t.updatedAt,
        })),
      },
      pagination: {
        total,
        limit,
        offset,
        hasMore: offset + tasks.length < total,
      },
    });
  } catch (err) {
    return res.status(500).json({
      success: false,
      error: {
        code: "INTERNAL_ERROR",
        message: "Server error fetching tasks.",
        details: err.message,
      },
    });
  }
};

/**
 * GET TASK BY ID
 */
export const getTaskById = async (req, res) => {
  if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
    return res.status(400).json({
      success: false,
      error: { code: "VALIDATION_ERROR", message: "Invalid Task ID." },
    });
  }

  const task = await TaskModel.findById(req.params.id).populate("location");

  if (!task)
    return res.status(404).json({
      success: false,
      error: { code: "NOT_FOUND", message: "Task not found." },
    });

  if (task.user.toString() !== req.user.id)
    return res.status(403).json({
      success: false,
      error: { code: "FORBIDDEN", message: "Not authorized." },
    });

  return res.status(200).json({
    success: true,
    data: {
      id: task._id,
      title: task.title,
      description: task.description,
      status: task.status.toLowerCase(),
      priority: task.priority.toLowerCase(),
      dueDate: task.dueDate,
      estimatedDuration: task.estimatedDuration,
      category: task.category,
      tags: task.tags,
      subtasks: task.subtasks,
      linkedLocation: task.location
        ? {
            name: task.location.name,
            lat: task.location.location.coordinates[1],
            lng: task.location.location.coordinates[0],
            radius: task.location.geofenceRadiusMeters,
          }
        : null,
      createdAt: task.createdAt,
      updatedAt: task.updatedAt,
    },
  });
};

/**
 * UPDATE TASK
 */
export const updateTask = async (req, res) => {
  if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
    return res.status(400).json({
      success: false,
      error: { code: "VALIDATION_ERROR", message: "Invalid Task ID." },
    });
  }

  const task = await TaskModel.findById(req.params.id);

  if (!task)
    return res.status(404).json({
      success: false,
      error: { code: "NOT_FOUND", message: "Task not found." },
    });

  if (task.user.toString() !== req.user.id)
    return res.status(403).json({
      success: false,
      error: { code: "FORBIDDEN", message: "Not authorized." },
    });

  Object.assign(task, req.body);
  await task.save();

  return res.status(200).json({
    success: true,
    data: {
      id: task._id,
      status: task.status.toLowerCase(),
      updatedAt: task.updatedAt,
    },
  });
};

/**
 * DELETE TASK
 */
export const deleteTask = async (req, res) => {
  if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
    return res.status(400).json({
      success: false,
      error: { code: "VALIDATION_ERROR", message: "Invalid Task ID." },
    });
  }

  const task = await TaskModel.findById(req.params.id);

  if (!task)
    return res.status(404).json({
      success: false,
      error: { code: "NOT_FOUND", message: "Task not found." },
    });

  if (task.user.toString() !== req.user.id)
    return res.status(403).json({
      success: false,
      error: { code: "FORBIDDEN", message: "Not authorized." },
    });

  await UserModel.findByIdAndUpdate(task.user, {
    $pull: { tasks: task._id },
  });

  await TaskModel.deleteOne({ _id: task._id });

  return res.status(200).json({
    success: true,
    message: "Task deleted successfully",
  });
};
