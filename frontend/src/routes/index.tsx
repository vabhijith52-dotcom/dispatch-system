import { createFileRoute, useNavigate } from "@tanstack/react-router";
import { useEffect, useState } from "react";
import { Truck, User, Lock, LogIn } from "lucide-react";
import { GlassBackdrop } from "@/components/GlassBackdrop";
import { login } from "@/lib/api";

export const Route = createFileRoute("/")({
  component: LoginPage,
});

function LoginPage() {
  useEffect(() => {
    document.title = "Sign In — Truck Loading AI Monitoring";
  }, []);

  const navigate = useNavigate();
  const [username, setUsername] = useState("admin");
  const [password, setPassword] = useState("admin123");
  const [remember, setRemember] = useState(true);
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError("");
    setLoading(true);
    try {
      await login(username.trim(), password);
      navigate({ to: "/dashboard" });
    } catch {
      setError("Invalid credentials. Check the backend .env for the current login.");
    } finally {
      setLoading(false);
    }
  }

  return (
    <main className="relative flex min-h-screen items-center justify-center px-4 py-12">
      <GlassBackdrop />

      <div className="glass w-full max-w-md p-8 sm:p-10">
        <div className="flex flex-col items-center text-center">
          <div className="grid h-14 w-14 place-items-center rounded-2xl bg-primary/10 text-primary ring-1 ring-primary/15">
            <Truck className="h-7 w-7" />
          </div>
          <h1 className="mt-5 text-2xl font-bold text-foreground">Truck Loading AI</h1>
          <p className="mt-1.5 text-sm text-muted-foreground">
            AI-Powered Truck Loading Monitoring
          </p>
        </div>

        <form onSubmit={handleSubmit} className="mt-8 space-y-4">
          <div className="space-y-1.5">
            <label htmlFor="username" className="text-xs font-semibold text-secondary-foreground">
              Username
            </label>
            <div className="relative">
              <User className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
              <input
                id="username"
                type="text"
                autoComplete="username"
                value={username}
                onChange={(e) => setUsername(e.target.value)}
                className="w-full rounded-xl border border-white/70 bg-white/60 py-2.5 pl-10 pr-3 text-sm text-foreground shadow-sm outline-none backdrop-blur-md transition placeholder:text-muted-foreground focus:border-primary/40 focus:ring-4 focus:ring-primary/10"
                placeholder="admin"
              />
            </div>
          </div>

          <div className="space-y-1.5">
            <label htmlFor="password" className="text-xs font-semibold text-secondary-foreground">
              Password
            </label>
            <div className="relative">
              <Lock className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
              <input
                id="password"
                type="password"
                autoComplete="current-password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="w-full rounded-xl border border-white/70 bg-white/60 py-2.5 pl-10 pr-3 text-sm text-foreground shadow-sm outline-none backdrop-blur-md transition focus:border-primary/40 focus:ring-4 focus:ring-primary/10"
                placeholder="••••••••"
              />
            </div>
          </div>

          <div className="flex items-center justify-between gap-3 pt-1">
            <label className="flex cursor-pointer items-center gap-2 text-xs text-muted-foreground">
              <input
                type="checkbox"
                checked={remember}
                onChange={(e) => setRemember(e.target.checked)}
                className="h-4 w-4 rounded border-border accent-primary"
              />
              Remember Me
            </label>
            <button
              type="button"
              className="text-xs font-medium text-primary transition hover:text-primary/80"
            >
              Forgot Password
            </button>
          </div>

          {error && (
            <p className="rounded-xl border border-destructive/20 bg-destructive/5 px-3 py-2 text-xs text-destructive">
              {error}
            </p>
          )}

          <button
            type="submit"
            disabled={loading}
            className="mt-2 inline-flex w-full items-center justify-center gap-2 rounded-xl bg-primary py-2.5 text-sm font-semibold text-primary-foreground shadow-lg shadow-primary/20 transition hover:bg-primary/90 disabled:opacity-60"
          >
            <LogIn className="h-4 w-4" />
            {loading ? "Signing in..." : "Sign In"}
          </button>
        </form>
      </div>
    </main>
  );
}
