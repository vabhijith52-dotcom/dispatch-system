import {
  createFileRoute,
  useNavigate,
} from "@tanstack/react-router";

import {
  useQuery,
  useQueryClient,
} from "@tanstack/react-query";

import {
  useEffect,
  useRef,
  useState,
} from "react";

import {
  Bell,
  Boxes,
  Menu,
  PackageCheck,
  PackageMinus,
  Plus,
  Truck,
  Check,
  Pencil,
  X,
} from "lucide-react";

import { GlassBackdrop } from "@/components/GlassBackdrop";
import { DashboardSidebar } from "@/components/dashboard/DashboardSidebar";
import { LiveMonitor } from "@/components/dashboard/LiveMonitor";
import { RecentSessionsToolbar } from "@/components/dashboard/RecentSessionsToolbar";

import {
  fetchTrucks,
  fetchTruckEvents,
  fetchDetectionStatus,
  isSignedIn,
  signOut,
  WS_URL,
  updateTruck,
  type Truck as TruckRecord,
} from "@/lib/api";

export const Route = createFileRoute(
  "/dashboard",
)({
  component: DashboardPage,
});

function statusBadge(status: string) {
  if (status === "completed") {
    return "border-emerald-200/70 bg-emerald-50/70 text-emerald-700";
  }

  if (status === "mismatch") {
    return "border-amber-200/70 bg-amber-50/70 text-amber-700";
  }

  return "border-sky-200/70 bg-sky-50/70 text-sky-700";
}

function DashboardPage() {
  useEffect(() => {
    document.title =
      "Loading Dashboard — Truck Loading AI";
  }, []);

  const navigate = useNavigate();

  const queryClient = useQueryClient();

  const [menuOpen, setMenuOpen] =
    useState(false);

  const [selectedDate, setSelectedDate] =
    useState(
      new Date().toLocaleDateString(
        "en-CA",
      ),
    );

  const [
    editingExpected,
    setEditingExpected,
  ] = useState(false);

  const [
    expectedInput,
    setExpectedInput,
  ] = useState("");

  const [
    savingExpected,
    setSavingExpected,
  ] = useState(false);

  useEffect(() => {
    if (!isSignedIn()) {
      navigate({ to: "/" });
    }
  }, [navigate]);

  const trucksQuery = useQuery({
    queryKey: ["trucks"],
    queryFn: fetchTrucks,
    refetchInterval: 3000,
  });

  const trucks =
    trucksQuery.data ?? [];

  const activeTruck:
    | TruckRecord
    | null =
    trucks.find(
      (truck) =>
        truck.status === "loading",
    ) ??
    trucks[0] ??
    null;

  const eventsQuery = useQuery({
    queryKey: [
      "truck-events",
      activeTruck?.id,
    ],

    queryFn: () =>
      fetchTruckEvents(
        activeTruck!.id,
      ),

    enabled: !!activeTruck,

    refetchInterval: 3000,
  });

  const events =
    eventsQuery.data ?? [];

  const detectionQuery = useQuery({
    queryKey: ["detection-status"],

    queryFn:
      fetchDetectionStatus,

    refetchInterval: 3000,
  });

  const detection =
    detectionQuery.data;

  const wsRef =
    useRef<WebSocket | null>(
      null,
    );

  useEffect(() => {
    let cancelled = false;

    let retryDelay = 1000;

    let retryTimer:
      | ReturnType<typeof setTimeout>
      | undefined;

    function connect() {
      if (cancelled) return;

      const ws =
        new WebSocket(WS_URL);

      wsRef.current = ws;

      ws.onopen = () => {
        retryDelay = 1000;
      };

      ws.onmessage = () => {
        queryClient.invalidateQueries({
          queryKey: ["trucks"],
        });

        queryClient.invalidateQueries({
          queryKey: ["truck-events"],
        });

        queryClient.invalidateQueries({
          queryKey: [
            "detection-status",
          ],
        });
      };

      ws.onclose = () => {
        if (cancelled) return;

        retryTimer =
          setTimeout(
            connect,
            retryDelay,
          );

        retryDelay = Math.min(
          retryDelay * 1.5,
          10000,
        );
      };

      ws.onerror = () => {
        ws.close();
      };
    }

    connect();

    return () => {
      cancelled = true;

      if (retryTimer) {
        clearTimeout(
          retryTimer,
        );
      }

      wsRef.current?.close();
    };
  }, [queryClient]);

  const expected =
    activeTruck?.expected_count ??
    0;

  const loaded =
    activeTruck?.loaded_count ??
    0;

  const remaining =
    activeTruck?.remaining ??
    0;

  const progress = expected
    ? Math.round(
        (loaded / expected) *
          100,
      )
    : 0;

  const now = Date.now();

  const loadingRate =
    events.filter(
      (event) =>
        now -
          new Date(
            event.created_at,
          ).getTime() <
        60000,
    ).length;

  const etaMinutes =
    loadingRate > 0
      ? Math.ceil(
          remaining /
            loadingRate,
        )
      : null;

  const accuracy =
    detection?.overall_accuracy;

  function startEditingExpected() {
    setExpectedInput(
      String(expected),
    );

    setEditingExpected(true);
  }

  async function saveExpectedCount() {
    if (!activeTruck) return;

    const value =
      Number(expectedInput);

    if (
      !Number.isFinite(value) ||
      value < 0
    ) {
      return;
    }

    setSavingExpected(true);

    try {
      await updateTruck(
        activeTruck.id,
        {
          expected_count: value,
        },
      );

      await queryClient.invalidateQueries(
        {
          queryKey: ["trucks"],
        },
      );

      setEditingExpected(false);
    } finally {
      setSavingExpected(false);
    }
  }

  function handleLogout() {
    signOut();

    navigate({
      to: "/",
    });
  }

  const kpis = [
    {
      label: "Truck Number",
      value:
        activeTruck?.plate_number ??
        "Scanning...",
      icon: Truck,
      tone:
        "text-sky-600 bg-sky-50/80",
    },

    {
      label: "Remaining",
      value: activeTruck
        ? String(remaining)
        : "—",
      icon: PackageMinus,
      tone:
        "text-amber-600 bg-amber-50/80",
    },

    {
      label: "Loaded Cartons",
      value: activeTruck
        ? String(loaded)
        : "—",
      icon: PackageCheck,
      tone:
        "text-emerald-600 bg-emerald-50/80",
      highlight: true,
    },
  ];

  const truckDet =
    detection?.classes?.[
      "Truck"
    ];

  const plateDet =
    detection?.classes?.[
      "Number plate"
    ];

  const cartonDet =
    detection?.classes?.[
      "Carton_box"
    ];

  const detectionCards = [
    {
      title: "Truck Detection",
      state: truckDet?.detected
        ? "Detected"
        : "Idle",
      detail:
        null as string | null,
      conf: truckDet
        ? `${truckDet.confidence}% confidence`
        : "no recent detection",
    },

    {
      title: "License Plate",
      state: plateDet?.detected
        ? "Detected"
        : "Scanning",
      detail:
        activeTruck?.plate_number ??
        null,
      conf: plateDet
        ? `${plateDet.confidence}% confidence`
        : "no recent detection",
    },

    {
      title: "Carton Detection",
      state: cartonDet?.detected
        ? "Active"
        : "Idle",
      detail:
        null as string | null,
      conf: cartonDet
        ? `${cartonDet.confidence}% confidence`
        : "no recent detection",
    },
  ];

  const filteredTrucks =
    trucks
      .filter((truck) => {
        const date =
          new Date(
            truck.loading_started_at ??
              truck.created_at,
          );

        return (
          date.toLocaleDateString(
            "en-CA",
          ) === selectedDate
        );
      })
      .sort(
        (a, b) =>
          new Date(
            b.loading_started_at ??
              b.created_at,
          ).getTime() -
          new Date(
            a.loading_started_at ??
              a.created_at,
          ).getTime(),
      );

  return (
    <div className="relative min-h-screen">
      <GlassBackdrop />

      <div className="flex min-h-screen gap-0 lg:gap-6 lg:p-6">
        <div className="hidden lg:block">
          <div className="sticky top-6 h-[calc(100vh-3rem)]">
            <DashboardSidebar
              onLogout={
                handleLogout
              }
            />
          </div>
        </div>

        {menuOpen && (
          <div className="fixed inset-0 z-50 lg:hidden">
            <button
              aria-label="Close menu overlay"
              onClick={() =>
                setMenuOpen(false)
              }
              className="absolute inset-0 bg-slate-900/20 backdrop-blur-sm"
            />

            <div className="absolute inset-y-0 left-0">
              <DashboardSidebar
                onLogout={
                  handleLogout
                }
                onClose={() =>
                  setMenuOpen(false)
                }
              />
            </div>
          </div>
        )}

        <main className="min-w-0 flex-1 px-4 py-6 sm:px-6 lg:px-0 lg:py-0">
          <header className="grid grid-cols-[minmax(0,1fr)_auto] items-center gap-4 sm:flex sm:justify-between">
            <div className="flex min-w-0 items-center gap-3">
              <button
                onClick={() =>
                  setMenuOpen(true)
                }
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

          {/* KPI Cards */}
          <div className="mt-6 grid grid-cols-1 gap-4 sm:grid-cols-2 xl:grid-cols-4">

            {/* Truck Number */}
            {(() => {
              const kpi = kpis[0];
              const Icon = kpi.icon;

              return (
                <div
                  key={kpi.label}
                  className="glass glass-hover p-5"
                >
                  <div className="flex items-center justify-between gap-3">
                    <p className="text-xs font-medium text-muted-foreground">
                      {kpi.label}
                    </p>

                    <span
                      className={`grid h-8 w-8 shrink-0 place-items-center rounded-lg ${kpi.tone}`}
                    >
                      <Icon className="h-4 w-4" />
                    </span>
                  </div>

                  <p className="mt-3 text-2xl font-bold tracking-tight text-foreground">
                    {kpi.value}
                  </p>
                </div>
              );
            })()}

            {/* Expected Cartons */}
            <div className="glass glass-hover p-5">
              <div className="flex items-center justify-between gap-3">
                <p className="text-xs font-medium text-muted-foreground">
                  Expected Cartons
                </p>

                {!editingExpected && (
                  <button
                    type="button"
                    onClick={
                      startEditingExpected
                    }
                    aria-label="Edit expected cartons"
                    title="Edit expected cartons"
                    className="grid h-8 w-8 place-items-center rounded-lg bg-slate-100/80 text-slate-600 transition hover:bg-slate-200/80"
                  >
                    <Pencil className="h-4 w-4" />
                  </button>
                )}
              </div>

              {!editingExpected ? (
                <p className="mt-3 text-2xl font-bold tracking-tight text-foreground">
                  {activeTruck
                    ? expected
                    : "—"}
                </p>
              ) : (
                <div className="mt-3">
                  <input
                    autoFocus
                    type="number"
                    min="0"
                    value={
                      expectedInput
                    }
                    onChange={(event) =>
                      setExpectedInput(
                        event.target
                          .value,
                      )
                    }
                    onKeyDown={(event) => {
                      if (
                        event.key ===
                        "Enter"
                      ) {
                        void saveExpectedCount();
                      }

                      if (
                        event.key ===
                        "Escape"
                      ) {
                        setEditingExpected(
                          false,
                        );
                      }
                    }}
                    className="w-full rounded-lg border border-input bg-background px-3 py-2 text-lg font-bold text-foreground outline-none focus:ring-2 focus:ring-primary/30"
                  />

                  <div className="mt-2 flex gap-2">
                    <button
                      type="button"
                      onClick={() =>
                        void saveExpectedCount()
                      }
                      disabled={
                        savingExpected
                      }
                      className="inline-flex flex-1 items-center justify-center gap-1.5 rounded-lg bg-primary px-3 py-2 text-xs font-semibold text-primary-foreground transition hover:bg-primary/90 disabled:opacity-50"
                    >
                      <Check className="h-3.5 w-3.5" />

                      {savingExpected
                        ? "Saving..."
                        : "Save"}
                    </button>

                    <button
                      type="button"
                      onClick={() =>
                        setEditingExpected(
                          false,
                        )
                      }
                      disabled={
                        savingExpected
                      }
                      className="inline-flex items-center justify-center rounded-lg border border-border px-3 py-2 text-xs font-semibold text-muted-foreground transition hover:bg-muted disabled:opacity-50"
                    >
                      <X className="h-3.5 w-3.5" />
                    </button>
                  </div>
                </div>
              )}
            </div>

            {/* Loaded Cartons */}
            {(() => {
              const kpi = kpis[2];
              const Icon = kpi.icon;

              return (
                <div
                  key={kpi.label}
                  className="glass glass-hover p-5"
                >
                  <div className="flex items-center justify-between gap-3">
                    <p className="text-xs font-medium text-muted-foreground">
                      {kpi.label}
                    </p>

                    <span
                      className={`grid h-8 w-8 shrink-0 place-items-center rounded-lg ${kpi.tone}`}
                    >
                      <Icon className="h-4 w-4" />
                    </span>
                  </div>

                  <p className="mt-3 text-2xl font-bold tracking-tight text-foreground">
                    {kpi.value}
                  </p>
                </div>
              );
            })()}

            {/* Remaining */}
            {(() => {
              const kpi = kpis[1];
              const Icon = kpi.icon;

              return (
                <div
                  key={kpi.label}
                  className="glass glass-hover p-5 ring-1 ring-primary/20"
                >
                  <div className="flex items-center justify-between gap-3">
                    <p className="text-xs font-medium text-muted-foreground">
                      {kpi.label}
                    </p>

                    <span
                      className={`grid h-8 w-8 shrink-0 place-items-center rounded-lg ${kpi.tone}`}
                    >
                      <Icon className="h-4 w-4" />
                    </span>
                  </div>

                  <p className="mt-3 text-3xl font-bold tracking-tight text-primary">
                    {kpi.value}
                  </p>
                </div>
              );
            })()}
          </div>

          {/* Live Monitor + Current Loading */}
          <div className="mt-4 grid grid-cols-1 gap-4 xl:grid-cols-3">
            <div className="xl:col-span-2">
              <LiveMonitor />
            </div>

            <section className="glass glass-hover p-5">
              <h2 className="text-base font-bold text-foreground">
                Current Loading
              </h2>

              <dl className="mt-4 space-y-2.5 text-sm">
                {[
                  [
                    "Truck Number",
                    activeTruck?.plate_number ??
                      "Scanning...",
                  ],

                  [
                    "Status",
                    (
                      activeTruck?.status ??
                      "waiting"
                    ).toUpperCase(),
                  ],

                  [
                    "Loading Bay",
                    "Bay 01",
                  ],

                  [
                    "Start Time",
                    activeTruck?.loading_started_at
                      ? new Date(
                          activeTruck.loading_started_at,
                        ).toLocaleTimeString(
                          [],
                          {
                            hour: "2-digit",
                            minute: "2-digit",
                          },
                        )
                      : "—",
                  ],

                  [
                    "Expected",
                    expected
                      ? String(expected)
                      : "—",
                  ],

                  [
                    "Loaded",
                    activeTruck
                      ? String(loaded)
                      : "—",
                  ],

                  [
                    "Remaining",
                    activeTruck
                      ? String(
                          remaining,
                        )
                      : "—",
                  ],

                  [
                    "Progress",
                    `${progress}%`,
                  ],
                ].map(([key, value]) => (
                  <div
                    key={key}
                    className="flex items-center justify-between gap-3"
                  >
                    <dt className="text-muted-foreground">
                      {key}
                    </dt>

                    <dd
                      className={`font-semibold ${
                        key === "Status"
                          ? "text-sky-600"
                          : "text-foreground"
                      }`}
                    >
                      {value}
                    </dd>
                  </div>
                ))}
              </dl>

              <div className="mt-5">
                <div className="h-2.5 w-full overflow-hidden rounded-full bg-slate-200/70">
                  <div
                    className="h-full rounded-full bg-primary transition-all duration-500"
                    style={{
                      width: `${progress}%`,
                    }}
                  />
                </div>

                <p className="mt-2 text-xs text-muted-foreground">
                  {loaded} / {expected} cartons
                </p>
              </div>

              <div className="mt-5 grid grid-cols-3 gap-2 border-t border-white/70 pt-4 text-center">
                {[
                  [
                    "Loading Rate",
                    `${loadingRate} /min`,
                  ],

                  [
                    "Est. Completion",
                    etaMinutes !== null
                      ? `${etaMinutes} min`
                      : "—",
                  ],

                  [
                    "Accuracy",
                    accuracy !== null &&
                    accuracy !== undefined
                      ? `${accuracy}%`
                      : "—",
                  ],
                ].map(([key, value]) => (
                  <div key={key}>
                    <p className="text-[11px] text-muted-foreground">
                      {key}
                    </p>

                    <p className="mt-0.5 text-sm font-bold text-foreground">
                      {value}
                    </p>
                  </div>
                ))}
              </div>
            </section>
          </div>

          {/* Live Count + Detection */}
          <div className="mt-4 grid grid-cols-1 gap-4 xl:grid-cols-3">
            <section className="glass glass-hover p-5">
              <div className="flex items-center justify-between gap-3">
                <h2 className="text-base font-bold text-foreground">
                  Live Carton Count
                </h2>

                <Boxes className="h-4 w-4 shrink-0 text-primary" />
              </div>

              <p className="mt-4 text-5xl font-extrabold tracking-tight text-primary">
                {loaded}
              </p>

              <p className="mt-1 text-sm text-muted-foreground">
                {loaded} of {expected} cartons loaded
              </p>

              <div className="mt-4 h-2.5 w-full overflow-hidden rounded-full bg-slate-200/70">
                <div
                  className="h-full rounded-full bg-primary transition-all duration-500"
                  style={{
                    width: `${progress}%`,
                  }}
                />
              </div>

              <div className="mt-4 grid grid-cols-3 gap-2 text-center text-xs">
                <div className="rounded-xl border border-white/70 bg-white/50 py-2 backdrop-blur-md">
                  <p className="text-muted-foreground">
                    Expected
                  </p>

                  <p className="mt-0.5 text-sm font-bold text-foreground">
                    {expected}
                  </p>
                </div>

                <div className="rounded-xl border border-white/70 bg-white/50 py-2 backdrop-blur-md">
                  <p className="text-muted-foreground">
                    Loaded
                  </p>

                  <p className="mt-0.5 text-sm font-bold text-emerald-600">
                    {loaded}
                  </p>
                </div>

                <div className="rounded-xl border border-white/70 bg-white/50 py-2 backdrop-blur-md">
                  <p className="text-muted-foreground">
                    Remaining
                  </p>

                  <p className="mt-0.5 text-sm font-bold text-amber-600">
                    {remaining}
                  </p>
                </div>
              </div>

              <button
                disabled
                title="Cartons are counted automatically by the detection pipeline"
                className="mt-4 inline-flex w-full cursor-not-allowed items-center justify-center gap-2 rounded-xl bg-primary/50 py-2.5 text-sm font-semibold text-primary-foreground/80"
              >
                <Plus className="h-4 w-4" />
                Counted automatically
              </button>
            </section>

            <div className="grid grid-cols-1 gap-4 sm:grid-cols-3 xl:col-span-2 xl:grid-cols-3">
              {detectionCards.map(
                (card) => (
                  <section
                    key={card.title}
                    className="glass glass-hover h-fit p-5"
                  >
                    <p className="text-xs font-medium text-muted-foreground">
                      {card.title}
                    </p>

                    <p className="mt-2 inline-flex items-center gap-1.5 text-sm font-semibold text-emerald-600">
                      <span className="h-1.5 w-1.5 rounded-full bg-emerald-500" />
                      {card.state}
                    </p>

                    {card.detail && (
                      <p className="mt-1.5 text-sm font-bold text-foreground">
                        {card.detail}
                      </p>
                    )}

                    <p className="mt-1 text-xs text-muted-foreground">
                      {card.conf}
                    </p>
                  </section>
                ),
              )}

              {/* Recent Activity */}
              <section className="glass glass-hover p-5 sm:col-span-3">
                <h2 className="text-base font-bold text-foreground">
                  Recent Activity
                </h2>

                <ul className="mt-3 max-h-64 space-y-2 overflow-y-auto pr-1">
                  {events.length ===
                    0 && (
                    <li className="text-sm text-muted-foreground">
                      No activity yet.
                    </li>
                  )}

                  {events.map(
                    (event) => (
                      <li
                        key={event.id}
                        className="flex items-center gap-3 rounded-xl border border-white/70 bg-white/50 px-3 py-2 text-sm backdrop-blur-md"
                      >
                        <span className="shrink-0 font-mono text-xs text-muted-foreground">
                          {new Date(
                            event.created_at,
                          ).toLocaleTimeString(
                            "en-GB",
                            {
                              hour12:
                                false,
                            },
                          )}
                        </span>

                        <span className="min-w-0 truncate text-secondary-foreground">
                          {event.event_type ===
                          "carton_added"
                            ? "Carton loaded"
                            : event.note ??
                              event.event_type}
                        </span>
                      </li>
                    ),
                  )}
                </ul>
              </section>
            </div>
          </div>

          {/* ================================================== */}
          {/* RECENT LOADING SESSIONS                            */}
          {/* ================================================== */}

          <section className="glass glass-hover mt-4 p-5">
            <div className="flex items-center justify-between gap-3">
              <div>
                <h2 className="text-base font-bold text-foreground">
                  Recent Loading Sessions
                </h2>

                <p className="mt-0.5 text-xs text-muted-foreground">
                  {selectedDate ===
                  new Date().toLocaleDateString(
                    "en-CA",
                  )
                    ? "Today"
                    : selectedDate}
                </p>
              </div>

              <RecentSessionsToolbar
                trucks={trucks}
                selectedDate={
                  selectedDate
                }
                onDateChange={
                  setSelectedDate
                }
              />
            </div>

            <div className="mt-4 overflow-x-auto">
              <table className="w-full min-w-[560px] text-left text-sm">
                <thead>
                  <tr className="text-xs uppercase tracking-wide text-muted-foreground">
                    <th className="pb-3 font-medium">
                      Truck Number
                    </th>

                    <th className="pb-3 font-medium">
                      Expected
                    </th>

                    <th className="pb-3 font-medium">
                      Loaded
                    </th>

                    <th className="pb-3 font-medium">
                      Start Time
                    </th>

                    <th className="pb-3 font-medium">
                      Status
                    </th>
                  </tr>
                </thead>

                <tbody>
                  {filteredTrucks.map(
                    (truck) => (
                      <tr
                        key={truck.id}
                        className="border-t border-white/70"
                      >
                        <td className="py-3 font-semibold text-foreground">
                          {truck.plate_number ??
                            "Scanning..."}
                        </td>

                        <td className="py-3 text-secondary-foreground">
                          {
                            truck.expected_count
                          }
                        </td>

                        <td className="py-3 text-secondary-foreground">
                          {
                            truck.loaded_count
                          }
                        </td>

                        <td className="py-3 text-secondary-foreground">
                          {truck.loading_started_at
                            ? new Date(
                                truck.loading_started_at,
                              ).toLocaleTimeString(
                                [],
                                {
                                  hour: "2-digit",
                                  minute:
                                    "2-digit",
                                },
                              )
                            : "—"}
                        </td>

                        <td className="py-3">
                          <span
                            className={`inline-flex rounded-full border px-2.5 py-1 text-[11px] font-semibold capitalize backdrop-blur-md ${statusBadge(
                              truck.status,
                            )}`}
                          >
                            {
                              truck.status
                            }
                          </span>
                        </td>
                      </tr>
                    ),
                  )}

                  {filteredTrucks.length ===
                    0 && (
                    <tr>
                      <td
                        colSpan={5}
                        className="py-6 text-center text-muted-foreground"
                      >
                        No loading sessions for{" "}
                        {selectedDate}.
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