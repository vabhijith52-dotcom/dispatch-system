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
  Truck,
  Check,
  Pencil,
  X,
} from "lucide-react";

import {
  Bar,
  BarChart,
  CartesianGrid,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts";

import { GlassBackdrop } from "@/components/GlassBackdrop";

import {
  DashboardSidebar,
} from "@/components/dashboard/DashboardSidebar";

import {
  LiveMonitor,
} from "@/components/dashboard/LiveMonitor";

import {
  RecentSessionsToolbar,
} from "@/components/dashboard/RecentSessionsToolbar";

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
      navigate({
        to: "/",
      });
    }
  }, [navigate]);

  /*
   * ==================================================
   * TRUCK DATA
   * ==================================================
   */

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

  /*
   * ==================================================
   * TRUCK EVENTS
   * ==================================================
   */

  const eventsQuery = useQuery({
    queryKey: [
      "truck-events",
      activeTruck?.id,
    ],

    queryFn: () =>
      fetchTruckEvents(
        activeTruck!.id,
      ),

    enabled:
      !!activeTruck,

    refetchInterval: 3000,
  });

  const events =
    eventsQuery.data ?? [];

  /*
   * ==================================================
   * DETECTION STATUS
   * ==================================================
   */

  const detectionQuery = useQuery({
    queryKey: [
      "detection-status",
    ],

    queryFn:
      fetchDetectionStatus,

    refetchInterval: 3000,
  });

  const detection =
    detectionQuery.data;

  /*
   * ==================================================
   * WEBSOCKET LIVE UPDATES
   * ==================================================
   */

  const wsRef =
    useRef<WebSocket | null>(
      null,
    );

  useEffect(() => {
    let cancelled = false;

    let retryDelay = 1000;

    let retryTimer:
      | ReturnType<
          typeof setTimeout
        >
      | undefined;

    function connect() {
      if (cancelled) {
        return;
      }

      const ws =
        new WebSocket(
          WS_URL,
        );

      wsRef.current = ws;

      ws.onopen = () => {
        retryDelay = 1000;
      };

      ws.onmessage = () => {
        queryClient.invalidateQueries({
          queryKey: [
            "trucks",
          ],
        });

        queryClient.invalidateQueries({
          queryKey: [
            "truck-events",
          ],
        });

        queryClient.invalidateQueries({
          queryKey: [
            "detection-status",
          ],
        });
      };

      ws.onclose = () => {
        if (cancelled) {
          return;
        }

        retryTimer =
          setTimeout(
            connect,
            retryDelay,
          );

        retryDelay =
          Math.min(
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

  /*
   * ==================================================
   * ACTIVE TRUCK VALUES
   * ==================================================
   */

  const expected =
    activeTruck?.expected_count ??
    0;

  const loaded =
    activeTruck?.loaded_count ??
    0;

  const remaining =
    activeTruck?.remaining ??
    0;

  const progress =
    expected > 0
      ? Math.round(
          (loaded /
            expected) *
            100,
        )
      : 0;

  /*
   * ==================================================
   * LOADING RATE / ETA
   * ==================================================
   */

  const now =
    Date.now();

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

  /*
   * ==================================================
   * EXPECTED CARTON EDITING
   * ==================================================
   */

  function startEditingExpected() {
    setExpectedInput(
      String(expected),
    );

    setEditingExpected(
      true,
    );
  }

  async function saveExpectedCount() {
    if (!activeTruck) {
      return;
    }

    const value =
      Number(
        expectedInput,
      );

    if (
      !Number.isFinite(
        value,
      ) ||
      value < 0
    ) {
      return;
    }

    setSavingExpected(
      true,
    );

    try {
      await updateTruck(
        activeTruck.id,
        {
          expected_count:
            value,
        },
      );

      await queryClient.invalidateQueries(
        {
          queryKey: [
            "trucks",
          ],
        },
      );

      setEditingExpected(
        false,
      );
    } finally {
      setSavingExpected(
        false,
      );
    }
  }

  /*
   * ==================================================
   * LOGOUT
   * ==================================================
   */

  function handleLogout() {
    signOut();

    navigate({
      to: "/",
    });
  }

  /*
   * ==================================================
   * KPI DATA
   * ==================================================
   *
   * Required order:
   * Expected → Loaded → Remaining
   */

  const kpis = [
    {
      label:
        "Expected Cartons",

      value:
        activeTruck
          ? String(
              expected,
            )
          : "—",

      icon: Boxes,

      tone:
        "text-sky-600 bg-sky-50/80",
    },

    {
      label:
        "Loaded Cartons",

      value:
        activeTruck
          ? String(
              loaded,
            )
          : "—",

      icon:
        PackageCheck,

      tone:
        "text-emerald-600 bg-emerald-50/80",

      highlight:
        true,
    },

    {
      label:
        "Remaining",

      value:
        activeTruck
          ? String(
              remaining,
            )
          : "—",

      icon:
        PackageMinus,

      tone:
        "text-amber-600 bg-amber-50/80",
    },
  ];

  /*
   * ==================================================
   * DETECTION CARDS
   * ==================================================
   */

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
      title:
        "Truck Detection",

      state:
        truckDet?.detected
          ? "Detected"
          : "Idle",

      detail:
        null as
          | string
          | null,

      conf: truckDet
        ? `${truckDet.confidence}% confidence`
        : "no recent detection",
    },

    {
      title:
        "License Plate",

      state:
        plateDet?.detected
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
      title:
        "Carton Detection",

      state:
        cartonDet?.detected
          ? "Active"
          : "Idle",

      detail:
        null as
          | string
          | null,

      conf: cartonDet
        ? `${cartonDet.confidence}% confidence`
        : "no recent detection",
    },
  ];

  /*
   * ==================================================
   * DATE FILTERED TRUCKS
   * ==================================================
   */

  const filteredTrucks =
    trucks
      .filter(
        (truck) => {
          const date =
            new Date(
              truck.loading_started_at ??
                truck.created_at,
            );

          return (
            date.toLocaleDateString(
              "en-CA",
            ) ===
            selectedDate
          );
        },
      )
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

  /*
   * ==================================================
   * DAILY GRAPH DATA
   * ==================================================
   */

  const dailyLoadingChartData =
    [...filteredTrucks]
      .reverse()
      .map(
        (
          truck,
          index,
        ) => ({
          truck:
            truck.plate_number ??
            truck.truck_code ??
            `Truck ${index + 1}`,

          loaded:
            truck.loaded_count,

          expected:
            truck.expected_count,
        }),
      );

  /*
   * ==================================================
   * DATE DISPLAY
   * ==================================================
   */

  const todayKey =
    new Date().toLocaleDateString(
      "en-CA",
    );

  const isToday =
    selectedDate ===
    todayKey;

  const selectedDateLabel =
    new Date(
      `${selectedDate}T00:00:00`,
    ).toLocaleDateString(
      "en-US",
      {
        month:
          "short",

        day:
          "numeric",

        year:
          "numeric",
      },
    );

  /*
   * ==================================================
   * RENDER
   * ==================================================
   */

  return (
    <div className="relative min-h-screen">

      <GlassBackdrop />

      <div className="flex min-h-screen gap-0 lg:gap-6 lg:p-6">

        {/* ================================================= */}
        {/* DESKTOP SIDEBAR                                   */}
        {/* ================================================= */}

        <div className="hidden lg:block">

          <div className="sticky top-6 h-[calc(100vh-3rem)]">

            <DashboardSidebar
              onLogout={
                handleLogout
              }
            />

          </div>

        </div>

        {/* ================================================= */}
        {/* MOBILE MENU                                       */}
        {/* ================================================= */}

        {menuOpen && (
          <div className="fixed inset-0 z-50 lg:hidden">

            <button
              aria-label="Close menu overlay"
              onClick={() =>
                setMenuOpen(
                  false,
                )
              }
              className="absolute inset-0 bg-slate-900/20 backdrop-blur-sm"
            />

            <div className="absolute inset-y-0 left-0">

              <DashboardSidebar
                onLogout={
                  handleLogout
                }

                onClose={() =>
                  setMenuOpen(
                    false,
                  )
                }
              />

            </div>

          </div>
        )}

        <main className="min-w-0 flex-1 px-4 py-6 sm:px-6 lg:px-0 lg:py-0">

          {/* ================================================= */}
          {/* HEADER                                            */}
          {/* ================================================= */}

          <header className="grid grid-cols-[minmax(0,1fr)_auto] items-center gap-4 sm:flex sm:justify-between">

            <div className="flex min-w-0 items-center gap-3">

              <button
                onClick={() =>
                  setMenuOpen(
                    true,
                  )
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

          {/* ================================================= */}
          {/* KPI CARDS                                         */}
          {/* ================================================= */}

          <div className="mt-6 grid grid-cols-1 gap-4 sm:grid-cols-2 xl:grid-cols-4">

            {/* Truck Number */}
            <div className="glass glass-hover p-5">

              <div className="flex items-center justify-between gap-3">

                <p className="text-xs font-medium text-muted-foreground">
                  Truck Number
                </p>

                <span className="grid h-8 w-8 shrink-0 place-items-center rounded-lg bg-sky-50/80 text-sky-600">

                  <Truck className="h-4 w-4" />

                </span>

              </div>

              <p className="mt-3 text-2xl font-bold tracking-tight text-foreground">
                {
                  activeTruck?.plate_number ??
                  "Scanning..."
                }
              </p>

            </div>

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
                    onChange={(
                      event,
                    ) =>
                      setExpectedInput(
                        event
                          .target
                          .value,
                      )
                    }
                    onKeyDown={(
                      event,
                    ) => {

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
            <div className="glass glass-hover p-5">

              <div className="flex items-center justify-between gap-3">

                <p className="text-xs font-medium text-muted-foreground">
                  Loaded Cartons
                </p>

                <span className="grid h-8 w-8 shrink-0 place-items-center rounded-lg bg-emerald-50/80 text-emerald-600">

                  <PackageCheck className="h-4 w-4" />

                </span>

              </div>

              <p className="mt-3 text-2xl font-bold tracking-tight text-foreground">
                {
                  activeTruck
                    ? loaded
                    : "—"
                }
              </p>

            </div>

            {/* Remaining */}
            <div className="glass glass-hover p-5 ring-1 ring-primary/20">

              <div className="flex items-center justify-between gap-3">

                <p className="text-xs font-medium text-muted-foreground">
                  Remaining
                </p>

                <span className="grid h-8 w-8 shrink-0 place-items-center rounded-lg bg-amber-50/80 text-amber-600">

                  <PackageMinus className="h-4 w-4" />

                </span>

              </div>

              <p className="mt-3 text-3xl font-bold tracking-tight text-primary">
                {
                  activeTruck
                    ? remaining
                    : "—"
                }
              </p>

            </div>

          </div>

          {/* ================================================= */}
          {/* LIVE MONITOR + CURRENT LOADING                    */}
          {/* ================================================= */}

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
                            hour:
                              "2-digit",
                            minute:
                              "2-digit",
                          },
                        )
                      : "—",
                  ],

                  [
                    "Expected",
                    expected
                      ? String(
                          expected,
                        )
                      : "—",
                  ],

                  [
                    "Loaded",
                    activeTruck
                      ? String(
                          loaded,
                        )
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
                ].map(
                  ([
                    key,
                    value,
                  ]) => (

                    <div
                      key={key}
                      className="flex items-center justify-between gap-3"
                    >

                      <dt className="text-muted-foreground">
                        {key}
                      </dt>

                      <dd
                        className={`font-semibold ${
                          key ===
                          "Status"
                            ? "text-sky-600"
                            : "text-foreground"
                        }`}
                      >
                        {value}
                      </dd>

                    </div>

                  ),
                )}

              </dl>

              <div className="mt-5">

                <div className="h-2.5 w-full overflow-hidden rounded-full bg-slate-200/70">

                  <div
                    className="h-full rounded-full bg-primary transition-all duration-500"
                    style={{
                      width: `${Math.min(
                        progress,
                        100,
                      )}%`,
                    }}
                  />

                </div>

                <p className="mt-2 text-xs text-muted-foreground">
                  {loaded} /{" "}
                  {expected} cartons
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
                    etaMinutes !==
                    null
                      ? `${etaMinutes} min`
                      : "—",
                  ],

                  [
                    "Accuracy",
                    accuracy !==
                      null &&
                    accuracy !==
                      undefined
                      ? `${accuracy}%`
                      : "—",
                  ],
                ].map(
                  ([
                    key,
                    value,
                  ]) => (

                    <div
                      key={key}
                    >

                      <p className="text-[11px] text-muted-foreground">
                        {key}
                      </p>

                      <p className="mt-0.5 text-sm font-bold text-foreground">
                        {value}
                      </p>

                    </div>

                  ),
                )}

              </div>

            </section>

          </div>

          {/* ================================================= */}
          {/* DAILY SUMMARY + DETECTION                         */}
          {/* ================================================= */}

          <div className="mt-4 grid grid-cols-1 gap-4 xl:grid-cols-3">

            {/* ================================================= */}
            {/* DAILY LOADING SUMMARY                             */}
            {/* ================================================= */}

            <section className="glass glass-hover p-5">

              <div className="flex items-center justify-between gap-3">

                <div>

                  <h2 className="text-base font-bold text-foreground">
                    Daily Loading Summary
                  </h2>

                  <p className="mt-0.5 text-xs text-muted-foreground">
                    {isToday
                      ? "Today"
                      : selectedDateLabel}
                  </p>

                </div>

                <Boxes className="h-5 w-5 shrink-0 text-primary" />

              </div>

              {/* ================================================= */}
              {/* GRAPH                                             */}
              {/* ================================================= */}

              <div className="mt-5 h-[240px] w-full">

                {dailyLoadingChartData.length >
                0 ? (

                  <ResponsiveContainer
                    width="100%"
                    height="100%"
                  >

                    <BarChart
                      data={
                        dailyLoadingChartData
                      }
                      margin={{
                        top: 10,
                        right: 10,
                        left: 0,
                        bottom: 5,
                      }}
                      barGap={4}
                    >

                      <CartesianGrid
                        vertical={false}
                        stroke="#e5e7eb"
                        strokeDasharray="3 3"
                      />

                      <XAxis
                        dataKey="truck"
                        tickLine={
                          false
                        }
                        axisLine={{
                          stroke:
                            "#94a3b8",
                        }}
                        fontSize={10}
                        tick={{
                          fill:
                            "#64748b",
                        }}
                      />

                      <YAxis
                        tickLine={
                          false
                        }
                        axisLine={{
                          stroke:
                            "#94a3b8",
                        }}
                        fontSize={10}
                        allowDecimals={
                          false
                        }
                        tick={{
                          fill:
                            "#64748b",
                        }}
                      />

                      {/* IMPORTANT:
                          cursor={false} prevents
                          the chart from turning
                          black/dark on hover.
                      */}
                      <Tooltip
                        cursor={
                          false
                        }
                        content={({
                          active,
                          payload,
                        }) => {

                          if (
                            !active ||
                            !payload ||
                            payload.length ===
                              0
                          ) {
                            return null;
                          }

                          const data =
                            payload[0]
                              ?.payload;

                          if (!data) {
                            return null;
                          }

                          return (
                            <div
                              className="rounded-xl border border-slate-200 bg-white px-3 py-2 shadow-lg"
                              style={{
                                color:
                                  "#0f172a",
                              }}
                            >

                              <p className="mb-1 text-xs font-semibold text-slate-900">
                                {
                                  data.truck
                                }
                              </p>

                              <div className="space-y-1">

                                <p className="text-xs text-blue-600">

                                  Loaded:{" "}

                                  <span className="font-semibold">

                                    {
                                      data.loaded
                                    }{" "}
                                    cartons

                                  </span>

                                </p>

                                <p className="text-xs text-slate-500">

                                  Expected:{" "}

                                  <span className="font-semibold text-slate-700">

                                    {
                                      data.expected
                                    }{" "}
                                    cartons

                                  </span>

                                </p>

                              </div>

                            </div>
                          );
                        }}
                      />

                      {/* Loaded */}
                      <Bar
                        dataKey="loaded"
                        name="Loaded"
                        fill="#1976D2"
                        radius={[
                          4,
                          4,
                          0,
                          0,
                        ]}
                        maxBarSize={
                          28
                        }
                      />

                      {/* Expected */}
                      <Bar
                        dataKey="expected"
                        name="Expected"
                        fill="#CBD5E1"
                        radius={[
                          4,
                          4,
                          0,
                          0,
                        ]}
                        maxBarSize={
                          28
                        }
                      />

                    </BarChart>

                  </ResponsiveContainer>

                ) : (

                  <div className="flex h-full items-center justify-center rounded-xl border border-dashed border-slate-200">

                    <div className="text-center">

                      <Boxes className="mx-auto h-8 w-8 text-slate-300" />

                      <p className="mt-2 text-sm font-medium text-slate-500">
                        No loading sessions
                      </p>

                      <p className="mt-1 text-xs text-slate-400">
                        No trucks processed on this date.
                      </p>

                    </div>

                  </div>

                )}

              </div>

              {/* ================================================= */}
              {/* GRAPH LEGEND                                      */}
              {/* ================================================= */}

              {dailyLoadingChartData.length >
                0 && (

                <div className="mt-3 flex items-center justify-center gap-5 text-[11px] text-slate-500">

                  <div className="flex items-center gap-1.5">

                    <span
                      className="h-2.5 w-2.5 rounded-sm"
                      style={{
                        backgroundColor:
                          "#1976D2",
                      }}
                    />

                    <span>
                      Loaded
                    </span>

                  </div>

                  <div className="flex items-center gap-1.5">

                    <span
                      className="h-2.5 w-2.5 rounded-sm"
                      style={{
                        backgroundColor:
                          "#CBD5E1",
                      }}
                    />

                    <span>
                      Expected
                    </span>

                  </div>

                </div>

              )}

            </section>

            {/* ================================================= */}
            {/* DETECTION CARDS                                   */}
            {/* ================================================= */}

            <div className="grid grid-cols-1 gap-4 sm:grid-cols-3 xl:col-span-2 xl:grid-cols-3">

              {detectionCards.map(
                (card) => (

                  <section
                    key={
                      card.title
                    }
                    className="glass glass-hover h-fit p-5"
                  >

                    <p className="text-xs font-medium text-muted-foreground">
                      {
                        card.title
                      }
                    </p>

                    <p className="mt-2 inline-flex items-center gap-1.5 text-sm font-semibold text-emerald-600">

                      <span className="h-1.5 w-1.5 rounded-full bg-emerald-500" />

                      {
                        card.state
                      }

                    </p>

                    {card.detail && (

                      <p className="mt-1.5 text-sm font-bold text-foreground">
                        {
                          card.detail
                        }
                      </p>

                    )}

                    <p className="mt-1 text-xs text-muted-foreground">
                      {
                        card.conf
                      }
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
                        key={
                          event.id
                        }
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

          {/* ================================================= */}
          {/* RECENT LOADING SESSIONS                            */}
          {/* ================================================= */}

          <section className="glass glass-hover mt-4 p-5">

            <div className="flex items-center justify-between gap-3">

              <div>

                <h2 className="text-base font-bold text-foreground">
                  Recent Loading Sessions
                </h2>

                <p className="mt-0.5 text-xs text-muted-foreground">
                  {isToday
                    ? "Today"
                    : selectedDateLabel}
                </p>

              </div>

              <RecentSessionsToolbar
                trucks={
                  trucks
                }
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
                        key={
                          truck.id
                        }
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
                                  hour:
                                    "2-digit",
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
                        colSpan={
                          5
                        }
                        className="py-6 text-center text-muted-foreground"
                      >
                        No loading sessions for{" "}
                        {
                          selectedDate
                        }.
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