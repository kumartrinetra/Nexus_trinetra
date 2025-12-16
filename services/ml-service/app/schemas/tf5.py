from pydantic import BaseModel, Field

class TF5PerformanceRequest(BaseModel):
    task_priority: float = Field(0.5, ge=0.0, le=1.0)
    focus_score: float = Field(0.5, ge=0.0, le=1.0)
    context_score: float = Field(0.5, ge=0.0, le=1.0)
    wellness_score: float = Field(0.5, ge=0.0, le=1.0)

    task_completion_rate: float = Field(0.5, ge=0.0, le=1.0)
    sleep_deviation_hours: float = Field(0.0)

    fatigue_score: float = Field(0.5, ge=0.0, le=1.0)  # ✅ MISSING FEATURE


class TF5PerformanceResponse(BaseModel):
    performance_score: float
