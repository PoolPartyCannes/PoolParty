"use client";

import { useEffect, useState } from "react";
import type { NextPage } from "next";
import { hardhat } from "viem/chains";
import { AddressInput, InputBase, IntegerInput } from "~~/components/scaffold-eth";
import { useFetchBlocks } from "~~/hooks/scaffold-eth";
import { useScaffoldWriteContract } from "~~/hooks/scaffold-eth";
import { useTargetNetwork } from "~~/hooks/scaffold-eth/useTargetNetwork";
import { notification } from "~~/utils/scaffold-eth";

// Interface for contract address with chain ID
interface ContractAddressInput {
  address: string;
  chainId: number | null;
  chainIdInput: string;
  chainIdError: string | null;
}

type DynamicInfo = {
  dynamicAddress: string;
  chainId: bigint;
};

const CreateMigraiton: NextPage = () => {
  const { error } = useFetchBlocks();
  const { targetNetwork } = useTargetNetwork();
  const [isLocalNetwork, setIsLocalNetwork] = useState(true);
  const [hasError, setHasError] = useState(false);
  const { writeContractAsync } = useScaffoldWriteContract({ contractName: "PoolPartyFactory", chainId: 31337 });
  const [contractAddressInputs, setContractAddressInputs] = useState<ContractAddressInput[]>([
    { address: "", chainId: null, chainIdInput: "", chainIdError: null },
  ]);
  const [newTokenName, setNewTokenName] = useState("");
  const [newTokenTicker, setNewTokenTicker] = useState("");
  const [newTokenDecimals, setNewTokenDecimals] = useState<number | null>(null);
  const [decimalsInput, setDecimalsInput] = useState(""); // input starts empty
  const [decimalsError, setDecimalsError] = useState<string | null>(null);
  const [newTokenSupply, setNewTokenSupply] = useState<number | null>(null);
  const [supplyInput, setSupplyInput] = useState<string>(""); // raw input as string
  const [supplyError, setSupplyError] = useState<string | null>(null);
  const [newContractCodeInput, setNewContractCodeInput] = useState("");
  const [newOwnable, setNewOwnable] = useState(Boolean);

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

  const handleContractAddressChange = (index: number, value: string) => {
    const newInputs = [...contractAddressInputs];
    newInputs[index].address = value;
    setContractAddressInputs(newInputs);
  };

  const handleChainIdChange = (index: number, value: string) => {
    const newInputs = [...contractAddressInputs];
    newInputs[index].chainIdInput = value;

    // Validate chain ID
    if (value.trim() === "") {
      newInputs[index].chainIdError = null;
      newInputs[index].chainId = null;
    } else {
      const parsed = Number(value);

      if (isNaN(parsed)) {
        newInputs[index].chainIdError = "Must be a valid number.";
        newInputs[index].chainId = null;
      } else if (!Number.isInteger(parsed)) {
        newInputs[index].chainIdError = "Must be an integer.";
        newInputs[index].chainId = null;
      } else if (parsed < 0) {
        newInputs[index].chainIdError = "Cannot be negative.";
        newInputs[index].chainId = null;
      } else {
        newInputs[index].chainIdError = null;
        newInputs[index].chainId = parsed;
      }
    }

    setContractAddressInputs(newInputs);
  };

  const addContractAddressInput = () => {
    setContractAddressInputs([
      ...contractAddressInputs,
      { address: "", chainId: null, chainIdInput: "", chainIdError: null },
    ]);
  };

  const removeContractAddressInput = (index: number) => {
    if (contractAddressInputs.length === 1) return; // prevent removing the last one
    const newInputs = contractAddressInputs.filter((_, i) => i !== index);
    setContractAddressInputs(newInputs);
  };

  const handleCreateMigration = async () => {
    const identifier = "iddy";
    const validContractInputs = contractAddressInputs.filter(
      input => input.address.trim() !== "" && input.chainId !== null,
    );

    const tokenInfo = {
      totalSupply: BigInt(newTokenSupply ?? 0),
      decimals: newTokenDecimals ?? 0,
      name: newTokenName ?? "",
      symbol: newTokenTicker ?? "",
      isOwnable: newOwnable ?? false,
    };

    const dynamicInfo: DynamicInfo[] = [];

    validContractInputs.forEach(function (value) {
      const newDynamicInfo: DynamicInfo = {
        dynamicAddress: value.address,
        chainId: BigInt(value.chainId ?? 0),
      };
      dynamicInfo.push(newDynamicInfo);
    });
    dynamicInfo.forEach(function (v) {
      console.log(v);
    });

    console.log("Deploying party: ", dynamicInfo, identifier, tokenInfo);

    try {
      await writeContractAsync({
        functionName: "deployParty",
        args: [
          dynamicInfo,
          identifier,
          tokenInfo,
          // migrationConfig,           // struct parameter
          // "0x742d35Cc6634C0532925a3b8D63C4CE4fF5e7a4c", // address parameter
          // BigInt("1000000000000000000"), // uint256 parameter (1 ETH)
        ],
        // value: BigInt("100000000000000000"), // 0.1 ETH if function is payable
      });
    } catch (error) {
      console.error("Transaction failed:", error);
    }
  };

  const handleDecimalsChange = (e: string) => {
    const value = e;
    setDecimalsInput(value);
    // Only validate if user has typed something
    if (value.trim() === "") {
      setDecimalsError(null);
      setNewTokenDecimals(null);
      return;
    }

    const parsed = Number(value);

    if (isNaN(parsed)) {
      setDecimalsError("Must be a valid number.");
      setNewTokenDecimals(null);
    } else if (!Number.isInteger(parsed)) {
      setDecimalsError("Must be an integer.");
      setNewTokenDecimals(null);
    } else if (parsed < 0) {
      setDecimalsError("Cannot be negative.");
      setNewTokenDecimals(null);
    } else {
      setDecimalsError(null); // ✅ valid
      setNewTokenDecimals(parsed);
    }
  };

  const handleSupplyChange = (e: string) => {
    const value = e;
    setSupplyInput(value);
    // Only validate if user has typed something
    if (value.trim() === "") {
      setSupplyError(null);
      setNewTokenSupply(null);
      return;
    }

    const parsed = Number(value);

    if (isNaN(parsed)) {
      setSupplyError("Must be a valid number.");
      setNewTokenSupply(null);
    } else if (!Number.isInteger(parsed)) {
      setSupplyError("Must be an integer.");
      setNewTokenSupply(null);
    } else if (parsed < 0) {
      setSupplyError("Cannot be negative.");
      setNewTokenSupply(null);
    } else {
      setSupplyError(null); // ✅ valid
      setNewTokenSupply(parsed);
    }
  };

  // const handleSubmit = (e: React.FormEvent) => {
  //   e.preventDefault();

  //   // Filter out empty contract addresses and prepare data for submission
  //   const validContractInputs = contractAddressInputs.filter(
  //     input => input.address.trim() !== "" && input.chainId !== null,
  //   );

  //   const dynamicInfoList: DynamicInfo[] = [];

  //   validContractInputs.forEach(function(value){
  //     const newDynamicInfo: DynamicInfo = {
  //       dynamicAddress: value.address,
  //       chainId: BigInt(value.chainId ?? 0),
  //     };
  //     dynamicInfoList.push(newDynamicInfo);
  //   })

  //   console.log(dynamicInfoList);

  //   console.log(
  //     "Submitted values:",
  //     validContractInputs,
  //     newTokenName,
  //     newTokenTicker,
  //     newTokenDecimals,
  //     newTokenSupply,
  //     newContractCodeInput,
  //     newOwnable,
  //   );
  // };

  return (
    <div className="container mx-auto my-10">
      <form
        onSubmit={handleCreateMigration}
        className="border-primary bg-base-100 text-base-content placeholder:text-base-content/50 p-2 mr-2 w-full md:w-1/2 lg:w-1/3 rounded-md shadow-md focus:outline-hidden focus:ring-2 focus:ring-accent"
      >
        {contractAddressInputs.map((contractInput, index) => (
          <div key={index} className="mb-4 p-3 border rounded-lg">
            <div className="flex gap-2 items-center mb-2">
              <label>Contract Address</label>
              <AddressInput
                onChange={e => handleContractAddressChange(index, e)}
                value={contractInput.address}
                placeholder="0x..."
              />
              {contractAddressInputs.length > 1 && (
                <button
                  type="button"
                  onClick={() => removeContractAddressInput(index)}
                  className="btn btn-sm btn-primary"
                >
                  ✕
                </button>
              )}
            </div>

            <div className="flex gap-2 items-center">
              <label>Chain ID</label>
              <IntegerInput
                value={contractInput.chainIdInput}
                onChange={e => handleChainIdChange(index, e)}
                placeholder="e.g. 1 (Ethereum)"
              />
            </div>
            {contractInput.chainIdError && (
              <span className="text-sm text-red-600 mt-1 block">{contractInput.chainIdError}</span>
            )}
          </div>
        ))}

        <button type="button" onClick={addContractAddressInput} className="btn btn-sm btn-primary mb-4">
          + Add another token to migrate
        </button>

        <div className="flex gap-2 items-center">
          <label>New Token Name</label>
          <InputBase value={newTokenName} onChange={e => setNewTokenName(e)} />
        </div>

        <div className="flex gap-2 items-center">
          <label>New Token Ticker</label>
          <InputBase value={newTokenTicker} onChange={e => setNewTokenTicker(e)} />
        </div>

        <div className="flex gap-2 items-center">
          <label>New Token Decimals</label>
          <IntegerInput value={decimalsInput} onChange={e => handleDecimalsChange(e)} />

          {decimalsError && <span className="text-sm text-red-600">{decimalsError}</span>}
        </div>

        <div className="flex gap-2 items-center">
          <label>New Token Supply</label>
          <IntegerInput value={supplyInput} onChange={e => handleSupplyChange(e)} />

          {supplyError && <span className="text-sm text-red-600">{supplyError}</span>}
        </div>

        <div className="flex gap-2 items-center">
          <label>New contract logic</label>
          <InputBase value={newContractCodeInput} onChange={e => setNewContractCodeInput(e)} />
        </div>

        <div className="flex gap-2 items-center">
          <label>
            <input type="checkbox" checked={newOwnable} onChange={e => setNewOwnable(e.target.checked)} />
            Ownable
          </label>
        </div>

        <button type="submit" className="btn btn-sm btn-primary">
          Submit
        </button>
      </form>
    </div>
  );
};

export default CreateMigraiton;
