import { notFound } from "next/navigation";
const PHASES: Record<string, [string, string]> = {
  candidates: ["Candidates", "Phase 2"], clients: ["Clients", "Phase 2"], vacancies: ["Vacancies", "Phase 2"],
  "weekly-workforce": ["Weekly Workforce", "Phase 3"], timesheets: ["Timesheets", "Phase 4"],
  "job-alerts": ["Job Alerts", "Phase 6"], growth: ["Growth & Performance", "Phase 5"], tasks: ["Tasks", "Phase 2"],
  reports: ["Reports", "Phase 5"], finance: ["Finance", "Phase 5"], settings: ["Settings", "the next Phase 1 step"],
};
export default function Section({ params }: { params: { section: string } }) {
  const s = PHASES[params.section]; if (!s) notFound();
  return <><h1 className="text-2xl font-semibold">{s[0]}</h1><p className="mt-2 text-ink/70">This screen is built in {s[1]}.</p></>;
}
