import Link from "next/link";
import { redirect } from "next/navigation";
import { supabaseServer } from "@/lib/supabase/server";

const NAV: [string, string][] = [
  ["Dashboard", "/dashboard"], ["Candidates", "/candidates"], ["Clients", "/clients"], ["Vacancies", "/vacancies"],
  ["Weekly Workforce", "/weekly-workforce"], ["Timesheets", "/timesheets"], ["Job Alerts", "/job-alerts"],
  ["Growth & Performance", "/growth"], ["Tasks", "/tasks"], ["Reports", "/reports"],
];

async function signOut() { "use server"; await supabaseServer().auth.signOut(); redirect("/login"); }

export default async function AppLayout({ children }: { children: React.ReactNode }) {
  const sb = supabaseServer();
  const { data: { user } } = await sb.auth.getUser();
  if (!user) redirect("/login");
  const [{ data: profile }, { data: role }, { data: fin }] = await Promise.all([
    sb.from("users").select("full_name").eq("id", user.id).maybeSingle(),
    sb.from("user_roles").select("role").eq("user_id", user.id).maybeSingle(),
    sb.rpc("has_financial_access"),
  ]);
  if (!role) return <main className="p-8">Your account has no role yet. Ask your Super Admin to set it up.</main>;
  const items: [string, string][] = [...NAV, ...(fin ? [["Finance", "/finance"] as [string, string]] : []),
    ...(role.role === "super_admin" ? [["Settings", "/settings"] as [string, string]] : [])];
  const menu = items.map(([label, href]) => (
    <Link key={href} href={href} className="block rounded px-3 py-2 text-sm hover:bg-white/10">{label}</Link>));
  return (
    <div className="md:flex min-h-screen">
      <aside className="hidden md:flex md:w-60 shrink-0 flex-col bg-ink text-white p-4">
        <div className="text-lg font-semibold px-3 pb-4">FORGE</div>
        <nav className="space-y-1 flex-1">{menu}</nav>
        <form action={signOut}><p className="px-3 text-xs opacity-70">{profile?.full_name} ({role.role.replace("_", " ")})</p>
          <button className="mt-1 px-3 py-2 text-sm underline">Sign out</button></form>
      </aside>
      <details className="md:hidden bg-ink text-white p-3"><summary className="font-semibold cursor-pointer">FORGE menu</summary>
        <nav className="mt-2">{menu}</nav>
        <form action={signOut}><button className="px-3 py-2 text-sm underline">Sign out</button></form></details>
      <main className="flex-1 p-4 md:p-8">{children}</main>
    </div>
  );
}
