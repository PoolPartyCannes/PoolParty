"use client";

import { useEffect, useState } from "react";
import type { NextPage } from "next";
import { hardhat } from "viem/chains";
import { AddressInput, InputBase, IntegerInput } from "~~/components/scaffold-eth";
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
  const { targetNetwork } = useTargetNetwork();
  const [isLocalNetwork, setIsLocalNetwork] = useState(true);
  const { writeContractAsync: writeYourContractAsync } = useScaffoldWriteContract({ contractName: "PoolPartyFactory" });
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

  const handleCreateMigration = async (e: React.FormEvent) => {
    e.preventDefault();
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
      await writeYourContractAsync({
        functionName: "testy",
        args: ["f8w9fwj3fosfjslfjsod8fus0d8fus083fjs3f"],
      });
    } catch (error) {
      console.error("Transaction failed:", error);
    }
  };

  const handleDecimalsChange = (e: string) => {
    const value = e;
    setDecimalsInput(value);
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
      setDecimalsError(null);
      setNewTokenDecimals(parsed);
    }
  };

  const handleSupplyChange = (e: string) => {
    const value = e;
    setSupplyInput(value);
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
      setSupplyError(null);
      setNewTokenSupply(parsed);
    }
  };

  return (
    <div className="container mx-auto my-10 flex flex-col items-center justify-center">
      <div>
        <span className="block text-5xl font-bold mb-30 text-white">Create a new Token Migration</span>
      </div>
      <form
        onSubmit={handleCreateMigration}
        className="w-full md:w-3/4 lg:w-2/3 xl:w-1/2 bg-white bg-base-100 text-base-content p-8 rounded-xl shadow-lg space-y-6"
      >
        {contractAddressInputs.map((contractInput, index) => (
          <div key={index} className="border rounded-lg p-4 space-y-4">
            <div className="flex items-center gap-4">
              <label className="w-40 text-right whitespace-nowrap">Contract Address</label>
              <AddressInput
                onChange={e => handleContractAddressChange(index, e)}
                value={contractInput.address}
                placeholder="0x..."
              />
              {contractAddressInputs.length > 1 && (
                <button
                  type="button"
                  onClick={() => removeContractAddressInput(index)}
                  className="btn btn-sm btn-outline btn-error"
                >
                  ✕
                </button>
              )}
            </div>

            <div className="flex items-center gap-4">
              <label className="w-40 text-right whitespace-nowrap">Chain ID</label>
              <IntegerInput
                value={contractInput.chainIdInput}
                onChange={e => handleChainIdChange(index, e)}
                placeholder="e.g. 1 (Ethereum)"
              />
            </div>

            {contractInput.chainIdError && <p className="text-sm text-red-600 ml-44">{contractInput.chainIdError}</p>}
          </div>
        ))}

        <div className="flex justify-end">
          <button type="button" onClick={addContractAddressInput} className="btn btn-primary btn-sm">
            + Add another token to migrate
          </button>
        </div>
        <div className="space-y-4">
          <div className="flex items-center gap-4">
            <label className="w-40 text-right whitespace-nowrap">New Token Name</label>
            <InputBase value={newTokenName} onChange={e => setNewTokenName(e)} placeholder="Pool Party Coin" />
          </div>

          <div className="flex items-center gap-4">
            <label className="w-40 text-right whitespace-nowrap">New Token Ticker</label>
            <InputBase value={newTokenTicker} onChange={e => setNewTokenTicker(e)} placeholder="PP" />
          </div>

          <div className="flex items-center gap-4">
            <label className="w-40 text-right whitespace-nowrap">New Token Decimals</label>
            <IntegerInput value={decimalsInput} onChange={handleDecimalsChange} placeholder="18" />
            {decimalsError && <p className="text-sm text-red-600">{decimalsError}</p>}
          </div>

          <div className="flex items-center gap-4">
            <label className="w-40 text-right whitespace-nowrap">New Token Supply</label>
            <IntegerInput value={supplyInput} onChange={handleSupplyChange} placeholder="10000000" />
            {supplyError && <p className="text-sm text-red-600">{supplyError}</p>}
          </div>

          <div className="flex items-center gap-4">
            <label className="w-40 text-right whitespace-nowrap">New Contract Logic</label>
            <InputBase value={newContractCodeInput} onChange={e => setNewContractCodeInput(e)} />
          </div>

          <div className="flex items-center gap-4">
            <label className="w-40 text-right">Ownable</label>
            <input
              type="checkbox"
              checked={newOwnable}
              onChange={e => setNewOwnable(e.target.checked)}
              className="toggle toggle-primary"
            />
          </div>
        </div>

        <div className="flex justify-end">
          <button type="submit" className="btn btn-primary">
            Create Migration
          </button>
        </div>
      </form>
    </div>
  );
};

export default CreateMigraiton;
