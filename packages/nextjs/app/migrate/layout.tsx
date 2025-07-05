import { getMetadata } from "~~/utils/scaffold-eth/getMetadata";

export const metadata = getMetadata({
  title: "Migrate",
  description: "Migrate token",
});

const MigrateLayout = ({ children }: { children: React.ReactNode }) => {
  return <>{children}</>;
};

export default MigrateLayout;
