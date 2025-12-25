/**
 * Keeps only the latest N entries for a user in a collection
 *
 * @param {mongoose.Model} Model - Mongoose model (Task, Place, etc.)
 * @param {String} userId - User ObjectId
 * @param {Number} limit - Max number of documents to keep
 */
export const limitUserEntries = async (Model, userId, limit = 20) => {
  // 1️⃣ Count total documents
  const total = await Model.countDocuments({ user: userId });

  if (total <= limit) return;

  // 2️⃣ Find IDs of documents to delete (oldest first)
  const docsToDelete = await Model.find({ user: userId })
    .sort({ createdAt: 1 }) // oldest first
    .limit(total - limit)
    .select("_id");

  const ids = docsToDelete.map((doc) => doc._id);

  // 3️⃣ Delete them in one operation
  await Model.deleteMany({ _id: { $in: ids } });
};
