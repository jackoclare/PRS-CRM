import "./globals.css";
import { Public_Sans } from "next/font/google";
const font = Public_Sans({ subsets: ["latin"] });
export const metadata = { title: "FORGE CRM" };
export default function Root({ children }: { children: React.ReactNode }) {
  return <html lang="en-GB"><body className={font.className}>{children}</body></html>;
}
