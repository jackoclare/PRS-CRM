# FORGE CRM: Phase 1 (foundation)

Includes sign-in, roles, role-aware navigation, dashboard shell and the financial security foundation.
Not included yet: user management screen, candidates, clients and later phases. Dashboard tiles show "–" until then.

## Setup (about 20 minutes)
1. **Supabase:** open your project > SQL Editor > paste all of `supabase/migrations/0001_foundation.sql` > Run.
2. **First admin:** Authentication > Users > Add user (tick Auto confirm). Then edit the three values at the top of
   `supabase/bootstrap_first_admin.sql`, paste it into the SQL Editor and Run.
3. **Check security:** paste `supabase/tests/consultant_cannot_read_finance.sql` into the SQL Editor and Run.
   Under Messages every line must say PASS. It leaves no test data behind.
4. **GitHub:** create a private repository and upload this folder (do not upload any `.env` file).
5. **Vercel:** Add New > Project > pick the repository > add environment variables
   `NEXT_PUBLIC_SUPABASE_URL` and `NEXT_PUBLIC_SUPABASE_ANON_KEY` (Supabase > Project Settings > API) > Deploy.
6. Open the Vercel link and sign in with the email from step 2.

Never put the `service_role` key in GitHub or share it in chat. It is not needed for Phase 1.

## Run locally (optional)
Copy `.env.example` to `.env.local`, fill in the two values, run `npm install` then `npm run dev`.
