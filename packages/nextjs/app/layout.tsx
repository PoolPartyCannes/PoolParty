import "@rainbow-me/rainbowkit/styles.css";
import { ScaffoldEthAppWithProviders } from "~~/components/ScaffoldEthAppWithProviders";
import { ThemeProvider } from "~~/components/ThemeProvider";
import "~~/styles/globals.css";
import { getMetadata } from "~~/utils/scaffold-eth/getMetadata";

export const metadata = getMetadata({ title: "Scaffold-ETH 2 App", description: "Built with 🏗 Scaffold-ETH 2" });

const ScaffoldEthApp = ({ children }: { children: React.ReactNode }) => {
  return (
    <html suppressHydrationWarning>
      <body>
        <ThemeProvider enableSystem>
          <div className="relative min-h-screen overflow-hidden walrus-background">
            {/* Background layer */}
            <div
              className="absolute inset-0"
              style={{
                zIndex: 10,
                background: "linear-gradient(180deg, #36d1c4 0%, #1e90ff 100%)",
              }}
              aria-hidden={true}
            />
            {/* Walrus image */}
            <img
              src="/walrus_t.png"
              alt="Walrus background"
              style={{
                position: "absolute",
                right: "-20%",
                top: "-30%",
                width: "10000lh",
                height: "auto",
                zIndex: 11,
                opacity: 0.5,
                pointerEvents: "none",
                userSelect: "none",
              }}
              aria-hidden={true}
            />
            {/* Main content */}
            <div className="relative z-12">
              <ScaffoldEthAppWithProviders>{children}</ScaffoldEthAppWithProviders>
            </div>
          </div>
        </ThemeProvider>
      </body>
    </html>
  );
};

export default ScaffoldEthApp;
