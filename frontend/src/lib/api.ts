// Real backend client — talks to the FastAPI + Postgres backend directly.
// No mock data, no Lovable/localStorage-only auth.

const API_BASE = "http://localhost:8000";

export const WS_URL = "ws://localhost:8000/ws/live";

// The actual test.mp4, annotated with your trained model's real
// detections and re-encoded to H.264/yuv420p for universal <video>
// support — not a live MJPEG stream (see backend/app/video_preprocess.py).
export const ANNOTATED_VIDEO_URL = `${API_BASE}/media/annotated.mp4`;

const TOKEN_KEY = "tla-token";

export interface Truck {
  id: number;
  truck_code: string;
  plate_number: string | null;
  expected_count: number;
  loaded_count: number;
  remaining: number;
  status: "waiting" | "loading" | "completed" | "mismatch";
  loading_started_at: string | null;
  created_at: string;
  updated_at: string;
}

export interface CountEvent {
  id: number;
  truck_id: number;
  event_type: string;
  track_id: number | null;
  note: string | null;
  created_at: string;
}

export interface DetectionClassStatus {
  detected: boolean;
  confidence: number; // 0-100
}

export interface DetectionStatus {
  classes: Record<string, DetectionClassStatus>;
  overall_accuracy: number | null; // 0-100, or null if nothing detected recently
}

function authHeaders(): HeadersInit {
  const token = isSignedIn()
    ? window.localStorage.getItem(TOKEN_KEY)
    : null;

  return token
    ? { Authorization: `Bearer ${token}` }
    : {};
}

async function request<T>(
  path: string,
  init?: RequestInit,
): Promise<T> {
  const res = await fetch(`${API_BASE}${path}`, {
    ...init,
    headers: {
      "Content-Type": "application/json",
      ...authHeaders(),
      ...(init?.headers ?? {}),
    },
  });

  if (!res.ok) {
    const body = await res.text().catch(() => "");

    throw new Error(
      `${res.status} ${res.statusText}${
        body ? `: ${body}` : ""
      }`,
    );
  }

  if (res.status === 204) {
    return undefined as T;
  }

  return res.json();
}

export async function login(
  email: string,
  password: string,
): Promise<void> {
  const data = await request<{ access_token: string }>(
    "/api/auth/login",
    {
      method: "POST",
      body: JSON.stringify({
        username: email,
        password,
      }),
    },
  );

  window.localStorage.setItem(
    TOKEN_KEY,
    data.access_token,
  );
}

export function signOut() {
  if (typeof window !== "undefined") {
    window.localStorage.removeItem(TOKEN_KEY);
  }
}

export function isSignedIn(): boolean {
  return (
    typeof window !== "undefined" &&
    !!window.localStorage.getItem(TOKEN_KEY)
  );
}

// --------------------------------------------------
// Truck API
// --------------------------------------------------

export const fetchTrucks = () =>
  request<Truck[]>("/api/trucks");

export const fetchTruckEvents = (truckId: number) =>
  request<CountEvent[]>(
    `/api/trucks/${truckId}/events`,
  );

export const createTruck = (payload: {
  truck_code: string;
  expected_count: number;
}) =>
  request<Truck>("/api/trucks", {
    method: "POST",
    body: JSON.stringify(payload),
  });

export const updateTruck = (
  truckId: number,
  payload: Partial<
    Pick<
      Truck,
      "expected_count" | "plate_number" | "status"
    >
  >,
) =>
  request<Truck>(`/api/trucks/${truckId}`, {
    method: "PATCH",
    body: JSON.stringify(payload),
  });

// --------------------------------------------------
// Detection API
// --------------------------------------------------

export const fetchDetectionStatus = () =>
  request<DetectionStatus>("/api/detections/status");