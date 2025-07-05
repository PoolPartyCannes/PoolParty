"use client";

import { useEffect, useState } from "react";
import type { NextPage } from "next";
import { hardhat } from "viem/chains";
import { AddressInput } from "~~/components/scaffold-eth";
import { useFetchBlocks } from "~~/hooks/scaffold-eth";
import { useTargetNetwork } from "~~/hooks/scaffold-eth/useTargetNetwork";
import { notification } from "~~/utils/scaffold-eth";

const Migrate: NextPage = () => {
  const { error } = useFetchBlocks();
  const { targetNetwork } = useTargetNetwork();
  const [isLocalNetwork, setIsLocalNetwork] = useState(true);
  const [hasError, setHasError] = useState(false);

  const [poolPartyContractAddress, setPoolPartyContractAddress] = useState("");
  // const [foundPoolParty, setFoundPoolParty] = useState(false);

  useEffect(() => {
    if (targetNetwork.id !== hardhat.id) {
      setIsLocalNetwork(false);
    }
  }, [targetNetwork.id]);

  useEffect(() => {
    if (targetNetwork.id === hardhat.id && error) {
      setHasError(true);
    }
  }, [targetNetwork.id, error]);

  useEffect(() => {
    if (!isLocalNetwork) {
      notification.error(
        <>
          <p className="font-bold mt-0 mb-1">
            <code className="italic bg-base-300 text-base font-bold"> targetNetwork </code> is not localhost
          </p>
          <p className="m-0">
            - You are on <code className="italic bg-base-300 text-base font-bold">{targetNetwork.name}</code> .This
            block explorer is only for <code className="italic bg-base-300 text-base font-bold">localhost</code>.
          </p>
          <p className="mt-1 break-normal">
            - You can use{" "}
            <a className="text-accent" href={targetNetwork.blockExplorers?.default.url}>
              {targetNetwork.blockExplorers?.default.name}
            </a>{" "}
            instead
          </p>
        </>,
      );
    }
  }, [
    isLocalNetwork,
    targetNetwork.blockExplorers?.default.name,
    targetNetwork.blockExplorers?.default.url,
    targetNetwork.name,
  ]);

  useEffect(() => {
    if (hasError) {
      notification.error(
        <>
          <p className="font-bold mt-0 mb-1">Cannot connect to local provider</p>
          <p className="m-0">
            - Did you forget to run <code className="italic bg-base-300 text-base font-bold">yarn chain</code> ?
          </p>
          <p className="mt-1 break-normal">
            - Or you can change <code className="italic bg-base-300 text-base font-bold">targetNetwork</code> in{" "}
            <code className="italic bg-base-300 text-base font-bold">scaffold.config.ts</code>
          </p>
        </>,
      );
    }
  }, [hasError]);

  const handleLookupPoolParty = async () => {
    // console.log("Deploying party: ", dynamicInfo, identifier, tokenInfo);
    // try {
    //   await writeContractAsync({
    //     functionName: "deployParty",
    //     args: [
    //       dynamicInfo,
    //       identifier,
    //       tokenInfo,
    //       // migrationConfig,           // struct parameter
    //       // "0x742d35Cc6634C0532925a3b8D63C4CE4fF5e7a4c", // address parameter
    //       // BigInt("1000000000000000000"), // uint256 parameter (1 ETH)
    //     ],
    //     // value: BigInt("100000000000000000"), // 0.1 ETH if function is payable
    //   });
    // } catch (error) {
    //   console.error("Transaction failed:", error);
    // }
  };

  return (
    <div className="container mx-auto my-10 flex justify-center">
      <form
        onSubmit={handleLookupPoolParty}
        className="w-full md:w-3/4 lg:w-2/3 xl:w-1/2 bg-white dark:bg-base-100 text-base-content p-8 rounded-xl shadow-lg space-y-6"
      >
        <div className="flex items-center gap-4">
          <label className="w-40 text-right whitespace-nowrap">Contract Address</label>
          <AddressInput
            onChange={e => setPoolPartyContractAddress(e)}
            value={poolPartyContractAddress}
            placeholder="0x..."
          />
        </div>
      </form>

      {/* {foundPoolParty && 
      
      <form
        onSubmit={handleLookupPoolParty}
        className="w-full md:w-3/4 lg:w-2/3 xl:w-1/2 bg-white dark:bg-base-100 text-base-content p-8 rounded-xl shadow-lg space-y-6"
      >
        <div className="flex items-center gap-4">
          <label className="w-40 text-right whitespace-nowrap">Contract Address</label>
          <AddressInput
            onChange={e => setPoolPartyContractAddress(e)}
            value={poolPartyContractAddress}
            placeholder="0x..."
          />
        </div>
      </form>
      
      } */}
    </div>
  );
};

export default Migrate;
