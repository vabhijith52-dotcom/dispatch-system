import { createFileRoute, useNavigate } from "@tanstack/react-router";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { useEffect, useRef, useState } from "react";
import {
  Bell,
  Boxes,
  ClipboardList,
  Menu,
  PackageCheck,
  PackageMinus,
  Plus,
  Truck,
} from "lucide-react";
import { GlassBackdrop } from "@/components/GlassBackdrop";
import { DashboardSidebar } from "@/components/dashboard/DashboardSidebar";
import { LiveMonitor } from "@/components/dashboard/LiveMonitor";
import {
  fetchTrucks,
  fetchTruckEvents,
  fetchDetectionStatus,
  isSignedIn,
  signOut,
  WS_URL,
  type Truck as TruckRecord,
} from "@/lib/api";

export const Route = createFileRoute("/dashboard")({
  component: DashboardPage,
});

function statusBadge(status: string) {
  if (status === "completed") return "border-emerald-200/70 bg-emerald-50/70 text-emerald-700";
  if (status === "mismatch") return "border-amber-200/70 bg-amber-50/70 text-amber-700";
  return "border-sky-200/70 bg-sky-50/70 text-sky-700";
}

function DashboardPage() {
  useEffect(() => {
    document.title = "Loading Dashboard — Truck Loading AI";
  }, []);

  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const [menuOpen, setMenuOpen] = useState(false);

  useEffect(() => {
    if (!isSignedIn()) navigate({ to: "/" });
  }, [navigate]);

  // Real data: trucks table, the currently-loading truck's events, and
  // live per-class detection confidence — all from the FastAPI backend.
  const trucksQuery = useQuery({
    queryKey: ["trucks"],
    queryFn: fetchTrucks,
    refetchInterval: 3000, // fallback poll; WebSocket above drives instant updates
  });

  const trucks = trucksQuery.data ?? [];
  const activeTruck: TruckRecord | null =
    trucks.find((t) => t.status === "loading") ?? trucks[0] ?? null;

  const eventsQuery = useQuery({
    queryKey: ["truck-events", activeTruck?.id],
    queryFn: () => fetchTruckEvents(activeTruck!.id),
    enabled: !!activeTruck,
    refetchInterval: 3000,
  });
  const events = eventsQuery.data ?? [];

  const detectionQuery = useQuery({
    queryKey: ["detection-status"],
    queryFn: fetchDetectionStatus,
    refetchInterval: 3000,
  });
  const detection = detectionQuery.data;

  // Live updates: pipeline detections AND manual DB edits both flow through
  // the same Postgres NOTIFY -> WebSocket path (see backend/sql/schema.sql).
  // Auto-reconnects with backoff — important now, since the very first
  // connection attempt can land while the backend is still doing its
  // one-time video preprocessing on startup.
  const wsRef = useRef<WebSocket | null>(null);
  useEffect(() => {
    let cancelled = false;
    let retryDelay = 1000;
    let retryTimer: ReturnType<typeof setTimeout>;

    function connect() {
      if (cancelled) return;
      const ws = new WebSocket(WS_URL);
      wsRef.current = ws;

      ws.onopen = () => {
        retryDelay = 1000; // reset backoff once a connection succeeds
      };
      ws.onmessage = () => {
        queryClient.invalidateQueries({ queryKey: ["trucks"] });
        queryClient.invalidateQueries({ queryKey: ["truck-events"] });
        queryClient.invalidateQueries({ queryKey: ["detection-status"] });
      };
      ws.onclose = () => {
        if (cancelled) return;
        retryTimer = setTimeout(connect, retryDelay);
        retryDelay = Math.min(retryDelay * 1.5, 10000);
      };
      ws.onerror = () => ws.close();
    }

    connect();
    return () => {
      cancelled = true;
      clearTimeout(retryTimer);
      wsRef.current?.close();
    };
  }, [queryClient]);

  const expected = activeTruck?.expected_count ?? 0;
  const loaded = activeTruck?.loaded_count ?? 0;
  const remaining = activeTruck?.remaining ?? 0;
  const progress = expected ? Math.round((loaded / expected) * 100) : 0;

  const now = Date.now();
  const loadingRate = events.filter(
    (e) => now - new Date(e.created_at).getTime() < 60000,
  ).length;
  const etaMinutes = loadingRate > 0 ? Math.ceil(remaining / loadingRate) : null;
  const accuracy = detection?.overall_accuracy;

  function handleLogout() {
    signOut();
    navigate({ to: "/" });
  }

  const kpis = [
    {
      label: "Truck Number",
      value: activeTruck?.plate_number ?? "Scanning...",
      icon: Truck,
      tone: "text-sky-600 bg-sky-50/80",
    },
    {
      label: "Expected Cartons",
      value: expected ? String(expected) : "—",
      icon: ClipboardList,
      tone: "text-slate-600 bg-slate-100/80",
    },
    {
      label: "Loaded Cartons",
      value: activeTruck ? String(loaded) : "—",
      icon: PackageCheck,
      tone: "text-emerald-600 bg-emerald-50/80",
      highlight: true,
    },
    {
      label: "Remaining",
      value: activeTruck ? String(remaining) : "—",
      icon: PackageMinus,
      tone: "text-amber-600 bg-amber-50/80",
    },
  ];

  const truckDet = detection?.classes?.["Truck"];
  const plateDet = detection?.classes?.["Number plate"];
  const cartonDet = detection?.classes?.["Carton_box"];

  const detectionCards = [
    {
      title: "Truck Detection",
      state: truckDet?.detected ? "Detected" : "Idle",
      detail: null as string | null,
      conf: truckDet ? `${truckDet.confidence}% confidence` : "no recent detection",
    },
    {
      title: "License Plate",
      state: plateDet?.detected ? "Detected" : "Scanning",
      detail: activeTruck?.plate_number ?? null,
      conf: plateDet ? `${plateDet.confidence}% confidence` : "no recent detection",
    },
    {
      title: "Carton Detection",
      state: cartonDet?.detected ? "Active" : "Idle",
      detail: null as string | null,
      conf: cartonDet ? `${cartonDet.confidence}% confidence` : "no recent detection",
    },
  ];

  return (
    <div className="relative min-h-screen">
      <GlassBackdrop />

      <div className="flex min-h-screen gap-0 lg:gap-6 lg:p-6">
        <div className="hidden lg:block">
          <div className="sticky top-6 h-[calc(100vh-3rem)]">
            <DashboardSidebar onLogout={handleLogout} />
          </div>
        </div>

        {menuOpen && (
          <div className="fixed inset-0 z-50 lg:hidden">
            <button
              aria-label="Close menu overlay"
              onClick={() => setMenuOpen(false)}
              className="absolute inset-0 bg-slate-900/20 backdrop-blur-sm"
            />
            <div className="absolute inset-y-0 left-0">
              <DashboardSidebar onLogout={handleLogout} onClose={() => setMenuOpen(false)} />
            </div>
          </div>
        )}

        <main className="min-w-0 flex-1 px-4 py-6 sm:px-6 lg:px-0 lg:py-0">
          <header className="grid grid-cols-[minmax(0,1fr)_auto] items-center gap-4 sm:flex sm:justify-between">
            <div className="flex min-w-0 items-center gap-3">
              <button
                onClick={() => setMenuOpen(true)}
                aria-label="Open menu"
                className="glass shrink-0 rounded-xl p-2 text-secondary-foreground lg:hidden"
              >
                <Menu className="h-4 w-4" />
              </button>
              <div className="min-w-0">
                <h1 className="truncate text-xl font-bold text-foreground sm:text-2xl">
                  Loading Dashboard
                </h1>
                <p className="truncate text-xs text-muted-foreground sm:text-sm">
                  Warehouse 01 • Loading Bay 01
                </p>
              </div>
            </div>
            <div className="flex shrink-0 items-center gap-2">
              <button
                aria-label="Notifications"
                className="glass relative rounded-xl p-2.5 text-secondary-foreground"
              >
                <Bell className="h-4 w-4" />
                <span className="absolute right-2 top-2 h-1.5 w-1.5 rounded-full bg-destructive" />
              </button>
              <div className="grid h-10 w-10 place-items-center rounded-full bg-primary/15 text-xs font-bold text-primary ring-1 ring-white/70">
                AD
              </div>
            </div>
          </header>

          <div className="mt-6 grid grid-cols-1 gap-4 sm:grid-cols-2 xl:grid-cols-4">
            {kpis.map((kpi) => (
              <div
                key={kpi.label}
                className={`glass glass-hover p-5 ${kpi.highlight ? "ring-1 ring-primary/20" : ""}`}
              >
                <div className="flex items-center justify-between gap-3">
                  <p className="text-xs font-medium text-muted-foreground">{kpi.label}</p>
                  <span className={`grid h-8 w-8 shrink-0 place-items-center rounded-lg ${kpi.tone}`}>
                    <kpi.icon className="h-4 w-4" />
                  </span>
                </div>
                <p
                  className={`mt-3 font-bold tracking-tight text-foreground ${
                    kpi.highlight ? "text-3xl text-primary" : "text-2xl"
                  }`}
                >
                  {kpi.value}
                </p>
              </div>
            ))}
          </div>

          <div className="mt-4 grid grid-cols-1 gap-4 xl:grid-cols-3">
            <div className="xl:col-span-2">
              <LiveMonitor />
            </div>

            <section className="glass glass-hover p-5">
              <h2 className="text-base font-bold text-foreground">Current Loading</h2>
              <dl className="mt-4 space-y-2.5 text-sm">
                {[
                  ["Truck Number", activeTruck?.plate_number ?? "Scanning..."],
                  ["Status", (activeTruck?.status ?? "waiting").toUpperCase()],
                  ["Loading Bay", "Bay 01"],
                  [
                    "Start Time",
                    activeTruck?.loading_started_at
                      ? new Date(activeTruck.loading_started_at).toLocaleTimeString([], {
                          hour: "2-digit",
                          minute: "2-digit",
                        })
                      : "—",
                  ],
                  ["Expected", expected ? String(expected) : "—"],
                  ["Loaded", activeTruck ? String(loaded) : "—"],
                  ["Remaining", activeTruck ? String(remaining) : "—"],
                  ["Progress", `${progress}%`],
                ].map(([k, v]) => (
                  <div key={k} className="flex items-center justify-between gap-3">
                    <dt className="text-muted-foreground">{k}</dt>
                    <dd className={`font-semibold ${k === "Status" ? "text-sky-600" : "text-foreground"}`}>
                      {v}
                    </dd>
                  </div>
                ))}
              </dl>

              <div className="mt-5">
                <div className="h-2.5 w-full overflow-hidden rounded-full bg-slate-200/70">
                  <div
                    className="h-full rounded-full bg-primary transition-all duration-500"
                    style={{ width: `${progress}%` }}
                  />
                </div>
                <p className="mt-2 text-xs text-muted-foreground">
                  {loaded} / {expected} cartons
                </p>
              </div>

              <div className="mt-5 grid grid-cols-3 gap-2 border-t border-white/70 pt-4 text-center">
                {[
                  ["Loading Rate", `${loadingRate} /min`],
                  ["Est. Completion", etaMinutes !== null ? `${etaMinutes} min` : "—"],
                  ["Accuracy", accuracy !== null && accuracy !== undefined ? `${accuracy}%` : "—"],
                ].map(([k, v]) => (
                  <div key={k}>
                    <p className="text-[11px] text-muted-foreground">{k}</p>
                    <p className="mt-0.5 text-sm font-bold text-foreground">{v}</p>
                  </div>
                ))}
              </div>
            </section>
          </div>

          <div className="mt-4 grid grid-cols-1 gap-4 xl:grid-cols-3">
            <section className="glass glass-hover p-5">
              <div className="flex items-center justify-between gap-3">
                <h2 className="text-base font-bold text-foreground">Live Carton Count</h2>
                <Boxes className="h-4 w-4 shrink-0 text-primary" />
              </div>
              <p className="mt-4 text-5xl font-extrabold tracking-tight text-primary">{loaded}</p>
              <p className="mt-1 text-sm text-muted-foreground">
                {loaded} of {expected} cartons loaded
              </p>

              <div className="mt-4 h-2.5 w-full overflow-hidden rounded-full bg-slate-200/70">
                <div
                  className="h-full rounded-full bg-primary transition-all duration-500"
                  style={{ width: `${progress}%` }}
                />
              </div>

              <div className="mt-4 grid grid-cols-3 gap-2 text-center text-xs">
                <div className="rounded-xl border border-white/70 bg-white/50 py-2 backdrop-blur-md">
                  <p className="text-muted-foreground">Expected</p>
                  <p className="mt-0.5 text-sm font-bold text-foreground">{expected}</p>
                </div>
                <div className="rounded-xl border border-white/70 bg-white/50 py-2 backdrop-blur-md">
                  <p className="text-muted-foreground">Loaded</p>
                  <p className="mt-0.5 text-sm font-bold text-emerald-600">{loaded}</p>
                </div>
                <div className="rounded-xl border border-white/70 bg-white/50 py-2 backdrop-blur-md">
                  <p className="text-muted-foreground">Remaining</p>
                  <p className="mt-0.5 text-sm font-bold text-amber-600">{remaining}</p>
                </div>
              </div>

              <button
                disabled
                title="Cartons are counted automatically by the detection pipeline — this is no longer a manual simulate button"
                className="mt-4 inline-flex w-full cursor-not-allowed items-center justify-center gap-2 rounded-xl bg-primary/50 py-2.5 text-sm font-semibold text-primary-foreground/80"
              >
                <Plus className="h-4 w-4" />
                Counted automatically
              </button>
            </section>

            <div className="grid grid-cols-1 gap-4 sm:grid-cols-3 xl:col-span-2 xl:grid-cols-3">
              {detectionCards.map((d) => (
                <section key={d.title} className="glass glass-hover h-fit p-5">
                  <p className="text-xs font-medium text-muted-foreground">{d.title}</p>
                  <p className="mt-2 inline-flex items-center gap-1.5 text-sm font-semibold text-emerald-600">
                    <span className="h-1.5 w-1.5 rounded-full bg-emerald-500" />
                    {d.state}
                  </p>
                  {d.detail && <p className="mt-1.5 text-sm font-bold text-foreground">{d.detail}</p>}
                  <p className="mt-1 text-xs text-muted-foreground">{d.conf}</p>
                </section>
              ))}

              <section className="glass glass-hover p-5 sm:col-span-3">
                <h2 className="text-base font-bold text-foreground">Recent Activity</h2>
                <ul className="mt-3 max-h-64 space-y-2 overflow-y-auto pr-1">
                  {events.length === 0 && (
                    <li className="text-sm text-muted-foreground">No activity yet.</li>
                  )}
                  {events.map((e) => (
                    <li
                      key={e.id}
                      className="flex items-center gap-3 rounded-xl border border-white/70 bg-white/50 px-3 py-2 text-sm backdrop-blur-md"
                    >
                      <span className="shrink-0 font-mono text-xs text-muted-foreground">
                        {new Date(e.created_at).toLocaleTimeString("en-GB", { hour12: false })}
                      </span>
                      <span className="min-w-0 truncate text-secondary-foreground">
                        {e.event_type === "carton_added" ? "Carton loaded" : e.note ?? e.event_type}
                      </span>
                    </li>
                  ))}
                </ul>
              </section>
            </div>
          </div>

          <section className="glass glass-hover mt-4 p-5">
            <h2 className="text-base font-bold text-foreground">Recent Loading Sessions</h2>
            <div className="mt-4 overflow-x-auto">
              <table className="w-full min-w-[560px] text-left text-sm">
                <thead>
                  <tr className="text-xs uppercase tracking-wide text-muted-foreground">
                    <th className="pb-3 font-medium">Truck Number</th>
                    <th className="pb-3 font-medium">Expected</th>
                    <th className="pb-3 font-medium">Loaded</th>
                    <th className="pb-3 font-medium">Start Time</th>
                    <th className="pb-3 font-medium">Status</th>
                  </tr>
                </thead>
                <tbody>
                  {trucks.map((t) => (
                    <tr key={t.id} className="border-t border-white/70">
                      <td className="py-3 font-semibold text-foreground">{t.plate_number ?? "Scanning..."}</td>
                      <td className="py-3 text-secondary-foreground">{t.expected_count}</td>
                      <td className="py-3 text-secondary-foreground">{t.loaded_count}</td>
                      <td className="py-3 text-secondary-foreground">
                        {t.loading_started_at
                          ? new Date(t.loading_started_at).toLocaleTimeString([], {
                              hour: "2-digit",
                              minute: "2-digit",
                            })
                          : "—"}
                      </td>
                      <td className="py-3">
                        <span
                          className={`inline-flex rounded-full border px-2.5 py-1 text-[11px] font-semibold capitalize backdrop-blur-md ${statusBadge(t.status)}`}
                        >
                          {t.status}
                        </span>
                      </td>
                    </tr>
                  ))}
                  {trucks.length === 0 && (
                    <tr>
                      <td colSpan={5} className="py-6 text-center text-muted-foreground">
                        No trucks yet.
                      </td>
                    </tr>
                  )}
                </tbody>
              </table>
            </div>
          </section>
        </main>
      </div>
    </div>
  );
}
