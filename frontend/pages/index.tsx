import { NextPage } from "next";
import { useEffect, useState } from "react";
import { Toaster, toast } from "react-hot-toast";
import { AptosClient } from "aptos";

const getAptosWallet = () => {
  if ("aptos" in window) {
    return (window as any).aptos;
  } else {
    window.open("https://petra.app/", `_blank`);
  }
};

const isConnected = async () => {
  const r: boolean = await getAptosWallet().isConnected();
  return r;
};

const Home: NextPage = () => {
  const [walletInfo, setWalletInfo] =
    useState<{ address: string; publicKey: string }>();

  useEffect(() => {
    // Connect wallet on startup.
    const wallet = getAptosWallet();
    (async () => {
      if (await wallet.isConnected()) {
        setWalletInfo(await wallet.account());
      }
    })();
  }, []);

  const handleConnectWallet = async () => {
    const wallet = getAptosWallet();
    try {
      const response = await wallet.connect();
      console.log("Response", response);

      const account = await wallet.account();
      console.log(account);
      setWalletInfo(account);
    } catch (err) {
      console.error(err);
    }
  };
  const disconnectWallet = async () => {
    const wallet = getAptosWallet();
    await wallet.disconnect();
    setWalletInfo(undefined);
    toast.success("Wallet got disconnected.");
  };
  const handleCreateStorage = async () => {
    if (!(await isConnected())) {
      toast.error("Wallet is not connected.");
    }

    // Send the transaction.
    const transaction = {
      arguments: [walletInfo?.publicKey],
      function:
        "0x3b3f1ebdfed349c2c5dd79e06b942ec1de07818232a69e75379738557d476679::Fundraiser::publish_storage",
      type_arguments: ["signer"],
    };

    try {
      const pendingTransaction = await (
        window as any
      ).aptos.signAndSubmitTransaction(transaction);
      toast.success(pendingTransaction.hash);
      const client = new AptosClient("https://fullnode.devnet.aptoslabs.com");
      const txn = await client.waitForTransactionWithResult(
        pendingTransaction.hash
      );
      console.log(txn);
    } catch (err) {
      console.error("Error while sending transaction", err);
      toast.error("Error while sending transaction.");
    }
  };

  return (
    <>
      <Toaster position="top-right" />
      <nav>
        <h1>🚀 Fundraiser</h1>
        <button onClick={walletInfo ? disconnectWallet : handleConnectWallet}>
          {walletInfo
            ? walletInfo.address.slice(0, 4) +
              "..." +
              walletInfo.address.slice(
                walletInfo.address.length - 4,
                walletInfo.address.length
              )
            : "Connect Wallet"}
        </button>
      </nav>
      <br />
      <div>
        {/* For creating Storage for yourself. */}
        <p>
          Create `Storage` resource for yourself so that other you can start
          raising frunds.
        </p>
        <button onClick={handleCreateStorage}>Create `Storage`</button>
      </div>
    </>
  );
};

export default Home;
