import { redirect } from "next/navigation";
import { supabaseServer } from "@/lib/supabase/server";

async function signIn(formData: FormData) {
  "use server";
  const { error } = await supabaseServer().auth.signInWithPassword({
    email: String(formData.get("email")), password: String(formData.get("password")),
  });
  if (error) redirect("/login?error=1");
  redirect("/dashboard");
}

export default function Login({ searchParams }: { searchParams: { error?: string } }) {
  return (
    <main className="min-h-screen grid place-items-center p-6">
      <form action={signIn} className="w-full max-w-sm space-y-4 bg-white border border-line rounded-md p-6">
        <h1 className="text-2xl font-semibold">Sign in to FORGE</h1>
        {searchParams.error && <p role="alert" className="text-sm text-red-700">Email or password is incorrect. Check them and try again.</p>}
        <label className="block text-sm">Email
          <input name="email" type="email" required autoComplete="email" className="mt-1 w-full border border-line rounded px-3 py-2" /></label>
        <label className="block text-sm">Password
          <input name="password" type="password" required autoComplete="current-password" className="mt-1 w-full border border-line rounded px-3 py-2" /></label>
        <button className="w-full bg-ink text-white rounded py-2 font-medium">Sign in</button>
      </form>
    </main>
  );
}
