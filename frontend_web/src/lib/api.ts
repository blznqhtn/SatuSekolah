const API_URL = process.env.NEXT_PUBLIC_API_URL || "http://localhost:8080/api/v1";

export async function fetchApi(endpoint: string, options: RequestInit = {}) {
  const token = typeof window !== "undefined" ? localStorage.getItem("satu_sekolah_token") : null;
  
  const headers: Record<string, string> = {
    "Content-Type": "application/json",
  };

  if (token) {
    headers["Authorization"] = `Bearer ${token}`;
  }

  const res = await fetch(`${API_URL}${endpoint}`, {
    ...options,
    headers: {
      ...headers,
      ...options.headers,
    },
  });

  const data = await res.json().catch(() => ({}));

  if (res.status === 401 && typeof window !== "undefined") {
    localStorage.removeItem("satu_sekolah_token");
    localStorage.removeItem("satu_sekolah_user");
    if (!window.location.pathname.startsWith("/login")) {
      window.location.href = "/login";
    }
  }

  if (!res.ok) {
    const errorMsg = data.error || data.message || `API error: ${res.statusText} (${res.status})`;
    throw new Error(errorMsg);
  }

  return data;
}

export const api = {
  get: <T = any>(endpoint: string, options?: RequestInit): Promise<T> =>
    fetchApi(endpoint, { ...options, method: "GET" }),
  post: <T = any>(endpoint: string, body?: any, options?: RequestInit): Promise<T> =>
    fetchApi(endpoint, {
      ...options,
      method: "POST",
      body: body !== undefined ? JSON.stringify(body) : undefined,
    }),
  put: <T = any>(endpoint: string, body?: any, options?: RequestInit): Promise<T> =>
    fetchApi(endpoint, {
      ...options,
      method: "PUT",
      body: body !== undefined ? JSON.stringify(body) : undefined,
    }),
  delete: <T = any>(endpoint: string, options?: RequestInit): Promise<T> =>
    fetchApi(endpoint, { ...options, method: "DELETE" }),
};

