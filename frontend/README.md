# Truck Loading AI — Frontend

Vite + React + TypeScript + TanStack Router + Tailwind CSS v4, using a light
glassmorphism design system. Talks to the FastAPI + Postgres backend in
`../backend` — no mock data, no Lovable dependency.

See the top-level setup guide (shared alongside this project) for full
instructions. Quick start:

```sh
npm install
npm run dev
```

Runs on http://localhost:5173 and expects the backend at http://localhost:8000
(see `../backend/README` equivalent — the setup doc — for how to start it).

## Structure

- `src/routes/` — TanStack Router file-based routes (`index.tsx` = login,
  `dashboard.tsx` = main dashboard)
- `src/components/dashboard/` — dashboard-specific UI (sidebar, live monitor)
- `src/components/ui/` — shadcn/ui-style primitives (Radix + Tailwind)
- `src/lib/api.ts` — the only place that talks to the backend (fetch + JWT)
