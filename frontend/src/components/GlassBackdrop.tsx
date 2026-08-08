export function GlassBackdrop() {
  return (
    <div aria-hidden className="pointer-events-none fixed inset-0 -z-10 overflow-hidden bg-background">
      <div className="absolute -left-32 -top-40 h-[520px] w-[520px] rounded-full bg-primary/10 blur-[120px]" />
      <div className="absolute right-[-10%] top-[10%] h-[460px] w-[460px] rounded-full bg-sky-200/40 blur-[130px]" />
      <div className="absolute bottom-[-15%] left-[30%] h-[500px] w-[500px] rounded-full bg-slate-200/50 blur-[140px]" />
      <div className="absolute inset-0 bg-[radial-gradient(circle_at_50%_0%,rgba(255,255,255,0.9),rgba(255,255,255,0.4))]" />
    </div>
  );
}
