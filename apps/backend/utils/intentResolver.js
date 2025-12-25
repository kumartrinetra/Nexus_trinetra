export const resolveIntent = (text) => {
  const t = text.toLowerCase().trim();

  if (t.includes("add") && (t.includes("location") || t.includes("place"))) {
    return {
      intent: "ADD_PLACE",
      entities: {
        placeName: extractPlaceName(t),
      },
    };
  }

  if (t.includes("add") && t.includes("task")) {
    return {
      intent: "ADD_TASK",
      entities: {
        title: extractTaskTitle(t),
      },
    };
  }

  return {
    intent: "UNKNOWN",
    entities: {},
  };
};

const extractPlaceName = (text) => {
  return text.replace(/add|my|current|location|place|as|save/g, "").trim();
};

const extractTaskTitle = (text) => {
  return text.replace(/add|task|to|me|remind/g, "").trim();
};
