import { useMemo, useState } from "react";
import { BarChart3, CalendarDays, Download } from "lucide-react";
import {
  CartesianGrid,
  Line,
  LineChart,
  XAxis,
  YAxis,
} from "recharts";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import {
  ChartContainer,
  ChartTooltip,
  ChartTooltipContent,
  type ChartConfig,
} from "@/components/ui/chart";
import type { Truck } from "@/lib/api";
import * as XLSX from "xlsx";

interface Props {
  trucks: Truck[];
  selectedDate: string;
  onDateChange: (date: string) => void;
}

function sessionDate(truck: Truck): Date {
  return new Date(
    truck.loading_started_at ?? truck.created_at,
  );
}

function localDateKey(date: Date): string {
  return date.toLocaleDateString("en-CA");
}

function formatDateTime(date: Date): string {
  return date.toLocaleString([], {
    year: "numeric",
    month: "short",
    day: "2-digit",
    hour: "2-digit",
    minute: "2-digit",
  });
}

function formatTime(date: Date): string {
  return date.toLocaleTimeString([], {
    hour: "2-digit",
    minute: "2-digit",
  });
}

function loadingMinutes(truck: Truck): number | null {
  if (!truck.loading_started_at) return null;

  const start = new Date(
    truck.loading_started_at,
  ).getTime();

  const end = new Date(
    truck.updated_at,
  ).getTime();

  const minutes = (end - start) / 60000;

  return minutes > 0 ? minutes : null;
}

const chartConfig: ChartConfig = {
  loaded: {
    label: "Cartons Loaded",
    color: "hsl(var(--primary))",
  },
};

export function RecentSessionsToolbar({
  trucks,
  selectedDate,
  onDateChange,
}: Props) {
  const [calendarOpen, setCalendarOpen] =
    useState(false);

  const [summaryOpen, setSummaryOpen] =
    useState(false);

  const [exportOpen, setExportOpen] =
    useState(false);

  const todayKey = localDateKey(new Date());

  const [fromDate, setFromDate] =
    useState(todayKey);

  const [toDate, setToDate] =
    useState(todayKey);

  /*
   * Trucks belonging to the selected calendar date.
   */
  const selectedDayTrucks = useMemo(() => {
    return trucks
      .filter(
        (truck) =>
          localDateKey(sessionDate(truck)) ===
          selectedDate,
      )
      .sort(
        (a, b) =>
          sessionDate(b).getTime() -
          sessionDate(a).getTime(),
      );
  }, [trucks, selectedDate]);

  /*
   * Today's operational summary.
   *
   * Mismatch is intentionally not shown as
   * a separate metric.
   */
  const summary = useMemo(() => {
    const todays = trucks.filter(
      (truck) =>
        localDateKey(sessionDate(truck)) ===
        todayKey,
    );

    const completed = todays.filter(
      (truck) => truck.status === "completed",
    ).length;

    const loadingNow = todays.filter(
      (truck) => truck.status === "loading",
    ).length;

    const totalExpected = todays.reduce(
      (sum, truck) =>
        sum + truck.expected_count,
      0,
    );

    const totalLoaded = todays.reduce(
      (sum, truck) =>
        sum + truck.loaded_count,
      0,
    );

    const avgProgress =
      totalExpected > 0
        ? Math.round(
            (totalLoaded / totalExpected) * 100,
          )
        : 0;

    /*
     * Average loading time is calculated only
     * from completed trucks.
     */
    const durations = todays
      .filter(
        (truck) => truck.status === "completed",
      )
      .map(loadingMinutes)
      .filter(
        (minutes): minutes is number =>
          minutes !== null,
      );

    const avgLoadingTime =
      durations.length > 0
        ? durations.reduce(
            (a, b) => a + b,
            0,
          ) / durations.length
        : 0;

    const rates = todays
      .map((truck) => {
        const minutes = loadingMinutes(truck);

        if (!minutes || minutes <= 0) {
          return null;
        }

        return truck.loaded_count / minutes;
      })
      .filter(
        (rate): rate is number =>
          rate !== null,
      );

    const avgRate =
      rates.length > 0
        ? rates.reduce(
            (a, b) => a + b,
            0,
          ) / rates.length
        : 0;

    /*
     * Cumulative cartons loaded over time.
     */
    const timeline = [...todays]
      .sort(
        (a, b) =>
          sessionDate(a).getTime() -
          sessionDate(b).getTime(),
      )
      .reduce<
        { time: string; loaded: number }[]
      >((acc, truck) => {
        const previous =
          acc.length > 0
            ? acc[acc.length - 1].loaded
            : 0;

        acc.push({
          time: formatTime(
            sessionDate(truck),
          ),
          loaded:
            previous + truck.loaded_count,
        });

        return acc;
      }, []);

    return {
      total: todays.length,
      completed,
      loadingNow,
      totalExpected,
      totalLoaded,
      avgProgress,
      avgLoadingTime,
      avgRate,
      timeline,
    };
  }, [trucks, todayKey]);

  /*
   * Export selected date range as a real XLSX file.
   */
  function downloadExcel() {
    const from = new Date(
      `${fromDate}T00:00:00`,
    );

    const to = new Date(
      `${toDate}T23:59:59`,
    );

    const rows = trucks
      .filter((truck) => {
        const date = sessionDate(truck);

        return date >= from && date <= to;
      })
      .sort(
        (a, b) =>
          sessionDate(a).getTime() -
          sessionDate(b).getTime(),
      );

    /*
     * Proper Excel table structure.
     */
    const excelRows = rows.map(
      (truck, index) => ({
        "S.No": index + 1,
        "Truck Number": truck.truck_code,
        "Plate Number":
          truck.plate_number ?? "Scanning...",
        "Date": sessionDate(truck).toLocaleDateString(),
        "Time": sessionDate(truck).toLocaleTimeString(
          [],
          {
            hour: "2-digit",
            minute: "2-digit",
          },
        ),
        "Expected Cartons":
          truck.expected_count,
        "Loaded Cartons":
          truck.loaded_count,
        "Remaining Cartons":
          truck.remaining,
        Status: truck.status,
      }),
    );

    /*
     * If no trucks exist for the selected date,
     * don't generate an empty file.
     */
    if (excelRows.length === 0) {
      return;
    }

    /*
     * Create workbook.
     */
    const worksheet =
      XLSX.utils.json_to_sheet(excelRows);

    /*
     * Set readable column widths.
     */
    worksheet["!cols"] = [
      { wch: 8 },
      { wch: 18 },
      { wch: 18 },
      { wch: 14 },
      { wch: 12 },
      { wch: 20 },
      { wch: 18 },
      { wch: 20 },
      { wch: 15 },
    ];

    /*
     * Freeze the header row.
     */
    worksheet["!freeze"] = {
      xSplit: 0,
      ySplit: 1,
    };

    /*
     * Create workbook and add worksheet.
     */
    const workbook =
      XLSX.utils.book_new();

    XLSX.utils.book_append_sheet(
      workbook,
      worksheet,
      "Loading Sessions",
    );

    /*
     * Download proper .xlsx file.
     */
    XLSX.writeFile(
      workbook,
      `loading-sessions-${fromDate}_to_${toDate}.xlsx`,
    );
  }

  const exportCount = useMemo(() => {
    const from = new Date(
      `${fromDate}T00:00:00`,
    );

    const to = new Date(
      `${toDate}T23:59:59`,
    );

    return trucks.filter((truck) => {
      const date = sessionDate(truck);

      return date >= from && date <= to;
    }).length;
  }, [trucks, fromDate, toDate]);

  return (
    <>
      {/* ====================================================== */}
      {/* TOOLBAR                                                 */}
      {/* ====================================================== */}

      <div className="flex items-center gap-1.5">
        {/* Calendar */}
        <button
          type="button"
          onClick={() =>
            setCalendarOpen(true)
          }
          aria-label="Filter loading sessions by date"
          title="Filter loading sessions by date"
          className="grid h-8 w-8 place-items-center rounded-lg bg-slate-100/80 text-slate-600 transition hover:bg-slate-200/80"
        >
          <CalendarDays className="h-4 w-4" />
        </button>

        {/* Operational Summary */}
        <button
          type="button"
          onClick={() =>
            setSummaryOpen(true)
          }
          aria-label="Today's operational summary"
          title="Today's operational summary"
          className="grid h-8 w-8 place-items-center rounded-lg bg-slate-100/80 text-slate-600 transition hover:bg-slate-200/80"
        >
          <BarChart3 className="h-4 w-4" />
        </button>

        {/* Export */}
        <button
          type="button"
          onClick={() =>
            setExportOpen(true)
          }
          aria-label="Export loading sessions"
          title="Export loading sessions"
          className="grid h-8 w-8 place-items-center rounded-lg bg-slate-100/80 text-slate-600 transition hover:bg-slate-200/80"
        >
          <Download className="h-4 w-4" />
        </button>
      </div>

      {/* ====================================================== */}
      {/* CALENDAR                                                 */}
      {/* ====================================================== */}

      <Dialog
        open={calendarOpen}
        onOpenChange={setCalendarOpen}
      >
        <DialogContent className="max-w-sm">
          <DialogHeader>
            <DialogTitle>
              Select Loading Session Date
            </DialogTitle>
          </DialogHeader>

          <div className="space-y-4">
            <div>
              <label className="text-xs font-medium text-muted-foreground">
                Date
              </label>

              <input
                type="date"
                value={selectedDate}
                onChange={(event) => {
                  onDateChange(
                    event.target.value,
                  );

                  setCalendarOpen(false);
                }}
                className="mt-1 w-full rounded-lg border border-input bg-background px-3 py-2 text-sm text-foreground outline-none focus:ring-2 focus:ring-primary/30"
              />
            </div>

            <div className="rounded-lg bg-muted/40 p-3 text-sm">
              <span className="text-muted-foreground">
                Loading sessions:
              </span>

              <span className="ml-2 font-semibold text-foreground">
                {selectedDayTrucks.length}
              </span>
            </div>

            <button
              type="button"
              onClick={() => {
                onDateChange(todayKey);
                setCalendarOpen(false);
              }}
              className="w-full rounded-lg border border-border px-3 py-2 text-sm font-medium transition hover:bg-muted"
            >
              Show Today
            </button>
          </div>
        </DialogContent>
      </Dialog>

      {/* ====================================================== */}
      {/* OPERATIONAL SUMMARY                                     */}
      {/* ====================================================== */}

      <Dialog
        open={summaryOpen}
        onOpenChange={setSummaryOpen}
      >
        <DialogContent className="max-h-[85vh] max-w-lg overflow-y-auto">
          <DialogHeader>
            <DialogTitle>
              Today's Operational Summary
            </DialogTitle>
          </DialogHeader>

          <div className="grid grid-cols-2 gap-3">
            <div className="rounded-xl border border-border p-3">
              <p className="text-xs text-muted-foreground">
                Total Trucks
              </p>

              <p className="text-xl font-bold text-foreground">
                {summary.total}
              </p>
            </div>

            <div className="rounded-xl border border-border p-3">
              <p className="text-xs text-muted-foreground">
                Completed
              </p>

              <p className="text-xl font-bold text-foreground">
                {summary.completed}
              </p>
            </div>

            <div className="rounded-xl border border-border p-3">
              <p className="text-xs text-muted-foreground">
                Loading
              </p>

              <p className="text-xl font-bold text-foreground">
                {summary.loadingNow}
              </p>
            </div>

            <div className="rounded-xl border border-border p-3">
              <p className="text-xs text-muted-foreground">
                Avg. Progress
              </p>

              <p className="text-xl font-bold text-foreground">
                {summary.avgProgress}%
              </p>
            </div>

            <div className="rounded-xl border border-border p-3">
              <p className="text-xs text-muted-foreground">
                Expected Cartons
              </p>

              <p className="text-xl font-bold text-foreground">
                {summary.totalExpected}
              </p>
            </div>

            <div className="rounded-xl border border-border p-3">
              <p className="text-xs text-muted-foreground">
                Loaded Cartons
              </p>

              <p className="text-xl font-bold text-foreground">
                {summary.totalLoaded}
              </p>
            </div>

            <div className="rounded-xl border border-border p-3">
              <p className="text-xs text-muted-foreground">
                Avg. Loading Rate
              </p>

              <p className="text-xl font-bold text-foreground">
                {summary.avgRate > 0
                  ? `${summary.avgRate.toFixed(1)} /min`
                  : "—"}
              </p>
            </div>

            <div className="rounded-xl border border-border p-3">
              <p className="text-xs text-muted-foreground">
                Avg. Loading Time
              </p>

              <p className="text-xl font-bold text-foreground">
                {summary.avgLoadingTime > 0
                  ? `${summary.avgLoadingTime.toFixed(1)} min`
                  : "—"}
              </p>
            </div>
          </div>

          <div className="mt-4">
            <p className="mb-2 text-xs font-medium text-muted-foreground">
              Cartons Loaded Over Time
            </p>

            {summary.timeline.length > 0 ? (
              <ChartContainer
                config={chartConfig}
                className="h-40 w-full"
              >
                <LineChart
                  data={summary.timeline}
                >
                  <CartesianGrid
                    vertical={false}
                    strokeDasharray="3 3"
                  />

                  <XAxis
                    dataKey="time"
                    tickLine={false}
                    axisLine={false}
                    fontSize={11}
                  />

                  <YAxis
                    tickLine={false}
                    axisLine={false}
                    fontSize={11}
                    allowDecimals={false}
                  />

                  <ChartTooltip
                    content={
                      <ChartTooltipContent />
                    }
                  />

                  <Line
                    type="monotone"
                    dataKey="loaded"
                    stroke="var(--color-loaded)"
                    strokeWidth={2}
                    dot={{
                        r: 4,
                        strokeWidth: 2,
                        fill: "var(--color-loaded)",
                    }}
                    activeDot={{
                        r: 6,
                    }}
                    />
                </LineChart>
              </ChartContainer>
            ) : (
              <p className="text-sm text-muted-foreground">
                No loading activity yet today.
              </p>
            )}
          </div>
        </DialogContent>
      </Dialog>

      {/* ====================================================== */}
      {/* EXPORT                                                   */}
      {/* ====================================================== */}

      <Dialog
        open={exportOpen}
        onOpenChange={setExportOpen}
      >
        <DialogContent className="max-w-sm">
          <DialogHeader>
            <DialogTitle>
              Export Loading Sessions
            </DialogTitle>
          </DialogHeader>

          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="text-xs font-medium text-muted-foreground">
                From
              </label>

              <input
                type="date"
                value={fromDate}
                max={toDate}
                onChange={(event) =>
                  setFromDate(
                    event.target.value,
                  )
                }
                className="mt-1 w-full rounded-lg border border-input bg-background px-3 py-2 text-sm text-foreground outline-none focus:ring-2 focus:ring-primary/30"
              />
            </div>

            <div>
              <label className="text-xs font-medium text-muted-foreground">
                To
              </label>

              <input
                type="date"
                value={toDate}
                min={fromDate}
                onChange={(event) =>
                  setToDate(
                    event.target.value,
                  )
                }
                className="mt-1 w-full rounded-lg border border-input bg-background px-3 py-2 text-sm text-foreground outline-none focus:ring-2 focus:ring-primary/30"
              />
            </div>
          </div>

          <p className="mt-3 text-sm text-muted-foreground">
            {exportCount} loading{" "}
            {exportCount === 1
              ? "session"
              : "sessions"}{" "}
            found
          </p>

          <button
            type="button"
            onClick={downloadExcel}
            disabled={exportCount === 0}
            className="mt-2 inline-flex w-full items-center justify-center gap-2 rounded-xl bg-primary py-2.5 text-sm font-semibold text-primary-foreground transition hover:bg-primary/90 disabled:cursor-not-allowed disabled:opacity-50"
          >
            <Download className="h-4 w-4" />
            Download Excel
          </button>
        </DialogContent>
      </Dialog>
    </>
  );
}