import Link from "next/link";
const TILES = [
  ["Jobs to fill", "/vacancies", "Phase 2"], ["New candidates", "/candidates", "Phase 2"],
  ["Current hours this week", "/weekly-workforce", "Phase 3"], ["New job alerts", "/job-alerts", "Phase 6"],
  ["Active clients", "/clients", "Phase 2"], ["Active temporary workers", "/weekly-workforce", "Phase 3"],
  ["Interviews", "/tasks", "Phase 2"], ["Tasks and follow-ups", "/tasks", "Phase 2"],
];
export default function Dashboard() {
  return (
    <>
      <h1 className="text-2xl font-semibold mb-1">Dashboard</h1>
      <p className="text-sm text-ink/70 mb-6">Live figures appear here as each part of FORGE is built. Nothing below is demo data.</p>
      <div className="grid gap-3 sm:grid-cols-2 xl:grid-cols-4">
        {TILES.map(([label, href, phase]) => (
          <Link key={label} href={href} className="bg-white border border-line rounded-md p-4 hover:border-steel">
            <div className="text-sm text-ink/70">{label}</div>
            <div className="text-3xl font-semibold mt-1">–</div>
            <div className="text-xs text-ink/60 mt-2">Available in {phase}</div>
          </Link>))}
      </div>
    </>
  );
}
