import { getMetadata } from "~~/utils/scaffold-eth/getMetadata";

export const metadata = getMetadata({
  title: "Create Migration",
  description: "Create a new token migration",
});

const CreateMigrationLayout = ({ children }: { children: React.ReactNode }) => {
  return <>{children}</>;
};

export default CreateMigrationLayout;
