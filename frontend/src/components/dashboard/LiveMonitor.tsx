import { useEffect, useState } from "react";
import { ANNOTATED_VIDEO_URL } from "@/lib/api";

function LiveClock() {
  const [now, setNow] = useState(new Date());
  useEffect(() => {
    const id = setInterval(() => setNow(new Date()), 1000);
    return () => clearInterval(id);
  }, []);
  return (
    <div className="absolute right-3 top-3 rounded-lg bg-black/45 px-2.5 py-1 font-mono text-[11px] font-medium text-white backdrop-blur-sm">
      {now.toLocaleTimeString([], { hour12: false })}
    </div>
  );
}

export function LiveMonitor() {
  return (
    <section className="glass glass-hover p-5">
      <div className="mb-4 flex items-center justify-between gap-3">
        <h2 className="text-base font-bold text-foreground">Live Loading Monitor</h2>
        <span className="inline-flex items-center gap-1.5 rounded-full border border-red-200/70 bg-red-50/70 px-2.5 py-1 text-[11px] font-semibold text-red-600 backdrop-blur-md">
          <span className="h-1.5 w-1.5 animate-pulse rounded-full bg-red-500" />
          LIVE
        </span>
      </div>

      {/* Real backend output: your trained model's actual YOLO+ByteTrack
          detections baked into the video during preprocessing (thin boxes,
          per-carton track ID, open_door box — no fixed line), re-encoded
          to H.264/yuv420p mp4 so it plays natively in every browser.
          (backend/app/video_preprocess.py) */}
      <div className="relative aspect-video w-full overflow-hidden rounded-2xl border border-white/70 bg-slate-900 shadow-inner">
        <video
          src={ANNOTATED_VIDEO_URL}
          autoPlay
          loop
          muted
          playsInline
          className="h-full w-full object-cover"
        />
        <div className="absolute bottom-3 left-3 rounded-lg bg-black/45 px-2.5 py-1 text-[11px] font-medium text-white backdrop-blur-sm">
          Camera 01 • Loading Bay 01
        </div>
        {/* System clock — the actual time on the machine running this
            browser tab, ticking every second. Recent Activity and Recent
            Loading Sessions below already render their timestamps with
            toLocaleTimeString(), i.e. the same local clock. */}
        <LiveClock />
      </div>
    </section>
  );
}
