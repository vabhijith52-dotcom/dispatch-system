import { LayoutDashboard, LogOut, Truck, X } from "lucide-react";

export function DashboardSidebar({
  onLogout,
  onClose,
}: {
  onLogout: () => void;
  onClose?: () => void;
}) {
  return (
    <aside className="glass flex h-full w-64 shrink-0 flex-col rounded-none border-y-0 border-l-0 p-5 lg:rounded-2xl lg:border">
      <div className="flex items-center gap-2.5">
        <div className="grid h-9 w-9 shrink-0 place-items-center rounded-xl bg-primary/10 text-primary ring-1 ring-primary/15">
          <Truck className="h-4.5 w-4.5" />
        </div>
        <span className="min-w-0 truncate text-sm font-bold text-foreground">Truck Loading AI</span>
        {onClose && (
          <button
            onClick={onClose}
            aria-label="Close menu"
            className="ml-auto shrink-0 rounded-lg p-1.5 text-muted-foreground transition hover:bg-white/60 lg:hidden"
          >
            <X className="h-4 w-4" />
          </button>
        )}
      </div>

      <nav className="mt-8">
        <p className="px-3 text-[10px] font-semibold uppercase tracking-widest text-muted-foreground">
          Menu
        </p>
        <a
          href="/dashboard"
          className="mt-2 flex items-center gap-3 rounded-xl bg-primary/10 px-3 py-2.5 text-sm font-semibold text-primary ring-1 ring-primary/10"
        >
          <LayoutDashboard className="h-4 w-4" />
          Dashboard
        </a>
      </nav>

      <div className="mt-auto space-y-3 pt-6">
        <div className="flex items-center gap-3 rounded-xl border border-white/70 bg-white/50 px-3 py-2.5 backdrop-blur-md">
          <div className="grid h-9 w-9 shrink-0 place-items-center rounded-full bg-primary/15 text-xs font-bold text-primary">
            AD
          </div>
          <div className="min-w-0">
            <p className="truncate text-sm font-semibold text-foreground">Admin</p>
            <p className="truncate text-xs text-muted-foreground">Administrator</p>
          </div>
        </div>
        <button
          onClick={onLogout}
          className="flex w-full items-center gap-3 rounded-xl px-3 py-2.5 text-sm font-medium text-muted-foreground transition hover:bg-destructive/5 hover:text-destructive"
        >
          <LogOut className="h-4 w-4" />
          Logout
        </button>
      </div>
    </aside>
  );
}
